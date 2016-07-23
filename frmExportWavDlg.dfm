object ExportWavDlg: TExportWavDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Export to WAV file'
  ClientHeight = 152
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    320
    152)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 304
    Height = 75
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Recording Length:'
    TabOrder = 0
    object Label2: TLabel
      Left = 113
      Top = 48
      Width = 141
      Height = 13
      Caption = 'seconds (looping as required)'
    end
    object optNoLoop: TRadioButton
      Left = 18
      Top = 22
      Width = 271
      Height = 17
      Caption = 'Stop recording at the end of the song (do not loop)'
      TabOrder = 0
    end
    object optLoop: TRadioButton
      Left = 18
      Top = 45
      Width = 63
      Height = 17
      Caption = 'Record:'
      TabOrder = 1
    end
    object txtWavSecs: TEdit
      Left = 79
      Top = 45
      Width = 28
      Height = 21
      TabOrder = 2
      Text = '120'
    end
  end
  object pbrExport: TProgressBar
    Left = 8
    Top = 89
    Width = 304
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object cmdOK: TButton
    Left = 156
    Top = 119
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 237
    Top = 119
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 3
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'wav'
    Filter = 'Windows Audio File (wav)|*.wav|All Files|*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Save Song File'
    Left = 12
    Top = 115
  end
end
