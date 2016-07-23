unit GrokUtils;

interface

uses Classes;

function Sto_GetFileSize(const FileName: String): Int64;
procedure GetAppVersionInfo(var sInfo: string);
function StreamGetString(F: TStream; out bEOF: boolean): string;

implementation

uses Windows, SysUtils, Forms;

////////////////////////////////////////////////////////////////
// this function determines the size of a file in bytes, the size
// can be more than 2 GB.
function Sto_GetFileSize(const FileName: String): Int64;
var
  myFile: THandle;
  myFindData: TWin32FindData;
begin
  // set default value
  Result := 0;
  // get the file handle.
  myFile := FindFirstFile(PChar(FileName), myFindData);
  if (myFile <> INVALID_HANDLE_VALUE) then
  begin
    Windows.FindClose(myFile);
    Int64Rec(Result).Lo := myFindData.nFileSizeLow;
    Int64Rec(Result).Hi := myFindData.nFileSizeHigh;
  end;
end;

procedure GetAppVersionInfo(var sInfo: string);
var
  VerInfo: PChar;
  VerInfoSize: integer;
  Discard: cardinal;
  FileVer: PChar;
  DataLen: cardinal;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(Application.ExeName),Discard);
  if VerInfoSize > 0 then
  begin
    VerInfo := AllocMem(VerInfoSize);
    GetFileVersionInfo(PChar(Application.ExeName),0,VerInfoSize,VerInfo);
    VerQueryValue(VerInfo,Pchar('\' + #0),Pointer(FileVer),DataLen);

    sInfo := IntToStr((PVSFIXEDFILEINFO(FileVer).dwFileVersionMS and $FFFF0000) shr 16) + '.' +
             Copy(IntToStr((PVSFIXEDFILEINFO(FileVer).dwFileVersionMS and $FFFF)+100),2,2) + '.' +
             Format('%.2d',[(PVSFIXEDFILEINFO(FileVer).dwFileVersionLS and $FFFF0000) shr 16]);

    FreeMem(VerInfo,VerInfoSize);
  end
  else
    sInfo := '0.0.0.0000';
end;

function StreamGetString(F: TStream; out bEOF: boolean): string;
var
  i, iLen: integer;
  c: array [0..1026] of char;
begin
  bEOF := true;

  iLen := F.Read(c,1024);
  for i := 0 to iLen-2 do begin
    if (c[i] = #13) and (c[i+1] = #10) then
    begin
      F.Seek(-iLen+i+2,soFromCurrent);
      Result := Copy(c,0,i);
      bEOF := false;
      break;
    end;
  end;

  if bEof then
    Result := Copy(c,0,iLen);
end;

end.
