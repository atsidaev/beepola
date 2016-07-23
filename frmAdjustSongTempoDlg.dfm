object AdjustSongTempoDlg: TAdjustSongTempoDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Adjust Song Tempo'
  ClientHeight = 149
  ClientWidth = 311
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
    311
    149)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 14
    Width = 140
    Height = 13
    Alignment = taRightJustify
    Caption = 'Adjust all pattern &tempos by:'
  end
  object lblRangeErrorMsg: TLabel
    Left = 12
    Top = 47
    Width = 273
    Height = 66
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Adjusting the song tempo by this much will cause one or more pat' +
      'terns to exceed the supported range. These patterns will have th' +
      'eir tempos adjusted to the limit of the supported range only.'
    WordWrap = True
  end
  object cmdOK: TButton
    Left = 147
    Top = 116
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOKClick
    ExplicitTop = 163
  end
  object cmdCancel: TButton
    Left = 228
    Top = 116
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitTop = 163
  end
  object cboAdjust: TComboBox
    Left = 158
    Top = 11
    Width = 99
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    OnClick = cboAdjustClick
    Items.Strings = (
      '-10'
      '-9'
      '-8'
      '-7'
      '-6'
      '-5'
      '-4'
      '-3'
      '-2'
      '-1'
      'None'
      '+1'
      '+2'
      '+3'
      '+4'
      '+5'
      '+6'
      '+7'
      '+8'
      '+9'
      '+10')
  end
end
