unit STSong;

interface

uses STPatterns, STInstruments, Classes;

type
  TSTSong = class(TObject)
  private
    FSongLength: integer;
    FSongLoopStart: integer;
    FSongTitle: string;
    FSongAuthor: string;
    FSongLayout: array [0..1024] of byte;
    FPreferredEngine: string;
    function GetSongLayout(iIndex: integer): byte;
    procedure SetSongLayout(iIndex: integer; const Value: byte);
    function LoadV1BBSongFile(F: TFileStream): boolean;
    function ReadBBSong1Block_INFO(F: TFileStream): boolean;
    function ReadBBSong1Block_LAYOUT(F: TFileStream): boolean;
    function ReadBBSong1Block_PATTERNDATA(F: TFileStream): boolean;
    procedure SetPreferredEngine(const Value: string);
    function ReadBBSong1Block_P1INSTR(F: TFileStream): boolean;
    function ReadBBSong1Block_SVGPATTERNDATA(F: TFileStream): boolean;
    function ReadBBSong1Block_SVGORNAMENTS(F: TFileStream): boolean;
    function ReadBBSong1Block_SVGWARPDATA(F: TFileStream): boolean;
  public
    Pattern: array [0..255] of TPattern;
    SvgPatternData: array [0..255] of TPatternSVG;
    Phaser1Instrument: array [0..99] of TP1DInstrument;
    SVGArpeggio: array [0..31] of TSVGArpeggio;
    property SongLayout[iIndex: integer]: byte read GetSongLayout write SetSongLayout;
    property LoopStart: integer read FSongLoopStart write FSongLoopStart;
    property SongLength: integer read FSongLength;
    property SongTitle: string read FSongTitle write FSongTitle;
    property SongAuthor: string read FSongAuthor write FSongAuthor;
    property PreferredEngine: string read FPreferredEngine write SetPreferredEngine;
    function SaveFile(sFileName: string): boolean;
    function LoadFile(sFileName: string): boolean;
    function DeleteSongLayoutItem(iIndex: integer): boolean;
    function InsertSongLayoutItem(iIndex: integer): boolean;
    function IsPatternUsed(iPat: integer): boolean;
    function MelodyMatch(iPat1,iPat2: integer; bCheckSustain: boolean): boolean;
    function MelodyMatchSVG(iChan, iPat1, iPat2: integer): boolean;    
    function PercussionMatch(iPat1, iPat2: integer): boolean;
    function IsPatternEmpty(iPat: integer): boolean;
    function GetHighestInstrument(): integer;
    function IsInstrumentUsed(iInst: integer): boolean;
    function IsOrnamentUsed(iArp: integer): boolean;
    function GetHighestArpeggio: integer;    
    function DeleteSVGOrnItem(iOrn, iIndex: integer): boolean;
    function InsertSVGOrnItem(iOrn, iIndex: integer): boolean;
    procedure Clear;
    constructor Create();
    destructor Destroy(); override;
  end;

implementation

{ TSTSong }

uses SysUtils;

constructor TSTSong.Create;
begin
  Clear();

  inherited;
end;

function TSTSong.DeleteSongLayoutItem(iIndex: integer): boolean;
var
  i: integer;
begin
  if (iIndex >= 0) and (iIndex < FSongLength) then
  begin
    for i := iIndex to FSongLength - 2 do
      FSongLayout[i] := FSongLayout[i+1];
    Dec(FSongLength);
    FSongLayout[FSongLength] := 255;
    Result := true;
  end
  else
    Result := false;
end;

function TSTSong.InsertSongLayoutItem(iIndex: integer): boolean;
var
  i: integer;
begin
  if (iIndex >= 0) and (iIndex < FSongLength) then
  begin
    for i := FSongLength - 1 downto iIndex do
      FSongLayout[i+1] := FSongLayout[i];
    Inc(FSongLength);
    Result := true;
  end
  else
    Result := false;
end;

function TSTSong.DeleteSVGOrnItem(iOrn, iIndex: integer): boolean;
var
  i: integer;
begin
  if (iIndex >= 1) and (iIndex <= SVGArpeggio[iOrn].Length) then
  begin
    for i := iIndex to SVGArpeggio[iOrn].Length - 1 do
      SVGArpeggio[iOrn].Value[i] := SVGArpeggio[iOrn].Value[i+1];

    SVGArpeggio[iOrn].Value[SVGArpeggio[iOrn].Length] := 255;
    Dec(SVGArpeggio[iOrn].Length);
    Result := true;
  end
  else
    Result := false;
end;

function TSTSong.InsertSVGOrnItem(iOrn, iIndex: integer): boolean;
var
  i: integer;
begin
  if (iIndex >= 1) and (iIndex <= SVGArpeggio[iOrn].Length) then
  begin
    for i := SVGArpeggio[iOrn].Length downto iIndex do
      SVGArpeggio[iOrn].Value[i+1] := SVGArpeggio[iOrn].Value[i];
    Inc(SVGArpeggio[iOrn].Length);
    Result := true;
  end
  else
    Result := false;
end;

function TSTSong.IsPatternEmpty(iPat: integer): boolean;
var
  i: integer;
begin
  Result := true;

  if PreferredEngine = 'SVG' then
  begin
    // Savage pattern (2xchan,2xsust,1xdrum,2xglis,2xskew,2xskewxor,2xarp)
    for i := 1  to Pattern[iPat].Length do
    begin
      if (Pattern[iPat].Chan[1][i] <> 255) or (Pattern[iPat].Chan[2][i]  <> 255) or
         (Pattern[iPat].Sustain[1][i] <> 255) or (Pattern[iPat].Sustain[2][i] <> 255) or
         (Pattern[iPat].Drum[i] <> 0) or
         (SvgPatternData[iPat].Glissando[1][i] <> 256) or  (SvgPatternData[iPat].Glissando[2][i] <> 256) or
         (SvgPatternData[iPat].Skew[1][i] <> 256) or  (SvgPatternData[iPat].Skew[2][i] <> 256) or
         (SvgPatternData[iPat].SkewXOR[1][i] <> 256) or  (SvgPatternData[iPat].SkewXOR[2][i] <> 256) or
         (SvgPatternData[iPat].Arpeggio[1][i] <> 256) or  (SvgPatternData[iPat].Arpeggio[2][i] <> 256) then
      begin
        Result := false;
        exit;
      end;
    end;
  end
  else
  begin
    // Standard pattern (2xchan, 2xsust, 1xdrum)
    for i := 1  to Pattern[iPat].Length do
    begin
      if (Pattern[iPat].Chan[1][i] <> 255) or (Pattern[iPat].Chan[2][i]  <> 255) or
         (Pattern[iPat].Sustain[1][i] <> 255) or (Pattern[iPat].Sustain[2][i] <> 255) or
         (Pattern[iPat].Drum[i] <> 0) then
      begin
        Result := false;
        exit;
      end;
    end;
  end;


end;

function TSTSong.IsPatternUsed(iPat: integer): boolean;
var
  i: integer;
begin
  for i := 0 to FSongLength - 1 do
  begin
    if FSongLayout[i] = iPat then
    begin
      Result := true;
      exit;
    end;
  end;

  Result := false;
end;

destructor TSTSong.Destroy;
begin

  inherited;
end;

procedure TSTSong.Clear();
var
  i,j: integer;
  k: Integer;
begin
  FSongLength := 1;
  FSongLoopStart := 0;
  FSongTitle := '';
  FSongAuthor := '';
  FPreferredEngine := 'SFX';

  for i := 0 to 255 do
  begin
    Pattern[i].Length := 16;
    Pattern[i].Tempo := 14;
    for j := 1 to 256 do
    begin
      Pattern[i].Name := '';
      Pattern[i].Chan[1][j] := 255;
      Pattern[i].Chan[2][j] := 255;
      Pattern[i].Drum[j] := 0;
      Pattern[i].Sustain[1][j] := 255;
      Pattern[i].Sustain[2][j] := 255;
      SvgPatternData[i].Glissando[1][j] := 256; // 256 = no value
      SvgPatternData[i].Glissando[2][j] := 256; // 256 = no value
      SvgPatternData[i].Skew[1][j] := 256;
      SvgPatternData[i].Skew[2][j] := 256;
      SvgPatternData[i].SkewXOR[1][j] := 256;
      SvgPatternData[i].SkewXOR[2][j] := 256;
      SvgPatternData[i].Arpeggio[1][j] := 256;
      SvgPatternData[i].Arpeggio[2][j] := 256;
      SvgPatternData[i].Warp[1][j] := 0;
      SvgPatternData[i].Warp[2][j] := 0;
    end;
    for j := 0 to 99 do
    begin
      Phaser1Instrument[i].Multiple := 01;
      Phaser1Instrument[i].Detune := 0;
      Phaser1Instrument[i].Phase := 0;
    end;
    for j := 0 to 31 do
    begin
      SvgArpeggio[j].Length := 0;
      for k := 1 to 256 do
        SvgArpeggio[j].Value[k] := 255;
    end;
    SvgArpeggio[1].Length := 3;
    SvgArpeggio[1].Value[1] := 0; SvgArpeggio[1].Value[2] := 4; SvgArpeggio[1].Value[3] := 7 or $80;
    SvgArpeggio[2].Length := 4;
    SvgArpeggio[2].Value[1] := 12; SvgArpeggio[2].Value[2] := 0;
    SvgArpeggio[2].Value[3] := 12; SvgArpeggio[2].Value[4] := 12;
  end;
  FSongLayout[0] := 0;
  for i := 1 to 1024 do
    FSongLayout[i] := 255;
end;

function TSTSong.GetHighestInstrument: integer;
var
  i, j: integer;
begin
  Result := -1;
  for i := 0 to FSongLength-1 do
  begin
    for j := 1 to Pattern[FSongLayout[i]].Length do
    begin
      if (Pattern[FSongLayout[i]].Sustain[2][j] < 255) and (Pattern[FSongLayout[i]].Sustain[2][j] > Result) then
        Result := Pattern[FSongLayout[i]].Sustain[2][j];
    end;
  end;

  if Result > 99 then Result := 99;
end;

function TSTSong.GetHighestArpeggio: integer;
var
  i, j: integer;
begin
  Result := 0;
  for i := 0 to FSongLength-1 do
  begin
    for j := 1 to Pattern[FSongLayout[i]].Length do
    begin
      if (SvgPatternData[FSongLayout[i]].Arpeggio[1][j] < 32) and (SvgPatternData[FSongLayout[i]].Arpeggio[1][j] > Result) then
        Result := SvgPatternData[FSongLayout[i]].Arpeggio[1][j];
      if (SvgPatternData[FSongLayout[i]].Arpeggio[2][j] < 32) and (SvgPatternData[FSongLayout[i]].Arpeggio[2][j] > Result) then
        Result := SvgPatternData[FSongLayout[i]].Arpeggio[2][j];
    end;
  end;

  if Result > 31 then Result := 31;
end;

function TSTSong.IsInstrumentUsed(iInst: integer): boolean;
var
  iPat, i, j: integer;
begin
  Result := false;

  for j := 0 to FSongLength-1 do
  begin
    iPat := FSongLayout[j];
    for i := 1 to Pattern[iPat].Length do
    begin
      if Pattern[iPat].Sustain[2][i] = iInst then
      begin
        Result := true;
        exit;
      end;
    end;
  end;
end;

function TSTSong.IsOrnamentUsed(iArp: integer): boolean;
var
  iPat, i, j: integer;
begin
  Result := false;

  for j := 0 to FSongLength-1 do
  begin
    iPat := FSongLayout[j];
    for i := 1 to Pattern[iPat].Length do
    begin
      if (SvgPatternData[iPat].Arpeggio[1][i] = iArp) or
         (SvgPatternData[iPat].Arpeggio[2][i] = iArp) then
      begin
        Result := true;
        exit;
      end;
    end;
  end;
end;

function TSTSong.GetSongLayout(iIndex: integer): byte;
begin
  Result := FSongLayout[iIndex];
end;

function TSTSong.SaveFile(sFileName: string): boolean;
var
  F: TFileStream;
  sData: string;
  i,j: Integer;
begin
  Result := true;
  try
    F := TFileStream.Create(sFileName, fmCreate or fmShareDenyWrite);
    F.Write('BBSONG'#0'0001'#0,12);
    F.Write(':INFO'#0,6);
    sData := 'Title=' + FSongTitle + #0;
    F.Write(sData[1],Length(sData));
    sData := 'Author=' + FSongAuthor + #0;
    F.Write(sData[1],Length(sData));
    sData := 'Engine=' + FPreferredEngine + #0;
    F.Write(sData[1],Length(sData));
    F.Write(':END'#0,5);
    F.Write(':LAYOUT'#0,8);
    sData := 'LoopStart=' + IntToStr(FSongLoopStart) + #0;
    F.Write(sData[1],Length(sData));
    sData := 'Length=' + IntToStr(FSongLength) + #0;
    F.Write(sData[1],Length(sData));
    for i := 0 to FSongLength - 1 do
      F.Write(FSongLayout[i],SizeOf(byte));
    F.Write(':END'#0,5);      
    F.Write(':PATTERNDATA'#0,13);
    sData := 'PatternCount=127' + #0;
    F.Write(sData[1],Length(sData));
    for i := 0 to 126 do
    begin
      sData := 'PatternName=' + Pattern[i].Name  + #0;
      F.Write(sData[1],Length(sData));
      F.Write(Pattern[i].Length,SizeOf(Pattern[i].Length));
      F.Write(Pattern[i].Tempo,SizeOf(Pattern[i].Tempo));
      F.Write(Pattern[i].Chan[1],Pattern[i].Length);
      F.Write(Pattern[i].Chan[2],Pattern[i].Length);
      F.Write(Pattern[i].Drum,Pattern[i].Length);
      F.Write(Pattern[i].Sustain[1],Pattern[i].Length);
      F.Write(Pattern[i].Sustain[2],Pattern[i].Length);      
    end;
    F.Write(':END'#0,5);
    if (FPreferredEngine = 'SVG') then
    begin
      F.Write(':SVGPATTERNDATA'#0,16);
      sData := 'PatternCount=127' + #0;
      F.Write(sData[1],Length(sData));
      for i := 0 to 126 do
      begin
        F.Write(Pattern[i].Length,SizeOf(Pattern[i].Length));
        F.Write(SvgPatternData[i].Glissando[1],Pattern[i].Length * SizeOf(SvgPatternData[i].Glissando[1][1]));
        F.Write(SvgPatternData[i].Glissando[2],Pattern[i].Length * SizeOf(SvgPatternData[i].Glissando[2][1]));
        F.Write(SvgPatternData[i].Skew[1],Pattern[i].Length * SizeOf(SvgPatternData[i].Skew[1][1]));
        F.Write(SvgPatternData[i].Skew[2],Pattern[i].Length * SizeOf(SvgPatternData[i].Skew[2][1]));
        F.Write(SvgPatternData[i].SkewXOR[1],Pattern[i].Length * SizeOf(SvgPatternData[i].SkewXOR[1][1]));
        F.Write(SvgPatternData[i].SkewXOR[2],Pattern[i].Length * SizeOf(SvgPatternData[i].SkewXOR[2][1]));
        F.Write(SvgPatternData[i].Arpeggio[1],Pattern[i].Length * SizeOf(SvgPatternData[i].Arpeggio[1][1]));
        F.Write(SvgPatternData[i].Arpeggio[2],Pattern[i].Length * SizeOf(SvgPatternData[i].Arpeggio[2][1]));
      end;
      F.Write(':END'#0,5);
      F.Write(':SVGWARPDATA'#0,13);
      sData := 'PatternCount=127' + #0;
      F.Write(sData[1],Length(sData));
      for i := 0 to 126 do
      begin
        F.Write(Pattern[i].Length,SizeOf(Pattern[i].Length));
        F.Write(SvgPatternData[i].Warp[1],Pattern[i].Length * SizeOf(SvgPatternData[i].Warp[1][1]));
        F.Write(SvgPatternData[i].Warp[2],Pattern[i].Length * SizeOf(SvgPatternData[i].Warp[2][1]));
      end;
      F.Write(':END'#0,5);
      F.Write(':SVGORNAMENTS'#0,14);
      sData := 'OrnamentCount=32' + #0;
      F.Write(sData[1],Length(sData));
      for i := 0 to 31 do
      begin
        F.Write(SvgArpeggio[i].Length,SizeOf(SvgArpeggio[i].Length));
        for j := 1 to SvgArpeggio[i].Length-1 do
        begin
          SvgArpeggio[i].Value[j] := SvgArpeggio[i].Value[j] and $7F;
          F.Write(SvgArpeggio[i].Value[j],SizeOf(SvgArpeggio[i].Value[j]));
        end;

        if SvgArpeggio[i].Length > 0 then
          F.Write(SvgArpeggio[i].Value[SvgArpeggio[i].Length],SizeOf(SvgArpeggio[i].Value[SvgArpeggio[i].Length]));
      end;
      F.Write(':END'#0,5);
    end;
    if (FPreferredEngine = 'P1D') or (FPreferredEngine = 'P1S') then
    begin
      F.Write(':P1INSTR'#0,9);
      sData := 'Length=100'#0;
      F.Write(sData[1],Length(sData));
      for i := 0 to 99 do
      begin
        F.Write(Phaser1Instrument[i].Multiple,SizeOf(byte));  // Siiiiize of a mouse!
        F.Write(Phaser1Instrument[i].Detune,SizeOf(integer)); // Siiiiize of an antelope!
        F.Write(Phaser1Instrument[i].Phase,SizeOf(byte));     // Siiiiize of a byte!
      end;
      F.Write(':END'#0,5);
    end;
  except
    on Exception do
      Result := false;
  end;
  FreeAndNil(F);
end;

function StreamGetNullString(F: TFileStream; out bEOF: boolean): string;
var
  i, iLen: integer;
  c: array [0..1026] of char;
begin
  bEOF := true;

  iLen := F.Read(c,1024);
  for i := 0 to iLen-2 do begin
    if (c[i] = #0) then
    begin
      F.Seek(-iLen+i+1,soFromCurrent);
      Result := Copy(c,0,i);
      bEOF := false;
      break;
    end;
  end;

  if bEof then
    Result := Copy(c,0,iLen);
end;

function TSTSong.ReadBBSong1Block_INFO(F: TFileStream): boolean;
var
  sData,sProp: string;
  bEOF: boolean;
begin
  Result := false;
  while F.Position < F.Size do
  begin
    sData := StreamGetNullString(F,bEOF);
    if sData = ':END' then
    begin
      Result := true;
      exit;
    end;

    sProp := Copy(sData,1,Pos('=',sData)-1);
    sData := Copy(sData,Pos('=',sData)+1,1024);
    if sProp = 'Title' then FSongTitle := sData;
    if sProp = 'Author' then FSongAuthor := sData;
    if sProp = 'Engine' then SetPreferredEngine(sData);
  end;
end;

function TSTSong.ReadBBSong1Block_LAYOUT(F: TFileStream): boolean;
var
  sData,sProp: string;
  bEOF: boolean;
  i: integer;
begin
  Result := false;
  while F.Position < F.Size do
  begin
    sData := StreamGetNullString(F,bEOF);
    if sData = ':END' then
    begin
      Result := true;
      exit;
    end;

    sProp := Copy(sData,1,Pos('=',sData)-1);
    sData := Copy(sData,Pos('=',sData)+1,1024);
    if sProp = 'LoopStart' then FSongLoopStart := StrToIntDef(sData,0);
    if sProp = 'Length' then
    begin
      FSongLength := StrToIntDef(sData,0);
      for i := 0 to FSongLength - 1 do
        F.Read(FSongLayout[i],SizeOf(byte));
    end;
  end;
end;

function TSTSong.ReadBBSong1Block_PATTERNDATA(F: TFileStream): boolean;
var
  sData, sProp: string;
  bEOF: boolean;
  i, iPatternCount: integer;
begin
  Result := true;
  while F.Position < F.Size do
  begin
    sData := StreamGetNullString(F,bEOF);
    if sData = ':END' then
    begin
      Result := true;
      exit;
    end;

    sProp := Copy(sData,1,Pos('=',sData)-1);
    sData := Copy(sData,Pos('=',sData)+1,1024);
    if sProp = 'PatternCount' then
    begin
      iPatternCount := StrToIntDef(sData,0);
      for i := 0 to iPatternCount - 1 do
      begin
        sData := StreamGetNullString(F,bEOF);
        sProp := Copy(sData,1,Pos('=',sData)-1);
        sData := Copy(sData,Pos('=',sData)+1,1024);
        if sProp = 'PatternName' then
        begin
          Pattern[i].Name := sData;
          F.Read(Pattern[i].Length,SizeOf(Pattern[i].Length));
          F.Read(Pattern[i].Tempo,SizeOf(Pattern[i].Tempo));
          F.Read(Pattern[i].Chan[1],Pattern[i].Length);
          F.Read(Pattern[i].Chan[2],Pattern[i].Length);
          F.Read(Pattern[i].Drum,Pattern[i].Length);
          F.Read(Pattern[i].Sustain[1],Pattern[i].Length);
          F.Read(Pattern[i].Sustain[2],Pattern[i].Length);
        end;
      end;
    end;
  end;
end;

function TSTSong.ReadBBSong1Block_SVGPATTERNDATA(F: TFileStream): boolean;
var
  sData, sProp: string;
  bEOF: boolean;
  i, iPatternCount, iPatLen: integer;
begin
  Result := true;
  while F.Position < F.Size do
  begin
    sData := StreamGetNullString(F,bEOF);
    if sData = ':END' then
    begin
      Result := true;
      exit;
    end;

    sProp := Copy(sData,1,Pos('=',sData)-1);
    sData := Copy(sData,Pos('=',sData)+1,1024);
    if sProp = 'PatternCount' then
    begin
      iPatternCount := StrToIntDef(sData,0);
      for i := 0 to iPatternCount - 1 do
      begin
        F.Read(iPatLen,SizeOf(iPatLen));
        F.Read(SvgPatternData[i].Glissando[1],iPatLen * 2);
        F.Read(SvgPatternData[i].Glissando[2],iPatLen * 2);
        F.Read(SvgPatternData[i].Skew[1],iPatLen * 2);
        F.Read(SvgPatternData[i].Skew[2],iPatLen * 2);
        F.Read(SvgPatternData[i].SkewXOR[1],iPatLen * 2);
        F.Read(SvgPatternData[i].SkewXOR[2],iPatLen * 2);
        F.Read(SvgPatternData[i].Arpeggio[1],iPatLen * 2);
        F.Read(SvgPatternData[i].Arpeggio[2],iPatLen * 2);
      end;
    end;
  end;
end;

function TSTSong.ReadBBSong1Block_SVGWARPDATA(F: TFileStream): boolean;
var
  sData, sProp: string;
  bEOF: boolean;
  i, iPatternCount, iPatLen: integer;
begin
  Result := true;
  while F.Position < F.Size do
  begin
    sData := StreamGetNullString(F,bEOF);
    if sData = ':END' then
    begin
      Result := true;
      exit;
    end;

    sProp := Copy(sData,1,Pos('=',sData)-1);
    sData := Copy(sData,Pos('=',sData)+1,1024);
    if sProp = 'PatternCount' then
    begin
      iPatternCount := StrToIntDef(sData,0);
      for i := 0 to iPatternCount - 1 do
      begin
        F.Read(iPatLen,SizeOf(iPatLen));
        F.Read(SvgPatternData[i].Warp[1],iPatLen);
        F.Read(SvgPatternData[i].Warp[2],iPatLen);
      end;
    end;
  end;
end;

function TSTSong.ReadBBSong1Block_P1INSTR(F: TFileStream): boolean;
var
  sData, sProp: string;
  bEOF: boolean;
  i, iInstCount: integer;
begin
  Result := true;
  while F.Position < F.Size do
  begin
    sData := StreamGetNullString(F,bEOF);
    if sData = ':END' then
    begin
      Result := true;
      exit;
    end;

    sProp := Copy(sData,1,Pos('=',sData)-1);
    sData := Copy(sData,Pos('=',sData)+1,1024);
    if sProp = 'Length' then
    begin
      iInstCount := StrToIntDef(sData,0);
      for i := 0 to iInstCount do
      begin
        F.Read(Phaser1Instrument[i].Multiple,SizeOf(Phaser1Instrument[i].Multiple));
        F.Read(Phaser1Instrument[i].Detune,SizeOf(Phaser1Instrument[i].Detune));
        F.Read(Phaser1Instrument[i].Phase,SizeOf(Phaser1Instrument[i].Phase));
      end;
    end;

  end;
end;

function TSTSong.ReadBBSong1Block_SVGORNAMENTS(F: TFileStream): boolean;
var
  sData, sProp: string;
  bEOF: boolean;
  i, j, iOrnCount: integer;
begin
  Result := true;
  while F.Position < F.Size do
  begin
    sData := StreamGetNullString(F,bEOF);
    if sData = ':END' then
    begin
      Result := true;
      exit;
    end;

    sProp := Copy(sData,1,Pos('=',sData)-1);
    sData := Copy(sData,Pos('=',sData)+1,1024);
    if sProp = 'OrnamentCount' then
    begin
      iOrnCount := StrToIntDef(sData,0);
      for i := 0 to iOrnCount - 1 do
      begin
        F.Read(SvgArpeggio[i].Length,SizeOf(SvgArpeggio[i].Length));
        for j := 1 to 256 do
          SvgArpeggio[i].Value[j] := 255;
          
        for j := 1 to SvgArpeggio[i].Length do
          F.Read(SvgArpeggio[i].Value[j],SizeOf(SvgArpeggio[i].Value[j]));
      end;
    end;
  end;
end;

function TSTSong.LoadV1BBSongFile(F: TFileStream): boolean;
var
  sData: string;
  bEOF: boolean;
begin
  Result := false;

  while F.Position < F.Size do
  begin
    sData := StreamGetNullString(F,bEOF);
    if Copy(sData,1,1) <> ':' then exit;
    sData := Copy(sData,2,254);

    if sData = 'INFO' then Result := ReadBBSong1Block_INFO(F)
    else if sData = 'LAYOUT' then Result := ReadBBSong1Block_LAYOUT(F)
    else if sData = 'PATTERNDATA' then Result := ReadBBSong1Block_PATTERNDATA(F)
    else if sData = 'SVGPATTERNDATA' then Result := ReadBBSong1Block_SVGPATTERNDATA(F)
    else if sData = 'SVGWARPDATA' then Result := ReadBBSong1Block_SVGWARPDATA(F)
    else if sData = 'P1INSTR' then Result := ReadBBSong1Block_P1INSTR(F)
    else if sData = 'SVGORNAMENTS' then Result := ReadBBSong1Block_SVGORNAMENTS(F)    
    else Result := true; // Unhandled Data Block
    if not Result then exit;
  end;

end;

function TSTSong.MelodyMatch(iPat1, iPat2: integer; bCheckSustain: boolean): boolean;
var
  i: integer;
begin
  Result := false;

  if (Pattern[iPat1].Length <> Pattern[iPat2].Length) or
     (Pattern[iPat1].Tempo  <> Pattern[iPat2].Tempo) then exit;

  for i := 1 to Pattern[iPat1].Length do
  begin
    if (Pattern[iPat1].Chan[1][i] <> Pattern[iPat2].Chan[1][i]) then exit;
    if (Pattern[iPat1].Chan[2][i] <> Pattern[iPat2].Chan[2][i]) then exit;
    if bCheckSustain then
    begin
      if (Pattern[iPat1].Sustain[1][i] <> Pattern[iPat2].Sustain[1][i]) then exit;
      if (Pattern[iPat1].Sustain[2][i] <> Pattern[iPat2].Sustain[2][i]) then exit;
    end;
  end;

  Result := true;
end;

function TSTSong.MelodyMatchSVG(iChan, iPat1, iPat2: integer): boolean;
var
  i: integer;
begin
  Result := false;

  if (Pattern[iPat1].Length <> Pattern[iPat2].Length) or
     (Pattern[iPat1].Tempo  <> Pattern[iPat2].Tempo) then exit;

  for i := 1 to Pattern[iPat1].Length do
  begin
    if (Pattern[iPat1].Chan[iChan][i] <> Pattern[iPat2].Chan[iChan][i]) then exit;
    if (SvgPatternData[iPat1].Glissando[iChan][i] <>  SvgPatternData[iPat2].Glissando[iChan][i]) then exit;
    if (SvgPatternData[iPat1].Skew[iChan][i] <>  SvgPatternData[iPat2].Skew[iChan][i]) then exit;
    if (SvgPatternData[iPat1].SkewXor[iChan][i] <>  SvgPatternData[iPat2].SkewXor[iChan][i]) then exit;
    if (SvgPatternData[iPat1].Arpeggio[iChan][i] <>  SvgPatternData[iPat2].Arpeggio[iChan][i]) then exit;
  end;

  Result := true;
end;

function TSTSong.PercussionMatch(iPat1, iPat2: integer): boolean;
var
  i: integer;
begin
  Result := false;

  if (Pattern[iPat1].Length <> Pattern[iPat2].Length) or
     (Pattern[iPat1].Tempo  <> Pattern[iPat2].Tempo) then exit;

  for i := 1 to Pattern[iPat1].Length do
  begin
    if (Pattern[iPat1].Drum[i] <> Pattern[iPat2].Drum[i]) then exit;
  end;

  Result := true;
end;

function TSTSong.LoadFile(sFileName: string): boolean;
var
  F: TFileStream;
  sData: string;
  bEOF: boolean;
begin
  Result := false;
  Clear();
  try
    F := TFileStream.Create(sFileName, fmOpenRead or fmShareDenyNone);
    sData := StreamGetNullString(F,bEOF);
    if sData <> 'BBSONG' then exit;
    sData := StreamGetNullString(F,bEOF);
    if sData <> '0001' then exit;
    Result := LoadV1BBSongFile(F)
  finally
    FreeAndNil(F);
  end;
end;

procedure TSTSong.SetPreferredEngine(const Value: string);
begin
  if UpperCase(Value) = 'SFX' then
    FPreferredEngine := 'SFX'
  else if UpperCase(Value) = 'TMB' then
    FPreferredEngine := 'TMB'
  else if UpperCase(Value) = 'MSD' then
    FPreferredEngine := 'MSD'
  else if UpperCase(Value) = 'P1D' then
    FPreferredEngine := 'P1D'
  else if UpperCase(Value) = 'P1S' then
    FPreferredEngine := 'P1S'
  else if UpperCase(Value) = 'SVG' then
    FPreferredEngine := 'SVG'
  else if UpperCase(Value) = 'RMB' then
    FPreferredEngine := 'RMB'
  else if UpperCase(Value) = 'PLP' then
    FPreferredEngine := 'PLP'
  else if UpperCase(Value) = 'STK' then
    FPreferredEngine := 'STK';
end;

procedure TSTSong.SetSongLayout(iIndex: integer; const Value: byte);
begin
  FSongLayout[iIndex] := Value;
  if iIndex > (FSongLength-1) then
    FSongLength := iIndex + 1;
end;

end.
