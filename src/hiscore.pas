{$I-}
UNIT HiScore;

INTERFACE

CONST
  MinMajor   : BYTE      =  1    ;
  MinMinor   : BYTE      =    51 ;
  MinVersion : STRING[4] = '1.51';

TYPE
  HeadSType  = RECORD
                 Mark : STRING[6];
                 Name : STRING[30];
                 VerS : STRING[4];
                 VerN : WORD;
                 ChkS : LongINT;
                 ChkZ : LongINT;
               END;

  ScoreRECO  = RECORD
                 Namen : ARRAY [1..2] OF STRING [15];
                 Score : ARRAY [1..2] OF WORD;
                 Datum : LONGINT
               END;

  ScoreType  = ARRAY[1..100] OF ScoreRECO;

VAR
  HighScore : ScoreType;

FUNCTION  ReadHighScoreFile(FileName : STRING) : BYTE;
PROCEDURE WriteHighScoreFile(FileName : STRING; HSFversion : STRING);

IMPLEMENTATION

USES YEAstd;

TYPE
  Scrambler  = ARRAY[1..32,1..125] OF BYTE;
  LoadArray  = ARRAY[1..4000] OF BYTE;

VAR
  Save_n_Load  : Scrambler ABSOLUTE HighScore;
  CheckArr     : LoadArray ABSOLUTE HighScore;

FUNCTION CalcChkSum(ChkArray : LoadARRAY) : LongINT;
VAR
  Counter : WORD;
  ChkSum  : LongINT;
BEGIN
  ChkSum  := 0;
  FOR Counter := 1 TO 4000 DO
    Inc(ChkSum, ChkArray[Counter]);
  CalcChkSum := ChkSum;
END;

FUNCTION  ReadHighScoreFile(FileName : STRING) : BYTE;
VAR
  fi           : FILE;
  i, j         : BYTE;
  BuffArr      : LoadARRAY;
  ArrPtr, err  : WORD;
  HiScoreProt  : HeadSType;
  HiScoreHead  : HeadSType;
BEGIN
  WITH HiScoreProt DO
  BEGIN
    Mark := 'BTRHSF';
    Name := 'The BiTRIS<no_tm> HighScore File';
    VerS := MinVersion;
    VerN := (MinMajor SHL 8) OR MinMinor;
    ChkS := 0;
    ChkZ := 0;
  END;
  Assign (fi, FileName);
  Reset (fi,1);
  IF IOResult <> 0 THEN
  BEGIN
    ReadHighScoreFile := 1;
    FillChar(HighScore, SizeOf(HighScore), #0);
    EXIT;
  END;
  BlockRead (fi, HiScoreHead, SizeOf(HiScoreHead), err);
  BlockRead (fi, BuffArr, 4000, err);
  Close (fi);
  IF (HiScoreHead.VerN < HiScoreProt.VerN) THEN
  BEGIN
    ReadHighScoreFile := 2;
    FillChar(HighScore, SizeOf(HighScore), #0);
    EXIT;
  END;
  IF (err <> 4000) OR
     (HiScoreProt.Mark <> HiScoreHead.Mark) OR
     (HiScoreProt.Name <> HiScoreHead.Name) OR
     (HiScoreHead.VerN <> (Value(Copy(HiScoreHead.VerS,1,1)) SHL 8) OR Value(Copy(HiScoreHead.VerS,3,2))) OR
     (HiScoreHead.ChkS <> CalcChkSum(BuffArr)) THEN
  BEGIN
    ReadHighScoreFile := 3;
    FillChar(HighScore, SizeOf(HighScore), #0);
    EXIT;
  END;
  RandSeed := HiScoreHead.VerN;
  ArrPtr   := 0;
  FOR j := 1 TO 125 DO
    FOR i := 1 TO 32 DO
    BEGIN
      Inc(ArrPtr);
      Save_n_Load[i,j] := BuffArr[ArrPtr];
    END;
  FOR i := 1 TO 100 DO
    WITH HighScore[i] DO
      FOR j := 1 TO 15 DO
      BEGIN
        Namen[1,j] := char (byte (Namen[1,j]) XOR Lo (3*j + i + Random(100)));
        Namen[2,j] := char (byte (Namen[2,j]) XOR Lo (5*j + i + Random(100)))
      END;
  IF CalcChkSum(CheckArr) <> HiScoreHead.ChkZ THEN
  BEGIN
    ReadHighScoreFile := 3;
    FillChar(HighScore, SizeOf(HighScore), #0);
    EXIT;
  END;
  ReadHighScoreFile := 0;
END;

PROCEDURE WriteHighScoreFile(FileName : STRING; HSFversion : STRING);
VAR
  fi           : FILE;
  i, j         : BYTE;
  BuffArr      : LoadARRAY;
  ArrPtr, err  : WORD;
  HiScoreHead  : HeadSType;
BEGIN
  WITH HiScoreHead DO
  BEGIN
    Mark := 'BTRHSF';
    Name := 'The BiTRIS<no_tm> HighScore File';
    VerS := HSFversion;
    VerN := (Value(Copy(HSFversion,1,1)) SHL 8) OR Value(Copy(HSFversion,3,2));
    ChkZ := CalcChkSum(CheckArr);
  END;
  RandSeed := HiScoreHead.VerN;
  FOR i := 1 TO 100 DO
    WITH HighScore[i] DO
      FOR j := 1 TO 15 DO
      BEGIN
        Namen[1,j] := char (byte (Namen[1,j]) XOR Lo (3*j + i + Random(100)));
        Namen[2,j] := char (byte (Namen[2,j]) XOR Lo (5*j + i + Random(100)))
      END;
  ArrPtr := 0;
  FOR j := 1 TO 125 DO
    FOR i := 1 TO 32 DO
    BEGIN
      Inc(ArrPtr);
      BuffArr[ArrPtr] := Save_n_Load[i,j];
    END;
  HiScoreHead.ChkS := CalcChkSum(BuffArr);
  Assign (fi, FileName);
  Rewrite (fi,1);
  BlockWrite (fi, HiScoreHead, SizeOf(HiScoreHead), err);
  BlockWrite (fi, BuffArr, 4000, err);
  Close (fi);
  RandSeed := HiScoreHead.VerN;
  FOR i := 1 TO 100 DO
    WITH HighScore[i] DO
      FOR j := 1 TO 15 DO
      BEGIN
        Namen[1,j] := char (byte (Namen[1,j]) XOR byte ((3*j + i) + Random(100)));
        Namen[2,j] := char (byte (Namen[2,j]) XOR byte ((5*j + i) + Random(100)))
      END;
END;

BEGIN
END.
