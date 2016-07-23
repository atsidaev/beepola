unit RegSettings;

interface

type
  TRegSettings = class (TObject)
  private
    FSongLayoutColNumbers: boolean;
    FPatternRowHex: boolean;
    bDirty: boolean;
    procedure SetPatternRowHex(const Value: boolean);
    procedure SetSongLayoutColNumbers(const Value: boolean);
  public
    property ShowLayoutColNumbers: boolean read FSongLayoutColNumbers write SetSongLayoutColNumbers;
    property PatternRowNumbersHex: boolean read FPatternRowHex write SetPatternRowHex;
    property Dirty: boolean read bDirty;
    procedure SaveSettings();
    procedure LoadSettings();
    constructor Create();
  end;

implementation

{ TRegSettings }

uses Registry, Windows, SysUtils;


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

constructor TRegSettings.Create;
begin
  inherited;

  LoadSettings();
end;

procedure TRegSettings.LoadSettings;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Grok\Beepola\Options',true) then
      begin
        FSongLayoutColNumbers := RegGetBool(Reg,'ShowLayoutColNumbers',false);
        FPatternRowHex := RegGetBool(Reg,'PatternRowHex',false);
      end;
    finally
      Reg.CloseKey;
    end;
  except
    on ERegistryException do;
  end;

  FreeAndNil(Reg);
  bDirty := false;
end;

procedure TRegSettings.SaveSettings;
var
  Reg: TRegistry;
begin
  if not bDirty then exit;
  
  try
    Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Grok\Beepola\Options',true) then
      begin
        Reg.WriteBool('ShowLayoutColNumbers',FSongLayoutColNumbers);
        Reg.WriteBool('PatternRowHex',FPatternRowHex);
      end;
    finally
      Reg.CloseKey;
    end;
  except
    on ERegistryException do;
  end;

  FreeAndNil(Reg);
  bDirty := false;
end;

procedure TRegSettings.SetPatternRowHex(const Value: boolean);
begin
  if (Value <> FPatternRowHex) then bDirty := true;

  FPatternRowHex := Value;
end;

procedure TRegSettings.SetSongLayoutColNumbers(const Value: boolean);
begin
  if (Value <> FSongLayoutColNumbers) then bDirty := true;

  FSongLayoutColNumbers := Value;
end;

end.
