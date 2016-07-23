unit SVG_Engine;

interface

uses Classes, STSong, STPatterns;

procedure SVG_AddPlayerAsm(sl: TStringList; iType: integer);
procedure SVG_AddSongData(sl: TStringList; Song: TSTSong; bLoop: boolean; iTranspose: integer);

implementation

uses SysUtils, GrokUtils;

procedure SVG_AddPlayerAsm(sl: TStringList; iType: integer);
var
  s: string;
begin
  GetAppVersionInfo(s);
  sl.Add('; *****************************************************************************');
  sl.Add('; * Savage Music Player Engine');
  sl.Add('; *');
  sl.Add('; * Based on code written by Jason C Brooke for the Probe Software game,');
  sl.Add('; * Savage. Reverse engineerd in Ukraine by barmaley_m and translated to');
  sl.Add('; * English by Shiru.  Minor mods by Chris Cowley.');
  sl.Add('; *');
  sl.Add('; * Produced by Beepola v' + s);
  sl.Add('; ******************************************************************************');
  sl.Add(' ');
  sl.Add('START:');
  sl.Add('              PUSH  AF');
  sl.Add('              LD    HL,VECTOR_TABLE_LOC');
  sl.Add('              LD    DE,VECTOR_TABLE_LOC + 1');
  sl.Add('              LD    BC,257             ; Length of vector table = 257 bytes');
  sl.Add('              LD    (HL),$FF           ; Point vector table at address $FFFF');
  sl.Add('              LDIR');
  sl.Add('              LD    HL,$FFFF');
  sl.Add('              LD    (HL),$18           ; Copy in a JR instruction for JR FFF4');
  sl.Add('              LD    HL,$FFF4');
  sl.Add('              LD    (HL),$C3           ; Copy in a JP instruction');
  sl.Add('              INC   HL');
  sl.Add('              LD    (HL),ISR_0');
  sl.Add('              LD    A,VECTOR_TABLE_LOC / 256');
  sl.Add('              LD    I,A');
  sl.Add('              IM    2');
  sl.Add('              EI                       ; Enable IM2 routine at $F0F0');
  sl.Add('              POP   AF');
  sl.Add('              CALL  INIT_MUSIC');
  sl.Add('              CALL  PLAY_MUSIC');
  sl.Add('              IM    1');
  sl.Add('              LD    IY,$5C3A           ; Set up IY and');
  sl.Add('              LD    HL,$2758           ; HL'' with sensible values for');
  sl.Add('              EXX                      ; returning to BASIC');
  sl.Add('              EI');
  sl.Add('              RET');
  sl.Add('');
  sl.Add('INTVEC_ADR:   EQU   $FFF5');
  sl.Add('');
  sl.Add('INIT_MUSIC:');
  sl.Add('              PUSH  BC');
  sl.Add('              PUSH  DE');
  sl.Add('              PUSH  HL');
  sl.Add('              PUSH  IX');
  sl.Add('              LD    HL,SONG_INITDATA_0');
  sl.Add('              LD    IX,CHAN_0_DATA');
  sl.Add('              LD    C,$11              ; Length of channel data');
  sl.Add('LE4BB:');
  sl.Add('              LD    A,(HL)');
  sl.Add('              LD    (IX + CHAN_ENDPOS),A');
  sl.Add('              INC   HL');
  sl.Add('              LD    A,(HL)');
  sl.Add('              LD    (IX + CHAN_SONGLOOPPOS),A');
  sl.Add('              INC   HL');
  sl.Add('              LD    E,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              LD    D,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              LD    (IX + CHAN_NOTE_LEN_REMAIN),1');
  sl.Add('              LD    (IX + CHAN_TRANSPOSE),B');
  sl.Add('              LD    (IX + CHAN_SKEW_XORING),B');
  sl.Add('              LD    (IX + CHAN_ORN_BASE),B');
  sl.Add('              LD    (IX + CHAN_CURPOS),B');
  sl.Add('              LD    (IX + CHAN_PATT_TBL_ADR),E');
  sl.Add('              LD    (IX + CHAN_PATT_TBL_ADR + 1),D');
  sl.Add('              LD    A,(DE)');
  sl.Add('              LD    (IX + CHAN_DATA),A');
  sl.Add('              INC   DE                  ; relocatable');
  sl.Add('              LD    A,(DE)');
  sl.Add('              LD    (IX + 1),A');
  sl.Add('              BIT   7,(IX + CHAN_NOTE_LEN_TOTAL)');
  sl.Add('              ADD   IX,BC');
  sl.Add('              JR    Z,LE4BB');
  sl.Add('');
  sl.Add('              LD    E,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              LD    D,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              LD    (LD_HL_ORNOFF + 1),DE');
  sl.Add('              LD    E,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              LD    D,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              LD    (LD_HL_ORNDAT + 1),DE');
  sl.Add('');
  sl.Add('              POP   IX');
  sl.Add('              POP   HL');
  sl.Add('              POP   DE');
  sl.Add('              POP   BC');
  sl.Add('              LD    A,$FF');
  sl.Add('              LD    (CONT_FLAG + 1),A');
  sl.Add('              RET');
  sl.Add('');
  sl.Add('; Reserve 17 bytes for our Channel 0 (tone) status structure');
  sl.Add('CHAN_0_DATA:  DEFW  $0000	; Pattern pointer (CHAN_DATA)');
  sl.Add('              DEFW  $0000       ; Pattern Table Address (CHAN_PATT_TBL_ADR)');
  sl.Add('              DEFB  $00,$00,$00 ; CHAN_CURPOS, CHAN_ENDPOS, CHAN_SONGLOOPPOS');
  sl.Add('              DEFB  $00         ; CHAN_TRANSPOSE');
  sl.Add('              DEFB  $00,$00     ; CHAN_NOTE_LEN_REMAIN, CHAN_NOTE_LEN_TOTAL');
  sl.Add('              DEFB  $00         ; CHAN_GENFX');
  sl.Add('              DEFB  $00         ; CHAN_SKEW_PARAM');
  sl.Add('              DEFB  $10         ; Channel on');
  sl.Add('              DEFB  $00         ; CHAN_ORN_BASE');
  sl.Add('              DEFB  $00         ; CHAN_ORN_COUNT');
  sl.Add('              DEFB  $00         ; Note');
  sl.Add('              DEFB  $00         ; CHAN_SKEW_XORING');
  sl.Add('');
  sl.Add('; Reserve 17 bytes for our Channel 1 (tone) status structure');
  sl.Add('CHAN_1_DATA:  DEFW  $0000	; Pattern pointer (CHAN_DATA)');
  sl.Add('              DEFW  $0000       ; Pattern Table Address (CHAN_PATT_TBL_ADR)');
  sl.Add('              DEFB  $00,$00,$00 ; CHAN_CURPOS, CHAN_ENDPOS, CHAN_SONGLOOPPOS');
  sl.Add('              DEFB  $00         ; CHAN_TRANSPOSE');
  sl.Add('              DEFB  $00,$00     ; CHAN_NOTE_LEN_REMAIN, CHAN_NOTE_LEN_TOTAL');
  sl.Add('              DEFB  $00         ; CHAN_GENFX');
  sl.Add('              DEFB  $00         ; CHAN_SKEW_PARAM');
  sl.Add('              DEFB  $10         ; Channel on');
  sl.Add('              DEFB  $00         ; CHAN_ORN_BASE');
  sl.Add('              DEFB  $00         ; CHAN_ORN_COUNT');
  sl.Add('              DEFB  $00         ; Note');
  sl.Add('              DEFB  $00         ; CHAN_SKEW_XORING');
  sl.Add('');
  sl.Add('; Reserve bytes for percussion channel status');
  sl.Add('PATDRUM_PTR:      DEFW  $0000       ; Percussion pattern pointer');
  sl.Add('LISTDRUM_AD:      DEFW  $0000       ; Percussion pattern table address');
  sl.Add('CURPOS_DRUM:      DEFW  $0000');
  sl.Add('DRUM_SONGLOOPPOS: DEFB  $00');
  sl.Add('                  DEFB  $00');
  sl.Add('PATDRUM_CNT_QTS:  DEFB  $00');
  sl.Add('              DEFB  $FF');
  sl.Add('              DEFB  $00');
  sl.Add('');
  sl.Add('CHAN_DATA:               EQU  0');
  sl.Add('CHAN_PATT_TBL_ADR:       EQU  2');
  sl.Add('CHAN_CURPOS:             EQU  4');
  sl.Add('CHAN_ENDPOS:             EQU  5');
  sl.Add('CHAN_SONGLOOPPOS:        EQU  6');
  sl.Add('CHAN_TRANSPOSE:          EQU  7');
  sl.Add('CHAN_NOTE_LEN_REMAIN:    EQU  8');
  sl.Add('CHAN_NOTE_LEN_TOTAL:     EQU  9');
  sl.Add('CHAN_GENFX:              EQU  10');
  sl.Add('CHAN_SKEW_PARAM:         EQU  11');
  sl.Add('CHAN_CHANNEL_ON:         EQU  12');
  sl.Add('CHAN_ORN_BASE:           EQU  13');
  sl.Add('CHAN_ORN_COUNT:          EQU  14');
  sl.Add('CHAN_NOTE:               EQU  15');
  sl.Add('CHAN_SKEW_XORING:        EQU  16');
  sl.Add('');
  sl.Add('FREQ_TABLE:');
  sl.Add('              DEFW  $D8D8,$CC00,$00C0,$B6B5,$ACAB,$A2A1,$9998,$9090,$8888,$8180,$7979,$7372');
  sl.Add('              DEFW  $6C6C,$6666,$6060,$5B5A,$5655,$5151,$4D4C,$4848,$4444,$4040,$3D3C,$3939');
  sl.Add('              DEFW  $3636,$3333,$3030,$2E2D,$2B2B,$2928,$2626,$2424,$2222,$2020,$1F1E,$1D1C');
  sl.Add('              DEFW  $1B1B,$1A19,$1818,$1716,$1615,$1414,$1313,$1212,$1111,$1010,$0F0F,$0F0E');
  sl.Add('              DEFW  $0E0D,$0D0C,$0C0C,$0C0B,$0B0A,$0A0A,$0A09,$0909,$0908,$0808,$0807,$0707');
  sl.Add('');
  sl.Add('PLAY_MUSIC:');
  sl.Add('              DI');
  sl.Add('              EX    AF,AF''');
  sl.Add('              PUSH  AF');
  sl.Add('CONT_FLAG:');
  sl.Add('              LD    A,$FF');
  sl.Add('              OR    A');
  sl.Add('              JP    Z,END_PLAY');
  sl.Add('              PUSH  IX');
  sl.Add('              EXX');
  sl.Add('              PUSH  BC');
  sl.Add('              PUSH  DE');
  sl.Add('              PUSH  HL');
  sl.Add('              LD    A,I');
  sl.Add('              LD    H,A');
  sl.Add('              LD    A,(HL)');
  sl.Add('              LD    H,A');
  sl.Add('              LD    L,A');
  sl.Add('              INC   A');
  sl.Add('              JR    NZ,LE25A');
  sl.Add('              LD    L,$F4');
  sl.Add('LE25A:');
  sl.Add('              LD    A,(HL)');
  sl.Add('              LD    (HL),$C3');
  sl.Add('              INC   HL');
  sl.Add('              LD    (LE2AF+1),HL');
  sl.Add('              LD    (LE400+1),HL');
  sl.Add('              LD    E,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              LD    D,(HL)');
  sl.Add('              PUSH  HL');
  sl.Add('              PUSH  AF');
  sl.Add('              PUSH  DE');
  sl.Add('              LD    (SAVE_SP+1),SP');
  sl.Add('              ; Set initial pattern tempo from CH0');
  sl.Add('              LD    HL,(CHAN_0_DATA)');
  sl.Add('              LD    A,(HL)                ; Pattern tempo');
  sl.Add('              INC   HL');
  sl.Add('              LD    (QNT_VAL + 2),A');
  sl.Add('              LD    (CHAN_0_DATA),HL');
  sl.Add('');
  sl.Add('              ; Skip tempo byte in CH2');
  sl.Add('              LD    HL,(CHAN_1_DATA)');
  sl.Add('              INC   HL');
  sl.Add('              LD    (CHAN_1_DATA),HL');
  sl.Add('');
  sl.Add('              JR    NEXTQUANT');
  sl.Add('');
  sl.Add('ISR_2:');
  sl.Add('              DEC   IXL');
  sl.Add('              JR    Z,NEXTQUANT_CHK');
  sl.Add('              LD    SP,(SAVE_SP+1)');
  sl.Add('              PUSH  IX');
  sl.Add('              CALL  SETUP_GEN');
  sl.Add('              POP   IX');
  sl.Add('              JR    ISR2_END');
  sl.Add('');
  sl.Add('NEXTQUANT_CHK:');
  sl.Add('              CALL  CHECK_KEY');
  sl.Add('NEXTQUANT:');
  sl.Add('              CALL  PATSTEP_DRUMS');
  sl.Add('              LD    HL,CHAN_0_DATA + CHAN_NOTE_LEN_REMAIN');
  sl.Add('              DEC   (HL)');
  sl.Add('LE28B:        LD    IX,CHAN_0_DATA');
  sl.Add('              CALL  Z,PATTERN_STEP');
  sl.Add('              LD    HL,CHAN_1_DATA + CHAN_NOTE_LEN_REMAIN');
  sl.Add('              DEC   (HL)');
  sl.Add('SAVE_SP:      LD    SP,$0000');
  sl.Add('              LD    IX,CHAN_1_DATA');
  sl.Add('              CALL  Z,PATTERN_STEP');
  sl.Add('              LD    HL,CHAN_0_DATA + CHAN_ORN_BASE');
  sl.Add('LE2A3:        LD    A,(CHAN_1_DATA + CHAN_ORN_BASE)');
  sl.Add('              OR    (HL)');
  sl.Add('              LD    HL,ISR_1');
  sl.Add('              JR    Z,LE2AF');
  sl.Add('              LD    HL,ISR_2');
  sl.Add('LE2AF:        LD    (INTVEC_ADR),HL');
  sl.Add('              LD    A,(CHAN_0_DATA + CHAN_CHANNEL_ON)');
  sl.Add('              LD    (CHAN0_XOUT + 1),A');
  sl.Add('              LD    A,(CHAN_1_DATA + CHAN_CHANNEL_ON)');
  sl.Add('              LD    (CHAN1_XOUT + 1),A');
  sl.Add('              CALL  SETUP_GEN');
  sl.Add('QNT_VAL:      LD    IXL,4');
  sl.Add('ISR2_END:     EI');
  sl.Add('');
  sl.Add('GENLOOP:');
  sl.Add('              EXX');
  sl.Add('              EX    AF,AF''');
  sl.Add('              DJNZ  LE2F4');
  sl.Add('              EX    DE,HL');
  sl.Add('              ADD   HL,BC');
  sl.Add('              LD    B,H');
  sl.Add('CHAN0_XOUT:   XOR   $10');
  sl.Add('LE2CE:        JP    LE2FC');
  sl.Add('');
  sl.Add('ISR_0:        EI');
  sl.Add('              RET           ;');
  sl.Add('');
  sl.Add('ISR_1:');
  sl.Add('              DEC   IXL');
  sl.Add('              JR    Z,ISR1_PROC_QNT');
  sl.Add('              EI');
  sl.Add('              RET');
  sl.Add('ISR1_PROC_QNT:');
  sl.Add('              PUSH  HL');
  sl.Add('              PUSH  AF');
  sl.Add('              CALL  CHECK_KEY');
  sl.Add('              CALL  PATSTEP_DRUMS');
  sl.Add('              LD    HL,CHAN_0_DATA + CHAN_NOTE_LEN_REMAIN');
  sl.Add('              DEC   (HL)');
  sl.Add('              JR    Z,LE28B');
  sl.Add('              LD    HL,CHAN_1_DATA + CHAN_NOTE_LEN_REMAIN');
  sl.Add('              DEC   (HL)');
  sl.Add('              JR    Z,SAVE_SP');
  sl.Add('              LD    A,(QNT_VAL + 2)');
  sl.Add('              LD    IXL,A');
  sl.Add('              POP   AF');
  sl.Add('              POP   HL');
  sl.Add('              EI');
  sl.Add('              RET');
  sl.Add('');
  sl.Add('LE2F4:        RLCA');
  sl.Add('              RRCA');
  sl.Add('              JR    NC,LE2CE');
  sl.Add('              ADD   A,$80');
  sl.Add('              LD    H,L');
  sl.Add('              LD    L,B');
  sl.Add('LE2FC:        OUT   ($FE),A');
  sl.Add('              EXX');
  sl.Add('              EX    AF,AF''');
  sl.Add('              DJNZ  LE30C');
  sl.Add('              EX    DE,HL');
  sl.Add('              ADD   HL,BC');
  sl.Add('              LD    B,H');
  sl.Add('CHAN1_XOUT:   XOR   $10');
  sl.Add('LE307:        OUT   ($FE),A');
  sl.Add('JP_GENLOOP:   JP    GENLOOP');
  sl.Add('');
  sl.Add('LE30C:        RLCA');
  sl.Add('              RRCA');
  sl.Add('              JR    NC,LE307');
  sl.Add('              DEC   HL');
  sl.Add('              JP    JP_GENLOOP');
  sl.Add('');
  sl.Add('CHECK_KEY:');
  if iType = 1 then
  begin
    // Read keyboard/kemp
    sl.Add('              SUB   A');
    sl.Add('              IN    A,($FE)');
    sl.Add('              CPL');
    sl.Add('              AND   $1F');
    sl.Add('              JR    NZ,KEY_PRESSED');
    sl.Add('              IN    A,($1F)             ; Read kempston');
    sl.Add('              AND   0');
    sl.Add('              RET   Z');
    sl.Add('              JR    KEY_PRESSED');
  end
  else
    sl.Add('              RET');  // Ignore keypresses

  sl.Add('');
  sl.Add('TBL_FUNC_OFFSETS:');
  sl.Add('              DEFB  $9E                 ; Func $80 - Rest');
  sl.Add('              DEFB  $5E                 ; Func $81 - Glissando');
  sl.Add('              DEFB  $20                 ; Func $82 - End of pattern');
  sl.Add('              DEFB  $05                 ; Func $83 - End of song');
  sl.Add('              DEFB  $54                 ; Func $84 - Set transpose');
  sl.Add('              DEFB  $45                 ; Func $85 - Set Skew');
  sl.Add('              DEFB  $3E                 ; Func $86 - GenFX');
  sl.Add('              DEFB  $4A                 ; Func $87 - Set Skew XOR');
  sl.Add('');
  sl.Add('FUNC_83_SONG_END:');
  sl.Add('              SUB   A');
  sl.Add('              LD    (CONT_FLAG + 1),A');
  sl.Add('KEY_PRESSED:');
  sl.Add('              LD    SP,(SAVE_SP + 1)');
  sl.Add('              EX    AF,AF''');
  sl.Add('              POP   DE');
  sl.Add('              POP   AF');
  sl.Add('              POP   HL');
  sl.Add('              LD    (HL),D');
  sl.Add('              DEC   HL');
  sl.Add('              LD    (HL),E');
  sl.Add('              DEC   HL');
  sl.Add('              LD    (HL),A');
  sl.Add('              POP   HL');
  sl.Add('              POP   DE');
  sl.Add('              POP   BC');
  sl.Add('              EXX');
  sl.Add('              POP   IX');
  sl.Add('END_PLAY:     POP   AF');
  sl.Add('              EX    AF,AF''');
  sl.Add('              RET');
  sl.Add('');
  sl.Add('FUNC_82_PATTERN_END:');
  sl.Add('              LD    A,(IX + CHAN_CURPOS)  ; Get current position within song');
  sl.Add('              ADD   A,2');
  sl.Add('              CP    (IX + CHAN_ENDPOS)    ; Are we at the end of the song');
  sl.Add('              JR    NZ,LE352');
  sl.Add('              LD    A,(IX + CHAN_SONGLOOPPOS) ; Yes - Jump back to the loop start');
  sl.Add('LE352:        LD    (IX + CHAN_CURPOS),A');
  sl.Add('              LD    L,(IX + CHAN_PATT_TBL_ADR)');
  sl.Add('              LD    H,(IX + CHAN_PATT_TBL_ADR + 1)');
  sl.Add('              LD    C,A');
  sl.Add('              ADD   HL,BC');
  sl.Add('              LD    E,(HL)');
  sl.Add('              INC   HL                    ; relocatable');
  sl.Add('              LD    D,(HL)');
  sl.Add('              ; DE = address of next pattern');
  sl.Add('              LD    A,(DE)');
  sl.Add('              LD    (QNT_VAL + 2),A');
  sl.Add('              INC   DE');
  sl.Add('              JR    PATSTEP_LOOP');
  sl.Add('');
  sl.Add('FUNC_86_GENFX:');
  sl.Add('              LD    (IX + CHAN_CHANNEL_ON),$90');
  sl.Add('              JR    PATSTEP_LOOP');
  sl.Add('');
  sl.Add('FUNC_85_SKEW:');
  sl.Add('              LD    A,(DE)');
  sl.Add('              INC   DE');
  sl.Add('              LD    (IX + CHAN_SKEW_PARAM),A');
  sl.Add('              JR    PATSTEP_LOOP');
  sl.Add('');
  sl.Add('FUNC_87_SKEW_XOR:');
  sl.Add('              LD    A,(DE)');
  sl.Add('              INC   DE');
  sl.Add('              LD    (IX + CHAN_SKEW_XORING),A');
  sl.Add('              JR    PATSTEP_LOOP');
  sl.Add('');
  sl.Add('FUNC_84_TRANSPOSE:');
  sl.Add('              LD    A,(DE)');
  sl.Add('              INC   DE');
  sl.Add('              LD    (IX + CHAN_TRANSPOSE),A');
  sl.Add('              JR    PATSTEP_LOOP');
  sl.Add('');
  sl.Add('FUNC_81_GLIS:');
  sl.Add('              LD    A,(DE)');
  sl.Add('              INC   DE');
  sl.Add('              LD    (IX + CHAN_GENFX),A');
  sl.Add('              JR    PATSTEP_LOOP');
  sl.Add('');
  sl.Add('; *****************************************************************************');
  sl.Add('; * PATTERN_STEP');
  sl.Add('; *');
  sl.Add('; * Read the next value (a note, an effect, a note_len cmd, or an arpeggio)');
  sl.Add('; * from the pattern');
  sl.Add('; *****************************************************************************');
  sl.Add('PATTERN_STEP:');
  sl.Add('              LD    B,0');
  sl.Add('              LD    (IX + CHAN_GENFX),B');
  sl.Add('              LD    (IX + CHAN_CHANNEL_ON),$10');
  sl.Add('              LD    E,(IX + CHAN_DATA)');
  sl.Add('              LD    D,(IX + CHAN_DATA + 1)');
  sl.Add('PATSTEP_LOOP:');
  sl.Add('              LD    A,(DE)');
  sl.Add('              INC   DE');
  sl.Add('              CP    $C0');
  sl.Add('              JR    C,PLAY_NOTE    ; Is less than $C0 (note or effect)');
  sl.Add('              ADD   A,$20');
  sl.Add('              JR    C,SET_NOTELEN  ; Is E0 to FF (set note length)');
  sl.Add('              ADD   A,$20          ; Else is an arpeggio (C0 - DF)');
  sl.Add('              LD    C,A');
  sl.Add('LD_HL_ORNOFF: LD    HL,ORN_OFFSETS');
  sl.Add('              ADD   HL,BC');
  sl.Add('              LD    A,(HL)');
  sl.Add('              LD    (IX + CHAN_ORN_BASE),A');
  sl.Add('              JR    PATSTEP_LOOP');
  sl.Add('');
  sl.Add('; *****************************************************************************');
  sl.Add('; * SET_NOTELEN');
  sl.Add('; *');
  sl.Add('; * Set the length of all following notes in the channel');
  sl.Add('; *****************************************************************************');
  sl.Add('SET_NOTELEN:  INC   A');
  sl.Add('              LD    (IX + CHAN_NOTE_LEN_TOTAL),A');
  sl.Add('              JR    PATSTEP_LOOP');
  sl.Add('');
  sl.Add('PLAY_NOTE:');
  sl.Add('              OR    A');
  sl.Add('              JP    P,SIMPLE_NOTE                ; Value $00 - $7F are notes');
  sl.Add('              LD    C,A                          ; $80 - $BF are effects');
  sl.Add('              LD    HL,TBL_FUNC_OFFSETS - $80');
  sl.Add('              ADD   HL,BC');
  sl.Add('              LD    C,(HL)');
  sl.Add('              ADD   HL,BC');
  sl.Add('              JP    (HL)                         ; execute effect function');
  sl.Add('');
  sl.Add('FUNC_80_REST:                                    ; On entry B=0');
  sl.Add('              LD    (IX + CHAN_CHANNEL_ON),B     ; Silence this channel');
  sl.Add('');
  sl.Add('SIMPLE_NOTE:  LD    (IX + CHAN_NOTE),A');
  sl.Add('              LD    (IX + CHAN_ORN_COUNT),B      ; B = 0');
  sl.Add('              LD    A,(IX + CHAN_NOTE_LEN_TOTAL)');
  sl.Add('              LD    (IX + CHAN_NOTE_LEN_REMAIN),A');
  sl.Add('              LD    (IX + CHAN_DATA + 1),D');
  sl.Add('              LD    (IX + CHAN_DATA),E');
  sl.Add('              RET');
  sl.Add('');
  sl.Add('SETUP_GEN:');
  sl.Add('              LD    IX,CHAN_0_DATA');
  sl.Add('              CALL  SETUP_GEN_CHAN');
  sl.Add('              EXX');
  sl.Add('              EX    AF,AF''');
  sl.Add('              LD    IX,CHAN_1_DATA');
  sl.Add('SETUP_GEN_CHAN:');
  sl.Add('              LD     A,(IX + CHAN_SKEW_PARAM)');
  sl.Add('              XOR    (IX + CHAN_SKEW_XORING)');
  sl.Add('              LD     (IX + CHAN_SKEW_PARAM),A    ; Store the xored value');
  sl.Add('              SUB    A');
  sl.Add('              LD     D,A');
  sl.Add('              LD     E,(IX + CHAN_ORN_BASE)');
  sl.Add('LD_HL_ORNDAT: LD     HL,ORNAMENTS_DATA');
  sl.Add('              ADD    HL,DE');
  sl.Add('              LD     E,(IX + CHAN_ORN_COUNT)');
  sl.Add('              ADD    HL,DE');
  sl.Add('              LD     A,(HL)');
  sl.Add('              OR     A');
  sl.Add('              JP     P, LE40A                    ; 00-7F = note offset');
  sl.Add('              INC    A');
  sl.Add('              JR     NZ,LE405                    ; 80-FE = note offset + reset');
  sl.Add('              LD     HL,ISR_1                    ; FF - end ornament, no need for ISR2');
  sl.Add('LE400:        LD     (INTVEC_ADR),HL');
  sl.Add('              JR     LE40E');
  sl.Add('LE405:        DEC    A');
  sl.Add('              AND    $7F');
  sl.Add('              LD     E,$FF                       ; Restart ornament');
  sl.Add('LE40A:        INC    E');
  sl.Add('              LD     (IX + CHAN_ORN_COUNT),E     ; Incremement the ornament counter');
  sl.Add('LE40E:        LD     H,D                         ; d = 0');
  sl.Add('              ADD    A,(IX + CHAN_NOTE)');
  sl.Add('              ADD    A,(IX + CHAN_TRANSPOSE)');
  sl.Add('              ADD    A,A');
  sl.Add('              LD     HL,FREQ_TABLE');
  sl.Add('              LD     E,A');
  sl.Add('              ADD    HL,DE');
  sl.Add('              LD     E,(HL)                      ; NoteFrq1 into E');
  sl.Add('              INC    HL');
  sl.Add('              LD     C,(HL)                      ; NoteFrq2 into C');
  sl.Add('              LD     A,(IX + CHAN_SKEW_PARAM)');
  sl.Add('              OR     A');
  sl.Add('              LD     L,D                         ; d=0');
  sl.Add('              JR     Z,NO_SKEW');
  sl.Add('              ADD    A,A');
  sl.Add('              LD     H,A');
  sl.Add('              JR     NC,LE42A');
  sl.Add('              ADD    HL,DE');
  sl.Add('LE42A:');
  sl.Add('              ADD    HL,HL');
  sl.Add('              JR     NC,LE42E');
  sl.Add('              ADD    HL,DE');
  sl.Add('LE42E:');
  sl.Add('              ADD    HL,HL');
  sl.Add('              JR     NC,LE432');
  sl.Add('              ADD    HL,DE');
  sl.Add('LE432:');
  sl.Add('              ADD    HL,HL');
  sl.Add('              JR     NC,LE436');
  sl.Add('              ADD    HL,DE');
  sl.Add('LE436:');
  sl.Add('              ADD    HL,HL');
  sl.Add('              JR     NC,LE43A');
  sl.Add('              ADD    HL,DE');
  sl.Add('LE43A:');
  sl.Add('              ADD    HL,HL');
  sl.Add('              JR     NC,LE43E');
  sl.Add('              ADD    HL,DE');
  sl.Add('LE43E:');
  sl.Add('              ADD    HL,HL');
  sl.Add('              JR     NC,LE442');
  sl.Add('              ADD    HL,DE');
  sl.Add('LE442:');
  sl.Add('              ADD    HL,HL');
  sl.Add('              JR     NC,LE446');
  sl.Add('              ADD    HL,DE');
  sl.Add('LE446:');
  sl.Add('              LD     L,H');
  sl.Add('NO_SKEW:');
  sl.Add('              LD     A,C         ; C = initial phase1 period');
  sl.Add('              ADD    A,L         ; L = skew value');
  sl.Add('              LD     H,A         ; store skewed phase1 in H');
  sl.Add('              LD     A,E         ; E = initial phase2 period');
  sl.Add('              SUB    L');
  sl.Add('              LD     L,D         ; initialise fractional period to 0');
  sl.Add('              LD     E,D         ; initialise fractional period to 0');
  sl.Add('              LD     D,A         ; skewed phase2 period');
  sl.Add('              LD     C,(IX + CHAN_GENFX)');
  sl.Add('LE452:');
  sl.Add('              LD     A,BORDER_CLR');
  sl.Add('              LD     B,H         ; init counter with phase1');
  sl.Add('              RET');
  sl.Add('');
  sl.Add('; ************************************************************************');
  sl.Add('; * PATSTEP_DRUMS');
  sl.Add('; *');
  sl.Add('; * Percussion');
  sl.Add('; ************************************************************************');
  sl.Add('PATSTEP_DRUMS:');
  sl.Add('              LD    HL,PATDRUM_CNT_QTS');
  sl.Add('              DEC   (HL)');
  sl.Add('              RET   NZ');
  sl.Add('              LD    HL,(PATDRUM_PTR)');
  sl.Add('              LD    A,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              OR    A');
  sl.Add('              JR    NZ,LE483     ; Jump if not end of pattern');
  sl.Add('              PUSH  BC');
  sl.Add('              PUSH  DE');
  sl.Add('              LD    B,A          ; A = 0 at this point');
  sl.Add('              LD    HL,(CURPOS_DRUM)');
  sl.Add('              LD    A,L');
  sl.Add('              ADD   A,2');
  sl.Add('              CP    H');
  sl.Add('              JR    NZ,LE472      ; jump if not end of song');
  sl.Add('              LD    A,(DRUM_SONGLOOPPOS)');
  sl.Add('LE472:');
  sl.Add('              LD    (CURPOS_DRUM),A');
  sl.Add('              LD    C,A');
  sl.Add('              LD    HL,(LISTDRUM_AD)');
  sl.Add('              ADD   HL,BC        ; here B=0');
  sl.Add('              LD    E,(HL)');
  sl.Add('              INC   HL            ; relocatable');
  sl.Add('              LD    D,(HL)');
  sl.Add('              EX    DE,HL');
  sl.Add('              LD    A,(HL)');
  sl.Add('              INC   HL');
  sl.Add('              OR    A');
  sl.Add('              POP   DE');
  sl.Add('              POP   BC');
  sl.Add('LE483:');
  sl.Add('              LD    (PATDRUM_PTR),HL');
  sl.Add('              JP    M,PLAYNOISE');
  sl.Add('              LD    (PATDRUM_CNT_QTS),A');
  sl.Add('              RET');
  sl.Add('');
  sl.Add('PLAYNOISE:    LD    HL,PATDRUM_CNT_QTS');
  sl.Add('              LD    B,(HL)       ; here (HL) = 0');
  sl.Add('              INC   (HL)');
  sl.Add('              PUSH  BC');
  sl.Add('              PUSH  DE');
  sl.Add('              LD    C,A');
  sl.Add('              LD    HL,NOISE_OFFSETS - $80');
  sl.Add('              ADD   HL,BC');
  sl.Add('              LD    C,(HL)');
  sl.Add('              ADD   HL,BC');
  sl.Add('              LD    A,(LE452 + 1)');
  sl.Add('              JP    (HL)');
  sl.Add('');
  sl.Add('NOISE_OFFSETS:');
  sl.Add('              DEFB  $0F,$13,$17,$07,$1');
  sl.Add('NOISE_01:     LD    BC,$E01F');
  sl.Add('              JR    LEA24');
  sl.Add('NOISE_07:     LD    BC,$C0A1');
  sl.Add('              JR    LEA24');
  sl.Add('NOISE_OF:     LD    BC,$200F');
  sl.Add('              JR    LEA24');
  sl.Add('NOISE_13:     LD    BC,$CF3F');
  sl.Add('              JR    LEA24');
  sl.Add('NOISE_17:     LD    BC,$283F');
  sl.Add('LEA24:        LD    HL,$014A');
  sl.Add('              JR    LEA30');
  sl.Add('LEA29:        LD    E,8');
  sl.Add('LEA2B:        DEC   H');
  sl.Add('              JR    NZ,LEA3E');
  sl.Add('              XOR   $10');
  sl.Add('LEA30:        OUT   ($FE),A');
  sl.Add('              LD    E,A');
  sl.Add('              LD    A,R');
  sl.Add('              XOR   L');
  sl.Add('              RLCA');
  sl.Add('              LD    L,A');
  sl.Add('              AND   C');
  sl.Add('              INC   A');
  sl.Add('              LD    H,A');
  sl.Add('              LD    A,E');
  sl.Add('              JR    LEA41');
  sl.Add('LEA3E:        DEC   E');
  sl.Add('              JR    NZ,LEA2B');
  sl.Add('LEA41:        DJNZ  LEA29');
  sl.Add('              POP   DE');
  sl.Add('              POP   BC');
  sl.Add('              RET');
end;

procedure SVG_CompressMelody(SongIn: TSTSong; SongOut: TSTSong; iChan: integer);
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
          (SongIn.MelodyMatchSVG(iChan,SongIn.SongLayout[i],
                              SongIn.SongLayout[j])) then
          SongOut.SongLayout[j] := SongIn.SongLayout[i];
      end;
    end;
  end;
end;

procedure SVG_CompressPercussion(SongIn: TSTSong; SongOut: TSTSong);
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

function SavageTransposeNote(cNote: byte; iTrans: integer): byte;
var
  iNew: integer;
begin
  if (cNote >= $80) then
    Result := cNote
  else
  begin
    iNew := cNote + iTrans;
    if (iNew > 59) and (iNew < 79) then
      Result := $80 // Note is off-scale high - replace with a Rest
    else if (iNew > 107) and (iNew <119) then
      Result := iNew - 107  // Note has been transposed up from bottom 6 to within std range
    else if (iNew < 0) and (iNew >= -6) then
      Result := iNew + 107 // Note has been transposed down from bottom 6 to within std range
    else if (iNew >= 0) and (iNew <= 59) then
      Result := iNew
    else if (iNew >= 101) and (iNew <= 106) then
      Result := iNew
    else if (iNew < -6) then
      Result := $80 // Note is off-scale low - replace with a rest
    else
      Result := 255;
  end;
end;

procedure AddNoteData(sl: TStringList; iNote,iNoteLen: integer; var iLastNoteLen: integer; iTranspose: integer);
begin
  if (iTranspose <> 0) and (iNote < $80) then
  begin
    // Transpose the note and check it's within range
    SavageTransposeNote(iNote,iTranspose);
  end;

  while (iNoteLen > 32) do
  begin
    sl.Add('        DEFB  $FF,$' + IntToHex(iNote,2));
    Dec(iNoteLen,32);
  end;
  if iNoteLen > 0 then
  begin
    if (iNoteLen <> iLastNoteLen) then
    begin
      sl.Add('        DEFB $' + IntToHex($DF + iNoteLen,2) + ',$' + IntToHex(iNote,2));
      iLastNoteLen := iNoteLen;
    end
    else
      sl.Add('        DEFB $' + IntToHex(iNote,2));
  end;
end;

procedure SVG_AddPatternData(sl: TStringList; Song: TSTSong; iPat: integer; iTranspose: integer; iChan: integer);
var
  i,iNote,iNoteLen,iLastNoteLen: integer;
begin
  sl.Add('PAT' + IntToStr(iChan) + '_' + IntToStr(iPat) + ':');
  sl.Add('        DEFB ' + IntToStr(21 - Song.Pattern[iPat].Tempo) + '    ; Pattern Tempo');

  // Channel 1 pattern data
  iNote := $80;  // Rest (erk! - notes cannot sustain between patterns with Savage!)
  iNoteLen := 0; // Length of note in Rows
  iLastNoteLen := 99999; // Last note length written out for this pattern
  for i := 1 to Song.Pattern[iPat].Length do
  begin
    if ((Song.Pattern[iPat].Chan[iChan][i] = 255) and
        (Song.SvgPatternData[iPat].Glissando[iChan][i] = 256) and
        (Song.SvgPatternData[iPat].Skew[iChan][i] = 256) and
        (Song.SvgPatternData[iPat].SkewXOR[iChan][i] = 256) and
        (Song.SvgPatternData[iPat].Arpeggio[iChan][i] = 256)) then
      Inc(iNoteLen)
    else
    begin
      if iNoteLen > 0 then
        AddNoteData(sl,iNote,iNoteLen,iLastNoteLen,iTranspose);

      if (Song.SvgPatternData[iPat].Warp[iChan][i] <> 0) then
        sl.Add('           DEFB $86' + '       ; Phase effect');
      if (Song.SvgPatternData[iPat].Glissando[iChan][i] < 256) then
        sl.Add('           DEFB $81,$' + IntToHex(Song.SvgPatternData[iPat].Glissando[iChan][i],2) + '   ; Glissando');
      if (Song.SvgPatternData[iPat].Skew[iChan][i] < 256) then
        sl.Add('           DEFB $85,$' + IntToHex(Song.SvgPatternData[iPat].Skew[iChan][i],2) + '   ; Skew');
      if (Song.SvgPatternData[iPat].SkewXOR[iChan][i] < 256) then
        sl.Add('           DEFB $87,$' + IntToHex(Song.SvgPatternData[iPat].SkewXOR[iChan][i],2) + '   ; SkewXOR');
      if (Song.SvgPatternData[iPat].Arpeggio[iChan][i] < 32) then
        sl.Add('           DEFB $' + IntToHex(Song.SvgPatternData[iPat].Arpeggio[iChan][i] + $C0,2) + '   ; Arpeggio');

      if Song.Pattern[iPat].Chan[iChan][i] <> 255 then
        iNote := Song.Pattern[iPat].Chan[iChan][i];

      if (iNote = $82) then iNote := $80; // Savage rests are $80, not $82
      if (iNote < 60) then inc(iNote,6);
      if (iNote > 100) and (iNote < 107) then dec(iNote,101);  // bottom 6 notes
      
      iNoteLen := 1;
    end;
  end;
  if iNoteLen > 0 then
    AddNoteData(sl,iNote,iNoteLen,iLastNoteLen,iTranspose);
  sl.Add('        DEFB $82   ; End of Pattern');
end;

procedure SVG_AddDrumPatternData(sl: TStringList; Song: TSTSong; iPat: integer);
var
  i, iNoteLen: integer;
begin
  sl.Add('DRM' + IntToStr(iPat) + ':');

  // Drum pattern data
  iNoteLen := 0;
  for i := 1 to Song.Pattern[iPat].Length do
  begin
    if (Song.Pattern[iPat].Drum[i] >= $81) and (Song.Pattern[iPat].Drum[i] <= $85) then
    begin
      if (iNoteLen > 0) then
        sl.Add('        DEFB $' + IntToHex(iNoteLen,2));
      sl.Add('        DEFB $' + IntToHex(Song.Pattern[iPat].Drum[i] - 1,2));
      iNoteLen := 0;
    end
    else
      Inc(iNoteLen);
  end;
  if iNoteLen > 0 then
    sl.Add('        DEFB $' + IntToHex(iNoteLen,2));
    
  sl.Add('        DEFB $00   ; End of pattern');
end;

procedure SVG_AddSongData(sl: TStringList; Song: TSTSong; bLoop: boolean; iTranspose: integer);
var
  i,j,iOrnOff: integer;
  CompressedSong: TSTSong;
begin
  sl.Add('SONG_INITDATA_0:');
  sl.Add('              ; *** Channel 1 ***');
  if (not bLoop) then
    sl.Add('              DEFB  $FF   ; no song end loop')
  else
    sl.Add('              DEFB  ' + IntToStr(Song.SongLength * 2) + '  ; song end');
  sl.Add('              DEFB  ' + IntToStr(Song.LoopStart * 2)  + '  ; loop');
  sl.Add('              DEFW  C1_PATTERNS');
  sl.Add('              ; *** Channel 2 ***');
  if (not bLoop) then
    sl.Add('              DEFB  $FF   ; no song end loop')
  else
    sl.Add('              DEFB  ' + IntToStr(Song.SongLength * 2) + '  ; song end');
  sl.Add('              DEFB  ' + IntToStr(Song.LoopStart * 2)  + '  ; loop');
  sl.Add('              DEFW  C2_PATTERNS');
  sl.Add('              ; *** Percussion ***');
  sl.Add('              DEFB  ' + IntToStr(Song.SongLength * 2) + '  ; song end');
  sl.Add('              DEFB  ' + IntToStr(Song.LoopStart * 2)  + '  ; loop');
  sl.Add('              DEFW  PERC_PATTERNS');
  sl.Add('              DEFW  ORN_OFFSETS');
  sl.Add('              DEFW  ORNAMENTS_DATA');
  sl.Add('');
  sl.Add('ORN_OFFSETS:  DEFB  $00');

  iOrnOff := 1;
  for i := 1 to Song.GetHighestArpeggio() do
  begin
    sl.Add('              DEFB  $' + IntToHex(iOrnOff and 255,2));
    inc(iOrnOff,Song.SVGArpeggio[i].Length+1);
    if iOrnOff > 255 then iOrnOff := 255;
  end;
  sl.Add('');
  sl.Add('ORNAMENTS_DATA:');
  sl.Add('              DEFB  $80       ; Ornament 0 (no arpeggio)');
  for i := 1 to Song.GetHighestArpeggio() do
  begin
    for j := 1 to Song.SVGArpeggio[i].Length do
      if j = Song.SVGArpeggio[i].Length then
        sl.Add('              DEFB  $' + IntToHex(Song.SVGArpeggio[i].Value[j] and $FF,2))
      else
        sl.Add('              DEFB  $' + IntToHex(Song.SVGArpeggio[i].Value[j] and $7F,2));

      if Song.SVGArpeggio[i].Value[Song.SVGArpeggio[i].Length] and $80 = 0 then
      begin
        // $FF end marker for non-looped arpeggios
        sl.Add('              DEFB  $FF');
      end;
  end;
  sl.Add('');

  CompressedSong := TSTSong.Create;
  SVG_CompressMelody(Song,CompressedSong,1);

  sl.Add('C1_PATTERNS:  DEFW      PAT1_' + IntToStr(CompressedSong.SongLayout[0]));
  for i := 1 to CompressedSong.SongLength - 1 do
  begin
    sl.Add('              DEFW      PAT1_' + IntToStr(CompressedSong.SongLayout[i]));
  end;
  if (not bLoop) then
    sl.Add('              DEFW      SONG_END');

  sl.Add('');

  // C1 PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressedSong.IsPatternUsed(i) then
    begin
      SVG_AddPatternData(sl,Song,i,iTranspose,1); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;
  if (not bLoop) then
    sl.Add('SONG_END:     DEFB $01,$83');  

  SVG_CompressMelody(Song,CompressedSong,2);

  sl.Add('');
  sl.Add('C2_PATTERNS:  DEFW      PAT2_' + IntToStr(CompressedSong.SongLayout[0]));
  for i := 1 to CompressedSong.SongLength - 1 do
  begin
    sl.Add('              DEFW      PAT2_' + IntToStr(CompressedSong.SongLayout[i]));
  end;
  if (not bLoop) then
    sl.Add('              DEFW      SONG_END');
      
  sl.Add('');
  // C2 PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressedSong.IsPatternUsed(i) then
    begin
      SVG_AddPatternData(sl,Song,i,iTranspose,2); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;

  SVG_CompressPercussion(Song,CompressedSong);

  sl.Add('PERC_PATTERNS:');
    sl.Add('              DEFW      DRM' + IntToStr(CompressedSong.SongLayout[0]));
  for i := 1 to CompressedSong.SongLength - 1 do
  begin
    sl.Add('              DEFW      DRM' + IntToStr(CompressedSong.SongLayout[i]));
  end;
  sl.Add('');
  // PERCUSSION PATTERN DATA
  for i := 0 to 255 do
  begin
    if CompressedSong.IsPatternUsed(i) then
    begin
      SVG_AddDrumPatternData(sl,Song,i); // Add the pattern (from the uncompressed version of the song, as the compressed version does not contain any pattern data)
    end;
  end;
{

SONG_INITDATA_0:
              ; *** CHANNEL 1 ***
              DEFB  $B6          ; end position
              DEFB  4            ; song loop position
              DEFW  C1_PATTERNS
              ; *** CHANNEL 2 ***
              DEFB  $1E          ; end position
              DEFB  4            ; song loop position
              DEFW  C2_PATTERNS
              ; *** PERCUSSION ***
              DEFB  $54          ; end position
              DEFB  8		 ; song	loop position
              DEFW  PERC_PATTERNS

ORN_OFFSETS:  DEFB  $00
              DEFB  $01
              DEFB  $06
              DEFB  $0A
              DEFB  $0E

ORNAMENTS_DATA:
              DEFB  $80          ; ORNAMENT 0 (no arpeggio)
              DEFB  $0C          ; ORNAMENT 1
              DEFB  $00
              DEFB  $0C
              DEFB  $0C
              DEFB  $FF
              DEFB  $00          ; ORNAMENT 2
              DEFB  $07
              DEFB  $04
              DEFB  $FF
              DEFB  $00          ; ORNAMENT 3
              DEFB  $07
              DEFB  $03
              DEFB  $FF
              DEFB  $0C          ; ORNAMENT 4
              DEFB  $00
              DEFB  $0A
              DEFB  $03
              DEFB  $00
              DEFB  $07
              DEFB  $FF

C1_PATTERNS:                 ; off_E5A0
              DEFW  PAT_E7A9
              DEFW  PAT_E7DA
              DEFW  PAT_E81F
;              DEFW  PAT_E80D
;              DEFW  PAT_E821
;              DEFW  PAT_E816
	
C2_PATTERNS:                 ; off_E656
              DEFW  PAT_E7AB
              DEFW  PAT_E7C7
              DEFW  PAT_E83E
;              DEFW  PAT_E83E
;              DEFW  PAT_E884
;              DEFW  PAT_E8CE

PERC_PATTERNS:               ; compat_adrs
              DEFW  DRM_E7F1
              DEFW  DRM_E7EF
              DEFW  DRM_E800
              DEFW  DRM_E95F
              DEFW  DRM_E95F
              DEFW  DRM_E95F

PAT_TEST:     DEFB  $85,$80,$87,$93,$E1,$10,$11,$12,$E9,$10,$11,$12,$13,$E9,$11,$80,$80,$80,$12,$80,$80,$80,$82


PAT_E7A9:     DEFB  $84,$F4
PAT_E7AB:     DEFB  $85,$00,$E1,$10,$80,$10,$80,$10,$80,$10,$E3,$11,$E1,$10,$80,$10
              DEFB  $E3,$13,$15,$E1,$10,$80,$10,$80,$10,$80,$10,$82
PAT_E7C7:     DEFB  $85,$C8,$81,$FF,$22,$81,$FF,$22,$80,$81,$FF,$22,$80,$81,$FF,$22
              DEFB  $E3,$80,$82 
PAT_E7DA:     DEFB  $86,$81,$06,$3B,$86,$81,$06,$3B,$80,$86,$81,$06,$3B,$80,$86,$81
              DEFB  $06,$3B,$E3,$80,$82
DRM_E7EF:     DEFB  $83,$01
DRM_E7F1:     DEFB  $83,$01,$83,$01,$81,$01,$83,$01,$83,$01,$83,$01,$81,$01,$00
DRM_E800:     DEFB  $84,$01,$84,$03,$84,$03,$84,$01,$82,$01,$80,$80,$00
PAT_E81F:     DEFB  $84,$00,$E1,$85,$28,$09,$15,$80,$E0,$09,$80,$E1,$09,$15,$80,$09
              DEFB  $E1,$09,$15,$80,$E0,$09,$80,$E1,$09,$15,$80,$E0,$07,$08,$82
PAT_E83E:     DEFB  $85,$CC,$87,$20,$E3,$1D,$E0,$1C,$80,$F1,$1C,$E3,$21,$E2,$1F,$E0
              DEFB  $80,$E3,$1F,$E0,$1D,$80,$F5,$1D,$E3,$1E,$FB,$1F,$E3,$1A,$EF,$1C
              DEFB  $86,$81,$28,$28,$E1,$1A,$E2,$18,$E0,$80,$F1,$18,$E3,$1A,$1C,$1A
              DEFB  $E0,$18,$80,$F5,$18,$E3,$19,$FB,$1A,$E3,$13,$EF,$15,$E7,$86,$81
              DEFB  $50,$34,$80,$84,$00,$82
DRM_E95F:     DEFB  $82,$01,$82,$01,$81,$01,$82,$01,$82,$01,$82,$01,$81,$01,$82,$01
              DEFB  $82,$01,$82,$01,$81,$01,$82,$01,$82,$01,$82,$01,$81,$01,$82,$01
              DEFB  $82,$01,$82,$01,$81,$01,$82,$01,$82,$01,$82,$01,$81,$01,$82,$01
              DEFB  $82,$01,$82,$01,$81,$01,$82,$01,$82,$01,$82,$01,$81,$01,$80,$80
              DEFB  $00
}
end;

end.

