object CompileDlg: TCompileDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Compile Song'
  ClientHeight = 361
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  ShowHint = True
  OnShow = FormShow
  DesignSize = (
    366
    361)
  PixelsPerInch = 96
  TextHeight = 13
  object lblCompileAddress: TLabel
    Left = 29
    Top = 11
    Width = 95
    Height = 13
    Hint = 'The memory address for the start of the compiled player routine'
    Alignment = taRightJustify
    Caption = 'Compile to address:'
  end
  object lblBorder: TLabel
    Left = 54
    Top = 38
    Width = 70
    Height = 13
    Hint = 'The border colour of the Spectrum display during playback'
    Alignment = taRightJustify
    Caption = 'Border Colour:'
  end
  object Label1: TLabel
    Left = 51
    Top = 119
    Width = 73
    Height = 13
    Alignment = taRightJustify
    Caption = '&Beeper Engine:'
  end
  object Label3: TLabel
    Left = 67
    Top = 65
    Width = 57
    Height = 13
    Alignment = taRightJustify
    Caption = 'Output File:'
  end
  object lblTranspose: TLabel
    Left = 70
    Top = 92
    Width = 54
    Height = 13
    Alignment = taRightJustify
    Caption = 'Transpose:'
  end
  object pnlTMB: TPanel
    Left = 0
    Top = 218
    Width = 369
    Height = 101
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    TabOrder = 9
    DesignSize = (
      369
      101)
    object grpPlayerType: TGroupBox
      Left = 8
      Top = 5
      Width = 350
      Height = 87
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Player Routine'
      TabOrder = 0
      object optTMBAlwaysReturn: TRadioButton
        Left = 23
        Top = 66
        Width = 242
        Height = 17
        Hint = 
          'For in-game music, create a polling routine that can be called r' +
          'epeatedly to play the next part of the song'
        Caption = 'Exit after every note (for in-game music)'
        TabOrder = 0
      end
      object optTMBReturnKeypress: TRadioButton
        Left = 23
        Top = 20
        Width = 242
        Height = 17
        Hint = 
          'Create a routine that plays the song, but returns if any key is ' +
          'pressed on the Spectrum keyboard'
        Caption = 'Exit when a key is pressed'
        TabOrder = 1
      end
      object optTMBContinuous: TRadioButton
        Left = 23
        Top = 43
        Width = 250
        Height = 17
        Hint = 'Plays the song without interruption'
        Caption = 'Play continuously (ignore keypresses)'
        TabOrder = 2
      end
    end
  end
  object pnlSpecialFX: TPanel
    Left = 0
    Top = 223
    Width = 365
    Height = 101
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    TabOrder = 8
    DesignSize = (
      365
      101)
    object lblVectorTableLoc: TLabel
      Left = 13
      Top = 78
      Width = 111
      Height = 13
      Alignment = taRightJustify
      Caption = 'Interrupt Vector Table:'
    end
    object cboVectorTableLoc: TComboBox
      Left = 130
      Top = 75
      Width = 105
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        '0xFE00 - Default'
        '0x3900 - ROM')
    end
    object GroupBox1: TGroupBox
      Left = 8
      Top = 0
      Width = 350
      Height = 69
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Player Routine'
      TabOrder = 0
      object optSFXReturnKeypress: TRadioButton
        Left = 23
        Top = 20
        Width = 242
        Height = 17
        Hint = 
          'Create a routine that plays the song, but returns if any key is ' +
          'pressed on the Spectrum keyboard'
        Caption = 'Exit when a key is pressed'
        TabOrder = 0
      end
      object optSFXContinuous: TRadioButton
        Left = 23
        Top = 43
        Width = 250
        Height = 17
        Hint = 'Plays the song without interruption'
        Caption = 'Play continuously (ignore keypresses)'
        TabOrder = 1
      end
    end
  end
  object txtCompileAddress: TEdit
    Left = 130
    Top = 8
    Width = 47
    Height = 21
    Hint = 'The memory address for the start of the compiled player routine'
    TabOrder = 2
    Text = '60000'
  end
  object cboBorder: TComboBox
    Left = 130
    Top = 35
    Width = 73
    Height = 21
    Hint = 'The border colour of the Spectrum display during playback'
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 3
    Text = 'Black'
    Items.Strings = (
      'Black'
      'Blue'
      'Red'
      'Magenta'
      'Green'
      'Cyan'
      'Yellow'
      'White')
  end
  object cmdOK: TButton
    Left = 202
    Top = 328
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 283
    Top = 329
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object cboEngine: TComboBox
    Left = 130
    Top = 116
    Width = 135
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 6
    Text = 'Special FX (Fuzz Click)'
    OnChange = cboEngineChange
    Items.Strings = (
      'Special FX (Fuzz Click)'
      'The Music Box'
      'The Music Studio'
      'Phaser1, Digital Drums'
      'Phaser1, Synth Drums'
      'Savage'
      'ROM Beep'
      'Plip Plop'
      'Stocker')
  end
  object cboOutputType: TComboBox
    Left = 130
    Top = 62
    Width = 165
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 4
    Text = '*.tap file (with BASIC loader)'
    Items.Strings = (
      '*.tap file (with BASIC loader)'
      '*.tap file (code block only)'
      'Binary File (*.bin)'
      'Assembly Listing (*.asm)'
      'Song Data Only (*.tap)'
      'Song Data Only (*.bin)'
      'Song Data Only (*.asm)')
  end
  object cboTranspose: TComboBox
    Left = 130
    Top = 89
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 12
    TabOrder = 5
    Text = 'None'
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
  object grpSongEnd: TGroupBox
    Left = 8
    Top = 143
    Width = 350
    Height = 74
    Anchors = [akLeft, akTop, akRight]
    Caption = 'When the end of the song is reached'
    TabOrder = 7
    object optLoopAtEnd: TRadioButton
      Left = 23
      Top = 20
      Width = 242
      Height = 17
      Hint = 
        'When the last pattern in the song finishes, loop back to the def' +
        'ined loop start point'
      Caption = 'Loop back to the defined LOOP START point'
      TabOrder = 0
    end
    object optReturnAtEnd: TRadioButton
      Left = 23
      Top = 43
      Width = 242
      Height = 17
      Hint = 
        'When the last pattern in the song finishes, exit from the player' +
        ' routine'
      Caption = 'Exit'
      TabOrder = 1
    end
  end
  object dlgSave: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Compile Song'
    Left = 158
    Top = 326
  end
end
