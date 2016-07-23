unit frmSongInfoDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids;

type
  TSongInfoDlg = class(TForm)
    cmdClose: TButton;
    grdSongProperties: TStringGrid;
    lblSongProperties: TLabel;
    lblCompiledLength: TLabel;
    grdCompiledLength: TStringGrid;
    procedure FormShow(Sender: TObject);
  private
    procedure PopulateSongProperties;
    procedure PopulateCompiledLengths;
    function CompileSFX: integer;
    function CompileTMB: integer;
    function CompileMSD: integer;
    function CompileP1D: integer;
    function CompileP1S: integer;
    function CompileSVG: integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SongInfoDlg: TSongInfoDlg;

implementation

uses frmSTMainWnd, Assemb, AsmTypes, GrokUtils,
     SFX_Engine, TMB_Engine, MSD_Engine, P1D_Engine, P1S_Engine, SVG_Engine;

{$R *.dfm}

procedure TSongInfoDlg.FormShow(Sender: TObject);
begin
  Screen.Cursor := crHourglass;
  PopulateSongProperties();
  PopulateCompiledLengths();
  Screen.Cursor := crDefault;  
end;

function NoteValToDisplay(iNote: integer): string;
const
  COffset = 6;
begin
  if (iNote < -6) or (iNote >= 255) then
    Result := '---'
  else if (iNote = $82) then
    Result := 'R--'
  else
  begin
    if (iNote > 100) and (iNote < 107) then
      dec(iNote,101)
    else
      inc(iNote,COffset); // 0 now = C, Octave 1
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

procedure TSongInfoDlg.PopulateSongProperties();
var
  i, iPatCount: integer;
  iNote1, iNote2, iCh1, iCh2: integer;
begin
  grdSongProperties.RowCount := 7;
  with grdSongProperties do
  begin
    ColWidths[0] := 200;        ColWidths[1] := 64;
    Cells[0,0] := 'Property';   Cells[1,0] := 'Value';

    Cells[0,1] := 'Unique Patterns in Song';
    iPatCount := 0;
    for i := 0 to 255 do
    begin
      if STMainWnd.Song.IsPatternUsed(i) then Inc(iPatCount);
    end;
    Cells[1,1] := IntToStr(iPatCount);

    Cells[0,2] := 'Length of Song Layout';
    Cells[1,2] := IntToStr(STMainWnd.Song.SongLength);

    Cells[0,3] := 'Lowest note in Channel 1';
    Cells[0,4] := 'Lowest note in Channel 2';
    iNote1 := 255; iNote2 := 255;
    for iPatCount := 0 to STMainWnd.Song.SongLength - 1 do
    begin
      for i := 1 to STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[iPatCount]].Length do
      begin
        iCh1 := STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[iPatCount]].Chan[1][i];
        if (iCh1 > 100) and (iCh1 < 107) then dec(iCh1,107);
        iCh2 := STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[iPatCount]].Chan[2][i];
        if (iCh2 > 100) and (iCh2 < 107) then dec(iCh2,107);

        if iCh1 < iNote1 then
          iNote1 := iCh1;
        if iCh2 < iNote2 then
          iNote2 := iCh2;
      end;
    end;
    Cells[1,3] := NoteValToDisplay(iNote1);
    Cells[1,4] := NoteValToDisplay(iNote2);
      

    Cells[0,5] := 'Highest note in Channel 1';
    Cells[0,6] := 'Highest note in Channel 2';
    iNote1 := -1; iNote2 := -1;
    for iPatCount := 0 to STMainWnd.Song.SongLength - 1 do
    begin
      for i := 1 to STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[iPatCount]].Length do
      begin
        iCh1 := STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[iPatCount]].Chan[1][i];
        if (iCh1 > 100) and (iCh1 < 107) then dec(iCh1,107);
        iCh2 := STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[iPatCount]].Chan[2][i];
        if (iCh2 > 100) and (iCh2 < 107) then dec(iCh2,107);

        if (iCh1 < $80) and
           (iCh1 > iNote1) then
          iNote1 := iCh1;
        if (iCh2 < $80) and
           (iCh2 > iNote2) then
          iNote2 := iCh2;
      end;
    end;
    if iNote1 = -1 then iNote1 := 255;
    if iNote2 = -1 then iNote2 := 255;
    Cells[1,5] := NoteValToDisplay(iNote1);
    Cells[1,6] := NoteValToDisplay(iNote2);
  end;
end;

procedure TSongInfoDlg.PopulateCompiledLengths();
begin
  grdCompiledLength.RowCount := 7;
  with grdCompiledLength do
  begin
    ColWidths[0] := 128;        ColWidths[1] := 128;
    Cells[0,0] := 'Tone Generator';   Cells[1,0] := 'Length (bytes)';

    Cells[0,1] := 'Special FX';
    if (STMainWnd.Song.SongLength < 1) then
      Cells[1,1] := '0'
    else
      Cells[1,1] := IntToStr(CompileSFX());

    Cells[0,2] := 'The Music Box';
    if (STMainWnd.Song.SongLength < 1) then
      Cells[1,2] := '0'
    else
      Cells[1,2] := IntToStr(CompileTMB());

    Cells[0,3] := 'The Music Studio';
    if (STMainWnd.Song.SongLength < 1) then
      Cells[1,3] := '0'
    else
      Cells[1,3] := IntToStr(CompileMSD());

    Cells[0,4] := 'Phaser1, Digital Drums';
    if (STMainWnd.Song.SongLength < 1) then
      Cells[1,4] := '0'
    else
      Cells[1,4] := IntToStr(CompileP1D());

    Cells[0,5] := 'Phaser1, Synth Drums';
    if (STMainWnd.Song.SongLength < 1) then
      Cells[1,5] := '0'
    else
      Cells[1,5] := IntToStr(CompileP1S());

    Cells[0,6] := 'Savage';
    if (STMainWnd.Song.SongLength < 1) then
      Cells[1,6] := '0'
    else
      Cells[1,6] := IntToStr(CompileSVG());
  end;
end;

function TSongInfoDlg.CompileSFX(): integer;
var
  slAsm: TStringList;
  sFilePath, sFileName: string;
begin
  Result := 0;

  slAsm := TStringList.Create();
  slAsm.Add('                ORG 32768');
  SFX_AddPlayerAsm(slAsm,true,1); // Read Keyboard, Loop at end
  slAsm.Add('');
  slAsm.Add('; *** DATA ***');
  slAsm.Add('VECTOR_TABLE_LOC:    EQU $FE00');
  slAsm.Add('BORDER_CLR:          EQU $0');
  SFX_AddFreqTable(slAsm);
  slAsm.Add('');
  SFX_AddSongData(slAsm,STMainWnd.Song,0);

  ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');

  SetLength(sFilePath,255);
  if GetTempPath(255,PChar(sFilePath)) = 0 then exit;

  SetLength(sFileName,255);
  if GetTempFileName(PAnsiChar(sFilePath),'BPO',0,PAnsiChar(sFileName)) = 0 then exit;
  sFileName := Copy(sFileName,1,Pos(#0,sFileName)-1);

  AssembleStringList(slAsm,sFileName,Binary,ASCII);
  Result := STO_GetFileSize(sFileName);

  DeleteFile(sFileName);

  FreeAndNil(slAsm);
end;

function TSongInfoDlg.CompileTMB(): integer;
var
  slAsm: TStringList;
  sFileName, sFilePath: string;
begin
  Result := 0;

  slAsm := TStringList.Create();
  slAsm.Add('                ORG 32768');

  // Loop at song end, return on keypress
  TMB_AddPlayerAsm(slAsm,true,1,STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210);
  slAsm.Add('');
  slAsm.Add('; *** DATA ***');
  slAsm.Add('BORDER_COL:               DEFB $00');
  // We must initialise the tempo for the first pattern in the song
  slAsm.Add('TEMPO:                    DEFB ' + IntToStr(STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210));
  TMB_AddFreqTable(slAsm);
  slAsm.Add('');
  TMB_AddSongData(slAsm,STMainWnd.Song,0);

  ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');

  SetLength(sFilePath,255);
  if GetTempPath(255,PChar(sFilePath)) = 0 then exit;

  SetLength(sFileName,255);
  if GetTempFileName(PAnsiChar(sFilePath),'BPO',0,PAnsiChar(sFileName)) = 0 then exit;
  sFileName := Copy(sFileName,1,Pos(#0,sFileName)-1);

  AssembleStringList(slAsm,sFileName,Binary,ASCII);
  Result := STO_GetFileSize(sFileName);

  DeleteFile(sFileName);

  FreeAndNil(slAsm);
end;

function TSongInfoDlg.CompileMSD(): integer;
var
  slAsm: TStringList;
  sFilePath, sFileName: string;
begin
  Result := 0;

  slAsm := TStringList.Create();
  slAsm.Add('                ORG 32768');
  // Loop at end, return on keypress
  MSD_AddPlayerAsm(slAsm,true,1,64 - STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 3);
  slAsm.Add('');
  slAsm.Add('; *** DATA ***');
  slAsm.Add('BORDER_COL:               DEFB $00');
  // We must initialise the tempo for the first pattern in the song
  slAsm.Add('TEMPO:                    DEFB ' + IntToStr(STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210));
  MSD_AddFreqTable(slAsm);
  slAsm.Add('');
  MSD_AddSongData(slAsm,STMainWnd.Song,0);

  ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');

  SetLength(sFilePath,255);
  if GetTempPath(255,PChar(sFilePath)) = 0 then exit;

  SetLength(sFileName,255);
  if GetTempFileName(PAnsiChar(sFilePath),'BPO',0,PAnsiChar(sFileName)) = 0 then exit;
  sFileName := Copy(sFileName,1,Pos(#0,sFileName)-1);

  AssembleStringList(slAsm,sFileName,Binary,ASCII);
  Result := STO_GetFileSize(sFileName);

  DeleteFile(sFileName);

  FreeAndNil(slAsm);
end;

function TSongInfoDlg.CompileP1D(): integer;
var
  slAsm: TStringList;
  sFilePath, sFileName: string;
begin
  Result := 0;

  slAsm := TStringList.Create();
  slAsm.Add('                ORG 32768');
  slAsm.Add('BORDER_COL:     EQU 0');
  // Loop at end, return on keypress
  P1D_AddPlayerAsm(slAsm,true,1);
  slAsm.Add('');
  slAsm.Add('; *** DATA ***');
  P1D_AddFreqTable(slAsm);
  slAsm.Add('');
  P1D_AddSongData(slAsm,STMainWnd.Song,0);

  ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');

  SetLength(sFilePath,255);
  if GetTempPath(255,PChar(sFilePath)) = 0 then exit;

  SetLength(sFileName,255);
  if GetTempFileName(PAnsiChar(sFilePath),'BPO',0,PAnsiChar(sFileName)) = 0 then exit;
  sFileName := Copy(sFileName,1,Pos(#0,sFileName)-1);

  AssembleStringList(slAsm,sFileName,Binary,ASCII);
  Result := STO_GetFileSize(sFileName);

  DeleteFile(sFileName);

  FreeAndNil(slAsm);
end;

function TSongInfoDlg.CompileP1S(): integer;
var
  slAsm: TStringList;
  sFilePath, sFileName: string;
begin
  Result := 0;

  slAsm := TStringList.Create();
  slAsm.Add('                ORG 32768');
  slAsm.Add('BORDER_COL:     EQU 0');
  // Loop at end, return on keypress
  P1S_AddPlayerAsm(slAsm,true,1);
  slAsm.Add('');
  slAsm.Add('; *** DATA ***');
  P1S_AddFreqTable(slAsm);
  slAsm.Add('');
  P1S_AddSongData(slAsm,STMainWnd.Song,0);

  ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');

  SetLength(sFilePath,255);
  if GetTempPath(255,PChar(sFilePath)) = 0 then exit;

  SetLength(sFileName,255);
  if GetTempFileName(PAnsiChar(sFilePath),'BPO',0,PAnsiChar(sFileName)) = 0 then exit;
  sFileName := Copy(sFileName,1,Pos(#0,sFileName)-1);

  AssembleStringList(slAsm,sFileName,Binary,ASCII);
  Result := STO_GetFileSize(sFileName);

  DeleteFile(sFileName);

  FreeAndNil(slAsm);
end;

function TSongInfoDlg.CompileSVG(): integer;
var
  slAsm: TStringList;
  sFilePath, sFileName: string;
begin
  Result := 0;

  slAsm := TStringList.Create();
  slAsm.Add('                ORG 32768');
  SVG_AddPlayerAsm(slAsm,1); // Read Keyboard, Loop at end
  slAsm.Add('');
  slAsm.Add('; *** DATA ***');
  slAsm.Add('VECTOR_TABLE_LOC:    EQU $FE00');
  slAsm.Add('BORDER_CLR:          EQU $0');
  slAsm.Add('');
  SVG_AddSongData(slAsm,STMainWnd.Song,true,0);

  ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');

  SetLength(sFilePath,255);
  if GetTempPath(255,PChar(sFilePath)) = 0 then exit;

  SetLength(sFileName,255);
  if GetTempFileName(PAnsiChar(sFilePath),'BPO',0,PAnsiChar(sFileName)) = 0 then exit;
  sFileName := Copy(sFileName,1,Pos(#0,sFileName)-1);

  AssembleStringList(slAsm,sFileName,Binary,ASCII);
  Result := STO_GetFileSize(sFileName);

  DeleteFile(sFileName);

  FreeAndNil(slAsm);
end;

end.
