object KeyboardLayoutWnd: TKeyboardLayoutWnd
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Beepola Keyboard Layout'
  ClientHeight = 303
  ClientWidth = 503
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 105
    Height = 13
    Caption = 'Piano Key Layout:-'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 20
    Top = 23
    Width = 84
    Height = 13
    Caption = '2 3    5  6 7    9 0 '
  end
  object Label3: TLabel
    Left = 11
    Top = 35
    Width = 98
    Height = 13
    Caption = 'Q W E R T Y U I O P '
  end
  object Label4: TLabel
    Left = 16
    Top = 68
    Width = 88
    Height = 13
    Caption = 'Z X C V B N M ,  . /'
  end
  object Label5: TLabel
    Left = 20
    Top = 56
    Width = 80
    Height = 13
    Caption = 'S D    G H J     L ;'
  end
  object Label6: TLabel
    Left = 132
    Top = 30
    Width = 95
    Height = 13
    Caption = 'Current Octave + 1'
  end
  object Label7: TLabel
    Left = 132
    Top = 64
    Width = 75
    Height = 13
    Caption = 'Current Octave'
  end
  object Label8: TLabel
    Left = 288
    Top = 8
    Width = 94
    Height = 13
    Caption = 'Numeric Keypad:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label9: TLabel
    Left = 297
    Top = 22
    Width = 141
    Height = 13
    Caption = 'Keys 1- 5 set current octave.'
  end
  object Label10: TLabel
    Left = 12
    Top = 130
    Width = 411
    Height = 13
    Caption = 
      '[Ins] - Insert a new row for the current channel (shift other no' +
      'tes and effects down).'
  end
  object Label11: TLabel
    Left = 12
    Top = 169
    Width = 213
    Height = 13
    Caption = '[Del] - Delete the currently highlighted note.'
  end
  object Label12: TLabel
    Left = 12
    Top = 189
    Width = 470
    Height = 13
    Caption = 
      '[Ctrl]+[Del] - Delete the currently hightlighted channel row (sh' +
      'ift remaining notes and effects up).'
  end
  object Label13: TLabel
    Left = 8
    Top = 94
    Width = 65
    Height = 13
    Caption = 'Other Keys:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label14: TLabel
    Left = 12
    Top = 232
    Width = 76
    Height = 13
    Caption = '[F5] - Play song'
  end
  object Label15: TLabel
    Left = 12
    Top = 247
    Width = 127
    Height = 13
    Caption = '[F4] - Play current pattern'
  end
  object Label16: TLabel
    Left = 12
    Top = 278
    Width = 182
    Height = 13
    Caption = '[F8] - Stop playback (also SPACE key)'
  end
  object Label17: TLabel
    Left = 12
    Top = 111
    Width = 431
    Height = 13
    Caption = 
      '[A] or [1] - Insert a rest/note-off at the current location (not' +
      ' used by all beeper engines).'
  end
  object Label18: TLabel
    Left = 12
    Top = 150
    Width = 497
    Height = 13
    Caption = 
      '[Shift]+[Ins] - Insert a new note only at the current location (' +
      'shift other notes, but not effects, down).'
  end
  object Label19: TLabel
    Left = 12
    Top = 209
    Width = 404
    Height = 13
    Caption = 
      '[Shift]+[Del] - Delete the currently hightlighted note only (shi' +
      'ft remaining notes up).'
  end
  object Label20: TLabel
    Left = 12
    Top = 262
    Width = 179
    Height = 13
    Caption = '[F6] - Play song from current location'
  end
end
