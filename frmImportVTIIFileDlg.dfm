object ImportVTIIFileDlg: TImportVTIIFileDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Import VTII Text File'
  ClientHeight = 211
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    320
    211)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 38
    Top = 12
    Width = 24
    Height = 13
    Alignment = taRightJustify
    Caption = 'Title:'
  end
  object Label3: TLabel
    Left = 25
    Top = 28
    Width = 37
    Height = 13
    Alignment = taRightJustify
    Caption = 'Author:'
  end
  object lblSongTitle: TLabel
    Left = 68
    Top = 12
    Width = 25
    Height = 13
    Caption = 'None'
  end
  object lblSongAuthor: TLabel
    Left = 68
    Top = 28
    Width = 25
    Height = 13
    Caption = 'None'
  end
  object cmdOK: TButton
    Left = 156
    Top = 178
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOKClick
    ExplicitLeft = 264
    ExplicitTop = 259
  end
  object cmdCancel: TButton
    Left = 237
    Top = 178
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 345
    ExplicitTop = 259
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 47
    Width = 304
    Height = 121
    Caption = 'Channels'
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 106
      Height = 13
      Alignment = taRightJustify
      Caption = 'Exclude VTII Channel:'
    end
    object Label4: TLabel
      Left = 16
      Top = 48
      Width = 271
      Height = 27
      AutoSize = False
      Caption = 'VTII  modules have 3 tone channels compared to two in Beepola. '
      WordWrap = True
    end
    object Label5: TLabel
      Left = 16
      Top = 81
      Width = 265
      Height = 32
      AutoSize = False
      Caption = 
        'You can select which of the VTII channels should be excluded fro' +
        'm the import.'
      WordWrap = True
    end
    object cboExcludeChan: TComboBox
      Left = 128
      Top = 21
      Width = 43
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'A'
      Items.Strings = (
        'A'
        'B'
        'C')
    end
  end
end
