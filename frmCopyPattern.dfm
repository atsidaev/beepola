object CopyPatternDlg: TCopyPatternDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Copy Pattern'
  ClientHeight = 223
  ClientWidth = 266
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
    266
    223)
  PixelsPerInch = 96
  TextHeight = 13
  object lblCopyTo: TLabel
    Left = 7
    Top = 38
    Width = 83
    Height = 13
    Alignment = taRightJustify
    Caption = 'Copy To Pattern:'
  end
  object Label1: TLabel
    Left = 14
    Top = 11
    Width = 76
    Height = 13
    Alignment = taRightJustify
    Caption = 'Source Pattern:'
  end
  object lblOverwriteMsg: TLabel
    Left = 14
    Top = 153
    Width = 247
    Height = 26
    AutoSize = False
    Caption = 
      'The destination pattern, 0, already contains data which will be ' +
      'overwritten if you select OK.'
    Visible = False
    WordWrap = True
  end
  object cmdOK: TButton
    Left = 102
    Top = 190
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 183
    Top = 190
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object txtDest: TEdit
    Left = 96
    Top = 35
    Width = 43
    Height = 21
    TabOrder = 4
    Text = '0'
  end
  object udnDest: TUpDown
    Left = 139
    Top = 35
    Width = 16
    Height = 21
    Associate = txtDest
    Max = 126
    TabOrder = 5
    OnClick = udnDestClick
  end
  object txtSource: TEdit
    Left = 96
    Top = 8
    Width = 43
    Height = 21
    TabOrder = 2
    Text = '0'
  end
  object udnSource: TUpDown
    Left = 139
    Top = 8
    Width = 16
    Height = 21
    Associate = txtSource
    Max = 126
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 62
    Width = 250
    Height = 85
    Anchors = [akLeft, akTop, akRight]
    Caption = 'What to Copy'
    TabOrder = 6
    object chkChan1: TCheckBox
      Left = 20
      Top = 18
      Width = 121
      Height = 19
      Caption = 'Channel 1 Data'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkChan2: TCheckBox
      Left = 20
      Top = 39
      Width = 133
      Height = 19
      Caption = 'Channel 2 Data'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object chkDrums: TCheckBox
      Left = 20
      Top = 60
      Width = 163
      Height = 17
      Caption = 'Drum Channel Data'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
end
