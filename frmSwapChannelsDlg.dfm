object SwapChannelsDlg: TSwapChannelsDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Swap Channel Data'
  ClientHeight = 81
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    234
    81)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 45
    Top = 11
    Width = 40
    Height = 13
    Alignment = taRightJustify
    Caption = '&Pattern:'
    FocusControl = txtPatternNum
  end
  object txtPatternNum: TEdit
    Left = 91
    Top = 8
    Width = 37
    Height = 21
    ReadOnly = True
    TabOrder = 0
    Text = '0'
  end
  object udnPatternNum: TUpDown
    Left = 128
    Top = 8
    Width = 16
    Height = 21
    Associate = txtPatternNum
    Max = 126
    TabOrder = 1
  end
  object cmdOK: TButton
    Left = 70
    Top = 48
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 151
    Top = 48
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
