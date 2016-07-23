unit frmPatternAppendDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TPatternAppendDlg = class(TForm)
    Label1: TLabel;
    txtPatternNum: TEdit;
    udnPatternNum: TUpDown;
    cmdOK: TButton;
    cmdCancel: TButton;
    Label2: TLabel;
    txtPattern2Num: TEdit;
    udnPattern2Num: TUpDown;
    lblP1Length: TLabel;
    lblP2Length: TLabel;
    lblLengthErrorMsg: TLabel;
    procedure udnPatternNumChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Smallint; Direction: TUpDownDirection);
    procedure udnPattern2NumChangingEx(Sender: TObject;
      var AllowChange: Boolean; NewValue: Smallint;
      Direction: TUpDownDirection);
    procedure FormShow(Sender: TObject);
    procedure txtPatternNumChange(Sender: TObject);
    procedure txtPattern2NumChange(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
  private
    procedure UpdateLengthErrMsg;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PatternAppendDlg: TPatternAppendDlg;

implementation

uses frmSTMainWnd;

{$R *.dfm}

procedure TPatternAppendDlg.cmdOKClick(Sender: TObject);
var
  i: integer;
begin
  STMainWnd.UndoPattern := STMainWnd.Song.Pattern[udnPatternNum.Position];
  STMainWnd.UndoSvgPattern := STMainWnd.Song.SvgPatternData[udnPatternNum.Position];

  i := STMainWnd.Song.Pattern[udnPatternNum.Position].Length +
                 STMainWnd.Song.Pattern[udnPattern2Num.Position].Length;
  if (i > 126) then i := 126;
  STMainWnd.Song.Pattern[udnPatternNum.Position].Length := i;

  for i := 1 to STMainWnd.Song.Pattern[udnPattern2Num.Position].Length do
  begin
    STMainWnd.Song.Pattern[udnPatternNum.Position].Chan[1][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.Pattern[udnPattern2Num.Position].Chan[1][i];

    STMainWnd.Song.Pattern[udnPatternNum.Position].Chan[2][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.Pattern[udnPattern2Num.Position].Chan[2][i];

    STMainWnd.Song.Pattern[udnPatternNum.Position].Sustain[1][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.Pattern[udnPattern2Num.Position].Sustain[1][i];

    STMainWnd.Song.Pattern[udnPatternNum.Position].Sustain[2][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.Pattern[udnPattern2Num.Position].Sustain[2][i];

    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Glissando[1][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].Glissando[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Glissando[2][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].Glissando[2][i];

    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Skew[1][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].Skew[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Skew[2][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].Skew[2][i];

    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].SkewXOR[1][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].SkewXOR[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].SkewXOR[2][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].SkewXOR[2][i];

    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].Arpeggio[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].Arpeggio[2][i];

    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Warp[1][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].Warp[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Warp[2][i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.SvgPatternData[udnPattern2Num.Position].Warp[2][i];

    STMainWnd.Song.Pattern[udnPatternNum.Position].Drum[i + STMainWnd.UndoPattern.Length] :=
              STMainWnd.Song.Pattern[udnPattern2Num.Position].Drum[i];
  end;

  Self.ModalResult := mrOK;
end;

procedure TPatternAppendDlg.FormShow(Sender: TObject);
var
  x: boolean;
begin
  udnPatternNumChangingEx(udnPatternNum,x,udnPatternNum.Position,updNone);
  udnPattern2NumChangingEx(udnPattern2Num,x,udnPattern2Num.Position,updNone);
  UpdateLengthErrMsg();
end;

procedure TPatternAppendDlg.txtPattern2NumChange(Sender: TObject);
begin
  UpdateLengthErrMsg();
end;

procedure TPatternAppendDlg.txtPatternNumChange(Sender: TObject);
begin
  UpdateLengthErrMsg();
end;

procedure TPatternAppendDlg.udnPattern2NumChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
begin
  if (NewValue < 0) or (NewValue > 126) then
    AllowChange := false
  else
  begin
    AllowChange := true;
    lblP2Length.Caption := '(Length: ' + IntToStr(STMainWnd.Song.Pattern[NewValue].Length) + ')';
  end;
end;

procedure TPatternAppendDlg.udnPatternNumChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
begin
  if (NewValue < 0) or (NewValue > 126) then
    AllowChange := false
  else
  begin
    AllowChange := true;
    lblP1Length.Caption := '(Length: ' + IntToStr(STMainWnd.Song.Pattern[NewValue].Length) + ')';
  end;
end;

procedure TPatternAppendDlg.UpdateLengthErrMsg();
begin
  if (STMainWnd.Song.Pattern[udnPatternNum.Position].Length +
      STMainWnd.Song.Pattern[udnPattern2Num.Position].Length) > 126 then
    lblLengthErrorMsg.Show
  else
    lblLengthErrorMsg.Hide;
end;

end.
