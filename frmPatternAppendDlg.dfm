object PatternAppendDlg: TPatternAppendDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Append Patterns'
  ClientHeight = 138
  ClientWidth = 285
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    285
    138)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 14
    Top = 11
    Width = 97
    Height = 13
    Alignment = taRightJustify
    Caption = '&Destination Pattern:'
    FocusControl = txtPatternNum
  end
  object Label2: TLabel
    Left = 18
    Top = 38
    Width = 93
    Height = 13
    Alignment = taRightJustify
    Caption = 'Pattern to &Append:'
    FocusControl = txtPattern2Num
  end
  object lblP1Length: TLabel
    Left = 176
    Top = 11
    Width = 54
    Height = 13
    Caption = '(Length: 0)'
  end
  object lblP2Length: TLabel
    Left = 176
    Top = 38
    Width = 54
    Height = 13
    Caption = '(Length: 0)'
  end
  object lblLengthErrorMsg: TLabel
    Left = 8
    Top = 68
    Width = 261
    Height = 37
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'The maximum length for a pattern is 126 notes. The destination p' +
      'attern will be truncated to this length.'
    WordWrap = True
  end
  object txtPatternNum: TEdit
    Left = 117
    Top = 8
    Width = 37
    Height = 21
    ReadOnly = True
    TabOrder = 0
    Text = '0'
    OnChange = txtPatternNumChange
  end
  object udnPatternNum: TUpDown
    Left = 154
    Top = 8
    Width = 16
    Height = 21
    Associate = txtPatternNum
    Max = 126
    TabOrder = 1
    OnChangingEx = udnPatternNumChangingEx
  end
  object cmdOK: TButton
    Left = 121
    Top = 105
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 202
    Top = 105
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object txtPattern2Num: TEdit
    Left = 117
    Top = 35
    Width = 37
    Height = 21
    ReadOnly = True
    TabOrder = 4
    Text = '0'
    OnChange = txtPattern2NumChange
  end
  object udnPattern2Num: TUpDown
    Left = 154
    Top = 35
    Width = 16
    Height = 21
    Associate = txtPattern2Num
    Max = 126
    TabOrder = 5
    OnChangingEx = udnPattern2NumChangingEx
  end
end
