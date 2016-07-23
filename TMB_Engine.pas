unit TMB_Engine;

interface

uses Classes, STSong, STPatterns;

procedure TMB_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer; cInitialTempo: byte);
procedure TMB_AddFreqTable(sl: TStringList);
procedure TMB_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);

implementation

uses SysUtils, GrokUtils;

procedure TMB_Compress(SongIn: TSTSong; SongOut: TSTSong);
var
  i,j: integer;
begin
  SongOut.Clear;

  // Preset the compiled layout to be = to the uncompiled one
  for i := 0 to SongIn.SongLength - 1 do
    SongOut.SongLayout[i] := SongIn.SongLayout[i];

  for i := 0 to SongIn.SongLength - 1 do
  begin
    if SongOut.IsPatternUsed(SongIn.SongLayout[i]) then
    begin
      for j := 0 to SongIn.SongLength - 1 do
      begin
        if (SongIn.SongLayout[i] <> SongIn.SongLayout[j]) and
          (SongIn.MelodyMatch(SongIn.SongLayout[i],
                              SongIn.SongLayout[j],false)) then
          SongOut.SongLayout[j] := SongIn.SongLayout[i];
      end;
    end;
  end;
end;


procedure TMB_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer; cInitialTempo: byte);
var
  s: string;
begin
  GetAppVersionInfo(s);
  sl.Add('; *****************************************************************************');
  sl.Add('; * The Music Box Player Engine');
  sl.Add('; *');
  sl.Add('; * Based on code written by Mark Alexander for the utility, The Music Box.');
  sl.Add('; * Modified by Chris Cowley');
  sl.Add('; *');
  sl.Add('; * Produced by Beepola v' + s);
  sl.Add('; ******************************************************************************');
  sl.Add(' ');
  sl.Add('START:');
  sl.Add('                          LD    HL,MUSICDATA         ;  <- Pointer to Music Data. Change');
  sl.Add('                                                     ;     this to play a different song');
  sl.Add('                          LD   A,(HL)                         ; Get the loop start pointer');
  sl.Add('                          LD   (PATTERN_LOOP_BEGIN),A');
  sl.Add('                          INC  HL');
  sl.Add('                          LD   A,(HL)                         ; Get the song end pointer');
  sl.Add('                          LD   (PATTERN_LOOP_END),A');
  sl.Add('                          INC  HL');
  sl.Add('                          LD   (PATTERNDATA1),HL');
  sl.Add('                          LD   (PATTERNDATA2),HL');
  sl.Add('                          LD   A,254');
  sl.Add('                          LD   (PATTERN_PTR),A                ; Set the pattern pointer to zero');
  if iType = 1 then
  begin
    // Return if Key Pressed
    sl.Add('                          DI');
    sl.Add('                          CALL  NEXT_PATTERN');
    sl.Add('NEXTNOTE:');
    sl.Add('                          CALL  PLAYNOTE');
    sl.Add('                          XOR   A');
    sl.Add('                          IN    A,($FE)');
    sl.Add('                          AND   $1F');
    sl.Add('                          CP    $1F');
    sl.Add('                          JR    Z,NEXTNOTE                    ; Play next note if no key pressed');
  end
  else if iType = 2 then
  begin
    // Return after each note
    sl.Add('                          DI');
    sl.Add('                          CALL  NEXT_PATTERN');
    sl.Add('                          EI');
    sl.Add('                          RET');
    sl.Add('NEXTNOTE:');
    sl.Add('                          DI');
    sl.Add('                          CALL  PLAYNOTE');
  end
  else if iType =3 then
  begin
    // Continuous Play
    sl.Add('                          DI');
    sl.Add('                          CALL  NEXT_PATTERN');
    sl.Add('NEXTNOTE:');
    sl.Add('                          CALL  PLAYNOTE');
    sl.Add('                          JR    NEXTNOTE                    ; Play next note');
  end;
  sl.Add('');
  sl.Add('                          EI');
  sl.Add('                          RET                                 ; Return from playing tune');
  sl.Add('');
  sl.Add('PATTERN_PTR:              DEFB 0');
  sl.Add('NOTE_PTR:                 DEFB 0');
  sl.Add('');
  sl.Add('');
  sl.Add('; ********************************************************************************************************');
  sl.Add('; * NEXT_PATTERN');
  sl.Add('; *');
  sl.Add('; * Select the next pattern in sequence (and handle looping if we''ve reached PATTERN_LOOP_END');
  sl.Add('; * Execution falls through to PLAYNOTE to play the first note from our next pattern');
  sl.Add('; ********************************************************************************************************');
  sl.Add('NEXT_PATTERN:');
  sl.Add('                          LD   A,(PATTERN_PTR)');
  sl.Add('                          INC  A');
  sl.Add('                          INC  A');
  sl.Add('                          DEFB $FE                           ; CP n');
  sl.Add('PATTERN_LOOP_END:         DEFB 0');
  sl.Add('                          JR   NZ,NO_PATTERN_LOOP');
  sl.Add('                          DEFB $3E                           ; LD A,n');
  sl.Add('PATTERN_LOOP_BEGIN:       DEFB 0');
  if not bLoop then
  begin
    // RETURN TO CALLER at end of song
    sl.Add('                          POP  HL');
    sl.Add('                          EI');
    sl.Add('                          RET');
  end;
  sl.Add('NO_PATTERN_LOOP:          LD   (PATTERN_PTR),A');
  sl.Add('			                    DEFB $21                            ; LD HL,nn');
  sl.Add('PATTERNDATA1:             DEFW $0000');
  sl.Add('                          LD   E,A                            ; (this is the first byte of the pattern)');
  sl.Add('                          LD   D,0                            ; and store it at TEMPO');
  sl.Add('                          ADD  HL,DE');
  sl.Add('                          LD   E,(HL)');
  sl.Add('                          INC  HL');
  sl.Add('                          LD   D,(HL)');
  sl.Add('                          LD   A,(DE)                         ; Pattern Tempo -> A');
  sl.Add('	                	      LD   (TEMPO),A                      ; Store it at TEMPO');
  sl.Add('');
  sl.Add('                          LD   A,1');
  sl.Add('                          LD   (NOTE_PTR),A');
  //sl.Add('                          RET');
  sl.Add('');
  sl.Add('PLAYNOTE: ');
  sl.Add('			                    DEFB $21                            ; LD HL,nn');
  sl.Add('PATTERNDATA2:             DEFW $0000');
  sl.Add('                          LD   A,(PATTERN_PTR)');
  sl.Add('                          LD   E,A');
  sl.Add('                          LD   D,0');
  sl.Add('                          ADD  HL,DE');
  sl.Add('                          LD   E,(HL)');
  sl.Add('                          INC  HL');
  sl.Add('                          LD   D,(HL)                         ; Now DE = Start of Pattern data');
  sl.Add('                          LD   A,(NOTE_PTR)');
  sl.Add('                          LD   L,A');
  sl.Add('                          LD   H,0');
  sl.Add('                          ADD  HL,DE                          ; Now HL = address of note data');
  sl.Add('                          LD   D,(HL)');
  sl.Add('                          LD   E,1');
  sl.Add('');
  sl.Add('; IF D = $0 then we are at the end of the pattern so increment PATTERN_PTR by 2 and set NOTE_PTR=0');
  sl.Add('                          LD   A,D');
  sl.Add('                          AND  A                              ; Optimised CP 0');
  sl.Add('                          JR   Z,NEXT_PATTERN');
  sl.Add('');
  sl.Add('                          PUSH DE');
  sl.Add('                          INC  HL');
  sl.Add('                          LD   D,(HL)');
  sl.Add('                          LD   E,1');
  sl.Add('');
  sl.Add('                          LD   A,(NOTE_PTR)');
  sl.Add('                          INC  A');
  sl.Add('                          INC  A');
  sl.Add('                          LD   (NOTE_PTR),A                   ; Increment the note pointer by 2 (one note per chan)');
  sl.Add('');
  sl.Add('                          POP  HL                             ; Now CH1 freq is in HL, and CH2 freq is in DE');
  sl.Add('');
  sl.Add('                          LD   A,H');
  sl.Add('                          DEC  A');
  sl.Add('                          JR   NZ,OUTPUT_NOTE');
  sl.Add('');
  sl.Add('                          LD   A,D                            ; executed only if Channel 2 contains a rest');
  sl.Add('                          DEC  A                              ; if DE (CH1 note) is also a rest then..');
  sl.Add('                          JR   Z,PLAY_SILENCE                 ; Play silence');
  sl.Add('');
  sl.Add('OUTPUT_NOTE:              LD   A,(TEMPO)');
  sl.Add('                          LD   C,A');
  sl.Add('                          LD   B,0');
  sl.Add('                          LD   A,BORDER_COL');
  sl.Add('                          EX   AF,AF''');
  sl.Add('                          LD   A,BORDER_COL                   ; So now BC = TEMPO, A and A'' = BORDER_COL');
  sl.Add('                          LD   IXH,D');
  sl.Add('                          LD   D,$10');
  sl.Add('EAE5:                     NOP');
  sl.Add('                          NOP');
  sl.Add('EAE7:                     EX   AF,AF''');
  sl.Add('                          DEC  E');
  sl.Add('                          OUT  ($FE),A');
  sl.Add('                          JR   NZ,EB04');
  sl.Add('');
  sl.Add('                          LD   E,IXH');
  sl.Add('                          XOR  D');
  sl.Add('                          EX   AF,AF''');
  sl.Add('                          DEC  L');
  sl.Add('                          JP   NZ,EB0B');
  sl.Add('');
  sl.Add('EAF5:                     OUT  ($FE),A');
  sl.Add('                          LD   L,H');
  sl.Add('                          XOR  D');
  sl.Add('                          DJNZ EAE5');
  sl.Add('');
  sl.Add('                          INC  C');
  sl.Add('                          JP   NZ,EAE7');
  sl.Add('');
  sl.Add('                          RET');
  sl.Add('');
  sl.Add('EB04:');
  sl.Add('                          JR   Z,EB04');
  sl.Add('                          EX   AF,AF''');
  sl.Add('                          DEC  L');
  sl.Add('                          JP   Z,EAF5');
  sl.Add('EB0B:');
  sl.Add('                          OUT  ($FE),A');
  sl.Add('                          NOP');
  sl.Add('                          NOP');
  sl.Add('                          DJNZ EAE5');
  sl.Add('                          INC  C');
  sl.Add('                          JP   NZ,EAE7');
  sl.Add('                          RET');
  sl.Add('');
  sl.Add('PLAY_SILENCE:');
  sl.Add('                          LD   A,(TEMPO)');
  sl.Add('                          CPL');
  sl.Add('                          LD   C,A');
  sl.Add('                          PUSH BC');
  sl.Add('                          PUSH AF');
  sl.Add('                          LD   B,0');
  sl.Add('SILENCE_LOOP:             PUSH HL');
  sl.Add('                          LD   HL,0000');
  sl.Add('                          SRA  (HL)');
  sl.Add('                          SRA  (HL)');
  sl.Add('                          SRA  (HL)');
  sl.Add('                          NOP');
  sl.Add('                          POP  HL');
  sl.Add('                          DJNZ SILENCE_LOOP');
  sl.Add('                          DEC  C');
  sl.Add('                          JP   NZ,SILENCE_LOOP');
  sl.Add('                          POP  AF');
  sl.Add('                          POP  BC');
  sl.Add('                          RET');
  sl.Add('');
end;

procedure TMB_AddFreqTable(sl: TStringList);
begin
  // Not needed since we now write the frequency data direct to the patterns
  // rather than note values
  {
  sl.Add('; FREQ_TABLE:               DEFB $FF,$F0,$E3,$D7,$CB,$C0,$B4,$AB,$A1,$97,$90,$88');
  sl.Add(';                           DEFB $80,$79,$72,$6C,$66,$60,$5B,$56,$51,$4C,$48,$44');
  sl.Add(';                           DEFB $40,$3D,$39,$36,$33,$30,$2D,$2B,$28,$26,$24,$22');
  sl.Add(';                           DEFB $20,$1E,$1C,$1B,$19,$18,$17,$15,$14,$13,$12,$11');
  sl.Add(';                           DEFB $10,$0F,$0E,$0D,$0C,$01');
  }

  // SFX has 52 notes from F#0 to A-4
  // TMB has 53 notes from C-1 to E-5
end;

function GetNoteFreq(iNote: integer): integer;
begin
  case iNote of
  0:  Result := $FF;
  1:  Result := $F0;
  2:  Result := $E3;
  3:  Result := $D7;
  4: Result := $CB;
  5: Result := $C0;
  6: Result := $B4;
  7: Result := $AB;
  8: Result := $A1;
  9: Result := $97;
  10: Result := $90;
  11: Result := $88;
  12: Result := $80;
  13: Result := $79;
  14: Result := $72;
  15: Result := $6C;
  16: Result := $66;
  17: Result := $60;
  18: Result := $5B;
  19: Result := $56;
  20: Result := $51;
  21: Result := $4C;
  22: Result := $48;
  23: Result := $44;
  24: Result := $40;
  25: Result := $3D;
  26: Result := $39;
  27: Result := $36;
  28: Result := $33;
  29: Result := $30;
  30: Result := $2D;
  31: Result := $2B;
  32: Result := $28;
  33: Result := $26;
  34: Result := $24;
  35: Result := $22;
  36: Result := $20;
  37: Result := $1E;
  38: Result := $1C;
  39: Result := $1B;
  40: Result := $19;
  41: Result := $18;
  42: Result := $17;
  43: Result := $15;
  44: Result := $14;
  45: Result := $13;
  46: Result := $12;
  47: Result := $11;
  48: Result := $10;
  49: Result := $0F;
  50: Result := $0E;
  51: Result := $0D;
  52: Result := $0C;
  else
    Result := $01; // Rest
  end;

end;

procedure AddNoteData(sl: TStringList; iCh1,iCh2: integer);
begin
  sl.Add('             DEFB ' + IntToStr(GetNoteFreq(iCh1)) + ',' +
                                IntToStr(GetNoteFreq(iCh2)));
end;

procedure TMB_AddPatternData(sl: TStringList; Song: TSTSong; iPat: integer; iTranspose: integer);
var
  i: integer;
begin
  sl.Add('PAT' + IntToStr(iPat) + ':');
  sl.Add('         DEFB ' + IntToStr(Song.Pattern[iPat].Tempo * 2 + 210) + '  ; Pattern tempo');  
  for i := 1 to Song.Pattern[iPat].Length do
    AddNoteData(sl, Song.Pattern[iPat].Chan[1][i] + iTranspose, Song.Pattern[iPat].Chan[2][i] + iTranspose);
  sl.Add('         DEFB $0'); // End of pattern
end;

procedure TMB_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);
var
  i: integer;
  CompressedSong: TSTSong;
begin
  CompressedSong := TSTSong.Create();
  TMB_Compress(Song,CompressedSong);

  // MELODY SONG DATA
  sl.Add('MUSICDATA:');
  sl.Add('                    DEFB ' + IntToStr(Song.LoopStart * 2) + '   ; Loop start point * 2');
  sl.Add('                    DEFB ' + IntToStr(Song.SongLength * 2) + '   ; Song Length * 2');
  sl.Add('PATTERNDATA:        DEFW      PAT' + IntToStr(CompressedSong.SongLayout[0]));
  for i := 1 to CompressedSong.SongLength - 1 do
  begin
    sl.Add('                    DEFW      PAT' + IntToStr(CompressedSong.SongLayout[i]));
  end;
  sl.Add('');
  sl.Add('; *** Pattern data consists of pairs of frequency values CH1,CH2 with a single $0 to');
  sl.Add('; *** Mark the end of the pattern, and $01 for a rest');
  // MELODY PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressedSong.IsPatternUsed(i) then
    begin
      TMB_AddPatternData(sl,Song,i,iTranspose); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;

  FreeAndNil(CompressedSong);
end;

end.
