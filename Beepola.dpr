program Beepola;

uses
  Forms,
  frmSTMainWnd in 'frmSTMainWnd.pas' {STMainWnd},
  frmCompileDlg in 'frmCompileDlg.pas' {CompileDlg},
  STPatterns in 'STPatterns.pas',
  STSong in 'STSong.pas',
  AsmPass1 in 'AsmPass1.pas',
  AsmPass2 in 'AsmPass2.pas',
  AsmTypes in 'AsmTypes.pas',
  AsmUtils in 'AsmUtils.pas',
  Assemb in 'Assemb.pas',
  SFX_Engine in 'SFX_Engine.pas',
  SpecEmu in 'SpecEmu.pas',
  GrokUtils in 'GrokUtils.pas',
  TMB_Engine in 'TMB_Engine.pas',
  frmCopyPattern in 'frmCopyPattern.pas' {CopyPatternDlg},
  frmTransposePatternDlg in 'frmTransposePatternDlg.pas' {TransposePatternDlg},
  frmAboutDlg in 'frmAboutDlg.pas' {AboutDlg},
  frmKeyLayoutWnd in 'frmKeyLayoutWnd.pas' {KeyboardLayoutWnd},
  MSD_Engine in 'MSD_Engine.pas',
  frmSongInfoDlg in 'frmSongInfoDlg.pas' {SongInfoDlg},
  frmTransposeSongDlg in 'frmTransposeSongDlg.pas' {TransposeSongDlg},
  frmExportWavDlg in 'frmExportWavDlg.pas' {ExportWavDlg},
  P1S_Engine in 'P1S_Engine.pas',
  STInstruments in 'STInstruments.pas',
  P1D_Engine in 'P1D_Engine.pas',
  PlayerThread in 'PlayerThread.pas',
  frmSwapChannelsDlg in 'frmSwapChannelsDlg.pas' {SwapChannelsDlg},
  frmPatternAppendDlg in 'frmPatternAppendDlg.pas' {PatternAppendDlg},
  frmImportVTIIFileDlg in 'frmImportVTIIFileDlg.pas' {ImportVTIIFileDlg},
  frmAdjustSongTempoDlg in 'frmAdjustSongTempoDlg.pas' {AdjustSongTempoDlg},
  MRUList in 'MRUList.pas',
  SVG_Engine in 'SVG_Engine.pas',
  frmOptionsDlg in 'frmOptionsDlg.pas' {OptionsDlg},
  RegSettings in 'RegSettings.pas',
  SongRipper in 'SongRipper.pas',
  frmSongRipper in 'frmSongRipper.pas' {SongRipperDlg},
  RMB_Engine in 'RMB_Engine.pas',
  PLP_Engine in 'PLP_Engine.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Beepola';
  Application.CreateForm(TSTMainWnd, STMainWnd);
  Application.CreateForm(TCompileDlg, CompileDlg);
  Application.CreateForm(TCopyPatternDlg, CopyPatternDlg);
  Application.CreateForm(TTransposePatternDlg, TransposePatternDlg);
  Application.CreateForm(TAboutDlg, AboutDlg);
  Application.CreateForm(TKeyboardLayoutWnd, KeyboardLayoutWnd);
  Application.CreateForm(TSongInfoDlg, SongInfoDlg);
  Application.CreateForm(TTransposeSongDlg, TransposeSongDlg);
  Application.CreateForm(TExportWavDlg, ExportWavDlg);
  Application.CreateForm(TSwapChannelsDlg, SwapChannelsDlg);
  Application.CreateForm(TPatternAppendDlg, PatternAppendDlg);
  Application.CreateForm(TImportVTIIFileDlg, ImportVTIIFileDlg);
  Application.CreateForm(TAdjustSongTempoDlg, AdjustSongTempoDlg);
  Application.CreateForm(TOptionsDlg, OptionsDlg);
  Application.CreateForm(TSongRipperDlg, SongRipperDlg);
  Application.Run;
end.
