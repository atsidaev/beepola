unit AsmPass1;

interface

uses AsmUtils,AsmTypes;

function FirstPassASMLine(s: string; sFile: string; iLine: integer; var regPC: integer; Encoding: TCharEncoding): integer;

implementation

uses SysUtils, Assemb;

{ ParseAsmDirective

  IN:     sOp     - OpCode, eg. "LD", "NOP", "JR", "BIT"
  IN:     sParam  - Parameters, eg. "A,62", "", "print-a", "1,B"
  IN:     sFile   - Name of file being processed (name only, not path)
  IN:     iLine   - Line number being processed, within sFile.
  IN/OUT: regPC   - Current assembly address - modified as necessary after the
                    line has been parsed to point to the address of the next instr

  RETURNS:      -  0 = no errors, 1 = Warning, 2 = Error, 3 = Internal failure
}
function ParseAsmDirective(sOp,sParam: string; sFile: string; iLine: integer;
                           var regPC: integer; Encoding: TCharEncoding): integer;
var
  i: integer;
  sOut: string;
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
    if (Evaluate(true,sParam,regPC,Encoding,i) <> 0) then
    begin
      Result := 2;
      AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                       ': Invalid EQUates parameter.');
      exit;
    end;

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

  // DEFW/WORD/DW
  if (sOp = 'DEFW') or (sOp = '.DEFW') or (sOp = 'WORD') or (sOp = '.WORD') then
  begin
    // sParam contains either a single byte or a comma separated list to add
    // to sOut
    Result := AsmDirDEFW(sParam,sFile,iLine,regPC,sOut,Encoding);
    exit;
  end;

 Result := 4; // 4 = Not a supported ASM directive
end;

function ParseOpCode(sOp,sParam: string; sFile: string; iLine: integer;
                     var regPC: integer; var sOut: string;
                     Encoding: TCharEncoding): integer;
var
  i: integer;
  sParamU,sMid: string;
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
        case Evaluate(false, sEval, regPC, Encoding, iEval) of
        0:
          begin
            sOut := sOut + ' ';

            if (Length(sOut) = 4) and ((Copy(sOut,1,2) = #$DD#$CB) or (Copy(sOut,1,2) = #$FD#$CB)) then
              sOut := Copy(sOut,1,2) + sOut[4] + sOut[3];

            Result := 0;
          end;
        else
          Result := 3;
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
          regPC := regPC + Length(sOut) + ASMInfo[i].iParamBytes;

          sEval := Copy(sParam,Pos('?',ASMInfo[i].sOperand),512);
          // +$20),$32
          sEval := Copy(sEval,1,Pos(sMid,sEval)-1);

          // Evaluate sEval and tag the appropriate value (1 byte offet)
          // onto sOut
          case Evaluate(false, sEval, regPC, Encoding, iEval) of
          0:
            sOut := sOut + ' ';
          else
            begin
              Result := 3;
              exit;
            end;
          end;

          sEval := Copy(sParam,Pos(sMid,sParamU)+Length(sMid),512);

          case Evaluate(false, sEval, regPC, Encoding, iEval) of
          0:
            begin
              sOut := sOut + ' ';
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
        Inc(regPC,Length(sOut) + ASMInfo[i].iParamBytes);

        sEval := Copy(sParam,Pos('*',ASMInfo[i].sOperand),512);
        sEval := Copy(sEval,
                     1,
                     Length(sEval)-(Length(ASMInfo[i].sOperand)-Pos('*',ASMInfo[i].sOperand)));
        // Evaluate sEval and tag the appropriate value (1 or 2 bytes)
        // onto sOut
        Evaluate(false,sEval, regPC, Encoding, iEval);
        case ASMInfo[i].iParamBytes of
        1:
          sOut := sOut + Char(iEval and $FF);
        2:
          sOut := sOut + Char(iEval and $FF) + Char(iEval div 256);
        end;

        Result := 0;
        exit;
      end;
    end;

  end;

  Result := 4;
end;

{ FirstPassASMLine

  First pass of processing a line of assembly. Actions any assembler directives,
  updates regPC, and adds and labels/equates to the ASMEquates array.

  IN:     s     - Full name of assembler input file.
  IN:     iLine - Number of line being processed.
  IN/OUT: regPC - Current assembly address - modified as necessary after the
                  line has been parsed to point to the address of the next instr
  RETURNS:      -  0 = no errors, 1 = Warning, 2 = Error, 3 = Internal failure
}
function FirstPassASMLine(s: string; sFile: string; iLine: integer;
                          var regPC: integer; Encoding: TCharEncoding): integer;
var
  sLabel: string;
  sOperator: string;
  sOut: string;
  i, iOldPC: integer;
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
  begin
    // Cope with semi-colons in strings and as character literals
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
  end;

  if (Length(s)>0) and ((s[1]=' ') or (s[1]=#9)) then
  begin
    // No Label
    sLabel := '';
    s := Trim(s);
  end
  else
  begin
    // Label found
    if (Pos(' ',s)>1) then
    begin
      // Label + Possibly an instruction
      sLabel := Copy(s,1,Pos(' ',s)-1);
      s := Trim(Copy(s,Pos(' ',s)+1,512));
    end
    else if (Pos(#9,s)>1) then
    begin
      sLabel := Copy(s,1,Pos(#9,s)-1);
      s := Trim(Copy(s,Pos(#9,s)+1,512));
    end
    else
    begin
      sLabel := Trim(s);
      s := '';
    end;
    
    if sLabel[Length(sLabel)] = ':' then SetLength(sLabel,Length(sLabel)-1);
  end;

  { Right, we now have:-

     sLabel = containing a case-sensisitve label name if one is present on the
              line, minus any tailing ':'
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
  iOldPC := regPC;
  i := ParseAsmDirective(sOperator,s,sFile,iLine,regPC,Encoding);
  if (i And $08000000) > 0 then
  begin
    Result := AddLabelValue(sLabel,i and $FFFF);
    case Result of
    0:
      Result := 0;
    1:
      begin
        Result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Duplicate label definition.');
      end;
    2:
      begin
        Result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': EQU directive must have a label.');
      end;
    else
      begin
        Result := 3;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': INTERNAL ERROR: Label definition could not be added.');
      end;
    end;
    exit;
  end
  else if sLabel <> '' then
  begin
    Result := AddLabelValue(sLabel,iOldPC);
    if Result = 1 then
    begin
      Result := 2;
      AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                       ': Duplicate label definition.');
      exit;
    end
    else if Result > 0 then
    begin
      Result := 3;
      AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                       ': INTERNAL ERROR: Label definition could not be added.');
      exit;
    end;
  end;
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
  Result := ParseOpCode(sOperator,s,sFile,iLine,regPC,sOut,Encoding);

  if Result = 4 then
  begin
    AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                     ': Unknown Instruction - ' + sOperator + ' ' + s);
    Result := 2;
  end;
end;

end.
