unit MRUList;

interface

type
  TMRUList = class(TObject)
    private
      FSize: integer;
      FItems: array of string;
      function GetItem(iIndex: integer): string;
      function GetItemCount: integer;
      function GetItemIndex(s: string): integer;
      procedure SetSize(const Value: integer);
    public
      property Size: integer read FSize write SetSize;
      property Item[iIndex: integer]: string read GetItem;
      property ItemCount: integer read GetItemCount;
      function AddFile(sName: string): integer;
      function Store(): integer;
      function Load(): integer;
      constructor Create;
      destructor Destroy; override;
  end;

implementation

{ TMRUList }

uses SysUtils, Registry, Windows;

function RegGetInt(Reg: TRegistry; sKey: string; iDefault: integer): integer;
begin
  try
    Result := Reg.ReadInteger(sKey);
  except
    on ERegistryException do Result := iDefault;
  end;
end;

function RegGetDateTime(Reg: TRegistry; sKey: string; dtDefault: TDateTime): TDateTime;
begin
  try
    Result := Reg.ReadDateTime(sKey);
  except
    on ERegistryException do Result := dtDefault;
  end;
end;

function RegGetBool(Reg: TRegistry; sKey: string; bDefault: boolean): boolean;
begin
  try
    Result := Reg.ReadBool(sKey);
  except
    on ERegistryException do Result := bDefault;
  end;
end;

function RegGetString(Reg: TRegistry; sKey: string; sDefault: string): string;
begin
  try
    Result := Reg.ReadString(sKey);
  except
    on ERegistryException do Result := sDefault;
  end;
  if (Result = '') then Result := sDefault;
end;

function TMRUList.GetItemIndex(s: string): integer;
var
  i: Integer;
begin
  s := LowerCase(s);

  Result := -1;

  for i := 0 to Length(FItems) - 1 do
  begin
    if LowerCase(FItems[i]) = s then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TMRUList.SetSize(const Value: integer);
begin
  FSize := Value;
  SetLength(FItems,FSize);
end;

function TMRUList.Store: integer;
var
  Reg: TRegistry;
  i: Integer;
begin
  try
    Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Grok\Beepola\MRU',true) then
      begin
        Reg.WriteInteger('Count',FSize);
        for i := 0 to FSize - 1 do
          Reg.WriteString(IntToStr(i),FItems[i]);
      end;
    finally
      Reg.CloseKey;
    end;
  except
    on ERegistryException do;
  end;

  Result := FSize;

  FreeAndNil(Reg);
end;

function TMRUList.Load: integer;
var
  Reg: TRegistry;
  i, iCount: Integer;
begin
  try
    Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Grok\Beepola\MRU',true) then
      begin
        iCount := RegGetInt(Reg,'Count',0);
        for i := 0 to FSize-1 do
        begin
          if i < iCount then
            FItems[i] := RegGetString(Reg,IntToStr(i),'')
          else
            FItems[i] := '';
        end;
      end;
    finally
      Reg.CloseKey;
    end;
  except
    on ERegistryException do;
  end;

  Result := FSize;
  FreeAndNil(Reg);
end;

function TMRUList.AddFile(sName: string): integer;
var
  i: Integer;
begin
  i := GetItemIndex(sName);
  Result := i;
  if i = -1 then
  begin
    // Not in list. Add it to the top...
    for i := Length(FItems) - 2 downto 0 do
      FItems[i+1] := FItems[i];
    FItems[0] := sName;
  end
  else
  begin
    // In list. Move it to the top of the list
   for i := (i-1) downto 0 do
     FItems[i+1] := FItems[i];

   FItems[0] := sName;
  end;

  Store;
end;

constructor TMRUList.Create;
begin
  Size := 20;
  Load();
end;

destructor TMRUList.Destroy;
begin
  Store();
  inherited;
end;

function TMRUList.GetItem(iIndex: integer): string;
begin
  if (iIndex >= 0) and (iIndex < Length(FItems)) then
    Result := FItems[iIndex]
  else
    Result := '';
end;

function TMRUList.GetItemCount: integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to FSize - 1 do
    if FItems[i] <> '' then inc(Result);
end;

end.

