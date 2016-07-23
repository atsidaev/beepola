unit SpecEmu;

interface

uses MMSystem, STSong, STPatterns, Classes;

type
  TNewPatternFunc = procedure() of object;
  TPatternTickFunc = procedure() of object;

  TEngine = (SFX, TMB, MSD, P1D, P1S, SVG, RMB, PLP, STK, ABOUT);

  TSpecEmu = class(TObject)
  private
    //bLog: boolean;
    //F: TextFile;
    iPerfFreq: int64;
    iSVGStartPos: integer;
    FVolume: integer;
    FNewPatternFunc: TNewPatternFunc;
    FPatternTickFunc: TPatternTickFunc;
    FEngine: TEngine;
    FWavOutFile: string;
    bOutputWavFile: boolean;
    FWav: TFileStream;
    iWavDataLen: Cardinal;
    iPatternTickAddr: array [0..2] of Word;
    iNewPatternAddr: array [0..2] of Word;

    // Main registers
    regA, regF, regB, regC: Byte;
    regHL, regDE: Word;

    // Alternate registers
    regAF_, regHL_, regDE_, regBC_: Word;

    // Other registers
    regPC, regSP: Word;
    regIX, regIY, regID: Word;
    regI, regR, regRtemp: Byte;
    regIM: byte;

    waveout: array [0..4410] of byte;

    bInterruptsEnabled: boolean;
    Parity: array[0..255] of Byte;
    // Speccy hardware
    Mem: array [0..65535] of Byte;  // RAM
    TStates: integer;
    cBeeperVal: byte;
    cWaveBuf: array [0..70000] of byte; // 69888 Ts per WaveOut
    iWavePtr: integer;
    iLastIntTime: cardinal;
    iLast5IntTime: int64;
    WavHdr: array [0..10] of TWaveHdr;
    iBufNum: integer;
    ghMem: array [0..10] of cardinal;
    gpMem: array [0..10] of Pointer;
    procedure SetBC(nn: Word);
    function NextPCW: Word;
    procedure exx;
    procedure pushw(w: Word);
    procedure pokeb(addr: Word; b: byte);
    procedure pokew(addr, w: Word);
    function execute_ed: Word;
    function popw: Word;
    procedure InitParityTable;
    procedure or_a(b: byte);
    function execute_cb: Word;
    function srl(b: Byte): Byte;
    procedure SetD(b: byte);
    function inc8(b: byte): byte;
    function dec8(b: byte): byte;
    function outb(port: Word; b: Byte): Word;
    procedure SetE(b: byte);
    procedure and_a(b: byte);
    procedure scf;
    procedure add_a(b: byte);
    function peekw(addr: Word): Word;
    procedure bit(b, r: byte);
    procedure cp_a(b: byte);
    function add16(a, b: Word): Word;
    procedure AddWaveOutBuffer(cBeeperVal: byte; iTS: integer);
    procedure OutputWave;
    procedure InitializeWaveOut;
    procedure xor_a(b: byte);
    procedure SetEngine(const Value: TEngine);
    function LoadSFXPattern(Patt: STPatterns.TPattern): integer;
    function LoadTMBPattern(Patt: STPatterns.TPattern): integer;
    procedure SFXAddNoteData(var iMemPtr: integer; iNote, iNoteLen: integer);
    function LoadSFXSong(Song: TSTSong; iStartPos: integer): integer;
    function LoadTMBSong(Song: TSTSong; iStartPos: integer): integer;
    function execute_id: Word;
    function sra(b: Byte): Byte;
    procedure TMBAddNoteData(var iMemPtr: integer; iCH1, iCH2: integer);
    function LoadMSDPattern(Patt: STPatterns.TPattern): integer;
    procedure MSDAddNoteData(var iMemPtr: integer; iCH1, iCH2: integer);
    function rlc(b: byte): byte;
    procedure MSDAddDrumData(var iMemPtr: integer; iCH1, iDrum: integer);
    function LoadMSDSong(Song: TSTSong; iStartPos: integer): integer;
    procedure SetWavOutFile(const Value: string);
    procedure OutputWaveFile;
    function LoadP1DPattern(Patt: STPatterns.TPattern; Song: TSTSong): integer;
    function LoadP1DSong(Song: TSTSong; iStartPos: integer): integer;
    procedure AddIdleTime(var iPtr: integer; iIdleTime: integer);
    function bitRes(b, val: byte): byte;
    procedure sub_a(b: byte);
    procedure rl_a;
    procedure P1DAddPatternData(Patt: STPatterns.TPattern;
      var iMemPtr: integer);
    function LoadP1SPattern(Patt: STPatterns.TPattern; Song: TSTSong): integer;
    function LoadP1SSong(Song: TSTSong; iStartPos: integer): integer;
    procedure SetVolume(const Value: integer);
    procedure execute_id_cb(op: byte; adr: Word);
    function SvgAddPatternData(Patt: STPatterns.TPattern;
      SvgPatt: STPatterns.TPatternSvg; iChan, iMemPtr: integer): integer;
    procedure SvgAddNoteData(iNote, iNoteLen: integer;
      var iLastNoteLen: integer; var iMemPtr: integer);
    procedure SVG_AddDrumPatternData(Patt: STPatterns.TPattern;
      var iMemPtr: integer);
    procedure DisplayEmuError(sErr: string; iIntr: byte; regPC: word);
    function LoadSVGSong(Song: TSTSong; iStartPos: integer): integer;
    function LoadRMBPattern(Patt: STPatterns.TPattern; Song: TSTSong): integer;
    function LoadRMBSong(Song: TSTSong; iStartPos: integer): integer;
    procedure RMBAddNoteData(var iMemPtr: integer; iCH1, iCH2: integer);
    function in_bc: Word;
    function sbc16(a, b: Word): Word;
    procedure adc_a(b: byte);
    procedure sbc_a(b: byte);
    procedure rr_a;
    function rrc(b: byte): byte;
    function bitSet(b, val: byte): byte;
    function rr(ans: byte): byte;
    function adc16(a, b: Word): Word;
    function rl(ans: byte): byte;
    procedure neg_a;
    function sla(b: Byte): Byte;
    procedure rrc_a;
  const
    Ts_PER_INTERRUPT = 69888;
    FLAG_S  = $80;
    FLAG_Z  = $40;
    FLAG_5  = $20;
    FLAG_H  = $10;
    FLAG_3  = $08;
    FLAG_PV = $04;
    FLAG_N  = $02;
    FLAG_C  = $01;
    FLAG_NOT_PV = $251;
  public
    hWaveOut: System.Cardinal;
    iIntCycle: integer;
    constructor Create(hWaveOutIn: System.Cardinal);
    destructor Destroy(); override;
    procedure Exec(bUntilInterrupt: boolean = true);
    function Interrupt(): Word;
    function LoadImage(sResName: string): integer;
    function LoadPlayerNote(iCh1, iCh2, iSus1, iSus2, iDrum: byte; iTempo: integer; Song: TSTSong = nil): integer;
    function LoadPlayerPattern(Patt: STPatterns.TPattern; SvgPatt: STPatterns.TPatternSVG; Song: TSTSong = nil): integer;
    function LoadPlayerSong(Song: TSTSong; iStartPos: integer = 0): integer;
    function GetPhaser1Drum(iIndex: integer; var A: array of byte): boolean;
    procedure ResetWaveBuffers();
    procedure SaveTop32K(sFileName: string);
    procedure CloseWaveFile;
    property Register_PC: Word read regPC write regPC;
    property Register_SP: Word read regSP write regSP;
    property OnNewPattern: TNewPatternFunc read FNewPatternFunc write FNewPatternFunc;
    property OnPatternTick: TPatternTickFunc read FPatternTickFunc write FPatternTickFunc;
    property Engine: TEngine read FEngine write SetEngine;
    property WavOutputFile: string read FWavOutFile write SetWavOutFile;
    property WavDataLength: Cardinal read iWavDataLen;
    property Volume: Integer read FVolume write SetVolume;
    procedure SetDrum(iIndex: byte; iOffset: integer; bVal: boolean);
    function SavageLoadPlayerNote(iCh1,iCh2: byte; iGlis1,iGlis2: integer;
                                  iSkew1,iSkew2: integer;
                                  iXor1,iXor2: integer;
                                  iArp1,iArp2: integer;
                                  iPhase1,iPhase2: integer;
                                  iDrum: byte; iTempo: integer; Song: TSTSong = nil): integer;
    function LoadSVGPattern(Patt: STPatterns.TPattern; SvgPatt: STPatterns.TPatternSvg; Song: TSTSong): integer;
  end;

implementation

{ TSpecEmu }

uses Math, SysUtils, Dialogs, Windows, GrokUtils, Forms;

procedure TSpecEmu.InitParityTable();
var
  i: integer;
  p: boolean;
  j: Byte;
begin
  for i := 0 to 255 do
  begin
    p := true;
    for j := 0 To 7 do
      if ((i and Trunc(IntPower(2,j))) <> 0) then p := not p;

    if p then Parity[i] := FLAG_PV else Parity[i] := 0;
  end;
end;

constructor TSpecEmu.Create(hWaveOutIn: System.Cardinal);
begin
  if not QueryPerformanceFrequency(iPerfFreq) then
  begin
    iPerfFreq := 1000;
    ShowMessage('No high res timer available on this PC');
  end;
  // Initialize Spectrum
  regA := 0; regF := 0; regHL := 0; regPC := 0; regSP := 0;
  regI := 0; regR := 0; regIM := 0; regRtemp := 0;
  TStates := Ts_PER_INTERRUPT;
  InitParityTable();

  bOutputWavFile := false;
  FWavOutFile := '';
  iWavDataLen := 0;
  FWav := nil;
  FVolume := 100;
  hWaveOut := hWaveOutIn;
  InitializeWaveOut();

  FEngine := SFX;
end;

destructor TSpecEmu.Destroy;
var
  i: Integer;
begin
  for i := 0 to 10 do
  begin
    waveOutUnprepareHeader(hWaveOut,@WavHdr[i],SizeOf(WavHdr[i]));
    GlobalUnlock(ghMem[i]);
    GlobalFree(ghMem[i]);
  end;
  //waveOutClose(hWaveOut);

  CloseWaveFile(); // Close the Wav output file if one exists
  inherited;
end;

procedure TSpecEmu.Exec(bUntilInterrupt: boolean = true);
var
  pcb: Byte;
  wTemp: Word;
  d: Shortint; // (Signed byte for relative jumps)
  TStart: integer;
begin
  repeat
    if TStates <= 0 then
    begin
      TStates := TStates + Ts_PER_INTERRUPT - Interrupt();
      break;
    end;

    inc(regRtemp);

    // Call NewPatternFunc if we hit a new pattern...
    if (Assigned(FNewPatternFunc)) then
    begin
      if (regPC = iNewPatternAddr[0]) or (regPC = iNewPatternAddr[1]) or
         (regPC = iNewPatternAddr[2]) then
        FNewPatternFunc();
    end;
    // Call PatternTickFunc one starting a new pattern row
    if (Assigned(FPatternTickFunc)) then
    begin
      if (regPC = iPatternTickAddr[0]) or (regPC = iPatternTickAddr[1]) or
         (regPC = iPatternTickAddr[2]) then
        FPatternTickFunc();
    end;

    if (FEngine = SVG) then
    begin
      if ((regPC = 33345) and (regIX = 32899)) and (Assigned(FNewPatternFunc)) then
        FNewPatternFunc()
      else if (iSVGStartPos > 0) and (regPC = 32880) then
      begin
        // Set CHAN_DATA
        Mem[regIX] := Mem[regDE - 1 + (iSVGStartPos * 2)];
        Mem[regIX+1] := Mem[regDE + (iSVGStartPos * 2)];
        // Set CHAN_CURPOS
        mem[regIX+4] := iSVGStartPos * 2;
      end;
    end;

  {
    if regPC = $806c then
    begin
      bLog := not bLog;
      if bLog then
      begin
        AssignFile(F,'c:\dev\grok\specem\tzx\SPTRACK-TMB-806C.txt');
        Rewrite(F);
      end
      else
        CloseFile(F);
    end;

    if bLog then
      WriteLn(F,Format('%.4x',[regPC]));


    ShowMessage('PC: ' + Format('%.4x',[regPC]) + '   SP: ' + Format('%.4x',[regSP]) + #13#10 +
                'AF: ' + Format('%.2x%.2x',[regA,regF]) + '  AF'':' + Format('%.4x',[regAF_]) + #13#10 +
                'BC: ' + Format('%.2x%.2x',[regB,regC]) + '  BC'':' + Format('%.4x',[regBC_]) + #13#10 +
                'DE: ' + Format('%.4x',[regDE]) + '  DE'':' + Format('%.4x',[regDE_]) + #13#10 +
                'HL: ' + Format('%.4x',[regHL]) + '  HL'':' + Format('%.4x',[regHL_]) + #13#10 +
                'IX: ' + Format('%.4x',[regIX]) + '   IY:' + Format('%.4x',[regIY]) + #13#10 +
                'IR: ' + Format('%.2x%.2x',[regI,regR]) + '   IM:' + Format('%.2x',[regIM]));
  }

    pcb := Mem[regPC];
    inc(regPC);

    TStart := TStates;

    case pcb of
    0:    dec(TStates,4);      // NOP
    1:    begin                // LD BC,nn
            SetBC(NextPCW());
            dec(TStates,10);
          end;
    2:    begin                // LD (BC),A
            Mem[(regB shl 8) or regC] := regA;
            dec(TStates,7);
          end;
    3:    begin                // INC BC
            setBC(((regB shl 8) or regC) + 1);
            dec(TStates,6);
          end;
    4:    begin                // INC B
            regB := inc8(regB);
            dec(TStates,4);
          end;
    5:    begin                // DEC B
            regB := dec8(regB);
            dec(TStates,4);
          end;
    6:    begin                // LD B,n
            regB := Mem[regPC];
            inc(regPC);
            dec(TStates,7);
          end;
    7:    begin                // RLCA
            regF := (regF and FLAG_S) or
                    (regF and FLAG_Z) or
                    (regF and FLAG_PV);

            if (regA and $80) <> 0 then
              regF := regF or FLAG_C;

            regA := ((regA * 2) or (regF and FLAG_C));

            regF := regF or
                    (regA and FLAG_3) or
                    (regA and FLAG_5);

            // H and N are reset
            dec(TStates,4);
          end;
    8:    begin                // EX AF,AF'
            wTemp := ((regA * 256) or regF);
            regA := regAF_ shr 8;
            regF := regAF_ and $FF;
            regAF_ := wTemp;
            dec(TStates,4)
          end;
    9:    begin                // ADD HL,BC
            regHL := add16(regHL, (regB shl 8) or regC);
            dec(TStates,11);
          end;
    10:   begin                // LD A,(BC)
            regA := Mem[(regB shl 8) Or regC];
            dec(TStates,7);
          end;
    11:   begin                // DEC BC
            wTemp := ((regB shl 8) or regC);
            dec(wTemp);
            regB := (wTemp and $FF00) shr 8;
            regC := (wTemp and $FF);
            dec(TStates,6)
          end;
    12:   begin                // INC C
            regC := inc8(regC);
            dec(TStates,4);
          end;
    13:   begin                // DEC C
            regC := dec8(regC);
            dec(TStates,4);
          end;
    14:   begin                // LD C,n
            regC := Mem[regPC];
            inc(regPC);
            dec(TStates,7);
          end;
    15:   begin                // RRC A
            rrc_a();
            dec(TStates,4)
          end;
    16:   begin                // DJNZ dis
            dec(regB);

            if (regB <> 0) then
            begin
              d := Mem[regPC];
              inc(regPC);
              regPC := (regPC + d);
              dec(TStates,13)
            end
            else begin
              inc(regPC);
              dec(TStates,8)
            end;
          end;
    17:   begin                // LD DE,nn
            regDE := NextPCW();
            dec(TStates,10);
          end;
    18:   begin               // LD (DE),A
            pokeb(regDE, regA);
            dec(TStates,7);
          end;
    19:   begin               // INC DE
            inc(regDE);
            dec(TStates,6)
          end;
    20:   begin                // INC D
            setD( inc8((regDE shr 8)));
            dec(TStates,4)
          end;
    21:   begin                // DEC D
            setD( dec8((regDE shr 8)));
            dec(TStates,4)
          end;
    22:   begin                // LD D,n
            setD(Mem[regPC]);
            inc(regPC);
            dec(TStates,7);
          end;
    23:   begin                // RLA
            rl_a();
            dec(TStates,4);
          end;
    24:   begin                // JR dis
            d := Mem[regPC];
            inc(regPC);
            regPC := (regPC + d);
            dec(TStates,12);
          end;
    25:   begin                // ADD HL,DE
            regHL := add16(regHL, regDE);
            dec(TStates,11);
          end;
    26:   begin                // LD A,(DE)
            regA := Mem[regDE];
            dec(TStates,7)
          end;
    27:   begin               // DEC DE
            dec(regDE);
            dec(TStates,6)
          end;
    28:   begin                // INC E
            setE( inc8((regDE and $FF)));
            dec(TStates,4);
          end;
    29:   begin                // DEC E
            setE( dec8((regDE and $FF)));
            dec(TStates,4);
          end;
    30:   begin                // LD E,n
            setE(Mem[regPC]);
            inc(regPC);
            dec(TStates,7);
          end;
    31:   begin                // RRA
            rr_a;
            dec(TStates,4);
          end;
    32:   begin                // JR NZ,dis
            if (regF and FLAG_Z) = 0 then
            begin
               d := Mem[regPC];
               inc(regPC);
               regPC := (regPC + d);
               dec(TStates,12);
            end
            else
            begin
              inc(regPC);
              dec(TStates,7);
            end;
          end;
    33:   begin                // LD HL,nn
            regHL := NextPCW();
            dec(TStates,10);
          end;
    34:   begin                // LD (nn),HL
            pokew(NextPCW(), regHL);
            dec(TStates,16);
          end;
    35:   begin                // INC HL
            inc(regHL);
            dec(TStates,6)
          end;
    37:   begin                // DEC H
            regHL := (regHL and $FF) or (dec8(regHL shr 8) shl 8);
            dec(TStates,4);
          end;
    38:   begin                // LD H,n
            regHL := (Mem[regPC] * 256) or (regHL and $FF);
            inc(regPC);
            dec(TStates,7);
          end;
    40:   begin                // JR Z,dis
            if (regF and FLAG_Z) <> 0 then
            begin
              d := Mem[regPC];
              inc(regPC);
              regPC := (regPC + d);
              dec(TStates,12);
            end
            else begin
              inc(regPC);
              dec(TStates,7)
            end;
          end;
    41:   begin                // ADD HL,HL
            regHL := add16(regHL, regHL);
            dec(TStates,11);
          end;
    42:   begin                // LD HL,(nn)
            regHL := peekw(NextPCW());
            dec(TStates,16);
          end;
    43:   begin                // DEC HL
            dec(regHL);
            dec(TStates,6);
          end;
    45:   begin                // DEC L
            regHL := (regHL and $FF00) or dec8(regHL and $FF);
            dec(TStates,4);
          end;
    46:   begin                // LD L,n
            regHL := (regHL and $FF00) or Mem[regPC];
            inc(regPC);
            dec(TStates,7);
          end;
    47:   begin                // CPL
            regA := (regA xor $FF);
            regF := (regF and (FLAG_S or FLAG_Z or FLAG_C or FLAG_PV))or
                    (regA and FLAG_3) or
                    (regA and FLAG_5) or
                    FLAG_H or FLAG_N;
            dec(TStates,4);
          end;
    48:   begin                // JR NC,dis
            if (regF and FLAG_C) = 0 then
            begin
               d := Mem[regPC];
               inc(regPC);
               regPC := (regPC + d);
               dec(TStates,12);
            end
            else
            begin
              inc(regPC);
              dec(TStates,7);
            end;
          end;
    49:   begin                // LD SP,nn
            regSP := NextPCW();
            dec(TStates,10);
          end;
    50:   begin                // LD (nn),A
            pokeb(NextPCW(), regA);
            dec(TStates,13);
          end;
    52:   begin                // INC (HL)
            Mem[regHL] := inc8(Mem[regHL]);
            dec(TStates,11)
          end;
    53:   begin                // DEC (HL)
            Mem[regHL] := dec8(Mem[regHL]);
            dec(TStates,11)
          end;
    54:   begin                // LD (HL),n
            pokeb(regHL, Mem[regPC]);
            inc(regPC);
            dec(TStates,10)
          end;
    55:   begin                // SCF
            scf();
            dec(TStates,4);
          end;
    56:   begin                // JR C,dis
            if (regF and FLAG_C) = FLAG_C then
            begin
              d := Mem[regPC];
              inc(regPC);
              regPC := (regPC + d);
              dec(TStates,12)
            end
            else
            begin
              inc(regPC);
              dec(TStates,7)
            end;
          end;
    58:   begin                // LD A,(nn)
            regA := Mem[NextPCW()];
            dec(TStates,13)
          end;
    60:   begin                // INC A
            regA := inc8(regA);
            dec(TStates,4);
          end;
    61:   begin                // DEC A
            regA := dec8(regA);
            dec(TStates,4);
          end;
    62:   begin                // LD A,n
            regA := Mem[regPC];
            inc(regPC);
            dec(TStates,7);
          end;
    63:   begin                // CCF
            regF := (regF and (FLAG_S or FLAG_PV or FLAG_H)) or
                    (regA and FLAG_3) or
                    (regA and FLAG_5);
            if (regF and FLAG_C) <> 0 then regF := regF or FLAG_H;
            if (regF and FLAG_C) = 0 then regF := regF or FLAG_C;
            dec(TStates,4);
          end;
    65:   begin                // LD B,C
            regB := regC;
            dec(TStates,4);
          end;
    66:   begin                // LD B,D
            regB := (regDE shr 8);
            dec(TStates,4);
          end;
    67:   begin                // LD B,E
            regB := regDE and $FF;
            dec(TStates,4);
          end;
    68:   begin                // LD B,H
            regB := regHL shr 8;
            dec(TStates,4);
          end;
    69:   begin                // LD B,L
            regB := regHL and $FF;
            dec(TStates,4);
          end;
    70:   begin                // LD B,(HL)
            regB := Mem[regHL];
            dec(TStates,7);
          end;
    71:   begin                // LD B,A
            regB := regA;
            dec(TStates,4);
          end;
    72:   begin                // LD C,B
            regC := regB;
            dec(TStates,4);
          end;
    73:   begin                // LD C,C
            dec(TStates,4);
          end;
    74:   begin                // LD C,D
            regC := (regDE shr 8);
            dec(TStates,4);
          end;
    75:   begin                // LD C,E
            regC := (regDE and $FF);
            dec(TStates,4);
          end;
    76:   begin                // LD C,H
            regC := (regHL shr 8);
            dec(TStates,4);
          end;
    77:   begin                // LD C,L
            regC := regHL and $FF;
            dec(TStates,4);
          end;
    78:   begin                // LD C,(HL)
            regC := Mem[regHL];
            dec(TStates,7);
          end;
    79:   begin                // LD C,A
            regC := regA;
            dec(TStates,4);
          end;
    80:   begin                // LD D,B
            setD(regB);
            dec(TStates,4);
          end;
    81:   begin                // LD D,C
            setD(regC);
            dec(TStates,4);
          end;
    83:   begin                // LD D,E
            setD(regDE and $FF);
            dec(TStates,4);
          end;
    84:   begin                // LD D,H
            setD(regHL shr 8);
            dec(TStates,4);
          end;
    85:   begin                // LD D,L
            setD(regHL and $FF);
            dec(TStates,4);
          end;
    86:   begin                // LD D,(HL)
            setD(Mem[regHL]);
            dec(TStates,7)
          end;
    87:   begin                // LD D,A
            setD(regA);
            dec(TStates,4);
          end;
    88:   begin                // LD E,B
            regDE := (regDE and $FF00) or (regB);
            dec(TStates,4);
          end;
    89:   begin                // LD E,C
            regDE := (regDE and $FF00) or (regC);
            dec(TStates,4);
          end;
    90:   begin                // LD E,D
            regDE := (regDE and $FF00) or (regDE shr 8);
            dec(TStates,4);
          end;
    93:   begin                // LD E,L
            regDE := (regDE and $FF00) or (regHL and $FF);
            dec(TStates,4);
          end;
    94:   begin                // LD E,(HL)
            setE(Mem[regHL]);
            dec(TStates,7);
          end;
    95:   begin                // LD E,A
            setE(regA);
            dec(TStates,4)
          end;
    96:   begin                // LD H,B
            regHL := (regHL or $FF) or (regB shl 8);
            dec(TStates,4);
          end;
    97:   begin                // LD H,C
            regHL := (regHL or $FF) or (regC shl 8);
            dec(TStates,4);
          end;
    98:   begin                // LD H,D
            regHL := (regDE and $FF00) or (regHL and $FF);
            dec(TStates,4);
          end;
    100:  begin                // LD H,H
            dec(TStates,4);
          end;
    101:  begin                // LD H,L
            regHL := (regHL and $FF) or (regHL shl 8);
            dec(TStates,4);
          end;
    102:  begin                // LD H,(HL)
            regHL := (Mem[regHL] * 256) or (regHL and $FF);
            dec(TStates,7);
          end;
    103:   begin                // LD H,A
            regHL := (regA shl 8) or (regHL and $FF);
            dec(TStates,4);
          end;
    104:  begin                 // LD L,B
            regHL := (regHL and $FF00) or regB;
            dec(TStates,4);
          end;
    105:  begin                 // LD L,C
            regHL := (regHL and $FF00) or regC;
            dec(TStates,4);
          end;
    106:  begin                // LD L,D
            regHL := (regDE shr 8) or (regHL and $FF00);
            dec(TStates,4);
          end;
    107:  begin                // LD L,E
            regHL := (regDE and $FF) or (regHL and $FF00);
            dec(TStates,4);
          end;
    108:  begin                // LD L,H
            regHL := (regHL and $FF00) or (regHL shr 8);
            dec(TStates,4);
          end;
    110:  begin                // LD L,(HL)
            regHL := (regHL and $FF00) or (Mem[regHL]);
            dec(TStates,7);
          end;
    111:  begin                // LD L,A
            regHL := (regHL and $FF00) or regA;
            dec(TStates,4);
          end;
    112:  begin                // LD  (HL),B
            pokeb(regHL, regB);
            dec(TStates,7);
          end;
    113:  begin                // LD  (HL),C
            pokeb(regHL, regC);
            dec(TStates,7);
          end;
    114:  begin                // LD (HL),D
            Mem[regHL] := regDE shr 8;
            dec(TStates,7);
          end;
    115:  begin                // LD (HL),E
            Mem[regHL] := regDE and $FF;
            dec(TStates,7);
          end;
    118:  begin                // HALT
            dec(TStates,4);
            if (TStates > 0) then dec(regPC);  // Keep executing HALT until interrupt
          end;
    119:  begin                // LD (HL),A
            mem[regHL] := regA;
            dec(TStates,7);
          end;
    120:  begin                // LD A,B
            regA := regB;
            dec(TStates,4)
          end;
    121:  begin                // LD A,C
            regA := regC;
            dec(TStates,4);
          end;
    122:  begin                // LD A,D
            regA := regDE shr 8;
            dec(TStates,4);
          end;
    123:  begin                // LD A,E
            regA := regDE and $FF;
            dec(TStates,4)
          end;
    124:  begin                // LD A,H
            regA := regHL shr 8;
            dec(TStates,4);
          end;
    125:  begin                // LD A,L
            regA := regHL and $FF;
            dec(TStates,4);
          end;
    126:  begin                // LD A,(HL)
            regA := Mem[regHL];
            dec(TStates,7);
          end;
    127:  begin                // LD A,A
            dec(TStates,4);
          end;
    128:  begin                // ADD A,B
            add_a(regB);
            dec(TStates,4)
          end;
    129:  begin                // ADD A,C
            add_a(regC);
            dec(TStates,4)
          end;
    130:  begin                // ADD A,D
            add_a(regDE shr 8);
            dec(TStates,4)
          end;
    131:  begin                // ADD A,E
            add_a(regDE and $FF);
            dec(TStates,4)
          end;
    132:  begin                // ADD A,H
            add_a(regHL shr 8);
            dec(TStates,4)
          end;
    133:  begin                // ADD A,L
            add_a(regHL and $FF);
            dec(TStates,4);
          end;
    134:  begin                // ADD A,(HL)
            add_a(Mem[regHL]);
            dec(TStates,7)
          end;
    135:  begin                // ADD A,A
            add_a(regA);
            dec(TStates,4)
          end;
    137:  begin                // ADC A,C
            adc_a(regC);
            dec(TStates,4);
          end;
    138:  begin                // ADC A,D
            adc_a(regDE shr 8);
            dec(TStates,4);
          end;
    139:  begin                // ADC A,E
            adc_a(regDE and $FF);
            dec(TStates,4);
          end;
    140:  begin                // ADC A,H
            adc_a(regHL shr 8);
            dec(TStates,4);
          end;
    141:  begin                // ADC A,L
            adc_a(regHL and $FF);
            dec(TStates,4);
          end;
    142:  begin                // ADC A,(HL)
            adc_a(Mem[regHL]);
            dec(TStates,7);
          end;
    144:  begin                // SUB B
            sub_a(regB);
            dec(TStates,4);
          end;
    145:  begin                // SUB C
            sub_a(regC);
            dec(TStates,4);
          end;
    149:  begin                // SUB L
            sub_a(regHL and $FF);
            dec(TStates,4);
          end;
    151:  begin                // SUB A
            sub_a(regA);
            dec(TStates,4);
          end;
    159:  begin                // SBC A,A
            sbc_a(regA);
            dec(TStates,4);
          end;
    161:  begin                // AND C
            and_a(regC);
            dec(TStates,4);
          end;
    162:  begin                // AND D
            and_a(regDE shr 8);
            dec(TStates,4);
          end;
    163:  begin                // AND E
            and_a(regDE and $FF);
            dec(TStates,4);
          end;
    164:  begin                // AND H
            and_a(regHL shr 8);
            dec(TStates,4);
          end;
    165:  begin                // AND L
            and_a(regHL and $FF);
            dec(TStates,4);
          end;
    166:  begin                // AND (HL)
            and_a(Mem[regHL]);
            dec(TStates,7);
          end;
    167:  begin                // AND A
            and_a(regA);
            dec(TStates,4)
          end;
    168:  begin               // XOR B
            xor_a(regB);
            dec(TStates,4)
          end;
    169:  begin               // XOR C
            xor_a(regC);
            dec(TStates,4)
          end;
    170:  begin                // XOR D
            xor_a(regDE shr 8);
            dec(TStates,4);
          end;
    171:  begin                // XOR E
            xor_a(regDE and $FF);
            dec(TStates,4);
          end;
    172:  begin               // XOR H
            xor_a(regHL shr 8);
            dec(TStates,4);
          end;
    173:  begin               // XOR L
            xor_a(regHL And $FF);
            dec(TStates,4);
          end;
    174:  begin               // XOR (HL)
            xor_a(Mem[regHL]);
            dec(TStates,7);
          end;
    175:  begin                // XOR A
            regA := 0;
            regF := FLAG_PV or FLAG_Z;
            dec(TStates,4)
          end;
    177:  begin                // OR C
            or_a(regC);
            dec(TStates,4)
          end;
    178:  begin                // OR D
            or_a(regDE shr 8);
            dec(TStates,4)
          end;
    179:  begin                // OR E
            or_a(regDE and $FF);
            dec(TStates,4)
          end;
    180:  begin                // OR H
            or_a(regHL shr 8);
            dec(TStates,4);
          end;
    181:  begin                // OR L
            or_a(regHL and $FF);
            dec(TStates,4);
          end;
    182:  begin                // OR (HL)
            or_a(Mem[regHL]);
            dec(TStates,7)
          end;
    183:  begin                // OR A
            or_a(regA);
            dec(TStates,4);
          end;
    184:  begin                // CP B
            cp_a(regB);
            dec(TStates,4);
          end;
    185:  begin                // CP C
            cp_a(regC);
            dec(TStates,4);
          end;
    186:  begin                // CP D
            cp_a(regDE shr 8);
            dec(TStates,4);
          end;
    187:  begin                // CP E
            cp_a(regDE and $FF);
            dec(TStates,4);
          end;
    188:  begin                // CP H
            cp_a(regHL shr 8);
            dec(TStates,4);
          end;
    189:  begin                // CP L
            cp_a(regHL and $FF);
            dec(TStates,4);
          end;
    190:  begin                // CP (HL)
            cp_a(Mem[regHL]);
            dec(TStates,7);
          end;
    191:  begin                // CP A
            cp_a(regA);
            dec(TStates,4);
          end;
    192:  begin                // RET NZ
            if (regF and FLAG_Z) = 0 then
            begin
              regPC := popw();
              dec(TStates,11);
            end
            else
              dec(TStates,5);
          end;
    193:  begin                // POP BC
            setBC(popw());
            dec(TStates,10)
          end;
    194:  begin                // JP NZ,nn
            if (regF and FLAG_Z) = 0 then
              regPC := Mem[regPC] + (Mem[regPC + 1] * 256)
            else
              inc(regPC,2);
            dec(TStates, 10);
          end;
    195:  begin                // JP nn
            regPC := Mem[regPC] + (Mem[regPC + 1] * 256);
            dec(TStates, 10);
          end;
    196:  begin                // CALL NZ,nn
            if (regF and FLAG_Z) = 0 then
            begin
              wTemp := NextPCW();
              pushw(regPC);
              regPC := wTemp;
              dec(TStates,17);
            end
            else
            begin
              inc(regPC,2);
              dec(TStates,10);
            end;
          end;
    197:  begin                // PUSH BC
            pushw ((regB * 256) or regC);
            dec(TStates,11);
          end;
    198:  begin                // ADD A,n
            add_a(Mem[regPC]);
            inc(regPC);
            dec(TStates,7);
          end;
    200:  begin                // RET Z
            if (regF and FLAG_Z) <> 0 then
            begin
              regPC := popw();
              dec(TStates,11);
            end
            else
              dec(TStates,5);
          end;
    201:  begin                // RET
            regPC := popw();
            dec(TStates,10);
          end;
    202:  begin               // JP Z,nn
            if (regF and FLAG_Z) <> 0 then
              regPC := Mem[regPC] + (Mem[regPC + 1] * 256)
            else
              inc(regPC,2);
            dec(TStates,10);
          end;
    203:  begin               // prefix CB
            dec(TStates, execute_cb());
          end;
    204:  begin               // CALL Z,nn
            if (regF and FLAG_Z) <> 0 then
            begin
              wTemp := NextPCW();
              pushw(regPC);
              regPC := wTemp;
              dec(TStates,17);
            end
            else
            begin
              inc(regPC,2);
              dec(TStates,10)
            end;
          end;
    205:  begin                // CALL nn
            wTemp := NextPCW();
            pushw(regPC);
            regPC := wTemp;
            dec(TStates,17);
          end;
    206:  begin               // ADC A,n
            adc_a(Mem[regPC]);
            inc(regPC);
            dec(TStates,7);
          end;
    207:  begin                // RST 8
            pushw(regPC);
            regPC := 8;
            dec(TStates,11);
          end;
    208:  begin                // RET NC
            if (regF and FLAG_C) = 0 then
            begin
              regPC := popw();
              dec(TStates,11);
            end
            else
              dec(TStates,5);
          end;
    209:  begin                // POP DE
            regDE := popw();
            dec(TStates,10)
          end;
    210:  begin                // JP NC,nn
            if (regF and FLAG_C) = 0 then
              regPC := Mem[regPC] + (Mem[regPC + 1] * 256)
            else
              inc(regPC,2);
            dec(TStates, 10);
          end;
    211:  begin                // OUT (n),A
            outb(((256 * regA) or Mem[regPC]), regA);
            inc(regPC);
            dec(TStates,11);
          end;
    213:  begin                // PUSH DE
            pushw(regDE);
            dec(TStates,11)
          end;
    214:  begin                // SUB n
            sub_a(Mem[regPC]);
            inc(regPC);
            dec(TStates,7)
          end;
    216:  begin                // RET C
            if (regF and FLAG_C) = FLAG_C then
            begin
              regPC := popw();
              dec(TStates,11);
            end
            else
              dec(TStates,5);
          end;
    217:  begin                // EXX
            exx();
            dec(TStates,4);
          end;
    219:  begin               // IN A,(n)
            // We always read $FF from any port in this mini-emulation
            inc(regPC);  // skip port number
            regA := $FF;
            dec(TStates,11);
          end;
    220:  begin               // CALL C,nn
            if (regF and FLAG_C) = FLAG_C then
            begin
              wTemp := NextPCW();
              pushw(regPC);
              regPC := wTemp;
              dec(TStates,17)
            end
            else
            begin
              inc(regPC,2);
              dec(TStates,10);
            end;
          end;
    221:  begin               // prefix IX ($DD)
            regID := regIX;
            dec(TStates, execute_id());
            regIX := regID;
          end;
    225:  begin               // POP HL
            regHL := popw();
            dec(TStates,10);
          end;
    227:  begin               // EX (SP),HL
            wTemp := regHL;
            regHL := peekw(regSP);
            pokew(regSP, wTemp);
            dec(TStates,19);
          end;
    229:  begin               // PUSH HL
            pushw(regHL);
            dec(TStates,11);
          end;
    230:  begin               // AND n
            and_a(Mem[regPC]);
            inc(regPC);
            dec(TStates,7);
          end;
    231:  begin               // RST 32
            pushw(regPC);
            regPC := 32;
            dec(TStates,11);
          end;
    233:  begin               // JP HL
            regPC := regHL;
            dec(TStates,4);
          end;
    235:  begin               // EX DE,HL
            wTemp := regHL;
            regHL := regDE;
            regDE := wTemp;
            dec(TStates,4)
          end;
    237:  begin               // prefix ED
            dec(TStates, execute_ed());
          end;
    238:  begin               // XOR n
            xor_a(Mem[regPC]);
            inc(regPC);
            dec(TStates,7);
          end;
    239:  begin               // RST 40
            pushw(regPC);
            regPC := 40;
            dec(TStates,11);
          end;
    240:  begin               // RET P
            if (regF and FLAG_S) = 0 then
            begin
              regPC := popw();
              dec(TStates,11);
            end
            else
              dec(TStates,5);
          end;
    241:  begin               // POP AF
            wTemp := popw();
            regA := wTemp shr 8;
            regF := wTemp and $FF;
            dec(TStates,10);
          end;
    242:  begin               // JP P,nn
            if (regF and FLAG_S) = 0 then
              regPC := NextPCW()
            else
              inc(regPC,2);
            dec(TStates,10);
          end;
    243:  begin                // DI
            bInterruptsEnabled := false;
            dec(TStates,4);
          end;
    244:  begin               // CALL P,nn
            if (regF and FLAG_S) = 0 then
            begin
              wTemp := NextPCW();
              pushw(regPC);
              regPC := wTemp;
              dec(TStates,17)
            end
            else
            begin
              inc(regPC,2);
              dec(TStates,10);
            end;
          end;
    245:  begin               // PUSH AF
            pushw((regA * 256) or regF);
            dec(TStates,11);
          end;
    246:  begin               // OR n
            or_a(Mem[regPC]);
            inc(regPC);
            dec(TStates,7);
          end;
    250:  begin                // JP M,nn
            if (regF and FLAG_S) = FLAG_S then
                regPC := NextPCW()
             else
                inc(regPC,2);

             dec(TStates,10)
          end;
    251:  begin                // EI
            bInterruptsEnabled := true;
            dec(TStates,4);
          end;
    253:  begin               // prefix IY ($FD)
            regID := regIY;
            dec(TStates, execute_id());
            regIY := regID;
          end;
    254:  begin                // CP n
            cp_a(Mem[regPC]);
            inc(regPC);
            dec(TStates,7)
          end;
    else  begin
            DisplayEmuError('Unhandled instruction: $',pcb,regPC-1);
          end;
    end;

    AddWaveOutBuffer(cBeeperVal,TStart - TStates);
  until bUntilInterrupt = false;
end;

function TSpecEmu.in_bc(): Word;
var
  ans: Word;
begin
  ans := $FF;
  regF := (FLAG_S and ans) or (FLAG_3 and ans) or (FLAG_5 and ans) or Parity[ans];
  Result := ans;
end;

function TSpecEmu.Interrupt(): Word;
var
  iSleep,iTimer,iPoorTimer: int64;
begin
  Result := 0; // No interrupt

  // Execute a maskable interrupt
  if bInterruptsEnabled then
  begin
    case regIM of
    0,1: begin
           pushw(regPC);
           bInterruptsEnabled := false;
           regPC := 56;
           Result := 13;
         end;
    2:   begin
           pushw(regPC);
           bInterruptsEnabled := false;
           regPC := peekw((regI * 256) or $FF);
           Result := 19;
         end;
    end;
  end;

  // If we're not writing to a WAV File, then output the wave audio and throttle the emulation
  if not bOutputWavFile then
  begin
    // Waveout
    OutputWave();
    QueryPerformanceCounter(iTimer);

    iPoorTimer := timeGetTime();
    iSleep := iPoorTimer - iLastIntTime;
    if iSleep < 19 then
      Sleep(19 - iSleep);

    // Sleep delay
    while (((iTimer - iLast5IntTime) / iPerfFreq)  < 0.02) do
    begin
      QueryPerformanceCounter(iTimer);
    end;

    QueryPerformanceCounter(iLast5IntTime);
    iLastIntTime := timeGetTime();
  end
  else
    OutputWaveFile();


end;

function TSpecEmu.LoadImage(sResName: string): integer;
var
  Stream: TResourceStream;
begin
  Stream := TResourceStream.Create(hInstance, sResName, 'BINARY');
  if Stream.Size <> 65536 then
  begin
    Result := -2; // INAVLID IMAGE SIZE
    FreeAndNil(Stream);
    exit;
  end;
  Stream.Read(Mem[0],65536);
  FreeAndNil(Stream);
  Result := 0;
end;

procedure TSpecEmu.SetBC(nn: Word);
begin
  regB := nn shr 8;
  regC := nn and $FF;
end;

function TSpecEmu.NextPCW(): Word;
begin
  Result := Mem[regPC] or (Mem[regPC + 1] * 256);
  inc(regPC,2);
end;

procedure TSpecEmu.exx();
var
  t: Word;
begin
    t := regHL;
    regHL := regHL_;
    regHL_ := t;

    t := regDE;
    regDE := regDE_;
    regDE_ := t;

    t := ((regB * 256) or regC);
    setBC(regBC_);
    regBC_ := t;
end;

procedure TSpecEmu.or_a(b: byte);
begin
  regA := (regA or b);

  regF := (regA and (FLAG_S or FLAG_3 or FLAG_5)) or
          (Parity[regA]);
  if regA = 0 then regF := regF or FLAG_Z;
end;

procedure TSpecEmu.xor_a(b: byte);
begin
  regA := (regA xor b);

  regF := (regA and (FLAG_S or FLAG_3 or FLAG_5)) or
          (Parity[regA]);
  if regA = 0 then regF := regF or FLAG_Z;
end;

procedure TSpecEmu.add_a(b: byte);
var
  ans: byte;
begin
  ans := (regA + b);

  regF := (ans and (FLAG_S and FLAG_3 and FLAG_5)) or
          (((regA and $F) + (b and $F)) and FLAG_H);
  if (ans = 0) then regF := regF or FLAG_Z;
  if ((regA + b) and $100) = $100 then regF := regF or FLAG_C;
  // FIXME: Is this P/V flag behaviour correct???
  if ((regA xor ((not (b)) and $FFFF)) and (regA xor ans) and $80) <> 0 then
    regF := regF or FLAG_PV;
  // FLAG_N is reset

  regA := ans;
end;

procedure TSpecEmu.adc_a(b: byte);
var
  ans, c: byte;
begin
  if (regF and FLAG_C) = FLAG_C then
    c := 1
  else
    c := 0;

  ans := (regA + b + c);

  regF := (ans and (FLAG_S or FLAG_3 or FLAG_5)) or
          (((regA and $F) + (b and $F) + c) and FLAG_H);
  if (ans = 0) then regF := regF or FLAG_Z;
  if ((regA + b + c) and $100) = $100 then regF := regF or FLAG_C;
  // FIXME: Is this P/V flag behaviour correct???
  if ((regA xor ((not (b)) and $FFFF)) and (regA xor ans) and $80) <> 0 then
    regF := regF or FLAG_PV;
  // FLAG_N is reset

  regA := ans;
end;

procedure TSpecEmu.sub_a(b: byte);
var
  ans: byte;
begin
  ans := (regA - b);

  regF := (ans and (FLAG_S or FLAG_3 or FLAG_5)) or
          (((regA and $F) - (b and $F)) and FLAG_H) or FLAG_N;
  if (ans = 0) then regF := regF or FLAG_Z;
  if (regA < b) then regF := regF or FLAG_C;

  if ((regA xor b) and (regA xor ans) and $80) <> 0 then
    regF := regF or FLAG_PV;

  regA := ans;
end;

procedure TSpecEmu.sbc_a(b: byte);
var
  ans,c: byte;
begin
  if (regF and FLAG_C) <> 0 then
    c := 1
  else
    c := 0;

  ans := (regA - b - c);

  regF := (ans and (FLAG_S or FLAG_3 or FLAG_5)) or
          (((regA and $F) - (b and $F) - c) and FLAG_H) or FLAG_N;
  if (ans = 0) then regF := regF or FLAG_Z;
  if ((regA - b - c) and $100) <> $0 then regF := regF or FLAG_C;

  if ((regA xor b) and (regA xor ans) and $80) <> 0 then
    regF := regF or FLAG_PV;

  regA := ans;
end;

function TSpecEmu.add16(a,b: Word): Word;
var
  ans: Word;
begin
  ans := (a + b);

  regF := (regF and (FLAG_S or FLAG_Z or FLAG_PV)) or
          ((ans shr 8) and FLAG_3) or
          ((ans shr 8) and FLAG_5);

  if ((a + b) and $10000) <> 0 then
    regF := regF or FLAG_C;
  if (((a and $FFF) + (b and $FFF)) and $1000) <> 0  then
    regF := regF or FLAG_H;
  // FLAG_N is false as a result of this add operation

  Result := ans;
end;

function TSpecEmu.adc16(a,b: Word): Word;
var
  ans,c: Word;
begin
  if (regF and FLAG_C) <> 0 then c := 1 else c := 0;

  ans := (a + b + c);

  regF := ((ans shr 8) and (FLAG_S or FLAG_3 or FLAG_5));
  if (((a and $FFF) + (b and $FFF) + c) and $1000) <> 0 then regF := regF and FLAG_H;
  if (ans = 0) then regF := regF or FLAG_Z;
  if ((a + b + c) And $10000) <> 0 then regF := regF or FLAG_C;


  if ((a xor ((not b) and $FFFF)) and (a xor ans) And $8000) <> 0 then
    regF := regF or FLAG_PV;

  Result := ans;
end;

procedure TSpecEmu.and_a(b: byte);
begin
  regA := (regA and b);

  regF := (regA and FLAG_S) or
          (regA and FLAG_3) or
          (regA and FLAG_5) or
          (Parity[regA]) or
          FLAG_H;
  if regA = 0 then regF := regF or FLAG_Z;
end;

procedure TSpecEmu.cp_a(b: byte);
var
  ans: byte;
begin
    ans := (regA - b);

    regF := (ans and FLAG_S) or
            (b and FLAG_3) or
            (b and FLAG_5) or
            FLAG_N or
            (((regA And $F) - (b And $F)) and FLAG_H);

    if (ans = 0) then regF := regF or FLAG_Z;
    if ((regA xor b) and (regA xor ans) and $80) <> 0 then
      regF := regF or FLAG_PV;
    if ((regA - b) and $100 = $100) then
      regF := regF or FLAG_C;
end;

procedure TSpecEmu.scf();
begin
  regF := (regF and (FLAG_S or FLAG_Z or FLAG_PV)) or
          (FLAG_3 and regA) or
          (FLAG_5 and regA) or
          FLAG_C;

  // FLAG_N and FLAG_H are reset by SCF
end;

function TSpecEmu.rlc(b: byte): byte;
begin
  regF := (b and $80) shr 7;    // Set the carry flag if necessary;

  Result := ((b shl 1) or (regF and FLAG_C));

  regF := regF or (Result and (FLAG_S or FLAG_3 or FLAG_5))
          or Parity[Result]; // S,3,5 and P from result, H and N are false

  if Result = 0 then regF := regF or FLAG_Z;
end;

function TSpecEmu.rrc(b: byte): byte;
begin
  regF := (b and $1);    // Set the carry flag if necessary;

  Result := ((b shr 1) or ((regF and FLAG_C) shl 7));

  regF := regF or (Result and (FLAG_S or FLAG_3 or FLAG_5))
          or Parity[Result]; // S,3,5 and P from result, H and N are false

  if Result = 0 then regF := regF or FLAG_Z;
end;

procedure TSpecEmu.rrc_a();
var
  c: byte;
begin
  c := regA and FLAG_C;

  regA := (regA shr 1) or (c shl 7);

  regF := (regF and (FLAG_S or FLAG_Z or FLAG_PV)) or
          (regA and FLAG_3) or
          (regA and FLAG_5) or
          c;
end;

procedure TSpecEmu.rl_a();
var
  ans: byte;
begin
  ans := (regA shl 1) or (regF and FLAG_C);

  regF := (regF and (FLAG_Z or FLAG_S or FLAG_PV)) or // preserve Z,S and PV
          (ans and (FLAG_3 or FLAG_5)); // copy bits 3 and 5 from A
  if (regA and $80) = $80 then
    regF := regF or FLAG_C;

  // N and H are reset
  regA := ans;
end;

function TSpecEmu.rl(ans: byte): byte;
var
  c: byte;
begin
  if (ans and $80) <> 0 then c := FLAG_C else c := 0;

  Result := (ans shl 1) or (regF and FLAG_C);

  regF := (Result and (FLAG_S or FLAG_3 or FLAG_5)) or
          (Parity[Result]) or
          c;

  if (Result = 0) then regF := regF or FLAG_Z;

  // N and H are reset
end;


procedure TSpecEmu.rr_a();
var
  c: byte;
begin
  c := (regA And $1);

  regA := (regA shr 1) or ($80 * (regF and FLAG_C));

  regF := (regF and (FLAG_S or FLAG_PV or FLAG_Z)) or
          (regA and FLAG_3) or
          (regA and FLAG_5) or
          (c);
end;

function TSpecEmu.rr(ans: byte): byte;
var
  c: byte;
begin
  c := (ans and $01);

  Result := (ans shr 1) or ($80 * (regF and FLAG_C));

  regF := (Result and (FLAG_S or FLAG_3 or FLAG_5)) or
          Parity[Result] or
          (c);
  if Result = 0 then regF := regF or FLAG_Z;

end;

procedure TSpecEmu.pushw(w: Word);
begin
  dec(regSP,2);
  pokew(regSP, w);
end;

procedure TSpecEmu.ResetWaveBuffers;
var
  i: integer;
begin
  for i := 0 to Length(cWaveBuf) - 1 do
    cWaveBuf[i] := 128;

  iIntCycle := 0;
  iWavePtr := 0;
end;

function TSpecEmu.popw(): Word;
begin
  Result := Mem[regSP] or (Mem[regSP + 1] * 256);
  inc(regSP,2);
end;

procedure TSpecEmu.pokew(addr: Word; w: Word);
begin
  pokeb(addr, w and $FF);
  pokeb(addr + 1, w shr 8);
end;

function TSpecEmu.peekw(addr: Word): Word;
begin
  Result := (Mem[addr+1] shl 8) or Mem[addr];
end;

procedure TSpecEmu.pokeb(addr: Word; b: byte);
begin
  if addr < 16384 then exit; // ROM
  Mem[addr] := b;
end;

procedure TSpecEmu.SetD(b: byte);
begin
  regDE := (b * 256) or (regDE and $FF);
end;

procedure TSpecEmu.SetE(b: byte);
begin
  regDE := (regDE and $FF00) or b;
end;

procedure TSpecEmu.SetEngine(const Value: TEngine);
begin
  FEngine := Value;

  if FEngine = SFX then
  begin
    LoadImage('sfx_img');
    iPatternTickAddr[0] := 33370;
    iPatternTickAddr[1] := 0;
    iPatternTickAddr[2] := 0;
    iNewPatternAddr[0]  := 33136;
    iNewPatternAddr[1]  := 0;
    iNewPatternAddr[2]  := 0;
  end
  else if FEngine = TMB then
  begin
    LoadImage('tmb_img');
    iPatternTickAddr[0] := 32972;
    iPatternTickAddr[1] := 32942;
    iPatternTickAddr[2] := 32924;
    iNewPatternAddr[0]  := 32800;
    iNewPatternAddr[1]  := 32773;
    iNewPatternAddr[2]  := 0;
  end
  else if FEngine = MSD then
  begin
    LoadImage('msd_img');
    iPatternTickAddr[0] := 32968;
    iPatternTickAddr[1] := 0;
    iPatternTickAddr[2] := 0;
    iNewPatternAddr[0]  := 32805;
    iNewPatternAddr[1]  := 32783;
    iNewPatternAddr[2]  := 0;
  end
  else if FEngine = P1D then
  begin
    LoadImage('p1d_img');
    iPatternTickAddr[0] := 33110;
    iPatternTickAddr[1] := 33313;
    iPatternTickAddr[2] := 0;
    iNewPatternAddr[0]  := 32836;
    iNewPatternAddr[1]  := 32838;
    iNewPatternAddr[2]  := 0;
  end
  else if FEngine = P1S then
  begin
    LoadImage('p1s_img');
    iPatternTickAddr[0] := 33110;
    iPatternTickAddr[1] := 33313;
    iPatternTickAddr[2] := 0;
    iNewPatternAddr[0]  := 32836;
    iNewPatternAddr[1]  := 32838;
    iNewPatternAddr[2]  := 0;
  end
  else if FEngine = SVG then
  begin
    LoadImage('svg_img');
    iPatternTickAddr[0] := 33297;
    iPatternTickAddr[1] := 0;
    iPatternTickAddr[2] := 0;
    iNewPatternAddr[0]  := 33064;
    iNewPatternAddr[1]  := 0;
    iNewPatternAddr[2]  := 0;
  end
  else if FEngine = ABOUT then
  begin
    LoadImage('abt_img');
    iPatternTickAddr[0] := 33110;
    iPatternTickAddr[1] := 33313;
    iPatternTickAddr[2] := 0;
    iNewPatternAddr[0]  := 32836;
    iNewPatternAddr[1]  := 32838;
    iNewPatternAddr[2]  := 0;
  end
  else if FEngine = RMB then
  begin
    LoadImage('rmb_img');
    regI := $3f;
    regHL_ := $5CD8;
    regA := 0;
    regF := $5C;
    regB := $17; regC := 21;
    regDE := $5CB9;
    regHL := $5CB6;
    regIX := $03D4;
    regIY := $5C3A;
    regIM := 1;
    regHL_ := 0;
    iPatternTickAddr[0] := 32882;
    iPatternTickAddr[1] := 0;
    iPatternTickAddr[2] := 0;
    iNewPatternAddr[0]  := 32814;
    iNewPatternAddr[1]  := 0;
    iNewPatternAddr[2]  := 0;
  end;
end;

procedure TSpecEmu.SetVolume(const Value: integer);
begin
  if (Value >= 0) and (Value <= 100) then
    FVolume := Value;
end;

procedure TSpecEmu.SetWavOutFile(const Value: string);
var
  i: Cardinal;
  w: word;
begin
  FreeAndNil(FWav);
  FWavOutFile := Value;

  if Value = '' then
    bOutputWavFile := false
  else
  begin
    bOutputWavFile := true;
    try
      FWav := TFileStream.Create(FWavOutFile,fmCreate or fmShareDenyWrite);
      FWav.Write('RIFFxxxxWAVEfmt ',16);
      i := $10;
      FWav.Write(i,4); // fmt chunk = 16 bytes
      w := 1;
      FWav.Write(w,2); // Always       $0001, 2 bytes
      FWav.Write(w,2); // Chans        $0001, 2 bytes
      i := 44100;
      FWav.Write(i,4); // FreqHz       44100, 4 bytes
      FWav.Write(i,4); // Bytes/Second 44100, 4 bytes
      FWav.Write(w,2); // Bytes/Sample $0001, 2 bytes
      w := 8;
      FWav.Write(w,2); // Bits/Sample  $0008, 2 bytes
      FWav.Write('dataxxxx',8);
      iWavDataLen := 0;
    except
      bOutputWavFile := false;
      FWavOutFile := '';
    end;
  end;


end;

function TSpecEmu.inc8(b: byte): byte;
begin
  regF := regF and FLAG_C;  // preserve the carry flag
  if (b = $7F) then regF := regF or FLAG_PV;
  regF := regF or ( ((b and $F) +1) and FLAG_H);
  Result := b + 1;

  regF := regF or (Result and FLAG_S) or
                  (Result and FLAG_3) or
                  (Result and FLAG_5);

  if (Result = 0) then regF := regF or FLAG_Z;
end;

function TSpecEmu.dec8(b: byte): byte;
begin
  regF := regF and FLAG_C;  // preserve the carry flag
  if (b = $80) then regF := regF or FLAG_PV;
  regF := regF or ( ((b and $F) - 1) and FLAG_H);
  Result := b - 1;

  regF := regF or (Result and FLAG_S) or
                  (Result and FLAG_3) or
                  (Result and FLAG_5) or
                  FLAG_N;
  if (Result = 0) then regF := regF or FLAG_Z;
end;

procedure TSpecEmu.neg_a();
var
  t: byte;
begin
    t := regA;
    regA := 0;
    sub_a(t);
end;

function TSpecEmu.execute_ed(): Word;
var
  pcb, b: Byte;
begin
  inc(regRtemp);

  pcb := Mem[regPC];
  inc(regPC);

  case pcb of
  67:   begin              // LD (nn),BC
          pokew(NextPCW(), ((regB shl 8) or regC));
          Result := 20;
        end;
  68:   begin              // NEG
          neg_a();
          Result := 8;
        end;
  71:   begin              // LD I,A
          regI := regA;
          Result := 9;
        end;
  72:   begin              // IN C,(c)
          regC := in_bc();
          Result := 12;
        end;
  74:   begin              // ADC HL,BC
          regHL := adc16(regHL, (regB shl 8) or regC);
          Result := 15;
        end;
  75:   begin              // LD BC,(nn)
          setBC(peekw(NextPCW()));
          Result := 20;
        end;
  77:   begin              // RETI
          regPC := popw();
          Result := 14;
        end;
  82:   begin              // SBC HL,DE
          regHL := sbc16(regHL, regDE);
          Result := 15;
        end;
  83:   begin              // LD (nn),DE
          pokew(NextPCW(), regDE);
          Result := 20;
        end;
  86:   begin              // IM 1
          regIM := 1;
          Result := 8;
        end;
  87:   begin              // LD A,I
          regF := (regF and FLAG_C) or
                  (regI and FLAG_S) or
                  (regI and FLAG_3) or
                  (regI and FLAG_5);
          if bInterruptsEnabled then
            regF := regF or FLAG_PV;
          if regI = 0 then
            regF := regF or FLAG_Z;
          // FLAG_H and FLAG_N are reset
          regA := regI;
          Result := 9;
        end;
  90:   begin              // ADC HL,DE
          regHL := adc16(regHL, regDE);
          Result := 15;
        end;
  91:   begin              // LD DE,(nn)
          regDE := peekw(NextPCW());
          Result := 20;
        end;
  94:   begin              // IM 2
          regIM := 2;
          Result := 8;
        end;
  95:   begin              // LD A,R
          regRtemp := regRtemp and $7F;

          regA := (regR and $80) or regRtemp;
          regF := (regF and FLAG_C) or
                  (regA and FLAG_S) or
                  (regA and FLAG_3) or
                  (regA and FLAG_5);
          if (regA = 0) then regF := regF or FLAG_Z;
          if bInterruptsEnabled then regF := regF or FLAG_PV;
          // H and N are reset
          Result := 9;
        end;
  98:   begin              // SBC HL,HL
          regHL := sbc16(regHL, regHL);
          Result := 15;
        end;
  106:  begin              // ADC HL,HL
          regHL := adc16(regHL, regHL);
          Result := 15;
        end;
  114:  begin              // SBC HL,SP
          regHL := sbc16(regHL, regSP);
          Result := 15;
        end;
  115:  begin              // LD (nn),SP
          pokew(NextPCW(), regSP);
          Result := 20;
        end;
  120:  begin              // IN A,(C)
          regA := $FF;
          result := 12;
        end;
  123:  begin              //  LD SP,(nn)
          regSP := NextPCW();
          regSP := Mem[regSP] + (Mem[regSP+1] shl 8);
          Result := 20;
        end;
  176:  begin              // LDIR
          b := Mem[regHL];
          Mem[regDE] := b;
          inc(regHL);
          inc(regDE);
          SetBC(((regB * 256) or regC) - 1);
          regF := (regF and (FLAG_S or FLAG_Z or FLAG_C or FLAG_PV)) or
                  (b and FLAG_3) or
                  (b and FLAG_5); // H and N are reset
          if ((regB * 256) or regC) <> 0 then
          begin
            dec(regPC,2);
            regF := regF or FLAG_PV; // PV = true
            Result := 21;
          end
          else
          begin
            regF := regF and FLAG_NOT_PV;
            Result := 16;
          end;
        end;
  else  begin
          DisplayEmuError('Unhandled ED instruction: ED ',pcb,regPC-2);
          Result := 0;
        end;
  end;
end;

function TSpecEmu.sbc16(a,b: Word): Word;
var
  c, ans: Word;
begin
  if (regF and FLAG_C) = FLAG_C then
    c := 1
  else
    c := 0;

  ans := a-b-c;

  regF := ((ans shr 8) and FLAG_S) or
          ((ans shr 8) and FLAG_3) or
          ((ans shr 8) and FLAG_5) or
          FLAG_N;
  if ans = 0 then regF := regF or FLAG_Z;
  if ((a-b-c) and $10000) <> 0 then regF := regF or FLAG_C;
  if (((a and $FFF) - (b and $FFF) - c) and $1000) <> 0 then regF := regF or FLAG_H;
  if ((a xor b) and (a xor ans) And $8000) <> 0 then regF := regF or FLAG_PV;

  Result := ans;
end;

procedure TSpecEmu.bit(b,r: byte);
var
  ans, zeroFlag: byte;
begin
    ans := (r And b);
    if ans = 0 then zeroFlag := FLAG_Z or FLAG_PV else zeroFlag := 0;


    // FLAG_N is reset
    regF := (ans and (FLAG_3 or FLAG_5)) or
            FLAG_H or zeroFlag or (regF and FLAG_C);

    if (b = FLAG_S) and (zeroFlag <> 0) then regF := regF or FLAG_S;
end;

function TSpecEmu.bitRes(b, val: byte): byte;
begin
  Result := val and (b xor $FF);
end;

function TSpecEmu.bitSet(b, val: byte): byte;
begin
  Result := val or b;
end;

function TSpecEmu.execute_cb(): Word;
var
  pcb: Byte;
begin
  inc(regRtemp);

  pcb := Mem[regPC];
  inc(regPC);

  case pcb of
  0:   begin                // RLC B
         regB := rlc(regB);
         Result := 8;
       end;
  9:   begin                // RRC C
         regC := rrc(regC);
         Result := 8;
       end;
  16:  begin                // RL B
         regB := rl(regB);
         Result := 8;
       end;
  17:  begin                // RL C
         regC := rl(regC);
         Result := 8;
       end;
  18:  begin                // RL D
         regDE := (rl(regDE shr 8) shl 8) or (regDE and $FF);
         Result := 8;
       end;
  19:  begin                // RL E
         regDE := (regDE and $FF00) or (rl(regDE and $FF));
         Result := 8;
       end;
  20:  begin                // RL H
         regHL := (rl(regHL shr 8) shl 8) or (regHL and $FF);
         Result := 8;
       end;
  21:  begin                // RL L
         regDE := (regHL and $FF00) or (rl(regHL and $FF));
         Result := 8;
       end;
  22:  begin                // RL (HL)
        Mem[regHL] := rl(Mem[regHL]);
        Result := 15;
       end;
  24:  begin                // RR B
         regB := rr(regB);
         Result := 8;
       end;
  25:  begin                // RR C
         regC := rr(regC);
         Result := 8;
       end;
  26:  begin                // RR D
         regDE := (regDE and $FF) or (rr(regDE shr 8) shl 8);
         Result := 8;
       end;
  27:  begin                // RR E
         regDE := (regDE and $FF00) or rr(regDE and $FF);
         Result := 8;
       end;
  28:  begin                // RR H
         regHL := (regHL and $FF) or (rr(regHL shr 8) shl 8);
         Result := 8;
       end;
  29:  begin                // RR L
         regHL := (regHL and $FF00) or rr(regHL and $FF);
         Result := 8;
       end;
  39:  begin                // SLA A
         regA := sla(regA);
         Result := 8;
       end;
  44:  begin                // SRA H
        regHL := (regHL and $FF) or (sra(regHL shr 8) shl 8);
        Result := 8;
       end;
  45:  begin                // SRA L
        regHL := (regHL and $FF00) or sra(regHL and $FF);
        Result := 8;
       end;
  46:  begin                // SRA (HL)
        pokeb(regHL, sra(Mem[regHL]));
        Result := 15;
       end;
  56:  begin                // SRL B
         regB := srl(regB);
         Result := 8;
       end;
  57:  begin                // SRL C
         regC := srl(regC);
         Result := 8;
       end;
  58:  begin                // SRL D
         regDE := (srl(regDE shr 8) shl 8) or (regDE and $FF);
         Result := 8;
       end;
  59:  begin                // SRL E
         regDE := srl(regDE and $FF) or (regDE and $FF00);
         Result := 8;
       end;
  60:  begin                // SRL H
         regHL := (regHL and $FF) or (srl(regHL shr 8) shl 8);
         Result := 8;
       end;
  61:  begin                // SRL L
         regHL := (regHL and $FF00) or srl(regHL and $FF);
         Result := 8;
       end;
  63:  begin                // SRL A
         regA := srl(regA);
         Result := 8;
       end;
  103: begin                // BIT 4,A
        bit($10, regA);
        Result := 8;
       end;
  111: begin                // BIT 5,A
        bit($20, regA);
        Result := 8;
       end;
  120: begin                // BIT 7,B
         bit($80, regB);
         Result := 8;
       end;
  121: begin                // BIT 7,C
        bit($80,regC);
        Result := 8;
       end;
  122: begin                // BIT 7,D
         bit($80, regDE shr 8);
         Result := 8;
       end;
  123: begin                // BIT 7,E
        bit($80,(regDE and $FF));
        Result := 8;
       end;
  124: begin                // BIT 7,H
        bit($80, regHL shr 8);
        Result := 8;
       end;
  125: begin                // BIT 7,L
        bit($80,(regHL and $FF));
        Result := 8;
       end;
  126: begin                // BIT 7,(HL)
         bit($80, Mem[regHL]);
         Result := 12;
       end;
  127: begin                // BIT 7,A
        bit($80, regA);
        Result := 8;
       end;
  166: begin                // RES 4,(HL)
         Mem[regHL] := bitRes($10,Mem[regHL]);
         Result := 15;
       end;
  250: begin                // SET 7,D
        regDE := (regDE and $FF) or (bitSet($80, regDE shr 8) shl 8);
        Result := 8;
       end;
  251: begin                // SET 7,E
        regDE := (regDE and $FF00) or (bitSet($80, regDE and $FF));
        Result := 8;
       end;
  252: begin                // SET 7,H
        regHL := (regHL and $FF) or (bitSet($80, regHL shr 8) shl 8);
        Result := 8;
       end;
  253: begin                // SET 7,L
        regHL := (regHL and $FF00) or (bitSet($80, regHL and $FF));
        Result := 8;
       end;
  254: begin                // SET 7,(HL)
         Mem[regHL] := bitSet($80,Mem[regHL]);
         Result := 15;
       end;
  255: begin                // SET 7,A
         regA := bitSet($80,regA);
         Result := 8;
       end;
  else  begin
          DisplayEmuError('Unhandled CB instruction: CB ',pcb,regPC-2);
          Result := 0;
        end;
  end;
end;


function TSpecEmu.execute_id(): Word;
var
  pcb,op: Byte;
  d: ShortInt; // Signed byte for relative jumps
begin
  inc(regRtemp);

  pcb := Mem[regPC];
  inc(regPC);

  case pcb of
  9:   begin                // ADD ID,BC
         regID := add16(regID, (regB shl 8) or regC);
         Result := 15;
       end;
  25:  begin                // ADD ID,DE
         regID := add16(regID, regDE);
         Result := 15;
       end;
  33:  begin                // LD ID,nn
         regID := NextPCW();
         Result := 14;
       end;
  34:  begin                // LD (nn),ID
         pokew(NextPCW(),regID);
         Result := 20;
       end;
  44:  begin                // INC IDL
         regID := (regID and $FF00) or inc8(regID and $FF);
         Result := 8;
       end;
  45:  begin                // DEC IDL
         regID := (regID and $FF00) or dec8(regID and $FF);
         Result := 8;
       end;
  46:  begin                // LD IDL,n
         regID := (regID and $FF00) or Mem[regPC];
         inc(regPC);
         Result := 11;
       end;
  54:  begin               // LD (ID+d),n
         d := Mem[regPC];
         inc(regPC);
         pokeb(regID+d,Mem[regPC]);
         inc(regPC);
         execute_id := 19;
       end;
  69:  begin                // LD B,IDL
         regB := regID and $FF;
         Result := 8;
       end;
  78:  begin                // LD C,(ID+d)
         d := Mem[regPC];
         inc(regPC);
         regC := Mem[regID+d];
         Result := 19;
       end;
  86:  begin                // LD D,(ID+d)
         d := Mem[regPC];
         inc(regPC);
         regDE := (regDE and $FF) or (Mem[regID+d] shl 8);
         Result := 19;
       end;
  92:  begin                // LD E,IDH
         setE(regID shr 8);
         Result := 8;
       end;
  94:  begin                // LD E,(ID+d)
         d := Mem[regPC];
         inc(regPC);
         regDE := (regDE and $FF00) or Mem[regID+d];
         Result := 19;
       end;
  98:  begin                // LD IDH,D
         regID := (regDE and $FF00) or (regID and $FF);
         Result := 8;
       end;
  102: begin                // LD H,(ID+d)
         d := Mem[regPC];
         inc(regPC);
         regHL := (regHL and $FF) or (Mem[regID+d] shl 8);
         Result := 19;
       end;
  103: begin                // LD IDH,A
         regID := (regA shl 8) or (regID and $FF);
         Result := 8;
       end;
  106: begin                // LD IDL,D
         regID := (regID and $FF00) or (regDE shr 8);
         Result := 9;
       end;
  110: begin                // LD L,(ID+d)
         d := Mem[regPC];
         inc(regPC);
         regHL := (regHL and $FF00) or (Mem[regID+d]);
         Result := 19;
       end;
  111: begin                // LD IDL,A
         regID := (regA) or (regID and $FF00);
         Result := 8;
       end;
  112: begin                // LD (ID+d),B
         d := Mem[regPC];
         inc(regPC);
         pokeb(regID+d,regB);
         Result := 19;
       end;
  113: begin                // LD (ID+d),C
         d := Mem[regPC];
         inc(regPC);
         pokeb(regID+d,regC);
         Result := 19;
       end;
  114: begin                // LD (ID+d),D
         d := Mem[regPC];
         inc(regPC);
         pokeb(regID+d,regDE shr 8);
         Result := 19;
       end;
  115: begin                // LD (ID+d),E
         d := Mem[regPC];
         inc(regPC);
         pokeb(regID+d,regDE and $FF);
         Result := 19;
       end;
  117: begin                // LD (ID+d),L
         d := Mem[regPC];
         inc(regPC);
         pokeb(regID+d,regHL and $FF);
         Result := 19;
       end;
  119: begin                // LD (ID+d),A
         d := Mem[regPC];
         inc(regPC);
         pokeb(regID+d,regA);
         Result := 19;
       end;
  124: begin                // LD A,IDH
         regA := regID shr 8;
         Result := 8;
       end;
  125: begin                // LD A,IDL
         regA := regID and $FF;
         Result := 8;
       end;
  126: begin                // LD A,(ID+d)
         d := Mem[regPC];
         inc(regPC);
         regA := Mem[regID+d];
         Result := 19;
       end;
  134: begin               // ADD A,(ID+d)
         d := Mem[regPC];
         inc(regPC);
         add_a(Mem[regID+d]);
         Result := 19;
       end;
  174: begin               // XOR (ID+d)
         d := Mem[regPC];
         inc(regPC);
         xor_a (Mem[regID+d]);
         Result := 19;
       end;
  188: begin              // CP IDH
         cp_a(regID shr 8);
         Result := 8;
       end;
  189: begin              // CP IDL
         cp_a(regID and $FF);
         Result := 8;
       end;
  190: begin              // CP (ID+d)
         d := Mem[regPC];
         inc(regPC);
         cp_a(Mem[regID+d]);
         execute_id := 19;
       end;
  203: begin
         d := Mem[regPC];
         inc(regPC);

         op := Mem[regPC];
         inc(regPC);
         execute_id_cb(op, regID+d);
         if ((op and $C0) = $40) then Result := 20 else Result := 23;
       end;
  225: begin                // POP ID
        regID := popw();
        Result := 14;
       end;
  229: begin                // PUSH ID
         pushw(regID);
         Result := 15;
       end;
  233: begin                // JP ID  (also sometimes called JP (ID) )
         regPC := regID;
         Result := 8;
       end;
  else  begin
          DisplayEmuError('Unhandled ID instruction: ID ',pcb,regPC-2);
          Result := 0;
        end;
  end;
end;

procedure TSpecEmu.execute_id_cb(op: byte; adr: Word);
begin
  case op of
    88,89,90,91,92,93,94,95: begin           // BIT 3,ID+d
      bit($8,Mem[adr]);
    end;
    96,97,98,99,100,101,102,103: begin      // BIT 4,ID+d
      bit($10,Mem[adr]);
    end;
    104,105,106,107,108,109,110,111: begin   // BIT 5,ID+d
      bit($20,Mem[adr]);
    end;
    112,113,114,115,116,117,118,119: begin   // BIT 6,ID+d
      bit($40,Mem[adr]);
    end;
    120,121,122,123,124,125,126,127: begin   // BIT 7,ID+d
      bit($80,Mem[adr]);
    end;
    174: begin                               // RES 5,(HL)
      Mem[adr] := bitRes($20,Mem[adr]);
    end;
    182: begin                               // RES 6,(HL)
      Mem[adr] := bitRes($40,Mem[adr]);
    end;
    190: begin                               // RES 7,(HL)
      Mem[adr] := bitRes($80,Mem[adr]);
    end;
    222: begin                               // SET 3,(ID + d)
      Mem[adr] := bitSet($08, Mem[adr]);
    end;
  else begin
         DisplayEmuError('Unhandled ID_CB instruction: ID CB ',op,regPC-4);
       end;
  end;
end;

function TSpecEmu.srl(b: Byte): Byte;
begin
  Result := b shr 1;

  regF := (b and FLAG_C) or
          (Result and FLAG_S) or
          (Result and FLAG_3) or
          (Result and FLAG_5) or
          (Parity[Result]);

  if Result = 0 then regF := regF or FLAG_Z;
end;

function TSpecEmu.sra(b: Byte): Byte;
begin
  Result := (b shr 1) or (b and $80);

  regF := (b and FLAG_C) or
          (Result and FLAG_S) or
          (Result and FLAG_3) or
          (Result and FLAG_5) or
          (Parity[Result]);

  if Result = 0 then regF := regF or FLAG_Z;
end;

function TSpecEmu.sla(b: Byte): Byte;
begin
  if (b and $80) = $80 then regF := FLAG_C else regF := 0;

  Result := (b shl 1);

  regF := regF or (Result and FLAG_S) or
          (Result and FLAG_3) or
          (Result and FLAG_5) or
          (Parity[Result]);
  // H and N flags are false
  if Result = 0 then regF := regF or FLAG_Z;
end;

function TSpecEmu.outb(port: Word; b: Byte): Word;
begin
  if (port and 1) = 0 then
  begin
    if (b and 16) = 16 then
    begin
      cBeeperVal := 159;
    end
    else
    begin
      cBeeperVal := 128;
    end;
  end;

  Result := 0; // Is beeper port access contended??? If so return tstates taken
end;

procedure TSpecEmu.AddWaveOutBuffer(cBeeperVal: byte; iTS: integer);
var
  i: integer;
begin
  // WaveBuf wants 44100 samples per second  = 882 per frame
  // we generate 69888 samples per frame
  // this is squished down to 22050 or 44100 in the player routine called by
  // Interrupt().
  for i := 1 to iTS do
  begin
    cWaveBuf[iWavePtr] := cBeeperVal;
    inc(iWavePtr);
  end;
end;

procedure TSpecEmu.OutputWave();
var
  i,j,k: integer;
begin
  // cWaveBuf Length shouuld = 69888 * 5 (349440) - we need to squish this
  // down to 4410 samples (10th of a sec)
//  if iWavePtr < 399999 then
//    ShowMessage(IntToStr(iWavePtr));

  for i := 0 to 881 do
  begin
    k := 0;
    for j := 0 to 78 do
      if cWaveBuf[i*79+j] > 128 then inc(k);
    waveout[i] := 128 + Round(k * FVolume/100);
  end;

  CopyMemory(WavHdr[iBufNum].lpData, @waveout[0],882);
  waveOutWrite(hWaveOut, @WavHdr[iBufNum], SizeOf(WavHdr[iBufNum]));
  iWavePtr := 0;
  inc(iBufNum);
  if iBufNum > 10 then iBufNum := 0;
end;

procedure TSpecEmu.OutputWaveFile();
var
  i,j,k: integer;
begin
  for i := 0 to 881 do
  begin
    k := 128;
    for j := 0 to 78 do
      if cWaveBuf[i*79+j] > 128 then inc(k);
    waveout[i] := k;
  end;

  FWav.Write(waveout,882);
  Inc(iWavDataLen,882);
  iWavePtr := 0;
end;

procedure TSpecEmu.CloseWaveFile();
var
  i: cardinal;
begin
  if FWav = nil then exit;

  FWav.Seek(4,soFromBeginning);
  i := iWavDataLen + 32;
  FWav.Write(i,4);
  FWav.Seek(40,soFromBeginning);
  i := iWavDataLen;
  FWav.Write(i,4);

  FreeAndNil(FWav);
end;

procedure TSpecEmu.InitializeWaveOut();
var
  iRet: integer;
  sErrMsg: string;
  iRef,i: Integer;
begin
  cBeeperVal := 128;

  if hWaveOut = INVALID_HANDLE_VALUE then
  begin
    ShowMessage('WaveOut device is uninitialised.');
  end;

  for i := 0 to 10 do
  begin
    ghMem[i] := GlobalAlloc(GPTR, 882);
    gpMem[i] := GlobalLock(ghMem[i]);

    with WavHdr[i] do
    begin
      lpData := gpMem[i];
      dwBufferLength := 882;
      dwBytesRecorded := 882;
      dwUser := 0;
      dwFlags := 0;
      dwLoops := 0;
      lpNext := nil;
    end;

    iRet := waveOutPrepareHeader(hWaveOut, @WavHdr[i], SizeOf(WavHdr));
    If iRet <> MMSYSERR_NOERROR then
    begin
      sErrMsg := StringOfChar(#0,255);
      waveOutGetErrorText(iRet, PAnsiChar(sErrMsg), Length(sErrMsg));
      sErrMsg := Copy(sErrMsg, 1, Pos(#0,sErrMsg) - 1);
      ShowMessage('Error preparing wave header.'#13#10#13#10 + sErrMsg);
      //waveOutClose(hWaveOut);
      exit;
    end;
  end;
  for iRef := 0 to 350000 do
    cWaveBuf[iRet] := cBeeperVal;
  iBufNum := 0;
end;

procedure TSpecEmu.SaveTop32K(sFileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(sFileName, fmCreate or fmShareDenyWrite);
  F.Write(Mem[32768],32768);
  FreeAndNil(F);
end;

function TSpecEmu.LoadPlayerNote(iCh1,iCh2: byte; iSus1,iSus2: byte; iDrum: byte; iTempo: integer; Song: TSTSong = nil): integer;
var
  Patt: STPatterns.TPattern;
begin
  if FEngine = SFX then
    Patt.Length := 2
  else
    Patt.Length := 1;

  Patt.Tempo := iTempo;
  Patt.Name := 'NotePlay';
  Patt.Chan[1][1] := iCh1;
  Patt.Chan[2][1] := iCh2;
  Patt.Sustain[1][1] := iSus1;
  Patt.Sustain[2][1] := iSus2;
  Patt.Drum[1] := iDrum;
  Patt.Chan[1][2] := 255;
  Patt.Chan[2][2] := 255;
  Patt.Sustain[1][2] := 255;
  Patt.Sustain[2][2] := 255;
  Patt.Drum[2] := 0;

  case FEngine of
    SFX: Result := LoadSFXPattern(Patt);
    TMB: Result := LoadTMBPattern(Patt);
    MSD: Result := LoadMSDPattern(Patt);
    P1D: Result := LoadP1DPattern(Patt, Song);
    P1S: Result := LoadP1SPattern(Patt, Song);
    RMB: Result := LoadRMBPattern(Patt, Song);
    else
      Result := 0;
  end;
end;

function TSpecEmu.SavageLoadPlayerNote(iCh1,iCh2: byte; iGlis1,iGlis2: integer;
                                       iSkew1,iSkew2: integer;
                                       iXor1,iXor2: integer;
                                       iArp1,iArp2: integer;
                                       iPhase1,iPhase2: integer;
                                       iDrum: byte; iTempo: integer; Song: TSTSong = nil): integer;
var
  Patt: STPatterns.TPattern;
  SvgPatt: STPatterns.TPatternSVG;
begin
  Patt.Length := 1;

  Patt.Tempo := iTempo;
  Patt.Name := 'NotePlay';
  Patt.Chan[1][1] := iCh1;
  Patt.Chan[2][1] := iCh2;
  Patt.Drum[1] := iDrum;

  SvgPatt.Glissando[1][1] := iGlis1;
  SvgPatt.Glissando[2][1] := iGlis2;
  SvgPatt.Skew[1][1] := iSkew1;
  SvgPatt.Skew[2][1] := iSkew2;
  SvgPatt.SkewXor[1][1] := iXor1;
  SvgPatt.SkewXor[2][1] := iXor2;
  SvgPatt.Arpeggio[1][1] := iArp1;
  SvgPatt.Arpeggio[2][1] := iArp2;
  SvgPatt.Warp[1][1] := iPhase1;
  SvgPatt.Warp[2][1] := iPhase2;

  Result := LoadSVGPattern(Patt, SvgPatt, Song);
end;

// Loads the pattern into speccy memory (as a single pattern song) and returns just the pattern length
function TSpecEmu.LoadPlayerPattern(Patt: STPatterns.TPattern;  SvgPatt: STPatterns.TPatternSVG; Song: TSTSong = nil): integer;
begin
  case FEngine of
    SFX: Result := LoadSFXPattern(Patt);
    TMB: Result := LoadTMBPattern(Patt);
    MSD: Result := LoadMSDPattern(Patt);
    P1D: Result := LoadP1DPattern(Patt, Song);
    P1S: Result := LoadP1SPattern(Patt, Song);
    SVG: Result := LoadSVGPattern(Patt, SvgPatt, Song);
    RMB: Result := LoadRMBPattern(Patt, Song);    
    else
      Result := 0;
  end;
end;

// Loads the song into speccy memory and returns the total song length, including player
function TSpecEmu.LoadPlayerSong(Song: TSTSong; iStartPos: integer = 0): integer;
begin
  case FEngine of
    SFX: Result := LoadSFXSong(Song,iStartPos);
    TMB: Result := LoadTMBSong(Song,iStartPos);
    MSD: Result := LoadMSDSong(Song,iStartPos);
    P1D: Result := LoadP1DSong(Song,iStartPos);
    P1S: Result := LoadP1SSong(Song,iStartPos);
    SVG: Result := LoadSVGSong(Song,iStartPos);
    RMB: Result := LoadRMBSong(Song,iStartPos);
    else
      Result := 0;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// SpecialFX
//
// Routines to format a song or single pattern data in speccy memory for
// replay by the SFX player routine at $8000
///////////////////////////////////////////////////////////////////////////////
procedure TSpecEmu.SFXAddNoteData(var iMemPtr: integer; iNote,iNoteLen: integer);
begin
  while (iNoteLen > 255) do
  begin
    Mem[iMemPtr] := (iNote and 255);  Mem[iMemPtr+1] := $FF;
    inc(iMemPtr,2);
    Dec(iNoteLen,255);
  end;
  if iNoteLen > 0 then
  begin
    Mem[iMemPtr] := (iNote and 255);  Mem[iMemPtr+1] := iNoteLen and $FF;
    inc(iMemPtr,2);
  end;
end;

function TSpecEmu.LoadSFXPattern(Patt: STPatterns.TPattern): integer;
var
  iMemPtr: integer;
  iPATT_ADDR, iPERC_ADDR: integer;
  iChan, i, iNote, iNoteLen, iOneNote: integer;
begin
  //Mem[$82BC] := $00; Mem[$82BD] := $00; // song repeat marker
  Mem[$82C8] := $00; Mem[$82C9] := $00; // song repeat marker
  Mem[$82CA] := $C6; Mem[$82CB] := $82; // song start location

  iMemPtr := $82CC;
  iPATT_ADDR := iMemPtr;   // Address of pattern start - will hold ptr to chan 2
  inc(iMemPtr,2);

  iOneNote := 21 - Patt.Tempo; // Length of one row in the pattern
  for iChan := 1 to 2 do
  begin
    if iChan = 2 then
    begin
      Mem[iPATT_ADDR] := iMemPtr and $FF;
      Mem[iPATT_ADDR+1] := iMemPtr shr 8;
    end;
    // Channel pattern data
    iNote := $83; // Rest/Mute
    iNoteLen := 0;
    for i := 1 to Patt.Length do
    begin
      if Patt.Chan[iChan][i] = 255 then
        Inc(iNoteLen,iOneNote)
      else
      begin
        if iNoteLen > 0 then
          SFXAddNoteData(iMemPtr,iNote,iNoteLen);

        iNote := Patt.Chan[iChan][i];
        iNoteLen := iOneNote;
      end;
      if Patt.Sustain[iChan][i] <> 255 then
      begin
        Mem[iMemPtr] := $81; Mem[iMemPtr+1] := Patt.Sustain[iChan][i];
        inc(iMemPtr,2)
      end;
    end;
    if iNoteLen > 0 then
      SFXAddNoteData(iMemPtr,iNote,iNoteLen);

    Mem[iMemPtr] := $80; // Channel terminator
    inc(iMemPtr);
  end;

  Mem[$82C6] := iPATT_ADDR and $FF;
  Mem[$82C7] := iPATT_ADDR shr 8;

  iPERC_ADDR := iMemPtr;
  // Add the percussion pattern
  iNote := $85; // Rest/Mute
  iNoteLen := 0;
  for i := 1 to Patt.Length do
  begin
    if (Patt.Drum[i] < $80) or (Patt.Drum[i] > $85) then
      Inc(iNoteLen,iOneNote)
    else
    begin
      if iNoteLen > 0 then
        SFXAddNoteData(iMemPtr,iNote,iNoteLen);
      iNote := Patt.Drum[i];
      iNoteLen := iOneNote;
    end;
  end;
  if iNoteLen > 0 then
    SFXAddNoteData(iMemPtr,iNote,iNoteLen);
  Mem[iMemPtr] := $80; // Terminator
  inc(iMemPtr);

  // Set the pattern list for the percussion
  Mem[iMemPtr] := iPERC_ADDR and $FF;
  Mem[iMemPtr+1] := iPERC_ADDR shr 8;
  Mem[iMemPtr+2] := 0;
  Mem[iMemPtr+3] := 0;
  Mem[iMemPtr+4] := iMemPtr and $FF;
  Mem[iMemPtr+5] := iMemPtr shr 8;

  // Set the SONGSTART address in the player code...
  Mem[$8019] := $C6; Mem[$801A] := $82;
  // Set the PERCSTART address in the player code...
  Mem[$8020] := iMemPtr and $FF; Mem[$8021] := iMemPtr shr 8;

  inc(iMemPtr,6);

  Result := iMemPtr-$82C6;
end;

function TSpecEmu.LoadSFXSong(Song: TSTSong; iStartPos: integer): integer;
var
  iMemPtr: integer;
  iPATT_ADDR: array [0..255] of Word;
  iLOOP_ADDR: word;
  iChan, i, iPat, iNote, iNoteLen, iOneNote: integer;
begin
  iMemPtr := $82C6;
  iLOOP_ADDR := 0;

  // Add data for all used patterns
  for iPat := 0 to 255 do
  begin
    if not (Song.IsPatternUsed(iPat)) then
      iPATT_ADDR[iPat] := 0
    else
    begin
      iPATT_ADDR[iPat] := iMemPtr;
      inc(iMemPtr,2); // Leave two bytes ready to receive the ptr to ch2 data

      iOneNote := 21 - Song.Pattern[iPat].Tempo; // Length of one row in the pattern
      for iChan := 1 to 2 do
      begin
        if iChan = 2 then
        begin
          Mem[iPATT_ADDR[iPat]] := iMemPtr and $FF;
          Mem[iPATT_ADDR[iPat]+1] := iMemPtr shr 8;
        end;
        // Channel pattern data
        iNote := $83; // Rest/Mute
        iNoteLen := 0;
        for i := 1 to Song.Pattern[iPat].Length do
        begin
          if Song.Pattern[iPat].Chan[iChan][i] = 255 then
            Inc(iNoteLen,iOneNote)
          else
          begin
            if iNoteLen > 0 then
              SFXAddNoteData(iMemPtr,iNote,iNoteLen);

            iNote := Song.Pattern[iPat].Chan[iChan][i];
            iNoteLen := iOneNote;
          end;
          if Song.Pattern[iPat].Sustain[iChan][i] <> 255 then
          begin
            Mem[iMemPtr] := $81; Mem[iMemPtr+1] := Song.Pattern[iPat].Sustain[iChan][i];
            inc(iMemPtr,2)
          end;
        end;
        if iNoteLen > 0 then
          SFXAddNoteData(iMemPtr,iNote,iNoteLen);

        Mem[iMemPtr] := $80; // Channel terminator
        inc(iMemPtr);
      end;
    end;
  end;

  // Set the SONGSTART address in the player code...
  Mem[$8019] := ((iMemPtr + iStartPos * 2) and $FF); Mem[$801A] := ((iMemPtr + iStartPos * 2)  shr 8);

  // Add pattern layout at the SONGSTART address
  for i := 0 to Song.SongLength - 1 do
  begin
    if i = Song.LoopStart then
      iLOOP_ADDR := iMemPtr;

    Mem[iMemPtr] := iPATT_ADDR[Song.SongLayout[i]] and $FF;
    Mem[iMemPtr+1] := iPATT_ADDR[Song.SongLayout[i]] shr 8;
    inc(iMemPtr,2);
  end;
  Mem[iMemPtr] := $00;   Mem[iMemPtr+1] := $00;
  inc(iMemPtr,2);
  // ADD iLOOP_ADDR
  Mem[iMemPtr] := iLOOP_ADDR and $FF;
  Mem[iMemPtr+1] := iLOOP_ADDR shr 8;
  inc(iMemPtr,2);

  // ADD PERCUSSION DATA
  for iPat := 0 to 255 do
  begin
    if not (Song.IsPatternUsed(iPat)) then
      iPATT_ADDR[iPat] := 0
    else
    begin
      iPATT_ADDR[iPat] := iMemPtr;
      // Add the percussion pattern
      iNote := $85; // Rest/Mute
      iNoteLen := 0;
      iOneNote := 21 - Song.Pattern[iPat].Tempo; // Length of one row in the pattern

      for i := 1 to Song.Pattern[iPat].Length do
      begin
        if (Song.Pattern[iPat].Drum[i] < $80) or (Song.Pattern[iPat].Drum[i] > $85) then
          Inc(iNoteLen,iOneNote)
        else
        begin
          if iNoteLen > 0 then
            SFXAddNoteData(iMemPtr,iNote,iNoteLen);
          iNote := Song.Pattern[iPat].Drum[i];
          iNoteLen := iOneNote;
        end;
      end;
      if iNoteLen > 0 then
        SFXAddNoteData(iMemPtr,iNote,iNoteLen);
      Mem[iMemPtr] := $80; // Terminator
      inc(iMemPtr);
    end;
  end;

  // Set the PERCSTART address in the player code...
  Mem[$8020] := (iMemPtr + iStartPos * 2) and $FF; Mem[$8021] := (iMemPtr + iStartPos * 2) shr 8;

  // Add percussion pattern layout at the PERCSTART address
  for i := 0 to Song.SongLength - 1 do
  begin
    if i = Song.LoopStart then
      iLOOP_ADDR := iMemPtr;

    Mem[iMemPtr] := iPATT_ADDR[Song.SongLayout[i]] and $FF;
    Mem[iMemPtr+1] := iPATT_ADDR[Song.SongLayout[i]] shr 8;
    inc(iMemPtr,2);
  end;
  Mem[iMemPtr] := $00;   Mem[iMemPtr+1] := $00;
  inc(iMemPtr,2);
  // ADD iLOOP_ADDR
  Mem[iMemPtr] := iLOOP_ADDR and $FF;
  Mem[iMemPtr+1] := iLOOP_ADDR shr 8;
  inc(iMemPtr,2);

  Result := iMemPtr - $8000;
end;

///////////////////////////////////////////////////////////////////////////////
// The Music Box
//
// Routines to format a song or single pattern data in speccy memory for
// replay by the Music Box player routine at $8000
///////////////////////////////////////////////////////////////////////////////
function GetTMBNoteFreq(iNote: integer): integer;
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

procedure TSpecEmu.TMBAddNoteData(var iMemPtr: integer; iCH1, iCH2: integer);
begin
  Mem[iMemPtr] := GetTMBNoteFreq(iCH1);
  Mem[iMemPtr+1] := GetTMBNoteFreq(iCH2);
  inc(iMemPtr,2);
end;

function TSpecEmu.LoadTMBPattern(Patt: STPatterns.TPattern): integer;
var
  iMemPtr, i: integer;
begin
  // Load a single pattern of song data for the TMB engine to play
  iMemPtr := $80CF;
  Mem[iMemPtr] := $D1; Mem[iMemPtr+1] := $80; // Pattern address
  inc(iMemPtr,2);
  // PATTERN DATA
  Mem[iMemPtr] := Patt.Tempo * 2 + 210; // Pattern Tempo byte
  inc(iMemPtr);
  for i := 1 to Patt.Length do
  begin
    TMBAddNoteData(iMemPtr, Patt.Chan[1][i], Patt.Chan[2][i]);
  end;
  Mem[iMemPtr] := $00; // Pattern end marker

  // Point the two instances of PATTERDATA at the start of the first pattern address
  Mem[$802E] := $CF;   Mem[$802F] := $80;
  Mem[$8041] := $CF;   Mem[$8042] := $80;

  // Set PATTERN_LOOP_BEGIN IN CODE
  Mem[$801E] := 0;
  Mem[$8026] := 2; // Loop after 1 pattern

  // Set initial TEMP
  Mem[$8009] := Patt.Tempo * 2 + 210;

  Result := iMemPtr - $80CF;
end;

function TSpecEmu.LoadTMBSong(Song: TSTSong; iStartPos: integer): integer;
var
  iMemPtr, iPat: Integer;
  iPATT_ADDR: array [0..255] of Word;
  i: Integer;
begin
  // Load a song for the TMB engine to play

  // Set initial TEMPO for first patterm
  Mem[$8009] := Song.Pattern[Song.SongLayout[iStartPos]].Tempo * 2 + 210;

  // Write all the used patterns
  iMemPtr := $80CF;
  for iPat := 0 to 255 do
  begin
    if not (Song.IsPatternUsed(iPat)) then
      iPATT_ADDR[iPat] := 0
    else
    begin
      iPATT_ADDR[iPat] := iMemPtr;
      Mem[iMemPtr] := Song.Pattern[iPat].Tempo * 2 + 210;
      inc(iMemPtr);

      for i := 1 to Song.Pattern[iPat].Length do
        TMBAddNoteData(iMemPtr, Song.Pattern[iPat].Chan[1][i], Song.Pattern[iPat].Chan[2][i]);
      Mem[iMemPtr] := $00;
      inc(iMemPtr);
    end;
  end;

  // Point the two instances of PATTERDATA at the start of the first pattern address
  Mem[$802E] := iMemPtr and $FF;   Mem[$802F] := iMemPtr shr 8;
  Mem[$8041] := iMemPtr and $FF;   Mem[$8042] := iMemPtr shr 8;

  for i := 0 to Song.SongLength - 1 do
  begin
    Mem[iMemPtr] := iPATT_ADDR[Song.SongLayout[i]] and $FF;
    Mem[iMemPtr+1] := iPATT_ADDR[Song.SongLayout[i]] shr 8;
    inc(iMemPtr,2);
  end;

  // Set PATTERN_LOOP_BEGIN IN CODE
  Mem[$801E] := Song.LoopStart * 2; // Start of Loop
  Mem[$8026] := Song.SongLength * 2; // Length of songdata block in bytes

  // Set PATTER_PTR IN CODE
  Mem[$801B] := iStartPos * 2;
  Mem[$801C] := 1;

  // NOP out the LD (PATTERN_PTR),A from the start of the plyer  as this
  // would overwrite out above manual setting of the start pattern
  Mem[$8001] := 0;   Mem[$8002] := 0;   Mem[$8003] := 0;  

  Result := iMemPtr - $80CF;
end;

///////////////////////////////////////////////////////////////////////////////
// Music Studio
//
// Routines to format a song or single pattern data in speccy memory for
// replay by the SFX player routine at $8000
///////////////////////////////////////////////////////////////////////////////
function GetMSDNoteFreq(iNote: integer): integer;
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

procedure TSpecEmu.MSDAddNoteData(var iMemPtr: integer; iCH1, iCH2: integer);
begin
  Mem[iMemPtr] := GetMSDNoteFreq(iCH1);
  Mem[iMemPtr+1] := GetMSDNoteFreq(iCH2);
  inc(iMemPtr,2);
end;

procedure TSpecEmu.MSDAddDrumData(var iMemPtr: integer; iCH1, iDrum: integer);
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
  Mem[iMemPtr] := GetMSDNoteFreq(iCH1);
  Mem[iMemPtr+1] := iDrum;
  inc(iMemPtr,2);
end;

function TSpecEmu.LoadMSDPattern(Patt: STPatterns.TPattern): integer;
var
  iMemPtr, i: integer;
begin
  // Load a single pattern of song data for the TMB engine to play
  iMemPtr := $80CB;
  Mem[iMemPtr] := $CD; Mem[iMemPtr+1] := $80; // Pattern address
  inc(iMemPtr,2);
  // PATTERN DATA
  Mem[iMemPtr] := Patt.Tempo * 2; // Pattern Tempo byte
  inc(iMemPtr);
  for i := 1 to Patt.Length do
  begin
    if (Patt.Drum[i] > $80) and (Patt.Drum[i] < $8E) then
      MSDAddDrumData(iMemPtr, Patt.Chan[1][i], Patt.Drum[i])
    else
      MSDAddNoteData(iMemPtr, Patt.Chan[1][i], Patt.Chan[2][i]);
  end;
  Mem[iMemPtr] := $FE; // Pattern end marker

  // Point the two instances of PATTERDATA at the start of the first pattern address
  Mem[$8033] := $CB;   Mem[$8034] := $80;
  Mem[$8046] := $CB;   Mem[$8047] := $80;

  // Set PATTERN_LOOP_BEGIN IN CODE
  Mem[$8023] := 0;
  Mem[$802B] := 2; // Loop after 1 pattern

  // Set initial TEMPO
  Mem[$8009] := 64 - Patt.Tempo * 3;
  Mem[$8020] := 0;

  Result := iMemPtr - $80CB;
end;

function TSpecEmu.LoadMSDSong(Song: TSTSong; iStartPos: integer): integer;
var
  iMemPtr, iPat: Integer;
  iPATT_ADDR: array [0..255] of Word;
  i: Integer;
begin
  // Set initial TEMPO for first patterm
  Mem[$8009] := 64 - Song.Pattern[Song.SongLayout[iStartPos]].Tempo * 3;

  // Write all the used patterns
  iMemPtr := $80CB;
  for iPat := 0 to 255 do
  begin
    if not (Song.IsPatternUsed(iPat)) then
      iPATT_ADDR[iPat] := 0
    else
    begin
      iPATT_ADDR[iPat] := iMemPtr;
      Mem[iMemPtr] := 64 - Song.Pattern[iPat].Tempo * 3;
      inc(iMemPtr);

      for i := 1 to Song.Pattern[iPat].Length do
      begin
        if (Song.Pattern[iPat].Drum[i] > $80) and (Song.Pattern[iPat].Drum[i] < $8E) then
          MSDAddDrumData(iMemPtr, Song.Pattern[iPat].Chan[1][i], Song.Pattern[iPat].Drum[i])
        else
          MSDAddNoteData(iMemPtr, Song.Pattern[iPat].Chan[1][i], Song.Pattern[iPat].Chan[2][i]);
      end;
      Mem[iMemPtr] := $FE;
      inc(iMemPtr);
    end;
  end;

  // Point the two instances of PATTERDATA at the start of the first pattern address
  Mem[$8033] := iMemPtr and $FF;   Mem[$8034] := iMemPtr shr 8;
  Mem[$8046] := iMemPtr and $FF;   Mem[$8047] := iMemPtr shr 8;

  for i := 0 to Song.SongLength - 1 do
  begin
    Mem[iMemPtr] := iPATT_ADDR[Song.SongLayout[i]] and $FF;
    Mem[iMemPtr+1] := iPATT_ADDR[Song.SongLayout[i]] shr 8;
    inc(iMemPtr,2);
  end;

  // Set PATTERN_LOOP_BEGIN IN CODE
  Mem[$8023] := Song.LoopStart * 2; // Start of Loop
  Mem[$802B] := Song.SongLength * 2; // Length of songdata block in bytes

  // Set PATTER_PTR IN CODE
  Mem[$8020] := iStartPos * 2;
  Mem[$8021] := 1;

  // NOP out the LD (PATTERN_PTR),A from the start of the plyer  as this
  // would overwrite out above manual setting of the start pattern
  Mem[$8001] := 0;   Mem[$8002] := 0;   Mem[$8003] := 0;

  Result := iMemPtr - $80CB;
end;

///////////////////////////////////////////////////////////////////////////////
// Phaser1
//
// Routines to format a song or single pattern data in speccy memory for
// replay by the Phaser1 player routine at $8000
///////////////////////////////////////////////////////////////////////////////
function GetHighestSustainValue(Patt: STPatterns.TPattern; iChan: integer): integer;
var
  i: Integer;
begin
  Result := -1;

  if (iChan < 1) or (iChan > 2) then exit;


  for i := 1 to Patt.Length do
  begin
    if (Patt.Sustain[iChan][i] <> 255) and
       (Patt.Sustain[iChan][i] > Result) then
      Result := Patt.Sustain[iChan][i];
  end;
end;

procedure TSpecEmu.AddIdleTime(var iPtr: integer; iIdleTime: integer);
begin
  while (iIdleTime > $75) do
  begin
    Mem[iPtr] := $75;
    Dec(iIdleTime,$75);
    Inc(iPtr);
  end;
  if iIdleTime > 0 then
  begin
    Mem[iPtr] := (iIdleTime and $FF);
    Inc(iPtr);
  end;
end;

procedure TSpecEmu.P1DAddPatternData(Patt: STPatterns.TPattern; var iMemPtr: integer);
var
  i, iTempo, iIdleTime: integer;
  cNote1,cNote2,cDrum: byte;
begin
  iTempo := 17 - Patt.Tempo;
  if iTempo < 1 then iTempo := 1;

  iIdleTime := 0;
  for i := 1 to Patt.Length do
  begin
    cNote1 := Patt.Chan[2][i];
    if cNote1 = $82 then cNote1 := 60; // Rest/Note-off
    cNote2 := Patt.Chan[1][i];
    if cNote2 = $82 then cNote2 := 60; // Rest/Note-off
    if (cNote1 < 60) then inc(cNote1,6);
    if (cNote2 < 60) then inc(cNote2,6);
    if (cNote1 > 100) and (cNote1 < 107) then dec(cNote1,101);  // bottom 6 notes
    if (cNote2 > 100) and (cNote2 < 107) then dec(cNote2,101);  // bottom 6 notes
    // cNote1 and cNote2 are now 0-60 or 255 for no note data
    cDrum := Patt.Drum[i] - $80;
    if cDrum > 9 then cDrum := 0;

    if (cNote1 = 255) and (cNote2 = 255) and
       (Patt.Sustain[1][i] = 255) and
       (Patt.Sustain[2][i] = 255) and
       (Patt.Drum[i] = 0) then
      inc(iIdleTime,iTempo)
    else
    begin
      if iIdleTime >0 then
      begin
        AddIdleTime(iMemPtr,iIdleTime);
        iIdleTime := 0;
      end;
      if cNote1 = 255 then cNote1 := 62; // Phaser1's no-action is 62, not 255
      if cNote2 = 255 then cNote2 := 62; // Phaser1's no-action is 62, not 255
      if (Patt.Sustain[2][i] <> 255) then
      begin
        Mem[iMemPtr] := $BD;
        Mem[iMemPtr+1] := (Patt.Sustain[2][i] mod 100) * 2;
        inc(iMemPtr,2);
      end;
      if (Patt.Sustain[1][i] <> 255) then
        cNote1 := cNote1 or $C0 // bits 7 and 6 on (reset phaser)
      else
        cNote1 := cNote1 or $80; // just bit 7 on (no phaser reset);
      cNote2 := cNote2 or $80;
      Mem[iMemPtr] := cNote1;
      inc(iMemPtr);
      if cNote2 <> $BE  then
      begin
        Mem[iMemPtr] := cNote2;
        inc(iMemPtr);
      end;
      if cDrum > 0 then
      begin
        Mem[iMemPtr] := cDrum + $75;
        inc(iMemPtr);
        inc(iIdleTime,iTempo-1);
      end
      else
        inc(iIdleTime,iTempo);
    end;
  end;
  if iIdleTime >0 then
    AddIdleTime(iMemPtr,iIdleTime);

  Mem[iMemPtr] := $0; // End of Pattern
  inc(iMemPtr);
end;

function TSpecEmu.LoadP1DPattern(Patt: STPatterns.TPattern; Song: TSTSong): integer;
var
  iMemPtr, i, iMaxInst, iTempo, iIdleTime: integer;
  cNote1,cNote2,cDrum: byte;
begin
  if Song = nil then
  begin
    Result := 0;
    exit;
  end;

  // Load a single pattern of song data for the Phaser1 engine to play
  iMemPtr := $8700;

  // Point the instance of MUSICDATA at the start of the data
  Mem[$8001] := iMemPtr and $FF;   Mem[$8002] := iMemPtr shr 8;

  iMaxInst := GetHighestSustainValue(Patt,2);
  if (iMaxInst < 0) then
  begin
    Patt.Sustain[2][1] := 0;
    iMaxInst := 0;
  end;

  // Set PATTERN_LOOP_BEGIN IN SONG DATA
  Mem[iMemPtr] := 0;
  inc(iMemPtr);
  Mem[iMemPtr] := 2; // Loop after 1 pattern
  inc(iMemPtr);

  Mem[iMemPtr] := ((iMaxInst+1) * 4) and $FF;
  Mem[iMemPtr+1] := ((iMaxInst+1) * 4) shr 8; // Size of instrument table
  inc(iMemPtr,2);
  // INSTRUMENT TABLE
  for i := 0 to iMaxInst do
  begin
    Mem[iMemPtr] := Song.Phaser1Instrument[i].Multiple;
    Mem[iMemPtr+1] := Song.Phaser1Instrument[i].Detune and $FF;
    Mem[iMemPtr+2] := Song.Phaser1Instrument[i].Detune shr 8;
    Mem[iMemPtr+3] := Song.Phaser1Instrument[i].Phase;
    inc(iMemPtr,4)
  end;
  Mem[iMemPtr] := (iMemPtr + 2) and $FF;
  Mem[iMemPtr+1] := (iMemPtr + 2) shr 8;
  inc(iMemPtr,2);

  iTempo := 17 - Patt.Tempo;
  if iTempo < 1 then iTempo := 1;

  iIdleTime := 0;
  for i := 1 to Patt.Length do
  begin
    cNote1 := Patt.Chan[2][i];
    if cNote1 = $82 then cNote1 := 60; // Rest/Note-off
    cNote2 := Patt.Chan[1][i];
    if cNote2 = $82 then cNote2 := 60; // Rest/Note-off
    if (cNote1 < 60) then inc(cNote1,6);
    if (cNote2 < 60) then inc(cNote2,6);
    if (cNote1 > 100) and (cNote1 < 107) then dec(cNote1,101);  // bottom 6 notes
    if (cNote2 > 100) and (cNote2 < 107) then dec(cNote2,101);  // bottom 6 notes
    // cNote1 and cNote2 are now 0-60 or 255 for no note data
    cDrum := Patt.Drum[i] - $80;
    if cDrum > 9 then cDrum := 0;

    if (cNote1 = 255) and (cNote2 = 255) and
       (Patt.Sustain[1][i] = 255) and
       (Patt.Sustain[2][i] = 255) and
       (Patt.Drum[i] = 0) then
      inc(iIdleTime,iTempo)
    else
    begin
      if iIdleTime >0 then
      begin
        AddIdleTime(iMemPtr,iIdleTime);
        iIdleTime := 0;
      end;
      if cNote1 = 255 then cNote1 := 62; // Phaser1's no-action is 62, not 255
      if cNote2 = 255 then cNote2 := 62; // Phaser1's no-action is 62, not 255
      if (Patt.Sustain[2][i] <> 255) then
      begin
        Mem[iMemPtr] := $BD;
        Mem[iMemPtr+1] := (Patt.Sustain[2][i] mod 100) * 2;
        inc(iMemPtr,2);
      end;
      if (Patt.Sustain[1][i] <> 255) then
        cNote1 := cNote1 or $C0 // bits 7 and 6 on (reset phaser)
      else
        cNote1 := cNote1 or $80; // just bit 7 on (no phaser reset);
      cNote2 := cNote2 or $80;
      Mem[iMemPtr] := cNote1;
      inc(iMemPtr);
      if cNote2 <> $BE  then
      begin
        Mem[iMemPtr] := cNote2;
        inc(iMemPtr);
      end;
      if cDrum > 0 then
      begin
        Mem[iMemPtr] := cDrum + $75;
        inc(iMemPtr);
        inc(iIdleTime,iTempo-1);
      end
      else
        inc(iIdleTime,iTempo);
    end;
  end;
  if iIdleTime >0 then
    AddIdleTime(iMemPtr,iIdleTime);

  Mem[iMemPtr] := $0; // End of Pattern

  // Set PATTER_PTR and NOTE_PTR IN CODE
  Mem[$8251] := 0;
  Mem[$8252] := 0;   Mem[$8253] := 0;
  // Nop out the code at the start of the player that initialises PATTERN_PTR
  // and NOTE_PTR to zero...
  Mem[$801C] := 0; Mem[$801D] := 0; Mem[$801E] := 0; Mem[$801F] := 0;
  Mem[$8020] := 0; Mem[$8021] := 0; Mem[$8022] := 0; Mem[$8023] := 0;

  Result := iMemPtr - $8700;
end;

function TSpecEmu.LoadP1DSong(Song: TSTSong; iStartPos: integer): integer;
var
  iMemPtr, iMaxInst, i, iPat: integer;
  iPATT_ADDR: array [0..255] of Word;
  iSongStartAddr: integer;
begin
  // Load a single pattern of song data for the Phaser1 engine to play
  iMemPtr := $8700;

  // Point the instance of MUSICDATA at the start of the data
  Mem[$8001] := iMemPtr and $FF;   Mem[$8002] := iMemPtr shr 8;

  iMaxInst := Song.GetHighestInstrument();
  if (iMaxInst < 0) then
  begin
    Song.Pattern[Song.SongLayout[0]].Sustain[2][1] := 0;
    iMaxInst := 0;
  end;

  // Set PATTERN_LOOP_BEGIN and PATTERN_LOOP_END in song data
  Mem[iMemPtr] := Song.LoopStart * 2;;
  inc(iMemPtr);
  Mem[iMemPtr] := Song.SongLength * 2;;
  inc(iMemPtr);

  Mem[iMemPtr] := ((iMaxInst+1) * 4) and $FF;
  Mem[iMemPtr+1] := ((iMaxInst+1) * 4) shr 8; // Size of instrument table
  inc(iMemPtr,2);
  // INSTRUMENT TABLE
  for i := 0 to iMaxInst do
  begin
    Mem[iMemPtr] := Song.Phaser1Instrument[i].Multiple;
    Mem[iMemPtr+1] := Song.Phaser1Instrument[i].Detune and $FF;
    Mem[iMemPtr+2] := Song.Phaser1Instrument[i].Detune shr 8;
    Mem[iMemPtr+3] := Song.Phaser1Instrument[i].Phase;
    inc(iMemPtr,4)
  end;

  // Reserve space for the sound layout (2 bytes per
  iSongStartAddr := iMemPtr;
  inc(iMemPtr,Song.SongLength * 2);

  // Add data for all used patterns
  for iPat := 0 to 255 do
  begin
    if not (Song.IsPatternUsed(iPat)) then
      iPATT_ADDR[iPat] := 0
    else
    begin
      iPATT_ADDR[iPat] := iMemPtr;
      P1DAddPatternData(Song.Pattern[iPat],iMemPtr);
    end;
  end;

  // Add pattern layout at the SONGSTART address
  for i := 0 to Song.SongLength - 1 do
  begin
    Mem[iSongStartAddr+i*2] := iPATT_ADDR[Song.SongLayout[i]] and $FF;
    Mem[iSongStartAddr+i*2+1] := iPATT_ADDR[Song.SongLayout[i]] shr 8;
  end;

  // Set PATTER_PTR and NOTE_PTR IN CODE
  Mem[$8251] := iStartPos * 2;
  Mem[$8252] := 0;   Mem[$8253] := 0;
  // Nop out the code at the start of the player that initialises PATTERN_PTR
  // and NOTE_PTR to zero...
  Mem[$801C] := 0; Mem[$801D] := 0; Mem[$801E] := 0; Mem[$801F] := 0;
  Mem[$8020] := 0; Mem[$8021] := 0; Mem[$8022] := 0; Mem[$8023] := 0;

  Result := iMemPtr - $8000;
end;

function TSpecEmu.LoadP1SPattern(Patt: STPatterns.TPattern; Song: TSTSong): integer;
var
  iMemPtr, i, iMaxInst, iTempo, iIdleTime: integer;
  cNote1,cNote2,cDrum: byte;
begin
  if Song = nil then
  begin
    Result := 0;
    exit;
  end;

  // Load a single pattern of song data for the Phaser1 engine to play
  iMemPtr := $8700;

  // Point the instance of MUSICDATA at the start of the data
  Mem[$8001] := iMemPtr and $FF;   Mem[$8002] := iMemPtr shr 8;

  iMaxInst := GetHighestSustainValue(Patt,2);
  if (iMaxInst < 0) then
  begin
    Patt.Sustain[2][1] := 0;
    iMaxInst := 0;
  end;

  // Set PATTERN_LOOP_BEGIN IN SONG DATA
  Mem[iMemPtr] := 0;
  inc(iMemPtr);
  Mem[iMemPtr] := 2; // Loop after 1 pattern
  inc(iMemPtr);

  Mem[iMemPtr] := ((iMaxInst+1) * 4) and $FF;
  Mem[iMemPtr+1] := ((iMaxInst+1) * 4) shr 8; // Size of instrument table
  inc(iMemPtr,2);
  // INSTRUMENT TABLE
  for i := 0 to iMaxInst do
  begin
    Mem[iMemPtr] := Song.Phaser1Instrument[i].Multiple;
    Mem[iMemPtr+1] := Song.Phaser1Instrument[i].Detune and $FF;
    Mem[iMemPtr+2] := Song.Phaser1Instrument[i].Detune shr 8;
    Mem[iMemPtr+3] := Song.Phaser1Instrument[i].Phase;
    inc(iMemPtr,4)
  end;
  Mem[iMemPtr] := (iMemPtr + 2) and $FF;
  Mem[iMemPtr+1] := (iMemPtr + 2) shr 8;
  inc(iMemPtr,2);

  iTempo := 17 - Patt.Tempo;
  if iTempo < 1 then iTempo := 1;

  iIdleTime := 0;
  for i := 1 to Patt.Length do
  begin
    cNote1 := Patt.Chan[2][i];
    if cNote1 = $82 then cNote1 := 60; // Rest/Note-off
    cNote2 := Patt.Chan[1][i];
    if cNote2 = $82 then cNote2 := 60; // Rest/Note-off
    if (cNote1 < 60) then inc(cNote1,6);
    if (cNote2 < 60) then inc(cNote2,6);
    if (cNote1 > 100) and (cNote1 < 107) then dec(cNote1,101);  // bottom 6 notes
    if (cNote2 > 100) and (cNote2 < 107) then dec(cNote2,101);  // bottom 6 notes
    // cNote1 and cNote2 are now 0-60 or 255 for no note data
    cDrum := Patt.Drum[i] - $80;
    if cDrum > 9 then cDrum := 0;

    if (cNote1 = 255) and (cNote2 = 255) and
       (Patt.Sustain[1][i] = 255) and
       (Patt.Sustain[2][i] = 255) and
       (Patt.Drum[i] = 0) then
      inc(iIdleTime,iTempo)
    else
    begin
      if iIdleTime >0 then
      begin
        AddIdleTime(iMemPtr,iIdleTime);
        iIdleTime := 0;
      end;
      if cNote1 = 255 then cNote1 := 62; // Phaser1's no-action is 62, not 255
      if cNote2 = 255 then cNote2 := 62; // Phaser1's no-action is 62, not 255
      if (Patt.Sustain[2][i] <> 255) then
      begin
        Mem[iMemPtr] := $BD;
        Mem[iMemPtr+1] := (Patt.Sustain[2][i] mod 100) * 2;
        inc(iMemPtr,2);
      end;
      if (Patt.Sustain[1][i] <> 255) then
        cNote1 := cNote1 or $C0 // bits 7 and 6 on (reset phaser)
      else
        cNote1 := cNote1 or $80; // just bit 7 on (no phaser reset);
      cNote2 := cNote2 or $80;
      Mem[iMemPtr] := cNote1;
      inc(iMemPtr);
      if cNote2 <> $BE  then
      begin
        Mem[iMemPtr] := cNote2;
        inc(iMemPtr);
      end;
      if cDrum > 0 then
      begin
        Mem[iMemPtr] := cDrum + $75;
        inc(iMemPtr);
        inc(iIdleTime,iTempo-1);
      end
      else
        inc(iIdleTime,iTempo);
    end;
  end;
  if iIdleTime >0 then
    AddIdleTime(iMemPtr,iIdleTime);

  Mem[iMemPtr] := $0; // End of Pattern

  // Set PATTER_PTR and NOTE_PTR IN CODE
  Mem[$8293] := 0;
  Mem[$8294] := 0;   Mem[$8295] := 0;
  // Nop out the code at the start of the player that initialises PATTERN_PTR
  // and NOTE_PTR to zero...
  Mem[$801C] := 0; Mem[$801D] := 0; Mem[$801E] := 0; Mem[$801F] := 0;
  Mem[$8020] := 0; Mem[$8021] := 0; Mem[$8022] := 0; Mem[$8023] := 0;

  Result := iMemPtr - $8700;
end;

function TSpecEmu.LoadP1SSong(Song: TSTSong; iStartPos: integer): integer;
var
  iMemPtr, iMaxInst, i, iPat: integer;
  iPATT_ADDR: array [0..255] of Word;
  iSongStartAddr: integer;
begin
  // Load a single pattern of song data for the Phaser1 engine to play
  iMemPtr := $8700;

  // Point the instance of MUSICDATA at the start of the data
  Mem[$8001] := iMemPtr and $FF;   Mem[$8002] := iMemPtr shr 8;

  iMaxInst := Song.GetHighestInstrument();
  if (iMaxInst < 0) then
  begin
    Song.Pattern[Song.SongLayout[0]].Sustain[2][1] := 0;
    iMaxInst := 0;
  end;

  // Set PATTERN_LOOP_BEGIN and PATTERN_LOOP_END in song data
  Mem[iMemPtr] := Song.LoopStart * 2;;
  inc(iMemPtr);
  Mem[iMemPtr] := Song.SongLength * 2;;
  inc(iMemPtr);

  Mem[iMemPtr] := ((iMaxInst+1) * 4) and $FF;
  Mem[iMemPtr+1] := ((iMaxInst+1) * 4) shr 8; // Size of instrument table
  inc(iMemPtr,2);
  // INSTRUMENT TABLE
  for i := 0 to iMaxInst do
  begin
    Mem[iMemPtr] := Song.Phaser1Instrument[i].Multiple;
    Mem[iMemPtr+1] := Song.Phaser1Instrument[i].Detune and $FF;
    Mem[iMemPtr+2] := Song.Phaser1Instrument[i].Detune shr 8;
    Mem[iMemPtr+3] := Song.Phaser1Instrument[i].Phase;
    inc(iMemPtr,4)
  end;

  // Reserve space for the sound layout (2 bytes per
  iSongStartAddr := iMemPtr;
  inc(iMemPtr,Song.SongLength * 2);

  // Add data for all used patterns
  for iPat := 0 to 255 do
  begin
    if not (Song.IsPatternUsed(iPat)) then
      iPATT_ADDR[iPat] := 0
    else
    begin
      iPATT_ADDR[iPat] := iMemPtr;
      P1DAddPatternData(Song.Pattern[iPat],iMemPtr);
    end;
  end;

  // Add pattern layout at the SONGSTART address
  for i := 0 to Song.SongLength - 1 do
  begin
    Mem[iSongStartAddr+i*2] := iPATT_ADDR[Song.SongLayout[i]] and $FF;
    Mem[iSongStartAddr+i*2+1] := iPATT_ADDR[Song.SongLayout[i]] shr 8;
  end;

  // Set PATTER_PTR and NOTE_PTR IN CODE
  Mem[$8293] := iStartPos * 2;
  Mem[$8294] := 0;   Mem[$8295] := 0;
  // Nop out the code at the start of the player that initialises PATTERN_PTR
  // and NOTE_PTR to zero...
  Mem[$801C] := 0; Mem[$801D] := 0; Mem[$801E] := 0; Mem[$801F] := 0;
  Mem[$8020] := 0; Mem[$8021] := 0; Mem[$8022] := 0; Mem[$8023] := 0;

  Result := iMemPtr - $8000;
end;

function TSpecEmu.GetPhaser1Drum(iIndex: integer; var A: array of byte): boolean;
const
  P1DrumLoc = $82CC;
var
  i: integer;
begin
  Result := false;
  if (iIndex < 1) or (iIndex > 8) then exit;
  iIndex := Floor(Math.Power(2,iIndex-1));

  for i := 0 to 1023 do
  begin
    if (Mem[P1DrumLoc + i] and iIndex) = 0  then
      A[i] := 0
    else
      A[i] := 255;
  end;
end;

procedure TSpecEmu.SetDrum(iIndex: byte; iOffset: integer; bVal: boolean);
const
  P1DrumLoc = $82CC;
begin
  if (iIndex < 1) or (iIndex > 8) then exit;
  iIndex := Floor(Math.Power(2,iIndex-1));

  Mem[P1DrumLoc + iOffset] := Mem[P1DrumLoc + iOffset] and not iIndex;
  if bVal then
    Mem[P1DrumLoc + iOffset] := Mem[P1DrumLoc + iOffset] or iIndex;
end;

///////////////////////////////////////////////////////////////////////////////
// Savage
//
// Routines to format a song or single pattern data in speccy memory for
// replay by the Savage player routine at $8000. Song data is stored at 35000
///////////////////////////////////////////////////////////////////////////////
function GetHighestArpValue(Patt: STPatterns.TPattern; SvgPatt: STPatterns.TPatternSvg): integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 1 to Patt.Length do
  begin
    if (SvgPatt.Arpeggio[1][i] <> 256) and
       (SvgPatt.Arpeggio[1][i] > Result) then
      Result := SvgPatt.Arpeggio[1][i];
    if (SvgPatt.Arpeggio[2][i] <> 256) and
       (SvgPatt.Arpeggio[2][i] > Result) then
      Result := SvgPatt.Arpeggio[2][i];
  end;
end;

procedure TSpecEmu.SvgAddNoteData(iNote,iNoteLen: integer;
                                  var iLastNoteLen: integer;
                                  var iMemPtr: integer);
begin
  while (iNoteLen > 32) do
  begin
    Mem[iMemPtr] := $FF;  Mem[iMemPtr + 1] := iNote;
    inc(iMemPtr,2);
    Dec(iNoteLen,32);
  end;
  if iNoteLen > 0 then
  begin
    if (iNoteLen <> iLastNoteLen) then
    begin
      Mem[iMemPtr] := $DF + iNoteLen;  Mem[iMemPtr + 1] := iNote;
      inc(iMemPtr,2);
      iLastNoteLen := iNoteLen;
    end
    else
    begin
      Mem[iMemPtr] := iNote;
      inc(iMemPtr);
    end;
  end;
end;

function TSpecEmu.SvgAddPatternData(Patt: STPatterns.TPattern; SvgPatt: STPatterns.TPatternSvg; iChan:integer; iMemPtr: integer): integer;
var
  i, iNote, iNoteLen, iLastNoteLen: integer;
begin
  iNote := $80;  // Rest (erk! - notes cannot sustain between patterns with Savage!)
  iNoteLen := 0; // Length of note in Rows
  iLastNoteLen := 99999; // Last note length written out for this pattern
  for i := 1 to Patt.Length do
  begin
    if ((Patt.Chan[iChan][i] = 255) and
        (SvgPatt.Glissando[iChan][i] = 256) and
        (SvgPatt.Skew[iChan][i] = 256) and
        (SvgPatt.SkewXOR[iChan][i] = 256) and
        (SvgPatt.Arpeggio[iChan][i] = 256) and
        (SvgPatt.Warp[iChan][i] = 0)) then
      Inc(iNoteLen)
    else
    begin
      if iNoteLen > 0 then
        SvgAddNoteData(iNote,iNoteLen,iLastNoteLen,iMemPtr);

      if (SvgPatt.Warp[iChan][i] <> 0) then
      begin
        Mem[iMemPtr] := $86;
        inc(iMemPtr);
      end;
      if (SvgPatt.Glissando[iChan][i] < 256) then
      begin
        Mem[iMemPtr] := $81;    Mem[iMemPtr+1] := SvgPatt.Glissando[iChan][i];
        inc(iMemPtr,2);
      end;
      if (SvgPatt.Skew[iChan][i] < 256) then
      begin
        Mem[iMemPtr] := $85;    Mem[iMemPtr+1] := SvgPatt.Skew[iChan][i];
        inc(iMemPtr,2);
      end;
      if (SvgPatt.SkewXOR[iChan][i] < 256) then
      begin
        Mem[iMemPtr] := $87;    Mem[iMemPtr+1] := SvgPatt.SkewXOR[iChan][i];
        inc(iMemPtr,2);
      end;
      if (SvgPatt.Arpeggio[iChan][i] < 32) then
      begin
        Mem[iMemPtr] := SvgPatt.Arpeggio[iChan][i] + $C0;
        inc(iMemPtr);
      end;

      if Patt.Chan[iChan][i] <> 255 then
        iNote := Patt.Chan[iChan][i];
      if (iNote < 60) then inc(iNote,6);
      if (iNote > 100) and (iNote < 107) then dec(iNote,101);  // bottom 6 notes

      if (iNote = $82) then iNote := $80; // Savage rests are $80, not $82

      iNoteLen := 1;
    end;
  end;
  if iNoteLen > 0 then
    SvgAddNoteData(iNote,iNoteLen,iLastNoteLen,iMemPtr);

  Mem[iMemPtr] := $82; // End of pattern
  inc(iMemPtr);
  Result := iMemPtr;
end;

procedure TSpecEmu.SVG_AddDrumPatternData(Patt: STPatterns.TPattern; var iMemPtr: integer);
var
  i, iNoteLen: integer;
begin
  // Drum pattern data
  iNoteLen := 0;
  for i := 1 to Patt.Length do
  begin
    if (Patt.Drum[i] >= $81) and (Patt.Drum[i] <= $85) then
    begin
      if (iNoteLen > 0) then
      begin
        Mem[iMemPtr] := iNoteLen;
        inc(iMemPtr);
      end;
      Mem[iMemPtr] := Patt.Drum[i]-1;
      inc(iMemPtr);
      iNoteLen := 0;
    end
    else
      Inc(iNoteLen);
  end;
  if iNoteLen > 0 then
  begin
    Mem[iMemPtr] := iNoteLen;
    inc(iMemPtr);
  end;

  Mem[iMemPtr] := $00; // End of pattern
  inc(iMemPtr);
end;

function TSpecEmu.LoadSVGPattern(Patt: STPatterns.TPattern; SvgPatt: STPatterns.TPatternSvg; Song: TSTSong): integer;
var
  iMemPtr, i, j, iMaxArp,iArpOff, iTempo: integer;
const
  SONG_ADDR = 35000;
begin
  if Song = nil then
  begin
    Result := 0;
    exit;
  end;

  // Load a single pattern of song data for the Phaser1 engine to play
  iMemPtr := SONG_ADDR;

  // Point the instance of SONG_INITDATA_0 at the start of the data
  Mem[$803B] := iMemPtr and $FF;   Mem[$803C] := iMemPtr shr 8;

  iMaxArp := GetHighestArpValue(Patt, SvgPatt);

  if (iMaxArp < 0) then
  begin
    SvgPatt.Arpeggio[1][1] := 0;
    SvgPatt.Arpeggio[2][1] := 0;
    iMaxArp := 0;
  end;
  if iMaxArp > 31 then iMaxArp := 31;


  // Set SONG_INITDATA_0
  Mem[iMemPtr] := 4; // Loop after 2 patterns
  inc(iMemPtr);
  Mem[iMemPtr] := 0;
  inc(iMemPtr,3); // Space for CH1 Pattern List

  Mem[iMemPtr] := 4; // Loop after 2 patterns
  inc(iMemPtr);
  Mem[iMemPtr] := 0;
  inc(iMemPtr,3); // Space for CH2 Pattern List

  Mem[iMemPtr] := 2; // Loop after 1 pattern
  inc(iMemPtr);
  Mem[iMemPtr] := 0;
  inc(iMemPtr,3); // Space for Perc Pattern List

  // Point the player at our ornament data
  Mem[$82A2] := iMemPtr and $FF;
  Mem[$82A3] := iMemPtr shr 8;

  // Orn offsets
  iArpOff := 0;
  for i := 0 to iMaxArp do
  begin
    Mem[iMemPtr] := iArpOff and $FF;
    inc(iMemPtr);
    inc(iArpOff,Song.SVGArpeggio[i].Length+1);
  end;

  // Point the player at our ornament data
  Mem[$82EF] := iMemPtr and $FF;
  Mem[$82F0] := iMemPtr shr 8;

  // Ornament data
  Mem[iMemPtr] := $80;
  inc(iMemPtr);
  for i := 1 to iMaxArp do
  begin
    for j := 1 to Song.SVGArpeggio[i].Length do
    begin
      if j = Song.SVGArpeggio[i].Length then
        Mem[iMemPtr] := Song.SVGArpeggio[i].Value[j] and $FF
      else
        Mem[iMemPtr] := Song.SVGArpeggio[i].Value[j] and $7F;

      inc(iMemPtr);
    end;
    if Song.SVGArpeggio[i].Value[Song.SVGArpeggio[i].Length] and $80 = 0 then
    begin
      // $FF end marker for non-looped arpeggios
      Mem[iMemPtr] := $FF;
      inc(iMemPtr);
    end;
  end;

  // CH1
  Mem[SONG_ADDR + 2] := iMemPtr and $FF;
  Mem[SONG_ADDR + 3] := iMemPtr shr 8;

  Mem[iMemPtr] := (iMemPtr + 4) and $FF;
  Mem[iMemPtr+1] := (iMemPtr + 4) shr 8;
  inc(iMemPtr,2);
  Mem[iMemPtr] := 60000 and $FF;
  Mem[iMemPtr+1] := 60000 shr 8;
  inc(iMemPtr,2);

  iTempo := 21 - Patt.Tempo;
  if iTempo < 1 then iTempo := 1;

  Mem[iMemPtr] := iTempo and $FF;
  inc(iMemPtr);

  // Channel 1 pattern data
  iMemPtr := SvgAddPatternData(Patt,SvgPatt,1,iMemPtr);

  // CH2
  Mem[SONG_ADDR + 6] := iMemPtr and $FF;
  Mem[SONG_ADDR + 7] := iMemPtr shr 8;
  Mem[iMemPtr] := (iMemPtr + 4) and $FF;
  Mem[iMemPtr+1] := (iMemPtr + 4) shr 8;
  inc(iMemPtr,2);
  Mem[iMemPtr] := 60000 and $FF;
  Mem[iMemPtr+1] := 60000 shr 8;
  inc(iMemPtr,2);

  Mem[iMemPtr] := iTempo and $FF;
  inc(iMemPtr);

  // Channel 2 pattern data
  iMemPtr := SvgAddPatternData(Patt,SvgPatt,2,iMemPtr);

  // Percussion
  Mem[SONG_ADDR + 10] := iMemPtr and $FF;
  Mem[SONG_ADDR + 11] := iMemPtr shr 8;
  Mem[iMemPtr] := (iMemPtr + 4) and $FF;
  Mem[iMemPtr+1] := (iMemPtr + 4) shr 8;
  inc(iMemPtr,2);
  Mem[iMemPtr] := 60020 and $FF;
  Mem[iMemPtr+1] := 60020 shr 8;
  inc(iMemPtr,2);

  // Percussion pattern data
  SVG_AddDrumPatternData(Patt,iMemPtr);

  // Copy short silent pattern to 60000, + silent perc at 60020
  Mem[60000] := 6; // tempo
  Mem[60001] := $80; // rest
  Mem[60002] := $82; // End
  Mem[60020] := 4; // rest for 4 rows
  Mem[60021] := 0; // end
  iSVGStartPos := 0;

  Result := iMemPtr - SONG_ADDR;
end;


function TSpecEmu.LoadSVGSong(Song: TSTSong; iStartPos: integer): integer;
const
  SONG_ADDR = 35000;
  PATT_ADDR = 36000;
var
  iMemPtr, iTempo, iMaxArp, iArpOff: integer;
  iPATT_ADDR1: array [0..255] of Word;
  iPATT_ADDR2: array [0..255] of Word;
  iPERC_ADDR: array [0..255] of Word;
  i, j, iPat: integer;
begin
  iMemPtr := PATT_ADDR;

  // Add data for all used patterns
  for iPat := 0 to 255 do
  begin
    if not (Song.IsPatternUsed(iPat)) then
      iPATT_ADDR1[iPat] := 0
    else
    begin
      iPATT_ADDR1[iPat] := iMemPtr;

      iTempo := 21 - Song.Pattern[iPat].Tempo;
      if iTempo < 1 then iTempo := 1;

      // Channel 1 pattern data
      Mem[iMemPtr] := iTempo and $FF;
      inc(iMemPtr);

      iMemPtr := SvgAddPatternData(Song.Pattern[iPat],Song.SvgPatternData[iPat],1,iMemPtr);

      // Channel 2 pattern data
      iPATT_ADDR2[iPat] := iMemPtr;
      Mem[iMemPtr] := iTempo and $FF;
      inc(iMemPtr);

      iMemPtr := SvgAddPatternData(Song.Pattern[iPat],Song.SvgPatternData[iPat],2,iMemPtr);

      iPERC_ADDR[iPat] := iMemPtr;

      // Drum pattern data
      SVG_AddDrumPatternData(Song.Pattern[iPat],iMemPtr);
    end;
  end;
  Result := iMemPtr - $8000;

  iMemPtr := SONG_ADDR;
  // Point the instance of SONG_INITDATA_0 at the start of the data
  Mem[$803B] := iMemPtr and $FF;   Mem[$803C] := iMemPtr shr 8;

  iMaxArp := Song.GetHighestArpeggio();

  if (iMaxArp < 0) then
  begin
    Song.SvgPatternData[Song.SongLayout[0]].Arpeggio[1][1] := 0;
    Song.SvgPatternData[Song.SongLayout[0]].Arpeggio[2][1] := 0;
    iMaxArp := 0;
  end;
  if iMaxArp > 31 then iMaxArp := 31;

  // Set SONG_INITDATA_0
  Mem[iMemPtr] := Song.SongLength * 2;
  inc(iMemPtr);
  Mem[iMemPtr] := Song.LoopStart * 2;
  inc(iMemPtr,3); // Space for CH1 Pattern List

  Mem[iMemPtr] := Song.SongLength * 2;
  inc(iMemPtr);
  Mem[iMemPtr] := Song.LoopStart * 2;
  inc(iMemPtr,3); // Space for CH2 Pattern List

  Mem[iMemPtr] := Song.SongLength * 2;
  inc(iMemPtr);
  Mem[iMemPtr] := Song.LoopStart * 2;
  inc(iMemPtr,3); // Space for Perc Pattern List

  // Point the player at our ornament data
  Mem[$82A2] := iMemPtr and $FF;
  Mem[$82A3] := iMemPtr shr 8;

  // Orn offsets
  iArpOff := 0;
  for i := 0 to iMaxArp do
  begin
    Mem[iMemPtr] := iArpOff and $FF;
    inc(iMemPtr);
    inc(iArpOff,Song.SVGArpeggio[i].Length+1);
  end;

  // Point the player at our ornament data
  Mem[$82EF] := iMemPtr and $FF;
  Mem[$82F0] := iMemPtr shr 8;

  // Ornament data
  Mem[iMemPtr] := $80;
  inc(iMemPtr);
  for i := 1 to iMaxArp do
  begin
    for j := 1 to Song.SVGArpeggio[i].Length do
    begin
      Mem[iMemPtr] := Song.SVGArpeggio[i].Value[j] and $FF;
      inc(iMemPtr);
    end;
    Mem[iMemPtr] := $FF;
    inc(iMemPtr);
  end;

  Mem[SONG_ADDR + 2] := iMemPtr and $FF;
  Mem[SONG_ADDR + 3] := iMemPtr shr 8;

  // Add pattern layout at the for CH1
  for i := 0 to Song.SongLength - 1 do
  begin
    Mem[iMemPtr] := iPATT_ADDR1[Song.SongLayout[i]] and $FF;
    Mem[iMemPtr+1] := iPATT_ADDR1[Song.SongLayout[i]] shr 8;
    inc(iMemPtr,2);
  end;

  Mem[SONG_ADDR + 6] := iMemPtr and $FF;
  Mem[SONG_ADDR + 7] := iMemPtr shr 8;

  // Add pattern layout at the for CH2
  for i := 0 to Song.SongLength - 1 do
  begin
    Mem[iMemPtr] := iPATT_ADDR2[Song.SongLayout[i]] and $FF;
    Mem[iMemPtr+1] := iPATT_ADDR2[Song.SongLayout[i]] shr 8;
    inc(iMemPtr,2);
  end;

  Mem[SONG_ADDR + 10] := iMemPtr and $FF;
  Mem[SONG_ADDR + 11] := iMemPtr shr 8;

  // Add pattern layout at the for PERCUSSION
  for i := 0 to Song.SongLength - 1 do
  begin
    Mem[iMemPtr] := iPERC_ADDR[Song.SongLayout[i]] and $FF;
    Mem[iMemPtr+1] := iPERC_ADDR[Song.SongLayout[i]] shr 8;
    inc(iMemPtr,2);
  end;

  if (iStartPos > 0) and (iStartPos < Song.SongLength) then
    iSVGStartPos := iStartPos
  else
    iSVGStartPos := 0;
end;


procedure TSpecEmu.DisplayEmuError(sErr: string; iIntr: byte; regPC: word);
begin
  Application.MessageBox(PAnsiChar(
                         'An emulation error has occurred.'#13#10#13#10 +
                         sErr + IntToHex(iIntr,2) + #13#10#13#10 +
                         'Location: ' + IntToHex(regPC,4) + #13#10 +
                         'Engine: ' + IntToStr(Ord(FEngine)) + #13#10 +
                         'SP: ' + IntToHex(regSP,4)),
                         PAnsiChar(Application.Title),MB_ICONERROR or MB_OK);
  // Try to reboot the emulation
  Self.regPC := $8000;
  Self.regSP := $7FF0;
end;

///////////////////////////////////////////////////////////////////////////////
// ROM Beep
//
// Routines to format a song or single pattern data in speccy memory for
// replay by the ROM Beep player routine at $8000. Song data is stored at $8700
///////////////////////////////////////////////////////////////////////////////
procedure TSpecEmu.RMBAddNoteData(var iMemPtr: integer; iCH1, iCH2: integer);
begin
  if (iCh1 < 60) then inc(iCh1,6);
  if (iCh1 > 100) and (iCh1 < 107) then dec(iCh1,101);  // bottom 6 notes
  if (iCh2 < 60) then inc(iCh2,6);
  if (iCh2 > 100) and (iCh2 < 107) then dec(iCh2,101);  // bottom 6 notes

  if iCh1 > $80 then iCh1 := 1;
  if iCh2 > $80 then iCh2 := 1;
    
  Mem[iMemPtr] := iCh1;
  Mem[iMemPtr+1] := iCh2;
  inc(iMemPtr,2);
end;


function TSpecEmu.LoadRMBPattern(Patt: STPatterns.TPattern; Song: TSTSong): integer;
var
  iMemPtr, i, iMaxInst, iTempo, iIdleTime: integer;
  cNote1,cNote2,cDrum: byte;
begin
  if Song = nil then
  begin
    Result := 0;
    exit;
  end;

  // Load a single pattern of song data for the Phaser1 engine to play
  iMemPtr := $8700;

  // Point the instance of MUSICDATA at the start of the data
  Mem[$8001] := iMemPtr and $FF;   Mem[$8002] := iMemPtr shr 8;

  // Load a single pattern of song data for the RMB engine to play
  Mem[iMemPtr] := $00; // Pattern loop start * 2
  Mem[iMemPtr+1] := $02; // Song Length * 2
  inc(iMemPtr,2);
  Mem[iMemPtr] := (iMemPtr+2) and $FF;
  Mem[iMemPtr+1] := (iMemPtr+2) shr 8;
  inc(iMemPtr,2);

  // PATTERN DATA
  iTempo := 17 - Patt.Tempo;
  if iTempo < 1 then iTempo := 1;

  Mem[iMemPtr] := iTempo; // Pattern Tempo byte
  inc(iMemPtr);
  for i := 1 to Patt.Length do
  begin
    RMBAddNoteData(iMemPtr, Patt.Chan[1][i], Patt.Chan[2][i]);
  end;
  Mem[iMemPtr] := $00; // Pattern end marker

  Result := iMemPtr - $8700;
end;

function TSpecEmu.LoadRMBSong(Song: TSTSong; iStartPos: integer): integer;
var
  iMemPtr, iMaxInst, i, iPat: integer;
  iPATT_ADDR: array [0..255] of Word;
  iSongStartAddr: integer;
begin
  // Load a single pattern of song data for the Phaser1 engine to play
  iMemPtr := $8700;

  // Point the instance of MUSICDATA at the start of the data
  Mem[$8001] := iMemPtr and $FF;   Mem[$8002] := iMemPtr shr 8;

  iMaxInst := Song.GetHighestInstrument();
  if (iMaxInst < 0) then
  begin
    Song.Pattern[Song.SongLayout[0]].Sustain[2][1] := 0;
    iMaxInst := 0;
  end;

  // Set PATTERN_LOOP_BEGIN and PATTERN_LOOP_END in song data
  Mem[iMemPtr] := Song.LoopStart * 2;;
  inc(iMemPtr);
  Mem[iMemPtr] := Song.SongLength * 2;;
  inc(iMemPtr);

  Mem[iMemPtr] := ((iMaxInst+1) * 4) and $FF;
  Mem[iMemPtr+1] := ((iMaxInst+1) * 4) shr 8; // Size of instrument table
  inc(iMemPtr,2);
  // INSTRUMENT TABLE
  for i := 0 to iMaxInst do
  begin
    Mem[iMemPtr] := Song.Phaser1Instrument[i].Multiple;
    Mem[iMemPtr+1] := Song.Phaser1Instrument[i].Detune and $FF;
    Mem[iMemPtr+2] := Song.Phaser1Instrument[i].Detune shr 8;
    Mem[iMemPtr+3] := Song.Phaser1Instrument[i].Phase;
    inc(iMemPtr,4)
  end;

  // Reserve space for the sound layout (2 bytes per
  iSongStartAddr := iMemPtr;
  inc(iMemPtr,Song.SongLength * 2);

  // Add data for all used patterns
  for iPat := 0 to 255 do
  begin
    if not (Song.IsPatternUsed(iPat)) then
      iPATT_ADDR[iPat] := 0
    else
    begin
      iPATT_ADDR[iPat] := iMemPtr;
      P1DAddPatternData(Song.Pattern[iPat],iMemPtr);
    end;
  end;

  // Add pattern layout at the SONGSTART address
  for i := 0 to Song.SongLength - 1 do
  begin
    Mem[iSongStartAddr+i*2] := iPATT_ADDR[Song.SongLayout[i]] and $FF;
    Mem[iSongStartAddr+i*2+1] := iPATT_ADDR[Song.SongLayout[i]] shr 8;
  end;

  // Set PATTER_PTR and NOTE_PTR IN CODE
  Mem[$8251] := iStartPos * 2;
  Mem[$8252] := 0;   Mem[$8253] := 0;
  // Nop out the code at the start of the player that initialises PATTERN_PTR
  // and NOTE_PTR to zero...
  Mem[$801C] := 0; Mem[$801D] := 0; Mem[$801E] := 0; Mem[$801F] := 0;
  Mem[$8020] := 0; Mem[$8021] := 0; Mem[$8022] := 0; Mem[$8023] := 0;

  Result := iMemPtr - $8000;
end;


end.

