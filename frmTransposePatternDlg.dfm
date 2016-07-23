object TransposePatternDlg: TTransposePatternDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Transpose Pattern'
  ClientHeight = 144
  ClientWidth = 263
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
    263
    144)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTransposeBy: TLabel
    Left = 16
    Top = 38
    Width = 69
    Height = 13
    Alignment = taRightJustify
    Caption = '&Transpose by:'
    FocusControl = cboTranspose
  end
  object Label1: TLabel
    Left = 45
    Top = 11
    Width = 40
    Height = 13
    Alignment = taRightJustify
    Caption = '&Pattern:'
    FocusControl = txtPatternNum
  end
  object lblRangeErrorMsg: TLabel
    Left = 8
    Top = 62
    Width = 247
    Height = 43
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Transposing the pattern by this much will cause one or more note' +
      's to fall outside of the supported range. These notes will be re' +
      'placed by rests.'
    WordWrap = True
  end
  object cmdOK: TButton
    Left = 99
    Top = 111
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 180
    Top = 111
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object cboTranspose: TComboBox
    Left = 91
    Top = 35
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 12
    TabOrder = 4
    Text = 'None'
    OnChange = cboTransposeChange
    OnClick = cboTransposeClick
    Items.Strings = (
      '-1 octave'
      '-11 semitones'
      '-10 semitones'
      '-9 semitones'
      '-8 semitones'
      '-7 semitones'
      '-6 semitones'
      '-5 semitones'
      '-4 semitones'
      '-3 semitones'
      '-2 semitones'
      '-1 semitone'
      'None'
      '+1 semitone'
      '+2 semitones'
      '+3 semitones'
      '+4 semitones'
      '+5 semitones'
      '+6 semitones'
      '+7 semitones'
      '+8 semitones'
      '+9 semitones'
      '+10 semitones'
      '+11 semitones'
      '+1 octave')
  end
  object txtPatternNum: TEdit
    Left = 91
    Top = 8
    Width = 37
    Height = 21
    ReadOnly = True
    TabOrder = 2
    Text = '0'
    OnChange = txtPatternNumChange
  end
  object udnPatternNum: TUpDown
    Left = 128
    Top = 8
    Width = 16
    Height = 21
    Associate = txtPatternNum
    Max = 126
    TabOrder = 3
  end
end
