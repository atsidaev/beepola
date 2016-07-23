unit SongRipper;

interface

uses Classes;

type
  TSongDataType = (ERROR,TheMusicBox,Phaser1Digital,Phaser1Synth,SFX,P1D,P1S,TMB,MSD,SVG);

  TSongData = record
    SongLoc: Word;
    DataType: TSongDataType;
  end;
type
  TSongRipper = class(TObject)
  private
    FFileName: string;
    FSongs: array of TSongData;
    Mem: array [0..65535] of byte;
    function GetSongCount: integer;
    function GetSongDataType(i: integer): TSongDataType;
    function GetSongDataTypeString(i: integer): string;
    function GetSongLocation(i: integer): integer;
    function ScanTheMusicBox: integer;
    procedure RipTheMusicBox(iLoc: integer; iPatLen: integer);
    function ScanPhaser1DLinear: integer;
    function ScanPhaser1SLinear: integer;
    procedure RipPhaser1Linear(iLoc, iPatLen: integer);
    function GetPhaser1MinRender(i: integer): integer;
    procedure ReadZ80V1Snap(F: TFileStream);
    procedure ReadZ80V2orV3Snap(F: TFileStream);
    function ScanP1D: integer;
    function ScanP1S: integer;
    procedure RipPhaser1Patterns(iLoc, iPatLen: integer);
    function GetSongPatternNum(wAddr: word; dwLayout: array of Word): byte;
  public
    function Scan(): integer;
    function ConvertSong(iSong: integer; DefPatternLen: byte = 64): integer;
    function LoadTAP(sFileName: string): integer;
    function LoadZ80(sFileName: string): integer;
    function LoadSNA(sFileName: string): integer;
    property SongCount: integer read GetSongCount;
    property SongLocation[i: integer]: integer read GetSongLocation;
    property SongDataType[i: integer]: TSongDataType read GetSongDataType;
    property SongDataTypeString[i: integer]: string read GetSongDataTypeString;
    property FileName: string read FFileName write FFileName;
    constructor Create;
  end;

implementation

{ TSongRipper }

uses SysUtils, Forms, Windows, frmSTMainWnd;

procedure TSongRipper.RipTheMusicBox(iLoc: integer; iPatLen: integer);
var
  i, j, iPat, iRow, iTempo: integer;
  cNote1, cNote2: byte;
begin
  if (Mem[iLoc] <> 33) or (Mem[iLoc + 6] <> 33) then
    exit;

  iTempo := Mem[iLoc + 35];
  iTempo := (iTempo - 210) div 2;
  if iTempo < 1 then iTempo := 1;
  if iTempo > 20 then iTempo := 20;

  i := Mem[iLoc+1] + 256 * Mem[iLoc+2]+1; // Ch1 data
  j := Mem[iLoc+7] + 256 * Mem[iLoc+8]+1; // Ch2 data
  iPat := 0; iRow := 1;

  while (Mem[i] <> $40) and (Mem[j] <> $40) and (iPat < 126) do
  begin
    STMainWnd.Song.SongLayout[iPat] := iPat;
    STMainWnd.Song.Pattern[iPat].Length := iPatLen;
    STMainWnd.Song.Pattern[iPat].Tempo := iTempo;
    cNote1 := Mem[i] + 12;
    cNote2 := Mem[j] + 12;
    if cNote1 = $35 then cNote1 := $FF;
    if cNote2 = $35 then cNote2 := $FF;

    if (Mem[i] < $40) or (Mem[i] >= $F4) then
    begin
      STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := cNote1;
      STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := cNote2;
    end
    else if (Mem[i] = $B4) then
    begin
      // Kick Drum
      STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := 255;
      STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := 255;
      STMainWnd.Song.Pattern[iPat].Drum[iRow] := $89;
    end
    else if (Mem[i] >= $E4) and (Mem[i] <= $F3)  then
    begin
      // White Noise (Custom Drum)
      STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := 255;
      STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := 255;
      STMainWnd.Song.Pattern[iPat].Sustain[2][iRow] := Mem[i] - 228;
      case Mem[j] of
      $01: // Wave1
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := $81;
      $03: // Wave2
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := $82;
      $07: // Wave3
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := $83;
      $0F: // Wave4
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := $84;
      $1F: // Wave5
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := $85;
      $3F: // Wave6
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := $86;
      $7F: // Wave7
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := $87;
      $FF: // Wave8
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := $88;
      end;
    end;
    inc(iRow);
    inc(i);
    inc(j);

    if iRow > iPatLen then
    begin
      inc(iPat);
      iRow := 1;
    end;
  end;

  STMainWnd.Song.Pattern[iPat].Length := iRow-1;

  STMainWnd.Song.PreferredEngine := 'TMB';
  STMainWnd.mnuTGTheMusicBoxClick(nil);
end;

function TSongRipper.GetPhaser1MinRender(i: integer): integer;
var
  iLowest, iCurrent: integer;
begin
  iLowest := 9999; iCurrent := 0;
  while (Mem[i] <> $0) and (i < 65536) do
  begin
    if (Mem[i] = $BD) then
      inc(i)
    else if Mem[i] >= $80 then
    begin
      if (iCurrent < iLowest) and (iCurrent > 0) then
        iLowest := iCurrent;
        
      iCurrent := 0;
    end
    else if (Mem[i] >= $76) and (Mem[i] <= $7F) then
      inc(iCurrent)
    else if (Mem[i] < $76) then
      inc(iCurrent,Mem[i]);

    inc(i);
  end;

  Result := iLowest;
end;


procedure TSongRipper.RipPhaser1Linear(iLoc: integer; iPatLen: integer);
var
  i, iPat, iRow, iInstCount, iTempo, iSkip: integer;
  cNote1: byte;
begin
  iInstCount := (Mem[iLoc] + 256 * Mem[iLoc+1]) div 4;

  iRow := iLoc + 2;
  for i := 0 to iInstCount - 1 do
  begin
    STMainWnd.Song.Phaser1Instrument[i].Multiple := Mem[iRow];
    STMainWnd.Song.Phaser1Instrument[i].Detune := Mem[iRow+1] + 256 * Mem[iRow + 2];
    STMainWnd.Song.Phaser1Instrument[i].Phase := Mem[iRow + 3];
    inc(iRow,4);
  end;
  
  i := iLoc + iInstCount * 4 + 2;
  iPat := 0; iRow := 1;

  iTempo := GetPhaser1MinRender(i);

  iSkip := 0;

  while (Mem[i] <> $00) and (iPat < 126) do
  begin
    STMainWnd.Song.SongLayout[iPat] := iPat;
    STMainWnd.Song.Pattern[iPat].Length := iPatLen;
    STMainWnd.Song.Pattern[iPat].Tempo := 17 - iTempo;

    if (Mem[i] = $BF) then
    begin
      // Loop Start Marker
      if (iRow <> 1) then
      begin
        inc(iPat);
        iRow := 1;
      end;
      STMainWnd.Song.LoopStart := iPat;
      Inc(i);
    end
    else if (Mem[i] = $BD) then
    begin
      // Instrument Change
      inc(i);
      STMainWnd.Song.Pattern[iPat].Sustain[2][iRow] := Mem[i] div 2;
      Inc(i);
    end
    else if ((Mem[i] and $80) = $80) then
    begin
      cNote1 := Mem[i] and $3F;
      if cNote1 <= 6 then Inc(cNote1,101) else dec(cNote1,6);
      if (Mem[i] and $3F) = 60 then
        STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := $82
      else if (Mem[i] and $3F) = 62 then
        STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := 255
      else
        STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := cNote1;

      if ((Mem[i] and $40) = $40) then
        STMainWnd.Song.Pattern[iPat].Sustain[1][iRow] := 1
      else
        STMainWnd.Song.Pattern[iPat].Sustain[1][iRow] := 255;
      inc(i);

      // Chan 2
      cNote1 := Mem[i] and $3F;
      if cNote1 <= 6 then Inc(cNote1,101) else dec(cNote1,6);
      if ((Mem[i] and $80) = $80) and ((Mem[i] and $3F) = 60) then
        STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := $82
      else if ((Mem[i] and $80) = $80) and ((Mem[i] and $3F) = 62) then
        STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := 255
      else if ((Mem[i] and $80) = $80) then
        STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := cNote1;

      if ((Mem[i] and $80) = $80) then inc(i);
    end;
    // Drum/skiplines
    if (Mem[i] >= $76) and (Mem[i] <= $7E) then
    begin
      STMainWnd.Song.Pattern[iPat].Drum[iRow] := Mem[i] - $75 + $80;
      inc(i);
      iSkip := 1;
    end;

    if (Mem[i] <= $75) then
    begin
      inc(iSkip, Mem[i]);
      iSkip := iSkip div iTempo;
      inc(iRow,iSkip);
      iSkip := 0;
      inc(i);
      while (iRow > iPatLen) do
      begin
        inc(iPat);
        STMainWnd.Song.SongLayout[iPat] := iPat;
        STMainWnd.Song.Pattern[iPat].Length := iPatLen;
        STMainWnd.Song.Pattern[iPat].Tempo := 17 - iTempo;
        Dec(iRow,iPatLen);
      end;
    end
    else if (Mem[i] < $80) then
    begin
      iSkip := iSkip div iTempo;
      inc(iRow,iSkip);
      iSkip := 0;
    end;

    if iRow > iPatLen then
    begin
      inc(iPat);
      iRow := 1;
    end;
  end;

  STMainWnd.Song.Pattern[iPat].Length := iRow-1;
end;

function TSongRipper.GetSongPatternNum(wAddr: word; dwLayout: array of Word): byte;
var
  i: integer;
begin
  Result := 255;

  for i := 0 to Length(dwLayout) - 1 do
  begin
    if dwLayout[i] = wAddr then
    begin
      Result := STMainWnd.Song.SongLayout[i];
      break;
    end;
  end;
end;

procedure TSongRipper.RipPhaser1Patterns(iLoc: integer; iPatLen: integer);
var
  i, iPat, iRow, iInstCount, iTempo, iSkip: integer;
  cNote1: byte;
  cSongLength, cNextPat: byte;
  dwLayout: array of Word;
begin
  STMainWnd.Song.LoopStart := Mem[iLoc] div 2;
  cSongLength := Mem[iLoc+1] div 2;
  inc(iLoc,2);

  iInstCount := (Mem[iLoc] + 256 * Mem[iLoc+1]) div 4;

  iRow := iLoc + 2;
  for i := 0 to iInstCount - 1 do
  begin
    STMainWnd.Song.Phaser1Instrument[i].Multiple := Mem[iRow];
    STMainWnd.Song.Phaser1Instrument[i].Detune := Mem[iRow+1] + 256 * Mem[iRow + 2];
    STMainWnd.Song.Phaser1Instrument[i].Phase := Mem[iRow + 3];
    inc(iRow,4);
  end;
  
  inc(iLoc, iInstCount * 4 + 2);

  // Get Song Layout
  SetLength(dwLayout,0);
  cNextPat := 0;
  for i := 0 to cSongLength - 1 do
  begin
    iRow := Mem[iLoc] + 256 * Mem[iLoc+1];
    STMainWnd.Song.SongLayout[i] := GetSongPatternNum(iRow and $FFFF,dwLayout);
    if STMainWnd.Song.SongLayout[i] = 255 then
    begin
      STMainWnd.Song.SongLayout[i] := cNextPat;
      inc(cNextPat);
    end;
    SetLength(dwLayout,i+1);
    dwLayout[i] := iRow and $FFFF;
    inc(iLoc,2);
  end;

  for i := 0 to cSongLength - 1 do
  begin
    iPat := STMainWnd.Song.SongLayout[i];

    iLoc := dwLayout[i];

    iTempo := GetPhaser1MinRender(iLoc);
    STMainWnd.Song.Pattern[iPat].Tempo := 17 - iTempo;
    iSkip := 0;
    iRow := 1;

    while (Mem[iLoc] <> $00) and (iRow < 126) do
    begin
      if (Mem[iLoc] = $BF) then
        Inc(iLoc)
      else if (Mem[iLoc] = $BD) then
      begin
        // Instrument Change
        inc(iLoc);
        STMainWnd.Song.Pattern[iPat].Sustain[2][iRow] := Mem[iLoc] div 2;
        Inc(iLoc);
      end
      else if ((Mem[iLoc] and $80) = $80) then
      begin
        cNote1 := Mem[iLoc] and $3F;
        if cNote1 <= 6 then Inc(cNote1,101) else dec(cNote1,6);
        if (Mem[iLoc] and $3F) = 60 then
          STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := $82
        else if (Mem[iLoc] and $3F) = 62 then
          STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := 255
        else
          STMainWnd.Song.Pattern[iPat].Chan[2][iRow] := cNote1;

        if ((Mem[iLoc] and $40) = $40) then
          STMainWnd.Song.Pattern[iPat].Sustain[1][iRow] := 1
        else
          STMainWnd.Song.Pattern[iPat].Sustain[1][iRow] := 255;
        inc(iLoc);

        // Chan 2
        cNote1 := Mem[iLoc] and $3F;
        if cNote1 <= 6 then Inc(cNote1,101) else dec(cNote1,6);
        if ((Mem[iLoc] and $80) = $80) and ((Mem[iLoc] and $3F) = 60) then
          STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := $82
        else if ((Mem[iLoc] and $80) = $80) and ((Mem[iLoc] and $3F) = 62) then
          STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := 255
        else if ((Mem[iLoc] and $80) = $80) then
          STMainWnd.Song.Pattern[iPat].Chan[1][iRow] := cNote1;

        if ((Mem[iLoc] and $80) = $80) then inc(iLoc);
      end;
      // Drum/skiplines
      if (Mem[iLoc] >= $76) and (Mem[iLoc] <= $7E) then
      begin
        STMainWnd.Song.Pattern[iPat].Drum[iRow] := Mem[iLoc] - $75 + $80;
        inc(iLoc);
        iSkip := 1;
      end;

      if (Mem[iLoc] <= $75) then
      begin
        inc(iSkip, Mem[iLoc]);
        iSkip := iSkip div iTempo;
        inc(iRow,iSkip);
        iSkip := 0;
        inc(iLoc);
      end
      else if (Mem[iLoc] < $80) then
      begin
        iSkip := iSkip div iTempo;
        inc(iRow,iSkip);
        iSkip := 0;
      end;
    end;

    STMainWnd.Song.Pattern[iPat].Length := iRow-1;
  end;
end;


function TSongRipper.ConvertSong(iSong: integer; DefPatternLen: byte): integer;
begin
  if (iSong < 0) or (iSong >= Length(FSongs)) then
    Result := -1
  else
  begin
    // Rip Song #iSong
    STMainWnd.Song.Clear;

    case FSongs[iSong].DataType of
    TheMusicBox:
      RipTheMusicBox(FSongs[iSong].SongLoc, DefPatternLen);
    Phaser1Digital:
    begin
     RipPhaser1Linear(FSongs[iSong].SongLoc, DefPatternLen);
      STMainWnd.Song.PreferredEngine := 'P1D';
       STMainWnd.mnuTGPhaser1DigitalClick(nil);
    end;
    Phaser1Synth:
    begin
      RipPhaser1Linear(FSongs[iSong].SongLoc, DefPatternLen);
      STMainWnd.Song.PreferredEngine := 'P1S';
       STMainWnd.mnuTGPhaser1DigitalClick(nil);
    end;
    P1D:
    begin
     RipPhaser1Patterns(FSongs[iSong].SongLoc, DefPatternLen);
      STMainWnd.Song.PreferredEngine := 'P1D';
       STMainWnd.mnuTGPhaser1DigitalClick(nil);
    end;
    P1S:
    begin
      RipPhaser1Patterns(FSongs[iSong].SongLoc, DefPatternLen);
      STMainWnd.Song.PreferredEngine := 'P1S';
       STMainWnd.mnuTGPhaser1DigitalClick(nil);
    end;
    //SFX,TMB,MSD,SVG);
    end;

    Result := 0;
  end;
end;

constructor TSongRipper.Create;
begin
  inherited;

end;

function TSongRipper.GetSongCount: integer;
begin
  Result := Length(FSongs);
end;

function TSongRipper.GetSongDataType(i: integer): TSongDataType;
begin
  if (i >= 0) and (i < Length(FSongs)) then
    Result := FSongs[i].DataType
  else
    Result := ERROR;
end;

function TSongRipper.GetSongDataTypeString(i: integer): string;
var
  DT: TSongDataType;
begin
  if (i >= 0) and (i < Length(FSongs)) then
    DT := FSongs[i].DataType
  else
    DT := ERROR;

  case DT of
    ERROR: Result := 'ERROR';
    TheMusicBox: Result := 'The Music Box (original)' ;
    Phaser1Digital: Result := 'Phaser1 Digital (linear)';
    Phaser1Synth: Result := 'Phaser1 Synth (linear)';
    SFX: Result := 'Special FX (Beepola)';
    P1D: Result := 'Phaser1 Digital (Beepola)';
    P1S: Result := 'Phaser1 Synth (Beepola)';
    TMB: Result := 'The Music Box (Beepola)';
    MSD: Result := 'Music Studio (Beepola)';
    SVG: Result := 'Savage (Beepola)';
  end;
end;

function TSongRipper.GetSongLocation(i: integer): integer;
begin
  if (i < 0) or (i >= Length(FSongs)) then
    Result := -1
  else
  begin
    Result := FSongs[i].SongLoc;
  end;
end;

function TSongRipper.LoadSNA(sFileName: string): integer;
begin
  Result := -1;
end;

function TSongRipper.LoadTAP(sFileName: string): integer;
var
  F: TFileStream;
  wBlockLen: Word;
  cBytes: array of byte;
  c00Header: byte;
  cBlockType: byte;
  wCodeStart, wCodeLen: Word;
  i: Integer;
begin
  Result := -1; // Error
  try
    F := TFileStream.Create(sFileName,fmOpenRead or fmShareDenyNone);
    while F.Position < F.Size do
    begin
      F.Read(wBlockLen,2);
      SetLength(cBytes,wBlockLen);
      F.Read(cBytes[0],wBlockLen);
      c00Header := cBytes[0];
      cBlockType := cBytes[1];
      if c00Header = 00 then
      begin
        // This is a header block, get the properties of the following data block
        // and either LOAD it into Mem[] if it's code, or skip it
        if cBlockType = 3 then
        begin
          wCodeLen := cBytes[12] + 256 * cBytes[13];
          wCodeStart := cBytes[14] + 256 * cBytes[15];
          F.Read(wBlockLen,2);
          if wBlockLen <> wCodeLen + 2 then
            break;
          SetLength(cBytes,wBlockLen);
          F.Read(cBytes[0],wBlockLen);
          if (cBytes[0] = $FF) then
          begin
            Result := 0; // OK - Some TAP data was loaded
            // Stick the code block data into Mem
            for i := 0 to wCodeLen - 1 do
              Mem[i+wCodeStart] := cBytes[i+1];
          end;
        end
        else
        begin
          // Skip next block
          F.Read(wBlockLen,2);
          SetLength(cBytes,wBlockLen);
          F.Read(cBytes[0],wBlockLen);
        end;

      end;
    end;
  finally
    FreeAndNil(F);
  end;
end;

procedure TSongRipper.ReadZ80V1Snap(F: TFileStream);
var
  Buf: array of byte;
  iDataLen, iBlockLen, iCounter, iMemPos, iBlockCounter: integer;
begin
  iDataLen := F.Size - F.Position;
  SetLength(Buf,iDataLen);
  // read the compressed data into Buf
  F.Read(Buf[0],iDataLen);

  // Uncompress the block to memory
  iCounter := 1;
  iMemPos := 16384;

  repeat
    if Buf[iCounter] = $ED then
    begin
      if Buf[iCounter + 1] = $ED then
      begin
        // This is an encoded block
        inc(iCounter,2);
        iBlockLen := Buf[iCounter];
        inc(iCounter);
        for iBlockCounter := 1 to iBlockLen do
        begin
          Mem[iMemPos] := Buf[iCounter];
          inc(iMemPos);
        end;
      end
      else
      begin
        // Just a single ED, write it out
        Mem[iMemPos] := $ED;
        inc(iMemPos);
      end;
    end
    else
    begin
      Mem[iMemPos] := Buf[iCounter];
      inc(iMemPos);
    end;
    inc(iCounter);
  until iCounter > iDataLen - 5;

  if (Buf[iCounter] <> 0) or (Buf[iCounter+1] <>  $ED) or
     (Buf[iCounter+2] <> $ED) or (Buf[iCounter+3] <> 0) then
        Application.MessageBox('Error in compressed Z80 file. Block end marker 0x00EDED00 is not present.',
                               PAnsiChar(Application.Title),MB_ICONEXCLAMATION);
end;

procedure TSongRipper.ReadZ80V2orV3Snap(F: TFileStream);
var
  iHeaderLen, iCounter, iMemStart, iBlockCounter, iMemPos: integer;
  Buf: array of byte;
  b128KMap: boolean;
  cOut7FFD, cTop16KPage: byte;
begin
  SetLength(Buf,32768);
  F.Read(Buf[0],2);
  iHeaderLen := Buf[0] + 256 * Buf[1];
  F.Read(Buf[0],iHeaderLen);

  b128KMap := false;
  cOut7FFD := Buf[3] and 7;
  if (iHeaderLen = 23) then
  begin
    // V2
    if (Buf[2] = 3) or (Buf[2] = 4) or (Buf[2] = 7) or (Buf[2] = 8) or
       (Buf[2] = 9) or (Buf[2] = 10) or (Buf[2] = 11) or (Buf[2] = 12) or
       (Buf[2] = 13) then
      b128KMap := true;

  end
  else if (iHeaderLen = 54) or (iHeaderLen = 55) then
  begin
    // V3
    if (Buf[2] = 4) or (Buf[2] = 5) or (Buf[2] = 6) or (Buf[2] = 7) or
       (Buf[2] = 8) or (Buf[2] = 9) or (Buf[2] = 10) or (Buf[2] = 11) or
       (Buf[2] = 12) or (Buf[2] = 13) then
      b128KMap := true;
  end
  else
  begin
    Application.MessageBox(PAnsiChar(
                           'The specified Z80 file contains an invalid extended header length of ' + IntToHex(iHeaderLen,4) + ' bytes'#13#10#13#10 +
                           'Only valid V1, V2 or V3 Z80 snapshots are supported.'),
                           (PAnsiChar(Application.Title)),
                           MB_ICONINFORMATION or MB_OK);
    exit;
  end;

  if b128KMap then
    cTop16KPage := (cOut7FFD and 7)+3  // 128/+2 memory page operation
  else
    cTop16KPage := 5;                  // In 48K snaps, always put Page 5 into top 16K

  while F.Position < F.Size do
  begin
    // read a block
    F.Read(Buf[0],3);
    iHeaderLen := Buf[0] + 256 * Buf[1];

    if b128KMap then
    begin
      case Buf[2] of
      0: iMemPos := $0000; // 48K ROM
      // ROMs and 128K pages - unused by 48K speccy
      1,2,3,4,6,7,9,10,11:
        if (Buf[2] = cTop16KPage) then iMemPos := $C000 else iMemPos := -1;
      5: iMemPos := $8000; // Page 1 RAM at $8000
      8: iMemPos := $4000; // Page 5 RAM at $4000
      else
        iMemPos := -1;
      end;
    end
    else
    begin
      case Buf[2] of
      0: iMemPos := $0000; // 48K ROM
      5: iMemPos := $C000;
      4: iMemPos := $8000; // Page 1 RAM at $8000
      8: iMemPos := $4000; // Page 5 RAM at $4000
      else
        iMemPos := -1;
      end;
    end;

    if (iHeaderLen = $FFFF) then
    begin
      // Uncompressed block, just read it into RAM
      if iMemPos < 0 then
        F.Read(Buf[0],16384)
      else
        F.Read(Mem[iMemPos],16384);
    end
    else
    begin
      // Uncompress the block to memory
      SetLength(Buf,iHeaderLen);
      F.Read(Buf[0],iHeaderLen);

      iCounter := 0;
      if iMemPos > -1 then
      begin
        iMemStart := iMemPos;
        repeat
          if (Buf[iCounter] = $ED) then
          begin
            if Buf[iCounter + 1] = $ED then
            begin
              // This is an encoded block
              inc(iCounter,2);
              iHeaderLen := Buf[iCounter];
              inc(iCounter);
              for iBlockCounter := 0 To iHeaderLen - 1 do
                Mem[iMemPos + iBlockCounter] := Buf[iCounter];

              inc(iMemPos, iHeaderLen);
            end
            else
            begin
              // Just a single ED, write it out
              Mem[iMemPos] := $ED;
              inc(iMemPos);
            end;
           end
           else
           begin
             Mem[iMemPos] := Buf[iCounter];
             inc(iMemPos);
           end;

           inc(iCounter);
        until (iCounter >= Length(Buf));
        if iMemPos < iMemStart + 16384 then
          Application.MessageBox('Z80 block error','',0);
      end;
    end;
  end;
end;

function TSongRipper.LoadZ80(sFileName: string): integer;
var
  F: TFileStream;
  Buf: array of byte;
  regPC: word;
  bCompressed: boolean;
begin
  try
    F := TFileStream.Create(sFileName,fmOpenRead or fmShareDenyNone);
    while F.Position < F.Size do
    begin
      SetLength(Buf,65536);
      F.Read(Buf[0],6);
      F.Read(Buf[0],2);
      regPC := Buf[0] + 256 * Buf[1];
      F.Read(Buf[0],22);
      if (Buf[4] and $20) = $20 then bCompressed := true else bCompressed := false;

      if regPC = 0 then
      begin
        // Read V2 or V3 file
        ReadZ80V2orV3Snap(F);
      end
      else
      begin
        // Read V1 file
        if bCompressed then
        begin
          ReadZ80V1Snap(F);
        end
        else
          F.Read(Mem[16384],49152);
      end;

    end;
  finally
    FreeAndNil(F);
  end;
  Result := 0;
end;

function TSongRipper.Scan: integer;
var
  iRet: integer;
begin
  SetLength(FSongs,0);

  iRet := ScanTheMusicBox();
  if iRet >= 0 then
  begin
    SetLength(FSongs,Length(FSongs)+1);
    FSongs[Length(FSongs)-1].SongLoc := iRet;
    FSongs[Length(FSongs)-1].DataType := TheMusicBox;
  end;

  iRet := ScanPhaser1DLinear();
  if iRet >= 0 then
  begin
    SetLength(FSongs,Length(FSongs)+1);
    FSongs[Length(FSongs)-1].SongLoc := iRet;
    FSongs[Length(FSongs)-1].DataType := Phaser1Digital;
  end;

  iRet := ScanPhaser1SLinear();
  if iRet >= 0 then
  begin
    SetLength(FSongs,Length(FSongs)+1);
    FSongs[Length(FSongs)-1].SongLoc := iRet;
    FSongs[Length(FSongs)-1].DataType := Phaser1Synth;
  end;

  iRet := ScanP1D();
  if iRet >= 0 then
  begin
    SetLength(FSongs,Length(FSongs)+1);
    FSongs[Length(FSongs)-1].SongLoc := iRet;
    FSongs[Length(FSongs)-1].DataType := P1D;
  end;

  iRet := ScanP1S();
  if iRet >= 0 then
  begin
    SetLength(FSongs,Length(FSongs)+1);
    FSongs[Length(FSongs)-1].SongLoc := iRet;
    FSongs[Length(FSongs)-1].DataType := P1S;
  end;

  Result := Length(FSongs);
end;

function TSongRipper.ScanTheMusicBox(): integer;
var
  MatchBin: array [0..33] of word;
  i,j: integer;
begin
  MatchBin[0] := 94;   //	LD	E,(HL)
  MatchBin[1] := 35;   //	INC	HL
  MatchBin[2] := 86;   //	LD	D,(HL)
  MatchBin[3] := 19;   //	INC	DE
  MatchBin[4] := 26;   //	LD	A,(DE)
  MatchBin[5] := 254;  //	CP n
  MatchBin[6] := 64;   //	$40
  MatchBin[7] := 40;   //	JR	Z,d
  MatchBin[8] := 256;  //	CHANNEL_END
  MatchBin[9] := 114;  //	LD	(HL),D
  MatchBin[10] := 43;  //	DEC	HL
  MatchBin[11] := 115; //	LD	(HL),E
  MatchBin[12] := 201; //	RET
  MatchBin[13] := 126; //	LD	A,(HL)			; A = value of next note
  MatchBin[14] := 198; //	ADD	A,n
  MatchBin[15] := 12;  //	#0C			; Add 12 to it
  MatchBin[16] := 95;  //	LD	E,A			; store it in E
  MatchBin[17] := 22;  //	LD	D,n
  MatchBin[18] := 0;   //	#00			; LD D,0
  MatchBin[19] := 33;  //	LD	HL,nn
  MatchBin[20] := 256; //	#EB
  MatchBin[21] := 256; //	34		; LD HL with a pointer to a frequency table???
  MatchBin[22] := 25;  //	ADD	HL,DE			; ADD DE to it, to get value for our note
  MatchBin[23] := 102; //	LD	H,(HL)			; LD H with value
  MatchBin[24] := 46;  //	LD	L,n
  MatchBin[25] := 1;   //	1
  MatchBin[26] := 201; //	RET
  MatchBin[27] := 35;  //	INC	HL
  MatchBin[28] := 94;  //	LD	E,(HL)
  MatchBin[29] := 35;  //	INC	HL
  MatchBin[30] := 86;  //	LD	D,(HL)
  MatchBin[31] := 43;  //	DEC	HL
  MatchBin[32] := 43;  //	DEC	HL
  MatchBin[33] := 24;   //	JR	d

  for i := 0 to 65535 - Length(MatchBin) do
  begin
    Result := i;
    for j := 0 to Length(MatchBin)-1 do
    begin
      if (MatchBin[j] < 256) and (Mem[i+j] <> MatchBin[j]) then
      begin
        Result := -1;
        break;
      end;
    end;
    if (Result > -1) then break;
  end;

  if Result > 100 then
  begin
    Result := Result - 36;
    if Mem[Result] <> 33 then
      Result := -1;
  end;
end;

function TSongRipper.ScanPhaser1DLinear(): integer;
var
  MatchBin: array [0..98] of word;
  i,j: integer;
begin
  MatchBin[0] := 33;    // LD HL,nn
  MatchBin[1] := 256;   // n1
  MatchBin[2] := 256;   // n2

  MatchBin[3] := 62;    // LD A,n
  MatchBin[4] := 256;   // n
  MatchBin[5] := 6;     // LD B,n
  MatchBin[6] := 256;   // n
  MatchBin[7] := 183;   // OR A
  MatchBin[8] := 14;    // LD C,n
  MatchBin[9] := 256;   // n
  MatchBin[10] := 32;   // JR NZ,+2
  MatchBin[11] := 02;   // dis
  MatchBin[12] := 14;   // LD C,n
  MatchBin[13] := 256;   // n
  MatchBin[14] := $79;   // LD A,C
  MatchBin[15] := 50;    // LD (nn),A
  MatchBin[16] := 256;   // n1
  MatchBin[17] := 256;   // n2
  MatchBin[18] := 120;   // LD A,B
  MatchBin[19] := 183;   // OR A
  MatchBin[20] := 1;     // LD BC,nn
  MatchBin[21] := 256;   // n1
  MatchBin[22] := 256;   // n2
  MatchBin[23] := 40;    // JR Z,dis
  MatchBin[24] := 256;   // dis
  MatchBin[25] := 1;     // LD BC,exitplayer
  MatchBin[26] := 256;   // n1
  MatchBin[27] := 256;   // n2
  MatchBin[28] := 237;   // prefix ED
  MatchBin[29] := 67;    // LD (nn),BC
  MatchBin[30] := 256;   // n1
  MatchBin[31] := 256;   // n2
  MatchBin[32] := 243;   // DI
  MatchBin[33] := 253;   // prefix IY
  MatchBin[34] := 229;   // PUSH IY
  MatchBin[35] := 94;    // LD E,(HL)
  MatchBin[36] := 35;    // INC HL
  MatchBin[37] := 86;    // LD   D,(HL)
  MatchBin[38] := 35;    // INC  HL
  MatchBin[39] := 34;    // LD   (nn),HL
  MatchBin[40] := 256;   // INSTRUM_TBL_1
  MatchBin[41] := 256;   // INSTRUM_TBL_2
  MatchBin[42] := 34;    // LD (nn),HL
  MatchBin[43] := 256;   // CURRENT_INST_1
  MatchBin[44] := 256;   // CURRENT_INST_2
  MatchBin[45] := 25;    // ADD HL,DE
  MatchBin[46] := 229;   // PUSH HL
  MatchBin[47] := 58;    // LD A,(nn)
  MatchBin[48] := 256;   // n1
  MatchBin[49] := 256;   // n2

  MatchBin[50] := 31;    // RRA
  MatchBin[51] := 31;    // RRA
  MatchBin[52] := 31;    // RRA
  MatchBin[53] := 230;   // AND n
  MatchBin[54] := 7;     // $07
  MatchBin[55] := 50;    // LD (nn),A
  MatchBin[56] := 256;   // n1
  MatchBin[57] := 256;   // n2
  MatchBin[58] := 38;    // LD H,n
  MatchBin[59] := 0;     // $00
  MatchBin[60] := 111;   // LD L,A
  MatchBin[61] := 34;    // LD (nn),HL
  MatchBin[62] := 256;   // CNT_1A_1
  MatchBin[63] := 256;   // CNT_1A_2
  MatchBin[64] := 34;   // LD (nn),HL
  MatchBin[65] := 256;  // CNT_1B_1
  MatchBin[66] := 256;  // CNT_1B_2
  MatchBin[67] := 34;   // LD (nn),HL
  MatchBin[68] := 256;  // DIV_1A_1
  MatchBin[69] := 256;  // DIV_1A_2
  MatchBin[70] := 34;   // LD (nn),HL
  MatchBin[71] := 256;  // DIV_1B_1
  MatchBin[72] := 256;  // DIV_1B_2
  MatchBin[73] := 34;   // LD (nn),HL
  MatchBin[74] := 256;  // CNT_2_1
  MatchBin[75] := 256;  // CNT_2_2
  MatchBin[76] := 34;   // LD (nn),HL
  MatchBin[77] := 256;  // DIV_2_1
  MatchBin[78] := 256;  // DIV_2_2
  MatchBin[79] := 62;   // LD A,n
  MatchBin[80] := 256;  // DIV_2_2
  MatchBin[81] := 50;   // LD (nn),A
  MatchBin[82] := 256;  // OUT_1_1
  MatchBin[83] := 256;  // OUT_1_2
  MatchBin[84] := 50;   // LD (nn),A
  MatchBin[85] := 256;  // OUT_2_1
  MatchBin[86] := 256;  // OUT_2_2
  MatchBin[87] := 225;  // POP HL
  MatchBin[88] := 34;   // LD (nn),HL
  MatchBin[89] := 256;  // SEQ_PTR_1
  MatchBin[90] := 256;  // SEQ_PTR_2
  MatchBin[91] := 253;  // prefix IY
  MatchBin[92] := 46;   // LD IYL,n
  MatchBin[93] := 00;   // $00
  MatchBin[94] := 33;   // LD HL,nn
  MatchBin[95] := 256;  // n1
  MatchBin[96] := 256;  // n2
  MatchBin[97] := 126;  // LD A,(HL)
  MatchBin[98] := 35;   // INC HL

  for i := 32768 to 65535 - Length(MatchBin) do
  begin
    Result := i;
    for j := 0 to Length(MatchBin)-1 do
    begin
      if (MatchBin[j] < 256) and (Mem[i+j] <> MatchBin[j]) then
      begin
        Result := -1;
        break;
      end;
    end;
    if (Result > -1) then break;
  end;

  if Result > 100 then
  begin
    if Mem[Result + 551] <> 214 then  // SUB n
      Result := -1
    else
      Result := Mem[Result+1] + 256 * Mem[Result+2];
  end;
end;

function TSongRipper.ScanPhaser1SLinear(): integer;
var
  MatchBin: array [0..98] of word;
  i,j: integer;
begin
  MatchBin[0] := 33;    // LD HL,nn
  MatchBin[1] := 256;   // n1
  MatchBin[2] := 256;   // n2

  MatchBin[3] := 62;    // LD A,n
  MatchBin[4] := 256;   // n
  MatchBin[5] := 6;     // LD B,n
  MatchBin[6] := 256;   // n
  MatchBin[7] := 183;   // OR A
  MatchBin[8] := 14;    // LD C,n
  MatchBin[9] := 256;   // n
  MatchBin[10] := 32;   // JR NZ,+2
  MatchBin[11] := 02;   // dis
  MatchBin[12] := 14;   // LD C,n
  MatchBin[13] := 256;   // n
  MatchBin[14] := $79;   // LD A,C
  MatchBin[15] := 50;    // LD (nn),A
  MatchBin[16] := 256;   // n1
  MatchBin[17] := 256;   // n2
  MatchBin[18] := 120;   // LD A,B
  MatchBin[19] := 183;   // OR A
  MatchBin[20] := 1;     // LD BC,nn
  MatchBin[21] := 256;   // n1
  MatchBin[22] := 256;   // n2
  MatchBin[23] := 40;    // JR Z,dis
  MatchBin[24] := 256;   // dis
  MatchBin[25] := 1;     // LD BC,exitplayer
  MatchBin[26] := 256;   // n1
  MatchBin[27] := 256;   // n2
  MatchBin[28] := 237;   // prefix ED
  MatchBin[29] := 67;    // LD (nn),BC
  MatchBin[30] := 256;   // n1
  MatchBin[31] := 256;   // n2
  MatchBin[32] := 243;   // DI
  MatchBin[33] := 253;   // prefix IY
  MatchBin[34] := 229;   // PUSH IY
  MatchBin[35] := 94;    // LD E,(HL)
  MatchBin[36] := 35;    // INC HL
  MatchBin[37] := 86;    // LD   D,(HL)
  MatchBin[38] := 35;    // INC  HL
  MatchBin[39] := 34;    // LD   (nn),HL
  MatchBin[40] := 256;   // INSTRUM_TBL_1
  MatchBin[41] := 256;   // INSTRUM_TBL_2
  MatchBin[42] := 34;    // LD (nn),HL
  MatchBin[43] := 256;   // CURRENT_INST_1
  MatchBin[44] := 256;   // CURRENT_INST_2
  MatchBin[45] := 25;    // ADD HL,DE
  MatchBin[46] := 229;   // PUSH HL
  MatchBin[47] := 58;    // LD A,(nn)
  MatchBin[48] := 256;   // n1
  MatchBin[49] := 256;   // n2

  MatchBin[50] := 31;    // RRA
  MatchBin[51] := 31;    // RRA
  MatchBin[52] := 31;    // RRA
  MatchBin[53] := 230;   // AND n
  MatchBin[54] := 7;     // $07
  MatchBin[55] := 50;    // LD (nn),A
  MatchBin[56] := 256;   // n1
  MatchBin[57] := 256;   // n2
  MatchBin[58] := 38;    // LD H,n
  MatchBin[59] := 0;     // $00
  MatchBin[60] := 111;   // LD L,A
  MatchBin[61] := 34;    // LD (nn),HL
  MatchBin[62] := 256;   // CNT_1A_1
  MatchBin[63] := 256;   // CNT_1A_2
  MatchBin[64] := 34;   // LD (nn),HL
  MatchBin[65] := 256;  // CNT_1B_1
  MatchBin[66] := 256;  // CNT_1B_2
  MatchBin[67] := 34;   // LD (nn),HL
  MatchBin[68] := 256;  // DIV_1A_1
  MatchBin[69] := 256;  // DIV_1A_2
  MatchBin[70] := 34;   // LD (nn),HL
  MatchBin[71] := 256;  // DIV_1B_1
  MatchBin[72] := 256;  // DIV_1B_2
  MatchBin[73] := 34;   // LD (nn),HL
  MatchBin[74] := 256;  // CNT_2_1
  MatchBin[75] := 256;  // CNT_2_2
  MatchBin[76] := 34;   // LD (nn),HL
  MatchBin[77] := 256;  // DIV_2_1
  MatchBin[78] := 256;  // DIV_2_2
  MatchBin[79] := 62;   // LD A,n
  MatchBin[80] := 256;  // DIV_2_2
  MatchBin[81] := 50;   // LD (nn),A
  MatchBin[82] := 256;  // OUT_1_1
  MatchBin[83] := 256;  // OUT_1_2
  MatchBin[84] := 50;   // LD (nn),A
  MatchBin[85] := 256;  // OUT_2_1
  MatchBin[86] := 256;  // OUT_2_2
  MatchBin[87] := 225;  // POP HL
  MatchBin[88] := 34;   // LD (nn),HL
  MatchBin[89] := 256;  // SEQ_PTR_1
  MatchBin[90] := 256;  // SEQ_PTR_2
  MatchBin[91] := 253;  // prefix IY
  MatchBin[92] := 46;   // LD IYL,n
  MatchBin[93] := 00;   // $00
  MatchBin[94] := 33;   // LD HL,nn
  MatchBin[95] := 256;  // n1
  MatchBin[96] := 256;  // n2
  MatchBin[97] := 126;  // LD A,(HL)
  MatchBin[98] := 35;   // INC HL

  for i := 32768 to 65535 - Length(MatchBin) do
  begin
    Result := i;
    for j := 0 to Length(MatchBin)-1 do
    begin
      if (MatchBin[j] < 256) and (Mem[i+j] <> MatchBin[j]) then
      begin
        Result := -1;
        break;
      end;
    end;
    if (Result > -1) then break;
  end;

  if Result > 100 then
  begin
    if Mem[Result + 551] <> 135 then  // ADD A,A
      Result := -1
    else
      Result := Mem[Result+1] + 256 * Mem[Result+2];
  end;
end;

function TSongRipper.ScanP1D(): integer;
var
  MatchBin: array [0..79] of word;
  i,j: integer;
begin
  MatchBin[0] := 33;    // LD HL,nn
  MatchBin[1] := 256;   // n1
  MatchBin[2] := 256;   // n2
  MatchBin[3] := 126;   // LD A,(HL)
  MatchBin[4] := 50;    // LD (PATTERN_LOOP_BEGIN),A
  MatchBin[5] := 256;   // n1
  MatchBin[6] := 256;   // n2
  MatchBin[7] := 35;    // INC HL
  MatchBin[8] := 126;   // LD A,(HL)
  MatchBin[9] := 50;    // LD (PATTERN_LOOP_END),A
  MatchBin[10] := 256;  // n1
  MatchBin[11] := 256;  // n2
  MatchBin[12] := 35;   // INC HL
  MatchBin[13] := 94;   // LD E,(HL)
  MatchBin[14] := 35;   // INC HL
  MatchBin[15] := 86;   // LD D,(HL)
  MatchBin[16] := 35;   // INC HL
  MatchBin[17] := 34;   // LD (INSTRUM_TBL),HL
  MatchBin[18] := 256;  // n1
  MatchBin[19] := 256;  // n2
  MatchBin[20] := 34;   // LD (CURRENT_INST),HL
  MatchBin[21] := 256;  // n1
  MatchBin[22] := 256;  // n2
  MatchBin[23] := 25;   // ADD HL,DE
  MatchBin[24] := 34;   // LD (PATTERN_ADDR),HL
  MatchBin[25] := 256;  // n1
  MatchBin[26] := 256;  // n2
  MatchBin[27] := 175;  // XOR A
  MatchBin[28] := 50;   // LD  (PATTERN_PTR),A
  MatchBin[29] := 256;  // n1
  MatchBin[30] := 256;  // n2
  MatchBin[31] := 103;  // LD H,A
  MatchBin[32] := 111;  // LD L,A
  MatchBin[33] := 34;   // LD (NOTE_PTR),HL
  MatchBin[34] := 256;  // n1
  MatchBin[35] := 256;  // n2
  MatchBin[36] := 243;  // DI
  MatchBin[37] := 253;  // prefix IY
  MatchBin[38] := 229;  // PUSH IY
  MatchBin[39] := 62;   // LD A,BORDER_COL
  MatchBin[40] := 256;  // n
  MatchBin[41] := 38;   // LD H,n
  MatchBin[42] := 0;    // $00
  MatchBin[43] := 111;  // LD L,A
  MatchBin[44] := 34;   // LD (nn),HL
  MatchBin[45] := 256;  // CNT_1A_1
  MatchBin[46] := 256;  // CNT_1A_2
  MatchBin[47] := 34;   // LD (nn),HL
  MatchBin[48] := 256;  // CNT_1B_1
  MatchBin[49] := 256;  // CNT_1B_2
  MatchBin[50] := 34;   // LD (nn),HL
  MatchBin[51] := 256;  // DIV_1A_1
  MatchBin[52] := 256;  // DIV_1A_2
  MatchBin[53] := 34;   // LD (nn),HL
  MatchBin[54] := 256;  // DIV_1B_1
  MatchBin[55] := 256;  // DIV_1B_2
  MatchBin[56] := 34;   // LD (nn),HL
  MatchBin[57] := 256;  // CNT_2_1
  MatchBin[58] := 256;  // CNT_2_2
  MatchBin[59] := 34;   // LD (nn),HL
  MatchBin[60] := 256;  // DIV_2_1
  MatchBin[61] := 256;  // DIV_2_2
  MatchBin[62] := 50;   // LD (nn),A
  MatchBin[63] := 256;  // OUT_1_1
  MatchBin[64] := 256;  // OUT_1_2
  MatchBin[65] := 50;   // LD (nn),A
  MatchBin[66] := 256;  // OUT_2_1
  MatchBin[67] := 256;  // OUT_2_2
  MatchBin[68] := 24;   // JR dis
  MatchBin[69] := 256;  // dis
  MatchBin[70] := 58;   // LD   A,(PATTERN_PTR)
  MatchBin[71] := 256;  // n1
  MatchBin[72] := 256;  // n2
  MatchBin[73] := 60;   // INC A
  MatchBin[74] := 60;   // INC A
  MatchBin[75] := 254;  // CP n
  MatchBin[76] := 256;  // n
  MatchBin[77] := 32;   // JR NZ,dis
  MatchBin[78] := 256;  // n
  MatchBin[79] := 62;   // LD A,n

  for i := 32768 to 65535 - Length(MatchBin) do
  begin
    Result := i;
    for j := 0 to Length(MatchBin)-1 do
    begin
      if (MatchBin[j] < 256) and (Mem[i+j] <> MatchBin[j]) then
      begin
        Result := -1;
        break;
      end;
    end;
    if (Result > -1) then break;
  end;

  if Result > 100 then
  begin
    if Mem[Result + 545] <> $D6 then  // SUB n
      Result := -1
    else
      Result := Mem[Result+1] + 256 * Mem[Result+2];
  end;
end;

function TSongRipper.ScanP1S(): integer;
var
  MatchBin: array [0..79] of word;
  i,j: integer;
begin
  MatchBin[0] := 33;    // LD HL,nn
  MatchBin[1] := 256;   // n1
  MatchBin[2] := 256;   // n2
  MatchBin[3] := 126;   // LD A,(HL)
  MatchBin[4] := 50;    // LD (PATTERN_LOOP_BEGIN),A
  MatchBin[5] := 256;   // n1
  MatchBin[6] := 256;   // n2
  MatchBin[7] := 35;    // INC HL
  MatchBin[8] := 126;   // LD A,(HL)
  MatchBin[9] := 50;    // LD (PATTERN_LOOP_END),A
  MatchBin[10] := 256;  // n1
  MatchBin[11] := 256;  // n2
  MatchBin[12] := 35;   // INC HL
  MatchBin[13] := 94;   // LD E,(HL)
  MatchBin[14] := 35;   // INC HL
  MatchBin[15] := 86;   // LD D,(HL)
  MatchBin[16] := 35;   // INC HL
  MatchBin[17] := 34;   // LD (INSTRUM_TBL),HL
  MatchBin[18] := 256;  // n1
  MatchBin[19] := 256;  // n2
  MatchBin[20] := 34;   // LD (CURRENT_INST),HL
  MatchBin[21] := 256;  // n1
  MatchBin[22] := 256;  // n2
  MatchBin[23] := 25;   // ADD HL,DE
  MatchBin[24] := 34;   // LD (PATTERN_ADDR),HL
  MatchBin[25] := 256;  // n1
  MatchBin[26] := 256;  // n2
  MatchBin[27] := 175;  // XOR A
  MatchBin[28] := 50;   // LD  (PATTERN_PTR),A
  MatchBin[29] := 256;  // n1
  MatchBin[30] := 256;  // n2
  MatchBin[31] := 103;  // LD H,A
  MatchBin[32] := 111;  // LD L,A
  MatchBin[33] := 34;   // LD (NOTE_PTR),HL
  MatchBin[34] := 256;  // n1
  MatchBin[35] := 256;  // n2
  MatchBin[36] := 243;  // DI
  MatchBin[37] := 253;  // prefix IY
  MatchBin[38] := 229;  // PUSH IY
  MatchBin[39] := 62;   // LD A,BORDER_COL
  MatchBin[40] := 256;  // n
  MatchBin[41] := 38;   // LD H,n
  MatchBin[42] := 0;    // $00
  MatchBin[43] := 111;  // LD L,A
  MatchBin[44] := 34;   // LD (nn),HL
  MatchBin[45] := 256;  // CNT_1A_1
  MatchBin[46] := 256;  // CNT_1A_2
  MatchBin[47] := 34;   // LD (nn),HL
  MatchBin[48] := 256;  // CNT_1B_1
  MatchBin[49] := 256;  // CNT_1B_2
  MatchBin[50] := 34;   // LD (nn),HL
  MatchBin[51] := 256;  // DIV_1A_1
  MatchBin[52] := 256;  // DIV_1A_2
  MatchBin[53] := 34;   // LD (nn),HL
  MatchBin[54] := 256;  // DIV_1B_1
  MatchBin[55] := 256;  // DIV_1B_2
  MatchBin[56] := 34;   // LD (nn),HL
  MatchBin[57] := 256;  // CNT_2_1
  MatchBin[58] := 256;  // CNT_2_2
  MatchBin[59] := 34;   // LD (nn),HL
  MatchBin[60] := 256;  // DIV_2_1
  MatchBin[61] := 256;  // DIV_2_2
  MatchBin[62] := 50;   // LD (nn),A
  MatchBin[63] := 256;  // OUT_1_1
  MatchBin[64] := 256;  // OUT_1_2
  MatchBin[65] := 50;   // LD (nn),A
  MatchBin[66] := 256;  // OUT_2_1
  MatchBin[67] := 256;  // OUT_2_2
  MatchBin[68] := 24;   // JR dis
  MatchBin[69] := 256;  // dis
  MatchBin[70] := 58;   // LD   A,(PATTERN_PTR)
  MatchBin[71] := 256;  // n1
  MatchBin[72] := 256;  // n2
  MatchBin[73] := 60;   // INC A
  MatchBin[74] := 60;   // INC A
  MatchBin[75] := 254;  // CP n
  MatchBin[76] := 256;  // n
  MatchBin[77] := 32;   // JR NZ,dis
  MatchBin[78] := 256;  // n
  MatchBin[79] := 62;   // LD A,n

  for i := 32768 to 65535 - Length(MatchBin) do
  begin
    Result := i;
    for j := 0 to Length(MatchBin)-1 do
    begin
      if (MatchBin[j] < 256) and (Mem[i+j] <> MatchBin[j]) then
      begin
        Result := -1;
        break;
      end;
    end;
    if (Result > -1) then break;
  end;

  if Result > 100 then
  begin
    if Mem[Result + 545] <> 135 then  // ADD A,A
      Result := -1
    else
      Result := Mem[Result+1] + 256 * Mem[Result+2];
  end;
end;


end.
