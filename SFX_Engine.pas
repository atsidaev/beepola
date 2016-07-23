unit SFX_Engine;

interface

uses Classes, STSong, STPatterns;

procedure SFX_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer);
procedure SFX_AddFreqTable(sl: TStringList);
procedure SFX_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);

implementation

uses SysUtils, GrokUtils;

procedure SFX_AddPlayerAsm(sl: TStringList; bLoop: boolean; iType: integer);
var
  s: string;
begin
  GetAppVersionInfo(s);
  sl.Add('; *****************************************************************************');
  sl.Add('; * Special FX Music Player Engine');
  sl.Add('; *');
  sl.Add('; * Based on code written by Jonathan Smith for the Special FX game, Firefly.');
  sl.Add('; * Modified by Chris Cowley');
  sl.Add('; *');
  sl.Add('; * Produced by Beepola v' + s);
  sl.Add('; ******************************************************************************');
  sl.Add(' ');
  sl.Add('START:          DI');
  sl.Add('                EXX');
  sl.Add('                PUSH  HL                    ; Preserve HL'' for return to BASIC');
  sl.Add('                CALL  PLAY_MUSIC');
  sl.Add('                IM    1');
  sl.Add('                POP   HL');
  sl.Add('                EXX');
  sl.Add('                EI');
  sl.Add('                RET');
  sl.Add('');
  sl.Add('PLAY_MUSIC:');
  sl.Add('                CALL  MAKE_VECTOR_TABLE');
  sl.Add('                CALL  INIT_ISR');
  sl.Add('                IM    2');
  sl.Add('                LD    A,VECTOR_TABLE_LOC / 256');
  sl.Add('                LD    I,A');
  sl.Add('');
  sl.Add('                LD    HL,MUSICDATA         ;  <- Pointer to Music Data. Change');
  sl.Add('                                           ;     this to play a different song');
  sl.Add('                LD    E,(HL)');
  sl.Add('                INC   HL');
  sl.Add('                LD    D,(HL)');
  sl.Add('                INC   HL');
  sl.Add('                LD    (NEXT_PATT_PTR),HL');
  sl.Add('                LD    (NEXT_PERC_PATT_PTR),DE');
  sl.Add('                LD    (SAVED_SP),SP');
  sl.Add('                LD    HL,PLAYER_ISR');
  sl.Add('                LD    ($FFF5),HL           ; Set up the JP instruction to point');
  sl.Add('                                           ; to our player ISR');
  sl.Add('                LD    A,BORDER_CLR');
  sl.Add('                LD    (OUT_VAL1),A         ; Beeper out values for chan1');
  sl.Add('                LD    (OUT_VAL2),A         ; Beeper out values for chan1');
  sl.Add('                LD    (OUT_VAL3),A         ; Beeper out values for chan2');
  sl.Add('                LD    (OUT_VAL4),A         ; Beeper out values for chan2');
  sl.Add('                CALL  SET_NEXT_PATT');
  sl.Add('                CALL  SET_NEXT_PERC_PATT');
  sl.Add('                LD    C,$01');
  sl.Add('                EXX');
  sl.Add('                LD    BC,$0101');
  sl.Add('                EI');
  sl.Add('                HALT');
  sl.Add('NEXT_NOTE:      CALL  C,LF02C ');
  sl.Add('                LD    A,B');
  sl.Add('                OR    A');
  sl.Add('                JR    NZ,LEF99');
  sl.Add('LEF61:          DEFB  $21               ; LD HL,nn');
  sl.Add('CURR_PATT_CH1:');
  sl.Add('                DEFW  $0000             ; Current Pattern for chan1');
  sl.Add('LEF64:          LD    A,(HL)');
  sl.Add('                OR    A');
  sl.Add('                JP    M,LEB9B           ; bit7 set - command (sustain, pattern end, etc)');
  sl.Add('                CALL  LF0F6');
  sl.Add('                LD    (LEFA2),A');
  sl.Add('                SRL   A');
  sl.Add('                SRL   A');
  sl.Add('                SRL   A');
  sl.Add('                LD    D,A');
  sl.Add('                LD    (LEFAD),A');
  sl.Add('                XOR   A');
  sl.Add('                LD    (LF02D),A');
  sl.Add('                INC   A');
  sl.Add('                LD    (LEFA4),A');
  sl.Add('                LD    A,(OUT_VAL1)      ; Adjust the EAR and MIC bits of this');
  sl.Add('                OR    $18               ; port output value for the tone');
  sl.Add('                LD    (OUT_VAL1),A      ; generator');
  sl.Add('                INC   HL');
  sl.Add('POST_MUTE1:     LD    A,(HL)');
  sl.Add('                LD    (LEF96),A');
  sl.Add('                INC   HL');
  sl.Add('                LD    (CURR_PATT_CH1),HL');
  sl.Add('                DEFB  $06               ; LD    B,n');
  sl.Add('LEF96:          DEFB  $54');
  sl.Add('                JR    LEF9E');
  sl.Add('LEF99:          LD    A,$03');
  sl.Add('LEF9B:          DEC   A');
  sl.Add('                JR    NZ,LEF9B');
  sl.Add('LEF9E:          DEC   D');
  sl.Add('                JR    NZ,LEFB5');
  sl.Add('');
  sl.Add('                DEFB  $16               ; LD D,n');
  sl.Add('LEFA2:          DEFB  $3B');
  sl.Add('                DEFB  $3E               ; LD A,n');
  sl.Add('LEFA4:          DEFB  $07');
  sl.Add('LEFA5:          DEC   A');
  sl.Add('                JR    NZ,LEFA5');
  sl.Add('');
  sl.Add('                DEFB  $3E               ; LD A,n');
  sl.Add('OUT_VAL1:       DEFB  $0');
  sl.Add('                OUT   ($FE),A');
  sl.Add('                DEFB  $3E               ; LD A,n');
  sl.Add('LEFAD:          DEFB  $01               ; frequency counter for CH1');
  sl.Add('LEFAE:          DEC   A');
  sl.Add('                JR    NZ,LEFAE');
  sl.Add('');
  sl.Add('                DEFB  $3E               ; LD A,n');
  sl.Add('OUT_VAL2:       DEFB  $00');
  sl.Add('                OUT   ($FE),A');
  sl.Add('LEFB5:          LD    A,C');
  sl.Add('                OR    A');
  sl.Add('                JR    NZ,LEFEF');
  sl.Add('');
  sl.Add('                DEFB  $21               ; LD HL,nn');
  sl.Add('CURR_PATT_CH2:  DEFW  $0000             ; Current pattern for CH2');
  sl.Add('LEFBC:          LD    A,(HL)');
  sl.Add('                OR    A');
  sl.Add('                JP    M,LEBA6           ; bit7 set - command (sustain, pattern end, etc)');
  sl.Add('                CALL  LF0F6');
  sl.Add('                LD    (LEFF9),A');
  sl.Add('                SRL   A');
  sl.Add('                SRL   A');
  sl.Add('                LD    (LF004),A');
  sl.Add('                LD    E,A');
  sl.Add('                XOR   A');
  sl.Add('                LD    (LF045),A');
  sl.Add('                INC   A');
  sl.Add('                LD    (LEFFB),A');
  sl.Add('                LD    A,(OUT_VAL3)');
  sl.Add('                OR    $18');
  sl.Add('                LD    (OUT_VAL3),A');
  sl.Add('                INC   HL');
  sl.Add('POST_MUTE2:     LD    A,(HL)');
  sl.Add('                LD    (LEFEC),A');
  sl.Add('                INC   HL');
  sl.Add('                LD    (CURR_PATT_CH2),HL');
  sl.Add('                DEFB  $0E               ; LD C,n');
  sl.Add('LEFEC:          DEFB  $0E');
  sl.Add('                JR    LEFF4');
  sl.Add('');
  sl.Add('LEFEF:          LD    A,$03');
  sl.Add('LEFF1:          DEC   A');
  sl.Add('                JR    NZ,LEFF1');
  sl.Add('LEFF4:          DEC   E');
  sl.Add('                JP    NZ,NEXT_NOTE');
  sl.Add('');
  sl.Add('                DEFB  $1E               ; LD E,n');
  sl.Add('LEFF9:          DEFB  $3B');
  sl.Add('                DEFB  $3E               ; LD A,n');
  sl.Add('LEFFB:          DEFB  $02');
  sl.Add('LEFFC:          DEC   A');
  sl.Add('                JR    NZ,LEFFC');
  sl.Add('');
  sl.Add('                DEFB  $3E               ; LD A,n');
  sl.Add('OUT_VAL3:       DEFB  $18');
  sl.Add('                OUT   ($FE),A');
  sl.Add('                DEFB  $3E               ; LD A,n');
  sl.Add('LF004:          DEFB  $0D               ; ch2 note frequency');
  sl.Add('LF005:          DEC   A');
  sl.Add('                JR    NZ,LF005');
  sl.Add('');
  sl.Add('                DEFB  $3E');
  sl.Add('OUT_VAL4:       DEFB  $0');
  sl.Add('                OUT   ($FE),A');
  sl.Add('                JP    NEXT_NOTE');
  sl.Add('');
  sl.Add('LF00F:');
  sl.Add('                POP   HL');
  sl.Add('                LD    A,(HL)');
  sl.Add('                LD    (LF033),A');
  sl.Add('                INC   HL');
  sl.Add('                JP    LEF64');
  sl.Add('');
  sl.Add('LF018:          POP   HL');
  sl.Add('                LD    A,(HL)');
  sl.Add('                LD    (LF04B),A');
  sl.Add('                INC   HL');
  sl.Add('                JR    LEFBC');
  sl.Add('');
  sl.Add('MUTE_CH1:       POP   HL');
  sl.Add('                LD    A,(OUT_VAL1)');
  sl.Add('                AND   $07');
  sl.Add('                LD    (OUT_VAL1),A');
  sl.Add('                JP    POST_MUTE1');
  sl.Add('');
  sl.Add('MUTE_CH2:       POP   HL');
  sl.Add('                LD    A,(OUT_VAL3)');
  sl.Add('                AND   $07');
  sl.Add('                LD    (OUT_VAL3),A');
  sl.Add('                JP    POST_MUTE2');
  sl.Add('NULL_NOTE1:     POP   HL');
  sl.Add('                JP    POST_MUTE1');
  sl.Add('NULL_NOTE2:     POP   HL');
  sl.Add('                JP    POST_MUTE2');
  sl.Add('');
  sl.Add('LF021:');
  sl.Add('                POP   HL');
  sl.Add('                CALL  SET_NEXT_PATT');
  sl.Add('                JP    LEF61');
  sl.Add('');
  sl.Add('LF02C:          DEFB  $3E');
  sl.Add('LF02D:          DEFB  $00');
  sl.Add('                INC   A');
  sl.Add('                LD    (LF02D),A');
  sl.Add('                DEFB  $FE               ; CP');
  sl.Add('LF033:          DEFB  $02');
  sl.Add('                JR    C,LF044');
  sl.Add('                XOR   A');
  sl.Add('                LD    (LF02D),A');
  sl.Add('                LD    HL,LEFAD');
  sl.Add('                DEC   (HL)');
  sl.Add('                JR    Z,LF043');
  sl.Add('                LD    HL,LEFA4');
  sl.Add('LF043:          INC   (HL)');
  sl.Add('');
  sl.Add('LF044:          DEFB  $3E               ; LD A,n');
  sl.Add('LF045:          DEFB  $00');
  sl.Add('                INC   A');
  sl.Add('                LD    (LF045),A');
  sl.Add('                DEFB  $FE               ; CP');
  sl.Add('LF04B:          DEFB  $04');
  sl.Add('                RET   C');
  sl.Add('                XOR   A');
  sl.Add('                LD    (LF045),A');
  sl.Add('                LD    HL,LF004');
  sl.Add('                DEC   (HL)');
  sl.Add('                JR    Z,LF05A');
  sl.Add('                LD    HL,LEFFB');
  sl.Add('LF05A:          INC   (HL)');
  sl.Add('                RET');
  sl.Add('');
  sl.Add('LF0F6:          PUSH  HL');
  sl.Add('                PUSH  DE');
  sl.Add('                LD    HL,FREQ_TABLE');
  sl.Add('                LD    E,A');
  sl.Add('                LD    D,$0');
  sl.Add('                ADD   HL,DE');
  sl.Add('                LD    A,(HL)');
  sl.Add('                POP   DE');
  sl.Add('                POP   HL');
  sl.Add('                RET');
  sl.Add('');
  sl.Add('; ** Reads and sets up the next melody pattern to play');
  sl.Add('SET_NEXT_PATT:');
  sl.Add('               DEFB  $21   ; LD HL,nn');
  sl.Add('NEXT_PATT_PTR: DEFW  $0000              ; holds a pointer to the');
  sl.Add('                                        ; next pattern in the patter list');
  sl.Add('GET_PATT_ADDR: LD    E,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    D,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    A,E');
  sl.Add('               OR    D');
  sl.Add('               JR    NZ,STORE_NEXT_P');

  if not (bLoop) then
    sl.Add('               JP    ISR_KEY_PRESSED')
  else
  begin
    sl.Add('               LD    E,(HL)');
    sl.Add('               INC   HL');
    sl.Add('               LD    D,(HL)');
    sl.Add('               EX    DE,HL');
    sl.Add('               JR    GET_PATT_ADDR');
  end;
  sl.Add('STORE_NEXT_P:  LD    (NEXT_PATT_PTR),HL');
  sl.Add('               EX    DE,HL');
  sl.Add('               LD    E,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    D,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    (CURR_PATT_CH1),HL');
  sl.Add('               LD    (CURR_PATT_CH2),DE');
  sl.Add('               RET');
  sl.Add('');
  sl.Add('; ** Reads and sets up the next percussion pattern to play');
  sl.Add('SET_NEXT_PERC_PATT:');
  sl.Add('               DEFB  $21   ; LD HL,nn');
  sl.Add('NEXT_PERC_PATT_PTR:');
  sl.Add('               DEFW  $0000');
  sl.Add('GET_PERC_ADDR: LD    E,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    D,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    (NEXT_PERC_PATT_PTR),HL');
  sl.Add('               LD    (PERC_PATT),DE');
  sl.Add('               LD    A,E');
  sl.Add('               OR    D');
  sl.Add('               RET   NZ');
  sl.Add('               LD    E,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    D,(HL)');
  sl.Add('               EX    DE,HL');
  sl.Add('               JR    GET_PERC_ADDR');
  sl.Add('               CALL  SET_NEXT_PERC_PATT');
  sl.Add('               JR    PLAY_PERC');
  sl.Add('');
  sl.Add('LEB9B:');
  sl.Add('               INC   HL');
  sl.Add('               PUSH  HL');
  sl.Add('               AND   $7F');
  sl.Add('               CALL  JUMP_PERC_ADDR');
  sl.Add('               DEFW  LF021');
  sl.Add('               DEFW  LF00F');
  sl.Add('               DEFW  MUTE_CH1');
  sl.Add('               DEFW  NULL_NOTE1');
  sl.Add('');
  sl.Add('LEBA6:         INC   HL');
  sl.Add('               PUSH  HL');
  sl.Add('               AND   $7F');
  sl.Add('               CALL  JUMP_PERC_ADDR');
  sl.Add('               DEFW  LF021');
  sl.Add('               DEFW  LF018');
  sl.Add('               DEFW  MUTE_CH2');
  sl.Add('               DEFW  NULL_NOTE2');  
  sl.Add('');
  sl.Add('PLAY_PERC:');
  sl.Add('               DEFB  $21                   ; LD HL,nn');
  sl.Add('PERC_PATT:     DEFW  $0000                 ; Address of the percussion data');
  sl.Add('               LD    A,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    C,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    (PERC_PATT),HL        ; Point PERC_PATT at next datum');
  sl.Add('               AND   $7F');
  sl.Add('               CALL  JUMP_PERC_ADDR');
  sl.Add('               DEFW  DRUM00                ; F094');
  sl.Add('               DEFW  DRUM01                ; F09A');
  sl.Add('               DEFW  DRUM02                ; F0AC');
  sl.Add('               DEFW  DRUM03                ; F0BB');
  sl.Add('               DEFW  DRUM04                ; F0D4');
  sl.Add('               DEFW  DRUM05                ; F07C');
  sl.Add('');
  sl.Add('JUMP_PERC_ADDR:');
  sl.Add('               POP   HL                    ; F0ED');
  sl.Add('               ADD   A,A');
  sl.Add('               ADD   A,L');
  sl.Add('               LD    L,A');
  sl.Add('               LD    A,(HL)');
  sl.Add('               INC   HL');
  sl.Add('               LD    H,(HL)');
  sl.Add('               LD    L,A');
  sl.Add('               JP    (HL)');
  sl.Add('');
  sl.Add('DRUM00:        CALL  SET_NEXT_PERC_PATT');
  sl.Add('               JR    PLAY_PERC');
  sl.Add('');
  sl.Add('DRUM01:        LD    E,$0A');
  sl.Add('               LD    A,BORDER_CLR');
  sl.Add('               LD    HL,$0100');
  sl.Add('DRUM01NOISE:   XOR   $18');
  sl.Add('               OUT   ($FE),A');
  sl.Add('               LD    B,(HL)');
  sl.Add('DRUM01LOOP:    DJNZ  DRUM01LOOP');
  sl.Add('               INC   HL');
  sl.Add('               DEC   E');
  sl.Add('               JR    NZ,DRUM01NOISE');
  sl.Add('               RET');
  sl.Add('');
  sl.Add('DRUM02:        LD    HL,$005A');
  sl.Add('DRUM02LOOP:    LD    A,(HL)');
  sl.Add('               OR    A');
  sl.Add('               RET   Z');
  sl.Add('               AND   $18');
  sl.Add('               OR    BORDER_CLR');
  sl.Add('               OUT   ($FE),A');
  sl.Add('               INC   HL');
  sl.Add('               JR    DRUM02LOOP');
  sl.Add('');
  sl.Add('DRUM03:        LD    HL,$0F18');
  sl.Add('               LD    D,$0A');
  sl.Add('DRUM03LOOP3:   LD    B,(HL)');
  sl.Add('DRUM03LOOP:    DJNZ  DRUM03LOOP');
  sl.Add('               LD    A,$18');
  sl.Add('               OR    BORDER_CLR');
  sl.Add('               OUT   ($FE),A');
  sl.Add('               INC   HL');
  sl.Add('               LD    B,(HL)');
  sl.Add('DRUM03LOOP2:   DJNZ  DRUM03LOOP2');
  sl.Add('               LD    A,BORDER_CLR');
  sl.Add('               OUT   ($FE),A');
  sl.Add('               INC   HL');
  sl.Add('               DEC   D');
  sl.Add('               JR    NZ,DRUM03LOOP3');
  sl.Add('               RET');
  sl.Add('');
  sl.Add('DRUM04:        LD    E,$3F');
  sl.Add('               LD    D,$05');
  sl.Add('DRUM04LOOP3:   LD    B,E');
  sl.Add('DRUM04LOOP:    DJNZ  DRUM04LOOP');
  sl.Add('               LD    A,$18');
  sl.Add('               OR    BORDER_CLR');
  sl.Add('               OUT   ($FE),A');
  sl.Add('               LD    A,E');
  sl.Add('               RRCA');
  sl.Add('               LD    E,A');
  sl.Add('               LD    B,A');
  sl.Add('DRUM04LOOP2:   DJNZ  DRUM04LOOP2');
  sl.Add('               LD    A,BORDER_CLR');
  sl.Add('               OUT   ($FE),A');
  sl.Add('               DEC   D');
  sl.Add('               JR    NZ,DRUM04LOOP3');
  sl.Add('DRUM05:        RET');
  sl.Add('');
  sl.Add('; ** Creates a vector table of 257 0xFF bytes at the location specified');
  sl.Add('; ** by VECTOR_TABLE_LOC');
  sl.Add('MAKE_VECTOR_TABLE:');
  sl.Add('                LD    HL,VECTOR_TABLE_LOC');
  sl.Add('                LD    DE,VECTOR_TABLE_LOC + 1');
  sl.Add('                LD    BC,$0100');
  //sl.Add('                LD    A,255');
  sl.Add('                LD    (HL),$FF');
  sl.Add('                LDIR');
  sl.Add('                RET');
  sl.Add('');
  sl.Add('; *** The IM 2 service routine active throughout the life of the player');
  sl.Add('; *** updates counters, plays any active percussion sounds, and checks for');
  sl.Add('; *** keypresses or Kempston joystick fire button to terminate');
  sl.Add('PLAYER_ISR:');
  sl.Add('                PUSH  AF');
  sl.Add('                PUSH  DE');
  sl.Add('                PUSH  HL');
  sl.Add('                DEC   C');
  sl.Add('                DEC   B');
  sl.Add('                EXX');
  sl.Add('                DEC   C');
  sl.Add('                CALL  Z,PLAY_PERC          ; EBB1');
  if (iType = 1) then
  begin
    sl.Add('                ; Read keyboard');
    sl.Add('                XOR   A');
    sl.Add('                IN    A,($FE)');
    sl.Add('                CPL');
    sl.Add('                AND   $1F');
    sl.Add('                JR    NZ,ISR_KEY_PRESSED');
    sl.Add('                XOR   A');
    sl.Add('                IN    A,($1F)');
    sl.Add('                BIT   5,A');
    sl.Add('                JR    NZ,END_PLAYER_ISR');
    sl.Add('                BIT   4,A');
    sl.Add('                JR    NZ,ISR_FIRE_PRESSED');
  end;
  sl.Add('END_PLAYER_ISR: EXX');
  sl.Add('                POP   HL');
  sl.Add('                POP   DE');
  sl.Add('                POP   AF');
  sl.Add('                SCF');
  sl.Add('                EI');
  sl.Add('                RETI');
  sl.Add('ISR_FIRE_PRESSED:');
  sl.Add('ISR_KEY_PRESSED:');
  sl.Add('                DEFB  $31                  ; LD SP,nn');
  sl.Add('SAVED_SP:       DEFW  $0000                ;');
  sl.Add('                EI');
  sl.Add('                RETI');
  sl.Add('');
  sl.Add('; ** Sets up everything for our IM2 service routine. Specifically, copies a JR');
  sl.Add('; ** instruction to $FFFF and a JP $F0FF to $FFF4');
  sl.Add('INIT_ISR:');
  sl.Add('                LD    HL,$FFFF');
  sl.Add('                LD    (HL),$18               ; Copies in our JR for JR FFF4');
  sl.Add('                LD     HL,$FFF4');
  sl.Add('                LD    (HL),$C3               ; JP (jump address filled-in');
  sl.Add('                                             ; during player initialization)');
  sl.Add('                RET');
  sl.Add('');
end;

procedure SFX_AddFreqTable(sl: TStringList);
begin
  sl.Add('FREQ_TABLE:          DEFB $FD,$EE,$E1,$D4,$C8,$BD,$B2,$A8,$9F,$96,$8E,$86,$7E');
  sl.Add('                     DEFB $77,$70,$6A,$64,$5E,$59,$54,$4F,$4B,$47,$43,$3F');
  sl.Add('                     DEFB $3B,$38,$35,$32,$2F,$2C,$2A,$27,$25,$23,$21,$1F');
  sl.Add('                     DEFB $1D,$1C,$1B,$19,$17,$16,$15,$13,$12,$11,$10,$0F');
  sl.Add('                     DEFB $0E,$0D,$0C,$01,$00');
  sl.Add('');
end;

procedure SFX_CompressMelody(SongIn: TSTSong; SongOut: TSTSong);
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
                               SongIn.SongLayout[j],true)) then
          SongOut.SongLayout[j] := SongIn.SongLayout[i];
      end;
    end;
  end;
end;

procedure SFX_CompressPercussion(SongIn: TSTSong; SongOut: TSTSong);
var
  i,j: integer;
begin
  SongOut.Clear;

  // Preset the compiled layout to be = to the uncompiled one
  for i := 0 to SongIn.SongLength - 1 do
    SongOut.SongLayout[i] := SongIn.SongLayout[i];

  for i := 0 to SongIn.SongLength - 1 do
  begin
    for j := 0 to SongIn.SongLength - 1 do
    begin
      if SongOut.IsPatternUsed(SongIn.SongLayout[i]) then
      begin
        if (SongIn.SongLayout[i] <> SongIn.SongLayout[j]) and
          (SongIn.PercussionMatch(SongIn.SongLayout[i],
                                   SongIn.SongLayout[j])) then
          SongOut.SongLayout[j] := SongIn.SongLayout[i];
      end;
    end;
  end;
end;

procedure AddNoteData(sl: TStringList; iNote,iNoteLen,iTranspose: integer);
begin
  if (iTranspose <> 0) and (iNote < $80) then
  begin
    // Transpose the note and check it's within range
    inc(iNote,iTranspose);
    if (iNote < 0) or (iNote > $33) then iNote := $82; // Rest
  end;

  while (iNoteLen > 255) do
  begin
    sl.Add('     DEFB ' + IntToStr(iNote and 255) + ',$FF');
    Dec(iNoteLen,255);
  end;
  if iNoteLen > 0 then
  begin
    sl.Add('     DEFB ' + IntToStr(iNote and 255) + ',' + IntToStr(iNoteLen));
  end;
end;

procedure SFX_AddPatternData(sl: TStringList; Song: TSTSong; iPat: integer; iTranspose: integer);
var
  i, iOneNote, iNote,iNoteLen: integer;
begin
  sl.Add('PAT' + IntToStr(iPat) + ':     DEFW  PAT' + IntToStr(iPat) + 'C2');
  iOneNote := 21 - Song.Pattern[iPat].Tempo; // Length of one row in the pattern

  // Channel 1 pattern data
  iNote := $83; // No sound (continue previous note if sustain permits)
  iNoteLen := 0;
  for i := 1 to Song.Pattern[iPat].Length do
  begin
    if Song.Pattern[iPat].Chan[1][i] = 255 then
      Inc(iNoteLen,iOneNote)
    else
    begin
      if iNoteLen > 0 then
        AddNoteData(sl,iNote,iNoteLen,iTranspose);

      iNote := Song.Pattern[iPat].Chan[1][i];
      iNoteLen := iOneNote;
    end;
    if Song.Pattern[iPat].Sustain[1][i] <> 255 then
      sl.Add('     DEFB $81,' + IntToStr(Song.Pattern[iPat].Sustain[1][i]));
  end;
  if iNoteLen > 0 then
    AddNoteData(sl,iNote,iNoteLen,iTranspose);
  sl.Add('     DEFB $80');

  // Channel 2 pattern data
  sl.Add('PAT' + IntToStr(iPat) + 'C2:');
  iNote := $83;  // No sound (continue previous note if sustain permits)
  iNoteLen := 0;
  for i := 1 to Song.Pattern[iPat].Length do
  begin
    if Song.Pattern[iPat].Chan[2][i] = 255 then
      Inc(iNoteLen,iOneNote)
    else
    begin
      if iNoteLen > 0 then
        AddNoteData(sl,iNote,iNoteLen,iTranspose);
      iNote := Song.Pattern[iPat].Chan[2][i];
      iNoteLen := iOneNote;
    end;
    if Song.Pattern[iPat].Sustain[2][i] <> 255 then
      sl.Add('     DEFB $81,' + IntToStr(Song.Pattern[iPat].Sustain[2][i]));    
  end;
  if iNoteLen > 0 then
    AddNoteData(sl,iNote,iNoteLen,iTranspose);
  sl.Add('     DEFB $80');
end;

procedure SFX_AddDrumPatternData(sl: TStringList; Song: TSTSong; iPat: integer);
var
  i, iOneNote, iNote,iNoteLen: integer;
begin
  sl.Add('DRM' + IntToStr(iPat) + ':');
  iOneNote := 21 - Song.Pattern[iPat].Tempo; // Length of one row in the pattern

  // Drum pattern data
  iNote := $85; // Rest/Mute
  iNoteLen := 0;
  for i := 1 to Song.Pattern[iPat].Length do
  begin
    if (Song.Pattern[iPat].Drum[i] < $80) or (Song.Pattern[iPat].Drum[i] > $85) then
      Inc(iNoteLen,iOneNote)
    else
    begin
      if iNoteLen > 0 then
        AddNoteData(sl,iNote,iNoteLen,0);
      iNote := Song.Pattern[iPat].Drum[i];
      iNoteLen := iOneNote;
    end;
  end;
  if iNoteLen > 0 then
    AddNoteData(sl,iNote,iNoteLen,0);
  sl.Add('     DEFB $80');
end;

procedure SFX_AddSongData(sl: TStringList; Song: TSTSong; iTranspose: integer);
var
  i: integer;
  CompressSong: TSTSong;
begin
  CompressSong := TSTSong.Create;
  SFX_CompressMelody(Song,CompressSong);

  // MELODY SONG DATA
  sl.Add('MUSICDATA:        DEFW      PERCSTART');
  sl.ADD('SONGSTART:        DEFW      PAT' + IntToStr(CompressSong.SongLayout[0]));
  for i := 1 to Song.SongLength - 1 do
  begin
    if Song.LoopStart = i then
      sl.Add('LOOPSTART:        DEFW      PAT' + IntToStr(CompressSong.SongLayout[i]))
    else
      sl.Add('                  DEFW      PAT' + IntToStr(CompressSong.SongLayout[i]));
  end;
  sl.Add('                  DEFW      $0000');
  if Song.LoopStart = 0 then
    sl.Add('                  DEFW      SONGSTART')
  else
    sl.Add('                  DEFW      LOOPSTART');
  sl.Add('');

  // MELODY PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressSong.IsPatternUsed(i) then
    begin
      SFX_AddPatternData(sl,Song,i,iTranspose); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;

  SFX_CompressPercussion(Song,CompressSong);

  sl.Add('PERCSTART:   DEFW      DRM' + IntToStr(CompressSong.SongLayout[0]));
  for i := 1 to Song.SongLength - 1 do
  begin
    if Song.LoopStart = i then
      sl.Add('PERCLOOP:    DEFW      DRM' + IntToStr(CompressSong.SongLayout[i]))
    else
      sl.Add('             DEFW      DRM' + IntToStr(CompressSong.SongLayout[i]));
  end;
  sl.Add('             DEFW      $0000');
  if Song.LoopStart = 0 then
    sl.Add('             DEFW      PERCSTART')
  else
    sl.Add('             DEFW      PERCLOOP');
  sl.Add('');

  // DRUM PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressSong.IsPatternUsed(i) then
    begin
      SFX_AddDrumPatternData(sl,Song,i); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;
end;

end.
