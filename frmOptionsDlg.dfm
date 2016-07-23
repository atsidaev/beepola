object OptionsDlg: TOptionsDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 246
  ClientWidth = 383
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
    383
    246)
  PixelsPerInch = 96
  TextHeight = 13
  object cmdOK: TButton
    Left = 219
    Top = 213
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOKClick
    ExplicitLeft = 139
    ExplicitTop = 136
  end
  object cmdCancel: TButton
    Left = 300
    Top = 213
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 220
    ExplicitTop = 136
  end
  object pgOptions: TPageControl
    Left = 8
    Top = 8
    Width = 368
    Height = 198
    ActivePage = tsEditor
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object tsEditor: TTabSheet
      Caption = '&Editor'
      ExplicitLeft = 14
      ExplicitWidth = 425
      ExplicitHeight = 226
      DesignSize = (
        360
        170)
      object chkSongLayoutColNumbers: TCheckBox
        Left = 28
        Top = 14
        Width = 231
        Height = 21
        Caption = 'Show &column numbers in song layout area'
        TabOrder = 0
      end
      object GroupBox1: TGroupBox
        Left = 8
        Top = 47
        Width = 340
        Height = 72
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Pattern Editor'
        TabOrder = 1
        ExplicitWidth = 405
        object optPatternRowDec: TRadioButton
          Left = 20
          Top = 18
          Width = 191
          Height = 21
          Caption = 'Display row numbers in Decimal'
          TabOrder = 0
        end
        object optPatternRowHex: TRadioButton
          Left = 20
          Top = 41
          Width = 191
          Height = 19
          Caption = 'Display row numbers in Hexadecimal'
          TabOrder = 1
        end
      end
    end
  end
end
