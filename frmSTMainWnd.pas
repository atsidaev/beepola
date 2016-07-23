unit frmSTMainWnd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Grids, StdCtrls, ComCtrls, ExtCtrls, MMSystem, STSong,
  SpecEmu, STPatterns, Buttons, ImgList, PlayerThread, MRUList, RegSettings;

type
  TPlaying = (PLAY_SONG, PLAY_PATTERN);

type
  TSTMainWnd = class(TForm)
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuFileNew: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuFileSave: TMenuItem;
    mnuFileSaveAs: TMenuItem;
    N1: TMenuItem;
    mnuExit: TMenuItem;
    mnuPlay: TMenuItem;
    mnuPlaySong: TMenuItem;
    mnuPlayPattern: TMenuItem;
    mnuTools: TMenuItem;
    mnuCompile: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHelpKeys: TMenuItem;
    N2: TMenuItem;
    mnuAbout: TMenuItem;
    dlgSave: TSaveDialog;
    dlgOpen: TOpenDialog;
    mnuPattern: TMenuItem;
    mnuPatternCopy: TMenuItem;
    mnuPatternTranspose: TMenuItem;
    mnuPlayStop: TMenuItem;
    N4: TMenuItem;
    mnuPlayToneGen: TMenuItem;
    mnuTGSpecialFX: TMenuItem;
    mnuTGTheMusicBox: TMenuItem;
    pnlPattern: TPanel;
    lblPatternNum: TLabel;
    lblPatternLen: TLabel;
    lblTempo: TLabel;
    lblPatternName: TLabel;
    lblAutoInc: TLabel;
    txtPatternLen: TEdit;
    udnPatternLen: TUpDown;
    txtPatternNum: TEdit;
    udnPatternNum: TUpDown;
    txtTempo: TEdit;
    udnTempo: TUpDown;
    grdPattern: TStringGrid;
    txtPatternName: TEdit;
    cboAutoInc: TComboBox;
    pnlKeys: TPanel;
    imgPianoKeys: TImage;
    udnOctave: TUpDown;
    txtOctave: TEdit;
    lblOctave: TLabel;
    imgCh1Note: TImage;
    imgCh2Note: TImage;
    pnlSongInfo: TPanel;
    grdSong: TStringGrid;
    pbxLoopStart: TPaintBox;
    lblSongTitle: TLabel;
    txtSongTitle: TEdit;
    lblSongAuthor: TLabel;
    txtSongAuthor: TEdit;
    mnuEdit: TMenuItem;
    mnuEditCopy: TMenuItem;
    mnuEditPaste: TMenuItem;
    N3: TMenuItem;
    mnuEditUndo: TMenuItem;
    mnuHelpOnline: TMenuItem;
    mnuTGMusicStudio: TMenuItem;
    N5: TMenuItem;
    mnuSongInfo: TMenuItem;
    mnuSongTranspose: TMenuItem;
    mnuExportWAVFile: TMenuItem;
    N7: TMenuItem;
    mnuPlayFromCurrent: TMenuItem;
    mnuTGPhaser1Digital: TMenuItem;
    mnuTGPhaser1Synth: TMenuItem;
    pnlPhaser1Ed: TPanel;
    lblP1InstrEd: TLabel;
    lblP1Instrument: TLabel;
    lblP1Mult: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtP1Instrument: TEdit;
    udnP1Instrument: TUpDown;
    txtP1Mult: TEdit;
    udnP1Mult: TUpDown;
    txtP1Detune: TEdit;
    udnP1Detune: TUpDown;
    txtP1Phase: TEdit;
    udnP1Phase: TUpDown;
    N8: TMenuItem;
    mnuSong: TMenuItem;
    chkP1InstInUse: TCheckBox;
    Label1: TLabel;
    btnP1Test: TSpeedButton;
    pnlToolbar: TPanel;
    sbnOpen: TSpeedButton;
    sbnSave: TSpeedButton;
    sbnNew: TSpeedButton;
    sbnCompileSong: TSpeedButton;
    sbnPlay: TSpeedButton;
    sbnPlayFromCurrent: TSpeedButton;
    sbnPlayPattern: TSpeedButton;
    sbnStop: TSpeedButton;
    cboBeeperEngine: TComboBox;
    imlMenus: TImageList;
    sbnSongInfo: TSpeedButton;
    imgSep1: TImage;
    Image1: TImage;
    Image2: TImage;
    pnlSavageOrnEditor: TPanel;
    lblSavageArpEditor: TLabel;
    mnuPatternSwapChans: TMenuItem;
    mnuPatternAppend: TMenuItem;
    N6: TMenuItem;
    mnuFileImport: TMenuItem;
    mnuImportVTIIText: TMenuItem;
    dlgImport: TOpenDialog;
    mnuSongAdjustTempo: TMenuItem;
    mnuTGSavage: TMenuItem;
    lblSavageOrnament: TLabel;
    txtSvgOrnament: TEdit;
    udnSvgOrnament: TUpDown;
    chkSavageOrnInUse: TCheckBox;
    lblSavageOrnInUse: TLabel;
    btnSavageTest: TSpeedButton;
    grdSVGOrnEdit: TStringGrid;
    N9: TMenuItem;
    mnuToolsOptions: TMenuItem;
    mnuPatternExpand: TMenuItem;
    mnuPatternShrink: TMenuItem;
    mnuImportRipper: TMenuItem;
    mnuPatternExpandX3: TMenuItem;
    mnuPatternShrinkX3: TMenuItem;
    mnuPatternExpandX2: TMenuItem;
    mnuPatternShrinkX2: TMenuItem;
    chkOrnLooped: TCheckBox;
    lblOrnLooped: TLabel;
    mnuTGROMBeep: TMenuItem;
    mnuTGPlipPlop: TMenuItem;
    mnuTGStocker: TMenuItem;
    procedure mnuCompileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure grdPatternKeyPress(Sender: TObject; var Key: Char);
    procedure txtPatternNumChange(Sender: TObject);
    procedure udnPatternLenClick(Sender: TObject; Button: TUDBtnType);
    procedure grdPatternKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuFileSaveAsClick(Sender: TObject);
    procedure mnuFileNewClick(Sender: TObject);
    procedure mnuFileSaveClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnuFileOpenClick(Sender: TObject);
    procedure txtPatternNameChange(Sender: TObject);
    procedure grdSongKeyPress(Sender: TObject; var Key: Char);
    procedure grdSongSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure grdSongKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure udnTempoClick(Sender: TObject; Button: TUDBtnType);
    procedure mnuPlaySongClick(Sender: TObject);
    procedure mnuPlayPatternClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure mnuPatternCopyClick(Sender: TObject);
    procedure mnuPlayStopClick(Sender: TObject);
    procedure mnuTGSpecialFXClick(Sender: TObject);
    procedure mnuTGTheMusicBoxClick(Sender: TObject);
    procedure grdPatternMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grdSongTopLeftChanged(Sender: TObject);
    procedure pbxLoopStartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbxLoopStartPaint(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure pbxLoopStartMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbxLoopStartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure grdPatternDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure txtSongTitleChange(Sender: TObject);
    procedure txtSongAuthorChange(Sender: TObject);
    procedure mnuPatternTransposeClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure grdPatternSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuHelpKeysClick(Sender: TObject);
    procedure mnuEditUndoClick(Sender: TObject);
    procedure mnuEditCopyClick(Sender: TObject);
    procedure mnuEditPasteClick(Sender: TObject);
    procedure mnuHelpOnlineClick(Sender: TObject);
    procedure mnuTGMusicStudioClick(Sender: TObject);
    procedure mnuSongInfoClick(Sender: TObject);
    procedure mnuSongTransposeClick(Sender: TObject);
    procedure imgPianoKeysMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgCh1NoteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnuExportWAVFileClick(Sender: TObject);
    procedure mnuPlayFromCurrentClick(Sender: TObject);
    procedure mnuTGPhaser1DigitalClick(Sender: TObject);
    procedure mnuTGPhaser1SynthClick(Sender: TObject);
    procedure txtP1InstrumentChange(Sender: TObject);
    procedure txtP1MultChange(Sender: TObject);
    procedure txtP1DetuneChange(Sender: TObject);
    procedure txtP1PhaseChange(Sender: TObject);
    procedure btnP1TestClick(Sender: TObject);
    procedure sbnNewClick(Sender: TObject);
    procedure sbnOpenClick(Sender: TObject);
    procedure sbnSaveClick(Sender: TObject);
    procedure sbnPlayClick(Sender: TObject);
    procedure cboBeeperEngineClick(Sender: TObject);
    procedure chkP1InstInUseClick(Sender: TObject);
    procedure mnuPatternSwapChansClick(Sender: TObject);
    procedure mnuPatternAppendClick(Sender: TObject);
    procedure mnuImportVTIITextClick(Sender: TObject);
    procedure mnuSongAdjustTempoClick(Sender: TObject);
    procedure mnuTGSavageClick(Sender: TObject);
    procedure chkSavageOrnInUseClick(Sender: TObject);
    procedure txtSvgOrnamentChange(Sender: TObject);
    procedure grdSVGOrnEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grdSVGOrnEditKeyPress(Sender: TObject; var Key: Char);
    procedure grdSVGOrnEditSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cboAutoIncChange(Sender: TObject);
    procedure btnSavageTestClick(Sender: TObject);
    procedure mnuToolsOptionsClick(Sender: TObject);
    procedure grdSongDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure mnuPatternExpandClick(Sender: TObject);
    procedure mnuPatternShrinkClick(Sender: TObject);
    procedure txtPatternLenExit(Sender: TObject);
    procedure txtTempoExit(Sender: TObject);
    procedure mnuImportRipperClick(Sender: TObject);
    procedure mnuPatternExpandX3Click(Sender: TObject);
    procedure mnuPatternShrinkX3Click(Sender: TObject);
    procedure pbxOrnLoopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblOrnLoopedClick(Sender: TObject);
    procedure chkOrnLoopedClick(Sender: TObject);
    procedure mnuTGROMBeepClick(Sender: TObject);
    procedure mnuTGPlipPlopClick(Sender: TObject);
    procedure mnuTGStockerClick(Sender: TObject);
  private
    { Private declarations }
    bMovingLoop: boolean;
    bNewSongItemEntry: boolean;
    bNewOrnamentItemEntry: boolean;
    bNewPatternCellEntry: boolean;
    SpecEmu: TSpecEmu;
    bStopPlayer: boolean;
    iPatternPlayer: integer;
    iPatternTickCount: integer;
    iPlayerRow: integer;
    ZXPlay: TPlayerThread;
    iOldPatternRow, iOldPatternCol: integer;
    FPlaying: TPlaying;
    MRUList: TMRUList;
    procedure InitDisplay;
    procedure InitPatternGrid;
    procedure NumberGridRows;
    function KeyToNoteVal(Key: Char; Octave: integer): byte;
    procedure UpdatePatternGrid;
    function IsValidNoteKey(Key: Char): boolean;
    procedure InitSongGrid;
    procedure UpdateSongGrid;
    procedure PatternPlayerNewPattern;
    procedure PatternTick;
    procedure SongPlayerNewPattern;
    procedure TMBPatternTick;
    procedure UpdatePianoKeys(iCh1, iCh2: integer);
    procedure DrawSongLoopStart;
    procedure NotePlayerNewPattern;
    function MousePosToNoteVal(X, Y: integer): integer;
    function GetPhaser1Instr(iRow: integer): byte;
    procedure Phaser1PatternTick;
    procedure P1InstrumentTestNewPattern;
    procedure WM_NewPattern(var Msg: TMessage); message WM_USER_NEWPATTERN;
    procedure WM_PatternTick(var Msg: TMessage); message WM_USER_PATTERNTICK;
    procedure WM_SongEnd(var Msg: TMessage); message WM_USER_SONGEND;
    procedure StopPlayer;
    procedure UpdateMRUMenu;
    procedure mnuMRUItemClick(Sender: TObject);
    procedure SetPatternEdStandard;
    procedure SetPatternEdSavage;
    procedure RenderStandardPatternInfo;
    procedure RenderSVGPatternInfo;
    procedure SavagePatternKeyDown(var Key: Word; Shift: TShiftState);
    procedure StdPatternKeyPress(var Key: Char);
    procedure SavagePatternKeyPress(var Key: Char);
    procedure InitSVGOrnEditGrid;
    procedure SetSvgOrnamentGrid(i: integer);
    function SVGGetGlissando(iPat, iChan, iRow: integer): integer;
    function SVGGetSkew(iPat, iChan, iRow: integer): integer;
    function SVGGetSkewXOR(iPat, iChan, iRow: integer): integer;
    function SVGGetArpeggio(iPat, iChan, iRow: integer): integer;
    function EvenRowNotes(iPat: integer): boolean;
    function TripleShrinkRowNotes(iPat: integer): boolean;
  public
    { Public declarations }
    hWaveOut: System.Cardinal;
    bSongDirty: boolean;
    sFileName: string;
    Song: TSTSong;
    UndoPattern: STPatterns.TPattern;
    UndoSvgPattern: STPatterns.TPatternSvg;
    RegSettings: TRegSettings;
  end;

var
  STMainWnd: TSTMainWnd;

implementation

uses frmCompileDlg, frmCopyPattern, frmTransposePatternDlg,
  frmAboutDlg, frmKeyLayoutWnd, ShellApi, frmSongInfoDlg, frmTransposeSongDlg,
  frmExportWavDlg, Math, frmSwapChannelsDlg, frmPatternAppendDlg, IniFiles,
  frmImportVTIIFileDlg, frmAdjustSongTempoDlg, frmOptionsDlg,
  frmSongRipper;

{$R *.dfm}
{$R BeepolaData.res}

var
  CopyPattern: STPatterns.TPattern;
  CopySVGPattern: STPatterns.TPatternSVG;
  iTimerPeriod: Cardinal;


function ExtractBBSongFileName(sFile: string): string;
begin
  Result := ExtractFileName(sFile);
  if LowerCase(Copy(Result,Length(Result) - 6,7)) = '.bbsong' then
    Result := Copy(Result,1,Length(Result)-7);
end;

procedure TSTMainWnd.P1InstrumentTestNewPattern();
begin
  iPatternTickCount := 0;
  inc(iPatternPlayer);
  if iPatternPlayer > 1 then
    StopPlayer();
end;

procedure TSTMainWnd.btnP1TestClick(Sender: TObject);
var
  Spec: TSpecEmu;
begin
  if bStopPlayer = false then exit;

  Spec := TSpecEmu.Create(Self.hWaveOut);
  Spec.Engine := P1D;

  Spec.Register_SP := $7FF0; // stack pointer - 32752
  Spec.Register_PC := $8000; //$8000; // program counter - 32768
  Spec.LoadPlayerNote(255,24,1,udnP1Instrument.Position and $FF,0,2,Song);
  Spec.OnNewPattern := P1InstrumentTestNewPattern;
  Spec.OnPatternTick := nil;

  iPatternPlayer := 0; // inc'd to 0 on first OnNewPattern event
  bStopPlayer := false;
  while bStopPlayer = false do
    Spec.Exec(false);

//  for i := 0 to 2 do
//    Spec.Exec(true);
  Spec.ResetWaveBuffers;
  Sleep(210);

  FreeAndNil(Spec);
end;

procedure TSTMainWnd.btnSavageTestClick(Sender: TObject);
var
  Spec: TSpecEmu;
  i: integer;
begin
  if bStopPlayer = false then exit;

  Spec := TSpecEmu.Create(Self.hWaveOut);
  Spec.Engine := SVG;

  Spec.Register_SP := $7FF0; // stack pointer - 32752
  Spec.Register_PC := $8000; //$8000; // program counter - 32768
  Spec.SavageLoadPlayerNote(255,24,0,0,0,0,0,0,0,udnSVGOrnament.Position and $FF,0,0,0,4,Song);
  Spec.OnNewPattern := P1InstrumentTestNewPattern;
  Spec.OnPatternTick := nil;

  iPatternPlayer := 0; // inc'd to 0 on first OnNewPattern event
  bStopPlayer := false;
  while bStopPlayer = false do
    Spec.Exec(false);

  for i := 0 to 2 do
    Spec.Exec(true);
  Sleep(210);
  Spec.ResetWaveBuffers;

  FreeAndNil(Spec);
end;

procedure TSTMainWnd.Button1Click(Sender: TObject);
begin

  //SpecEmu.WavOutputFile := 'c:\users\chris\bb-debug.wav';
end;

procedure TSTMainWnd.cboAutoIncChange(Sender: TObject);
begin
  grdPattern.SetFocus();
  UpdatePatternGrid();
end;

procedure TSTMainWnd.cboBeeperEngineClick(Sender: TObject);
begin
  case (Sender as TComboBox).ItemIndex of
  0: mnuTGSpecialFXClick(nil);
  1: mnuTGTheMusicBoxClick(nil);
  2: mnuTGMusicStudioClick(nil);
  3: mnuTGPhaser1DigitalClick(nil);
  4: mnuTGPhaser1SynthClick(nil);
  5: mnuTGSavageClick(nil);
  6: mnuTGROMBeepClick(nil);
  7: mnuTGPlipPlopClick(nil);
  8: mnuTGStockerClick(nil);
  end;
end;

procedure TSTMainWnd.chkOrnLoopedClick(Sender: TObject);
begin
  bSongDirty := true;
  if Song.SVGArpeggio[udnSvgOrnament.Position].Length = 0 then exit;

  if chkOrnLooped.Checked then
    Song.SvgArpeggio[udnSvgOrnament.Position].Value[Song.SvgArpeggio[udnSvgOrnament.Position].Length] :=
      Song.SvgArpeggio[udnSvgOrnament.Position].Value[Song.SvgArpeggio[udnSvgOrnament.Position].Length] or $80
  else
    Song.SvgArpeggio[udnSvgOrnament.Position].Value[Song.SvgArpeggio[udnSvgOrnament.Position].Length] :=
      Song.SvgArpeggio[udnSvgOrnament.Position].Value[Song.SvgArpeggio[udnSvgOrnament.Position].Length] and $7F;
end;

procedure TSTMainWnd.chkP1InstInUseClick(Sender: TObject);
begin
  txtP1InstrumentChange(nil);
end;

procedure TSTMainWnd.chkSavageOrnInUseClick(Sender: TObject);
begin
  txtSvgOrnamentChange(nil);
end;

procedure TSTMainWnd.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  iRet: integer;
begin
  StopPlayer();

  if bSongDirty then
  begin
    iRet :=  Application.MessageBox('Do you want to save changes to the current song?',
                            PAnsiChar(Application.Title),
                            MB_YESNOCANCEL or MB_DEFBUTTON3 or MB_ICONQUESTION);
    if iRet = ID_YES then
    begin
      if sFileName <> '' then
        mnuFileSaveClick(nil)
      else
        mnuFileSaveAsClick(nil);

      if not bSongDirty then
      begin
        CanClose := true;
      end;
    end
    else if iRet = ID_NO then
    begin
      CanClose := true;
    end
    else if iRet = ID_CANCEL then CanClose := false;
  end
  else
    CanClose := true;
end;

procedure TSTMainWnd.FormCreate(Sender: TObject);
var
  TimeCaps: TTimeCaps;
  iRet: integer;
  sErrMsg: string;
  WavFormat: TWaveFormatEx;
begin
  MRUList := TMRUList.Create();
  MRUList.Size := 5;
  MRUList.Load();

  RegSettings := TRegSettings.Create();

  Song := TSTSong.Create();
  bSongDirty := false;
  sFileName := '';

  hWaveOut := INVALID_HANDLE_VALUE;

  with WavFormat do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := 1;
    nSamplesPerSec := 44100;
    nAvgBytesPerSec := 44100;
    nBlockAlign := 1;
    wBitsPerSample := 8;
    cbSize := 0;
  end;

  iRet := waveOutOpen(@hWaveOut, WAVE_MAPPER, @WavFormat, 0, 0, CALLBACK_NULL);
  if iRet <> MMSYSERR_NOERROR then
  begin
    sErrMsg := StringOfChar(#0,255);
    waveOutGetErrorText(iRet, PAnsiChar(sErrMsg), Length(sErrMsg));
    sErrMsg := Copy(sErrMsg, 1, Pos(#0,sErrMsg)- 1);
    ShowMessage('Error initialising WaveOut device.'#13#10#13#10 + sErrMsg);
    exit;
  end;

  SpecEmu := TSpecEmu.Create(Self.hWaveOut);
  SpecEmu.Engine := sfx;

  Self.DoubleBuffered := true;
  pnlPattern.DoubleBuffered := true;
  pnlKeys.DoubleBuffered := true;
  pnlSongInfo.DoubleBuffered := true;
  pnlToolbar.DoubleBuffered := true;

  InitSongGrid();
  grdSVGOrnEdit.Height := grdSVGOrnEdit.RowHeights[0] + GetSystemMetrics(SM_CXHSCROLL) + 5;
  StopPlayer();

  UpdateMRUMenu();

  timeGetDevCaps(@TimeCaps,SizeOf(TimeCaps));
  iTimerPeriod := TimeCaps.wPeriodMin;
  timeBeginPeriod(iTimerPeriod);
end;

procedure TSTMainWnd.UpdateMRUMenu();
var
  Item: TMenuItem;
  i: Integer;
begin
  for i := mnuFile.Count - 1 downto 0 do
  begin
    if Copy(mnuFile.Items[i].Name,1,6) = 'mnuMRU' then
      mnuFile.Items[i].Free;
  end;
  if MRUList.ItemCount < 1 then exit;

  Item := TMenuItem.Create(mnuFile);
  Item.Caption := '-';
  Item.Name := 'mnuMRUSep';
  mnuFile.Add(Item);
  for i := 0 to MRUList.ItemCount - 1 do
  begin
    Item := TMenuItem.Create(mnuFile);
    Item.Caption := '&' + IntToStr(i+1) + ' ' + MRUList.Item[i];
    Item.Name := 'mnuMRU' + IntToStr(i);
    Item.OnClick := mnuMRUItemClick;
    mnuFile.Add(Item);
  end;
end;

procedure TSTMainWnd.mnuMRUItemClick(Sender: TObject);
var
  iRet: integer;
  sFile: string;
begin
  StopPlayer();

  if bSongDirty then
  begin
    iRet :=  Application.MessageBox('Do you want to save changes to the current song?',
                            PAnsiChar(Application.Title),
                            MB_YESNOCANCEL or MB_DEFBUTTON3 or MB_ICONQUESTION);
    if iRet = ID_YES then
    begin
      if sFileName <> '' then
        mnuFileSaveClick(nil)
      else
        mnuFileSaveAsClick(nil);

      if bSongDirty then exit; // Failed to save file or Save Cancelled
    end
    else if iRet = ID_CANCEL then exit;
  end;

  sFile := Trim(Copy((Sender as TMenuItem).Caption,4,2048));
  if FileExists(sFile) then
  begin
    if Song.LoadFile(sFile) then
    begin
      sFileName := sFile;
      Self.Caption := ExtractBBSongFileName(sFileName) + ' - ' + Application.Title;
      udnPatternNum.Position := 0;
      UpdateSongGrid();
      UpdatePatternGrid();
      DrawSongLoopStart();
      UndoPattern := Song.Pattern[0];
      UndoSvgPattern := Song.SvgPatternData[0];
      if Song.PreferredEngine = 'TMB' then
      begin
        mnuTGTheMusicBoxClick(nil);
      end
      else if Song.PreferredEngine = 'MSD' then
      begin
        mnuTGMusicStudioClick(nil);
      end
      else if Song.PreferredEngine = 'P1D' then
      begin
        mnuTGPhaser1DigitalClick(nil);
      end
      else if Song.PreferredEngine = 'P1S' then
      begin
        mnuTGPhaser1SynthClick(nil);
      end
      else if Song.PreferredEngine = 'SVG' then
      begin
        mnuTGSavageClick(nil);
      end
      else
      begin
        mnuTGSpecialFXClick(nil);
      end;

      grdPattern.SetFocus();
      bSongDirty := false;
      MRUList.AddFile(sFileName);
      UpdateMRUMenu();
    end;
  end;
end;

procedure TSTMainWnd.FormDestroy(Sender: TObject);
begin
  timeEndPeriod(iTimerPeriod);
  FreeAndNil(MRUList);
  FreeAndNil(SpecEmu);
  FreeAndNil(Song);
  WaveOutClose(hWaveOut);
end;

procedure TSTMainWnd.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case KEY of
  VK_NUMPAD1:
    begin
      udnOctave.SetFocus;
      udnOctave.Position := 1;
    end;
  VK_NUMPAD2:
    begin
      udnOctave.SetFocus;
      udnOctave.Position := 2;
    end;
  VK_NUMPAD3:
    begin
      udnOctave.SetFocus;
      udnOctave.Position := 3;
    end;
  VK_NUMPAD4:
    begin
      udnOctave.SetFocus;
      udnOctave.Position := 4;
    end;
  VK_NUMPAD5:
    begin
      udnOctave.SetFocus;
      udnOctave.Position := 5;
    end;
  end;
end;

procedure TSTMainWnd.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if udnOctave.Focused then
  begin
    Key := #0;
    grdPattern.SetFocus;
  end;
  if Key = ' ' then
  begin
    StopPlayer();
  end;
end;

procedure TSTMainWnd.FormPaint(Sender: TObject);
var
  Ht,Row: integer;
begin
  Ht := (ClientHeight + 255) div 192 ;
  for Row := 0 to 255 do
    with Canvas do begin
      Brush.Color := RGB(0, 0, Row) ;
      FillRect(Rect(0, Row * Ht,
               ClientWidth, (Row + 1) * Ht)) ;
    end;
end;

procedure TSTMainWnd.FormResize(Sender: TObject);
begin
  if Assigned(Song) then
  begin
    UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                    Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
  end;
  FormPaint(Sender);
end;

procedure TSTMainWnd.FormShow(Sender: TObject);
var
  sFileName: string;
begin
  InitDisplay();

  // If a file name is specified on the cmd line, then attempt to load it
  if (ParamStr(1) <> '') and (Copy(ParamStr(1),1,1) <> '-') then
  begin
    if Song.LoadFile(ParamStr(1)) then
    begin
      sFileName := ParamStr(1);
      Self.Caption := ExtractBBSongFileName(sFileName) + ' - ' + Application.Title;
      udnPatternNum.Position := 0;
      if Song.PreferredEngine = 'TMB' then
      begin
        mnuTGTheMusicBoxClick(nil);
      end
      else if Song.PreferredEngine = 'MSD' then
      begin
        mnuTGMusicStudioClick(nil);
      end
      else if Song.PreferredEngine = 'P1D' then
      begin
        mnuTGPhaser1DigitalClick(nil);
      end
      else if Song.PreferredEngine = 'P1S' then
      begin
        mnuTGPhaser1SynthClick(nil);
      end
      else if Song.PreferredEngine = 'SVG' then
      begin
        mnuTGSavageClick(nil);
      end
      else if Song.PreferredEngine = 'RMB' then
      begin
        mnuTGROMBeepClick(nil);
      end
      else if Song.PreferredEngine = 'PLP' then
      begin
        mnuTGPlipPlopClick(nil);
      end
      else if Song.PreferredEngine = 'STK' then
      begin
        mnuTGStockerClick(nil);
      end
      else
      begin
        mnuTGSpecialFXClick(nil);
      end;
    end;
  end;


  UpdateSongGrid();
  UpdatePatternGrid();
  DrawSongLoopStart();
  grdPattern.SetFocus();
  CopyPattern := Song.Pattern[0];
  UndoPattern := Song.Pattern[0];
  UndoSvgPattern := Song.SvgPatternData[0];
  bSongDirty := false;
end;

function TSTMainWnd.GetPhaser1Instr(iRow: integer): byte;
var
  i: Integer;
begin
  Result := 0;

  for i := 1 to iRow do
  begin
    if Song.Pattern[udnPatternNum.Position].Sustain[2][i] < 255 then
      Result := Song.Pattern[udnPatternNum.Position].Sustain[2][i];
  end;
end;

procedure TSTMainWnd.grdPatternKeyPress(Sender: TObject; var Key: Char);
begin
  if not bStopPlayer then exit;
  if Key = #9 then exit;

  if Song.PreferredEngine = 'SVG' then
    SavagePatternKeyPress(Key)
  else
    StdPatternKeyPress(Key);
end;

function TSTMainWnd.SVGGetGlissando(iPat,iChan,iRow: integer): integer;
var
  i: Integer;
begin
  Result := 0; // Default to glis 0

  for i := 1 to iRow do
  begin
    if Song.SvgPatternData[iPat].Glissando[iChan][i] <> 256 then
      Result := Song.SvgPatternData[iPat].Glissando[iChan][i];
  end;
end;

function TSTMainWnd.SVGGetSkew(iPat,iChan,iRow: integer): integer;
var
  i: Integer;
begin
  Result := 0; // Default to glis 0

  for i := 1 to iRow do
  begin
    if Song.SvgPatternData[iPat].Skew[iChan][i] <> 256 then
      Result := Song.SvgPatternData[iPat].Skew[iChan][i];
  end;
end;

function TSTMainWnd.SVGGetSkewXOR(iPat,iChan,iRow: integer): integer;
var
  i: Integer;
begin
  Result := 0; // Default to glis 0

  for i := 1 to iRow do
  begin
    if Song.SvgPatternData[iPat].SkewXOR[iChan][i] <> 256 then
      Result := Song.SvgPatternData[iPat].SkewXOR[iChan][i];
  end;
end;

function TSTMainWnd.SVGGetArpeggio(iPat,iChan,iRow: integer): integer;
var
  i: Integer;
begin
  Result := 0; // Default to glis 0

  for i := 1 to iRow do
  begin
    if Song.SvgPatternData[iPat].Arpeggio[iChan][i] <> 256 then
      Result := Song.SvgPatternData[iPat].Arpeggio[iChan][i];
  end;
end;

procedure TSTMainWnd.SavagePatternKeyPress(var Key: Char);
var
  iChan: integer;
  wEditVal: word;
  KeyVal: byte;
begin
  if (grdPattern.Col = 1) or (grdPattern.Col = 7) then
  begin
    if (grdPattern.Col = 1) then iChan := 1 else iChan := 2;

    if IsValidNoteKey(Key) then
    begin
      UndoPattern := Song.Pattern[udnPatternNum.Position];
      UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];
      Song.Pattern[udnPatternNum.Position].Chan[iChan][grdPattern.Row] := KeyToNoteVal(Key,udnOctave.Position);
      UpdatePatternGrid();

      SpecEmu.Register_SP := $7FF0; // stack pointer - 32752
      SpecEmu.Register_PC := $8000; //$8000; // program counter - 32768
      SpecEmu.SavageLoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                                   Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Glissando[1][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Glissando[2][grdPattern.Row],
                                   SVGGetSkew(udnPatternNum.Position,1,grdPattern.Row),
                                   SVGGetSkew(udnPatternNum.Position,2,grdPattern.Row),
                                   SVGGetSkewXOR(udnPatternNum.Position,1,grdPattern.Row),
                                   SVGGetSkewXOR(udnPatternNum.Position,2,grdPattern.Row),
                                   SVGGetArpeggio(udnPatternNum.Position,1,grdPattern.Row),
                                   SVGGetArpeggio(udnPatternNum.Position,2,grdPattern.Row),
                                   Song.SvgPatternData[udnPatternNum.Position].Warp[1][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Warp[2][grdPattern.Row],
                                   Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],
                                   Song.Pattern[udnPatternNum.Position].Tempo,
                                   Song);
      SpecEmu.OnNewPattern := NotePlayerNewPattern;
      SpecEmu.OnPatternTick := nil;

      iPatternPlayer := 0; // inc'd to 0 on first OnNewPattern event
      bStopPlayer := false;
      while bStopPlayer = false do
        SpecEmu.Exec(false);

      for iChan := 0 to 5 do
        SpecEmu.Exec(false);
                
      SpecEmu.ResetWaveBuffers;

      bSongDirty := true;
    end
    else
      exit;
  end
  else if grdPattern.Col = 13 then
  begin
    // Drum Channel
    if (Key >= '0') and (Key <= '9') then
    begin
      UndoPattern := Song.Pattern[udnPatternNum.Position];
      UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

      if bNewPatternCellEntry or ((Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row]-$80)  * 10 >= 254) then
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := $80 + StrToIntDef(Key,0)
      else
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := $80 + (Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row]-$80) * 10 + StrToIntDef(Key,0);

      if Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] > $85 then
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := 0;

      if Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] < $81 then
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := 0;
      UpdatePatternGrid();

      SpecEmu.Register_SP := $7FF0; // stack pointer - 32752
      SpecEmu.Register_PC := $8000; //$8000; // program counter - 32768
      SpecEmu.SavageLoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                                   Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Glissando[1][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Glissando[2][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Skew[1][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Skew[2][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].SkewXOR[1][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].SkewXOR[2][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Warp[1][grdPattern.Row],
                                   Song.SvgPatternData[udnPatternNum.Position].Warp[2][grdPattern.Row],
                                   Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],
                                   Song.Pattern[udnPatternNum.Position].Tempo,
                                   Song);
      SpecEmu.OnNewPattern := NotePlayerNewPattern;
      SpecEmu.OnPatternTick := nil;

      iPatternPlayer := 0; // inc'd to 0 on first OnNewPattern event
      bStopPlayer := false;
      bNewPatternCellEntry := true; // always true as Savage drums < 10
      while bStopPlayer = false do
        SpecEmu.Exec(false);

      for iChan := 0 to 5 do
        SpecEmu.Exec(false);
                
      SpecEmu.ResetWaveBuffers;

      bSongDirty := true;
    end;
  end
  else if ((grdPattern.Col >= 2) and (grdPattern.Col <= 6)) or
          ((grdPattern.Col >= 8) and (grdPattern.Col <= 12)) then
  begin
    if (grdPattern.Col < 7) then iChan := 1 else iChan := 2;
    // Glis/Skew/Xor/Arp value for iChan
    wEditVal := 0;

    UndoPattern := Song.Pattern[udnPatternNum.Position];
    UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];
    case grdPattern.Col of
    2,8:  wEditVal := Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][grdPattern.Row];
    3,9:  wEditVal := Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][grdPattern.Row];
    4,10: wEditVal := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][grdPattern.Row];
    5,11: wEditVal := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][grdPattern.Row];
    6,12: wEditVal := Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][grdPattern.Row];
    end;

    if Key >= 'a' then Key := Chr(byte(Key) and $DF); // Make Uppercase
    if ((Key >= '0') and (Key <= '9')) or ((Key >= 'A') and (Key <= 'F')) then
    begin
      if (Key <= '9') then KeyVal := byte(Key)-48 else KeyVal := byte(Key)-55;
      
      if bNewPatternCellEntry or (wEditVal  * 16 >= 255) then
        wEditVal := KeyVal
      else
        wEditVal := wEditVal * 16 + KeyVal;

      case grdPattern.Col of
      2,8:  Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][grdPattern.Row] := wEditVal;
      3,9:  Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][grdPattern.Row] := wEditVal;
      4,10:  Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][grdPattern.Row] := wEditVal;
      5,11: Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][grdPattern.Row] := wEditVal;
      6,12: if wEditVal > 0 then Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][grdPattern.Row] := 255 else Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][grdPattern.Row] := 0;
      end;
      UpdatePatternGrid();
      bSongDirty := true;
      bNewPatternCellEntry := false;
      if (pnlSavageOrnEditor.Visible) then
        txtSvgOrnamentChange(nil); // Cause the "Is Instrument in use" flag to update
      exit;
    end
    else if Key = #13 then
    begin
      // Highlight next pattern row
      if grdPattern.Row < grdPattern.RowCount - 1 then
        grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1
      else
        grdPattern.Row := 1;
      exit;
    end
    else if Key = #8 then
    begin
      // Backspace
      UndoPattern := Song.Pattern[udnPatternNum.Position];
      UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];
      wEditVal := 256;
      case grdPattern.Col of
      2,7:  Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][grdPattern.Row] := wEditVal;
      3,8:  Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][grdPattern.Row] := wEditVal;
      4,9:  Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][grdPattern.Row] := wEditVal;
      5,10: Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][grdPattern.Row] := wEditVal;
      end;
      UpdatePatternGrid();
      if (pnlSavageOrnEditor.Visible) then
        txtSvgOrnamentChange(nil); // Cause the "Is Instrument in use" flag to update
      bSongDirty := true;
      exit; // do not advance the input cursor
    end
    else
      exit;
  end
  else
    exit;

  UpdatePatternGrid();
  grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1
end;

procedure TSTMainWnd.StdPatternKeyPress(var Key: Char);
var
  iChan: integer;
begin
  if (grdPattern.Col = 1) or (grdPattern.Col = 3) then
  begin
    if (grdPattern.Col = 1) then iChan := 1 else iChan := 2;

    if IsValidNoteKey(Key) then
    begin
      UndoPattern := Song.Pattern[udnPatternNum.Position];
      UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];
      Song.Pattern[udnPatternNum.Position].Chan[iChan][grdPattern.Row] := KeyToNoteVal(Key,udnOctave.Position);
      UpdatePatternGrid();

      SpecEmu.Register_SP := $7FF0; // stack pointer - 32752
      SpecEmu.Register_PC := $8000; //$8000; // program counter - 32768
      if (Song.PreferredEngine = 'P1D') or (Song.PreferredEngine = 'P1S') then
        SpecEmu.LoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                               Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                               255,GetPhaser1Instr(grdPattern.Row),Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],Song.Pattern[udnPatternNum.Position].Tempo,Song)
      else
        SpecEmu.LoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                               Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                               2,2,Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],Song.Pattern[udnPatternNum.Position].Tempo,Song);
      SpecEmu.OnNewPattern := NotePlayerNewPattern;
      SpecEmu.OnPatternTick := nil;

      iPatternPlayer := 0; // inc'd to 0 on first OnNewPattern event
      bStopPlayer := false;
      while bStopPlayer = false do
        SpecEmu.Exec(false);

      for iChan := 0 to 5 do
        SpecEmu.Exec(false);

      SpecEmu.ResetWaveBuffers;

      bSongDirty := true;
    end
    else
      exit;
  end
  else if grdPattern.Col = 5 then
  begin
    // Drum Channel
    if (Key >= '0') and (Key <= '9') then
    begin
      UndoPattern := Song.Pattern[udnPatternNum.Position];
      UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

      if bNewPatternCellEntry or ((Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row]-$80)  * 10 >= 254) then
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := $80 + StrToIntDef(Key,0)
      else
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := $80 + (Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row]-$80) * 10 + StrToIntDef(Key,0);

      if Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] > $8D then
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := 0;

      if Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] < $81 then
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := 0;
      UpdatePatternGrid();

      SpecEmu.Register_SP := $7FF0; // stack pointer - 32752
      SpecEmu.Register_PC := $8000; //$8000; // program counter - 32768
      if (Song.PreferredEngine = 'P1D') or (Song.PreferredEngine = 'P1S') then
        SpecEmu.LoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                               Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                               0,GetPhaser1Instr(grdPattern.Row),Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],Song.Pattern[udnPatternNum.Position].Tempo,Song)
      else
        SpecEmu.LoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                               Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                               2,2,Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],Song.Pattern[udnPatternNum.Position].Tempo,Song);
      SpecEmu.OnNewPattern := NotePlayerNewPattern;
      SpecEmu.OnPatternTick := nil;

      iPatternPlayer := 0; // inc'd to 0 on first OnNewPattern event
      bStopPlayer := false;
      bNewPatternCellEntry := false;
      while bStopPlayer = false do
        SpecEmu.Exec(false);

      for iChan := 0 to 5 do
        SpecEmu.Exec(false);
                
      SpecEmu.ResetWaveBuffers;

      bSongDirty := true;
      if Song.PreferredEngine = 'MSD' then exit else bNewPatternCellEntry := true; // MSD drums are 2 digits
    end;
  end
  else if (grdPattern.Col = 2) or (grdPattern.Col =4) then
  begin
    if (grdPattern.Col = 2) then iChan := 1 else iChan := 2;
    // Sustain
    UndoPattern := Song.Pattern[udnPatternNum.Position];
    UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

    if (Key >= '0') and (Key <= '9') then
    begin
      if bNewPatternCellEntry or (Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row]  * 10 >= 254) then
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] := byte(Key)-48
      else
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] := Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] * 10 + byte(Key)-48;
      UpdatePatternGrid();
      bSongDirty := true;
      bNewPatternCellEntry := false;
      if (pnlPhaser1Ed.Visible) then
        txtP1InstrumentChange(nil); // Cause the "Is Instrument in use" flag to update
      exit;
    end
    else if Key = #13 then
    begin
      // Highlight next pattern row
      if grdPattern.Row < grdPattern.RowCount - 1 then
        grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1
      else
        grdPattern.Row := 1;
      exit;
    end
    else if Key = #8 then
    begin
      // Backspace
      if Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] = 255 then
        exit
      else if Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] >= 10 then
      begin
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] := Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] div 10;
        UpdatePatternGrid();
        bSongDirty := true;
        if (pnlPhaser1Ed.Visible) then
          txtP1InstrumentChange(nil); // Cause the "Is Instrument in use" flag to update
        exit;
      end
      else
      begin
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] := 255;
        bSongDirty := true;
        if (pnlPhaser1Ed.Visible) then
          txtP1InstrumentChange(nil); // Cause the "Is Instrument in use" flag to update
      end;
    end;
  end
  else
    exit;

  UpdatePatternGrid();
  grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1
end;

procedure TSTMainWnd.grdPatternMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
  Refresh;
end;

procedure TSTMainWnd.grdPatternSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if ACol = 0 then exit;

  if not (bStopPlayer) and (ARow <> iPlayerRow) then
    CanSelect := false
  else
    bNewPatternCellEntry := true;
end;

procedure TSTMainWnd.UpdatePianoKeys(iCh1,iCh2: integer);
const
  NoteLeft: array [0..59] of integer =
            (009,016,023,031,039,054,061,069,076,084,091,099,
             114,121,128,136,144,159,166,174,181,189,196,204,
             219,226,233,241,249,264,271,279,286,294,301,309,
             324,331,338,346,354,369,376,384,391,399,406,414,
             429,436,443,451,459,474,481,489,496,504,511,519);
  NoteTop: array [0..59] of integer =
            (62,41,62,41,62,62,41,62,41,62,41,62,
             62,41,62,41,62,62,41,62,41,62,41,62,
             62,41,62,41,62,62,41,62,41,62,41,62,
             62,41,62,41,62,62,41,62,41,62,41,62,
             62,41,62,41,62,62,41,62,41,62,41,62);
begin
  Inc(iCh1,6);
  Inc(iCh2,6);
  if (iCh1 > 106) and (iCh1 < $80) then Dec(iCh1,107);
  if (iCh2 > 106) and (iCh2 < $80) then Dec(iCh2,107);

  if iCh1 > 61 then
    imgCh1Note.Hide
  else
  begin
    imgCh1Note.Left := NoteLeft[iCh1] - (imgCh1Note.Width div 2) + imgPianoKeys.Left;
    imgCh1Note.Top := imgPianoKeys.Top + NoteTop[iCh1] - (imgCh1Note.Height div 2);

    imgCh1Note.Show;
  end;

  if iCh2 > 61 then
    imgCh2Note.Hide
  else
  begin
    imgCh2Note.Left := NoteLeft[iCh2] - (imgCh2Note.Width div 2) + imgPianoKeys.Left;
    imgCh2Note.Top := imgPianoKeys.Top + NoteTop[iCh2] - (imgCh2Note.Height div 2) - 8;

    imgCh2Note.Show;
  end;

end;

procedure TSTMainWnd.grdSongDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if (ARow = 0) and RegSettings.ShowLayoutColNumbers then
  begin
    grdSong.Canvas.Font.Color := clBlack;
    grdSong.Canvas.TextRect(Rect,Rect.Left+2,Rect.Top+2,grdSong.Cells[ACol,ARow]);
  end;
end;

procedure TSTMainWnd.grdSongKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if bStopPlayer = false then exit;
  
  if Key = VK_DELETE then
  begin
    Song.DeleteSongLayoutItem(grdSong.Col);
    bNewSongItemEntry := true;
    UpdateSongGrid();    
  end
  else if Key = VK_INSERT then
  begin
    Song.InsertSongLayoutItem(grdSong.Col);
    bNewSongItemEntry := true;
    UpdateSongGrid();
  end;
end;

procedure TSTMainWnd.grdSongKeyPress(Sender: TObject; var Key: Char);
begin
  if bStopPlayer = false then exit;
  
  if (( grdSong.Col > 0) and (grdSong.Cells[grdSong.Col-1,grdSong.RowCount-1]='...') ) then
    exit;  // We can only edit the cell if it is not past the end of the song

  if (Key >= '0') and (Key <= '9') then
  begin
    if Song.SongLayout[grdSong.Col] = 255 then
      Song.SongLayout[grdSong.Col] := byte(Key)-48
    else if bNewSongItemEntry then
      Song.SongLayout[grdSong.Col] := byte(Key)-48
    else if Song.SongLayout[grdSong.Col] >= 100 then
      exit
    else if Song.SongLayout[grdSong.Col] * 10 + byte(Key)-48 < 127 then
      Song.SongLayout[grdSong.Col] := Song.SongLayout[grdSong.Col] * 10 + byte(Key)-48;
    UpdateSongGrid();
    bNewSongItemEntry := false;
    bSongDirty := true;
    exit;
  end
  else if Key = #13 then
  begin
    // Highlight next song column
    if grdSong.Col < grdSong.ColCount - 1 then
      grdSong.Col := grdSong.Col + 1
    else
      grdSong.Col := 1;
    exit;
  end
  else if Key = #8 then
  begin
    // Backspace
    if Song.SongLayout[grdSong.Col] = 255 then exit; // Nothing to delete - box is empty

    if Song.SongLayout[grdSong.Col] >= 10 then
    begin
      Song.SongLayout[grdSong.Col] := Song.SongLayout[grdSong.Col] div 10;
    end
    else
    begin
      Song.SongLayout[grdSong.Col] := 0
    end;
    UpdateSongGrid();
    bSongDirty := true;
  end;
end;

procedure TSTMainWnd.grdSongSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if not (bStopPlayer) and (ACol <> iPatternPlayer) then
    CanSelect := false
  else
  begin
    bNewSongItemEntry := true;
    if Song.SongLayout[ACol] <> 255 then
    begin
      udnPatternNum.Position := Song.SongLayout[ACol];
      txtPatternNum.Text := IntToStr(udnPatternNum.Position);
    end;
  end;
end;

procedure TSTMainWnd.grdSongTopLeftChanged(Sender: TObject);
begin
  DrawSongLoopStart();
end;

procedure TSTMainWnd.grdSVGOrnEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if bStopPlayer = false then exit;
  
  if Key = VK_DELETE then
  begin
    Song.DeleteSVGOrnItem(udnSvgOrnament.Position,grdSVGOrnEdit.Col+1);
    if chkOrnLooped.Checked then
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[Song.SVGArpeggio[udnSvgOrnament.Position].Length] := Song.SVGArpeggio[udnSvgOrnament.Position].Value[Song.SVGArpeggio[udnSvgOrnament.Position].Length] or $80
    else
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[Song.SVGArpeggio[udnSvgOrnament.Position].Length] := Song.SVGArpeggio[udnSvgOrnament.Position].Value[Song.SVGArpeggio[udnSvgOrnament.Position].Length] and $7F;    
    bNewOrnamentItemEntry := true;
    txtSvgOrnamentChange(nil);   
  end
  else if Key = VK_INSERT then
  begin
    Song.InsertSVGOrnItem(udnSvgOrnament.Position,grdSVGOrnEdit.Col+1);
    bNewOrnamentItemEntry := true;
    txtSvgOrnamentChange(nil);
  end;
end;

procedure TSTMainWnd.grdSVGOrnEditKeyPress(Sender: TObject; var Key: Char);
begin
  if bStopPlayer = false then exit;
  
  if (( grdSVGOrnEdit.Col > 0) and (grdSVGOrnEdit.Cells[grdSVGOrnEdit.Col-1,0]='...') ) then
    exit;  // We can only edit the cell if it is not past the end of the song

  if (Key >= '0') and (Key <= '9') then
  begin
    if Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] = 255 then
    begin
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] := byte(Key)-48;
      inc( Song.SVGArpeggio[udnSvgOrnament.Position].Length );
    end
    else if bNewOrnamentItemEntry then
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] := byte(Key)-48
    else if Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] and $7F >= 99 then
      exit
    else if (Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] * 10 + byte(Key)-48) and $7F < 99 then
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] := Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] * 10 + byte(Key)-48;
    if chkOrnLooped.Checked then
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[Song.SVGArpeggio[udnSvgOrnament.Position].Length] :=       Song.SVGArpeggio[udnSvgOrnament.Position].Value[Song.SVGArpeggio[udnSvgOrnament.Position].Length] or $80
    else
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[Song.SVGArpeggio[udnSvgOrnament.Position].Length] :=       Song.SVGArpeggio[udnSvgOrnament.Position].Value[Song.SVGArpeggio[udnSvgOrnament.Position].Length] and $7F;

    txtSvgOrnamentChange(nil);
    bNewOrnamentItemEntry := false;
    bSongDirty := true;
    exit;
  end
  else if Key = #13 then
  begin
    // Highlight next song column
    if grdSVGOrnEdit.Col < grdSVGOrnEdit.ColCount - 1 then
      grdSVGOrnEdit.Col := grdSVGOrnEdit.Col + 1
    else
      grdSVGOrnEdit.Col := 1;
    exit;
  end
  else if Key = #8 then
  begin
    // Backspace
    if Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] = 255 then
      exit; // Nothing to delete - box is empty

    if Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] >= 10 then
    begin
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] :=
        Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] div 10;
    end
    else
    begin
      Song.SVGArpeggio[udnSvgOrnament.Position].Value[grdSVGOrnEdit.Col+1] := 0
    end;
    txtSvgOrnamentChange(nil);
    bSongDirty := true;
  end;
end;

procedure TSTMainWnd.grdSVGOrnEditSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  bNewOrnamentItemEntry := true;
end;

function InRect(X,Y,L,T,R,B: integer): boolean;
begin
  if (X >= L) and (X <= R) and (Y >= T) and (Y <= B) then
    Result := true
  else
    Result := false;
end;

function TSTMainWnd.MousePosToNoteVal(X,Y: integer): integer;
const
  WhiteNote: array[0..6] of integer = (0,2,4,5,7,9,11);
begin
  // Test black notes first, then white
  if InRect(X,Y,12,12,20,48) then
    Result := -5
  else if InRect(X,Y,27,12,35,48) then
    Result := -3
  else if InRect(X,Y,57,12,65,48) then
    Result := 0
  else if InRect(X,Y,72,12,80,48) then
    Result := 2
  else if InRect(X,Y,86,12,94,48) then
    Result := 4
  else if InRect(X,Y,117,12,125,48) then
    Result := 7
  else if InRect(X,Y,132,12,140,48) then
    Result := 9
  else if InRect(X,Y,162,12,170,48) then
    Result := 12
  else if InRect(X,Y,177,12,185,48) then
    Result := 14
  else if InRect(X,Y,191,12,199,48) then
    Result := 16
  else if InRect(X,Y,222,12,230,48) then
    Result := 19
  else if InRect(X,Y,237,12,245,48) then
    Result := 21
  else if InRect(X,Y,267,12,275,48) then
    Result := 24
  else if InRect(X,Y,282,12,290,48) then
    Result := 26
  else if InRect(X,Y,296,12,304,48) then
    Result := 28
  else if InRect(X,Y,327,12,335,48) then
    Result := 31
  else if InRect(X,Y,342,12,350,48) then
    Result := 33
  else if InRect(X,Y,372,12,380,48) then
    Result := 36
  else if InRect(X,Y,387,12,395,48) then
    Result := 38
  else if InRect(X,Y,401,12,409,48) then
    Result := 40
  else if InRect(X,Y,432,12,440,48) then
    Result := 43
  else if InRect(X,Y,447,12,455,48) then
    Result := 45
  else if InRect(X,Y,477,12,485,48) then
    Result := 48
  else if InRect(X,Y,492,12,500,48) then
    Result := 50
  else if InRect(X,Y,506,12,514,48) then
    Result := 52
  else
    Result := 255;

  if Result = 255 then
  begin
    // Test for a white note
    if (Y >= 12) and (Y <= 69) and (X >= 1) and (X <= 525) then
    begin
      Result := WhiteNote[((X-1) div 15) mod 7] + ((X-1) div 105 * 12) - 6;
    end
    else
      Result := 255;
  end;

  if (Song.PreferredEngine = 'P1D') and (Result < -6) then
    Result := 255
  else if (Song.PreferredEngine = 'P1S') and (Result < -6) then
    Result := 255
  else if (Song.PreferredEngine = 'SVG') and (Result < -6) then
    Result := 255
  else if (Song.PreferredEngine = 'TMB') and (Result < 0) then
    Result := 255
  else if (Song.PreferredEngine = 'MSD') and (Result < 0) then
    Result := 255
  else if (Song.PreferredEngine = 'SFX') and (Result < 0) then
    Result := 255;

  if Song.PreferredEngine = 'TMB' then
    if (Result > $34) then Result := 255;
  if Song.PreferredEngine = 'SFX' then
    if (Result > $33) then Result := 255;
  if Song.PreferredEngine = 'MSD' then
    if (Result > $24) then Result := 255;

  if (Result < 0) then Inc(Result,107);

end;

procedure TSTMainWnd.imgCh1NoteMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  p.X := X;  p.Y := Y;
  p := (Sender as TImage).ClientToScreen(p);
  p := imgPianoKeys.ScreenToClient(p);
  imgPianoKeysMouseDown(imgPianoKeys,Button,Shift,p.X,p.Y);
end;

procedure TSTMainWnd.imgPianoKeysMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iNoteVal, iChan: integer;
begin
  if (Button <> mbLeft) or (bStopPlayer = false) then exit;
  
  if (grdPattern.Col = 1) or (grdPattern.Col = 3) or (grdPattern.Col = 6) then
  begin
    if (grdPattern.Col = 1) then iChan := 1 else iChan := 2;
    if (grdPattern.Col = 3) and (Song.PreferredEngine = 'SVG') then
    begin
      UpdatePatternGrid();
      grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      exit;
    end;

    iNoteVal := MousePosToNoteVal(X,Y);
    if iNoteVal < 255 then
    begin
      UndoPattern := Song.Pattern[udnPatternNum.Position];
      UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];
      Song.Pattern[udnPatternNum.Position].Chan[iChan][grdPattern.Row] := iNoteVal;
      //UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);

      SpecEmu.Register_SP := $7FF0; // stack pointer - 32752
      SpecEmu.Register_PC := $8000; //$8000; // program counter - 32768
      if (Song.PreferredEngine = 'P1D') or (Song.PreferredEngine = 'P1S') then
        SpecEmu.LoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                               Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                               255,GetPhaser1Instr(grdPattern.Row),Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],Song.Pattern[udnPatternNum.Position].Tempo,Song)
      else if Song.PreferredEngine = 'SVG' then
        SpecEmu.SavageLoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                                     Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                                     SVGGetGlissando(udnPatternNum.Position,1,grdPattern.Row),
                                     SVGGetGlissando(udnPatternNum.Position,2,grdPattern.Row),
                                     SVGGetSkew(udnPatternNum.Position,1,grdPattern.Row),
                                     SVGGetSkew(udnPatternNum.Position,2,grdPattern.Row),
                                     SVGGetSkewXOR(udnPatternNum.Position,1,grdPattern.Row),
                                     SVGGetSkewXOR(udnPatternNum.Position,2,grdPattern.Row),
                                     SVGGetArpeggio(udnPatternNum.Position,1,grdPattern.Row),
                                     SVGGetArpeggio(udnPatternNum.Position,2,grdPattern.Row),
                                     Song.SvgPatternData[udnPatternNum.Position].Warp[1][grdPattern.Row],
                                     Song.SvgPatternData[udnPatternNum.Position].Warp[2][grdPattern.Row],
                                     Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],
                                     Song.Pattern[udnPatternNum.Position].Tempo,
                                     Song)
      else
        SpecEmu.LoadPlayerNote(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],
                               Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row],
                               2,2,Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row],Song.Pattern[udnPatternNum.Position].Tempo,Song);
      SpecEmu.OnNewPattern := NotePlayerNewPattern;
      SpecEmu.OnPatternTick := nil;

      iPatternPlayer := 0; // inc'd to 0 on first OnNewPattern event
      bStopPlayer := false;
      while bStopPlayer = false do
        SpecEmu.Exec(false);
      SpecEmu.ResetWaveBuffers;

      bSongDirty := true;
    end
    else
      exit;
  end;

  UpdatePatternGrid();
  grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
end;

procedure TSTMainWnd.DrawSongLoopStart();
var
  r: TRect;
  tri: array[1..4] of TPoint;
begin
  pbxLoopStart.Canvas.Brush.Color := $00404040;
  pbxLoopStart.Canvas.Pen.Color := $000B9CFF;
  r.Top := 0; r.Left := 0; r.Right := pbxLoopStart.Width; r.Bottom := pbxLoopStart.Height;
  pbxLoopStart.Canvas.FillRect(r);  // Erase current loop starter graphic

  if (Song.LoopStart >= grdSong.LeftCol) and  (Song.LoopStart <= grdSong.VisibleColCount + grdSong.LeftCol) then
  begin
    r := grdSong.CellRect(Song.LoopStart,0);
    r.Left := r.Left + 2;
    pbxLoopStart.Canvas.MoveTo(r.Left,2);
    pbxLoopStart.Canvas.LineTo(r.Left,20);
    pbxLoopStart.Canvas.Brush.Color := $000B9CFF;
    r.Right := r.Left + 18; r.Top := 2; r.Bottom := 8;
    pbxLoopStart.Canvas.FillRect(r);
    tri[1].X := r.Right; tri[1].Y := 2;
    tri[2].X := r.Right+3; tri[2].Y := 4;
    tri[3].X := r.Right+3; tri[3].Y := 5;
    tri[4].X := r.Right; tri[4].Y := 7;
    pbxLoopStart.Canvas.Polygon(tri);
    pbxLoopStart.Canvas.Pen.Color := clBlack;
    // L
    pbxLoopStart.Canvas.MoveTo(r.Left + 2,3); pbxLoopStart.Canvas.LineTo(r.Left + 2,6);
    pbxLoopStart.Canvas.LineTo(r.Left + 5,6);
    // O
    pbxLoopStart.Canvas.Rectangle(r.Left + 6,3,r.Left + 9,7);
    // O
    pbxLoopStart.Canvas.Rectangle(r.Left + 10,3,r.Left + 13,7);
    // P
    pbxLoopStart.Canvas.Rectangle(r.Left + 14,3,r.Left + 17,6);
    pbxLoopStart.Canvas.MoveTo(r.Left + 14,3);
    pbxLoopStart.Canvas.LineTo(r.Left + 14,7);
  end;

  pbxLoopStart.Canvas.Refresh;
end;

procedure TSTMainWnd.grdPatternDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if (ACol = 0) or (ARow = 0) then
  begin
    grdPattern.Canvas.Font.Color := clBlack;
    grdPattern.Canvas.TextRect(Rect,Rect.Left+2,Rect.Top+2,grdPattern.Cells[ACol,ARow]);
  end
  else if (cboAutoInc.ItemIndex > 1) and ((ARow mod cboAutoInc.ItemIndex) = 1) then
  begin
    grdPattern.Canvas.Brush.Color := clBlack;
    grdPattern.Canvas.FillRect(Rect);
    grdPattern.Canvas.Font.Color := grdPattern.Font.Color;
    grdPattern.Canvas.TextRect(Rect,Rect.Left+2,Rect.Top+2,grdPattern.Cells[ACol,ARow]);
  end;
  
end;

procedure TSTMainWnd.SavagePatternKeyDown(var Key: Word; Shift: TShiftState);
var
  i: integer;
  iChan: integer;
begin
  if Key = VK_TAB then
  begin
    grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
    Key := 0;
  end
  else if Key = VK_DELETE then
  begin
    UndoPattern := Song.Pattern[udnPatternNum.Position];
    UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

    if (grdPattern.Col = 1) or (grdPattern.Col = 7) then
    begin
      if grdPattern.Col = 1 then iChan := 1 else iChan := 2;

      Song.Pattern[udnPatternNum.Position].Chan[iChan][grdPattern.Row] := 255;
      if (ssShift in Shift) then
      begin
        for i := grdPattern.Row to 255 do
          Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
        Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
      end
      else if (ssCtrl in Shift) then
      begin
        for i := grdPattern.Row to 255 do
        begin
          Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i + 1];
        end;
        Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][256] := 0;
      end
      else
        grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
    end;
    if (grdPattern.Col = 13) then
    begin
      // Delete drum
      Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := 0; // No drum
      if (ssShift in Shift) or (ssCtrl in Shift) then
      begin
        for i := grdPattern.Row to 255 do
          Song.Pattern[udnPatternNum.Position].Drum[i] := Song.Pattern[udnPatternNum.Position].Drum[i + 1];
        Song.Pattern[udnPatternNum.Position].Drum[256] := 0;
      end
      else
        grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
    end;
    if ((grdPattern.Col >= 2) and (grdPattern.Col <= 6)) or
       ((grdPattern.Col >= 8) and (grdPattern.Col <= 12)) then
    begin
      if ((grdPattern.Col >= 2) and (grdPattern.Col <= 6)) then iChan := 1 else iChan := 2;

      if (grdPattern.Col = 2) or (grdPattern.Col = 8) then
      begin
        // Delete Glissando
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][grdPattern.Row] := 256; // No glissando
        if (ssShift in Shift) then
        begin
          for i := grdPattern.Row to 255 do
            Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][256] := 256;
        end
      else if (ssCtrl in Shift) then
      begin
        for i := grdPattern.Row to 255 do
        begin
          Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i + 1];
        end;
        Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][256] := 0;
      end
        else
          grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      end;

      if (grdPattern.Col = 3) or (grdPattern.Col = 9) then
      begin
        // Delete Skew
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][grdPattern.Row] := 256; // No glissando
        if (ssShift in Shift) then
        begin
          for i := grdPattern.Row to 255 do
            Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][256] := 256;
        end
      else if (ssCtrl in Shift) then
      begin
        for i := grdPattern.Row to 255 do
        begin
          Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i + 1];
        end;
        Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][256] := 0;
      end
        else
          grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      end;

      if (grdPattern.Col = 4) or (grdPattern.Col = 10) then
      begin
        // Delete SkewXOR
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][grdPattern.Row] := 256; // No glissando
        if (ssShift in Shift) then
        begin
          for i := grdPattern.Row to 255 do
            Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][256] := 256;
        end
      else if (ssCtrl in Shift) then
      begin
        for i := grdPattern.Row to 255 do
        begin
          Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i + 1];
        end;
        Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][256] := 0;
      end
        else
          grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      end;

      if (grdPattern.Col = 5) or (grdPattern.Col = 11) then
      begin
        // Delete Arpeggio
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][grdPattern.Row] := 256; // No glissando
        if (ssShift in Shift) then
        begin
          for i := grdPattern.Row to 255 do
            Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][256] := 256;
        end
      else if (ssCtrl in Shift) then
      begin
        for i := grdPattern.Row to 255 do
        begin
          Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i + 1];
        end;
        Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][256] := 0;
      end
        else
          grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      end;

      if (grdPattern.Col = 6) or (grdPattern.Col = 12) then
      begin
        // Delete Phase
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][grdPattern.Row] := 0; // No phase
        if (ssShift in Shift) then
        begin
          for i := grdPattern.Row to 255 do
            Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][256] := 0;
        end
      else if (ssCtrl in Shift) then
      begin
        for i := grdPattern.Row to 255 do
        begin
          Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i + 1];
          Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i + 1];
        end;
        Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][256] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][256] := 0;
      end
        else
          grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      end;

    end;

    UpdatePatternGrid();
    UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
  end
  else if Key = VK_UP then
  begin
    if grdPattern.Row = 1 then
    begin
      grdPattern.Row := grdPattern.RowCount - 1;
      UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
      Key := 0;
    end
    else
      UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row-1],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row-1]);
    Refresh;
  end
  else if Key = VK_DOWN then
  begin
    if grdPattern.Row = grdPattern.RowCount - 1 then
    begin
      grdPattern.Row := 1;
      UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
      Key := 0;
    end
    else
      UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row+1],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row+1]);
    Refresh;
  end
  else if Key = VK_INSERT then
  begin
    UndoPattern := Song.Pattern[udnPatternNum.Position];
    UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

    if (grdPattern.Col >= 1) and (grdPattern.Col <= 6) then
    begin
      for i := 255 downto grdPattern.Row do
      begin
        if (grdPattern.Col = 1) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Chan[1][i+1] := Song.Pattern[udnPatternNum.Position].Chan[1][i];
        if (grdPattern.Col = 2) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Glissando[1][i+1] := Song.SvgPatternData[udnPatternNum.Position].Glissando[1][i];
        if (grdPattern.Col = 3) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Skew[1][i+1] := Song.SvgPatternData[udnPatternNum.Position].Skew[1][i];
        if (grdPattern.Col = 4) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].SkewXOR[1][i+1] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[1][i];
        if (grdPattern.Col = 5) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1][i+1] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1][i];
        if (grdPattern.Col = 6) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Warp[1][i+1] := Song.SvgPatternData[udnPatternNum.Position].Warp[1][i];
      end;
      if (grdPattern.Col = 1) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row] := 255;
      if (grdPattern.Col = 2) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Glissando[1][grdPattern.Row] := 256;
      if (grdPattern.Col = 3) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Skew[1][grdPattern.Row] := 256;
      if (grdPattern.Col = 4) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].SkewXOR[1][grdPattern.Row] := 256;
      if (grdPattern.Col = 5) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1][grdPattern.Row] := 256;
      if (grdPattern.Col = 6) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Warp[1][grdPattern.Row] := 0;
    end
    else if (grdPattern.Col >= 7) and (grdPattern.Col <= 12) then
    begin
      for i := 255 downto grdPattern.Row do
      begin
        if (grdPattern.Col = 7) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Chan[2][i+1] := Song.Pattern[udnPatternNum.Position].Chan[2][i];
        if (grdPattern.Col = 8) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Glissando[2][i+1] := Song.SvgPatternData[udnPatternNum.Position].Glissando[2][i];
        if (grdPattern.Col = 9) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Skew[2][i+1] := Song.SvgPatternData[udnPatternNum.Position].Skew[2][i];
        if (grdPattern.Col = 10) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].SkewXOR[2][i+1] := Song.SvgPatternData[udnPatternNum.Position].SkewXOR[2][i];
        if (grdPattern.Col = 11) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2][i+1] := Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2][i];
        if (grdPattern.Col = 12) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Warp[2][i+1] := Song.SvgPatternData[udnPatternNum.Position].Warp[2][i];
      end;
      if (grdPattern.Col = 7) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row] := 255;
      if (grdPattern.Col = 8) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Glissando[2][grdPattern.Row] := 256;
      if (grdPattern.Col = 9) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Skew[2][grdPattern.Row] := 256;
      if (grdPattern.Col = 10) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].SkewXOR[2][grdPattern.Row] := 256;
      if (grdPattern.Col = 11) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2][grdPattern.Row] := 256;
      if (grdPattern.Col = 12) or (not(ssShift in Shift)) then Song.SvgPatternData[udnPatternNum.Position].Warp[2][grdPattern.Row] := 0;
    end
    else if (grdPattern.Col = 13) then
    begin
      // Insert Drum
      for i := 255 downto grdPattern.Row do
      begin
        Song.Pattern[udnPatternNum.Position].Drum[i+1] := Song.Pattern[udnPatternNum.Position].Drum[i];
      end;
      Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := 0;
    end;
    UpdatePatternGrid();
    UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
  end;
end;

procedure TSTMainWnd.grdPatternKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: integer;
  iChan: integer;
begin
  if not bStopPlayer  then exit;

  if Song.PreferredEngine = 'SVG' then
    SavagePatternKeyDown(Key,Shift)
  else
  begin
    if Key = VK_TAB then
    begin
      grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      Key := 0;
    end
    else if Key = VK_DELETE then
    begin
      UndoPattern := Song.Pattern[udnPatternNum.Position];
      UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

      if (grdPattern.Col = 1) or (grdPattern.Col = 3) then
      begin
        if grdPattern.Col = 1 then iChan := 1 else iChan := 2;

        Song.Pattern[udnPatternNum.Position].Chan[iChan][grdPattern.Row] := 255;
        if (ssShift in Shift) then
        begin
          for i := grdPattern.Row to 255 do
            Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
          Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
        end
        else if (ssCtrl in Shift) then
        begin
          for i := grdPattern.Row to 255 do
          begin
            Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
            Song.Pattern[udnPatternNum.Position].Sustain[iChan][i] := Song.Pattern[udnPatternNum.Position].Sustain[iChan][i + 1];
          end;
          Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
          Song.Pattern[udnPatternNum.Position].Sustain[iChan][256] := 255;
        end
        else
          grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      end;
      if (grdPattern.Col = 5) then
      begin
        // Delete drum
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := 0; // No drum
        if (ssShift in Shift) or (ssCtrl in Shift) then
        begin
          for i := grdPattern.Row to 255 do
            Song.Pattern[udnPatternNum.Position].Drum[i] := Song.Pattern[udnPatternNum.Position].Drum[i + 1];
          Song.Pattern[udnPatternNum.Position].Drum[256] := 0;
        end
        else
          grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      end;
      if (grdPattern.Col = 2) or (grdPattern.Col = 4) then
      begin
        if grdPattern.Col = 2 then iChan := 1 else iChan := 2;
        // Delete sustain message
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][grdPattern.Row] := 255; // No sustain msg
        if (ssShift in Shift) then
        begin
          for i := grdPattern.Row to 255 do
            Song.Pattern[udnPatternNum.Position].Sustain[iChan][i] := Song.Pattern[udnPatternNum.Position].Sustain[iChan][i + 1];
          Song.Pattern[udnPatternNum.Position].Sustain[iChan][256] := 255;
        end
        else if (ssCtrl in Shift) then
        begin
          for i := grdPattern.Row to 255 do
          begin
            Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := Song.Pattern[udnPatternNum.Position].Chan[iChan][i + 1];
            Song.Pattern[udnPatternNum.Position].Sustain[iChan][i] := Song.Pattern[udnPatternNum.Position].Sustain[iChan][i + 1];
          end;
          Song.Pattern[udnPatternNum.Position].Chan[iChan][256] := 255;
          Song.Pattern[udnPatternNum.Position].Sustain[iChan][256] := 255;          
        end        
        else
          grdPattern.Row := ((grdPattern.Row-1 + cboAutoInc.ItemIndex) mod udnPatternLen.Position)+1;
      end;
      {if (Shift = []) then
      begin
        if grdPattern.Row = grdPattern.RowCount -1 then
          grdPattern.Row := 1
        else
          grdPattern.Row := grdPattern.Row + 1;
      end;}
      UpdatePatternGrid();
      UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
    end
    else if Key = VK_UP then
    begin
      if grdPattern.Row = 1 then
      begin
        grdPattern.Row := grdPattern.RowCount - 1;
        UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
        Key := 0;
      end
      else
        UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row-1],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row-1]);
      Refresh;
    end
    else if Key = VK_DOWN then
    begin
      if grdPattern.Row = grdPattern.RowCount - 1 then
      begin
        grdPattern.Row := 1;
        UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
        Key := 0;
      end
      else
        UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row+1],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row+1]);
      Refresh;
    end
    else if Key = VK_INSERT then
    begin
      UndoPattern := Song.Pattern[udnPatternNum.Position];
      UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

      if (grdPattern.Col = 1) or (grdPattern.Col = 2) then
      begin
        for i := 255 downto grdPattern.Row do
        begin
          if (grdPattern.Col = 1) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Chan[1][i+1] := Song.Pattern[udnPatternNum.Position].Chan[1][i];
          if (grdPattern.Col = 2) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Sustain[1][i+1] := Song.Pattern[udnPatternNum.Position].Sustain[1][i];
        end;
        if (grdPattern.Col = 1) or not(ssShift in Shift) then Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row] := 255;
        if (grdPattern.Col = 2) or not(ssShift in Shift) then Song.Pattern[udnPatternNum.Position].Sustain[1][grdPattern.Row] := 255;
      end
      else if (grdPattern.Col = 3) or (grdPattern.Col = 4) then
      begin
        for i := 255 downto grdPattern.Row do
        begin
          if (grdPattern.Col = 3) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Chan[2][i+1] := Song.Pattern[udnPatternNum.Position].Chan[2][i];
          if (grdPattern.Col = 4) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Sustain[2][i+1] := Song.Pattern[udnPatternNum.Position].Sustain[2][i];
        end;
        if (grdPattern.Col = 3) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row] := 255;
        if (grdPattern.Col = 4) or (not(ssShift in Shift)) then Song.Pattern[udnPatternNum.Position].Sustain[2][grdPattern.Row] := 255;
      end
      else if (grdPattern.Col = 5) then
      begin
        for i := 255 downto grdPattern.Row do
        begin
          Song.Pattern[udnPatternNum.Position].Drum[i+1] := Song.Pattern[udnPatternNum.Position].Drum[i];
        end;
        Song.Pattern[udnPatternNum.Position].Drum[grdPattern.Row] := 0;
      end;
      UpdatePatternGrid();
      UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
    end;
  end;
end;

procedure TSTMainWnd.mnuAboutClick(Sender: TObject);
begin
  StopPlayer();

  AboutDlg.ShowModal;
end;

procedure TSTMainWnd.mnuCompileClick(Sender: TObject);
begin
  StopPlayer();

  if Song.PreferredEngine = 'SFX' then
    CompileDlg.cboEngine.ItemIndex := 0
  else if Song.PreferredEngine = 'TMB' then
    CompileDlg.cboEngine.ItemIndex := 1
  else if Song.PreferredEngine = 'MSD' then
    CompileDlg.cboEngine.ItemIndex := 2
  else if Song.PreferredEngine = 'P1D' then
    CompileDlg.cboEngine.ItemIndex := 3
  else if Song.PreferredEngine = 'P1S' then
    CompileDlg.cboEngine.ItemIndex := 4
  else if Song.PreferredEngine = 'SVG' then
    CompileDlg.cboEngine.ItemIndex := 5
  else
    CompileDlg.cboEngine.ItemIndex := 0;

  CompileDlg.ShowModal;
end;

procedure TSTMainWnd.mnuEditCopyClick(Sender: TObject);
begin
  if grdPattern.Focused then
  begin
    CopyPattern := Song.Pattern[udnPatternNum.Position];
    CopySVGPattern := Song.SvgPatternData[udnPatternNum.Position];
  end
  else if Screen.ActiveControl is TEdit then
    (Screen.ActiveControl as TEdit).CopyToClipboard;
end;

procedure TSTMainWnd.mnuEditPasteClick(Sender: TObject);
begin
  if grdPattern.Focused then
  begin
    UndoPattern := Song.Pattern[udnPatternNum.Position];
    UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];
    
    Song.Pattern[udnPatternNum.Position] := CopyPattern;
    Song.SvgPatternData[udnPatternNum.Position] := CopySvgPattern;
    UpdatePatternGrid();
  end
  else if Screen.ActiveControl is TEdit then
    (Screen.ActiveControl as TEdit).PasteFromClipboard;
end;

procedure TSTMainWnd.mnuEditUndoClick(Sender: TObject);
var
  TempPattern: STPatterns.TPattern;
  TempSVG: STPatterns.TPatternSVG;
begin
  if not grdPattern.Focused then exit;

  TempPattern := Song.Pattern[udnPatternNum.Position];
  TempSVG := Song.SvgPatternData[udnPatternNum.Position];
  Song.Pattern[udnPatternNum.Position] := UndoPattern;
  Song.SvgPatternData[udnPatternNum.Position] := UndoSvgPattern;
  UndoPattern := TempPattern;
  UndoSvgPattern := TempSVG;
  UpdatePatternGrid();
end;

procedure TSTMainWnd.mnuExitClick(Sender: TObject);
begin
  StopPlayer();
  
  Close();
end;

procedure TSTMainWnd.mnuExportWAVFileClick(Sender: TObject);
begin
  ExportWavDlg.ShowModal;
end;

procedure TSTMainWnd.mnuFileNewClick(Sender: TObject);
var
  iRet: integer;
begin
  StopPlayer();
  
  if bSongDirty then
  begin
    iRet :=  Application.MessageBox('Do you want to save changes to the current song?',
                            PAnsiChar(Application.Title),
                            MB_YESNOCANCEL or MB_DEFBUTTON3 or MB_ICONQUESTION);
    if iRet = ID_YES then
    begin
      if sFileName <> '' then
        mnuFileSaveClick(nil)
      else
        mnuFileSaveAsClick(nil);

      if not bSongDirty then
      begin
        Song.Clear();
        sFileName := '';
      end;
    end
    else if iRet = ID_NO then
    begin
      Song.Clear();
      sFileName := '';
    end
    else if iRet = ID_CANCEL then exit;
  end
  else
  begin
    Song.Clear();
    sFileName := '';
  end;

  Self.Caption := 'Untitled - ' + Application.Title;
  udnPatternNum.Position := 0;
  mnuTGSpecialFXClick(nil);
  UpdateSongGrid();
  UpdatePatternGrid();
  UndoPattern := Song.Pattern[0];
  UndoSvgPattern := Song.SvgPatternData[0];
  DrawSongLoopStart();
  grdPattern.SetFocus();
  bSongDirty := false;
  cboAutoInc.ItemIndex := 1;
end;

procedure TSTMainWnd.mnuFileOpenClick(Sender: TObject);
var
  iRet: integer;
begin
  StopPlayer();

  if bSongDirty then
  begin
    iRet :=  Application.MessageBox('Do you want to save changes to the current song?',
                            PAnsiChar(Application.Title),
                            MB_YESNOCANCEL or MB_DEFBUTTON3 or MB_ICONQUESTION);
    if iRet = ID_YES then
    begin
      if sFileName <> '' then
        mnuFileSaveClick(nil)
      else
        mnuFileSaveAsClick(nil);

      if bSongDirty then exit; // Failed to save file or Save Cancelled
    end
    else if iRet = ID_CANCEL then exit;
  end;

  dlgOpen.DefaultExt := 'bbsong';
  if dlgOpen.Execute and FileExists(dlgOpen.FileName) then
  begin
    if Song.LoadFile(dlgOpen.FileName) then
    begin
      sFileName := dlgOpen.FileName;
      Self.Caption := ExtractBBSongFileName(sFileName) + ' - ' + Application.Title;
      udnPatternNum.Position := 0;
      UpdateSongGrid();
      UpdatePatternGrid();
      DrawSongLoopStart();
      UndoPattern := Song.Pattern[0];
      if Song.PreferredEngine = 'TMB' then
      begin
        mnuTGTheMusicBoxClick(nil);
      end
      else if Song.PreferredEngine = 'MSD' then
      begin
        mnuTGMusicStudioClick(nil);
      end
      else if Song.PreferredEngine = 'P1D' then
      begin
        mnuTGPhaser1DigitalClick(nil);
      end
      else if Song.PreferredEngine = 'P1S' then
      begin
        mnuTGPhaser1SynthClick(nil);
      end
      else if Song.PreferredEngine = 'SVG' then
      begin
        mnuTGSavageClick(nil);
      end
      else
      begin
        mnuTGSpecialFXClick(nil);
      end;

      grdPattern.SetFocus();
      bSongDirty := false;
      cboAutoInc.ItemIndex := 1;
      MRUList.AddFile(sFileName);
      UpdateMRUMenu();
    end;
  end;
end;

procedure TSTMainWnd.mnuFileSaveAsClick(Sender: TObject);
begin
  StopPlayer();
  
  dlgSave.FileName := sFileName;
  dlgSave.DefaultExt := 'bbsong';
  if dlgSave.Execute then
  begin
    // Write SongObject
    if Song.SaveFile(dlgSave.FileName) then
    begin
      sFileName := dlgSave.FileName;
      Self.Caption := ExtractBBSongFileName(sFileName) + ' - ' + Application.Title;
      bSongDirty := false;
      MRUList.AddFile(sFileName);
      UpdateMRUMenu();
    end;
  end;
end;

procedure TSTMainWnd.mnuFileSaveClick(Sender: TObject);
begin
  StopPlayer();
  
  if sFileName = '' then
    mnuFileSaveAsClick(nil)
  else
  begin
    // Write SongObject
    if Song.SaveFile(sFileName) then
    begin
      Self.Caption := ExtractBBSongFileName(sFileName) + ' - ' + Application.Title;
      bSongDirty := false;
    end;
  end;
end;

procedure TSTMainWnd.mnuHelpKeysClick(Sender: TObject);
var
  pnt: TPoint;
begin
  if pnlPhaser1Ed.Visible then
    pnt.Y := pnlPhaser1Ed.Top + pnlPhaser1Ed.Height + 10
  else if pnlSavageOrnEditor.Visible then
    pnt.Y := pnlSavageOrnEditor.Top + pnlSavageOrnEditor.Height + 10
  else
    pnt.Y := pnlKeys.Top + pnlKeys.Height + 10;
  pnt.X := pnlKeys.Left;

  pnt := Self.ClientToScreen(pnt);
  KeyboardLayoutWnd.Top := pnt.Y + GetSystemMetrics(SM_CYFRAME);
  KeyboardLayoutWnd.Left := pnt.X + GetSystemMetrics(SM_CXFRAME);
  
  KeyboardLayoutWnd.Show;
end;

procedure TSTMainWnd.mnuHelpOnlineClick(Sender: TObject);
begin
  ShellExecute(0,'open','iexplore.exe',PChar('http://freestuff.grok.co.uk/beepola/help/'),nil,SW_SHOWNORMAL);
end;

procedure TSTMainWnd.mnuImportRipperClick(Sender: TObject);
begin
  StopPlayer();

  if SongRipperDlg.ShowModal = mrOK then
  begin
    sFileName := '';
    Self.Caption := 'Untitled - ' + Application.Title;
    udnPatternNum.Position := 0;
    UpdateSongGrid();
    UpdatePatternGrid();
    DrawSongLoopStart();
    UndoPattern := Song.Pattern[0];
    bSongDirty := true;
    cboAutoInc.ItemIndex := 1;
    grdPattern.SetFocus();
  end;
end;

procedure TSTMainWnd.mnuImportVTIITextClick(Sender: TObject);
var
  iRet: integer;

  function IsValidVTIITextFile(sFileName: string): boolean;
  var
    INI: TIniFile;
  begin
    Result := false;

    try
      INI := TINIFile.Create(sFileName);
      if INI.ReadInteger('Module','VortexTrackerII',-1) = -1 then exit;
      Result := true;      
    finally
      FreeAndNil(INI);
    end;
  end;
begin
  StopPlayer();

  if bSongDirty then
  begin
    iRet :=  Application.MessageBox('Do you want to save changes to the current song?',
                            PAnsiChar(Application.Title),
                            MB_YESNOCANCEL or MB_DEFBUTTON3 or MB_ICONQUESTION);
    if iRet = ID_YES then
    begin
      if sFileName <> '' then
        mnuFileSaveClick(nil)
      else
        mnuFileSaveAsClick(nil);

      if bSongDirty then exit; // Failed to save file or Save Cancelled
    end
    else if iRet = ID_CANCEL then exit;
  end;

  dlgImport.DefaultExt := 'txt';
  if dlgImport.Execute and FileExists(dlgImport.FileName) then
  begin
    if not IsValidVTIITextFile(dlgImport.FileName) then
    begin
      Application.MessageBox('This file does not appear to be a valid Vortex Tracker II Text Module',
                             PAnsiChar(Application.Title),MB_OK or MB_ICONEXCLAMATION);
      exit;
    end;
    ImportVTIIFileDlg.sFile := dlgImport.FileName;
    Song.Clear;
    if ImportVTIIFileDlg.ShowModal = mrOK then
    begin
      sFileName := '';
      Self.Caption := 'Untitled - ' + Application.Title;
      udnPatternNum.Position := 0;
      UpdateSongGrid();
      UpdatePatternGrid();
      DrawSongLoopStart();
      UndoPattern := Song.Pattern[0];
      mnuTGPhaser1DigitalClick(nil);
      grdPattern.SetFocus();
      bSongDirty := true;
      cboAutoInc.ItemIndex := 1;
    end;
  end;
end;

procedure TSTMainWnd.pbxLoopStartMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  col, row: integer;
begin
  bMovingLoop := true;
  grdSong.MouseToCell(X,Y,col,row);
  if (col < Song.SongLength) and (col >= 0) then
  begin
    bSongDirty := true;
    Song.LoopStart := col;
    DrawSongLoopStart;
  end;
end;

procedure TSTMainWnd.pbxLoopStartMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  col, row: integer;
begin
  grdSong.MouseToCell(X,Y,col,row);

  if bMovingLoop and (col >= 0) and (col < Song.SongLength) then
  begin
    bSongDirty := true;
    Song.LoopStart := col;
    StopPlayer();
    DrawSongLoopStart;
  end;
end;

procedure TSTMainWnd.pbxLoopStartMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  bMovingLoop := false;
end;

procedure TSTMainWnd.pbxLoopStartPaint(Sender: TObject);
begin
  DrawSongLoopStart();
end;

procedure TSTMainWnd.pbxOrnLoopMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  col, row: integer;
begin
  bMovingLoop := true;
  grdSVGOrnEdit.MouseToCell(X,Y,col,row);
  if (col < Song.SVGArpeggio[udnSvgOrnament.Position].Length) and (col >= 0) then
  begin
    bSongDirty := true;
    Song.LoopStart := col;
    DrawSongLoopStart;
  end;
end;

procedure TSTMainWnd.NotePlayerNewPattern();
begin
  iPatternTickCount := 0;
  UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
  Refresh;
  inc(iPatternPlayer);
  if iPatternPlayer > 1 then
    StopPlayer();
end;

procedure TSTMainWnd.PatternPlayerNewPattern();
begin
  inc(iPatternPlayer);
  if iPatternPlayer > 1 then
    StopPlayer();

  iPatternTickCount := 0;
  iPlayerRow := 1;
  grdPattern.Row := iPlayerRow;
  UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
  Refresh;
end;

procedure TSTMainWnd.PatternTick();
begin
  inc(iPatternTickCount);
  if ((iPatternTickCount mod (21 - Song.Pattern[udnPatternNum.Position].Tempo)) = 0) and
    (grdPattern.Row < grdPattern.RowCount-1) then
  begin
    iPlayerRow := grdPattern.Row + 1;
    grdPattern.Row := iPlayerRow;
    UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
    Refresh;
  end;
end;

procedure TSTMainWnd.TMBPatternTick();
begin
  inc(iPatternTickCount);
  if (iPatternTickCount > 0) and (iPatternTickCount < grdPattern.RowCount-1) then
  begin
    iPlayerRow := grdPattern.Row + 1;
    grdPattern.Row := iPlayerRow;
    UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
  end;
  Refresh;
end;

procedure TSTMainWnd.Phaser1PatternTick();
var
  iTicksPerNote: integer;
begin
  iTicksPerNote := 17 - Song.Pattern[udnPatternNum.Position].Tempo;
  if iTicksPerNote < 1 then iTicksPerNote := 1;

  inc(iPatternTickCount);
  if ((iPatternTickCount mod iTicksPerNote) = 0) and
    (grdPattern.Row < grdPattern.RowCount-1) then
  begin
    iPlayerRow := grdPattern.Row + 1;
    grdPattern.Row := iPlayerRow;
    UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
    Refresh;
  end;
end;

procedure TSTMainWnd.sbnNewClick(Sender: TObject);
begin
  mnuFileNewClick(nil);
end;

procedure TSTMainWnd.sbnOpenClick(Sender: TObject);
begin
  mnuFileOpenClick(nil);
end;

procedure TSTMainWnd.sbnPlayClick(Sender: TObject);
begin
  mnuPlaySongClick(nil);
end;

procedure TSTMainWnd.sbnSaveClick(Sender: TObject);
begin
  mnuFileSaveClick(nil);
end;

procedure TSTMainWnd.SongPlayerNewPattern();
begin
  iPatternTickCount := 0;
  iPlayerRow := 1;
  grdPattern.Row := iPlayerRow;
  inc(iPatternPlayer);
  if iPatternPlayer >= Song.SongLength then
    iPatternPlayer := Song.LoopStart;

  grdSong.Col := iPatternPlayer;
  UpdatePianoKeys(Song.Pattern[udnPatternNum.Position].Chan[1][grdPattern.Row],Song.Pattern[udnPatternNum.Position].Chan[2][grdPattern.Row]);
  Refresh;
end;

procedure TSTMainWnd.mnuPatternAppendClick(Sender: TObject);
begin
  StopPlayer();

  PatternAppendDlg.udnPatternNum.Position := udnPatternNum.Position;
  PatternAppendDlg.udnPattern2Num.Position := udnPatternNum.Position;
  if PatternAppendDlg.ShowModal = mrOK then
  begin
    UpdatePatternGrid();
    bSongDirty := true;
  end;
end;

procedure TSTMainWnd.mnuPatternCopyClick(Sender: TObject);
var
  i: integer;
begin
  StopPlayer();

  CopyPatternDlg.udnSource.Position := udnPatternNum.Position;
  CopyPatternDlg.udnDest.Position := CopyPatternDlg.udnDest.Position + 1;

  for i := 0 to 126 do
  begin
    if Song.IsPatternEmpty(i) and (i <> CopyPatternDlg.udnSource.Position) then
    begin
      CopyPatternDlg.udnDest.Position := i;
      break;
    end;
  end;

  if CopyPatternDlg.ShowModal = mrOK then
    bSongDirty := true;
end;

procedure TSTMainWnd.mnuPatternExpandClick(Sender: TObject);
var
  i: Integer;
  iChan: Integer;
begin
  if Song.Pattern[udnPatternNum.Position].Length > 63 then
  begin
    if Application.MessageBox('Expanding this pattern would cause it to exceed the maximum pattern length of 126 rows.'#13#10#13#10'Continue anyway?',
                           PAnsiChar(Application.Title),
                           MB_ICONQUESTION or MB_OKCANCEL) = ID_CANCEL then
      exit;
  end;

  UndoPattern := Song.Pattern[udnPatternNum.Position];
  UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];
  
  if Song.Pattern[udnPatternNum.Position].Length > 63 then
    Song.Pattern[udnPatternNum.Position].Length := 126
  else
    Song.Pattern[udnPatternNum.Position].Length := Song.Pattern[udnPatternNum.Position].Length * 2;

  for i := 1 to Song.Pattern[udnPatternNum.Position].Length do
  begin
    if i mod 2 = 1 then
    begin
      for iChan := 1 to 2 do
      begin
        Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := UndoPattern.Chan[iChan][(i-1) div 2 + 1];
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][i] := UndoPattern.Sustain[iChan][(i-1) div 2 + 1];
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := UndoSvgPattern.Glissando[iChan][(i-1) div 2 + 1];
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := UndoSvgPattern.Skew[iChan][(i-1) div 2 + 1];
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := UndoSvgPattern.SkewXOR[iChan][(i-1) div 2 + 1];
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := UndoSvgPattern.Arpeggio[iChan][(i-1) div 2 + 1];
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := UndoSvgPattern.Warp[iChan][(i-1) div 2 + 1];
      end;
      Song.Pattern[udnPatternNum.Position].Drum[i] := UndoPattern.Drum[(i-1) div 2 + 1];
    end
    else
    begin
      for iChan := 1 to 2 do
      begin
        Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := 255;
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][i] := 255;
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := 256;
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := 0;
      end;
      Song.Pattern[udnPatternNum.Position].Drum[i] := 0;
    end;
  end;

  UpdatePatternGrid();
end;

procedure TSTMainWnd.mnuPatternExpandX3Click(Sender: TObject);
var
  i: Integer;
  iChan: Integer;
begin
  if Song.Pattern[udnPatternNum.Position].Length > 42 then
  begin
    if Application.MessageBox('Expanding this pattern x3 would cause it to exceed the maximum pattern length of 126 rows.'#13#10#13#10'Continue anyway?',
                           PAnsiChar(Application.Title),
                           MB_ICONQUESTION or MB_OKCANCEL) = ID_CANCEL then
      exit;
  end;

  UndoPattern := Song.Pattern[udnPatternNum.Position];
  UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];
  
  if Song.Pattern[udnPatternNum.Position].Length > 42 then
    Song.Pattern[udnPatternNum.Position].Length := 126
  else
    Song.Pattern[udnPatternNum.Position].Length := Song.Pattern[udnPatternNum.Position].Length * 3;

  for i := 1 to Song.Pattern[udnPatternNum.Position].Length do
  begin
    if i mod 3 = 1 then
    begin
      for iChan := 1 to 2 do
      begin
        Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := UndoPattern.Chan[iChan][(i-1) div 3 + 1];
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][i] := UndoPattern.Sustain[iChan][(i-1) div 3 + 1];
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := UndoSvgPattern.Glissando[iChan][(i-1) div 3 + 1];
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := UndoSvgPattern.Skew[iChan][(i-1) div 3 + 1];
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := UndoSvgPattern.SkewXOR[iChan][(i-1) div 3 + 1];
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := UndoSvgPattern.Arpeggio[iChan][(i-1) div 3 + 1];
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := UndoSvgPattern.Warp[iChan][(i-1) div 3 + 1];
      end;
      Song.Pattern[udnPatternNum.Position].Drum[i] := UndoPattern.Drum[(i-1) div 3 + 1];
    end
    else
    begin
      for iChan := 1 to 2 do
      begin
        Song.Pattern[udnPatternNum.Position].Chan[iChan][i] := 255;
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][i] := 255;
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i] := 256;
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i] := 256;
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i] := 0;
      end;
      Song.Pattern[udnPatternNum.Position].Drum[i] := 0;
    end;
  end;

  UpdatePatternGrid();
end;

function TSTMainWnd.EvenRowNotes(iPat: integer): boolean;
var
  i: Integer;
begin
  Result := false;

  for i := 1 to Song.Pattern[iPat].Length do
  begin
    if (i mod 2) = 0 then
    begin
      if (Song.Pattern[iPat].Chan[1][i] <> 255) or
         (Song.Pattern[iPat].Chan[2][i] <> 255) then
      begin
        Result := true;
        exit;
      end;
    end;
  end;
end;

function TSTMainWnd.TripleShrinkRowNotes(iPat: integer): boolean;
var
  i: Integer;
begin
  Result := false;

  for i := 1 to Song.Pattern[iPat].Length do
  begin
    if (i mod 3) <> 1 then
    begin
      if (Song.Pattern[iPat].Chan[1][i] <> 255) or
         (Song.Pattern[iPat].Chan[2][i] <> 255) then
      begin
        Result := true;
        exit;
      end;
    end;
  end;
end;

procedure TSTMainWnd.mnuPatternShrinkClick(Sender: TObject);
var
  i: Integer;
  iChan: Integer;
begin
  if Song.Pattern[udnPatternNum.Position].Length < 2 then exit;

  if EvenRowNotes(udnPatternNum.Position) then
  begin
    if Application.MessageBox('Shrinking this pattern would cause notes to be lost.'#13#10#13#10'Continue anyway?',
                           PAnsiChar(Application.Title),
                           MB_ICONQUESTION or MB_OKCANCEL) = ID_CANCEL then
      exit;
  end;

  UndoPattern := Song.Pattern[udnPatternNum.Position];
  UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

  Song.Pattern[udnPatternNum.Position].Length := Song.Pattern[udnPatternNum.Position].Length div 2;
  for i := 1 to UndoPattern.Length do
  begin
    if (i mod 2) = 1 then
    begin
      for iChan := 1 to 2 do
      begin
        Song.Pattern[udnPatternNum.Position].Chan[iChan][i div 2 + 1] := UndoPattern.Chan[iChan][i];
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][i div 2 + 1] := UndoPattern.Sustain[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i div 2 + 1] := UndoSvgPattern.Glissando[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i div 2 + 1] := UndoSvgPattern.Skew[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i div 2 + 1] := UndoSvgPattern.SkewXOR[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i div 2 + 1] := UndoSvgPattern.Arpeggio[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i div 2 + 1] := UndoSvgPattern.Warp[iChan][i];
      end;
      Song.Pattern[udnPatternNum.Position].Drum[i div 2 + 1] := UndoPattern.Drum[i];
    end;
  end;

  UpdatePatternGrid();
end;

procedure TSTMainWnd.mnuPatternShrinkX3Click(Sender: TObject);
var
  i: Integer;
  iChan: Integer;
begin
  if Song.Pattern[udnPatternNum.Position].Length < 3 then exit;

  if TripleShrinkRowNotes(udnPatternNum.Position) then
  begin
    if Application.MessageBox('Shrinking this pattern would cause notes to be lost.'#13#10#13#10'Continue anyway?',
                           PAnsiChar(Application.Title),
                           MB_ICONQUESTION or MB_OKCANCEL) = ID_CANCEL then
      exit;
  end;

  UndoPattern := Song.Pattern[udnPatternNum.Position];
  UndoSvgPattern := Song.SvgPatternData[udnPatternNum.Position];

  Song.Pattern[udnPatternNum.Position].Length := Song.Pattern[udnPatternNum.Position].Length div 3;
  for i := 1 to UndoPattern.Length do
  begin
    if (i mod 3) = 1 then
    begin
      for iChan := 1 to 2 do
      begin
        Song.Pattern[udnPatternNum.Position].Chan[iChan][i div 3 + 1] := UndoPattern.Chan[iChan][i];
        Song.Pattern[udnPatternNum.Position].Sustain[iChan][i div 3 + 1] := UndoPattern.Sustain[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].Glissando[iChan][i div 3 + 1] := UndoSvgPattern.Glissando[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].Skew[iChan][i div 3 + 1] := UndoSvgPattern.Skew[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].SkewXOR[iChan][i div 3 + 1] := UndoSvgPattern.SkewXOR[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].Arpeggio[iChan][i div 3 + 1] := UndoSvgPattern.Arpeggio[iChan][i];
        Song.SvgPatternData[udnPatternNum.Position].Warp[iChan][i div 3 + 1] := UndoSvgPattern.Warp[iChan][i];        
      end;
      Song.Pattern[udnPatternNum.Position].Drum[i div 3 + 1] := UndoPattern.Drum[i];
    end;
  end;

  UpdatePatternGrid();
end;

procedure TSTMainWnd.mnuPatternSwapChansClick(Sender: TObject);
begin
  StopPlayer();

  SwapChannelsDlg.udnPatternNum.Position := udnPatternNum.Position;
  if SwapChannelsDlg.ShowModal = mrOK then
  begin
    UpdatePatternGrid();
    bSongDirty := true;
  end;
end;

procedure TSTMainWnd.mnuPatternTransposeClick(Sender: TObject);
begin
  StopPlayer();

  TransposePatternDlg.udnPatternNum.Position := udnPatternNum.Position;
  if TransposePatternDlg.ShowModal = mrOK then
  begin
    UpdatePatternGrid();
    bSongDirty := true;
  end;
end;

procedure TSTMainWnd.mnuPlayFromCurrentClick(Sender: TObject);
begin
  if bStopPlayer = false then
  begin
    StopPlayer();
  end;

  if Song.SongLength = 0 then
  begin
    Application.MessageBox('The song contains no patterns. There is nothing to play.',
                           PAnsiChar(Application.Title),
                           MB_OK or MB_ICONEXCLAMATION);
    exit;
  end;

  if grdSong.Col >= Song.SongLength then exit;

  FreeAndNil(ZXPlay);
  ZXPlay := TPlayerThread.Create(true);
  ZXPlay.WaveOutHandle := Self.hWaveOut;
  ZXPlay.Engine := SpecEmu.Engine;
  ZXPlay.Song := Song;
  ZXPlay.iStartPos := grdSong.Col;
  ZXPlay.HMsgWnd := Self.Handle;

  iPatternPlayer := grdSong.Col-1;
  iPatternTickCount := 0;
  iOldPatternRow := grdPattern.Row;
  iOldPatternCol := grdPattern.Col;
  bStopPlayer := false;
  udnPatternNum.Position := Song.SongLayout[grdSong.Col];
  grdPattern.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goTabs,goThumbTracking,goRowSelect];
  grdPattern.Row := 1;
  grdPattern.SetFocus;
  grdPattern.Refresh;
  FPlaying := PLAY_SONG;
  ZXPlay.Resume;
end;

procedure TSTMainWnd.mnuPlayPatternClick(Sender: TObject);
var
  Pat: STPatterns.TPattern;
  SvgPat: STPatterns.TPatternSVG;
begin
  if bStopPlayer = false then
  begin
    StopPlayer();
  end;

  SvgPat := Song.SvgPatternData[udnPatternNum.Position];
  Pat := Song.Pattern[udnPatternNum.Position];
  if Pat.Length < 126 then
  begin
    Inc(Pat.Length);
    Pat.Chan[1][Pat.Length] := $82; // Rest
    Pat.Chan[2][Pat.Length] := $82; // Rest
    Pat.Sustain[1][Pat.Length] := 255; // None
    Pat.Sustain[2][Pat.Length] := 255; // None
    Pat.Drum[Pat.Length] := 0; // None
    SvgPat.Glissando[1][Pat.Length] := 0;
    SvgPat.Glissando[2][Pat.Length] := 0;
    SvgPat.Skew[1][Pat.Length] := 0;
    SvgPat.Skew[2][Pat.Length] := 0;
    SvgPat.SkewXOR[1][Pat.Length] := 0;
    SvgPat.SkewXOR[2][Pat.Length] := 0;
    SvgPat.Arpeggio[1][Pat.Length] := 0;
    SvgPat.Arpeggio[2][Pat.Length] := 0;
  end;

  FreeAndNil(ZXPlay);
  ZXPlay := TPlayerThread.Create(true);
  ZXPlay.WaveOutHandle := Self.hWaveOut;
  ZXPlay.Engine := SpecEmu.Engine;
  ZXPlay.Song := Song;
  ZXPlay.SvgPattern := Song.SvgPatternData[udnPatternNum.Position];
  ZXPlay.Pattern := Song.Pattern[udnPatternNum.Position];
  ZXPlay.iStartPos := 0;
  ZXPlay.HMsgWnd := Self.Handle;

  iPatternPlayer := 0;
  iPatternTickCount := 0;
  iOldPatternRow := grdPattern.Row;
  iOldPatternCol := grdPattern.Col;
  bStopPlayer := false;
  grdPattern.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goTabs,goThumbTracking,goRowSelect];
  grdPattern.Row := 1;
  grdPattern.Refresh;
  grdPattern.SetFocus;
  FPlaying := PLAY_PATTERN;
  ZXPlay.Resume;

  {
  SpecEmu.Register_SP := $7FF0; // stack pointer - 32752
  SpecEmu.Register_PC := $8000; //$8000; // program counter - 32768
  SpecEmu.LoadPlayerPattern(Song.Pattern[udnPatternNum.Position],Song);
  SpecEmu.OnNewPattern := PatternPlayerNewPattern;
  if SpecEmu.Engine = SFX then
    SpecEmu.OnPatternTick := PatternTick
  else if (SpecEmu.Engine = P1D) or (SpecEmu.Engine = P1S) then
    SpecEmu.OnPatternTick := Phaser1PatternTick
  else
    SpecEmu.OnPatternTick := TMBPatternTick;
  iPatternPlayer := 0; // inc'd to 0 on first OnNewPattern event
  iPatternTickCount := 0;
  bStopPlayer := false;
  iOldRow := grdPattern.Row;
  iOldCol := grdPattern.Col;
  grdPattern.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goTabs,goThumbTracking,goRowSelect];
  grdPattern.Row := 1;
  grdPattern.SetFocus;
  grdPattern.Refresh;
  pnlToolbar.ShowHint := false;
  while bStopPlayer = false do
  begin
    SpecEmu.Exec(false);
    Application.ProcessMessages();
  end;
  SpecEmu.ResetWaveBuffers;
  pnlToolbar.ShowHint := true;

  grdPattern.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goTabs,goThumbTracking];
  if iOldRow < grdPattern.RowCount then
    grdPattern.Row := iOldRow
  else
    grdPattern.Row := 1;
  if iOldCol < grdPattern.ColCount then
    grdPattern.Col := iOldCol
  else
    grdPattern.Col := 1;

  grdPattern.Refresh;
}  
end;

procedure TSTMainWnd.mnuPlaySongClick(Sender: TObject);
begin
  if bStopPlayer = false then
  begin
    StopPlayer();
  end;

  if Song.SongLength = 0 then
  begin
    Application.MessageBox('The song contains no patterns. There is nothing to play.',
                           PAnsiChar(Application.Title),
                           MB_OK or MB_ICONEXCLAMATION);
    exit;
  end;

  FreeAndNil(ZXPlay);
  ZXPlay := TPlayerThread.Create(true);
  ZXPlay.WaveOutHandle := Self.hWaveOut;
  ZXPlay.Engine := SpecEmu.Engine;
  ZXPlay.Song := Song;
  ZXPlay.iStartPos := 0;
  ZXPlay.HMsgWnd := Self.Handle;

  iPatternPlayer := -1;
  iPatternTickCount := 0;
  iOldPatternRow := grdPattern.Row;
  iOldPatternCol := grdPattern.Col;
  grdSong.Col := 0;
  bStopPlayer := false;
  grdPattern.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goTabs,goThumbTracking,goRowSelect];
  grdPattern.Row := 1;
  grdPattern.Refresh;
  grdPattern.SetFocus;
  FPlaying := PLAY_SONG;
  ZXPlay.Resume;
end;

procedure TSTMainWnd.mnuPlayStopClick(Sender: TObject);
begin
  StopPlayer();
end;

procedure TSTMainWnd.mnuSongAdjustTempoClick(Sender: TObject);
begin
  StopPlayer();

  if AdjustSongTempoDlg.ShowModal() = mrOK then
  begin
    bSongDirty := true;
    UpdatePatternGrid();
  end;
end;

procedure TSTMainWnd.mnuSongInfoClick(Sender: TObject);
begin
  StopPlayer();

  SongInfoDlg.ShowModal;
end;

procedure TSTMainWnd.mnuSongTransposeClick(Sender: TObject);
begin
  StopPlayer();

  if TransposeSongDlg.ShowModal() = mrOK then
  begin
    bSongDirty := true;
    UpdatePatternGrid();
  end;
end;

procedure TSTMainWnd.SetPatternEdStandard();
begin
  grdPattern.ColCount := 6;
  grdPattern.Cells[1,0] := 'Chan 1';
  grdPattern.Cells[3,0] := 'Chan 2';
  grdPattern.Cells[5,0] := 'Drum';
  grdPattern.ColWidths[0] := 24;
  grdPattern.ColWidths[1] := 48;
  grdPattern.ColWidths[2] := 40;
  grdPattern.ColWidths[3] := 48;
  grdPattern.ColWidths[4] := 40;
  grdPattern.ColWidths[5] := 32;
end;

procedure TSTMainWnd.SetPatternEdSavage();
begin
  grdPattern.ColCount := 14;
  grdPattern.Cells[1,0] := 'Chan 1';
  grdPattern.Cells[7,0] := 'Chan 2';
  grdPattern.Cells[13,0] := 'Drum';
  grdPattern.ColWidths[0] := 24;
  grdPattern.ColWidths[1] := 40;
  grdPattern.ColWidths[2] := 21;
  grdPattern.ColWidths[3] := 21;
  grdPattern.ColWidths[4] := 21;
  grdPattern.ColWidths[5] := 21;
  grdPattern.ColWidths[6] := 21;
  grdPattern.ColWidths[7] := 40;
  grdPattern.ColWidths[8] := 21;
  grdPattern.ColWidths[9] := 21;
  grdPattern.ColWidths[10] := 21;
  grdPattern.ColWidths[11] := 21;
  grdPattern.ColWidths[12] := 21;
  grdPattern.ColWidths[13] := 30;

end;

procedure TSTMainWnd.mnuTGMusicStudioClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := MSD;
  Song.PreferredEngine := 'MSD';
  mnuTGSpecialFX.Checked := false;
  mnuTGTheMusicBox.Checked := false;
  mnuTGMusicStudio.Checked := true;
  mnuTGPhaser1Digital.Checked := false;
  mnuTGPhaser1Synth.Checked := false;
  mnuTGSavage.Checked := false;
  mnuTGROMBeep.Checked := false;
  mnuTGPlipPlop.Checked := false;
  mnuTGStocker.Checked := false;
  SetPatternEdStandard();
  grdPattern.Cells[2,0] := 'N/A';
  grdPattern.Cells[4,0] := 'N/A';
  grdPattern.Cells[5,0] := 'Drum';
  pnlPhaser1Ed.Hide;
  pnlSavageOrnEditor.Hide;
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 2;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuTGPhaser1DigitalClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := P1D;
  Song.PreferredEngine := 'P1D';
  mnuTGSpecialFX.Checked := false;
  mnuTGTheMusicBox.Checked := false;
  mnuTGMusicStudio.Checked := false;
  mnuTGPhaser1Digital.Checked := true;
  mnuTGPhaser1Synth.Checked := false;
  mnuTGSavage.Checked := false;
  mnuTGROMBeep.Checked := false;
  mnuTGPlipPlop.Checked := false;
  mnuTGStocker.Checked := false;
  SetPatternEdStandard();
  grdPattern.Cells[2,0] := 'Phase';
  grdPattern.Cells[4,0] := 'Instr.';
  grdPattern.Cells[5,0] := 'Drum';
  udnP1Instrument.Position := 0;
  pnlPhaser1Ed.Show;
  pnlSavageOrnEditor.Hide;
  txtP1InstrumentChange(nil);
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 3;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuTGPhaser1SynthClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := P1S;
  Song.PreferredEngine := 'P1S';
  mnuTGSpecialFX.Checked := false;
  mnuTGTheMusicBox.Checked := false;
  mnuTGMusicStudio.Checked := false;
  mnuTGPhaser1Digital.Checked := false;
  mnuTGPhaser1Synth.Checked := true;
  mnuTGSavage.Checked := false;
  mnuTGROMBeep.Checked := false;
  mnuTGPlipPlop.Checked := false;
  mnuTGStocker.Checked := false;
  SetPatternEdStandard();
  grdPattern.Cells[2,0] := 'Phase';
  grdPattern.Cells[4,0] := 'Instr.';
  grdPattern.Cells[5,0] := 'Drum';
  udnP1Instrument.Position := 0;
  pnlPhaser1Ed.Show;
  pnlSavageOrnEditor.Hide;
  txtP1InstrumentChange(nil);
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 4;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuTGPlipPlopClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := PLP;
  Song.PreferredEngine := 'PLP';
  mnuTGSpecialFX.Checked := false;
  mnuTGTheMusicBox.Checked := false;
  mnuTGMusicStudio.Checked := false;
  mnuTGPhaser1Digital.Checked := false;
  mnuTGPhaser1Synth.Checked := false;
  mnuTGSavage.Checked := false;
  mnuTGROMBeep.Checked := false;
  mnuTGPlipPlop.Checked := true;
  mnuTGStocker.Checked := false;
  SetPatternEdStandard();
  grdPattern.Cells[2,0] := 'N/A';
  grdPattern.Cells[4,0] := 'N/A';
  grdPattern.Cells[5,0] := 'N/A';
  pnlPhaser1Ed.Hide;
  pnlSavageOrnEditor.Hide;
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 7;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuTGROMBeepClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := RMB;
  Song.PreferredEngine := 'RMB';
  mnuTGSpecialFX.Checked := false;
  mnuTGTheMusicBox.Checked := false;
  mnuTGMusicStudio.Checked := false;
  mnuTGPhaser1Digital.Checked := false;
  mnuTGPhaser1Synth.Checked := false;
  mnuTGSavage.Checked := false;
  mnuTGROMBeep.Checked := true;
  mnuTGPlipPlop.Checked := false;
  mnuTGStocker.Checked := false;
  SetPatternEdStandard();
  grdPattern.Cells[2,0] := 'N/A';
  grdPattern.Cells[4,0] := 'N/A';
  grdPattern.Cells[5,0] := 'N/A';
  pnlPhaser1Ed.Hide;
  pnlSavageOrnEditor.Hide;
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 6;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuTGSavageClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := SVG;
  Song.PreferredEngine := 'SVG';
  mnuTGSpecialFX.Checked := false;
  mnuTGTheMusicBox.Checked := false;
  mnuTGMusicStudio.Checked := false;
  mnuTGPhaser1Digital.Checked := false;
  mnuTGPhaser1Synth.Checked := false;
  mnuTGSavage.Checked := true;
  mnuTGROMBeep.Checked := false;
  mnuTGPlipPlop.Checked := false;
  mnuTGStocker.Checked := false;
  SetPatternEdSavage();
  grdPattern.Cells[2,0] := 'Glis';
  grdPattern.Cells[3,0] := 'Skw';
  grdPattern.Cells[4,0] := 'Xor';
  grdPattern.Cells[5,0] := 'Orn';
  grdPattern.Cells[6,0] := 'FX';
  grdPattern.Cells[8,0] := 'Glis';
  grdPattern.Cells[9,0] := 'Skw';
  grdPattern.Cells[10,0] := 'Xor';
  grdPattern.Cells[11,0] := 'Orn';
  grdPattern.Cells[12,0] := 'FX';
  udnP1Instrument.Position := 0;
  pnlPhaser1Ed.Hide;
  pnlSavageOrnEditor.Top := pnlPhaser1Ed.Top;
  pnlSavageOrnEditor.Show;
  txtSvgOrnamentChange(nil);
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 5;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuTGSpecialFXClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := SFX;
  Song.PreferredEngine := 'SFX';
  mnuTGSpecialFX.Checked := true;
  mnuTGTheMusicBox.Checked := false;
  mnuTGMusicStudio.Checked := false;
  mnuTGPhaser1Digital.Checked := false;
  mnuTGPhaser1Synth.Checked := false;
  mnuTGSavage.Checked := false;
  mnuTGROMBeep.Checked := false;
  mnuTGPlipPlop.Checked := false;
  mnuTGStocker.Checked := false;
  SetPatternEdStandard();
  grdPattern.Cells[2,0] := 'Sustain';
  grdPattern.Cells[4,0] := 'Sustain';
  grdPattern.Cells[5,0] := 'Drum';
  pnlPhaser1Ed.Hide;
  pnlSavageOrnEditor.Hide;
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 0;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuTGStockerClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := STK;
  Song.PreferredEngine := 'STK';
  mnuTGSpecialFX.Checked := false;
  mnuTGTheMusicBox.Checked := false;
  mnuTGMusicStudio.Checked := false;
  mnuTGPhaser1Digital.Checked := false;
  mnuTGPhaser1Synth.Checked := false;
  mnuTGSavage.Checked := false;
  mnuTGROMBeep.Checked := false;
  mnuTGPlipPlop.Checked := false;
  mnuTGStocker.Checked := true;
  SetPatternEdStandard();
  grdPattern.Cells[2,0] := 'N/A';
  grdPattern.Cells[4,0] := 'N/A';
  grdPattern.Cells[5,0] := 'N/A';
  pnlPhaser1Ed.Hide;
  pnlSavageOrnEditor.Hide;
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 8;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuTGTheMusicBoxClick(Sender: TObject);
begin
  StopPlayer();

  SpecEmu.Engine := TMB;
  Song.PreferredEngine := 'TMB';
  mnuTGSpecialFX.Checked := false;
  mnuTGTheMusicBox.Checked := true;
  mnuTGMusicStudio.Checked := false;
  mnuTGPhaser1Digital.Checked := false;
  mnuTGPhaser1Synth.Checked := false;
  mnuTGSavage.Checked := false;
  mnuTGROMBeep.Checked := false;
  mnuTGPlipPlop.Checked := false;
  mnuTGStocker.Checked := false;
  SetPatternEdStandard();
  grdPattern.Cells[2,0] := 'N/A';
  grdPattern.Cells[4,0] := 'N/A';
  grdPattern.Cells[5,0] := 'N/A';
  pnlPhaser1Ed.Hide;
  pnlSavageOrnEditor.Hide;
  UpdatePatternGrid();
  cboBeeperEngine.ItemIndex := 1;
  bSongDirty := true;
  grdPattern.SetFocus;
end;

procedure TSTMainWnd.mnuToolsOptionsClick(Sender: TObject);
begin
  if OptionsDlg.ShowModal = mrOK then
  begin
    NumberGridRows();
    UpdateSongGrid();
  end;
end;

procedure TSTMainWnd.InitDisplay();
begin
  InitPatternGrid();
  InitSongGrid();
  InitSVGOrnEditGrid();  
  mnuTGSpecialFXClick(nil);
end;

procedure TSTMainWnd.InitPatternGrid();
begin
  grdPattern.ColCount := 6;
  grdPattern.FixedCols := 1;
  grdPattern.RowCount := udnPatternLen.Position+1;
  grdPattern.DefaultRowHeight := 18;
  SetPatternEdStandard();
  grdPattern.Cells[1,0] := 'Chan 1';
  grdPattern.Cells[2,0] := 'Sustain';
  grdPattern.Cells[3,0] := 'Chan 2';
  grdPattern.Cells[4,0] := 'Sustain';
  grdPattern.Cells[5,0] := 'Drum';
  NumberGridRows();
end;

procedure TSTMainWnd.InitSongGrid();
var
  i: integer;
begin
  if RegSettings.ShowLayoutColNumbers then
    grdSong.Height := grdSong.RowHeights[0] + grdSong.RowHeights[1] + GetSystemMetrics(SM_CXHSCROLL) + 5
  else
    grdSong.Height := grdSong.RowHeights[0] + GetSystemMetrics(SM_CXHSCROLL) + 5;

  grdSong.ColCount := 256;
  grdSong.RowCount := 1;
  for i := 0 to 255 do
  begin
    grdSong.ColWidths[i] := 30;
    grdSong.Cells[i,0] := '...';
  end;
end;

procedure TSTMainWnd.InitSVGOrnEditGrid();
var
  i: integer;
begin
  grdSVGOrnEdit.ColCount := 255;
  grdSVGOrnEdit.RowCount := 1;
  for i := 0 to 254 do
  begin
    grdSVGOrnEdit.ColWidths[i] := 30;
    grdSVGOrnEdit.Cells[i,0] := '...';
  end;
end;


procedure TSTMainWnd.NumberGridRows();
var
  i: integer;
begin
  for i := 1 to grdPattern.RowCount - 1 do
  begin
    if RegSettings.PatternRowNumbersHex then
      grdPattern.Cells[0,i] := IntToHex(i-1,2)
    else
      grdPattern.Cells[0,i] := IntToStr(i-1);
  end;
end;

procedure TSTMainWnd.txtP1DetuneChange(Sender: TObject);
var
  i: integer;
begin
  i := StrToIntDef(txtP1Instrument.Text,0);
  if (i < 0) then i := 0;
  if (i > 99) then i := 99;
  txtP1Instrument.Text := IntToStr(i);

  Song.Phaser1Instrument[i].Detune := udnP1Detune.Position;
  bSongDirty := true;
end;


procedure TSTMainWnd.txtP1InstrumentChange(Sender: TObject);
var
  i: integer;
begin
  i := StrToIntDef(txtP1Instrument.Text,0);
  if (i < 0) then i := 0;
  if (i > 99) then i := 99;
  txtP1Instrument.Text := IntToStr(i);
  if Song.IsInstrumentUsed(i) then
    chkP1InstInUse.Checked := true
  else
    chkP1InstInUse.Checked := false;

  udnP1Mult.Position := Song.Phaser1Instrument[i].Multiple;
  udnP1Detune.Position := Song.Phaser1Instrument[i].Detune;
  udnP1Phase.Position := Song.Phaser1Instrument[i].Phase;
end;

procedure TSTMainWnd.txtP1MultChange(Sender: TObject);
var
  i: integer;
begin
  i := StrToIntDef(txtP1Instrument.Text,0);
  if (i < 0) then i := 0;
  if (i > 99) then i := 99;
  txtP1Instrument.Text := IntToStr(i);

  Song.Phaser1Instrument[i].Multiple := udnP1Mult.Position;
  bSongDirty := true;
end;

procedure TSTMainWnd.txtP1PhaseChange(Sender: TObject);
var
  i: integer;
begin
  i := StrToIntDef(txtP1Instrument.Text,0);
  if (i < 0) then i := 0;
  if (i > 99) then i := 99;
  txtP1Instrument.Text := IntToStr(i);

  Song.Phaser1Instrument[i].Phase := udnP1Phase.Position;
  bSongDirty := true;
end;

procedure TSTMainWnd.txtPatternLenExit(Sender: TObject);
begin
  if (StrToIntDef((Sender as TEdit).Text,0) >= udnPatternLen.Min) or
     (StrToIntDef((Sender as TEdit).Text,0) <= udnPatternLen.Max) then
    udnPatternLen.Position := StrToIntDef((Sender as TEdit).Text,0);
    udnPatternLenClick(udnPatternLen,btNext);
end;

procedure TSTMainWnd.txtPatternNameChange(Sender: TObject);
begin
  Song.Pattern[udnPatternNum.Position].Name := txtPatternName.Text;
end;

procedure TSTMainWnd.txtPatternNumChange(Sender: TObject);
begin
  UndoPattern := Song.Pattern[udnPatternNum.Position];
  UpdatePatternGrid();
end;

procedure TSTMainWnd.txtSongAuthorChange(Sender: TObject);
begin
  Song.SongAuthor := (Sender as TEdit).Text;
  bSongDirty := true;
end;

procedure TSTMainWnd.txtSongTitleChange(Sender: TObject);
begin
  Song.SongTitle := (Sender as TEdit).Text;
  bSongDirty := true;
end;

procedure TSTMainWnd.txtSvgOrnamentChange(Sender: TObject);
var
  i: integer;
begin
  i := StrToIntDef(txtSvgOrnament.Text,0);
  if (i < 0) then i := 0;
  if (i > 31) then i := 31;
  txtSvgOrnament.Text := IntToStr(i);
  if Song.IsOrnamentUsed(i) then
    chkSavageOrnInUse.Checked := true
  else
    chkSavageOrnInUse.Checked := false;

  SetSvgOrnamentGrid(i);
end;

procedure TSTMainWnd.txtTempoExit(Sender: TObject);
begin
  if (StrToIntDef((Sender as TEdit).Text,0) >= udnTempo.Min) or
     (StrToIntDef((Sender as TEdit).Text,0) <= udnTempo.Max) then
    udnTempo.Position := StrToIntDef((Sender as TEdit).Text,0);
    udnTempoClick(udnTempo,btNext);
end;

procedure TSTMainWnd.SetSvgOrnamentGrid(i: integer);
var
  j: integer;
begin
  grdSvgOrnEdit.ColCount := 255;
  for j := 1 to 255 do
  begin
    if Song.SVGArpeggio[i].Value[j] = 255 then
      grdSvgOrnEdit.Cells[j-1,0] := '...'
    else
      grdSvgOrnEdit.Cells[j-1,0] := IntToStr(Song.SVGArpeggio[i].Value[j] and $7F);
  end;

  if (Song.SVGArpeggio[i].Length = 0) or (Song.SVGArpeggio[i].Value[Song.SVGArpeggio[i].Length] >= $80) then
    chkOrnLooped.Checked := true
  else
    chkOrnLooped.Checked := false;
end;

procedure TSTMainWnd.udnPatternLenClick(Sender: TObject; Button: TUDBtnType);
begin
  Song.Pattern[udnPatternNum.Position].Length := udnPatternLen.Position;
  bSongDirty := true;
  UpdatePatternGrid();
  grdPattern.SetFocus();
end;

procedure TSTMainWnd.udnTempoClick(Sender: TObject; Button: TUDBtnType);
begin
  Song.Pattern[udnPatternNum.Position].Tempo := udnTempo.Position;
  bSongDirty := true;
  UpdatePatternGrid();
  grdPattern.SetFocus();
end;

function TSTMainWnd.IsValidNoteKey(Key: Char): boolean;
var
  i: cardinal;
begin
  i := GetKeyboardLayout(0);
  case i of
  $040C040C:
    begin
      // AZERTY (French, predominantly) layout
      if (Key >= 'A') and (Key <= 'Z') then Inc(Key,32);
      case Key of
      'w','s','x','d','c','v','g','b','h','n','j',',','l',';','m',':':
        Result := true;
      'a','é','z','"','e','r','(','t','-','y','è','u','i','ç','o','à','p':
        Result := true;
      'q','&':
        Result := true;
      else
        Result := false;
      end;
    end;
  $04070407,$F0070415,$04240424:
    begin
      // QWERTZ (Germany, Poland, Slovenia/etc) layout
      if (Key >= 'A') and (Key <= 'Z') then Inc(Key,32);
      case Key of
      'y','s','x','d','c','v','g','b','h','n','j','m',',','l','.','ö','-':
        Result := true;
      'q','2','w','3','e','r','5','t','6','z','7','u','i','9','o','0','p':
        Result := true;
      'a','1':
        Result := true;
      else
        Result := false;
      end;
    end;
  else
    begin
      // Default is standard QWERTY layout
      if (Key >= 'A') and (Key <= 'Z') then Inc(Key,32);
      case Key of
      'z','s','x','d','c','v','g','b','h','n','j','m',',','l','.',';','/':
        Result := true;
      'q','2','w','3','e','r','5','t','6','y','7','u','i','9','o','0','p':
        Result := true;
      'a','1':
        Result := true;
      else
        Result := false;
      end;
    end;
  end;
end;

function TSTMainWnd.KeyToNoteVal(Key: Char; Octave: integer): byte;
var
  iNote: integer;
  i: cardinal;
const
  COffset = -6;
begin
  iNote := 255;
  if (Key >= 'A') and (Key <= 'Z') then Inc(Key,32);

  i := GetKeyboardLayout(0);
  case i of
  $040C040C:
    begin
      // AZERTY (French, predominantly) layout
      case Key of
      'q','&': begin
             iNote := $82;  // REST
             Result := byte(iNote);
             exit;
           end;

      'w': iNote := 0;
      's': iNote := 1;
      'x': iNote := 2;
      'd': iNote := 3;
      'c': iNote := 4;
      'v': iNote := 5;
      'g': iNote := 6;
      'b': iNote := 7;
      'h': iNote := 8;
      'n': iNote := 9;
      'j': iNote := 10;
      ',': iNote := 11;
      ';': iNote := 12;
      'l': iNote := 13;
      ':': iNote := 14;
      'm': iNote := 15;
      'a': iNote := 12;
      'é': iNote := 13;
      'z': iNote := 14;
      '"': iNote := 15;
      'e': iNote := 16;
      'r': iNote := 17;
      '(': iNote := 18;
      't': iNote := 19;
      '-': iNote := 20;
      'y': iNote := 21;
      'è': iNote := 22;
      'u': iNote := 23;
      'i': iNote := 24;
      'ç': iNote := 25;
      'o': iNote := 26;
      'à': iNote := 27;
      'p': iNote := 28;
      end;
    end;
  $04070407,$F0070415,$04240424:
    begin
      // QWERTZ (Germany, Poland, etc) layout
      case Key of
      'a','1': begin
             iNote := $82;  // REST
             Result := byte(iNote);
             exit;
           end;
      'y': iNote := 0;
      's': iNote := 1;
      'x': iNote := 2;
      'd': iNote := 3;
      'c': iNote := 4;
      'v': iNote := 5;
      'g': iNote := 6;
      'b': iNote := 7;
      'h': iNote := 8;
      'n': iNote := 9;
      'j': iNote := 10;
      'm': iNote := 11;
      ',': iNote := 12;
      'l': iNote := 13;
      '.': iNote := 14;
      'ö': iNote := 15;
      '-': iNote := 16;
      'q': iNote := 12;
      '2': iNote := 13;
      'w': iNote := 14;
      '3': iNote := 15;
      'e': iNote := 16;
      'r': iNote := 17;
      '5': iNote := 18;
      't': iNote := 19;
      '6': iNote := 20;
      'z': iNote := 21;
      '7': iNote := 22;
      'u': iNote := 23;
      'i': iNote := 24;
      '9': iNote := 25;
      'o': iNote := 26;
      '0': iNote := 27;
      'p': iNote := 28;
      end;
    end;
  else
    begin
      // Default is standard QWERTY layout
      case Key of
      'a','1': begin
             iNote := $82;  // REST
             Result := byte(iNote);
             exit;
           end;
      'z': iNote := 0;
      's': iNote := 1;
      'x': iNote := 2;
      'd': iNote := 3;
      'c': iNote := 4;
      'v': iNote := 5;
      'g': iNote := 6;
      'b': iNote := 7;
      'h': iNote := 8;
      'n': iNote := 9;
      'j': iNote := 10;
      'm': iNote := 11;
      ',': iNote := 12;
      'l': iNote := 13;
      '.': iNote := 14;
      ';': iNote := 15;
      '/': iNote := 16;
      'q': iNote := 12;
      '2': iNote := 13;
      'w': iNote := 14;
      '3': iNote := 15;
      'e': iNote := 16;
      'r': iNote := 17;
      '5': iNote := 18;
      't': iNote := 19;
      '6': iNote := 20;
      'y': iNote := 21;
      '7': iNote := 22;
      'u': iNote := 23;
      'i': iNote := 24;
      '9': iNote := 25;
      'o': iNote := 26;
      '0': iNote := 27;
      'p': iNote := 28;
      end;
    end;
  end;



  Inc(iNote,COffset);
  Inc(iNote,(Octave-1) * 12);


  if Song.PreferredEngine = 'TMB' then
  begin
    if (iNote < 0) then iNote := 255;
    if (iNote > $34) then iNote := 255;
  end
  else if Song.PreferredEngine = 'SFX' then
  begin
    if (iNote < 0) then iNote := 255;
    if (iNote > $33) then iNote := 255;
  end
  else if Song.PreferredEngine = 'MSD' then
  begin
    if (iNote < 0) then iNote := 255;
    if (iNote > $24) then iNote := 255;
  end
  else if (Song.PreferredEngine = 'P1D') or (Song.PreferredEngine = 'P1S') or
          (Song.PreferredEngine = 'SVG') then
  begin
    if (iNote < -6) then iNote := 255;
    if (iNote > $35) then iNote := 255;
    if (iNote < 0) then inc(iNote,107);
  end;
  Result := byte(iNote);
end;

procedure TSTMainWnd.lblOrnLoopedClick(Sender: TObject);
begin
  chkOrnLooped.Checked := not chkOrnLooped.Checked;
end;

function NoteValToDisplay(iNote: integer): string;
const
  COffset = 6;
begin
  if (iNote < 0) or (iNote >= 255) then
    Result := '---'
  else if (iNote = $82) then
    Result := 'R--'
  else
  begin
    Inc(iNote,COffset); // 0 now = C, Octave 1
    if (iNote > 106) then Dec(iNote,107);
    
    case (iNote mod 12) of
    0:  Result := 'C-';
    1:  Result := 'C#';
    2:  Result := 'D-';
    3:  Result := 'D#';
    4:  Result := 'E-';
    5:  Result := 'F-';
    6:  Result := 'F#';
    7:  Result := 'G-';
    8:  Result := 'G#';
    9:  Result := 'A-';
    10: Result := 'A#';
    11: Result := 'B-';
    else
      Result := '??';
    end;
    Result := Result + IntToStr(iNote div 12 + 1);
  end;
end;

procedure TSTMainWnd.RenderSVGPatternInfo();
var
  i: integer;
  sDrum: string;
begin
  for i := 1 to grdPattern.RowCount - 1 do
  begin
    grdPattern.Cells[1,i] := NoteValToDisplay(Song.Pattern[udnPatternNum.Position].Chan[1][i]);
    grdPattern.Cells[7,i] := NoteValToDisplay(Song.Pattern[udnPatternNum.Position].Chan[2][i]);
    case Song.Pattern[udnPatternNum.Position].Drum[i] of
    $81: sDrum := '1';
    $82: sDrum := '2';
    $83: sDrum := '3';
    $84: sDrum := '4';
    $85: sDrum := '5';
    $86: sDrum := '6';
    $87: sDrum := '7';
    $88: sDrum := '8';
    $89: sDrum := '9';
    $8A: sDrum := '10';
    $8B: sDrum := '11';
    $8C: sDrum := '12';
    $8D: sDrum := '13';
    else sDrum := '-';
    end;
    // Glissando columns
    if Song.SvgPatternData[udnPatternNum.Position].Glissando[1,i] > 255 then
      grdPattern.Cells[2,i] := '--'
    else
      grdPattern.Cells[2,i] := IntToHex(Song.SvgPatternData[udnPatternNum.Position].Glissando[1,i],2);
    if Song.SvgPatternData[udnPatternNum.Position].Glissando[2,i] > 255 then
      grdPattern.Cells[8,i] := '--'
    else
      grdPattern.Cells[8,i] := IntToHex(Song.SvgPatternData[udnPatternNum.Position].Glissando[2,i],2);
    // Skew columns
    if Song.SvgPatternData[udnPatternNum.Position].Skew[1,i] > 255 then
      grdPattern.Cells[3,i] := '--'
    else
      grdPattern.Cells[3,i] := IntToHex(Song.SvgPatternData[udnPatternNum.Position].Skew[1,i],2);
    if Song.SvgPatternData[udnPatternNum.Position].Skew[2,i] > 255 then
      grdPattern.Cells[9,i] := '--'
    else
      grdPattern.Cells[9,i] := IntToHex(Song.SvgPatternData[udnPatternNum.Position].Skew[2,i],2);
    // SkewXOR columns
    if Song.SvgPatternData[udnPatternNum.Position].SkewXor[1,i] > 255 then
      grdPattern.Cells[4,i] := '--'
    else
      grdPattern.Cells[4,i] := IntToHex(Song.SvgPatternData[udnPatternNum.Position].SkewXor[1,i],2);
    if Song.SvgPatternData[udnPatternNum.Position].SkewXor[2,i] > 255 then
      grdPattern.Cells[10,i] := '--'
    else
      grdPattern.Cells[10,i] := IntToHex(Song.SvgPatternData[udnPatternNum.Position].SkewXor[2,i],2);
    // Arp columns
    if Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1,i] > 255 then
      grdPattern.Cells[5,i] := '--'
    else
      grdPattern.Cells[5,i] := IntToHex(Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1,i],2);
    if Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2,i] > 255 then
      grdPattern.Cells[11,i] := '--'
    else
      grdPattern.Cells[11,i] := IntToHex(Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2,i],2);
    // Phase columns
    if Song.SvgPatternData[udnPatternNum.Position].Warp[1,i] = 0 then
      grdPattern.Cells[6,i] := '--'
    else
      grdPattern.Cells[6,i] := 'On';
    if Song.SvgPatternData[udnPatternNum.Position].Warp[2,i] = 0 then
      grdPattern.Cells[12,i] := '--'
    else
      grdPattern.Cells[12,i] := 'On';

    grdPattern.Cells[13,i] := sDrum;
  end;
end;

procedure TSTMainWnd.RenderStandardPatternInfo();
var
  i: integer;
  sDrum: string;
begin
  for i := 1 to grdPattern.RowCount - 1 do
  begin
    grdPattern.Cells[1,i] := NoteValToDisplay(Song.Pattern[udnPatternNum.Position].Chan[1][i]);
    grdPattern.Cells[3,i] := NoteValToDisplay(Song.Pattern[udnPatternNum.Position].Chan[2][i]);
    case Song.Pattern[udnPatternNum.Position].Drum[i] of
    $81: sDrum := '1';
    $82: sDrum := '2';
    $83: sDrum := '3';
    $84: sDrum := '4';
    $85: sDrum := '5';
    $86: sDrum := '6';
    $87: sDrum := '7';
    $88: sDrum := '8';
    $89: sDrum := '9';
    $8A: sDrum := '10';
    $8B: sDrum := '11';
    $8C: sDrum := '12';
    $8D: sDrum := '13';
    else sDrum := '-';
    end;
    grdPattern.Cells[5,i] := sDrum;

    if Song.Pattern[udnPatternNum.Position].Sustain[1][i] = 255 then
      grdPattern.Cells[2,i] := '-'
    else if (Song.PreferredEngine = 'P1D') or (Song.PreferredEngine = 'P1S') then
      grdPattern.Cells[2,i] := 'Reset'
    else
      grdPattern.Cells[2,i] := IntToStr(Song.Pattern[udnPatternNum.Position].Sustain[1][i]);

    if Song.Pattern[udnPatternNum.Position].Sustain[2][i] = 255 then
      grdPattern.Cells[4,i] := '-'
    else
      grdPattern.Cells[4,i] := IntToStr(Song.Pattern[udnPatternNum.Position].Sustain[2][i]);
  end;
end;

procedure TSTMainWnd.UpdatePatternGrid();
begin
  txtPatternName.Text := Song.Pattern[udnPatternNum.Position].Name;
  udnPatternLen.Position := Song.Pattern[udnPatternNum.Position].Length;
  udnTempo.Position := Song.Pattern[udnPatternNum.Position].Tempo;
  txtPatternName.Text := Song.Pattern[udnPatternNum.Position].Name;
  grdPattern.RowCount := udnPatternLen.Position+1;
  NumberGridRows();

  if Song.PreferredEngine = 'SVG' then
    RenderSVGPatternInfo()
  else
    RenderStandardPatternInfo();
end;

procedure TSTMainWnd.UpdateSongGrid();
var
  i: integer;
begin
  txtSongTitle.Text := Song.SongTitle;
  txtSongAuthor.Text := Song.SongAuthor;

  if RegSettings.ShowLayoutColNumbers then
  begin
    grdSong.RowCount := 2;
    grdSong.FixedRows := 1;
    grdSong.Height := grdSong.RowHeights[0] + grdSong.RowHeights[1] + GetSystemMetrics(SM_CXHSCROLL) + 5;
  end
  else
  begin
    grdSong.RowCount := 1;
    grdSong.FixedRows := 0;
    grdSong.Height := grdSong.RowHeights[0] + GetSystemMetrics(SM_CXHSCROLL) + 5;
  end;

  for i := 0 to 255 do
  begin
    if RegSettings.ShowLayoutColNumbers then
      grdSong.Cells[i,0] := IntToStr(i);

    if Song.SongLayout[i] = 255 then
      grdSong.Cells[i,grdSong.RowCount-1] := '...'
    else
      grdSong.Cells[i,grdSong.RowCount-1] := IntToStr(Song.SongLayout[i]);
  end;
  udnPatternNum.Position := StrToIntDef(grdSong.Cells[grdSong.Col,grdSong.RowCount-1],udnPatternNum.Position);
end;

procedure TSTMainWnd.WM_NewPattern(var Msg: TMessage);
begin
  if FPlaying = PLAY_SONG then
    SongPlayerNewPattern()
  else
    PatternPlayerNewPattern();
end;

procedure TSTMainWnd.WM_PatternTick(var Msg: TMessage);
begin
  if SpecEmu.Engine = SFX then
    PatternTick()
  else if (SpecEmu.Engine = P1D) or (SpecEmu.Engine = P1S) then
    Phaser1PatternTick()
  else
    TMBPatternTick();
end;

procedure TSTMainWnd.WM_SongEnd(var Msg: TMessage);
begin
  grdPattern.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goTabs,goThumbTracking];

  if iOldPatternRow < grdPattern.RowCount then
    grdPattern.Row := iOldPatternRow
  else
    grdPattern.Row := 1;
  if iOldPatternCol < grdPattern.ColCount then
    grdPattern.Col := iOldPatternCol
  else
    grdPattern.Col := 1;

  grdPattern.Refresh;
end;

procedure TSTMainWnd.StopPlayer();
begin
  bStopPlayer := true;

  if Assigned(ZXPlay) then
  begin
    ZXPlay.Terminate;
    ZXPlay.WaitFor;
    FreeAndNil(ZXPlay);
  end;
end;

end.
