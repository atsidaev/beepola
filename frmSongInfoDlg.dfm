object SongInfoDlg: TSongInfoDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Song Information'
  ClientHeight = 349
  ClientWidth = 351
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
    351
    349)
  PixelsPerInch = 96
  TextHeight = 13
  object lblSongProperties: TLabel
    Left = 12
    Top = 8
    Width = 80
    Height = 13
    Caption = 'Song Properties:'
  end
  object lblCompiledLength: TLabel
    Left = 12
    Top = 162
    Width = 195
    Height = 13
    Caption = 'Compiled Song Length (including player):'
  end
  object cmdClose: TButton
    Left = 268
    Top = 316
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Close'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object grdSongProperties: TStringGrid
    Left = 8
    Top = 27
    Width = 335
    Height = 123
    Anchors = [akLeft, akTop, akRight]
    ColCount = 2
    DefaultRowHeight = 16
    FixedCols = 0
    TabOrder = 1
  end
  object grdCompiledLength: TStringGrid
    Left = 8
    Top = 181
    Width = 335
    Height = 126
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 2
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 7
    TabOrder = 2
  end
end
