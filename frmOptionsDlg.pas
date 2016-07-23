unit frmOptionsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TOptionsDlg = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    pgOptions: TPageControl;
    tsEditor: TTabSheet;
    chkSongLayoutColNumbers: TCheckBox;
    GroupBox1: TGroupBox;
    optPatternRowDec: TRadioButton;
    optPatternRowHex: TRadioButton;
    procedure FormShow(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsDlg: TOptionsDlg;

implementation

uses frmSTMainWnd;

{$R *.dfm}

procedure TOptionsDlg.cmdOKClick(Sender: TObject);
begin
   STMainWnd.RegSettings.ShowLayoutColNumbers := chkSongLayoutColNumbers.Checked;
   STMainWnd.RegSettings.PatternRowNumbersHex := optPatternRowHex.Checked;
   STMainWnd.RegSettings.SaveSettings;

   ModalResult := mrOK;
end;

procedure TOptionsDlg.FormShow(Sender: TObject);
begin
  chkSongLayoutColNumbers.Checked := STMainWnd.RegSettings.ShowLayoutColNumbers;
  if STMainWnd.RegSettings.PatternRowNumbersHex then
    optPatternRowHex.Checked := true
  else
    optPatternRowDec.Checked := true;
end;

end.
