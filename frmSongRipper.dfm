object SongRipperDlg: TSongRipperDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Song Ripper'
  ClientHeight = 223
  ClientWidth = 355
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
    355
    223)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 39
    Top = 19
    Width = 20
    Height = 13
    Alignment = taRightJustify
    Caption = '&File:'
    FocusControl = filSpecFile
  end
  object lblDefLen: TLabel
    Left = 18
    Top = 164
    Width = 114
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akRight]
    Caption = '&Default Pattern Length:'
    ExplicitTop = 170
  end
  object Label2: TLabel
    Left = 187
    Top = 164
    Width = 31
    Height = 13
    Anchors = [akLeft, akRight]
    Caption = '(rows)'
    ExplicitTop = 170
  end
  object cmdOK: TButton
    Left = 191
    Top = 190
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Convert'
    Default = True
    Enabled = False
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 272
    Top = 190
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object filSpecFile: TJvFilenameEdit
    Left = 65
    Top = 16
    Width = 282
    Height = 19
    AddQuotes = False
    BevelOuter = bvSpace
    Flat = True
    ParentFlat = False
    Filter = 
      'All supported files (*.tap; *.z80)|*.tap;*.z80|Spectrum Tape Fil' +
      'es (*.tap)|*.tap|Z80 Snapshots (*.z80)|*.z80|All Files (*)|*'
    DialogOptions = [ofHideReadOnly, ofPathMustExist, ofFileMustExist]
    DialogTitle = 'Select Spectrum Tape/Snapshot File'
    DirectInput = False
    ButtonWidth = 20
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    OnChange = filSpecFileChange
  end
  object grdSongList: TStringGrid
    Left = 8
    Top = 49
    Width = 339
    Height = 100
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 2
    DefaultRowHeight = 18
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    ScrollBars = ssVertical
    TabOrder = 3
    OnSelectCell = grdSongListSelectCell
  end
  object cboDefLen: TComboBox
    Left = 138
    Top = 161
    Width = 43
    Height = 21
    Anchors = [akLeft, akRight]
    ItemHeight = 13
    ItemIndex = 6
    TabOrder = 4
    Text = '64'
    Items.Strings = (
      '8'
      '16'
      '24'
      '32'
      '48'
      '56'
      '64')
  end
  object txtSVGRip: TEdit
    Left = 8
    Top = 194
    Width = 48
    Height = 21
    TabOrder = 5
    Text = '32768'
    Visible = False
  end
  object cmdSVGRip: TButton
    Left = 62
    Top = 194
    Width = 55
    Height = 19
    Caption = 'SVGRip'
    TabOrder = 6
    Visible = False
    OnClick = cmdSVGRipClick
  end
end
