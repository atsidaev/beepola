unit AsmUtils;

interface

uses AsmTypes;

function HexToDecimal(sHex: string; var i: integer): boolean;
function BinToDecimal(sBin: string; var i: integer): boolean;
procedure AssemblerDisplay(s: string);
function AsmDirDEFB(sParam: string; sFile: string; iLine: integer;
                         var regPC: integer; var sOut: string;
                         Encoding: TCharEncoding): integer;
function AsmDirDEFW(sParam: string; sFile: string; iLine: integer;
                         var regPC: integer; var sOut: string;
                         Encoding: TCharEncoding): integer;
function AddLabelValue(sLabel: string; iValue: integer): integer;
function Evaluate(bFinalPass: boolean; s: string; regPC: integer; Encoding: TCharEncoding; var i: integer): integer;

implementation

uses SysUtils,Math,Assemb;

function HexToDecimal(sHex: string; var i: integer): boolean;
var
  iErr: integer;
begin
  if Uppercase(sHex[Length(sHex)]) = 'H' then
    sHex := '$' + Copy(sHex,1,Length(sHex)-1);

  Result := false;

  if (sHex[1] = '$') then
  begin
    // Parameter is a hex number starting with $, convert it to decimal
    Val(sHex,i,iErr);
    if (iErr>0) then
      exit;
  end;

  Result := true;
end;

function BinToDecimal(sBin: string; var i: integer): boolean;
var
  iCount,iPower: integer;
begin
  Result := false;
  i := 0;  iPower := 0;

  // Strip iff the leading '%' sign if neccessary
  if sBin[1] = '%' then sBin := Copy(sBin,2,512);

  for iCount := Length(sBin) downto 1 do
  begin
    if sBin[iCount] = '1' then
      i := i + Round(IntPower(2,iPower))
    else if sBin[iCount] <> '0' then
      exit;

    Inc(iPower);
  end;

  Result := true;
end;

function GetEncodedChar(sCharIn: char; Encoding: TCharEncoding): char;
const
  ZX81CharSet = ' ¬¬¬¬¬¬¬¬¬¬"£$:?()><=+-*/;,.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬abcdefghijklmnopqrstuvwxyz';
begin
  if Encoding = ASCII then
    Result := sCharIn
  else if Encoding = ZX81 then
  begin
    Result := Chr(Pos(sCharIn,ZX81CharSet)-1);
  end
  else
    Result := sCharIn; // Default = ASCII
end;

procedure AssemblerDisplay(s: string);
begin
  //MainWnd.txtOutput.Lines.Add(s);
  //MainWnd.txtOutput.SelStart := Length(MainWnd.txtOutput.Text)-1;
end;

function GetValue(bFinalPass: boolean; s: string; regPC: integer;
                  var i: integer; Encoding: TCharEncoding): integer;
var
  iTemp,iErr: integer;
begin
  s := Trim(s);
  Result := 1;

  if s = '$' then
  begin
    i := regPC;
    Result := 0;
    exit;
  end;

  if s = '' then
  begin
    i := 0;
    Result := 0;
    exit;
  end;

  if (s[1] = '$') or (UpperCase(s[Length(s)]) = 'H') then
  begin
    if HexToDecimal(s,i) then Result := 0 else Result := 1;
  end
  else if (s[1] = '%') then
  begin
    if BinToDecimal(s,i) then Result := 0 else Result := 1;
  end
  else if ((s[1] >= 'A') and (s[1] <= 'z')) then
  begin
    if bFinalPass then
    begin
      for iTemp := 0 to Length(ASMEquates)-1 do
      begin
        if ASMEquates[iTemp].sLabel = s then
        begin
          i := ASMEquates[iTemp].iValue;
          Result := 0;
          exit;
        end;
      end;
      Result := 2; // Label not defined
    end
    else
    begin
      i := 0;
      Result := 0;
    end;
  end
  else if (s[1] = '''') and (s[3]='''') then 
  begin
    i := Ord(GetEncodedChar(s[2],Encoding));
    Result := 0;
  end
  else
  begin
    Val(s,i,iErr);
    if (iErr <> 0) then exit;
    Result := 0;
  end;
end;

function MathOp(iVal: integer; sOp: string; regPC: integer;
                Encoding: TCharEncoding): integer;
var
  i: integer;
begin
  Result := iVal;
  sOp := Trim(sOp);
  i := 0;

  if Length(sOp) < 1 then exit;

  if sOp[1] = '+' then
  begin
    GetValue(true,Copy(sOp,2,512),regPC,i,Encoding);
    Result := iVal + i;
  end
  else if sOp[1] = '-' then
  begin
    GetValue(true,Copy(sOp,2,512),regPC,i,Encoding);
    Result := iVal - i;
  end
  else if sOp[1] = '&' then
  begin
    GetValue(true,Copy(sOp,2,512),regPC,i,Encoding);
    Result := iVal and i;
  end
  else if sOp[1] = '|' then
  begin
    GetValue(true,Copy(sOp,2,512),regPC,i,Encoding);
    Result := iVal or i;
  end;
end;

function AsmDirDEFBOneParam(sIn: string; var sHex: string; regPC: integer; Encoding: TCharEncoding): boolean;
var
  i: integer;
begin
  sHex := '';
  Result := false;

  if Length(sIn) < 1 then exit;

  if sIn[1] = '"' then
  begin
    // Text string
    for i := 1 to Length(sIn) do
      if sIn[i] <> '"' then sHex := sHex +  GetEncodedChar(sIn[i],Encoding);
  end
  else
  begin
    Evaluate(true,sIn,regPC,Encoding,i);
    sHex := sHex + Chr(i and $ff);
  end;

  Result := true;
end;

function AsmDirDEFB(sParam: string; sFile: string; iLine: integer;
                         var regPC: integer; var sOut: string;
                         Encoding: TCharEncoding): integer;
var
  s, sHex: string;
  i: integer;
  bInString: boolean;
begin
  s := '';   bInString := false;

  for i := 1 to Length(sParam) do
  begin
    if sParam[i] = '"' then
    begin
      s := s + sParam[i];
      bInString := Not bInString;
    end
    else if (sParam[i] = ',') and (not bInString) then
    begin
      s := Trim(s);
      if AsmDirDEFBOneParam(s,sHex,regPC,Encoding) then
        sOut := sOut + sHex
      else
      begin
        result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Invalid byte parameter(s).');
        exit;
      end;
      s := '';
    end
    else
      s := s + sParam[i];
  end;

  if (sParam[Length(sParam)] <> ',') then
  begin
    s := Trim(s);
    if AsmDirDEFBOneParam(s,sHex,regPC,Encoding) then
      sOut := sOut + sHex
    else
    begin
      result := 2;
      AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                       ': Invalid byte parameter(s).');
      exit;
    end;
  end;

  regPC := regPC + Length(sOut);
  Result := 0;
end;


function AsmDirDEFWOneParam(sIn: string; var sHex: string; regPC: integer;
                            Encoding: TCharEncoding): boolean;
var
  i: integer;
begin
  sHex := '';
  Result := false;

  if Length(sIn) < 1 then exit;

  Evaluate(true,sIn,regPC,Encoding,i);
  sHex := sHex + Chr(i and $ff) + Chr((i and $ff00) shr 8);

  Result := true;
end;

function AsmDirDEFW(sParam: string; sFile: string; iLine: integer;
                         var regPC: integer; var sOut: string;
                         Encoding: TCharEncoding): integer;
var
  s, sHex: string;
  i: integer;
  bInString: boolean;
begin
  s := '';   bInString := false;

  for i := 1 to Length(sParam) do
  begin
    if sParam[i] = '"' then
    begin
      s := s + sParam[i];
      bInString := Not bInString;
    end
    else if (sParam[i] = ',') and (not bInString) then
    begin
      s := Trim(s);
      if AsmDirDEFWOneParam(s,sHex,regPC,Encoding) then
        sOut := sOut + sHex
      else
      begin
        result := 2;
        AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                         ': Invalid byte parameter(s).');
        exit;
      end;
      s := '';
    end
    else
      s := s + sParam[i];
  end;

  if (sParam[Length(sParam)] <> ',') then
  begin
    s := Trim(s);
    if AsmDirDEFWOneParam(s,sHex,regPC,Encoding) then
      sOut := sOut + sHex
    else
    begin
      result := 2;
      AssemblerDisplay('[Error] ' + sFile + ', line ' + IntToStr(iLine) +
                       ': Invalid word parameter(s).');
      exit;
    end;
  end;

  regPC := regPC + Length(sOut);
  Result := 0;
end;

function AddLabelValue(sLabel: string; iValue: integer): integer;
var i: integer;
begin
  sLabel := Trim(sLabel);

  if sLabel = '' then
  begin
    Result := 1; // Null label name
    exit;
  end;

  // Search to see if this label already exists and return if it does
  for i := 1 to iLabelCount do
    if ASMEquates[i].sLabel = sLabel then
    begin
      Result := 2; // Duplicate label def
      exit;
    end;

  Inc(iLabelCount);
  if iLabelCount >= Length(ASMEquates) then
    SetLength(ASMEquates,iLabelCount+20);

  ASMEquates[iLabelCount].sLabel := sLabel;
  ASMEquates[iLabelCount].iValue := iValue;

  Result := 0;
end;

function GetParam(var s: string): string;
var
  i: integer;
  bInString,bInChar: boolean;
const
  TermChars = '+-&|><*/^';
begin
  s := Trim(s);  Result := '';  bInString := false;  bInChar := false;

  for i := 1 to Length(s) do
  begin
    if (s[i] = '"') and (Not bInChar) then
    begin
      Result := Result + s[i];
      bInString := Not bInString;
    end
    else if (s[i]='''') and (not bInString) then
    begin
      Result := Result + s[i];
      bInChar := Not bInChar;
    end
    else if (Pos(s[i],TermChars)>0) and (not bInString) and (not bInChar) then
    begin
      s := Copy(s,i,512);
      exit;
    end
    else if (s[i] <> ' ') then
      Result := Result + s[i]
    else if (bInString) or (bInChar) then
      Result := Result + s[i];

  end;

  s := '';
end;

function Evaluate(bFinalPass: boolean; s: string; regPC: integer; Encoding: TCharEncoding; var i: integer): integer;
var
  sTemp, sOp: string;
  iTemp: integer;
begin
  if (s[1] = '+') or (s[1] = '-') then i := regPC else i := 0;

  while s <> '' do
  begin
    case s[1] of
    '+','-','|','&','*','/','^':
      begin
        sOp := s[1];
        s := Trim(Copy(s,2,512));
      end;
    '>','<':
      begin
        sOp := Copy(s,1,2);
        s := Trim(Copy(s,3,512));
      end;
    else
      sOp := '+';
    end;

    sTemp := GetParam(s);
    iTemp := 0;

    case GetValue(bFinalPass,sTemp,regPC,iTemp,Encoding) of
    1:
      begin
        Result := 1; // Invalid parameter value
        exit;
      end;
    2:
      begin
        Result := 2; // Label not defined
        exit;
      end;
    end;

    if sOp[1] = '+' then Inc(i,iTemp)
    else if sOp = '-' then Dec(i,iTemp)
    else if sOp = '&' then i := (i and iTemp)
    else if sOp = '*' then i := (i * iTemp)
    else if sOp = '/' then i := (i div iTemp)
    else if sOp = '^' then i := (i mod iTemp)
    else if sOp = '|' then i := (i or iTemp)
    else if sOp = '>>' then i := i shr itemp
    else if sOp = '<<' then i := i shl iTemp
    else
    begin
      Result := 2;
      exit;
    end;
  end;

  Result := 0;
end;

end.
