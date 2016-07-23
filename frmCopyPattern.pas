unit frmCopyPattern;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TCopyPatternDlg = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    lblCopyTo: TLabel;
    txtDest: TEdit;
    udnDest: TUpDown;
    Label1: TLabel;
    txtSource: TEdit;
    udnSource: TUpDown;
    lblOverwriteMsg: TLabel;
    GroupBox1: TGroupBox;
    chkChan1: TCheckBox;
    chkChan2: TCheckBox;
    chkDrums: TCheckBox;
    procedure udnDestClick(Sender: TObject; Button: TUDBtnType);
    procedure FormShow(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CopyPatternDlg: TCopyPatternDlg;

implementation

uses frmSTMainWnd;

{$R *.dfm}

procedure TCopyPatternDlg.cmdOKClick(Sender: TObject);
var
  i: Integer;
begin
  STMainWnd.Song.Pattern[udnDest.Position].Length :=   STMainWnd.Song.Pattern[udnSource.Position].Length;
  STMainWnd.Song.Pattern[udnDest.Position].Tempo :=   STMainWnd.Song.Pattern[udnSource.Position].Tempo;
  STMainWnd.Song.Pattern[udnDest.Position].Name :=   STMainWnd.Song.Pattern[udnSource.Position].Name;

  for i := 1 to STMainWnd.Song.Pattern[udnSource.Position].Length do
  begin
    if chkChan1.Checked then
    begin
      STMainWnd.Song.Pattern[udnDest.Position].Chan[1][i] := STMainWnd.Song.Pattern[udnSource.Position].Chan[1][i];
      STMainWnd.Song.Pattern[udnDest.Position].Sustain[1][i] := STMainWnd.Song.Pattern[udnSource.Position].Sustain[1][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].Glissando[1][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].Glissando[1][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].Skew[1][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].Skew[1][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].SkewXOR[1][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].SkewXOR[1][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].Arpeggio[1][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].Arpeggio[1][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].Warp[1][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].Warp[1][i];
    end;
    if chkChan2.Checked then
    begin
      STMainWnd.Song.Pattern[udnDest.Position].Chan[2][i] := STMainWnd.Song.Pattern[udnSource.Position].Chan[2][i];
      STMainWnd.Song.Pattern[udnDest.Position].Sustain[2][i] := STMainWnd.Song.Pattern[udnSource.Position].Sustain[2][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].Glissando[2][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].Glissando[2][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].Skew[2][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].Skew[2][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].SkewXOR[2][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].SkewXOR[2][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].Arpeggio[2][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].Arpeggio[2][i];
      STMainWnd.Song.SvgPatternData[udnDest.Position].Warp[2][i] := STMainWnd.Song.SvgPatternData[udnSource.Position].Warp[2][i];
    end;
    if chkDrums.Checked then
      STMainWnd.Song.Pattern[udnDest.Position].Drum[i] := STMainWnd.Song.Pattern[udnSource.Position].Drum[i];
  end;

  STMainWnd.udnPatternNum.Position := udnDest.Position;
  STMainWnd.txtPatternNumChange(nil);
  Self.ModalResult := mrOK;
end;

procedure TCopyPatternDlg.FormShow(Sender: TObject);
begin
  if not (STMainWnd.Song.IsPatternEmpty(udnDest.Position)) then
  begin
    lblOverwriteMsg.Caption := 'The destination pattern, ' + IntToStr(udnDest.Position) + ', already contains data which will be overwritten if you select OK.';
    lblOverwriteMsg.Show
  end
  else
    lblOverwriteMsg.Hide;
end;

procedure TCopyPatternDlg.udnDestClick(Sender: TObject; Button: TUDBtnType);
begin
  if not (STMainWnd.Song.IsPatternEmpty(udnDest.Position)) then
  begin
    lblOverwriteMsg.Caption := 'The destination pattern, ' + IntToStr(udnDest.Position) + ', already contains data which will be overwritten if you select OK.';
    lblOverwriteMsg.Show
  end
  else
    lblOverwriteMsg.Hide;
end;

end.
