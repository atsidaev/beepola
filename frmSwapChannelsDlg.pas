unit frmSwapChannelsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TSwapChannelsDlg = class(TForm)
    Label1: TLabel;
    txtPatternNum: TEdit;
    udnPatternNum: TUpDown;
    cmdOK: TButton;
    cmdCancel: TButton;
    procedure cmdOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SwapChannelsDlg: TSwapChannelsDlg;

implementation

uses frmSTMainWnd;

{$R *.dfm}

procedure TSwapChannelsDlg.cmdOKClick(Sender: TObject);
var
  i: integer;
  cSwap, cSwapSus: byte;
  iSwapSVG: integer;
begin
  STMainWnd.UndoPattern := STMainWnd.Song.Pattern[udnPatternNum.Position];
  STMainWnd.UndoSvgPattern := STMainWnd.Song.SvgPatternData[udnPatternNum.Position];

  for i := 1 to STMainWnd.Song.Pattern[udnPatternNum.Position].Length do
  begin
    cSwap := STMainWnd.Song.Pattern[udnPatternNum.Position].Chan[1][i];
    cSwapSus := STMainWnd.Song.Pattern[udnPatternNum.Position].Sustain[1][i];

    STMainWnd.Song.Pattern[udnPatternNum.Position].Chan[1][i] :=
                  STMainWnd.Song.Pattern[udnPatternNum.Position].Chan[2][i];

    STMainWnd.Song.Pattern[udnPatternNum.Position].Chan[2][i] := cSwap;

    // SVG Glis
    iSwapSVG := STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Glissando[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Glissando[1][i] :=
         STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Glissando[2][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Glissando[2][i] := iSwapSVG;
    // SVG Skew
    iSwapSVG := STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Skew[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Skew[1][i] :=
         STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Skew[2][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Skew[2][i] := iSwapSVG;
    // SVG SkewXOR
    iSwapSVG := STMainWnd.Song.SvgPatternData[udnPatternNum.Position].SkewXOR[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].SkewXOR[1][i] :=
         STMainWnd.Song.SvgPatternData[udnPatternNum.Position].SkewXOR[2][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].SkewXOR[2][i] := iSwapSVG;
    // SVG Arp
    iSwapSVG := STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Arpeggio[1][i] :=
         STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Arpeggio[2][i] := iSwapSVG;
    // SVG FX
    iSwapSVG := STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Warp[1][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Warp[1][i] :=
         STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Warp[2][i];
    STMainWnd.Song.SvgPatternData[udnPatternNum.Position].Warp[2][i] := iSwapSVG;

    if (STMainWnd.Song.PreferredEngine <> 'P1S') and
       (STMainWnd.Song.PreferredEngine <> 'P1D') then
    begin
      STMainWnd.Song.Pattern[udnPatternNum.Position].Sustain[1][i] :=
                  STMainWnd.Song.Pattern[udnPatternNum.Position].Sustain[2][i];

      STMainWnd.Song.Pattern[udnPatternNum.Position].Sustain[2][i] := cSwapSus;
    end;
  end;

  Self.ModalResult := mrOK;
end;

end.
