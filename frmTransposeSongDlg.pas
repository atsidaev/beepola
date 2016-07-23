unit frmTransposeSongDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TTransposeSongDlg = class(TForm)
    lblTransposeBy: TLabel;
    lblRangeErrorMsg: TLabel;
    cmdOK: TButton;
    cmdCancel: TButton;
    cboTranspose: TComboBox;
    procedure cmdOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cboTransposeClick(Sender: TObject);
  private
    function IsOffScale: boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TransposeSongDlg: TTransposeSongDlg;

implementation

uses frmSTMainWnd;

{$R *.dfm}

function TTransposeSongDlg.IsOffScale(): boolean;
var
  i, iPat, iTrans, iTopNote: integer;
  iCh1, iCh2: integer;
begin
  iTrans := cboTranspose.ItemIndex - 12;
  Result := false;

  if STMainWnd.Song.PreferredEngine = 'TMB' then
    iTopNote := $34
  else if STMainWnd.Song.PreferredEngine = 'SFX' then
    iTopNote := $33
  else if STMainWnd.Song.PreferredEngine = 'MSD' then
    iTopNote := $24
  else if STMainWnd.Song.PreferredEngine = 'P1D' then
    iTopNote := $3B
  else if STMainWnd.Song.PreferredEngine = 'P1S' then
    iTopNote := $3B
  else if STMainWnd.Song.PreferredEngine = 'SVG' then
    iTopNote := $3B
  else
    iTopNote := $33;


  for iPat := 0 to 255 do
  begin
    if STMainWnd.Song.IsPatternUsed(iPat) then
    begin
      for i := 1 to STMainWnd.Song.Pattern[iPat].Length do
      begin
        iCh1 := STMainWnd.Song.Pattern[iPat].Chan[1][i];
        iCh2 := STMainWnd.Song.Pattern[iPat].Chan[2][i];
        if (STMainWnd.Song.PreferredEngine = 'P1D') or
           (STMainWnd.Song.PreferredEngine = 'P1S') or
           (STMainWnd.Song.PreferredEngine = 'SVG') then
        begin
          if (iCh1 <> 255) and (iCh1 <> $82) then
          begin
            inc(iCh1,6);
            if (iCh1 > 106) and (iCh1 < 113) then dec(iCh1,107);
          end;
          if (iCh2 <> 255) and (iCh2 <> $82) then
          begin
            inc(iCh2,6);
            if (iCh2 > 106) and (iCh2 < 113) then dec(iCh2,107);
          end;
        end;
        if (iCh1 <> 255) and
           (iCh1 <> $82) and
          ((iCh1 + iTrans > iTopNote) or
           (iCh1 + iTrans < $0)) then
        begin
          Result := true;
          break;
        end;
        if (iCh2 <> 255) and
           (iCh2 <> $82) and
          ((iCh2 + iTrans > iTopNote) or
           (iCh2 + iTrans < $0)) then
        begin
          Result := true;
          break;
        end;
      end;
    end;
  end;
end;

procedure TTransposeSongDlg.cboTransposeClick(Sender: TObject);
begin
  if IsOffScale then
    lblRangeErrorMsg.Show
  else
    lblRangeErrorMsg.Hide;
end;

procedure TTransposeSongDlg.cmdOKClick(Sender: TObject);
var
  iPat, i, iTrans: integer;
  iCh1, iCh2: integer;
begin
  iTrans := cboTranspose.ItemIndex - 12;

  for iPat := 0 to 255 do
  begin
    if STMainWnd.Song.IsPatternUsed(iPat) then
    begin
      for i := 1 to STMainWnd.Song.Pattern[iPat].Length do
      begin
        iCh1 := STMainWnd.Song.Pattern[iPat].Chan[1][i];
        iCh2 := STMainWnd.Song.Pattern[iPat].Chan[2][i];

        // If channel 1 note is not a rest (255 or $82) then change it by the transposition amount
        if (iCh1 <> 255) and
           (iCh1 <> $82) then
        begin
          inc(iCh1,iTrans);
          if (STMainWnd.Song.PreferredEngine = 'P1D') or
             (STMainWnd.Song.PreferredEngine = 'P1S') or
             (STMainWnd.Song.PreferredEngine = 'SVG') then
          begin
            if (iCh1 >= 107) and (iCh1 <= 119) then
              dec(iCh1,107);

            if (iCh1 < 0) and (iCh1 >= -6) then
              inc(iCh1,107);
          end;
        end;
        // If channel 2 note is not a rest (255 or $82) then change it by the transposition amount
        if (iCh2 <> 255) and
           (iCh2 <> $82) then
        begin
          inc(iCh2,iTrans);
          if (STMainWnd.Song.PreferredEngine = 'P1D') or
             (STMainWnd.Song.PreferredEngine = 'P1S') or
             (STMainWnd.Song.PreferredEngine = 'SVG') then
          begin
            if (iCh2 >= 107) and (iCh2 <= 119) then
              dec(iCh2,107);

            if (iCh2 < 0) and (iCh2 >= -6) then
              inc(iCh2,107);
          end;
        end;

        // If channel 1 note is off-scale then make it a rest
        if (iCh1 < 0) or ((iCh1 > 59) and (iCh1 < 101)) or
           ((iCh1 > 107) and (iCh1 < $80)) then
          iCh1 := 255;
        // If channel 2 note is off-scale then make it a rest
        if (iCh2 < 0) or ((iCh2 > 59) and (iCh2 < 101)) or
           ((iCh2 > 107) and (iCh2 < $80)) then
          iCh2 := 255;

        // If current channel 1 note is not a rest or note-off (255 or $82) then transpose it
        if (STMainWnd.Song.Pattern[iPat].Chan[1][i] <> 255) and
           (STMainWnd.Song.Pattern[iPat].Chan[1][i] <> $82) then
          STMainWnd.Song.Pattern[iPat].Chan[1][i] := iCh1;

        // If current channel 2 note is not a rest or note-off (255 or $82) then transpose it
        if (STMainWnd.Song.Pattern[iPat].Chan[2][i] <> 255) and
           (STMainWnd.Song.Pattern[iPat].Chan[2][i] <> $82) then
          STMainWnd.Song.Pattern[iPat].Chan[2][i] := iCh2;
      end;
    end;
  end;

  Self.ModalResult := mrOK;
end;

procedure TTransposeSongDlg.FormShow(Sender: TObject);
begin
  cboTranspose.ItemIndex := 12;
  lblRangeErrorMsg.Hide;
end;

end.
