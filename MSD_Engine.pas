unit MSD_Engine;

interface

uses Classes, STSong, STPatterns;

procedure MSD_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer; cInitialTempo: byte);
procedure MSD_AddFreqTable(sl: TStringList);
procedure MSD_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);

implementation

uses SysUtils, GrokUtils;

procedure MSD_Compress(SongIn: TSTSong; SongOut: TSTSong);
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
                               SongIn.SongLayout[j],false)) and
           (SongIn.PercussionMatch(SongIn.SongLayout[i],
                                   SongIn.SongLayout[j])) then
          SongOut.SongLayout[j] := SongIn.SongLayout[i];
      end;
    end;
  end;
end;


procedure MSD_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer; cInitialTempo: byte);
var
  s: string;
begin
  GetAppVersionInfo(s);
  sl.Add('; *****************************************************************************');
  sl.Add('; * The Music Studio Player Engine');
  sl.Add('; *');
  sl.Add('; * Based on code written by Saša Pušica for the utility, The Music Studio.');
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
    sl.Add('                          EXX');
    sl.Add('                          PUSH  HL');
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
    sl.Add('                          EXX');
    sl.Add('                          PUSH  HL');
    sl.Add('                          CALL  NEXT_PATTERN');
    sl.Add('                          POP   HL');
    sl.Add('                          EXX                                 ; Restore HL'' for return to BASIC');
    sl.Add('                          EI');
    sl.Add('                          RET');
    sl.Add('NEXTNOTE:');
    sl.Add('                          DI');
    sl.Add('                          EXX');
    sl.Add('                          PUSH  HL');
    sl.Add('                          CALL  PLAYNOTE');
  end
  else if iType =3 then
  begin
    // Continuous Play
    sl.Add('                          DI');
    sl.Add('                          EXX');
    sl.Add('                          PUSH  HL');
    sl.Add('                          CALL  NEXT_PATTERN');    
    sl.Add('NEXTNOTE:');
    sl.Add('                          CALL  PLAYNOTE');
    sl.Add('                          JR    NEXTNOTE                    ; Play next note');
  end;
  sl.Add('');
  sl.Add('                          POP   HL');
  sl.Add('                          EXX                                 ; Restore HL'' for return to BASIC');
  sl.Add('                          EI');
  sl.Add('                          RET                                 ; Return from playing tune');
  sl.Add('');
  sl.Add('PATTERN_PTR:              DEFB 0');
  sl.Add('NOTE_PTR:                 DEFB 0');
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
    sl.Add('                          POP  HL');
    sl.Add('                          EXX');
    sl.Add('                          EI');
    sl.Add('                          RET');
  end;
  sl.Add('NO_PATTERN_LOOP:          LD   (PATTERN_PTR),A');
  sl.Add('');
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
  sl.Add('                          DEFB $21                            ; LD HL,nn');
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
  sl.Add('; IF D = $0 then were at the end of the pattern so increment PATTERN_PTR by 2 and set NOTE_PTR=0');
  sl.Add('                          LD   A,D');
  sl.Add('                          CP   $FE                           ; $FE indicates end of pattern');
  sl.Add('                          JR   Z,NEXT_PATTERN');
  sl.Add('');
  sl.Add('CONTINUE0:                PUSH DE');
  sl.Add('                          INC  HL');
  sl.Add('                          LD   D,(HL)');
  sl.Add('                          LD   E,1');
  sl.Add('');
  sl.Add('                          LD   A,(NOTE_PTR)');
  sl.Add('                          INC  A');
  sl.Add('                          INC  A');
  sl.Add('                          LD   (NOTE_PTR),A                   ; Increment the note pointer by 2 (one note per chan)');
  sl.Add('');
  sl.Add('                          EXX');
  sl.Add('                          POP  DE                             ; Now CH1 freq is in DE, and CH2 freq is in DE''');
  sl.Add('');
  sl.Add('                          LD   A,(TEMPO)');
  sl.Add('                          LD   C,A');
  sl.Add('                          LD   B,0');
  sl.Add('                          LD   A,BORDER_COL');
  sl.Add('                          EX   AF,AF''');
  sl.Add('                          LD   A,BORDER_COL                   ; So now BC = TEMPO, A and A'' = BORDER_COL');
  sl.Add('                          EXX');
  sl.Add('');
  sl.Add('OUTPUT_NOTE:');
  sl.Add('                          LD   IXH,D                          ; Put note frequency for chan 1 into IXH');
  sl.Add('                          LD   H,D');
  sl.Add('                          LD   L,H');
  sl.Add('                          DEC  L');
  sl.Add('                          LD   E,L');
  sl.Add('                          JR   Z,CONTINUE1');
  sl.Add('                          LD   E,$10');
  sl.Add('CONTINUE1:');
  sl.Add('                          EXX');
  sl.Add('                          LD   IXL,D                          ; Put note frequency for chan 2 into IXL');
  sl.Add('                          LD   H,D');
  sl.Add('                          LD   L,H');
  sl.Add('                          DEC  L');
  sl.Add('                          LD   E,L');
  sl.Add('                          JR   Z,CONTINUE2');
  sl.Add('                          LD   E,$10');
  sl.Add('CONTINUE2:');
  sl.Add('                          EXX');
  sl.Add('                          EX   AF,AF''');
  sl.Add('                          OUT  ($FE),A');
  sl.Add('                          DEC  H             ; Dec H, which also holds the frequency value');
  sl.Add('                          JR   NZ,L8055');
  sl.Add('                          XOR  E');
  sl.Add('                          LD   H,D');
  sl.Add('                          PUSH AF');
  sl.Add('                          LD   A,IXH');
  sl.Add('                          CP   $20');
  sl.Add('                          JR   NC,L8054      ; if A > $20 then this is not a drum effect, skip the INC D');
  sl.Add('                          INC  D             ; create the "fast falling pitch" percussion effect');
  sl.Add('L8054:                    POP  AF');
  sl.Add('L8055:                    DEC  L');
  sl.Add('                          JR   NZ,L805B');
  sl.Add('                          XOR  E');
  sl.Add('                          LD   L,D');
  sl.Add('                          DEC  L');
  sl.Add('L805B:                    EXX');
  sl.Add('                          EX   AF,AF''');
  sl.Add('                          OUT  ($FE),A');
  sl.Add('                          DEC  H');
  sl.Add('                          JR   NZ,L806D');
  sl.Add('                          XOR  E');
  sl.Add('                          LD   H,D');
  sl.Add('                          PUSH AF');
  sl.Add('                          LD   A,IXL');
  sl.Add('                          CP   $20');
  sl.Add('                          JR   NC,L806C     ; if A > $20 then this is not a drum effect, skip the INC D');
  sl.Add('                          INC  D            ; create the "fast falling pitch" percussion effect');
  sl.Add('L806C:                    POP  AF');
  sl.Add('L806D:                    DEC  L');
  sl.Add('                          JR   NZ,L8073');
  sl.Add('                          XOR  E');
  sl.Add('                          LD   L,D');
  sl.Add('                          DEC  L');
  sl.Add('L8073:                    DJNZ CONTINUE2');
  sl.Add('                          DEC  C');
  sl.Add('                          JR   NZ,CONTINUE2');
  sl.Add('                          RET');
end;

procedure MSD_AddFreqTable(sl: TStringList);
begin
  // Not needed since we now write the frequency data direct to the patterns
  // rather than note values
  {
  sl.Add(';FREQ_TABLE:     DEFB $FF,$F0,$E3,$D7,$CB,$C0,$B4,$AB,$A1,$97,$90,$88');
  sl.Add(';                DEFB $80,$79,$72,$6C,$66,$60,$5B,$56,$51,$4C,$48,$44');
  sl.Add(';                DEFB $40,$3D,$39,$36,$33,$30,$2D,$2B,$28,$26,$24,$22');
  sl.Add(';                DEFB $20,$1E,$1C,$1B,$19,$18,$17,$15,$14,$13,$12,$11');
  sl.Add(';                DEFB $10,$01');
  }

  // MSD has 37 notes from F#1 - F#4
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
  else
    Result := $01; // Rest
  end;

end;

procedure MSDAddNoteData(sl: TStringList; iCh1,iCh2: integer);
begin
  sl.Add('             DEFB ' + IntToStr(GetNoteFreq(iCh1)) + ',' +
                                IntToStr(GetNoteFreq(iCh2)));
end;

procedure MSDAddDrumData(sl: TStringList; iCh1,iDrum: integer);
begin
  dec(iDrum,$80); // make it 1-12
  case iDrum of
  1: iDrum := $1E;
  2: iDrum := $1C;
  3: iDrum := $1B;
  4: iDrum := $19;
  5: iDrum := $18;
  6: iDrum := $17;
  7: iDrum := $15;
  8: iDrum := $14;
  9: iDrum := $13;
  10: iDrum := $12;
  11: iDrum := $11;
  12: iDrum := $10;
  13: iDrum := $0;  
  else
    iDrum := $01; // rest
  end;

  sl.Add('             DEFB ' + IntToStr(GetNoteFreq(iCh1)) + ',' +
                                IntToStr(iDrum));
end;

procedure MSD_AddPatternData(sl: TStringList; Song: TSTSong; iPat: integer; iTranspose: integer);
var
  i: integer;
begin
  sl.Add('PAT' + IntToStr(iPat) + ':');
  sl.Add('         DEFB ' + IntToStr(64 - Song.Pattern[iPat].Tempo * 3) + '  ; Pattern tempo');
  for i := 1 to Song.Pattern[iPat].Length do
  begin
    if (Song.Pattern[iPat].Drum[i] > $80) and (Song.Pattern[iPat].Drum[i] < $8E) then
      MSDAddDrumData(sl, Song.Pattern[iPat].Chan[1][i] + iTranspose, Song.Pattern[iPat].Drum[i])
    else
      MSDAddNoteData(sl, Song.Pattern[iPat].Chan[1][i] + iTranspose, Song.Pattern[iPat].Chan[2][i] + iTranspose);
  end;
  sl.Add('         DEFB $FE'); // End of pattern
end;

procedure MSD_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);
var
  i: integer;
  CompressedSong: TSTSong;
begin
  CompressedSong := TSTSong.Create();
  MSD_Compress(Song,CompressedSong);

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
  sl.Add('; *** Pattern data consists of pairs of frequency values CH1,CH2 with a single $FE to');
  sl.Add('; *** Mark the end of the pattern, and $01 for a rest');
  // MELODY PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressedSong.IsPatternUsed(i) then
    begin
      MSD_AddPatternData(sl,Song,i,iTranspose); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;

  FreeAndNil(CompressedSong);
end;

end.
