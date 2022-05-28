{$A+,B-,D+,E+,F-,I-,L+,N-,O-,R-,S-,V-}
(***************************************************************************)
(*                                                                         *)
(* The MUZAK Unit v1.13 written 1989 by                                    *)
(*                                                                         *)
(* Leo Moll, SysOp 242/2 YFTN Aachen.                                      *)
(*                                                                         *)
(* Please define MUZCOMP for compiling for the MUZAK Compiler              *)
(* Please define BITRIS  for compiling for Jan Egner's BiTRIS<no_tm>       *)
(***************************************************************************)

UNIT Muz;

INTERFACE

{$IFDEF MUZCOMP}
USES YEAIO, YEAstd;
{$ENDIF}

CONST
  ON  : BOOLEAN = TRUE;
  OFF : BOOLEAN = FALSE;

  HYPERFAST    : BYTE = 1;
  FAST         : BYTE = 2;
  NORMAL       : BYTE = 3;
  SLOW         : BYTE = 4;
  SLOWEST      : BYTE = 5;
  HYPERSLOW    : BYTE = 6;

CONST
  UnitNAME    = 'The MUZAK    Unit';
  UnitVERSION = '1.13';
  UnitMONTH   = 'Oct';
  UnitYEAR    = '1989';
  UnitAUTHOR  = 'Leo Moll';

TYPE
  MuzakPhase = RECORD
                 Octave   : BYTE;
                 Note     : BYTE;
                 Duration : WORD;
               END;
  MuzakBASE  = ARRAY[0..2000] OF MuzakPhase;

VAR
  MuzakHEADER : RECORD
                  MUZID   : STRING[9];
                  Version : STRING[4];
                END;

PROCEDURE LinkMuzak(Status : BOOLEAN);
PROCEDURE LoadMuzakFile(FileNAME : STRING);
PROCEDURE LoadMuzakMEMO(InternLength : WORD; VAR InternData);
PROCEDURE SetMuzak(Status : BOOLEAN);
PROCEDURE SetMuzakSpeed(Speed : BYTE);
PROCEDURE ResetMuzak;
PROCEDURE ResumeMuzak;

{$IFDEF MUZCOMP}
PROCEDURE RestartMuzak;

VAR
  MuzakSTART, MuzakEND : WORD;
{$ENDIF}

{$IFNDEF MUZCOMP}
IMPLEMENTATION

USES CRT, DOS;
{$ENDIF}

VAR
  Muzak2Play   : ^MuzakBase;
  MuzakLength  : WORD;
  MuzakFILE    : FILE;
  MuzakPTR     : WORD;
  MuzakCTR     : INTEGER;
  MuzakSpeed   : BYTE;

  LoopStack    : ARRAY[1..10] OF RECORD
                                   Position : WORD;
                                   Turns    : WORD;
                                 END;

  URMregs      : ARRAY[1..15] OF BYTE;

  LoopPosition : BYTE;

CONST
  Notes : ARRAY[1..6, 1..12] OF WORD =
          ((   65,    69,    73,    78,    82,    87,
               92,    98,   104,   110,   116,   123),
           (  131,   138,   146,   155,   164,   174,
              185,   196,   207,   219,   233,   246),
           (  261,   277,   293,   310,   329,   348,
              369,   391,   414,   439,   465,   493),
           (  522,   553,   586,   621,   658,   697,
              738,   782,   829,   878,   930,   985),
           ( 1044,  1106,  1172,  1242,  1315,  1394,
             1476,  1564,  1657,  1756,  1860,  1971),
           ( 2088,  2212,  2344,  2483,  2631,  2787,
             2953,  3128,  3314,  3512,  3720,  3942));

VAR
  OldTickVec : POINTER;
  Muzak      : BOOLEAN;

{$IFDEF MUZCOMP}
IMPLEMENTATION

USES DOS, CRT;

CONST
  RollCounter : BYTE = 1;

PROCEDURE DispSpeed;
CONST
  SpeedNames : ARRAY[1..6] OF STRING[9] = ('HYPERFAST', 'FAST     ', 'NORMAL   ',
                                           'SLOW     ', 'SLOWEST  ', 'HYPERSLOW');
VAR Counter : BYTE;
BEGIN
  FOR Counter := 1 TO 9 DO
  BEGIN
    ScreenPTR^[3,40+Counter].Zeichen  := SpeedNames[MuzakSpeed,Counter];
    ScreenPTR^[3,40+Counter].Attribut := White;
  END;
END;

PROCEDURE DispMuzak;
CONST
  StatusNames : ARRAY[BOOLEAN] OF STRING[4] = ('STOP', 'PLAY');
VAR Counter : BYTE;
BEGIN
  FOR Counter := 1 TO 4 DO
  BEGIN
    ScreenPTR^[3,26+Counter].Zeichen  := StatusNames[Muzak,Counter];
    ScreenPTR^[3,26+Counter].Attribut := White;
  END;
END;

PROCEDURE Roller;
CONST
  RollBar : ARRAY[0..7] OF STRING[16] = ('█'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30,
                                         '▒'#30'█'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30,
                                         '▒'#30'▒'#30'█'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30,
                                         '▒'#30'▒'#30'▒'#30'█'#30'▒'#30'▒'#30'▒'#30'▒'#30,
                                         '▒'#30'▒'#30'▒'#30'▒'#30'█'#30'▒'#30'▒'#30'▒'#30,
                                         '▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'█'#30'▒'#30'▒'#30,
                                         '▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'█'#30'▒'#30,
                                         '▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'▒'#30'█'#30);
VAR
  X, Y : BYTE;
BEGIN
  Inc(RollCounter);
  RollCounter := (RollCounter AND 7);
  Move(RollBar[RollCounter,1], Mem[ScreenSEG:$0270], 12);
END;
{$ENDIF}

PROCEDURE LoadMuzakFile(FileNAME : STRING);
VAR
  Gelesen : WORD;
BEGIN
  Assign (MuzakFILE, FileNAME);
  {$I-}
    Reset (MuzakFILE, 1);
  {$I+}
  IF IOResult <> 0 THEN
  BEGIN
    Muzak       := OFF;
    MuzakLength := 0;
    FillChar(Muzak2Play^, SizeOf(Muzak2Play^), #0);
    {$IFDEF MUZCOMP}
    MuzakSTART  := 1;
    MuzakEND    := 0;
    {$ENDIF}
    EXIT;
  END;
  BlockRead(MuzakFILE, MuzakHEADER, SizeOf(MuzakHEADER), Gelesen);
  IF (Gelesen <> 15) OR (MuzakHEADER.Version > UnitVERSION) THEN
  BEGIN
    Close(MuzakFILE);
    EXIT;
  END;
  Muzak := OFF;
  BlockRead(MuzakFILE, Muzak2Play^, SizeOf(Muzak2Play^), Gelesen);
  MuzakLength := (Gelesen DIV SizeOf(MuzakPhase)) - 1;
  Close(MuzakFILE);
  {$IFDEF MUZCOMP}
  MuzakSTART  := 1;
  MuzakEND    := MuzakLength;
  {$ENDIF}
END;

PROCEDURE LoadMuzakMEMO(InternLength : WORD; VAR InternData);
BEGIN
  MuzakLength := InternLength;
  Dispose(Muzak2Play);
  Muzak2Play  := Addr(InternData);
  {$IFDEF MUZCOMP}
  MuzakSTART  := 1;
  MuzakEND    := MuzakLength;
  {$ENDIF}
END;

PROCEDURE SetMuzak(Status : BOOLEAN);
BEGIN
  Muzak := Status;
  IF NOT Status THEN
    NoSound;
  {$IFDEF MUZCOMP}
  IF Status THEN
    Comment(28,4, 'PLAY')
  ELSE
    Comment(28,4, 'STOP');
  {$ENDIF}
END;

PROCEDURE SetMuzakSpeed(Speed : BYTE);
BEGIN
  MuzakSpeed := Speed;
  {$IFDEF MUZCOMP}
  DispSpeed;
  {$ENDIF}
END;

{$IFDEF MUZCOMP}
PROCEDURE PlayMuzak; Interrupt;
LABEL Resume;
VAR
  BuffSTR  : STRING[9];
BEGIN
  IF Muzak THEN
  BEGIN
    IF MuzakCTR = 0 THEN
    BEGIN
      NoSound;
Resume:
      IF MuzakPTR < MuzakEnd THEN
        Inc(MuzakPTR)
      ELSE
        MuzakPTR := MuzakStart;
      Str(MuzakPTR : 4, BuffSTR);
      BuffSTR := BuffSTR[1] + #7 + BuffSTR[2] + #7 +BuffSTR[3] + #7 +BuffSTR[4] + #7;
      Move(BuffSTR[1], Mem[ScreenSEG:$0134], 8);
      MuzakCTR := Muzak2Play^[MuzakPTR].Duration * MuzakSpeed;
      WITH Muzak2Play^[MuzakPTR] DO
        IF Octave > 0 THEN
          Sound (Notes [Octave, Note])
        ELSE
        BEGIN     {Command Parser}
          CASE (Note AND $0F) OF
          00 : BEGIN              {Pause}
                 NoSound;
               END;
          01 : BEGIN              {End of Muzak}
                 Muzak := OFF;
                 NoSound;
                 DispMuzak;
               END;
          02 : BEGIN              {Stack Loop}
                 IF (LoopPosition < 10) THEN
                 BEGIN
                   Inc(LoopPosition);
                   LoopStack[LoopPosition].Position := MuzakPTR;
                   LoopStack[LoopPosition].Turns    := Duration;
                 END;
                 GOTO Resume;
               END;
          03 : BEGIN              {EndLoop}
                 IF (LoopPosition > 0) THEN
                 BEGIN
                   IF LoopStack[LoopPosition].Turns > 0 THEN
                   BEGIN
                     Dec(LoopStack[LoopPosition].Turns);
                     MuzakCTR := 1;
                     MuzakPTR := LoopStack[LoopPosition].Position;
                   END
                   ELSE
                     Dec(LoopPosition);
                 END;
                 GOTO Resume;
               END;
          04 : BEGIN              {Direct Jump}
                 IF Duration = 0 THEN {Go TOP}
                   MuzakPTR := 0
                 ELSE                 {Goto Line (Duration)}
                   IF (Duration > 0) AND (Duration <= MuzakLength) THEN
                     MuzakPTR := Duration - 1;
                 GOTO Resume;
               END;
          05 : BEGIN              {Set Speed}
                 IF (Duration > 0) AND (Duration < 7) THEN
                   MuzakSpeed := Duration;
                 DispSpeed;
                 GOTO Resume;
               END;
          06 : BEGIN              {Set Register}
                 URMregs[(Note SHR 4)] := Duration;
                 GOTO Resume;
               END;
          07 : BEGIN              {Inc Register}
                 Inc(URMregs[(Note SHR 4)]);
                 GOTO Resume;
               END;
          08 : BEGIN              {Dec Register}
                 Dec(URMregs[(Note SHR 4)]);
                 GOTO Resume;
               END;
          09 : BEGIN              {On Zero JMP}
                 IF URMregs[(Note SHR 4)] = 0 THEN
                   MuzakPTR := Duration - 1;
                 GOTO Resume;
               END;
          10 : BEGIN              {On NOT Zero JMP}
                 IF URMregs[(Note SHR 4)] <> 0 THEN
                   MuzakPTR := Duration - 1;
                 GOTO Resume;
               END;
          END;
      END;
    END;
    Dec(MuzakCTR);
  END
  ELSE
    NoSound;
  Roller;
END;
{$ENDIF}

{$IFNDEF MUZCOMP}
PROCEDURE PlayMuzak; Interrupt;
LABEL Resume;
BEGIN
  IF Muzak THEN
  BEGIN
    IF MuzakCTR = 0 THEN
    BEGIN
      NoSound;
Resume:
      IF MuzakPTR < MuzakLength THEN
        Inc(MuzakPTR)
      ELSE
        MuzakPTR := 1;
      MuzakCTR := Muzak2Play^[MuzakPTR].Duration * MuzakSpeed;
      WITH Muzak2Play^[MuzakPTR] DO
        IF Octave > 0 THEN
          Sound (Notes [Octave, Note])
        ELSE
        BEGIN     {Command Parser}
          CASE (Note AND $0F) OF
          00 : BEGIN              {Pause}
                 NoSound;
               END;
          01 : BEGIN              {End of Muzak}
                 NoSound;
                 Muzak := FALSE;
               END;
          02 : BEGIN              {Stack Loop}
                 IF (LoopPosition < 10) THEN
                 BEGIN
                   Inc(LoopPosition);
                   LoopStack[LoopPosition].Position := MuzakPTR;
                   LoopStack[LoopPosition].Turns    := Duration;
                 END;
                 GOTO Resume;
               END;
          03 : BEGIN              {EndLoop}
                 IF (LoopPosition > 0) THEN
                 BEGIN
                   IF LoopStack[LoopPosition].Turns > 0 THEN
                   BEGIN
                     Dec(LoopStack[LoopPosition].Turns);
                     MuzakCTR := 1;
                     MuzakPTR := LoopStack[LoopPosition].Position;
                   END
                   ELSE
                     Dec(LoopPosition);
                 END;
                 GOTO Resume;
               END;
          04 : BEGIN              {Direct Jump}
                 IF Duration = 0 THEN {Go TOP}
                   MuzakPTR := 0
                 ELSE                 {Goto Line (Duration)}
                   IF (Duration > 0) AND (Duration <= MuzakLength) THEN
                     MuzakPTR := Duration - 1;
                 GOTO Resume;
               END;
          05 : BEGIN              {Set Speed}
                 IF (Duration > 0) AND (Duration < 7) THEN
                   MuzakSpeed := Duration;
                 GOTO Resume;
               END;
          06 : BEGIN              {Set Register}
                 URMregs[(Note SHR 4)] := Duration;
                 GOTO Resume;
               END;
          07 : BEGIN              {Inc Register}
                 Inc(URMregs[(Note SHR 4)]);
                 GOTO Resume;
               END;
          08 : BEGIN              {Dec Register}
                 Dec(URMregs[(Note SHR 4)]);
                 GOTO Resume;
               END;
          09 : BEGIN              {On Zero JMP}
                 IF URMregs[(Note SHR 4)] = 0 THEN
                   MuzakPTR := Duration - 1;
                 GOTO Resume;
               END;
          10 : BEGIN              {On NOT Zero JMP}
                 IF URMregs[(Note SHR 4)] <> 0 THEN
                   MuzakPTR := Duration - 1;
                 GOTO Resume;
               END;
          END;
      END;
    END;
    Dec(MuzakCTR);
  END
  ELSE
    NoSound;
  {$IFNDEF BITRIS}
  Inline($9C/                 {PUSHF}
         $FF/$1E/OldTickVec); {CALL OldTickVec}
  {$ENDIF}
END;
{$ENDIF}

{$IFNDEF MUZCOMP}
PROCEDURE ResetMuzak;
BEGIN
  MuzakPTR     := 0;
  MuzakCTR     := 0;
  MuzakSpeed   := NORMAL;
  LoopPosition := 0;
  FillChar(LoopStack, SizeOf(LoopStack), #0);
END;
{$ENDIF}

{$IFDEF MUZCOMP}
PROCEDURE ResetMuzak;
BEGIN
  SetMuzak(OFF);
  MuzakSTART   := 1;
  MuzakEND     := MuzakLength;
  MuzakPTR     := 0;
  MuzakCTR     := 0;
  SetMuzakSpeed(NORMAL);
  WriteAT(75, 2, Strg(MuzakPTR,4));
  WriteAT(46, 2, Strg(MuzakSTART,4));
  WriteAT(58, 2, Strg(MuzakEND,4));
  LoopPosition := 0;
  FillChar(LoopStack, SizeOf(LoopStack), #0);
END;

PROCEDURE RestartMuzak;
BEGIN
  MuzakPTR     := MuzakSTART - 1;
  MuzakCTR     := 0;
  WriteAT(75, 2, Strg(MuzakPTR,4));
  WriteAT(46, 2, Strg(MuzakSTART,4));
  WriteAT(58, 2, Strg(MuzakEND,4));
  LoopPosition := 0;
  FillChar(LoopStack, SizeOf(LoopStack), #0);
END;
{$ENDIF}

PROCEDURE ResumeMuzak;
BEGIN
  IF Muzak THEN
    WITH Muzak2Play^[MuzakPTR] DO
      IF Octave > 0 THEN
        Sound (Notes [Octave, Note])
      ELSE
        NoSound;
END;

PROCEDURE LinkMuzak(Status : BOOLEAN);
BEGIN
  IF Status THEN
  BEGIN
    IF OldTickVec = NIL THEN
    BEGIN
      {$IFNDEF MUZCOMP}
      ResetMuzak;
      {$ENDIF}

      {$IFDEF DEAD}
      Inline($FA);
      GetIntVec($1C, OldTickVec);
      SetIntVec($1C, @PlayMuzak);
      Inline($FB);
      {$ENDIF}

    END;
    {$IFDEF MUZCOMP}
    Comment(9,4, 'LINKED  ');
    {$ENDIF}
  END
  ELSE
  BEGIN
    IF OldTickVec <> NIL THEN
    BEGIN
      {$IFDEF DEAD}
      Inline($FA);
      SetIntVec($1C, OldTickVec);
      Inline($FB);
      {$ENDIF}
      OldTickVec := NIL;
    END;
    {$IFDEF MUZCOMP}
    Comment(9,4, 'UNLINKED');
    {$ENDIF}
  END;
END;

BEGIN
  OldTickVec  := NIL;
  Muzak       := FALSE;
  MuzakLength := 0;
  {$IFDEF MUZCOMP}
  MuzakEND    := 0;
  MuzakSTART  := 1;
  {$ENDIF}
  ResetMuzak;
  New(Muzak2Play);
  FillChar(Muzak2Play^, SizeOf(Muzak2Play^), #0);
END.


