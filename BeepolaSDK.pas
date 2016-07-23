// BeepolaSDK
//
// By Chris Cowley
// (c) 2011 Grok Developments Ltd.
//
// Definitions for structures, constants and functions definiting the Beepola
// Engine SDK

unit BeepolaSDK;

interface

type TEditorCol=packed record
  iSize: integer;       // Size of this structure, for version control
  sColName: AnsiString; // Name of the Column (as it will appear in editor)
  iColType: integer;    // 0 = NOTE_DATA, 1=INTEGER, 3=PHASERINST, 4=ORNAMENT
  iMinVal: integer;     // Minimum permitted value for entries in this column
  iMaxVal: integer;     // Maximum permitted value for entries in this column
end;

type TEngineInfo=packed record
  iSize: integer;       // Size of this structure, for version control
  sName: AnsiString;    // Name of the Engine (as it will appear in Beepola)
  MemImage: array [0..65535] of byte; // Speccy Memory image
  iPlayerLoc: integer;  // Location of entry point for replay routine (nominally 32768)
  iDataLoc: integer;    // Location of start of music data pointed to by player routine 
  iPatternTick1: integer;  // Address of breakpoint signifying "Move to next row" in player
  iPatternTick2: integer;  // Secondary breakpoint (0 if not-used)
  iPatternTick3: integer;  // Tertiary breakpoint (0 if not-used)
  // Compile-time options
  bShowBorderSel: boolean; // TRUE=Show "Select Border Colour" dropdown in compile dlg
  bShowExitAfterEveryRow: boolean; // TRUE=Show "Exit after every row" option in compile dlg
  bShowSelectVectorTable: boolean; // TRUE=Show "Interrupt Vector Table location" option in compile dlg
  // Editor
  iColCount: integer;      // Number of columns used by editor
  iMinPatternLen: integer; // Minimum allowed pattern length (norminally 1)
  iMaxPatternLen: integer; // Maximum allowed pattern length
  bShowOrnamentEditor: boolean;    // Show Savage-style ornament editor
  bShowPhaserInstEditor: boolean;  // Show Phaser1-style instrument editor
  EditorCols: array of TEditorCol; // Array of iColCount TEditorCols, one for each column
end;

const
  COLTYPE_NOTE_DATA  = 0;
  COLTYPE_INTEGER    = 1;
  COLTYPE_BOOLEAN    = 2;
  COLTYPE_PHASERINST = 3;
  COLTYPE_ORNAMENT   = 4;

type
  PBEEPOLA_PATTERN = ^TBEEPOLA_PATTERN;
  TBEEPOLA_PATTERN = packed record
    iLength: integer;
    iTempoBPM: integer;
    sName: AnsiString;
    sPatternData: array of AnsiString;
end;

type
  PBEEPOLA_SONG = ^TBEEPOLA_SONG;
  TBEEPOLA_SONG = packed record
    sTitle: AnsiString;   // Song Title
    sAuthor: AnsiString;  // Song Author
    iLength: integer;     // Song Length (number of patterns in song layout)
    iLoopStart: integer;  // Position in song layout to which song will loop back to (0-based)
    iLayout: array of integer;
    Pattern: array of TBEEPOLA_PATTERN;
    //PhaserInstrument: array[0..99] of TBEEPOLA_PHASER_INSTRUMENT;
    //Ornament: array[0..31] of TBEEPOLA_ORNAMENT;
end;


type FuncGetEngineSettings = function (EngineInfo: TEngineInfo): integer; stdcall;
type FuncPlayOneRow = function (SpecMem: PByte; PatternData: PBEEPOLA_PATTERN; iRowNum: integer; SongData: PBEEPOLA_SONG): integer; stdcall;

implementation

end.
