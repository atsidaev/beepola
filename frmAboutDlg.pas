unit frmAboutDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, JvExControls, JvaScrollText, ToolWin,
  JvExForms, JvScrollPanel, PlayerThread;

type
  TAboutDlg = class(TForm)
    cmdOK: TButton;
    ani1: TImage;
    ani2: TImage;
    Image1: TImage;
    ani3: TImage;
    ani4: TImage;
    ani5: TImage;
    Timer1: TTimer;
    ani6: TImage;
    ani7: TImage;
    ani8: TImage;
    ani9: TImage;
    ani10: TImage;
    ani11: TImage;
    ani12: TImage;
    ani13: TImage;
    ani14: TImage;
    PaintBox1: TPaintBox;
    lblVer: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { Private declarations }
    iAni: integer;
    iMsg: integer;
    iPatCount: integer;
    procedure ScrollMsg;
    procedure WM_AboutMusic_NewPattern(var Msg: TMessage); message WM_USER_NEWPATTERN;
  public
    { Public declarations }
  end;

var
  AboutDlg: TAboutDlg;

implementation

{$R *.dfm}

uses GrokUtils, SpecEmu, frmSTMainWnd;

var
 sMsg: array [0..48] of string = ('','','','','','','',
                                  '','','By Chris Cowley','','v1.00.00','Beepola','',
                                  'by Shiru','Phaser1','','by Jonathan Smith','Special FX','Beeper Engine Credits:','',
                                  '','by Saša Pušica','The Music Studio','','by Mark Alexander','The Music Box','',
                                  'by Chris Cowley','to all engines','Minor modifications','','by Jason C. Brooke','Savage','',
                                  'worldofspectrum.org','','forums at:','the World of Spectrum','further info, visit the','For assistance and','',
                                  '','','','','','','');
 Spec: TPlayerThread;

procedure TAboutDlg.FormHide(Sender: TObject);
begin
  Timer1.Enabled := false;
  Spec.Terminate;
  FreeAndNil(Spec);
end;

procedure TAboutDlg.FormShow(Sender: TObject);
var
  sVer: string;
begin
  Self.DoubleBuffered := true;
  GetAppVersionInfo(sVer);
  lblVer.Caption := Application.Title + ' v' + sVer;
  sMsg[11] := 'v' + sVer;
  Image1.Picture := ani1.Picture;
  iAni := 0;
  iMsg := 0;
  Timer1.Interval := 4000;
  Timer1.Enabled := true;
  Spec := TPlayerThread.Create(true);
  Spec.WaveOutHandle := STMainWnd.hWaveOut;
  Spec.Volume := 50;
  Spec.HMsgWnd := Self.Handle;
  Spec.Engine := ABOUT;
  iPatCount := 0;
  Spec.Resume;
end;

procedure TAboutDlg.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Font.Color := clWhite;
  PaintBox1.Canvas.Font.Name := 'Arial';
  PaintBox1.Canvas.Font.Size := 13;
  PaintBox1.Canvas.Font.Style := [fsBold];
  PaintBox1.Canvas.Brush.Style := bsClear;

  PaintBox1.Canvas.TextOut(12,0,sMsg[iMsg+6]);
  PaintBox1.Canvas.TextOut(12,30,sMsg[iMsg+5]);
  PaintBox1.Canvas.TextOut(12,60,sMsg[iMsg+4]);
  PaintBox1.Canvas.TextOut(12,90,sMsg[iMsg+3]);
  PaintBox1.Canvas.TextOut(12,120,sMsg[iMsg+2]);
  PaintBox1.Canvas.TextOut(12,150,sMsg[iMsg+1]);
  PaintBox1.Canvas.TextOut(12,180,sMsg[iMsg+0]);

end;

procedure TAboutDlg.ScrollMsg();
begin
  PaintBox1.Refresh;
  inc(iMsg);
  if iMsg > 41 then iMsg := 0;
  
end;

procedure TAboutDlg.Timer1Timer(Sender: TObject);
begin
  (Sender as TTimer).Interval := 100;
  case iAni of
  0: Image1.Picture := ani1.Picture;   // Look up
  1: Image1.Picture := ani1.Picture;
  2: Image1.Picture := ani2.Picture;
  3: Image1.Picture := ani3.Picture;
  4: Image1.Picture := ani4.Picture;
  5: Image1.Picture := ani5.Picture;  // Stare...
  15: Image1.Picture := ani4.Picture; // Look down
  16: Image1.Picture := ani3.Picture;
  17: Image1.Picture := ani2.Picture;
  18: Image1.Picture := ani1.Picture; // Pause...
  25: Image1.Picture := ani6.Picture; // Wind
  26: Image1.Picture := ani7.Picture;
  27: Image1.Picture := ani8.Picture;
  28: Image1.Picture := ani9.Picture;
  29: Image1.Picture := ani10.Picture;
  30: Image1.Picture := ani11.Picture;
  31: Image1.Picture := ani12.Picture;
  32: Image1.Picture := ani13.Picture;
  33: Image1.Picture := ani14.Picture;
  34: Image1.Picture := ani1.Picture;  // Pause
  end;

  if (iAni >= 26) and (iAni <= 32)  then
    ScrollMsg();
  
  inc(iAni);
  if iAni > 50 then
  begin
    iAni := 0;
  end;
end;

procedure TAboutDlg.WM_AboutMusic_NewPattern(var Msg: TMessage);
begin
  inc(iPatCount);
  if iPatCount > 5 then begin
    Spec.Suspend;
  end;
end;

end.
