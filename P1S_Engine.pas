unit P1S_Engine;

interface

uses Classes, STSong, STPatterns;

procedure P1S_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer);
procedure P1S_AddFreqTable(sl: TStringList);
procedure P1S_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);

implementation

uses SysUtils, GrokUtils;

procedure P1S_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer);
var
  s: string;
begin
  GetAppVersionInfo(s);
  sl.Add('; *****************************************************************************');
  sl.Add('; * Phaser1 Engine, with synthesised drums');
  sl.Add('; *');
  sl.Add('; * Original code by Shiru - http://shiru.untergrund.net/');
  sl.Add('; * Modified by Chris Cowley');
  sl.Add('; *');
  sl.Add('; * Produced by Beepola v' + s);
  sl.Add('; ******************************************************************************');
  sl.Add(' ');
  sl.Add('START:');
  sl.Add('             LD    HL,MUSICDATA         ;  <- Pointer to Music Data. Change');
  sl.Add('                                        ;     this to play a different song');
  sl.Add('             LD   A,(HL)                         ; Get the loop start pointer');
  sl.Add('             LD   (PATTERN_LOOP_BEGIN),A');
  sl.Add('             INC  HL');
  sl.Add('             LD   A,(HL)                         ; Get the song end pointer');
  sl.Add('             LD   (PATTERN_LOOP_END),A');
  sl.Add('             INC  HL');
  sl.Add('             LD   E,(HL)');
  sl.Add('             INC  HL');
  sl.Add('             LD   D,(HL)');
  sl.Add('             INC  HL');
  sl.Add('             LD   (INSTRUM_TBL),HL');
  sl.Add('             LD   (CURRENT_INST),HL');
  sl.Add('             ADD  HL,DE');
  sl.Add('             LD   (PATTERN_ADDR),HL');
  sl.Add('             XOR  A');
  sl.Add('             LD   (PATTERN_PTR),A                ; Set the pattern pointer to zero');
  sl.Add('             LD   H,A');
  sl.Add('             LD   L,A');
  sl.Add('             LD   (NOTE_PTR),HL                  ; Set the note offset (within this pattern) to 0');
  sl.Add('');
  sl.Add('PLAYER:');
  sl.Add('             DI');
  sl.Add('             PUSH IY');
  sl.Add('             LD   A,BORDER_COL');
  sl.Add('             LD   H,$00');
  sl.Add('             LD   L,A');
  sl.Add('             LD   (CNT_1A),HL');
  sl.Add('             LD   (CNT_1B),HL');
  sl.Add('             LD   (DIV_1A),HL');
  sl.Add('             LD   (DIV_1B),HL');
  sl.Add('             LD   (CNT_2),HL');
  sl.Add('             LD   (DIV_2),HL');
  sl.Add('             LD   (OUT_1),A');
  sl.Add('             LD   (OUT_2),A');
  sl.Add('             JR   MAIN_LOOP');
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
  if bLoop then
  begin
    sl.Add('                          ; Handle Pattern Looping at and of song');
    sl.Add('                          DEFB $3E                           ; LD A,n');
    sl.Add('PATTERN_LOOP_BEGIN:       DEFB 0');
  end
  else
  begin
    sl.Add('                          ; Handle Exit at and of song');
    sl.Add('                          DEFB $3E                           ; LD A,n');
    sl.Add('PATTERN_LOOP_BEGIN:       DEFB 0');    
    sl.Add('                          JP   EXIT_PLAYER');
  end;
  sl.Add('NO_PATTERN_LOOP:          LD   (PATTERN_PTR),A');
  sl.Add('                          LD   HL,$0000');
  sl.Add('                          LD   (NOTE_PTR),HL   ; Start of pattern (NOTE_PTR = 0)');
  sl.Add('');
  sl.Add('MAIN_LOOP:');
  sl.Add('             LD   IYL,0                        ; Set channel = 0');
  sl.Add('');
  sl.Add('READ_LOOP:');
  sl.Add('             LD   HL,(PATTERN_ADDR)');
  sl.Add('             LD   A,(PATTERN_PTR)');
  sl.Add('             LD   E,A');
  sl.Add('             LD   D,0');
  sl.Add('             ADD  HL,DE');
  sl.Add('             LD   E,(HL)');
  sl.Add('             INC  HL');
  sl.Add('             LD   D,(HL)                       ; Now DE = Start of Pattern data');
  sl.Add('             LD   HL,(NOTE_PTR)');
  sl.Add('             INC  HL                           ; Increment the note pointer and...');
  sl.Add('             LD   (NOTE_PTR),HL                ; ..store it');
  sl.Add('             DEC  HL');  
  sl.Add('             ADD  HL,DE                        ; Now HL = address of note data');
  sl.Add('             LD   A,(HL)');
  sl.Add('             OR   A');
  sl.Add('             JR   Z,NEXT_PATTERN               ; select next pattern');
  sl.Add('');
  sl.Add('             BIT  7,A');
  sl.Add('             JP   Z,RENDER                     ; Play the currently defined note(S) and drum');
  sl.Add('             LD   IYH,A');
  sl.Add('             AND  $3F');
  sl.Add('             CP   $3C');
  sl.Add('             JP   NC,OTHER                     ; Other parameters');
  sl.Add('             ADD  A,A');
  sl.Add('             LD   B,0');
  sl.Add('             LD   C,A');
  sl.Add('             LD   HL,FREQ_TABLE');
  sl.Add('             ADD  HL,BC');
  sl.Add('             LD   E,(HL)');
  sl.Add('             INC  HL');
  sl.Add('             LD   D,(HL)');
  sl.Add('             LD   A,IYL                        ; IYL = 0 for channel 1, or = 1 for channel 2');
  sl.Add('             OR   A');
  sl.Add('             JR   NZ,SET_NOTE2');
  sl.Add('             LD   (DIV_1A),DE');
  sl.Add('             EX   DE,HL');
  sl.Add('');
  sl.Add('             DEFB $DD,$21                      ; LD IX,nn');
  sl.Add('CURRENT_INST:');
  sl.Add('             DEFW $0000');
  sl.Add('');
  sl.Add('             LD   A,(IX+$00)');
  sl.Add('             OR   A');
  sl.Add('             JR   Z,L809B                      ; Original code jumps into byte 2 of the DJNZ (invalid opcode FD)');
  sl.Add('             LD   B,A');
  sl.Add('L8098:       ADD  HL,HL');
  sl.Add('             DJNZ L8098');
  sl.Add('L809B:       LD   E,(IX+$01)');
  sl.Add('             LD   D,(IX+$02)');
  sl.Add('             ADD  HL,DE');
  sl.Add('             LD   (DIV_1B),HL');
  sl.Add('             LD   IYL,1                        ; Set channel = 1');
  sl.Add('             LD   A,IYH');
  sl.Add('             AND  $40');
  sl.Add('             JR   Z,READ_LOOP                  ; No phase reset');
  sl.Add('');
  sl.Add('             LD   HL,OUT_1                     ; Reset phaser');
  sl.Add('             RES  4,(HL)');
  sl.Add('             LD   HL,$0000');
  sl.Add('             LD   (CNT_1A),HL');
  sl.Add('             LD   H,(IX+$03)');
  sl.Add('             LD   (CNT_1B),HL');
  sl.Add('             JR   READ_LOOP');
  sl.Add('');
  sl.Add('SET_NOTE2:');
  sl.Add('             LD   (DIV_2),DE');
  sl.Add('             LD   A,IYH');
  sl.Add('             LD   HL,OUT_2');
  sl.Add('             RES  4,(HL)');
  sl.Add('             LD   HL,$0000');
  sl.Add('             LD   (CNT_2),HL');
  sl.Add('             JP   READ_LOOP');
  sl.Add('');
  sl.Add('SET_STOP:');
  sl.Add('             LD   HL,$0000');
  sl.Add('             LD   A,IYL');
  sl.Add('             OR   A');
  sl.Add('             JR   NZ,SET_STOP2');
  sl.Add('             ; Stop channel 1 note');
  sl.Add('             LD   (DIV_1A),HL');
  sl.Add('             LD   (DIV_1B),HL');
  sl.Add('             LD   HL,OUT_1');
  sl.Add('             RES  4,(HL)');
  sl.Add('             LD   IYL,1');
  sl.Add('             JP   READ_LOOP');
  sl.Add('SET_STOP2:');
  sl.Add('             ; Stop channel 2 note');
  sl.Add('             LD   (DIV_2),HL');
  sl.Add('             LD   HL,OUT_2');
  sl.Add('             RES  4,(HL)');
  sl.Add('             JP   READ_LOOP');
  sl.Add('');
  sl.Add('OTHER:       CP   $3C');
  sl.Add('             JR   Z,SET_STOP                   ; Stop note');
  sl.Add('             CP   $3E');
  sl.Add('             JR   Z,SKIP_CH1                   ; No changes to channel 1');
  sl.Add('             INC  HL                           ; Instrument change');
  sl.Add('             LD   L,(HL)');
  sl.Add('             LD   H,$00');
  sl.Add('             ADD  HL,HL');
  sl.Add('             LD   DE,(NOTE_PTR)');
  sl.Add('             INC  DE');
  sl.Add('             LD   (NOTE_PTR),DE                ; Increment the note pointer');
  sl.Add('');
  sl.Add('             DEFB $01                          ; LD BC,nn');
  sl.Add('INSTRUM_TBL:');
  sl.Add('             DEFW $0000');
  sl.Add('');
  sl.Add('             ADD  HL,BC');
  sl.Add('             LD   (CURRENT_INST),HL');
  sl.Add('             JP   READ_LOOP');
  sl.Add('');
  sl.Add('SKIP_CH1:');
  sl.Add('             LD   IYL,$01');
  sl.Add('             JP   READ_LOOP');
  sl.Add('');
  sl.Add('EXIT_PLAYER:');
  sl.Add('             LD   HL,$2758');
  sl.Add('             EXX');
  sl.Add('             POP  IY');
  sl.Add('             EI');
  sl.Add('             RET');
  sl.Add('');
  sl.Add('RENDER:');
  sl.Add('             AND  $7F                          ; L813A');
  sl.Add('             CP   $76');
  sl.Add('             JP   NC,DRUMS');
  sl.Add('             LD   D,A');
  sl.Add('             EXX');
  sl.Add('             DEFB $21                          ; LD HL,nn');
  sl.Add('CNT_1A:      DEFW $0000');
  sl.Add('             DEFB $DD,$21                      ; LD IX,nn');
  sl.Add('CNT_1B:      DEFW $0000');
  sl.Add('             DEFB $01                          ; LD BC,nn');
  sl.Add('DIV_1A:      DEFW $0000');
  sl.Add('             DEFB $11                          ; LD DE,nn');
  sl.Add('DIV_1B:      DEFW $0000');
  sl.Add('             DEFB $3E                          ; LD A,n');
  sl.Add('OUT_1:       DEFB $0');
  sl.Add('             EXX');
  sl.Add('             EX   AF,AF''');
  sl.Add('             DEFB $21                          ; LD HL,nn');
  sl.Add('CNT_2:       DEFW $0000');
  sl.Add('             DEFB $01                          ; LD BC,nn');
  sl.Add('DIV_2:       DEFW $0000');
  sl.Add('             DEFB $3E                          ; LD A,n');
  sl.Add('OUT_2:       DEFB $00');
  sl.Add('');
  sl.Add('PLAY_NOTE:');
  sl.Add('             ; Read keyboard');
  sl.Add('             LD   E,A');
  sl.Add('             XOR  A');
  if (iType = 1) then
  begin
    sl.Add('             IN   A,($FE)');
    sl.Add('             OR   $E0');
    sl.Add('             INC  A');
  end;
  sl.Add('');
  sl.Add('PLAYER_WAIT_KEY:');
  sl.Add('             JR   NZ,EXIT_PLAYER');
  sl.Add('             LD   A,E');
  sl.Add('             LD   E,0');
  sl.Add('');
  sl.Add('L8168:       EXX');
  sl.Add('             EX   AF,AF''');
  sl.Add('             ADD  HL,BC');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             JR   C,L8171');
  sl.Add('             JR   L8173');
  sl.Add('L8171:       XOR  $10');
  sl.Add('L8173:       ADD  IX,DE');
  sl.Add('             JR   C,L8179');
  sl.Add('             JR   L817B');
  sl.Add('L8179:       XOR  $10');
  sl.Add('L817B:       EX   AF,AF''');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             EXX');
  sl.Add('             ADD  HL,BC');
  sl.Add('             JR   C,L8184');
  sl.Add('             JR   L8186');
  sl.Add('L8184:       XOR  $10');
  sl.Add('L8186:       NOP');
  sl.Add('             JP   L818A');
  sl.Add('');
  sl.Add('L818A:       EXX');
  sl.Add('             EX   AF,AF''');
  sl.Add('             ADD  HL,BC');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             JR   C,L8193');
  sl.Add('             JR   L8195');
  sl.Add('L8193:       XOR  $10');
  sl.Add('L8195:       ADD  IX,DE');
  sl.Add('             JR   C,L819B');
  sl.Add('             JR   L819D');
  sl.Add('L819B:       XOR  $10');
  sl.Add('L819D:       EX   AF,AF''');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             EXX');
  sl.Add('             ADD  HL,BC');
  sl.Add('             JR   C,L81A6');
  sl.Add('             JR   L81A8');
  sl.Add('L81A6:       XOR  $10');
  sl.Add('L81A8:       NOP');
  sl.Add('             JP   L81AC');
  sl.Add('');
  sl.Add('L81AC:       EXX');
  sl.Add('             EX   AF,AF''');
  sl.Add('             ADD  HL,BC');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             JR   C,L81B5');
  sl.Add('             JR   L81B7');
  sl.Add('L81B5:       XOR  $10');
  sl.Add('L81B7:       ADD  IX,DE');
  sl.Add('             JR   C,L81BD');
  sl.Add('             JR   L81BF');
  sl.Add('L81BD:       XOR  $10');
  sl.Add('L81BF:       EX   AF,AF''');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             EXX');
  sl.Add('             ADD  HL,BC');
  sl.Add('             JR   C,L81C8');
  sl.Add('             JR   L81CA');
  sl.Add('L81C8:       XOR  $10');
  sl.Add('L81CA:       NOP');
  sl.Add('             JP   L81CE');
  sl.Add('');
  sl.Add('L81CE:       EXX');
  sl.Add('             EX   AF,AF''');
  sl.Add('             ADD  HL,BC');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             JR   C,L81D7');
  sl.Add('             JR   L81D9');
  sl.Add('L81D7:       XOR  $10');
  sl.Add('L81D9:       ADD  IX,DE');
  sl.Add('             JR   C,L81DF');
  sl.Add('             JR   L81E1');
  sl.Add('L81DF:       XOR  $10');
  sl.Add('L81E1:       EX   AF,AF''');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             EXX');
  sl.Add('             ADD  HL,BC');
  sl.Add('             JR   C,L81EA');
  sl.Add('             JR   L81EC');
  sl.Add('L81EA:       XOR  $10');
  sl.Add('');
  sl.Add('L81EC:       DEC  E');
  sl.Add('             JP   NZ,L8168');
  sl.Add('');
  sl.Add('             EXX');
  sl.Add('             EX   AF,AF''');
  sl.Add('             ADD  HL,BC');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             JR   C,L81F9');
  sl.Add('             JR   L81FB');
  sl.Add('L81F9:       XOR  $10');
  sl.Add('L81FB:       ADD  IX,DE');
  sl.Add('             JR   C,L8201');
  sl.Add('             JR   L8203');
  sl.Add('L8201:       XOR  $10');
  sl.Add('L8203:       EX   AF,AF''');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             EXX');
  sl.Add('             ADD  HL,BC');
  sl.Add('             JR   C,L820C');
  sl.Add('             JR   L820E');
  sl.Add('L820C:       XOR  $10');
  sl.Add('');
  sl.Add('L820E:       DEC  D');
  sl.Add('             JP   NZ,PLAY_NOTE');
  sl.Add('');
  sl.Add('             LD   (CNT_2),HL');
  sl.Add('             LD   (OUT_2),A');
  sl.Add('             EXX');
  sl.Add('             EX   AF,AF''');
  sl.Add('             LD   (CNT_1A),HL');
  sl.Add('             LD   (CNT_1B),IX');
  sl.Add('             LD   (OUT_1),A');
  sl.Add('             JP   MAIN_LOOP');
  sl.Add('');
  sl.Add('; ************************************************************');
  sl.Add('; * DRUMS - Synthesised');
  sl.Add('; ************************************************************');
  sl.Add('DRUMS:');
  sl.Add('             ADD  A,A                          ; On entry A=$75+Drum number (i.e. $76 to $7E)');
  sl.Add('             LD   B,0');
  sl.Add('             LD   C,A');
  sl.Add('             LD   HL,DRUM_TABLE - 236');
  sl.Add('             ADD  HL,BC');
  sl.Add('             LD   E,(HL)');
  sl.Add('             INC  HL');
  sl.Add('             LD   D,(HL)');
  sl.Add('             EX   DE,HL');
  sl.Add('             JP   (HL)');
  sl.Add('');
  sl.Add('DRUM_TONE1:  LD   L,16');
  sl.Add('             JR   DRUM_TONE');
  sl.Add('DRUM_TONE2:  LD   L,12');
  sl.Add('             JR   DRUM_TONE');
  sl.Add('DRUM_TONE3:  LD   L,8');
  sl.Add('             JR   DRUM_TONE');
  sl.Add('DRUM_TONE4:  LD   L,6');
  sl.Add('             JR   DRUM_TONE');
  sl.Add('DRUM_TONE5:  LD   L,4');
  sl.Add('             JR   DRUM_TONE');
  sl.Add('DRUM_TONE6:  LD   L,2');
  sl.Add('DRUM_TONE:');
  sl.Add('             LD   DE,3700');
  sl.Add('             LD   BC,$0101');
  sl.Add('             LD   A,BORDER_COL');
  sl.Add('DT_LOOP0:    OUT  ($FE),A');
  sl.Add('             DEC  B');
  sl.Add('             JR   NZ,DT_LOOP1');
  sl.Add('             XOR  16');
  sl.Add('             LD   B,C');
  sl.Add('             EX   AF,AF''');
  sl.Add('             LD   A,C');
  sl.Add('             ADD  A,L');
  sl.Add('             LD   C,A');
  sl.Add('             EX   AF,AF''');
  sl.Add('DT_LOOP1:    DEC  E');
  sl.Add('             JR   NZ,DT_LOOP0');
  sl.Add('             DEC  D');
  sl.Add('             JR   NZ,DT_LOOP0');
  sl.Add('             JP   MAIN_LOOP');
  sl.Add('');
  sl.Add('DRUM_NOISE1: LD   DE,2480');
  sl.Add('             LD   IXL,1');
  sl.Add('             JR   DRUM_NOISE');
  sl.Add('DRUM_NOISE2: LD   DE,1070');
  sl.Add('             LD   IXL,10');
  sl.Add('             JR   DRUM_NOISE');
  sl.Add('DRUM_NOISE3: LD   DE,365');
  sl.Add('             LD   IXL,101');
  sl.Add('DRUM_NOISE:');
  sl.Add('             LD   H,D');
  sl.Add('             LD   L,E');
  sl.Add('             LD   A,BORDER_COL');
  sl.Add('             LD   C,A');
  sl.Add('DN_LOOP0:    LD   A,(HL)');
  sl.Add('             AND  16');
  sl.Add('             OR   C');
  sl.Add('             OUT  ($FE),A');
  sl.Add('             LD   B,IXL');
  sl.Add('DN_LOOP1:    DJNZ DN_LOOP1');
  sl.Add('             INC  HL');
  sl.Add('             DEC  E');
  sl.Add('             JR   NZ,DN_LOOP0');
  sl.Add('             DEC  D');
  sl.Add('             JR   NZ,DN_LOOP0');
  sl.Add('             JP   MAIN_LOOP');
  sl.Add('');

  sl.Add('PATTERN_ADDR:   DEFW  $0000');
  sl.Add('PATTERN_PTR:    DEFB  0');
  sl.Add('NOTE_PTR:       DEFW  $0000');
  sl.Add('');
end;

procedure P1S_AddFreqTable(sl: TStringList);
begin
  sl.Add('; **************************************************************');
  sl.Add('; * Frequency Table');
  sl.Add('; **************************************************************');
  sl.Add('FREQ_TABLE:');
  sl.Add('             DEFW 178,189,200,212,225,238,252,267,283,300,318,337');
  sl.Add('             DEFW 357,378,401,425,450,477,505,535,567,601,637,675');
  sl.Add('             DEFW 715,757,802,850,901,954,1011,1071,1135,1202,1274,1350');
  sl.Add('             DEFW 1430,1515,1605,1701,1802,1909,2023,2143,2270,2405,2548,2700');
  sl.Add('             DEFW 2860,3030,3211,3402,3604,3818,4046,4286,4541,4811,5097,5400');
  sl.Add('');
  sl.Add('; *****************************************************************');
  sl.Add('; * Synth Drum Lookup Table');
  sl.Add('; *****************************************************************');
  sl.Add('DRUM_TABLE:');
  sl.Add('             DEFW DRUM_TONE1,DRUM_TONE2,DRUM_TONE3,DRUM_TONE4,DRUM_TONE5,DRUM_TONE6');
  sl.Add('             DEFW DRUM_NOISE1,DRUM_NOISE2,DRUM_NOISE3');
  sl.Add('');
end;


procedure P1S_Compress(SongIn: TSTSong; SongOut: TSTSong);
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
                              SongIn.SongLayout[j],true)) and
          (SongIn.PercussionMatch(SongIn.SongLayout[i],
                                   SongIn.SongLayout[j])) then
          SongOut.SongLayout[j] := SongIn.SongLayout[i];
      end;
    end;
  end;
end;

procedure AddIdleTime(sl: TStringList; iIdleTime: integer);
begin
  while (iIdleTime > $75) do
  begin
    sl.Add('     DEFB $75');
    Dec(iIdleTime,$75);
  end;
  if iIdleTime > 0 then
  begin
    sl.Add('     DEFB ' + IntToStr(iIdleTime));
  end;
end;

function Phaser1TransposeNote(cNote: byte; iTrans: integer): byte;
var
  iNew: integer;
begin
  if (cNote >= $80) then
    Result := cNote
  else
  begin
    iNew := cNote + iTrans;
    if (iNew > 59) and (iNew < 79) then
      Result := $88 // Note is off-scale high - replace with a Rest
    else if (iNew > 107) and (iNew <119) then
      Result := iNew - 107  // Note has been transposed up from bottom 6 to within std range
    else if (iNew < 0) and (iNew >= -6) then
      Result := iNew + 107 // Note has been transposed down from bottom 6 to withing std range
    else if (iNew >= 0) and (iNew <= 59) then
      Result := iNew
    else if (iNew >= 101) and (iNew <= 106) then
      Result := iNew
    else if (iNew < -6) then
      Result := $88 // Note is off-scale low - replace with a rest
    else
      Result := 255;
  end;
end;

procedure P1S_AddPatternData(sl: TStringList; Song: TSTSong; iPat: integer; iTranspose: integer);
var
  i, iTempo: integer;
  cNote1,cNote2,cDrum: byte;
  iIdleTime: integer;
begin
  sl.Add('PAT' + IntToStr(iPat) + ':');
  iTempo := 17 - Song.Pattern[iPat].Tempo;
  if iTempo < 1 then iTempo := 1;

  iIdleTime := 0;
  for i := 1 to Song.Pattern[iPat].Length do
  begin
    cNote1 := Phaser1TransposeNote(Song.Pattern[iPat].Chan[2][i],iTranspose);
    if cNote1 = $82 then cNote1 := 60; // Rest/Note-off
    cNote2 := Phaser1TransposeNote(Song.Pattern[iPat].Chan[1][i],iTranspose);
    if cNote2 = $82 then cNote2 := 60; // Rest/Note-off
    if (cNote1 < 60) then inc(cNote1,6);
    if (cNote2 < 60) then inc(cNote2,6);
    if (cNote1 > 100) and (cNote1 < 107) then dec(cNote1,101);  // bottom 6 notes
    if (cNote2 > 100) and (cNote2 < 107) then dec(cNote2,101);  // bottom 6 notes
    // cNote1 and cNote2 are now 0-60 or 255 for no note data
    cDrum := Song.Pattern[iPat].Drum[i] - $80;
    if cDrum > 9 then cDrum := 0;

    if (cNote1 = 255) and (cNote2 = 255) and
       (Song.Pattern[iPat].Sustain[1][i] = 255) and
       (Song.Pattern[iPat].Sustain[2][i] = 255) and
       (Song.Pattern[iPat].Drum[i] = 0) then
      inc(iIdleTime,iTempo)
    else
    begin
      if iIdleTime >0 then
      begin
        AddIdleTime(sl,iIdleTime);
        iIdleTime := 0;
      end;
      if cNote1 = 255 then cNote1 := 62; // Phaser1's no-action is 62, not 255
      if cNote2 = 255 then cNote2 := 62; // Phaser1's no-action is 62, not 255
      if (Song.Pattern[iPat].Sustain[2][i] <> 255) then
        sl.Add('         DEFB $BD,' + IntToStr((Song.Pattern[iPat].Sustain[2][i] mod 100)*2));
      if (Song.Pattern[iPat].Sustain[1][i] <> 255) then
        cNote1 := cNote1 or $C0 // bits 7 and 6 on (reset phaser)
      else
        cNote1 := cNote1 or $80; // just bit 7 on (no phaser reset);
      cNote2 := cNote2 or $80;
      sl.Add('         DEFB ' + IntToStr(cNote1));
      if cNote2 <> $BE  then
      sl.Add('         DEFB ' + IntToStr(cNote2));
      if cDrum > 0 then
      begin
        sl.Add('         DEFB ' + IntToStr(cDrum + $75));
        inc(iIdleTime,iTempo-1);
      end
      else
        inc(iIdleTime,iTempo);
    end;
  end;
  if iIdleTime >0 then
    AddIdleTime(sl,iIdleTime);

  sl.Add('         DEFB $00'); // End of pattern
end;

procedure P1S_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);
var
  iInstCount: integer;
  i: Integer;
  CompressedSong: TSTSong;
begin
  sl.Add('MUSICDATA:');
  sl.Add('             DEFB ' + IntToStr(Song.LoopStart * 2) + '  ; Pattern loop begin * 2');
  sl.Add('             DEFB ' + IntToStr(Song.SongLength * 2) + '  ; Song length * 2');
  iInstCount := Song.GetHighestInstrument();
  if (iInstCount < 0) then
  begin
    sl.Add('             DEFW $0004                        ; Offset to start of song (length of instrument table)');
    sl.Add('             DEFB $01                          ; Multiple 0');
    sl.Add('             DEFW $0000                        ; Detune 0000');
    sl.Add('             DEFB $00                          ; Phase  0');
  end
  else
  begin
    sl.Add('             DEFW ' + IntToStr((iInstCount + 1)*4) + '         ; Offset to start of song (length of instrument table)');
    for i := 0 to iInstCount do
    begin
      sl.Add('             DEFB ' + IntToStr(Song.Phaser1Instrument[i].Multiple) + '      ; Multiple');
      sl.Add('             DEFW ' + IntToStr(Song.Phaser1Instrument[i].Detune and 16383) + '      ; Detune');
      sl.Add('             DEFB ' + IntToStr(Song.Phaser1Instrument[i].Phase) + '      ; Phase');
    end;
  end;
  sl.Add('');

  CompressedSong := TSTSong.Create();
  P1S_Compress(Song,CompressedSong);

  // MELODY SONG DATA
  sl.Add('PATTERNDATA:        DEFW      PAT' + IntToStr(CompressedSong.SongLayout[0]));
  for i := 1 to CompressedSong.SongLength - 1 do
  begin
    sl.Add('                    DEFW      PAT' + IntToStr(CompressedSong.SongLayout[i]));
  end;
  sl.Add('');
  sl.Add('; *** Pattern data - $00 marks the end of a pattern ***');
  // MELODY PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressedSong.IsPatternUsed(i) then
    begin
      P1S_AddPatternData(sl,Song,i,iTranspose); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;

  FreeAndNil(CompressedSong);
end;

end.
