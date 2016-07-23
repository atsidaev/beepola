unit AsmPass2;

interface

uses AsmUtils,AsmTypes;

function SecondPassASMLine(s: string; sFile: string; iLine: integer;
                           var regPC: integer; var sOut: string;
                           Encoding: TCharEncoding): integer;

implementation

uses SysUtils, Assemb;

{ ParseAsmDirective

  IN:     sOp     - OpCode, eg. "LD", "NOP", "JR", "BIT"
  IN:     sParam  - Parameters, eg. "A,62", "", "print-a", "1,B"
  IN:     sFile   - Name of file being processed (name only, not path)
  IN:     iLine   - Line number being processed, within sFile.
  IN/OUT: regPC   - Current assembly address - modified as necessary after the
                    line has been parsed to point to the address of the next instr
  OUT:    sOut    - Assembled Binary for the line
  RETURNS:      -  0 = no errors, 1 = Warning, 2 = Error, 3 = Internal failure
}
function ParseAsmDirective(sOp,sParam: string; sFile: string; iLine: integer;
                           var regPC: integer; var sOut: string;
                           Encoding: TCharEncoding): integer;
var
  i: integer;
begin
  // ORG
  if (sOp = 'ORG') or (sOP = '.ORG') then
  begin
    if (sParam[1] = '$') or ( UpperCase(sParam[Length(sParam)]) = 'H') then
    begin
      if not HexToDecimal(sParam,i) then
      begin
        Result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Invalid origin. Unable to parse hex value.');
        exit;
      end;
    end
    else if sParam[1] = '%' then
    begin
      if not BinToDecimal(sParam,i) then
      begin
        Result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Invalid origin. Unable to parse binary value.');
        exit;
      end;
    end
    else
      i := StrToIntDef(sParam,-1);

    if regPC > 0 then
    begin
      if i < regPC then
      begin
        // Generate error: org value set lower than current assembly location
        Result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Attempt to set origin lower than current assembly location.');
        exit;
      end;
    end;

    if (i < 0) or (i> 65535) then
    begin
      Result := 2;
      AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                       ': Origin must be in the range 0 - 65535.');
      exit;
    end;

    regPC := i;
    Result := 0;
    exit;
  end;

  // EQU
  if (sOp = 'EQU') or (sOp = '.EQU') then
  begin
    if (sParam[1] = '$') or ( UpperCase(sParam[Length(sParam)]) = 'H') then
      if not HexToDecimal(sParam,i) then
      begin
        Result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Invalid hex value.');
        exit;
      end
    else if sParam[1] = '%' then
      if not BinToDecimal(sParam,i) then
      begin
        Result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Invalid binary value.');
        exit;
      end
    else
      i := StrToIntDef(sParam,-32769);

    if (i < -32768) or (i > 65535) then
    begin
      Result := 2;
      AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                       ': Value overflows word.');
    end
    else
    begin
      Result := ($08000000 Or i); // Special return code instructing the
                                  // calling procedure to add
                                  // label=(Result and $FFFF) rather than
                                  // label=regPC
    end;
    exit;
  end;

  // DEFB/BYTE/DB
  if (sOp = 'DEFB') or (sOp = '.DEFB') or (sOp = 'BYTE') or (sOp = '.BYTE') or
     (sOp = 'DEFM') or (sOp = '.DEFM') then
  begin
    // sParam contains either a single byte or a comma separated list to add
    // to sOut
    Result := AsmDirDEFB(sParam,sFile,iLine,regPC,sOut,Encoding);
    exit;
  end;

  // DEFW/WORD/DB
  if (sOp = 'DEFW') or (sOp = '.DEFW') or (sOp = 'WORD') or (sOp = '.WORD') then
  begin
    // sParam contains either a single byte or a comma separated list to add
    // to sOut
    Result := AsmDirDEFW(sParam,sFile,iLine,regPC,sOut,Encoding);
    exit;
  end;

 Result := 4; // 4 = Not a supported ASM directive
end;

function IsIndexedInstruction(sParam: string): boolean;
begin
  if (Copy(sParam,1,3) = '(IX') or (Copy(sParam,1,3) = '(IY') or
     (Copy(sParam,2,4) = ',(IX') or (Copy(sParam,2,4) = ',(IY') then
    Result := true
  else
    Result := false;
end;

function ParseOpCode(sOp,sParam: string; sFile: string; iLine: integer;
                     var regPC: integer; var sOut: string;
                     Encoding: TCharEncoding): integer;
var
  i: integer;
  sParamU, sMid: string;
  sEval: string;
  iEval: integer;
begin
  sParamU := UpperCase(sParam);

  // Scan for static (no params) instructions
  for i := 1 to Length(ASMInfo)-1 do
  begin
    if (sOp = ASMInfo[i].sOperator) and (sParamU = ASMInfo[i].sOperand) then
    begin
      // Static instruction matched
      sOut := ASMInfo[i].sOut;
      regPC := regPC + Length(sOut);
      Result := 0;
      exit;
    end;
  end;

  // Scan for parametized instructions
  for i := 1 to Length(ASMInfo)-1 do
  begin
    // Instruction contains a '?' parameter, which is a relative jump offset
    if (sOp = ASMInfo[i].sOperator) and (Pos('?',ASMInfo[i].sOperand)>0) then
    begin
      if (Copy(sParamU,1,Pos('?',ASMInfo[i].sOperand)-1) =
         Copy(ASMInfo[i].sOperand,1,Pos('?',ASMInfo[i].sOperand)-1)) and
         (Copy(ASMInfo[i].sOperand,Pos('?',ASMInfo[i].sOperand)+1,512) =
          Copy(sParamU,1+Length(sParamU)-Length(Copy(ASMInfo[i].sOperand,Pos('?',ASMInfo[i].sOperand)+1,512)),512)) then
      begin
        sOut := ASMInfo[i].sOut;

        sEval := Copy(sParam,Pos('?',ASMInfo[i].sOperand),512);
        sEval := Copy(sEval,
                     1,
                     Length(sEval)-(Length(ASMInfo[i].sOperand)-Pos('?',ASMInfo[i].sOperand)));
        regPC := regPC + Length(sOut) + ASMInfo[i].iParamBytes;

        if ASMInfo[i].iParamBytes <> 1 then
        begin
          AssemblerDisplay('[CPU Table Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Instruction for relative jump should only have 1 parameter byte.');
          Result := 3;
          exit;
        end;

        // Evaluate sEval and tag the appropriate value (1 byte offet)
        // onto sOut
        if IsIndexedInstruction(sParamU) then
        begin
          case Evaluate(true, sEval, 0, Encoding, iEval) of
          0:
            begin
              if (iEval < -128) or (iEval > 127) then
              begin
                AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                             ': Index register offset too far.');
                Result := 2;
                exit;
              end;

              if iEval < 0 then Inc(iEval,256);

              sOut := sOut + Chr(iEval and $FF);

              if (Length(sOut) = 4) and ((Copy(sOut,1,2) = #$DD#$CB) or (Copy(sOut,1,2) = #$FD#$CB)) then
                sOut := Copy(sOut,1,2) + sOut[4] + sOut[3];

              Result := 0;
            end;
          1:
            begin
              AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                           ': Index register offset jump too far.');
              Result := 2;
            end;
          2:
            begin
              AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                           ': Index reference to undefined label.');
              Result := 2;
            end;
          else
            Result := 3;
          end;
        end
        else
        begin
          case Evaluate(true, sEval, regPC, Encoding, iEval) of
          0:
            begin
              if (Copy(sParamU,1,3) <> '(IX') and (Copy(sParamU,1,3) <> '(IY') and
                 (Copy(sParamU,2,4) <> ',(IX') and (Copy(sParamU,2,4) <> ',(IY') and
                 ((iEval - regPC) < -128) or ((iEval - regPC) > 127) then
              begin
                AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                             ': Relative jump too far.');
                Result := 2;
                exit;
              end;

              if (Copy(sParamU,1,3) <> '(IX') and (Copy(sParamU,1,3) <> '(IY') then
                iEval := iEval - regPC;

              if iEval < 0 then Inc(iEval,256);

              sOut := sOut + Chr(iEval and $FF);

              if (Length(sOut) = 4) and ((Copy(sOut,1,2) = #$DD#$CB) or (Copy(sOut,1,2) = #$FD#$CB)) then
                sOut := Copy(sOut,1,2) + sOut[4] + sOut[3];

              Result := 0;
            end;
          1:
            begin
              AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                           ': Relative jump too far.');
              Result := 2;
            end;
          2:
            begin
              AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                           ': Relative jump to undefined label.');
              Result := 2;
            end;
          else
            Result := 3;
          end;
        end;

        exit;
      end;

      if ( Copy(sParamU,1,Pos('?',ASMInfo[i].sOperand)-1) =
           Copy(ASMInfo[i].sOperand,1,Pos('?',ASMInfo[i].sOperand)-1)) and
         (ASMInfo[i].sOperand[Length(ASMInfo[i].sOperand)]='*') then
      begin
        // (IX?),*
        sMid := Copy(ASMInfo[i].sOperand,Pos('?',ASMInfo[i].sOperand)+1,512);
        sMid := Copy(sMid,1,Length(sMid)-1);
        // ),

        if Pos(sMid,sParamU) > Pos('?',ASMInfo[i].sOperand) then
        begin
          // (IX+$20),$32
          sOut := ASMInfo[i].sOut;
          Inc(regPC,Length(sOut) + ASMInfo[i].iParamBytes);

          sEval := Copy(sParam,Pos('?',ASMInfo[i].sOperand),512);
          // +$20),$32
          sEval := Copy(sEval,1,Pos(sMid,sEval)-1);

          // Evaluate sEval and tag the appropriate value (1 byte offet)
          // onto sOut
          case Evaluate(true, sEval, 0, Encoding, iEval) of
          0:
            begin
              if ((iEval  < -128) or (iEval > 127)) then
              begin
                AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                             ': Index offset too far.');
                Result := 2;
                exit;
              end;

              if iEval < 0 then Inc(iEval,256);

              sOut := sOut + Chr(iEval and $FF);
            end;
          1:
            begin
              AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                           ': Index offset too far.');
              Result := 2;
              exit;
            end;
          2:
            begin
              AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                           ': Relative jump to undefined label.');
              Result := 2;
              exit;
            end;
          else
          begin
            Result := 3;
            exit;
          end;
          end;

          sEval := Copy(sParam,Pos(sMid,sParamU)+Length(sMid),512);

          case Evaluate(true, sEval, regPC, Encoding, iEval) of
          0:
            begin
              sOut := sOut + Char(iEval and $FF);
              Result := 0;
            end;
          else
            Result := 3;
          end;

          exit;
        end;
      end;
    end;

    if (sOp = ASMInfo[i].sOperator) and (Pos('*',ASMInfo[i].sOperand)>0) then
    begin
      if (Copy(sParamU,1,Pos('*',ASMInfo[i].sOperand)-1) =
         Copy(ASMInfo[i].sOperand,1,Pos('*',ASMInfo[i].sOperand)-1)) and
         (Copy(ASMInfo[i].sOperand,Pos('*',ASMInfo[i].sOperand)+1,512) =
          Copy(sParamU,1+Length(sParamU)-Length(Copy(ASMInfo[i].sOperand,Pos('*',ASMInfo[i].sOperand)+1,512)),512)) then
      begin
        sOut := ASMInfo[i].sOut;

        sEval := Copy(sParam,Pos('*',ASMInfo[i].sOperand),512);
        sEval := Copy(sEval,
                     1,
                     Length(sEval)-(Length(ASMInfo[i].sOperand)-Pos('*',ASMInfo[i].sOperand)));
        // Evaluate sEval and tag the appropriate value (1 or 2 bytes)
        // onto sOut
        case Evaluate(true,sEval, regPC, Encoding, iEval) of
        1:
          begin
            // Invalid parameter value
            AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Invalid parameter value.');
            Result := 2;
            exit;
          end;
        2:
          begin
            // Label not defined
            AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Label not defined.');
            Result := 2;
            exit;
          end;
        3:
          begin
            // Error evaluating parameters
            AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Unable to evaluate parameter(s).');
            Result := 2;
            exit;                                     
          end;
        end;

        case ASMInfo[i].iParamBytes of
        1:
          sOut := sOut + Char(iEval and $FF);
        2:
          sOut := sOut + Char(iEval and $FF) + Char(iEval div 256);
        end;

        regPC := regPC + Length(sOut);
        Result := 0;
        exit;
      end;
    end;
  end;

  Result := 4;
end;


{ SecondPassASMLine

  Second pass of processing a line of assembly. Procudes any binary output for
  the line in sOut.

  IN:  s     - Line of assembler to process
  IN:  sFile - Name of file being processed
  IN:  iLine - Number of line being processed.
  OUT: regPC - Full name of output file to create.
  OUT: sOut  - Binary output for the instruction
  RETURNS:   - 0 = no errors, 1 = Warning, 2 = Error, 3 = Internal failure
}
{$WARNINGS OFF} // Stop D2007 ERRONEOUSLY emitting 'bInString might not be initialized' warning below
function SecondPassASMLine(s: string; sFile: string; iLine: integer;
                           var regPC: integer; var sOut: string;
                           Encoding: TCharEncoding): integer;
var
  sOperator: string;
  i: integer;
  bInString, bInChar: boolean;
begin
  // First, strip off any comment text
  if Pos(';',Trim(s)) = 1 then
  begin
    // This is only a comment line, okay it
    Result := 0;
    exit;
  end
  else if (Pos(';',s)>1) then
    // Cope with about semi-colons in strings and as character literals
    // ("Hello;World" or ';')
    bInString := false;
    bInChar := false;
    for i := 1 to Length(s) do
    begin
      if s[i] = '"' then
        bInString := not bInString;
      if s[i] = '''' then
        bInChar := not bInChar;
      if (s[i] = '''') and (i >= 10) and (UpperCase(Copy(s,i-5,6)) = 'AF,AF''') and bInChar then
        bInChar := not bInChar; // Special case to deal with the quote char in ex af,af' which is NOT a char literal identifier
      if (s[i] = ';') and (not bInString) and (not bInChar) then
      begin
        s:=Copy(s,1,i-1);
        break;
      end;
    end;

  if (Length(s)>0) and ((s[1]=' ') or (s[1]=#9)) then
  begin
    // No Label
    s := Trim(s);
  end
  else
  begin
    // Label found
    if (Pos(' ',s)>1) then
    begin
      // Label + Possibly an instruction
      s := Trim(Copy(s,Pos(' ',s)+1,512));
    end
    else if (Pos(#9,s)>1) then
    begin
      s := Trim(Copy(s,Pos(#9,s)+1,512));
    end
    else    
      s := '';
  end;

  { Right, we now have:-

     s      = Full instruction or directive if one is present on the line,
              including any parameters.
  }
  if (Pos(' ',s)>0) then
  begin
    sOperator := UpperCase(Copy(s,1,Pos(' ',s)-1));
    s := Trim(Copy(s,Pos(' ',s)+1,512));
  end
  else if Pos(#9,s)>0 then
  begin
    sOperator := UpperCase(Copy(s,1,Pos(#9,s)-1));
    s := Trim(Copy(s,Pos(#9,s)+1,512));
  end
  else
  begin
    sOperator := UpperCase(s);
    s := '';
  end;

  // If label exists, return an error
  // Check Operator against assembler directives
  i := ParseAsmDirective(sOperator,s,sFile,iLine,regPC,sOut,Encoding);
  if (i And $08000000) > 0 then i := 0;

  if (i < 4) then
  begin
    // Line contained an ASM directive which we've processed or an error
    Result := i;
    exit;
  end;

  // if there's no opcode then this is a label-only line, exit ok
  if (sOperator = '') then
  begin
    Result := 0;
    exit;
  end;

  // Now the label, if present, has been recorded, and we know the line doesn't
  // contain an ASM directive, so it either contains an opcode or an error!
  i := ParseOpCode(sOperator,s,sFile,iLine,regPC,sOut,Encoding);

  if (i < 4) then
  begin
    Result := i;
    exit;
  end;

  Result := 2;  // ERROR not an asm directive or an opcode or a comment or a blank line!
end;
{$WARNINGS ON}  // Turn warnings back on

end.
