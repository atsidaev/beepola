unit frmCompileDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TCompileDlg = class(TForm)
    lblCompileAddress: TLabel;
    txtCompileAddress: TEdit;
    lblBorder: TLabel;
    cboBorder: TComboBox;
    cmdOK: TButton;
    cmdCancel: TButton;
    Label1: TLabel;
    cboEngine: TComboBox;
    pnlSpecialFX: TPanel;
    lblVectorTableLoc: TLabel;
    cboVectorTableLoc: TComboBox;
    pnlTMB: TPanel;
    grpPlayerType: TGroupBox;
    optTMBAlwaysReturn: TRadioButton;
    optTMBReturnKeypress: TRadioButton;
    optTMBContinuous: TRadioButton;
    Label3: TLabel;
    cboOutputType: TComboBox;
    lblTranspose: TLabel;
    cboTranspose: TComboBox;
    grpSongEnd: TGroupBox;
    optLoopAtEnd: TRadioButton;
    optReturnAtEnd: TRadioButton;
    GroupBox1: TGroupBox;
    optSFXReturnKeypress: TRadioButton;
    optSFXContinuous: TRadioButton;
    dlgSave: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure cboEngineChange(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
  private
    function ValidateSettings: boolean;
    function CompileSFX(): integer;
    function CompileTMB(): integer;
    procedure WriteBASICLoader(sFileName: string; iCodeAddr, iType: integer; sEngine: string);
    procedure WriteCODEHeader(sFileName: string; iCodeLen, iStart: integer;
      sTitle: string);
    function CompileMSD: integer;
    function CompileP1D: integer;
    function CompileP1S: integer;
    function CompileSVG: integer;
    function CompileRMB: integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CompileDlg: TCompileDlg;

implementation

uses frmSTMainWnd, SFX_Engine, TMB_Engine, MSD_Engine, P1D_Engine, P1S_Engine,
     SVG_Engine, RMB_Engine,
     Assemb, AsmTypes, GrokUtils;

{$R *.dfm}

procedure TCompileDlg.cboEngineChange(Sender: TObject);
begin
  case (Sender as TComboBox).ItemIndex of
  0: // SpecialFX
  begin
    pnlSpecialFX.Show;
    lblVectorTableLoc.Show;
    cboVectorTableLoc.Show;
    pnlTMB.Hide;
  end;
  1: // TMB
  begin
    pnlSpecialFX.Hide;
    pnlTMB.Show;
  end;
  2: // MSD
  begin
    pnlSpecialFX.Hide;
    pnlTMB.Show;
  end;
  3: // P1D
  begin
    pnlSpecialFX.Show;
    lblVectorTableLoc.Hide;
    cboVectorTableLoc.Hide;
    pnlTMB.Hide;
  end;
  4: // P1S
  begin
    pnlSpecialFX.Show;
    lblVectorTableLoc.Hide;
    cboVectorTableLoc.Hide;
    pnlTMB.Hide;
  end;
  5: // SVG
  begin
    pnlSpecialFX.Show;
    lblVectorTableLoc.Show;
    cboVectorTableLoc.Show;
    pnlTMB.Hide;
  end;
  6: // RMB - ROMBeep
  begin
    pnlSpecialFX.Hide;
    pnlTMB.Show;
  end;
  end;
end;

procedure TCompileDlg.cmdOKClick(Sender: TObject);
var
  iLen: integer;
begin
  iLen := 0;

  if ValidateSettings() then
  begin
    if cboEngine.ItemIndex = 0 then
      iLen := CompileSFX()
    else if cboEngine.ItemIndex = 1 then
      iLen := CompileTMB()
    else if cboEngine.ItemIndex = 2 then
      iLen := CompileMSD()
    else if cboEngine.ItemIndex = 3 then
      iLen := CompileP1D()
    else if cboEngine.ItemIndex = 4 then
      iLen := CompileP1S()
    else if cboEngine.ItemIndex = 5 then
      iLen := CompileSVG()
    else if cboEngine.ItemIndex = 6 then
      iLen := CompileRMB();

    if iLen > 0 then
    begin
      Application.MessageBox(PAnsiChar('Song compilation complete.'#13#10#13#10 +
                             'Player + song data: ' + IntToStr(iLen) + ' bytes.'),
                             PAnsiChar(Application.Name),
                             MB_ICONINFORMATION or MB_OK);
      ModalResult := mrOK;
    end;
  end;
end;

procedure TCompileDlg.FormShow(Sender: TObject);
var
  i: integer;
begin
  cboVectorTableLoc.Items.Clear();
  cboVectorTableLoc.Items.Add('0xFE00 - Default');
  cboVectorTableLoc.Items.Add('0x3900 - ROM');
  for i := $FD downto $80 do
    cboVectorTableLoc.Items.Add('0x' + Format('%.2x',[i]) + '00');

  cboVectorTableLoc.ItemIndex := 0;

  cboEngineChange(cboEngine);
  optTMBReturnKeypress.Checked := true;
  optSFXReturnKeypress.Checked := true;
  optLoopAtEnd.Checked := true;
end;

function TCompileDlg.ValidateSettings(): boolean;
var
  iCompileAddr,iIVector: integer;
begin
  Result := false;

  if STMainWnd.Song.SongLength = 0 then
  begin
    Application.MessageBox('The current song contains no patterns. There is nothing to compile.',
                           PAnsiChar(Application.Title),
                           MB_OK or MB_ICONEXCLAMATION);
    exit;
  end;

  iCompileAddr := StrToIntDef(txtCompileAddress.Text,-1);
  if (iCompileAddr < 16384) or (iCompileAddr > 65300) then
  begin
    Application.MessageBox('The compilation address for the machine code player routine must be at least 16384, and less than 65300.',
                           PAnsiChar(Application.Title),
                           MB_OK or MB_ICONEXCLAMATION);
    exit;
  end;
  if cboEngine.ItemIndex = 0 then
  begin
    // SpecialFX
    iIVector := StrToInt('$' + Copy(cboVectorTableLoc.Text,3,4));
    if (iCompileAddr > (iIVector - 200)) and
       (iCompileAddr <= (iIVector + 255)) then
    begin
      Application.MessageBox(PAnsiChar('The compilation address you have specified for the machine code player (' +
                             IntToStr(iCompileAddr) + ') is a location that will be overwritten by the ' +
                             'interrupt vector table that you have selected (' + IntToStr(iIVector) + ').'#13#10#13#10 +
                             'You must change either the compilation address or the interrupt vector table to ensure that ' +
                             'the resulting player code does not crash during playback.'),
                             PAnsiChar(Application.Title),
                             MB_OK or MB_ICONEXCLAMATION);
      exit;
    end;
  end;

  Result := true;
end;

function GetXORChecksum(P: PByte; iLength: integer): Byte;
var
  i: Integer;
begin
  Result := P^;
  inc(P);
  for i := 1 to iLength - 1 do
  begin
    Result := Result xor P^;
    inc(P);
  end;
end;

function TCompileDlg.CompileSFX(): integer;
var
  slAsm: TStringList;
  sFileName: string;
  cOut: array [0..65538] of byte;
  iLen: integer;
  F: TFileStream;
begin
  slAsm := TStringList.Create();
  iLen := 0;
  slAsm.Add('                ORG ' + IntToStr(StrToIntDef(txtCompileAddress.Text,0)));

  if cboOutputType.ItemIndex > 3 then
  begin
    // Compile Song Data Only
    SFX_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');    
  end
  else
  begin
    // Player Routine + Song Data
    if optSFXReturnKeypress.Checked then
      SFX_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,1) // Read Keyboard
    else
      SFX_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,3); // Ignore keyboard
    slAsm.Add('');
    slAsm.Add('; *** DATA ***');
    slAsm.Add('VECTOR_TABLE_LOC:    EQU $' + Copy(cboVectorTableLoc.Text,3,4));
    slAsm.Add('BORDER_CLR:          EQU $' + IntToStr(cboBorder.ItemIndex));
    SFX_AddFreqTable(slAsm);
    slAsm.Add('');
    SFX_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end;


  case cboOutputType.ItemIndex of
  0: begin
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         // Create an empty file
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),1,'SFX');
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  1,4: begin
       // TAP File Code Only
       // Create an empty file
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file without BASIC loader
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  2,5: begin
       dlgSave.DefaultExt := 'bin';
       dlgSave.Filter := 'Z80 Binary File (*.bin)|*.bin|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         AssembleStringList(slAsm,sFileName,Binary,ASCII);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  3,6: begin
       dlgSave.DefaultExt := 'asm';
       dlgSave.Filter := 'Assembly Listing (*.asm)|*.asm|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         slAsm.SaveToFile(sFileName);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  end;

  FreeAndNil(slAsm);

  Result := iLen;
end;



procedure StringToBytes(s: string; P: PByte);
var
  i: Integer;
begin
  for i := 1 to Length(s) do
  begin
    PByte(P)^ := Ord(s[i]);
    inc(P);
  end;
end;

procedure TCompileDlg.WriteCODEHeader(sFileName: string; iCodeLen, iStart: integer; sTitle: string);
var
  F: TFileStream;
  o: array[0..1024] of byte;
begin
  F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
  F.Seek(0,soFromEnd);
  o[0] := $13; o[1] := $00; // Header length 19 bytes (17 plus type + checksum)
  o[2] := $00;              // Identifies this block as a header -- BLOCK data follows:-
  o[3] := $03;              // $00 = Program:    ($03 = Code:)
  StringToBytes(Copy(sTitle + '          ',1,10),@o[4]);  // "Shark     "
  o[14] := iCodeLen and $FF; o[15] := iCodeLen shr 8; // BASIC loader length ($CF bytes)
  o[16] := iStart and $FF; o[17] := iStart shr 8; // Param1: Code start
  o[18] := $00; o[19] := $80; // Param2: 32768
  o[20] := GetXORChecksum(@o[2],18);
  F.Write(o[0],21);
  FreeAndNil(F);
end;

procedure TCompileDlg.WriteBASICLoader(sFileName: string; iCodeAddr: integer; iType: integer; sEngine: string);
var
  F: TFileStream;
  o: array[0..1024] of byte;
  sVer: string;
begin
  F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
  o[0] := $13; o[1] := $00; // Header length 19 bytes (17 plus type + checksum)
  o[2] := $00;              // Identifies this block as a header -- BLOCK data follows:-
  o[3] := $00;              // $00 = Program:    ($03 = Code:)
  StringToBytes('Beepola   ',@o[4]);  // "Beepola   "
  if (iType = 1) or (iType = 3) then
  begin
    o[14] := $D2; o[15] := $00 // BASIC loader length ($D2 bytes)
  end
  else if iType = 2 then
  begin
    o[14] := $5B; o[15] := $01;
  end;

  o[16] := $0A; o[17] := $00; // Param1: Autostart LINE 10
  o[18] := o[14]; o[19] := o[15]; // Param2: Offset to VARS
  o[20] := GetXORChecksum(@o[2],18);
  F.Write(o[0],21);
  if (iType = 1) or (iType = 3) then
  begin
    o[0] := $D4; o[1] := $00; // Length of BASIC block
  end
  else if iType = 2 then
  begin
    o[0] := $5D; o[1] := $01;
  end;
  o[2] := $FF;                // Identifies this block as data
  o[3] := $00; o[4] := $01;   // LINE 1
  o[5] := $35; o[6] := $00;   // Length = $35 (53) bytes
  o[7] := $EA;                // REM
  GetAppVersionInfo(sVer);
  sVer := 'Created with                    Beepola v' + sVer + '      ';
  StringToBytes(sVer,@o[8]);
  o[59] := $0D;
  o[60] := $00; o[61] := $0A; // LINE 10
  o[62] := $0F; o[63] := $00; // 15 bytes long
  o[64] := $FD; o[65] := $B0;
  o[66] := $22; StringToBytes(IntToStr(iCodeAddr-1),@o[67]);
  o[72] := $22; o[73] := Ord(':'); // CLEAR VAL "?????":
  o[74] := $EF; o[75] := $22; o[76] := $22; o[77] := $AF; // LOAD "" CODE
  o[78] := $0D;
  o[79] := $00; o[80] := $14; // LINE 20
  o[81] := $1D; o[82] := $00; // Length $1D (29) bytes
  o[83] := $E7; o[84] := $30; o[85] := $0E; o[86] := 0; o[87] := 0; o[88] := 0;
  o[89] := 0; o[90] := 0; o[91] := $3A; // BORDER 0:
  o[92] := $DA; o[93] := $30; o[94] := $0E; o[95] := 0; o[96] := 0; o[97] := 0;
  o[98] := 0; o[99] := 0; o[100] := $3A; // PAPER 0:
  o[101] := $D9; o[102] := $37; o[103] := $0E; o[104] := 0; o[105] := 0; o[106] := 7;
  o[107] := 0; o[108] := 0; o[109] := $3A; // INK 7:
  o[110] := $FB;                           // CLS
  o[111] := $0D;
  o[112] := $00; o[113] := $1E;    // LINE 30
  o[114] := $24; o[115] := $00;    // Length $24, 36 bytes
  o[116] := $F5;                   // PRINT
  StringToBytes('" Title: ' + Copy(STMainWnd.Song.SongTitle + StringOfChar(' ',30),1,24) + '"',@o[117]);
  o[151] := $0D;
  o[152] := $00; o[153] := $28;    // LINE 40
  o[154] := $24; o[155] := $00;    // Length $24, 36 bytes
  o[156] := $F5;                   // PRINT
  StringToBytes('"Author: ' + Copy(STMainWnd.Song.SongAuthor + StringOfChar(' ',30),1,24) + '"',@o[157]);
  o[191] := $0D;

  case iType of
  1,3:
    begin
      // Just a RANDOMIZE USR to begin playing the song
      o[192] := $00; o[193] := $32;    // LINE 50
      o[194] := $02; o[195] := $00;    // 2 bytes long
      o[196] := $F5; o[197] := $0D;    // PRINT
      o[198] := $00; o[199] := $3C;    // LINE 60
      o[200] := $0B; o[201] := $00;    // 11 bytes
      o[202] := $F9; o[203] := $C0; o[204] := $B0; // RANDOMIZE USR VAL
      o[205] := $22;
      StringToBytes(IntToStr(iCodeAddr),@o[206]);
      o[211] := $22;
      o[212] := $0D;
      o[213] := GetXORCheckSum(@o[2],211);
      F.Write(o[0],214);
    end;
  2:
    begin
      // RANDOMIZE USR addr to move to tune start
      // RANDOMIZE USR addr+offset to play next note
      o[192] := $00; o[193] := $32;    // LINE 50
      o[194] := $46; o[195] := $00;    // $46 bytes long
      o[196] := $F5; o[197] := $3A;    // PRINT :
      o[198] := $F5;                   // PRINT
      if (sEngine = 'TMB') or (sEngine = 'RMB') then
        StringToBytes('"RAND USR ' + IntToStr(iCodeAddr) + ' to init song     RAND USR ' + IntToStr(iCodeAddr+30) + ' to play next note"',@o[199])
      else
        StringToBytes('"RAND USR ' + IntToStr(iCodeAddr) + ' to init song     RAND USR ' + IntToStr(iCodeAddr+34) + ' to play next note"',@o[199]);
      o[265] := $0D;
      o[266] := $00; o[267] := $3C;    // LINE 60
      o[268] := $16; o[269] := $00;    // 22 bytes long
      o[270] := $F1; o[271] := $6E; o[272] := $3D; //  LET n=
      o[273] := $30; o[274] := $0E; o[275] := 0; o[276] := 0; o[277] := 0;
      o[278] := 0; o[279] := 0; o[280] := $3A;     //   0 :

      o[281] := $F9; o[282] := $C0; o[283] := $B0;
      o[284] := $22;
      StringToBytes(IntToStr(iCodeAddr),@o[285]);
      o[290] := $22;   // RANDOMIZE USR VAL "xxxxx"
      o[291] := $0D;
      o[292] := 0; o[293] := $46;      // LINE 70
      o[294] := $36; o[295] := $00;    // $36 bytes long
      o[296] := $F9; o[297] := $C0; o[298] := $B0; // RANDOMIZE USR VAL
      o[299] := $22;
      if sEngine = 'TMB' then
        StringToBytes(IntToStr(iCodeAddr+30),@o[300])
      else
        StringToBytes(IntToStr(iCodeAddr+34),@o[300]);
      o[305] := $22;
      o[306] := $3A; o[307] := $F1; o[308] := $6E; o[309] := $3D; o[310] := $6E;
      o[311] := $2B; o[312] := $31; o[313] := $0E; o[314] := 0; o[315] := 0;
      o[316] := 1; o[317] := 0; o[318] := 0; // : LET n=n+1
      o[319] := $3A; o[320] := $F5; o[321] := $AC; o[322] := $36; o[323] := $0E;
      o[324] := 0; o[325] := 0; o[326] := 6; o[327] := 0; o[328] := 0; o[329] := $2C;
      o[330] := $36; o[331] := $0E; o[332] := 0; o[333] := 0; o[334] := 6;
      o[335] := 0; o[336] := 0; o[337] := $3B; o[338] := $6E; // : PRINT AT 6,6;n
      o[339] := $3A; o[340] := $EC; o[341] := $37; o[342] := $30; o[343] := $0E;
      o[344] := 0; o[345] := 0; o[346] := $46; o[347] := 0; o[348] := 0;
      o[349] := $0D; // : GO TO 70
      o[350] := GetXORCheckSum(@o[2],348);
      F.Write(o[0],351)
    end;
  end;
  FreeAndNil(F);
end;

function TCompileDlg.CompileTMB(): integer;
var
  slAsm: TStringList;
  F: TFileStream;
  sFileName: string;
  iLen: integer;
  cOut: array [0..65538] of byte;
begin
  slAsm := TStringList.Create();
  iLen := 0;
  slAsm.Add('                ORG ' + IntToStr(StrToIntDef(txtCompileAddress.Text,0)));

  if cboOutputType.ItemIndex > 3 then
  begin
    // Compile Song Data Only
    TMB_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');    
  end
  else
  begin
    if optTMBReturnKeypress.Checked then
      TMB_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,1,STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210)
    else if optTMBAlwaysReturn.Checked then
      TMB_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,2,STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210)
    else if optTMBContinuous.Checked then
      TMB_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,3,STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210);

    slAsm.Add('');
    slAsm.Add('; *** DATA ***');
    slAsm.Add('BORDER_COL:               EQU $' + IntToStr(cboBorder.ItemIndex));
    // We must initialise the tempo for the first pattern in the song
    slAsm.Add('TEMPO:                    DEFB ' + IntToStr(STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210));
    TMB_AddFreqTable(slAsm);
    slAsm.Add('');
    TMB_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end;

  case cboOutputType.ItemIndex of
  0: begin
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         // Create an empty file
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         if optTMBReturnKeypress.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),1,'TMB')
         else if optTMBAlwaysReturn.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),2,'TMB')
         else if optTMBContinuous.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),3,'TMB');

         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  1,4: begin
       // TAP File Code Only
       // Create an empty file
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  2,5: begin
       dlgSave.DefaultExt := 'bin';
       dlgSave.Filter := 'Z80 Binary File (*.bin)|*.bin|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         AssembleStringList(slAsm,sFileName,Binary,ASCII);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  3,6: begin
       dlgSave.DefaultExt := 'asm';
       dlgSave.Filter := 'Assembly Listing (*.asm)|*.asm|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         slAsm.SaveToFile(sFileName);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  end;

  FreeAndNil(slAsm);
  Result := iLen;
end;

function TCompileDlg.CompileMSD(): integer;
var
  slAsm: TStringList;
  F: TFileStream;
  sFileName: string;
  iLen: integer;
  cOut: array [0..65538] of byte;
begin
  slAsm := TStringList.Create();
  iLen := 0;
  slAsm.Add('                ORG ' + IntToStr(StrToIntDef(txtCompileAddress.Text,0)));
  if cboOutputType.ItemIndex > 3 then
  begin
    // Compile Song Data Only
    MSD_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end
  else
  begin
    if optTMBReturnKeypress.Checked then
      MSD_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,1,64 - STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 3)
    else if optTMBAlwaysReturn.Checked then
      MSD_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,2,64 - STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 3)
    else if optTMBContinuous.Checked then
      MSD_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,3,64 - STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 3);

    slAsm.Add('');
    slAsm.Add('; *** DATA ***');
    slAsm.Add('BORDER_COL:               EQU $' + IntToStr(cboBorder.ItemIndex));
    // We must initialise the tempo for the first pattern in the song
    slAsm.Add('TEMPO:                    DEFB ' + IntToStr(STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210));
    MSD_AddFreqTable(slAsm);
    slAsm.Add('');
    MSD_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end;

  case cboOutputType.ItemIndex of
  0: begin
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         // Create an empty file
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         if optTMBReturnKeypress.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),1,'MSD')
         else if optTMBAlwaysReturn.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),2,'MSD')
         else if optTMBContinuous.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),3,'MSD');

         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  1,4: begin
       // TAP File Code Only
       // Create an empty file
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  2,5: begin
       dlgSave.DefaultExt := 'bin';
       dlgSave.Filter := 'Z80 Binary File (*.bin)|*.bin|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         AssembleStringList(slAsm,sFileName,Binary,ASCII);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  3: begin
       dlgSave.DefaultExt := 'asm';
       dlgSave.Filter := 'Assembly Listing (*.asm)|*.asm|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         slAsm.SaveToFile(sFileName);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  end;

  FreeAndNil(slAsm);
  Result := iLen;
end;

function TCompileDlg.CompileP1D(): integer;
var
  slAsm: TStringList;
  F: TFileStream;
  sFileName: string;
  iLen: integer;
  cOut: array [0..65538] of byte;
begin
  slAsm := TStringList.Create();
  iLen := 0;
  slAsm.Add('                ORG ' + IntToStr(StrToIntDef(txtCompileAddress.Text,0)));


  if cboOutputType.ItemIndex > 3 then
  begin
    // Compile Song Data Only
    P1D_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end
  else
  begin
    slAsm.Add('BORDER_COL:     EQU  $' + IntToStr(cboBorder.ItemIndex));
    slAsm.Add('');

    if optSFXReturnKeypress.Checked then
      P1D_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,1)
    else if optSFXContinuous.Checked then
      P1D_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,3);

    P1D_AddFreqTable(slAsm);
    slAsm.Add('');
    P1D_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end;

  case cboOutputType.ItemIndex of
  0: begin
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         // Create an empty file
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         if optSFXReturnKeypress.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),1,'P1D')
         else if optSFXContinuous.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),3,'P1D');

         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  1,4: begin
       // TAP File Code Only
       // Create an empty file
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  2,5: begin
       dlgSave.DefaultExt := 'bin';
       dlgSave.Filter := 'Z80 Binary File (*.bin)|*.bin|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         AssembleStringList(slAsm,sFileName,Binary,ASCII);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  3,6: begin
       dlgSave.DefaultExt := 'asm';
       dlgSave.Filter := 'Assembly Listing (*.asm)|*.asm|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         slAsm.SaveToFile(sFileName);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  end;

  FreeAndNil(slAsm);
  Result := iLen;
end;

function TCompileDlg.CompileP1S(): integer;
var
  slAsm: TStringList;
  F: TFileStream;
  sFileName: string;
  iLen: integer;
  cOut: array [0..65538] of byte;
begin
  slAsm := TStringList.Create();
  iLen := 0;
  slAsm.Add('                ORG ' + IntToStr(StrToIntDef(txtCompileAddress.Text,0)));
  if cboOutputType.ItemIndex > 3 then
  begin
    // Compile Song Data Only
    P1S_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end
  else
  begin
    slAsm.Add('BORDER_COL:     EQU  $' + IntToStr(cboBorder.ItemIndex));
    slAsm.Add('');

    if optSFXReturnKeypress.Checked then
      P1S_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,1)
    else if optSFXContinuous.Checked then
      P1S_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,3);

    P1S_AddFreqTable(slAsm);
    slAsm.Add('');
    P1S_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end;
  
  case cboOutputType.ItemIndex of
  0: begin
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         // Create an empty file
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         if optSFXReturnKeypress.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),1,'P1S')
         else if optSFXContinuous.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),3,'P1S');

         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  1,4: begin
       // TAP File Code Only
       // Create an empty file
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  2,5: begin
       dlgSave.DefaultExt := 'bin';
       dlgSave.Filter := 'Z80 Binary File (*.bin)|*.bin|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         AssembleStringList(slAsm,sFileName,Binary,ASCII);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  3,6: begin
       dlgSave.DefaultExt := 'asm';
       dlgSave.Filter := 'Assembly Listing (*.asm)|*.asm|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         slAsm.SaveToFile(sFileName);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  end;

  FreeAndNil(slAsm);
  Result := iLen;
end;

function TCompileDlg.CompileSVG(): integer;
var
  slAsm: TStringList;
  sFileName: string;
  cOut: array [0..65538] of byte;
  iLen: integer;
  F: TFileStream;
begin
  slAsm := TStringList.Create();
  iLen := 0;
  slAsm.Add('                ORG ' + IntToStr(StrToIntDef(txtCompileAddress.Text,0)));

  if cboOutputType.ItemIndex > 3 then
  begin
    // Compile Song Data Only
    SVG_AddSongData(slAsm,STMainWnd.Song,optLoopAtEnd.Checked,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');    
  end
  else
  begin
    // Player Routine + Song Data
    if optSFXReturnKeypress.Checked then
      SVG_AddPlayerAsm(slAsm,1) // Read Keyboard
    else
      SVG_AddPlayerAsm(slAsm,3); // Ignore keyboard
    slAsm.Add('');
    slAsm.Add('; ************************************************************************');
    slAsm.Add('; * Song data...');
    slAsm.Add('; ************************************************************************');
    slAsm.Add('VECTOR_TABLE_LOC:    EQU $' + Copy(cboVectorTableLoc.Text,3,4));
    slAsm.Add('BORDER_CLR:          EQU $' + IntToStr(cboBorder.ItemIndex));
    slAsm.Add('');
    SVG_AddSongData(slAsm,STMainWnd.Song,optLoopAtEnd.Checked,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end;


  case cboOutputType.ItemIndex of
  0: begin
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         // Create an empty file
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),1,'SVG');
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  1,4: begin
       // TAP File Code Only
       // Create an empty file
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file without BASIC loader
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  2,5: begin
       dlgSave.DefaultExt := 'bin';
       dlgSave.Filter := 'Z80 Binary File (*.bin)|*.bin|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         AssembleStringList(slAsm,sFileName,Binary,ASCII);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  3,6: begin
       dlgSave.DefaultExt := 'asm';
       dlgSave.Filter := 'Assembly Listing (*.asm)|*.asm|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         slAsm.SaveToFile(sFileName);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  end;

  FreeAndNil(slAsm);

  Result := iLen;
end;

function TCompileDlg.CompileRMB(): integer;
var
  slAsm: TStringList;
  F: TFileStream;
  sFileName: string;
  iLen: integer;
  cOut: array [0..65538] of byte;
  iTempo: integer;
begin
  slAsm := TStringList.Create();
  iLen := 0;
  slAsm.Add('                ORG ' + IntToStr(StrToIntDef(txtCompileAddress.Text,0)));

  if cboOutputType.ItemIndex > 3 then
  begin
    // Compile Song Data Only
    RMB_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end
  else
  begin
    if optTMBReturnKeypress.Checked then
      RMB_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,1,STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210)
    else if optTMBAlwaysReturn.Checked then
      RMB_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,2,STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210)
    else if optTMBContinuous.Checked then
      RMB_AddPlayerAsm(slAsm,optLoopAtEnd.Checked,3,STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo * 2 + 210);

    slAsm.Add('');
    slAsm.Add('; *** DATA ***');
    // We must initialise the tempo for the first pattern in the song
    iTempo := 17 - STMainWnd.Song.Pattern[STMainWnd.Song.SongLayout[0]].Tempo;
    if iTempo < 1 then iTempo := 1;
    slAsm.Add('TEMPO:                    DEFB ' + IntToStr(iTempo));
    RMB_AddFreqTable(slAsm);
    slAsm.Add('');
    RMB_AddSongData(slAsm,STMainWnd.Song,cboTranspose.ItemIndex - 12);

    ReadASMTableFile(ExtractFilePath(Application.ExeName) + '\z80.tab');
  end;

  case cboOutputType.ItemIndex of
  0: begin
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         // Create an empty file
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         if optTMBReturnKeypress.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),1,'RMB')
         else if optTMBAlwaysReturn.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),2,'RMB')
         else if optTMBContinuous.Checked then
           WriteBASICLoader(sFileName,StrToIntDef(txtCompileAddress.Text,0),3,'RMB');

         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  1,4: begin
       // TAP File Code Only
       // Create an empty file
       dlgSave.DefaultExt := 'tap';
       dlgSave.Filter := 'Spectrum Tape Files (*.tap)|*.tap|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         F := TFileStream.Create(sFileName,fmCreate or fmShareDenyWrite);
         FreeAndNil(F);
         // TAP file with BASIC loader
         iLen := AssembleStringListMem(slAsm,cOut,ASCII);
         WriteCODEHeader(sFileName,iLen,StrToIntDef(txtCompileAddress.Text,0),STMainWnd.Song.SongTitle);
         F := TFileStream.Create(sFileName,fmOpenWrite or fmShareDenyWrite);
         F.Seek(0,soFromEnd);

         cOut[65536] := (iLen+2) and $FF;
         cOut[65537] := (iLen+2) shr 8;
         cOut[65538] := $FF;
         F.Write(cOut[65536],3); // $FF byte marks the start of the code data block
         F.Write(cOut[0],iLen);
         cOut[iLen] := $FF;
         cOut[65536] := GetXORCheckSum(@cOut[0],iLen+1);
         F.Write(cOut[65536],1);
         FreeAndNil(F);
       end;
     end;
  2,5: begin
       dlgSave.DefaultExt := 'bin';
       dlgSave.Filter := 'Z80 Binary File (*.bin)|*.bin|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         AssembleStringList(slAsm,sFileName,Binary,ASCII);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  3,6: begin
       dlgSave.DefaultExt := 'asm';
       dlgSave.Filter := 'Assembly Listing (*.asm)|*.asm|All Files|*';
       if dlgSave.Execute() then
       begin
         sFileName := dlgSave.FileName;
         slAsm.SaveToFile(sFileName);
         iLen := STO_GetFileSize(sFileName);
       end;
     end;
  end;

  FreeAndNil(slAsm);
  Result := iLen;
end;

end.
