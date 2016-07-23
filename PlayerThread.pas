unit PlayerThread;

interface

uses
  Windows, Classes, Messages, SpecEmu, STSong, STPatterns;

const
  WM_USER_NEWPATTERN = WM_USER + 1;
  WM_USER_PATTERNTICK = WM_USER + 2;
  WM_USER_SONGEND = WM_USER + 3;
  
type
  TPlayerThread = class(TThread)
  private
    { Private declarations }
    ZX: TSpecEmu;
    bPatPlay: boolean;
    iNewPatCounter: integer;
    procedure NewPat;
    procedure PatTick;
  public
    WaveOutHandle: System.Cardinal;
    Engine: TEngine;
    Song: TSTSong;
    Pattern: STPatterns.TPattern;
    SvgPattern: STPatterns.TPatternSvg;
    iStartPos: integer;
    HMsgWnd: HWND;
    Volume: integer;
    constructor Create(CreateSuspended: boolean);
  protected
    procedure Execute; override;
  end;

implementation

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TPlayerThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TPlayerThread }

uses SysUtils;

constructor TPlayerThread.Create(CreateSuspended: boolean);
begin
  inherited;
  HMsgWnd := INVALID_HANDLE_VALUE;
  WaveOutHandle := INVALID_HANDLE_VALUE;
  Song := nil;
  Volume := 100;
  Pattern.Length := 0;
end;

procedure TPlayerThread.Execute;
begin
  { Place thread code here }
  ZX := TSpecEmu.Create(WaveOutHandle);

  bPatPlay := false;
  iNewPatCounter := 0;

  ZX.Engine := Engine;
  if Pattern.Length = 0 then
    ZX.LoadPlayerSong(Song,iStartPos)
  else
  begin
    ZX.LoadPlayerPattern(Pattern,SvgPattern,Song);
    bPatPlay := true;
  end;

  ZX.OnNewPattern := NewPat;
  ZX.OnPatternTick := PatTick;
  ZX.Volume := Volume;

  ZX.Register_PC := $8000;
  ZX.Register_SP := $7FF0;

  while not Terminated do
    ZX.Exec(true);

  Sleep(210); // Ensure the ZX emu thread is not in it's 200msec spinloop
  FreeAndNil(ZX);

  if HMsgWnd <> INVALID_HANDLE_VALUE then
    PostMessage(HMsgWnd,WM_USER_SONGEND,0,0);
end;

procedure TPlayerThread.NewPat;
begin
  if bPatPlay then
  begin
    if iNewPatCounter > 0 then ZX.Volume := 0;  
    inc(iNewPatCounter);
  end;

  if HMsgWnd <> INVALID_HANDLE_VALUE then
    PostMessage(HMsgWnd,WM_USER_NEWPATTERN,0,0);
end;

procedure TPlayerThread.PatTick;
begin
  if HMsgWnd <> INVALID_HANDLE_VALUE then
    PostMessage(HMsgWnd,WM_USER_PATTERNTICK,0,0);
end;

end.
