unit Assemb;

interface

uses AsmPass1,AsmPass2,AsmTypes,Classes;

type
  TASMInfo = record
   sOperator: string;
   sOperand: string;
   iParamBytes: integer;
   sOut: string;
  end;

type
  TASMEquates = record
    sLabel: string;
    iValue: integer;
  end;

var
  ASMInfo: array of TASMInfo;
  ASMEquates: array of TASMEquates;
  iLabelCount: integer;
  iCurLine: integer;
  iCurFile: string;

function ReadASMTableFile(sFileName: string): integer;
function ParseASMTableLine(S: string; i: integer): boolean;
procedure GetASMInstrInfo(sOperator,sOperand: string; var iParams: integer;
                          var sOut: string);
function AssembleFile(sInFile,sOutFile: string; OutputType: TASMOutput; Encoding: TCharEncoding): boolean;
function AssembleStringList(sIn: TStringList; sOutFile: string; OutputType: TASMOutput; Encoding: TCharEncoding): boolean;
function AssembleStringListMem(sIn: TStringList; var cOut: array of byte; Encoding: TCharEncoding): integer;

implementation

uses SysUtils,math,AsmUtils,GrokUtils;

{ ReadASMTableFile

  Opens the specified ASM Table text file, and add any instructions it contains
  to ASMInfo record array.

  IN: sFileName - Full filename (including drive and folder info) of the ASM
                  Table file to read.
  RETURNS: An integer specifying the number of instructions in the ASMInfo array.
}
function ReadASMTableFile(sFileName: string): integer;
var
  S: String;
  i: integer;
  Stream: TResourceStream;
  bEOF: boolean;
begin
  i := 0;
  SetLength(ASMInfo,i);

  Stream := TResourceStream.Create(hInstance, 'z80_tab', 'BINARY');
  try
    while Stream.Position < Stream.Size do
    begin
      S := StreamGetString(Stream,bEOF);
      if (Length(Trim(S)) > 0) and (Trim(S)[1] <> ';') then
        if ParseASMTableLine(S,i) then Inc(i);
    end;
  finally
    Stream.Free;
  end;

  SetLength(ASMInfo,i+1);
  Result := i;
end;

function HexToBin(sHex: string): string;
var
  s: string;
  i,iErr: integer;
begin
  Result := '';

  while Length(sHex)>0 do
  begin
    s := Trim(Copy(sHex,1,3));
    sHex := Copy(sHex,4,512);
    Val('$' + s,i,iErr);
    if iErr = 0 then
      Result := Result + Chr(i and $FF);
  end;
end;



{ ParseASMTableLine

  Processes a line of tab-delimeted text and adds the described instruction
  to the ASMInfo table if valid.

  IN: S - String containing a line from an ASM Table File in the format
          Operation[TAB]Operand[TAB]Number of parameter bytes[TAB]Assembled Hex
  IN: i - Highest used index in ASMInfo array.
  RETURNS: True if the instruction contained in the line was added to the table
           otherwise false
}
function ParseASMTableLine(S: string; i: integer): boolean;
var
  sOperator,sOperand,sParam,sHex: string;
  iParams: integer;
  sOut: string;
begin
  Result := false;

  if Pos(#9,S) < 1 then exit;
  sOperator := UpperCase(Copy(S,1,Pos(#9,S)-1));
  S := Copy(S,Pos(#9,S)+1,Length(S));

  if Pos(#9,S) < 1 then exit;
  sOperand := UpperCase(Copy(S,1,Pos(#9,S)-1));
  S := Copy(S,Pos(#9,S)+1,Length(S));

  if Pos(#9,S) < 1 then exit;
  sParam := UpperCase(Copy(S,1,Pos(#9,S)-1));
  S := Copy(S,Pos(#9,S)+1,Length(S));

  if Pos(#9,S) > 0 then S := Copy(S,1,Pos(#9,S)-1);
  sHex := UpperCase(S);

  // Check to see whether this operator/operand exists already
  GetASMInstrInfo(sOperator,sOperand,iParams,sOut);
  if sOut <> '' then exit;    // Entry already exists, return false

  // Add the new entry

  // Create a bit more space in the array for new entries
  Inc(i);
  if (Length(ASMInfo) <= i) then SetLength(ASMInfo,i+20);

  // Add the new entry after the current highest entry, and return true
  ASMInfo[i].sOperator := UpperCase(sOperator);
  ASMInfo[i].sOperand := UpperCase(sOperand);
  ASMInfo[i].iParamBytes := StrToIntDef(sParam,0);
  ASMInfo[i].sOut := HexToBin(sHex);
  Result := true;
end;

{ GetASMInstrInfo

  Searches the ASMInfo table for an operator matching sOperator and sOperand.
  If found, returns the number of parameter bytes in iParams and the assembled
  hex in sOut. If not found, returns 0 in iParams and an empty string in sOut.

  IN: sOperator - Operator for the ASM instruction (required)
  IN: sOperand  - Operands for the ASM instruction (empty if no operands)
  OUT: iParams  - Number of Parameter Bytes for the instruction
  OUT: sOut     - Assembled hex in binary format or empty if not found
}
procedure GetASMInstrInfo(sOperator,sOperand: string;
                          var iParams: integer;
                          var sOut: string);
var
  i: integer;
begin
  iParams := 0;
  sOut := '';

  for i:= 1 to Length(ASMInfo)-1 do
  begin
    if (UpperCase(sOperator) = ASMInfo[i].sOperator) and
       (UpperCase(sOperand) = ASMInfo[i].sOperand) then
    begin
      iParams := ASMInfo[i].iParamBytes;
      sOut := ASMInfo[i].sOut;
      break;
    end;
  end;
end;


{ AssembleFile

  Assembles the specified file, writing the result to an output file. Assembly
  is generated based on the information in the ASMInfo array.

  IN: sInFile    - Full name of assembler input file.
  IN: sOutFile   - Full name of output file to create.
  IN: OutputType - Type of file to produce (enum, currently 0=Hex, 1=Binary)
  RETURNS: True if assembled, otherwise False
}
function AssembleFile(sInFile,sOutFile: string; OutputType: TASMOutput; Encoding: TCharEncoding): boolean;
var
  FIn: TextFile;
  FOut: File of byte;
  regPC,iLine,i: integer;
  s,sOut: string;
  iErr,iWarn: integer;
  sName: string;
  cByte: byte;
begin
  Result := False;
  AssignFile(FIn,sInFile);
  Reset(FIn);

  AssemblerDisplay('Assembling file ' + sInFile);
  AssemblerDisplay('Pass 1...');

  // First pass, evaluate label and equates values, check opcode validity,
  // Check compiler directive validity and action as necessary
  regPC := 0;  iLine := 1; iErr := 0; iWarn := 0;
  iLabelCount := 0;
  SetLength(ASMEquates,0);
  sName := ExtractFileName(sInFile);

  While Not(Eof(FIn)) do
  begin
    ReadLn(FIn,s);
    if Trim(s)<>'' then
    begin
      case FirstPassASMLine(s,sName,iLine,regPC,Encoding) of
      1:
        Inc(iWarn);
      2:
        Inc(iErr);
      end;
    end;

    Inc(iLine);
  end;

  if (iErr > 0) then
  begin
    AssemblerDisplay('');
    AssemblerDisplay('Assembly terminated - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).');
    CloseFile(FIn);
    exit;
  end;
  // Move back to start of input file for second pass
  Reset(FIn);
  // Open the output file
  AssignFile(FOut,sOutFile);
  Rewrite(FOut);

  SetLength(AsmEquates,iLabelCount+1);

  AssemblerDisplay('Pass 2...');

  regPC := 0;  iLine := 1;
  While Not(Eof(FIn)) do
  begin
    ReadLn(FIn,s);
    if Trim(s)<>'' then
    begin
      sOut := '';
      case SecondPassASMLine(s,sName,iLine,regPC,sOut,Encoding) of
      1:
        Inc(iWarn);
      2:
        Inc(iErr);
      end;
      if (sOut<>'') then
      for i := 1 to Length(sOut) do
      begin
        cByte := Byte(sOut[i]);
        Write(FOut,cByte);
      end;
    end;

    Inc(iLine);
  end;

  AssemblerDisplay('');
  if (iErr = 0) then
    AssemblerDisplay('Assembly complete - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).')
  else
  begin
    AssemblerDisplay('Assembly terminated - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).');
  end;

  CloseFile(FOut);
  CloseFile(FIn);
  Result := True;
end;

{ AssembleStringList

  Assembles the specified stringlist, writing the result to an output file.
  Assembly is generated based on the information in the ASMInfo array.

  IN: sInFile    - Full name of assembler input file.
  IN: sOutFile   - Full name of output file to create.
  IN: OutputType - Type of file to produce (enum, currently 0=Hex, 1=Binary)
  RETURNS: True if assembled, otherwise False
}
function AssembleStringList(sIn: TStringList; sOutFile: string; OutputType: TASMOutput; Encoding: TCharEncoding): boolean;
var
  FOut: File of byte;
  regPC,iLine,i: integer;
  s,sOut: string;
  iErr,iWarn: integer;
  sName: string;
  cByte: byte;
begin
  Result := False;

  AssemblerDisplay('Assembling file - MEMORY_FILE');
  AssemblerDisplay('Pass 1...');

  // First pass, evaluate label and equates values, check opcode validity,
  // Check compiler directive validity and action as necessary
  regPC := 0;  iLine := 1; iErr := 0; iWarn := 0;
  iLabelCount := 0;
  SetLength(ASMEquates,0);
  sName := 'MEMORY_FILE';

  While (iLine <= sIn.Count) do
  begin
    s := sIn.Strings[iLine-1];

    if Trim(s)<>'' then
    begin
      case FirstPassASMLine(s,sName,iLine,regPC,Encoding) of
      1:
        Inc(iWarn);
      2:
        Inc(iErr);
      end;
    end;

    Inc(iLine);
  end;

  if (iErr > 0) then
  begin
    AssemblerDisplay('');
    AssemblerDisplay('Assembly terminated - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).');
    exit;
  end;
  // Open the output file
  AssignFile(FOut,sOutFile);
  Rewrite(FOut);

  SetLength(AsmEquates,iLabelCount+1);

  AssemblerDisplay('Pass 2...');

  regPC := 0;  iLine := 1;
  While (iLine <= sIn.Count) do
  begin
    s := sIn.Strings[iLine-1];
    if Trim(s)<>'' then
    begin
      sOut := '';
      case SecondPassASMLine(s,sName,iLine,regPC,sOut,Encoding) of
      1:
        Inc(iWarn);
      2:
        Inc(iErr);
      end;
      if (sOut<>'') then
      for i := 1 to Length(sOut) do
      begin
        cByte := Byte(sOut[i]);
        Write(FOut,cByte);
      end;
    end;

    Inc(iLine);
  end;

  AssemblerDisplay('');
  if (iErr = 0) then
    AssemblerDisplay('Assembly complete - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).')
  else
  begin
    AssemblerDisplay('Assembly terminated - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).');
  end;

  CloseFile(FOut);
  Result := True;
end;

{ AssembleStringListMem

  Assembles the specified stringlist, writing the result to a byte array.
  Assembly is generated based on the information in the ASMInfo array.

  IN: sInFile    - Full name of assembler input file.
  IN: sOutFile   - Full name of output file to create.
  IN: OutputType - Type of file to produce (enum, currently 0=Hex, 1=Binary)
  RETURNS: True if assembled, otherwise False
}
function AssembleStringListMem(sIn: TStringList; var cOut: array of byte; Encoding: TCharEncoding): integer;
var
  regPC,iLine,i: integer;
  s,sOut: string;
  iOutPtr: integer;
  iErr,iWarn: integer;
  sName: string;
begin
  Result := 0; // Default = 0 bytes written (error)

  AssemblerDisplay('Assembling file - MEMORY_FILE');
  AssemblerDisplay('Pass 1...');

  // First pass, evaluate label and equates values, check opcode validity,
  // Check compiler directive validity and action as necessary
  regPC := 0;  iLine := 1; iErr := 0; iWarn := 0;
  iLabelCount := 0;
  SetLength(ASMEquates,0);
  sName := 'MEMORY_FILE';

  While (iLine <= sIn.Count) do
  begin
    s := sIn.Strings[iLine-1];

    if Trim(s)<>'' then
    begin
      case FirstPassASMLine(s,sName,iLine,regPC,Encoding) of
      1:
        Inc(iWarn);
      2:
        Inc(iErr);
      end;
    end;

    Inc(iLine);
  end;

  if (iErr > 0) then
  begin
    AssemblerDisplay('');
    AssemblerDisplay('Assembly terminated - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).');
    exit;
  end;
  // Open the output file
  iOutPtr := 0;

  SetLength(AsmEquates,iLabelCount+1);

  AssemblerDisplay('Pass 2...');

  regPC := 0;  iLine := 1;
  While (iLine <= sIn.Count) do
  begin
    s := sIn.Strings[iLine-1];
    if Trim(s)<>'' then
    begin
      sOut := '';
      case SecondPassASMLine(s,sName,iLine,regPC,sOut,Encoding) of
      1:
        Inc(iWarn);
      2:
        Inc(iErr);
      end;
      if (sOut<>'') then
      for i := 1 to Length(sOut) do
      begin
        cOut[iOutPtr+i-1] := Byte(sOut[i]);
      end;
      inc(iOutPtr,Length(sOut));
    end;

    Inc(iLine);
  end;

  AssemblerDisplay('');
  if (iErr = 0) then
    AssemblerDisplay('Assembly complete - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).')
  else
  begin
    AssemblerDisplay('Assembly terminated - ' + IntToStr(iErr) + ' error(s), ' +
                                                IntToStr(iWarn) + ' warning(s).');
  end;

  Result := iOutPtr;
end;

end.
