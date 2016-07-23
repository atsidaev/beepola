unit RMB_Engine;

interface

uses Classes, STSong, STPatterns;

procedure RMB_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer; cInitialTempo: byte);
procedure RMB_AddFreqTable(sl: TStringList);
procedure RMB_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);

implementation

uses SysUtils, GrokUtils;

procedure RMB_Compress(SongIn: TSTSong; SongOut: TSTSong);
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


procedure RMB_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer; cInitialTempo: byte);
var
  s: string;
begin
  GetAppVersionInfo(s);
  sl.Add('; *****************************************************************************');
  sl.Add('; * ROM BEEP Engine');
  sl.Add('; *');
  sl.Add('; * By Chris Cowley');
  sl.Add('; *');
  sl.Add('; * Produced by Beepola v' + s);
  sl.Add('; ******************************************************************************');
  sl.Add(' ');
  sl.Add('START:');
  sl.Add('                          LD   HL,MUSICDATA         ;  <- Pointer to Music Data. Change');
  sl.Add('                                                    ;     this to play a different song');
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
    sl.Add('                          CALL  NEXT_PATTERN');
    sl.Add('                          IM    1');
    sl.Add('                          EI');
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
    sl.Add('                          CALL  NEXT_PATTERN');
    sl.Add('                          EI');
    sl.Add('                          RET');
    sl.Add('NEXTNOTE:');
    sl.Add('                          EI');
    sl.Add('                          CALL  PLAYNOTE');
  end
  else if iType =3 then
  begin
    // Continuous Play
    sl.Add('                          CALL  NEXT_PATTERN');
    sl.Add('                          EI');
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
  sl.Add('');
  sl.Add('                          ; IF D = $0 then we are at the end of the pattern so set next pattern');
  sl.Add('                          LD   A,D');
  sl.Add('                          AND  A                              ; Optimised CP 0');
  sl.Add('                          JR   Z,NEXT_PATTERN');
  sl.Add('');
  sl.Add('                          INC  HL');
  sl.Add('                          LD   E,(HL)');
  sl.Add('');
  sl.Add('                          LD   A,(NOTE_PTR)');
  sl.Add('                          INC  A');
  sl.Add('                          INC  A');
  sl.Add('                          LD   (NOTE_PTR),A                   ; Increment the note pointer by 2 (one note per chan)');
  sl.Add('');
  sl.Add('                          ; D = Note1 Value 0-255 (1=rest)');
  sl.Add('                          ; E = Note2 Value 0-255 (1=rest)');
  sl.Add('');
  sl.Add('OUTPUT_NOTE:              LD   A,(TEMPO)');
  sl.Add('                          LD   B,A');
  sl.Add('OUTPUT_NOTE_LOOP:         PUSH BC');
  sl.Add('                          PUSH DE');
  sl.Add('                          LD   A,D');
  sl.Add('                          CALL BEEP_REST_A');
  sl.Add('OUTPUT_CH2:               POP  DE');
  sl.Add('                          PUSH DE');
  sl.Add('                          LD   A,E');
  sl.Add('                          CALL BEEP_REST_A');
  sl.Add('                          POP  DE');
  sl.Add('                          POP  BC');
  sl.Add('                          DJNZ OUTPUT_NOTE_LOOP');
  sl.Add('                          RET');
  sl.Add('');
  sl.Add('BEEP_REST_A:              DEC  A');
  sl.Add('                          JR   Z,REST');
  sl.Add('                          ; Push duration onto calc stack');
  sl.Add('                          PUSH AF ');
  sl.Add('                          RST  $28 ');
  sl.Add('                          DEFB $34');
  sl.Add('                          DEFB $EB,$23,$D7,$0A,$3D');
  sl.Add('                          DEFB $38');
  sl.Add('                          POP  AF');
  sl.Add('                          ; Push note value onto calc stacl');
  sl.Add('                          INC  A');
  sl.Add('                          CALL $2D28');
  sl.Add('                          LD   A,60');
  sl.Add('                          CALL $2D28');
  sl.Add('                          RST  $28 ');
  sl.Add('                          DEFB $03,$38   ; SUBTRACT, END');
  sl.Add('                          CALL $03F8');
  sl.Add('                          RET');
  sl.Add('REST:                     HALT');
  sl.Add('                          HALT');
  sl.Add('                          LD   B,$FF');
  sl.Add('REST_LOOP:                LD   A,(BC)    ; Waste 7 Ts each iteration');
  sl.Add('                          DJNZ REST_LOOP');
  sl.Add('                          RET');
  sl.Add('');
end;

procedure RMB_AddFreqTable(sl: TStringList);
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

function RMBTransposeNote(cNote: byte; iTrans: integer): byte;
var
  iNew: integer;
begin
  if (cNote >= $82) then
    Result := cNote
  else
  begin
    iNew := cNote + iTrans;
    if (iNew > 59) and (iNew < 79) then
      Result := $82 // Note is off-scale high - replace with a Rest
    else if (iNew > 107) and (iNew <119) then
      Result := iNew - 107  // Note has been transposed up from bottom 6 to within std range
    else if (iNew < 0) and (iNew >= -6) then
      Result := iNew + 107 // Note has been transposed down from bottom 6 to within std range
    else if (iNew >= 0) and (iNew <= 59) then
      Result := iNew
    else if (iNew >= 101) and (iNew <= 106) then
      Result := iNew
    else if (iNew < -6) then
      Result := $82 // Note is off-scale low - replace with a rest
    else
      Result := $82; // Replace everything else with a rest
  end;
end;

procedure AddNoteData(sl: TStringList; iCh1,iCh2,iTranspose: integer);
begin
  if (iCh1 < 60) then inc(iCh1,6);
  if (iCh1 > 100) and (iCh1 < 107) then dec(iCh1,101);  // bottom 6 notes
  if (iCh2 < 60) then inc(iCh2,6);
  if (iCh2 > 100) and (iCh2 < 107) then dec(iCh2,101);  // bottom 6 notes

  if (iCh1 < $82) then
    // Transpose the note and check it's within range
    RMBTransposeNote(iCh1,iTranspose);

  if (iCh2 < $82) then
    // Transpose the note and check it's within range
    RMBTransposeNote(iCh2,iTranspose);

  if iCh1 >= $80 then iCh1 := 1 else Inc(iCh1,60);
  if iCh2 >= $80 then iCh2 := 1 else Inc(iCh2,60);

  sl.Add('                          DEFB ' + IntToStr(iCh1) + ',' +
                                IntToStr(iCh2));
end;

procedure RMB_AddPatternData(sl: TStringList; Song: TSTSong; iPat: integer; iTranspose: integer);
var
  i: integer;
  iTempo: integer;
begin
  iTempo := 17 - Song.Pattern[iPat].Tempo;
  if iTempo < 1 then iTempo := 1;

  sl.Add('PAT' + IntToStr(iPat) + ':');
  sl.Add('                          DEFB ' + IntToStr(iTempo) + '  ; Pattern tempo');
  for i := 1 to Song.Pattern[iPat].Length do
    AddNoteData(sl, Song.Pattern[iPat].Chan[1][i],Song.Pattern[iPat].Chan[2][i],iTranspose);
  sl.Add('                          DEFB $0'); // End of pattern
end;

procedure RMB_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);
var
  i: integer;
  CompressedSong: TSTSong;
begin
  CompressedSong := TSTSong.Create();
  RMB_Compress(Song,CompressedSong);

  // MELODY SONG DATA
  sl.Add('MUSICDATA:');
  sl.Add('                          DEFB ' + IntToStr(Song.LoopStart * 2) + '   ; Loop start point * 2');
  sl.Add('                          DEFB ' + IntToStr(Song.SongLength * 2) + '   ; Song Length * 2');
  sl.Add('PATTERNDATA:              DEFW PAT' + IntToStr(CompressedSong.SongLayout[0]));
  for i := 1 to CompressedSong.SongLength - 1 do
  begin
    sl.Add('                          DEFW PAT' + IntToStr(CompressedSong.SongLayout[i]));
  end;
  sl.Add('');
  sl.Add('; *** Pattern data consists of pairs of note values CH1,CH2 with a single $0 to');
  sl.Add('; *** mark the end of the pattern, and $01 for a rest');
  // MELODY PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressedSong.IsPatternUsed(i) then
    begin
      RMB_AddPatternData(sl,Song,i,iTranspose); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;

  FreeAndNil(CompressedSong);
end;

end.
