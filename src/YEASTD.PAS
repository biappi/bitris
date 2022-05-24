UNIT YEASTD;

INTERFACE

{$IFDEF STDIO}
USES DOS, CRT, STDIO;
{$ELSE}
USES DOS, CRT;
{$ENDIF}

CONST
  UnitNAME    = 'The YEAstd   Unit';
{$IFDEF STDIO}
  UnitVERSION = '3.18stdio';
{$ELSE}
  UnitVERSION = '3.18';
{$ENDIF}
  UnitMONTH   = 'Dec';
  UnitYEAR    = '1989';
  UnitAUTHOR  = 'Leo Moll';

CONST
  LF        = #10;
  FF        = #12;
  CR        = #13;
  ON        = TRUE;
  OFF       = FALSE;

{$IFNDEF STDIO}
TYPE
  ScreenType = ARRAY [0..24, 0..79] OF RECORD
                                         Zeichen  : CHAR;
                                         Attribut : BYTE
                                       END;

VAR
  ScreenPTR     : ^ScreenType;
  ScreenSEG     : WORD;

{$ENDIF}

FUNCTION  LoCase(ch : CHAR) : CHAR;
FUNCTION  Upper (InputString:STRING):STRING;
FUNCTION  Lower (InputString:STRING):STRING;
FUNCTION  Replicate(Origin : CHAR; HowMany : BYTE) : STRING;
FUNCTION  Space(Anzahl : BYTE) : STRING;
FUNCTION  Value(Str2Val : STRING) : LONGINT;
FUNCTION  Strg (n : LongINT; len : BYTE) : STRING;
FUNCTION  StrZ (n : LongINT; len : BYTE) : STRING;
FUNCTION  SNorm (Rein : STRING; Laenge : BYTE) : STRING;
FUNCTION  CenterNorm(Rein : STRING; Laenge : BYTE) : STRING;
FUNCTION  LTrim(Str2Trim:STRING):STRING;
FUNCTION  RTrim(Str2Trim:STRING):STRING;
FUNCTION  AllTrim(Str2Trim:STRING):STRING;
FUNCTION  Left (InpuString : STRING; Len : BYTE) : STRING;
FUNCTION  Right(InpuString : STRING; Len : BYTE) : STRING;
FUNCTION  FileExist (FiNam:STRING):BOOLEAN;
FUNCTION  DirExist (FiNam:STRING):BOOLEAN;
PROCEDURE AppendBackSlash (VAR PATH_NAME:STRING);
PROCEDURE StripBackSlash (VAR PATH_NAME:STRING);
FUNCTION  SBSL(PATH_NAME:STRING):STRING;
FUNCTION  ABSL(PATH_NAME:STRING):STRING;
FUNCTION  StripUnderScore(InputString:STRING):STRING;
FUNCTION  AT(SubStr, SeekStr : STRING):BYTE;
FUNCTION  RAT(SubStr, SeekStr : STRING):BYTE;
FUNCTION  StartPath : STRING;
FUNCTION  PathText(FileSpec : STRING) : STRING;
FUNCTION  FileText(FileSpec : STRING) : STRING;
FUNCTION  ExteText(FileSpec : STRING) : STRING;
FUNCTION  Empty(TestString  : STRING) : BOOLEAN;
FUNCTION  C2S(VAR String2Conv) : STRING;
FUNCTION  WildComp(DateiW, DateiI : PathStr) : BOOLEAN;
FUNCTION  Hex(Irgendwas : WORD) : STRING;
FUNCTION  IsColor : BOOLEAN;
FUNCTION  TestDelay : BOOLEAN;
FUNCTION  IsNumLock : BOOLEAN;
PROCEDURE SwapNumLock;
PROCEDURE SetNumLock(How : BOOLEAN);
FUNCTION  IsCapsLock : BOOLEAN;
PROCEDURE SwapCapsLock;
PROCEDURE SetCapsLock(How : BOOLEAN);
FUNCTION  IsScrollLock : BOOLEAN;
PROCEDURE SwapScrollLock;
PROCEDURE SetScrollLock(How : BOOLEAN);
PROCEDURE ClearKeyBuffer;
FUNCTION  StringIIF(Condition : BOOLEAN; S1, S2 : STRING) : STRING;
FUNCTION  IntegerIIF(Condition : BOOLEAN; L1, L2 : LongINT) : LongINT;
PROCEDURE AssignSTDIO;

IMPLEMENTATION

VAR
  FileFound      : SearchRec;
{$IFNDEF STDIO}
  CGAScreen      : ScreenType ABSOLUTE $B800:0000;
  MDAScreen      : ScreenType ABSOLUTE $B000:0000;
{$ENDIF}

FUNCTION LoCase(ch : CHAR) : CHAR;
BEGIN
  IF (ch >= 'A') AND (ch <= 'Z') THEN
    LoCase := Chr(Ord(ch)+32)
  ELSE
    LoCase := ch;
END;

FUNCTION Upper (InputString : STRING) : STRING;
VAR
  Counter   : BYTE;          {Converts a String in UpCase}
BEGIN
  FOR Counter := 1 TO Length (InputString) DO
    InputString[Counter] := UpCase(InputString[Counter]);
  Upper := InputString
END;

FUNCTION Lower (InputString : STRING) : STRING;
VAR
  Counter   : BYTE;          {Converts a String in LoCase}
BEGIN
  FOR Counter := 1 TO Length (InputString) DO
    InputString[Counter] := LoCase(InputString[Counter]);
  Lower := InputString
END;

FUNCTION  Replicate(Origin : CHAR; HowMany : BYTE) : STRING;
VAR
  Dummy : STRING;
BEGIN
  Dummy[0] := Chr(HowMany);
  FillChar (Dummy[1], HowMany, Origin);
  Replicate := Dummy;
END;

FUNCTION  Space(Anzahl : BYTE) : STRING;
VAR Dummy : STRING;
BEGIN
  Dummy[0] := Chr(Anzahl);
  FillChar (Dummy[1], Anzahl, #32);
  Space := Dummy
END;

FUNCTION  CenterNorm(Rein : STRING; Laenge : BYTE) : STRING;
VAR
  Dummy : STRING;
BEGIN
  Dummy[0] := Char(Laenge);
  FillChar (Dummy[1], Laenge, #32);
  IF Length(Rein) <= Laenge THEN
    Move(Rein[1], Dummy[(Laenge - Length(Rein)) DIV 2], Length(Rein));
  CenterNorm := Dummy;
END;

FUNCTION  Value(Str2Val : STRING) : LONGINT;
VAR
  NumBuff : LONGINT;
  ErrBuff : INTEGER;
BEGIN
  NumBuff := 0;
  Val (Str2Val, NumBuff, ErrBuff);
  IF ErrBuff <> 0 THEN
    NumBuff := 0;
  Value := NumBuff;
END;

FUNCTION Strg (n : LongINT; len : BYTE) : STRING;
VAR
  Dummy : STRING;
BEGIN
  Str (n:20, Dummy);
  Strg := Copy(Dummy, 21 - len, len);
END;

FUNCTION StrZ (n : LongINT; len : BYTE) : STRING;
VAR
  Dummy : STRING;
BEGIN
  Str (n, Dummy);
  Dummy := Replicate('0', 20 - Length(Dummy)) + Dummy;
  StrZ := Copy(Dummy, 21 - len, len);
END;

FUNCTION SNorm (Rein : STRING; Laenge : BYTE) : STRING;
VAR
  Raus : STRING;
BEGIN
  FillChar (Raus[1], Laenge, ' ');
  Raus := Rein;
  Raus [0] := char (Laenge);
  SNorm := Raus
END;

FUNCTION LTrim(Str2Trim : STRING) : STRING;
VAR
  PosPtr : BYTE;
BEGIN
  PosPtr := 1;
  WHILE (Str2Trim[PosPtr] = ' ') AND (PosPtr < Length(Str2Trim)) DO
    Inc(PosPtr);
  LTrim := Copy(Str2Trim, PosPtr, 100)
END;

FUNCTION RTrim(Str2Trim : STRING) : STRING;
VAR
  PosPtr : BYTE;
BEGIN
  PosPtr := Length(Str2Trim);
  WHILE (Str2Trim[PosPtr] = ' ') AND (PosPtr > 0) DO
    Dec(PosPtr);
  RTrim := Copy(Str2Trim, 1, PosPtr)
END;

FUNCTION AllTrim(Str2Trim : STRING) : STRING;
VAR
  PosPtr : BYTE;
BEGIN
  PosPtr := Length(Str2Trim);
  WHILE (Str2Trim[PosPtr] = ' ') AND (PosPtr > 0) DO
    Dec(PosPtr);
  Str2Trim := Copy(Str2Trim, 1, PosPtr);
  PosPtr := 1;
  WHILE (Str2Trim[PosPtr] = ' ') AND (PosPtr < Length(Str2Trim)) DO
    Inc(PosPtr);
  AllTrim := Copy(Str2Trim, PosPtr, 100)
END;

FUNCTION  Left (InpuString : STRING; Len : BYTE) : STRING;
BEGIN
  Left := Copy(InpuString, 1, Len);
END;

FUNCTION  Right(InpuString : STRING; Len : BYTE) : STRING;
BEGIN
  Right := Copy(InpuString, Length(InpuString) - Len, Len);
END;

FUNCTION FileExist (FiNam : STRING) : BOOLEAN;
BEGIN                        {Checks existence of a file}
  FindFirst (FiNam, Archive OR Hidden OR ReadOnly,FileFound);
  FileExist := (DosError = 0)
END;

FUNCTION DirExist (FiNam : STRING) : BOOLEAN;
VAR
  T1, T2, T3 : STRING;
BEGIN                        {Check existence of a directory}
  IF (
       (Finam = '\')
     OR
       ((Right (Finam, 2) = ':\') AND (Length (FiNam) = 3))
     ) THEN
  BEGIN
    DirExist := TRUE;
    EXIT;
  END;
  StripBackSlash(FiNam);
  FSplit (FiNam, T1, T2, T3);
  FindFirst (SBSL(FiNam), Directory, FileFound);
  IF boolean( DosError ) THEN
    DirExist := FALSE
  ELSE
  BEGIN
    WHILE (DosError = 0) DO
    BEGIN
      IF (boolean( FileFound.Attr AND Directory )) THEN
      BEGIN
        DirExist := (Upper (T2 + T3) = FileFound.Name);
        EXIT;
      END;
      FindNext(FileFound);
    END;
    DirExist := FALSE;
  END;
END;


PROCEDURE AppendBackSlash (VAR PATH_NAME : STRING);
BEGIN
  IF PATH_NAME[Length (PATH_NAME)] <> '\' THEN
    PATH_NAME := PATH_NAME + '\';
END;

PROCEDURE StripBackSlash (VAR PATH_NAME : STRING);
BEGIN
  IF PATH_NAME[Length (PATH_NAME)] = '\' THEN
    Dec(PATH_NAME[0]);
END;

FUNCTION  SBSL(PATH_NAME : STRING) : STRING;
BEGIN
  StripBackSlash(PATH_NAME);
  SBSL := PATH_NAME;
END;

FUNCTION  ABSL(PATH_NAME : STRING) : STRING;
BEGIN
  AppendBackSlash(PATH_NAME);
  ABSL := PATH_NAME;
END;

FUNCTION StripUnderScore(InputString : STRING) : STRING;
BEGIN                        {Strips Underscores from a string}
  WHILE Pos('_',InputString) <> 0 DO
    InputString[Pos('_',InputString)] := ' ';
  StripUnderScore := InputString
END;

FUNCTION AT(SubStr, SeekStr : STRING) : BYTE;
BEGIN
  AT := Pos(SubStr, SeekStr);
END;

FUNCTION RAT(SubStr, SeekStr : STRING) : BYTE;
VAR
  ThisPos : BYTE;
BEGIN
  ThisPos := Pos(SubStr, SeekStr);
  IF ThisPos = 0 THEN
    RAT := 0
  ELSE
    RAT := ThisPos + RAT(SubStr, Copy(SeekStr, ThisPos + 1, 255));
END;

FUNCTION  StartPath : STRING;
VAR
  T1, T2, T3 : STRING;
BEGIN
  FSplit(ParamStr(0), T1, T2, T3);
  StartPath := T1
END;

FUNCTION  PathText(FileSpec : STRING) : STRING;
VAR
  T1, T2, T3 : STRING;
BEGIN
  FSplit(FileSpec, T1, T2, T3);
  PathText := T1;
END;

FUNCTION  FileText(FileSpec : STRING) : STRING;
VAR
  T1, T2, T3 : STRING;
BEGIN
  FSplit(FileSpec, T1, T2, T3);
  FileText := T2 + T3
END;

FUNCTION  ExteText(FileSpec : STRING) : STRING;
VAR
  T1, T2, T3 : STRING;
BEGIN
  FSplit(FileSpec, T1, T2, T3);
  ExteText := T3
END;

FUNCTION  Empty(TestString  : STRING) : BOOLEAN;
BEGIN
  Empty := (Length(RTrim(TestString)) = 0)
END;

FUNCTION  C2S(VAR String2Conv) : STRING;
VAR
  BufferStr : STRING;
BEGIN
  Move(String2Conv, BufferStr[1], 255);
  BufferStr[0] := #255;
  BufferStr[0] := Chr(Pos (#0, BufferStr) - 1);
  C2S := BufferStr;
END;

FUNCTION WildComp(DateiW, DateiI : PathStr) : BOOLEAN;
VAR
  NameW, NameI : PathStr;
  ExtW, ExtI   : ExtStr;
  c            : BYTE;

  FUNCTION WComp(VAR WildS, IstS : NameStr) : BOOLEAN;
  VAR
    i : BYTE;
  BEGIN
    i := 1;
    WHILE (i <= Length(WildS)) DO
    BEGIN
      IF WildS[i] = '*' THEN
      BEGIN
        WComp := TRUE;
        EXIT
      END;
      IF (WildS[i] <> '?') AND
         ((Length(IstS) < i) OR (WildS[i] <> IstS[i])) THEN
      BEGIN
        WComp := FALSE;
        EXIT
      END;
      Inc(i);
    END;
    WComp := (i-1 >= Length(IstS));
  END;

BEGIN
  c := Pos('.', DateiW);
  IF c=0 THEN         { automatisch .* anhaengen }
  BEGIN
    NameW := DateiW;
    ExtW  := '*';
  END
  ELSE
  BEGIN
    NameW := Copy(DateiW, 1, c-1);
    ExtW  := Copy(DateiW, c+1, 255);
  END;
  c := Pos('.', DateiI);
  IF c = 0 THEN
    c := Length(DateiI) + 1;
  NameI := Copy(DateiI, 1, c-1);
  ExtI  := Copy(DateiI, c+1, 255);

  WildComp := WComp(NameW, NameI) AND WComp(ExtW, ExtI);
END;

FUNCTION Hex(Irgendwas : WORD) : STRING;
VAR   Buffer : STRING[4];
CONST HexArr : ARRAY[0..$F] OF CHAR = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
BEGIN
  Buffer[0] := #4;
  Buffer[1] := HexArr[((Irgendwas SHR 12) AND $0F)];
  Buffer[2] := HexArr[((Irgendwas SHR  8) AND $0F)];
  Buffer[3] := HexArr[((Irgendwas SHR  4) AND $0F)];
  Buffer[4] := HexArr[((Irgendwas       ) AND $0F)];
  Hex := Buffer;
END;

FUNCTION  IsColor : BOOLEAN;
VAR Regs : REGISTERS;
BEGIN
  Regs.ah := 15;
  Intr($10, Regs);
  IsColor := (Regs.al <> 7);
END;

FUNCTION  TestDelay : BOOLEAN;
VAR
  a, b, c, d1, d2 : WORD;
  result          : BYTE;
BEGIN
  GetTime(a, b, c, d1);
  Delay(42);
  GetTime(a, b, c, d2);
  IF d2 > d1 THEN
    IF (d2 - d1) > 6 THEN
      Testdelay := FALSE
    ELSE
      TestDelay := TRUE
  ELSE
    TestDelay := TRUE;
END;

FUNCTION IsNumLock : BOOLEAN;
BEGIN
  IsNumLock := ((MEM[$0000:$0417] AND 32) <> 0);
END;

PROCEDURE SetNumLock(How : BOOLEAN);
VAR
  DummyB : BOOLEAN;
BEGIN
  IF How THEN
    MEM[$0000:$0417] := MEM[$0000:$0417] OR 32
  ELSE
    MEM[$0000:$0417] := MEM[$0000:$0417] AND 223;
  DummyB := KeyPressed;
END;

PROCEDURE SwapNumLock;
VAR
  DummyB : BOOLEAN;
BEGIN
  MEM[$0000:$0417] := MEM[$0000:$0417] XOR 32;
  DummyB := KeyPressed;
END;

FUNCTION IsCapsLock : BOOLEAN;
BEGIN
  IsCapsLock := ((MEM[$0000:$0417] AND 64) <> 0);
END;

PROCEDURE SetCapsLock(How : BOOLEAN);
VAR
  DummyB : BOOLEAN;
BEGIN
  IF How THEN
    MEM[$0000:$0417] := MEM[$0000:$0417] OR 64
  ELSE
    MEM[$0000:$0417] := MEM[$0000:$0417] AND 191;
  DummyB := KeyPressed;
END;

PROCEDURE SwapCapsLock;
VAR
  DummyB : BOOLEAN;
BEGIN
  MEM[$0000:$0417] := MEM[$0000:$0417] XOR 64;
  DummyB := KeyPressed;
END;

FUNCTION IsScrollLock : BOOLEAN;
BEGIN
  IsScrollLock := ((MEM[$0000:$0417] AND 16) <> 0);
END;

PROCEDURE SetScrollLock(How : BOOLEAN);
VAR
  DummyB : BOOLEAN;
BEGIN
  IF How THEN
    MEM[$0000:$0417] := MEM[$0000:$0417] OR 16
  ELSE
    MEM[$0000:$0417] := MEM[$0000:$0417] AND 239;
  DummyB := KeyPressed;
END;

PROCEDURE SwapScrollLock;
VAR
  DummyB : BOOLEAN;
BEGIN
  MEM[$0000:$0417] := MEM[$0000:$0417] XOR 16;
  DummyB := KeyPressed;
END;

PROCEDURE ClearKeyBuffer;
VAR Regs : REGISTERS;
BEGIN
  Regs.AL := $0F;
  Regs.AH := $0C;
  MsDOS(Regs);
END;

FUNCTION  StringIIF(Condition : BOOLEAN; S1, S2 : STRING) : STRING;
BEGIN
  IF Condition THEN
    StringIIF := S1
  ELSE
    StringIIF := S2;
END;

FUNCTION  IntegerIIF(Condition : BOOLEAN; L1, L2 : LongINT) : LongINT;
BEGIN
  IF Condition THEN
    IntegerIIF := L1
  ELSE
    IntegerIIF := L2;
END;

PROCEDURE AssignSTDIO;
BEGIN
  Assign(INPUT,  '');
  Assign(OUTPUT, '');
  Reset(INPUT);
  Rewrite(OUTPUT);
END;

BEGIN
{$IFNDEF STDIO}
  IF IsColor THEN
  BEGIN
    ScreenPTR := @CGAscreen;
    ScreenSEG := $B800;
  END
  ELSE
  BEGIN
    ScreenPTR := @MDAscreen;
    ScreenSEG := $B000;
  END;
{$ENDIF}
END.

