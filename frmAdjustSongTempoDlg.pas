unit frmAdjustSongTempoDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TAdjustSongTempoDlg = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    Label1: TLabel;
    lblRangeErrorMsg: TLabel;
    cboAdjust: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure cboAdjustClick(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
  private
    function IsOffScale: boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AdjustSongTempoDlg: TAdjustSongTempoDlg;

implementation

{$R *.dfm}

uses frmSTMainWnd;

function TAdjustSongTempoDlg.IsOffScale(): boolean;
var
  iLowest, iHighest, iPat: integer;
  iAdjust: integer;
begin
  Result := false;
  
  iLowest := 21; iHighest := 0;

  for iPat := 0 to 255 do
  begin
    if STMainWnd.Song.IsPatternUsed(iPat) then
    begin
      if STMainWnd.Song.Pattern[iPat].Tempo < iLowest then
        iLowest := STMainWnd.Song.Pattern[iPat].Tempo;

      if STMainWnd.Song.Pattern[iPat].Tempo > iHighest then
        iHighest := STMainWnd.Song.Pattern[iPat].Tempo;
    end;
  end;

  iAdjust := cboAdjust.ItemIndex - 10;
  if (iLowest + iAdjust) < 1 then Result := true;
  if (iHighest + iAdjust) > 20 then Result := true;
end;


procedure TAdjustSongTempoDlg.cboAdjustClick(Sender: TObject);
begin
  if IsOffScale() then
    lblRangeErrorMsg.Show
  else
    lblRangeErrorMsg.Hide;
end;

procedure TAdjustSongTempoDlg.cmdOKClick(Sender: TObject);
var
  iPat, i: integer;
begin
  for iPat := 0 to 255 do
  begin
    if STMainWnd.Song.IsPatternUsed(iPat) then
    begin
      i := STMainWnd.Song.Pattern[iPat].Tempo + (cboAdjust.ItemIndex - 10);
      if i < 1 then i := 1;
      if i > 20 then i := 20;

      STMainWnd.Song.Pattern[iPat].Tempo := i;
    end;
  end;

  Self.ModalResult := mrOK;
end;

procedure TAdjustSongTempoDlg.FormShow(Sender: TObject);
begin
  cboAdjust.ItemIndex := 10;
  lblRangeErrorMsg.Hide;
end;

end.
