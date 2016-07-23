unit frmSongRipper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SongRipper, Mask, JvExMask, JvToolEdit, Grids;

type
  TSongRipperDlg = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    filSpecFile: TJvFilenameEdit;
    Label1: TLabel;
    grdSongList: TStringGrid;
    lblDefLen: TLabel;
    cboDefLen: TComboBox;
    Label2: TLabel;
    txtSVGRip: TEdit;
    cmdSVGRip: TButton;
    procedure FormShow(Sender: TObject);
    procedure filSpecFileChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure grdSongListSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cmdSVGRipClick(Sender: TObject);
  private
    { Private declarations }
    Rip: TSongRipper;
    procedure SetConvertButton;
  public
    { Public declarations }
  end;

var
  SongRipperDlg: TSongRipperDlg;

implementation

uses frmSTMainWnd;

{$R *.dfm}

procedure TSongRipperDlg.SetConvertButton();
begin
  if (grdSongList.Row >= 1) and (grdSongList.Cells[1,grdSongList.Row] <> '') then
    cmdOK.Enabled := true
  else
    cmdOK.Enabled := false;
end;


procedure TSongRipperDlg.cmdOKClick(Sender: TObject);
var
  iDefPatLen, iRet: integer;
begin
  SetConvertButton();

  if StrToIntDef(grdSongList.Cells[1,grdSongList.Row],0) <= 0 then
    exit;

  if STMainWnd.bSongDirty then
  begin
    iRet :=  Application.MessageBox('Do you want to save changes to the current song?',
                            PAnsiChar(Application.Title),
                            MB_YESNOCANCEL or MB_DEFBUTTON3 or MB_ICONQUESTION);
    if iRet = ID_YES then
    begin
      if STMainWnd.sFileName <> '' then
        STMainWnd.mnuFileSaveClick(nil)
      else
        STMainWnd.mnuFileSaveAsClick(nil);

      if STMainWnd.bSongDirty then exit; // Failed to save file or Save Cancelled
    end
    else if iRet = ID_CANCEL then exit;
  end;

  iDefPatLen := StrToIntDef(cboDefLen.Text,16);
  if (iDefPatLen < 2) then iDefPatLen := 2;
  if (iDefPatLen > 126) then iDefPatLen := 126;

  Rip.ConvertSong(grdSongList.Row-1,iDefPatLen);
  STMainWnd.Song.SongTitle := Copy(ExtractFileName(filSpecFile.FileName),1,Length(ExtractFileName(filSpecFile.FileName))-4);;
  STMainWnd.Song.SongAuthor := 'Ripped by Beepola';

  Self.ModalResult := mrOK;
end;

procedure TSongRipperDlg.cmdSVGRipClick(Sender: TObject);
var
  iRet: integer;
begin
  if STMainWnd.bSongDirty then
  begin
    iRet :=  Application.MessageBox('Do you want to save changes to the current song?',
                            PAnsiChar(Application.Title),
                            MB_YESNOCANCEL or MB_DEFBUTTON3 or MB_ICONQUESTION);
    if iRet = ID_YES then
    begin
      if STMainWnd.sFileName <> '' then
        STMainWnd.mnuFileSaveClick(nil)
      else
        STMainWnd.mnuFileSaveAsClick(nil);

      if STMainWnd.bSongDirty then exit; // Failed to save file or Save Cancelled
    end
    else if iRet = ID_CANCEL then exit;
  end;

  //Rip.ConvertSVGSong(StrToIntDef(txtSVGRip.Text,0),64);
  STMainWnd.Song.SongTitle := Copy(ExtractFileName(filSpecFile.FileName),1,Length(ExtractFileName(filSpecFile.FileName))-4);;
  STMainWnd.Song.SongAuthor := 'Ripped by Beepola';
end;

procedure TSongRipperDlg.filSpecFileChange(Sender: TObject);
var
  i, iRet: Integer;
  sMsg: string;
begin
  if (filSpecFile.FileName = '') or not FileExists(filSpecFile.FileName) then 
   exit;

  if LowerCase(ExtractFileExt(filSpecFile.FileName))  = '.tap' then
    iRet := Rip.LoadTAP(filSpecFile.FileName)
  else if LowerCase(ExtractFileExt(filSpecFile.FileName))  = '.z80' then
    iRet := Rip.LoadZ80(filSpecFile.FileName)
  else
    iRet := -1;

   
  if(iRet < 0) then
  begin
    sMsg := 'Failed to load file: ' + filSpecFile.FileName;
    if LowerCase(ExtractFileExt(filSpecFile.FileName))  = '.tap' then
      sMsg := sMsg + #13#10#13#10 + 'For the best results, save a Z80 snapshot of the game during music playback using an emulator.';

    Application.MessageBox(PAnsiChar(sMsg),
                           PAnsiChar(Application.Title),
                           MB_OK or MB_ICONEXCLAMATION);
  end
  else
  begin
    if Rip.Scan = 0 then
    begin
      grdSongList.RowCount := 2;
      grdSongList.Cells[0,1] := '';
      grdSongList.Cells[1,1] := '';
    end
    else
    begin
      grdSongList.RowCount := Rip.SongCount + 1;

      for i := 0 to Rip.SongCount - 1 do
      begin
        grdSongList.Cells[0,i+1] := Rip.SongDataTypeString[i];
        grdSongList.Cells[1,i+1] := IntToStr(Rip.SongLocation[i]);
      end;
    end;
  end;

  SetConvertButton();
end;

procedure TSongRipperDlg.FormHide(Sender: TObject);
begin
  FreeAndNil(Rip);
end;

procedure TSongRipperDlg.FormShow(Sender: TObject);
begin
  filSpecFile.FileName := '';
  filSpecFile.Text := '';
  
  grdSongList.ColCount := 2;
  grdSongList.RowCount := 2;

  grdSongList.Cells[0,0] := 'Song Data Type';
  grdSongList.Cells[1,0] := 'Location';
  grdSongList.ColWidths[0] := 240;
  grdSongList.ColWidths[1] := 64;
  grdSongList.Cells[0,1] := '';
  grdSongList.Cells[1,1] := '';

  FreeAndNil(Rip);
  Rip := TSongRipper.Create();

  SetConvertButton();  
end;

procedure TSongRipperDlg.grdSongListSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  SetConvertButton();
end;

end.
