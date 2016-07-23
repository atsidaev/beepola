unit frmImportVTIIFileDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, INIFiles;

type
  TImportVTIIFileDlg = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    cboExcludeChan: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    lblSongTitle: TLabel;
    lblSongAuthor: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
  private
    { Private declarations }
    INI: TINIFile;
    iVTSpeed: integer;
    function ImportSongLayout: boolean;
    function ReadPatterns: boolean;
    function ReadPattern(iPat: integer): boolean;
  public
    { Public declarations }
    sFile: string;
  end;

var
  ImportVTIIFileDlg: TImportVTIIFileDlg;

implementation

{$R *.dfm}

uses frmSTMainWnd;

var
  F: TextFile;

function TImportVTIIFileDlg.ImportSongLayout(): boolean;
var
  s,t: string;
  i,j: integer;
begin
  s := Trim(INI.ReadString('Module','PlayOrder',''));
  iVTSpeed := INI.ReadInteger('Module','Speed',4);

  i := 0;
  while (s <> '') do
  begin
    if (Pos(',',s) > 0) then
    begin
      t := Copy(s,1,Pos(',',s)-1);
      s := Copy(s,Pos(',',s)+1,2048);
    end
    else
    begin
      t := s;
      s := '';
    end;
    if t[1] = 'L' then
    begin
      STMainWnd.Song.LoopStart := i;
      t := Copy(t,2,10);
    end;

    j := StrToIntDef(t,-1);

    if (j >= 0) and (j <= 126) then
    begin
      STMainWnd.Song.SongLayout[i] := j;
      inc(i);
    end;
  end;

  Result := true;
end;

function DisplayToNoteVal(s: string): integer;
begin
  s := UpperCase(s);
  if s = '---' then
    Result := 255
  else if s = 'R--' then
    Result := $82
  else
  begin
    if Copy(s,1,2) = 'C-' then
      Result := 0
    else if Copy(s,1,2) = 'C#' then
      Result := 1
    else if Copy(s,1,2) = 'D-' then
      Result := 2
    else if Copy(s,1,2) = 'D#' then
      Result := 3
    else if Copy(s,1,2) = 'E-' then
      Result := 4
    else if Copy(s,1,2) = 'F-' then
      Result := 5
    else if Copy(s,1,2) = 'F#' then
      Result := 6
    else if Copy(s,1,2) = 'G-' then
      Result := 7
    else if Copy(s,1,2) = 'G#' then
      Result := 8
    else if Copy(s,1,2) = 'A-' then
      Result := 9
    else if Copy(s,1,2) = 'A#' then
      Result := 10
    else if Copy(s,1,2) = 'B-' then
      Result := 11
    else
      Result := 0;

    Result := Result + ((StrToIntDef(s[3],1)-1) * 12);
    if (Result < 0) or (Result > 59) then
      Result := 255 // Note out of range, remove it
    else
    begin
      dec(Result,6);
      if Result < 0 then inc(Result,107);
    end;
  end;

end;

function GetNoteValues(s: string; var iCh1: integer;
                                  var iCh2: integer;
                                  var iCh3: integer): boolean;
begin
  result := false;
  if Length(s) <> 49 then exit;
  if (s[5] <> '|') or (s[8] <> '|') or (s[22] <> '|') or (s[36] <> '|') then exit;
  if (s[12] <> ' ') or (s[17] <> ' ') or (s[26] <> ' ') or (s[31] <> ' ') or (s[40] <> ' ') or (s[45] <> ' ') then exit;

  iCh1 := DisplayToNoteVal(Copy(s,9,3));
  iCh2 := DisplayToNoteVal(Copy(s,23,3));
  iCh3 := DisplayToNoteVal(Copy(s,37,3));
end;

function TImportVTIIFileDlg.ReadPattern(iPat: integer): boolean;
var
  s: string;
  i, iCh1, iCh2, iCh3: integer;
begin
  i := 1;

  while (i <= 126) do
  begin
    ReadLn(F,s);
    if s = '' then break;

    GetNoteValues(s,iCh1,iCh2,iCh3);
    if cboExcludeChan.ItemIndex = 0 then
    begin
      STMainWnd.Song.Pattern[iPat].Chan[1][i] := iCh2;
      STMainWnd.Song.Pattern[iPat].Chan[2][i] := iCh3;
    end
    else if cboExcludeChan.ItemIndex = 1 then
    begin
      STMainWnd.Song.Pattern[iPat].Chan[1][i] := iCh1;
      STMainWnd.Song.Pattern[iPat].Chan[2][i] := iCh3;
    end
    else if cboExcludeChan.ItemIndex = 2 then
    begin
      STMainWnd.Song.Pattern[iPat].Chan[1][i] := iCh1;
      STMainWnd.Song.Pattern[iPat].Chan[2][i] := iCh2;
    end;
    inc(i);
  end;

  STMainWnd.Song.Pattern[iPat].Length := i-1;

  case iVTSpeed of
  0,1,2:
    STMainWnd.Song.Pattern[iPat].Tempo := 16;
  3,4:
    STMainWnd.Song.Pattern[iPat].Tempo := 15;
  5,6,7:
    STMainWnd.Song.Pattern[iPat].Tempo := 14;
  8,9:
    STMainWnd.Song.Pattern[iPat].Tempo := 13;
  10,11:
    STMainWnd.Song.Pattern[iPat].Tempo := 12;
  12,13:
    STMainWnd.Song.Pattern[iPat].Tempo := 11;
  else
    STMainWnd.Song.Pattern[iPat].Tempo := 10;  
  end;

  Result := true;
end;

function TImportVTIIFileDlg.ReadPatterns(): boolean;
var
  s: string;
  iPatNum: integer;
begin
  AssignFile(F,sFile);
  Reset(F);
  while not EOF(F) do
  begin
    ReadLn(F,s);
    if LowerCase(Copy(s,1,8)) = '[pattern' then
    begin
      iPatNum := StrToIntDef(Copy(s,9,Pos(']',s)-9),-1);
      if (iPatNum >= 0) and (iPatNum <= 126) then
      begin
        ReadPattern(iPatNum);
      end;
    end;
  end;
  CloseFile(F);
  Result := true;
end;

procedure TImportVTIIFileDlg.cmdOKClick(Sender: TObject);
begin
  STMainWnd.Song.SongTitle := lblSongTitle.Caption;
  STMainWnd.Song.SongAuthor := lblSongAuthor.Caption;
  ImportSongLayout();
  FreeAndNil(INI);
  ReadPatterns();

  ModalResult := mrOK;
end;

procedure TImportVTIIFileDlg.FormHide(Sender: TObject);
begin
  FreeAndNil(INI);
end;

procedure TImportVTIIFileDlg.FormShow(Sender: TObject);
begin
  INI := TINIFile.Create(sFile);

  lblSongTitle.Caption := INI.ReadString('Module','Title','');
  lblSongAuthor.Caption := INI.ReadString('Module','Author','');
end;

end.
