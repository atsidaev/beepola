object TransposeSongDlg: TTransposeSongDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Transpose Song'
  ClientHeight = 131
  ClientWidth = 289
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
    289
    131)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTransposeBy: TLabel
    Left = 16
    Top = 11
    Width = 69
    Height = 13
    Alignment = taRightJustify
    Caption = '&Transpose by:'
    FocusControl = cboTranspose
  end
  object lblRangeErrorMsg: TLabel
    Left = 8
    Top = 35
    Width = 273
    Height = 43
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Transposing the song by this much will cause one or more notes t' +
      'o fall outside of the supported range. These notes will be repla' +
      'ced by rests.'
    WordWrap = True
    ExplicitWidth = 263
  end
  object cmdOK: TButton
    Left = 125
    Top = 98
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 206
    Top = 98
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
    Top = 8
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 12
    TabOrder = 2
    Text = 'None'
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
end
