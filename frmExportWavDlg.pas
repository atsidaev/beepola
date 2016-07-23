unit frmExportWavDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, SpecEmu;

type
  TExportWavDlg = class(TForm)
    GroupBox1: TGroupBox;
    optNoLoop: TRadioButton;
    optLoop: TRadioButton;
    Label2: TLabel;
    txtWavSecs: TEdit;
    pbrExport: TProgressBar;
    cmdOK: TButton;
    cmdCancel: TButton;
    dlgSave: TSaveDialog;
    procedure cmdOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    SpecEmu: TSpecEmu;
    iPattern: integer;
    iTargetLen: Cardinal;
    bStopPlayer: boolean;
    procedure NewPattern;
  public
    { Public declarations }
  end;

var
  ExportWavDlg: TExportWavDlg;

implementation

uses frmSTMainWnd;

{$R *.dfm}

procedure TExportWavDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  bStopPlayer := true;
  iTargetLen := 0;
end;

procedure TExportWavDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  bStopPlayer := true;
  iTargetLen := 0;
end;

procedure TExportWavDlg.FormDestroy(Sender: TObject);
begin
  bStopPlayer := true;
  iTargetLen := 0;
end;

procedure TExportWavDlg.FormHide(Sender: TObject);
begin
  bStopPlayer := true;
  iTargetLen := 0;
end;

procedure TExportWavDlg.FormShow(Sender: TObject);
begin
  pbrExport.Position := 0;
  optNoLoop.Checked := true;
  txtWavSecs.Text := '120';
end;

procedure TExportWavDlg.NewPattern();
begin
  inc(iPattern);
  if (iPattern > STMainWnd.Song.SongLength) then
    bStopPlayer := true
  else
  begin
    pbrExport.Position := iPattern;
    Refresh;
  end;
end;

procedure TExportWavDlg.cmdOKClick(Sender: TObject);
var
  sFileName: string;
begin
  if (Sender as TButton).Caption = 'Abort' then
  begin
    bStopPlayer := true;
    iTargetLen := 0;
    pbrExport.Position := 0;
    exit;
  end;

  if not dlgSave.Execute then
    exit;

  sFileName := dlgSave.FileName;
  if sFileName = '' then exit;
  

  SpecEmu := TSpecEmu.Create(STMainWnd.hWaveOut);
  if STMainWnd.Song.PreferredEngine = 'SFX' then
    SpecEmu.Engine := SFX
  else if STMainWnd.Song.PreferredEngine = 'TMB' then
    SpecEmu.Engine := TMB
  else if STMainWnd.Song.PreferredEngine = 'MSD' then
    SpecEmu.Engine := MSD
  else if STMainWnd.Song.PreferredEngine = 'P1D' then
    SpecEmu.Engine := P1D
  else if STMainWnd.Song.PreferredEngine = 'P1S' then
    SpecEmu.Engine := P1S
  else if STMainWnd.Song.PreferredEngine = 'SVG' then
    SpecEmu.Engine := SVG
  //else if STMainWnd.Song.PreferredEngine = 'RMB' then
    //SpecEmu.Engine := RMB
  else
    SpecEmu.Engine := SFX;

  SpecEmu.LoadPlayerSong(STMainWnd.Song);

  SpecEmu.WavOutputFile := sFileName;
  if SpecEmu.WavOutputFile <> sFileName then
  begin
    Application.MessageBox('Unable to create output file. The file may be in use, or the target directory may be read only.',
                           PAnsiChar(Application.Title),
                           MB_ICONEXCLAMATION or MB_OK);
    exit;                           
  end;

  SpecEmu.Register_SP := $7FF0; // stack pointer - 32752
  SpecEmu.Register_PC := $8000; //$8000; // program counter - 32768

  cmdOK.Enabled := true;
  cmdOK.Caption := 'Abort';

  cmdCancel.Enabled := false;
  if optNoLoop.Checked then
  begin
    SpecEmu.OnNewPattern := NewPattern;
    iPattern := 0;
    pbrExport.Max := STMainWnd.Song.SongLength;
    bStopPlayer := false;
    while not bStopPlayer do
    begin
      SpecEmu.Exec(true);
      Application.ProcessMessages;
    end;
  end
  else
  begin
    // Timed output
    iTargetLen := StrToIntDef(txtWavSecs.Text,0);
    iTargetLen := Trunc(Abs(iTargetLen * 44100));
    pbrExport.Max := iTargetLen;
    while SpecEmu.WavDataLength < iTargetLen do
    begin
      SpecEmu.Exec(true);
      pbrExport.Position := SpecEmu.WavDataLength;
      Application.ProcessMessages;      
    end;
  end;

  SpecEmu.CloseWaveFile();
  FreeAndNil(SpecEmu);
  cmdOK.Caption := 'OK';
  cmdOK.Enabled := true;
  cmdCancel.Enabled := true;

//  Self.ModalResult := mrOK;
end;

end.
