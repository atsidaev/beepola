unit AboutMusic;

interface

uses
  Classes, Messages, SpecEmu;

type
  TAboutMusic = class(TThread)
  private
    bStopPlayer: boolean;
    iPat: integer;
    procedure NewPat(var Msg: TMessage); message WM_USER_NEWPATTERN;
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure AboutMusic.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ AboutMusic }

uses SysUtils;

procedure TAboutMusic.NewPat(var Msg: TMessage);
begin
  inc(iPat);
  if iPat > 5 then bStopPlayer := true;
  
end;

procedure TAboutMusic.Execute;
var
  SpecEm: TSpecEmu;
begin
  SpecEm := TSpecEmu.Create(true);
  SpecEm.Engine := ABOUT;
  SpecEm.Register_SP := $7FF0;
  SpecEm.Register_PC := $8000;
  SpecEm.Engine := ABOUT;
  SpecEm.MessageWnd := Self.Handle;
  
  bStopPlayer := false;
  iPat := 0;
  while not bStopPlayer do
    SpecEm.Exec(true);

  SpecEm.ResetWaveBuffers();
  FreeAndNil(SpecEm);
end;

end.
