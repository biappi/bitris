{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}

PROGRAM Bitris;

USES HiScore, Crt, DOS, YEAstd, YEAio, Titles, DATE, MUZ, NOISES, CPU;

TYPE
  BrickType  = ARRAY [0..6, 0..3, 0..3, 0..1] OF ShortINT;

CONST
  Breite = 20;

  Bricks : BrickType =
((((-1,0),(0,0),(1,0),(2,0)),((0,-1),(0,0),(0,1),(0,2)),((-1,0),(0,0),(1,0),(2,0)),((0,-1),(0,0),(0,1),(0,2))),
 (((0,0),(1,0),(0,1),(1,1)),((0,0),(1,0),(0,1),(1,1)),((0,0),(1,0),(0,1),(1,1)),((0,0),(1,0),(0,1),(1,1))),
 (((-1,0),(0,0),(1,0),(0,1)),((0,1),(0,0),(0,-1),(1,0)),((1,0),(0,0),(-1,0),(0,-1)),((0,-1),(0,0),(0,1),(-1,0))),
 (((-1,0),(0,0),(1,0),(1,1)),((0,1),(0,0),(0,-1),(1,-1)),((1,0),(0,0),(-1,0),(-1,-1)),((0,-1),(0,0),(0,1),(-1,1))),
 (((-1,0),(0,0),(1,0),(-1,1)),((0,1),(0,0),(0,-1),(1,1)),((1,0),(0,0),(-1,0),(1,-1)),((0,-1),(0,0),(0,1),(-1,-1))),
 (((-1,0),(0,0),(0,1),(1,1)),((0,1),(0,0),(1,0),(1,-1)),((-1,0),(0,0),(0,1),(1,1)),((0,1),(0,0),(1,0),(1,-1))),
 (((1,0),(0,0),(0,1),(-1,1)),((0,-1),(0,0),(1,0),(1,1)),((1,0),(0,0),(0,1),(-1,1)),((0,-1),(0,0),(1,0),(1,1))));

  GarbageBonus : ARRAY [0..15] OF BYTE =
                 (0, 1, 1, 2, 3, 4, 6, 9, 13, 17, 22, 27, 33, 40, 48, 60);

  MBox         : ARRAY [0..3] OF CHAR = ('░','▒','▓','█');


VAR
  StartLevel    : WORD;
  GarbageLevel  : BYTE;
  DummySTR      : STRING;
  NichtGemogelt : BOOLEAN;
  SpeedDelay    : BYTE;
  OldNumLock    : BOOLEAN;
  OldCapsLock   : BOOLEAN;
  OldScrollLock : BOOLEAN;

VAR
  Mono,
  Separate,
  Muzak,
  AddQuads,
  HighScoreProcess  : BOOLEAN;
  PlayerName1,
  PlayerName2       : STRING[15];
  MuzakFileName     : STRING;
  HighScoreFileName : STRING;

VAR (* Colors *)
  WarningWindow       : ARRAY[1..2] OF BYTE;
  FootLine            : ARRAY[1..1] OF BYTE;
  PausingWindow       : ARRAY[1..3] OF BYTE;
  HighScoreWindow     : ARRAY[1..3] OF BYTE;
  NewHighScore        : ARRAY[1..4] OF BYTE;
  HelpWindow          : ARRAY[1..1] OF BYTE;
  CopyRightWindow     : ARRAY[1..2] OF BYTE;
  OptionsWIndow       : ARRAY[1..6] OF BYTE;
  MenueWindow         : ARRAY[1..3] OF BYTE;
  Raster              : BYTE;
  ScoreBoard          : BYTE;

PROCEDURE SetPRGdefinition;
BEGIN                        {Defines the ProgramHeader}
  SetVersion('1.55');
  SetLicense('SHAREWARE, see BITRIS.DOC');
  SetRelease('29.08.1991');
  SetPRGname('BITRIS');
  SetPRGdescription('two_player_Tetris');
  SetPRGauthor('Jan Egner and Leo Moll, SysOp of 2:242/2');
  SetVERdescription('OFFICIAL');
  SetVERyear('1991');
  SetBUGreporter('Jan Egner or Leo Moll, 2:242/2 YFTN West_Germany');
END;

PROCEDURE SetColorVars(Mode : BOOLEAN);
BEGIN
  IF Mode THEN
  BEGIN
    WarningWindow[1]   := (LightGray SHL 4) + Black;
    WarningWindow[2]   := Blink + (LightGray SHL 4) + Black;
    FootLine[1]        := Blink + (LightGray SHL 4) + Black;
    PausingWindow[1]   := White;
    PausingWindow[2]   := Blink + White;
    PausingWIndow[3]   := LightGray;
    HighScoreWindow[1] := White;
    HighScoreWindow[2] := White;
    HighScoreWindow[3] := LightGray;
    NewHighScore[1]    := LightGray;
    NewHighScore[2]    := Blink + White;
    NewHighScore[3]    := White;
    NewHighScore[4]    := LightGray;
    HelpWindow[1]      := (LightGray SHL 4) + Black;
    CopyRightWindow[1] := (LightGray SHL 4) + Black;
    CopyRightWindow[2] := (LightGray SHL 4) + Black;
    OptionsWindow[1]   := White;
    OptionsWindow[2]   := White;
    OptionsWindow[3]   := White;
    OptionsWindow[4]   := LightGray;
    OptionsWIndow[5]   := White;
    OptionsWIndow[6]   := LightGray;
    MenueWindow[1]     := White;
    MenueWindow[2]     := White;
    MenueWindow[3]     := LightGray;
    Raster             := (Cyan SHL 4) + LightGray;
    ScoreBoard         := White;
  END
  ELSE
  BEGIN
    WarningWindow[1]   := (Red SHL 4) + White;
    WarningWindow[2]   := Blink + (Red SHL 4) + White;
    FootLine[1]        := Blink + (Red SHL 4) + White;
    PausingWindow[1]   := (Red SHL 4) + Yellow;
    PausingWindow[2]   := Blink + (Red SHL 4) + Yellow;
    PausingWIndow[3]   := (Red SHL 4) + LightGray;
    HighScoreWindow[1] := (Red SHL 4) + Yellow;
    HighScoreWindow[2] := (Red SHL 4) + White;
    HighScoreWindow[3] := (Red SHL 4) + LightGray;
    NewHighScore[1]    := (Blue SHL 4) + LightGray;
    NewHighScore[2]    := Blink + (Blue SHL 4) + Yellow;
    NewHighScore[3]    := (Blue SHL 4) + White;
    NewHighScore[4]    := (Blue SHL 4) + LightCyan;
    HelpWindow[1]      := (Magenta SHL 4) + Yellow;
    CopyRightWindow[1] := (Blue SHL 4) + Yellow;
    CopyRightWindow[2] := (Blue SHL 4) + LightCyan;
    OptionsWindow[1]   := (Red SHL 4) + Yellow;
    OptionsWindow[2]   := (Brown SHL 4) + Yellow;
    OptionsWindow[3]   := (Red SHL 4) + White;
    OptionsWindow[4]   := (Red SHL 4) + LightGray;
    OptionsWIndow[5]   := (Brown SHL 4) + White;
    OptionsWIndow[6]   := (Brown SHL 4) + LightGray;
    MenueWindow[1]     := (Blue SHL 4) + White;
    MenueWindow[2]     := (Blue SHL 4) + Yellow;
    MenueWindow[3]     := (Blue SHL 4) + Cyan;
    Raster             := (Cyan SHL 4) + Blue;
    ScoreBoard         := Yellow;
  END;
END;

PROCEDURE LeoClrScr;
VAR
  C, CC : BYTE;
  PROCEDURE ClrChar(dX,dY : BYTE);
  BEGIN
    ScreenPtr^[dY,dX].Zeichen  := ' ';
    ScreenPtr^[dY,dX].Attribut := LightGray;
    Delay(1);
  END;
BEGIN
  FOR C := 0 TO 12 DO
  BEGIN
    FOR CC := C TO (79 - C) DO
      ClrChar(CC, C);
    FOR CC := C TO (24 - C) DO
      ClrChar(79 - C, CC);
    FOR CC := (79 - C) DOWNTO C DO
      ClrChar(CC, (24 - C));
    FOR CC := (24 - C) DOWNTO C DO
      ClrChar(C, CC);
  END;
END;

PROCEDURE LoadHighScoreFile(FiNam : STRING);
VAR
  OldColor     : BYTE;
  ScreenBuffer : ScreenType;
BEGIN
  CASE ReadHighScoreFile(FiNam) OF
  0 : ;
  1 : ;
  2 : BEGIN
        OldColor     := TextAttr;
        ScreenBuffer := ScreenPtr^;
        TextAttr     := WarningWindow[1];
        NormBox( 9,10, 74, 17);
        TextAttr     := WarningWindow[2];
        WriteAT(11,10, ' WARNING ');
        TextAttr     := WarningWindow[1];
        Window(11,12, 73, 16);
        ClrScr;
        WriteLn('I found an old fashioned BITRIS.TTL HighScore File. Because I');
        WriteLn('can process only files newer than version ' + MinVersion + ', I will create');
        WriteLn('a new HighScore File.');
        Write(LF, 'Hit the [ANYKEY] to continue.....');
        ErrorSound;
        Wait;
        Window(1,1,80,25);
        TextAttr := OldColor;
        ScreenPtr^ := ScreenBuffer;
      END;
  3 : BEGIN
        OldColor     := TextAttr;
        ScreenBuffer := ScreenPtr^;
        TextAttr     := WarningWindow[1];
        NormBox( 9,10, 78, 16);
        TextAttr     := WarningWindow[2];
        WriteAT(11,10, ' WARNING ');
        TextAttr     := WarningWindow[1];
        Window(11,12, 77, 15);
        ClrScr;
        WriteLn('Sorry, but the BITRIS.TTL HighScore File appears to be corrupted.');
        WriteLn('To avoid any trouble, it''s better I will create a new one.');
        Write(LF, 'Hit the [ANYKEY] to continue.....');
        ErrorSound;
        Wait;
        Window(1,1,80,25);
        TextAttr := OldColor;
        ScreenPtr^ := ScreenBuffer;
      END;
  END;
END;

PROCEDURE PaintBrick (x, y, BNr, Rot : BYTE; Hin, Weg : BOOLEAN);
TYPE
  BlahType = ARRAY [0..3] OF CHAR;

CONST
  Box          : ARRAY [BOOLEAN] OF CHAR = (' ', '█');

VAR
  i : BYTE;
  bx, by : BYTE;
  ActBrick : ^BlahType;

BEGIN
  IF y > 0 THEN
    FOR i := 0 TO 3 DO
    BEGIN
      by := y + Bricks [BNr, Rot, i, 1];
      bx := 2 * (x + Bricks [BNr, Rot, i, 0]);
      ActBrick := Addr (ScreenPtr^ [by, bx].Zeichen);
      IF Mono THEN
      BEGIN
        IF Hin THEN
          ActBrick^[0] := MBox [BNr AND 3]
        ELSE
          ActBrick^[0] := ' ';
        ActBrick^[2] := ActBrick^[0];
        ActBrick^[1] := char (7 + (BNr AND 4) SHL 1 +
                                  byte (weg) * 48);
        ActBrick^[3] := ActBrick^[1]
      END
      ELSE
      BEGIN
        ActBrick^[0] := Box [Hin];
        ActBrick^[2] := ActBrick^[0];
        ActBrick^[1] := char (BNr + 1 + byte (weg) * 48);
        ActBrick^[3] := ActBrick^[1]
      END;
    END
END;

FUNCTION CheckBrick (x, y, BNr, Rot : BYTE) : BYTE;
VAR
  i     : BYTE;
  Hit,
  Fall  : BOOLEAN;

BEGIN
  Hit := FALSE;
  Fall := TRUE;
  FOR i := 0 TO 3 DO
    IF (ScreenPtr^ [y+Bricks [BNr, Rot, i, 1],
                 2*(x+Bricks [BNr, Rot, i, 0])].Zeichen <> ' ') THEN
    BEGIN
      Hit := TRUE;
      Fall := Fall AND ((ScreenPtr^ [y+Bricks [BNr, Rot, i, 1],
                                  2*(x+Bricks [BNr, Rot, i, 0])].Attribut AND 16)=0)
    END;
  CheckBrick := 2 * byte (Hit) + byte (Fall);
END;

VAR
  x, y,
  Rot, BNr : ARRAY [1..2] OF SHORTINT;
  GameOver : ARRAY [1..2] OF BOOLEAN;
  Counter,
  Level,
  Punkte   : ARRAY [1..2] OF WORD;
  FreeFall : ARRAY [1..2] OF BOOLEAN;

  dummy    : INTEGER;

  xa, Ra,
  i        : WORD;
  j, k     : BYTE;

  ch       : CHAR;

FUNCTION TestDelay : BOOLEAN;
VAR
  a, b, c, d1, d2 : WORD;
  result          : BYTE;
  OldColor        : BYTE;
BEGIN
  GetTime(a, b, c, d1);
  Delay(42);
  GetTime(a, b, c, d2);
  IF d2 > d1 THEN
    IF (d2 - d1) > 7 THEN
    BEGIN
      SetMuzakSpeed(HYPERFAST);
      OldColor := TextAttr;
      TextAttr := FootLine[1];
      WriteAT (32, 25, '[PUNISHING_MODE:ON]');
      TextAttr := OldColor;
      Testdelay := FALSE;
    END
    ELSE
      TestDelay := TRUE
  ELSE
    TestDelay := TRUE;
END;

PROCEDURE KillLine (LineNr, Scorer : BYTE);
VAR
  j    : WORD;
BEGIN
  FOR j := 20-Breite DIV 2 TO 20+Breite DIV 2 - 1 DO
    IF (ScreenPtr^ [LineNr, j*2].Zeichen <= ' ') OR
       (ScreenPtr^ [LineNr, j*2].Attribut AND 16 = 0) THEN
      Exit;
  FOR j := 40-Breite TO 40+Breite-1 DO
  BEGIN
    ScreenPtr^ [LineNr, j].Attribut := 0;
    ScreenPtr^ [LineNr, j].Zeichen := ' ';
  END;
  (*
  FOR j := 800 TO 2300 DO
    Sound (j);
  *)
  FirePhasers(0, 0);
  ResumeMuzak;
  NichtGemogelt := NichtGemogelt AND TestDelay;
  FOR j := 1 TO 2 DO
    IF (j <> Scorer) AND NOT GameOver[j] THEN
      PaintBrick (x[j], y[j], BNr[j], Rot[j], FALSE, FALSE);
  FOR j := LineNr DOWNTO 1 DO
    Move (ScreenPtr^ [j-1, 40-Breite], ScreenPtr^ [j, 40-Breite], Breite*4);
  FOR j := 1 TO 2 DO
    IF (j <> Scorer) AND NOT GameOver[j] THEN
      PaintBrick (x[j], y[j], BNr[j], Rot[j], TRUE, FALSE);
  IF Scorer > 0 THEN
    Inc (Punkte[Scorer], 70-3*LineNr+GarbageBonus[GarbageLevel]);
END;

PROCEDURE AddQuad;
TYPE
  BlahType = ARRAY [0..255] OF CHAR;

VAR
  i,
  Zeile,
  Spalte   : BYTE;
  ActBrick : ^BlahType;

BEGIN
  Zeile := Random (20) + 3;
  Spalte:= 2 * Random (Breite) + 40 - Breite;
  ActBrick := Addr (ScreenPtr^ [Zeile, Spalte].Zeichen);
  IF (ActBrick^ [0]  <> ' ') OR
     (ActBrick^ [160] = ' ') OR
     (byte (ActBrick^ [161]) AND 16 = 0) THEN
    Exit;
  ActBrick^ [0] := '█';
  ActBrick^ [1] := char (128+48+5);
  ActBrick^ [2] := '█';
  ActBrick^ [3] := char (128+48+5);
  Sound (2000);
  Delay (10);
  ResumeMuzak;
  KillLine (Zeile, 0)
END;

PROCEDURE ShowPoints (PlayerNumber : BYTE);
BEGIN
  GotoXY (12 + (PlayerNumber-1) * 61, 3);
  Write (Punkte[PlayerNumber]:5);
  IF Punkte[1] > Punkte[2] THEN
  BEGIN
    ScreenPtr^[3, 18].Attribut := 250;
    ScreenPtr^[3, 61].Attribut := 4
  END
  ELSE IF Punkte[1] < Punkte[2] THEN
  BEGIN
    ScreenPtr^[3, 18].Attribut := 4;
    ScreenPtr^[3, 61].Attribut := 250
  END
  ELSE
  BEGIN
    ScreenPtr^[3, 18].Attribut := 19;
    ScreenPtr^[3, 61].Attribut := 19
  END;

  GotoXY (12 + (PlayerNumber-1) * 61, 5);
  Write (Level[PlayerNumber]:5);
END;

FUNCTION Main : BOOLEAN;
TYPE
  BlahType = ARRAY [0..3] OF CHAR;

VAR
  ScreenBuffer : ScreenType;
  AlteFarbe    : BYTE;
  ActBrick     : ^BlahType;
  PNr          : ARRAY[1..2] OF BYTE;

PROCEDURE NextBricks (How : BOOLEAN);
BEGIN
  PaintBrick ( 4, 11, PNr[1], 1, How, How);
  PaintBrick (34, 11, PNr[2], 1, How, How);
END;

BEGIN
  FOR i := 0 TO 24 DO
    FOR j := 0 TO 79 DO
    IF (j < 40-Breite) OR (j >= 40+Breite) OR (i > 22) THEN
    BEGIN
      ScreenPtr^ [i, j].Zeichen := #8;
      ScreenPtr^ [i, j].Attribut := Raster;
    END
    ELSE
    BEGIN
      ScreenPtr^ [i, j].Zeichen := ' ';
      ScreenPtr^ [i, j].Attribut := 7
    END;
  TextAttr := ScoreBoard;
  WriteAT ( 2, 2, '                 ');
  WriteAT ( 2, 3, '  Score:         ');
  WriteAT ( 2, 4, '                 ');
  WriteAT ( 2, 5, '  Level:         ');
  WriteAT ( 2, 6, '                 ');
  WriteAT (63, 2, '                 ');
  WriteAT (63, 3, '  Score:         ');
  WriteAT (63, 4, '                 ');
  WriteAT (63, 5, '  Level:         ');
  WriteAT (63, 6, '                 ');
{  WriteAT ( 5, 10, '            ');
  WriteAT ( 5, 11, '            ');
  WriteAT ( 5, 12, '            ');
  WriteAT ( 5, 13, '            ');
  WriteAT ( 5, 14, '            ');
  WriteAT ( 5, 15, '            ');
  WriteAT (65, 10, '            ');
  WriteAT (65, 11, '            ');
  WriteAT (65, 12, '            ');
  WriteAT (65, 13, '            ');
  WriteAT (65, 14, '            ');
  WriteAT (65, 15, '            '); }
  GameOver[1] := FALSE;
  GameOver[2] := FALSE;
  Level[1] := StartLevel;
  Level[2] := Level[1];
  Counter[1] := 0;
  Counter[2] := 0;
  IF Separate THEN
    Punkte[1]  := 500
  ELSE
    Punkte[1] := 0;
  Punkte[2]  := Punkte[1];
  ShowPoints (1);
  ShowPoints (2);

  SetNumLock(ON);

  Randomize;

  FOR j := 22 DOWNTO 23-GarbageLevel DO
    FOR k := 20-Breite DIV 2 TO 19 + Breite DIV 2 DO
      IF Random(100) < 40 THEN
      BEGIN
        ActBrick := Addr (ScreenPtr^ [j, k*2].Zeichen);
        IF NOT Mono THEN
        BEGIN
          i := 49 + Random (7);
          ActBrick^ [0] := '█';
          ActBrick^ [1] := char (i);
          ActBrick^ [2] := '█';
          ActBrick^ [3] := char (i)
        END
        ELSE
        BEGIN
          i := Random (4);
          ActBrick^ [0] := MBox [i];
          ActBrick^ [1] := char (48+LightGray);
          ActBrick^ [2] := MBox [i];
          ActBrick^ [3] := char (48+LightGray)
        END
      END;

  IF Separate THEN
  BEGIN
    PaintBrick (20,  4, 0, 1, TRUE, TRUE);
    PaintBrick (20,  8, 0, 1, TRUE, TRUE);
    PaintBrick (20, 12, 0, 1, TRUE, TRUE);
    PaintBrick (20, 16, 0, 1, TRUE, TRUE);
    PaintBrick (20, 20, 0, 1, TRUE, TRUE);
    PaintBrick (19, 20, 0, 1, TRUE, TRUE);
    PaintBrick (19, 16, 0, 1, TRUE, TRUE);
    PaintBrick (19, 12, 0, 1, TRUE, TRUE);
    PaintBrick (19,  8, 0, 1, TRUE, TRUE);
    PaintBrick (19,  4, 0, 1, TRUE, TRUE)
  END;


  y[1] := 0;
  y[2] := 0;

  PNr[1] := Random (7);
  PNr[2] := Random (7);

  REPEAT
    FOR i := 1 TO 2 DO
      IF y[i]=0 THEN
      BEGIN
        {NextBricks (FALSE);}
        x[i] := 20 + (2 * shortint(i) - 3) * Breite DIV 4;
        FreeFall[i] := FALSE;
        BNr[i] := PNr[i];
        PNr[i] := Random (7);
        Rot[i] := 0;
        y[i] := 2;
        {NextBricks (TRUE);}
      END;

    IF AddQuads AND (Random (3000) = 0) THEN
      AddQuad;       (* needs no optimizing, Turbo is FAST enough *)

    IF KeyPressed THEN
    BEGIN
      ch := UpCase (ReadKey);
      IF (ch>='4') AND (ch<='6') AND NOT GameOver[2] THEN
      BEGIN
        xa := x[2]; Ra := Rot[2];
        IF ch='4' THEN Dec (x[2])
        ELSE IF ch='5' THEN Rot[2] := (Rot[2]+1) AND 3
        ELSE Inc (x[2]);
        PaintBrick (xa, y[2], BNr[2], Ra, FALSE, FALSE);
        IF CheckBrick (x[2], y[2], BNr[2], Rot[2]) >= 2 THEN
        BEGIN
          x[2] := xa; Rot[2] := Ra
        END;
        PaintBrick (x[2], y[2], BNr[2], Rot[2], TRUE, FALSE)
      END
      ELSE IF ((ch=#13) OR (ch=#48)) AND NOT GameOver[2] THEN
      BEGIN
        FreeFall[2] := TRUE;
        Dec (Punkte[2], y[2] DIV 2)
      END
      ELSE IF (ch>='F') AND (ch<='H') AND NOT GameOver[1] THEN
      BEGIN
        xa := x[1]; Ra := Rot[1];
        IF ch='F' THEN Dec (x[1])
        ELSE IF ch='G' THEN Rot[1] := (Rot[1]+1) AND 3
        ELSE Inc (x[1]);
        PaintBrick (xa, y[1], BNr[1], Ra, FALSE, FALSE);
        IF CheckBrick (x[1], y[1], BNr[1], Rot[1]) >= 2 THEN
        BEGIN
          x[1] := xa; Rot[1] := Ra
        END;
        PaintBrick (x[1], y[1], BNr[1], Rot[1], TRUE, FALSE)
      END
      ELSE IF ((ch=#32) OR (ch=#09)) AND NOT GameOver[1] THEN
      BEGIN
        FreeFall[1] := TRUE;
        Dec (Punkte[1], y[1] DIV 2)
      END
      ELSE IF ch=#27 THEN
      BEGIN
        SetMuzak(OFF);
        NoSound;
        ScreenBuffer := ScreenPtr^;
        AlteFarbe := TextAttr;
        TextAttr  := PausingWindow[1];
        Box(16, 10, 65, 15, '╒═╕│╛═╘│');
        TextAttr  := PausingWindow[2];
        WriteAT (30, 12, 'G A M E    P A U S E D');
        TextAttr  := PausingWindow[3];
        WriteAT (18, 14, 'Hit [ESC] to quit or any other key to resume.');
        ch := ReadKey;
        ScreenPtr^ := ScreenBuffer;
        TextAttr := AlteFarbe;
        IF ch = #27 THEN
        BEGIN
          Main := FALSE;
          Exit;
        END;
        ResumeMuzak;
        SetMuzak(Muzak);
      END
    END
    ELSE
      IF NichtGemogelt THEN
        Delay (SpeedDelay);

    FOR i := 1 TO 2 DO
      IF ((Counter[i]=0) OR FreeFall[i]) AND NOT GameOver[i] THEN
      BEGIN
        PaintBrick (x[i], y[i], BNr[i], Rot[i], FALSE, FALSE);
        Inc (y[i]);
        IF CheckBrick (x[i], y[i], BNr[i], Rot[i]) = 3 THEN
        BEGIN
          Dec (y[i]);
          FreeFall[3-i] := FreeFall[i];
          FreeFall[i] := FALSE;
        END;

        IF CheckBrick (x[i], y[i], BNr[i], Rot[i]) >= 2 THEN
        BEGIN
          IF y[i]<=3 THEN
            GameOver[i] := TRUE
          ELSE
          BEGIN
            PaintBrick (x[i], y[i]-1, BNr[i], Rot[i], TRUE, TRUE);
            Sound (500+Level[i]*2);
            Delay (20);
            ResumeMuzak;
            IF FreeFall[i] THEN
              Inc (Punkte[i], y[i] DIV 2);
            FreeFall[i] := FALSE;

            Inc (Level[i]);
            IF Level[i] > 400 THEN
              Level[i] := 400;
            Inc (Punkte[i], (2*StartLevel+Level[i]) DIV (28 - 4 * byte(AddQuads)) + 5);
            ShowPoints (i);

            IF y[i] <= 3 THEN
              j := 1
            ELSE
              j := y[i]-3;
            FOR k := j TO y[i]+1 DO
              KillLine (k, i);
            y[i] := 0;
          END;
        END
        ELSE
          PaintBrick (x[i], y[i], BNr[i], Rot[i], TRUE, FALSE);
        Counter[i]:= (450 - Level[i]) SHR 1;
      END
      ELSE IF NOT GameOver[i] THEN
        Dec (Counter[i]);
  UNTIL GameOver[1] AND GameOver[2];
  SetMuzak(OFF);
  TextAttr  := PausingWindow[1];
  Box(28, 11, 53, 15, '╒═╕│╛═╘│');
  TextAttr  := PausingWindow[2];
  WriteAT (32, 13, 'G A M E    O V E R');
  FOR i := 1000 DOWNTO 25 DO
  BEGIN
    Sound (i*4);
    Delay(1)
  END;
  Main := TRUE;
END;

PROCEDURE ShowHighScores(Initial : BYTE);
VAR
  ScreenBuffer : ^ScreenType;
  OldColor     : BYTE;
  Counter      : BYTE;
  KeyHit       : CHAR;

  PROCEDURE Separe(WhY : BYTE);
  BEGIN
    Dec(WhY);
    ScreenPtr^[WhY, 5].Zeichen  := #179;
    ScreenPtr^[WhY, 5].Attribut := TextAttr;
    ScreenPtr^[WhY,22].Zeichen  := #179;
    ScreenPtr^[WhY,22].Attribut := TextAttr;
    ScreenPtr^[WhY,46].Zeichen  := #179;
    ScreenPtr^[WhY,46].Attribut := TextAttr;
    ScreenPtr^[WhY,70].Zeichen  := #179;
    ScreenPtr^[WhY,70].Attribut := TextAttr;
  END;

  PROCEDURE ShowScores(Start : BYTE);
  VAR
    Zaehler : BYTE;
    YPos    : BYTE;
    APos    : BYTE;
  BEGIN
    IF Start > 90 THEN
      Start := 90;
    FOR Zaehler := 1 TO 10 DO
    BEGIN
      YPos :=     9 + Zaehler;
      APos := Start + Zaehler;
      IF APos = 1 THEN
        TextAttr := HighScoreWindow[2]
      ELSE
        TextAttr := HighScoreWindow[3];
      IF APos = Initial THEN
        Inc(TextAttr, Blink);
      WriteAT( 3, YPos, StrZ(APos, 2));
      IF HighScore[APos].Score[1] > 0 THEN
      BEGIN
        WriteAT( 8, YPos, DtoC(HighScore[APos].Datum));
        WriteAt(17, YPos, Copy(TtoC(HighScore[APos].Datum),1,5));
        WriteAT(25, YPos, SNorm(HighScore[APos].Namen[1], 15));
        GotoXY(41, YPos); Write(HighScore[APos].Score[1] : 5);
        WriteAT(49, YPos, SNorm(HighScore[APos].Namen[2], 15));
        GotoXY(65, YPos); Write(HighScore[APos].Score[2] : 5);
        GotoXY(73, YPos); Write(HighScore[APos].Score[1] +
                                HighScore[APos].Score[2] : 6);
      END
      ELSE
      BEGIN
        WriteAT( 8, YPos, '              ');
        WriteAT(25, YPos, '                     ');
        WriteAT(49, YPos, '                     ');
        WriteAT(73, YPos, '      ');
      END;
    END;
  END;

BEGIN
  New(ScreenBuffer);
  ScreenBuffer^ := ScreenPtr^;
  OldColor := TextAttr;
  TextAttr := HighScoreWindow[1];
  NormBox( 1, 5,80,22);
  TextAttr := HighScoreWindow[2];
  WriteAT( 8, 8,'Date/Time        LEFT Player             RIGHT Player            Score');
  WriteAT(15, 6,'***** BITRIS<tm> -- Hall of Fame: The TOP 100 *****');
  WriteAT( 3,21,'Use cursor keys or PgUp/PgDn to scroll. [ESC] returns to MAIN MENU.');
  TextAttr := HighScoreWindow[1];;
  WriteAT( 1, 7, '╠════╤════════════════╤═══════════════════════╤═══════════════════════╤════════╡');
  WriteAT( 1, 9, '╟────┼────────────────┼───────────────────────┼───────────────────────┼────────┤');
  WriteAT( 1,20, '╟────┴────────────────┴───────────────────────┴───────────────────────┴────────┤');
  Separe(8);
  FOR Counter := 10 TO 19 DO
    Separe(Counter);
  IF Initial = 0 THEN
    Counter := 0
  ELSE
    IF Initial < 6 THEN
      Counter := 0
    ELSE
      Counter := Initial - 6;
  REPEAT
    ShowScores(Counter);
    GotoXY(75,21);
    KeyHit := ReadKey;
    IF KeyHit = #0 THEN
    BEGIN
      KeyHit := ReadKey;
      CASE KeyHit OF
        #71 : Counter := 0;              {Home}
        #73 : IF Counter >  9 THEN       {PgUp}
                Dec(Counter, 10)
              ELSE
                Counter := 0;
        #72 : IF Counter >  0 THEN       {Up}
                Dec(Counter);
        #80 : IF Counter < 90 THEN       {Down}
                Inc(Counter);
        #81 : IF Counter < 81 THEN       {PgDn}
                Inc(Counter, 10)
              ELSE
                Counter := 90;
        #79 : Counter := 90;             {End}
      END;
    END;
  UNTIL KeyHit = #27;
  ScreenPtr^ := ScreenBuffer^;
  Dispose(ScreenBuffer);
  TextAttr := OldColor;
END;

PROCEDURE UpdateHighScores (P1, P2 : WORD);
VAR
  i, j : BYTE;
  Y, Mo, D, W,
  H, Mi, S, C : WORD;
  dt           : DateTime;

BEGIN
  FOR i := 1 TO 100 DO
    IF P1+P2 > HighScore[i].Score[1]+HighScore[i].Score[2] THEN
    BEGIN
      FOR j := 100 DOWNTO i+1 DO
        HighScore[j] := HighScore[j-1];
      HighScore[i].Score[1] := P1;
      HighScore[i].Score[2] := P2;
      GetDate (Y, Mo, D, W);
      GetTime (H, Mi, S, C);
      WITH dt DO
      BEGIN
        Year := Y; Month := Mo; Day := D;
        Hour := H; Min   := Mi; Sec := S
      END;
      PackTime (dt, HighScore[i].Datum);
      TextAttr := NewHighScore[1];
      NormBox (16, 7, 65, 18);
      Box(23, 8, 57, 10, '┌─┐│┘─└│');
      TextAttr := NewHighScore[2];
      WriteAT (25, 9, 'C O N G R A T U L A T I O N S !');
      IF i=1 THEN
      BEGIN
        TextAttr := NewHighScore[3];
        WriteAT (24, 11, 'You made an ALL-TIME HIGH SCORE !');
        TextAttr := NewHighScore[1];
      END
      ELSE
      BEGIN
        TextAttr := NewHighScore[1];
        WriteAT (26, 11, 'You made a TOP HUNDRED score !');
      END;
      WriteAT (21, 14, 'LEFT  player''s name:');
      WriteAT (21, 15, 'RIGHT player''s name:');
      TextAttr := NewHighScore[4];
      WriteAT(42, 15, PlayerName2);
      REPEAT
        WriteAT (21, 17, Space(21));
        TextAttr := NewHighScore[4];
        Get (42, 14, 15, PlayerName1);
        Get (42, 15, 15, PlayerName2);
        TextAttr := NewHighScore[3];
        WriteAT (21,17, 'All correct [Y/n] ? ');
      UNTIL GetYN (TRUE);
      IF NOT (Empty(PlayerName1) AND Empty(PlayerName2)) THEN
      BEGIN
        HighScore[i].Namen[1] := PlayerName1;
        HighScore[i].Namen[2] := PlayerName2;
        WriteHighScoreFile(HighScoreFileName, GetVersion);
        TextAttr := FootLine[1];
        WriteAT (26, 25, 'Press [ESC] to continue.....');
        ShowHighScores(i);
      END
      ELSE
        LoadHighScoreFile(HighScoreFileName);
      EXIT
    END
END;

PROCEDURE WriteLnP(TextStr : STRING);
BEGIN
  WriteLn(TextStr);
  Delay(10);
END;

PROCEDURE Help;
VAR
  ScreenBuffer : ^ScreenType;
  OldColor     : BYTE;
BEGIN
  New(ScreenBuffer);
  ScreenBuffer^ := ScreenPtr^;
  OldColor := TextAttr;
  TextAttr := HelpWIndow[1];
  NormBox( 5, 5, 70, 20);
  WriteAT( 7, 5, ' BiTRIS<no_tm> Help Screens ');
  Window(7, 7, 69, 19);
  GotoXY(1,12);
  WriteLnP('BiTRIS<no_tm>, (c) 1989 by Jan Egner & Leo Moll' + LF);
  WriteLnP('BiTRIS is a two player TETRIS<tm>. That means that you have to');
  WriteLnP('play simultaneusly with another player.    There are different');
  WriteLnP('strategies for this game.     You can try a collaboration game');
  WriteLnP('with your partner, or you can try to disturb him.');
  WriteLnP('The HighScoreList contains the player names of the two players');
  WriteLnP('their own scores and the total score.    The list is sorted by');
  WriteLnP('the total score.  A collaboration game gives you more probabi-');
  WriteLnP('lities to make a HighScore.');
  Write(LF + LF + 'Hit the [ANYKEY] to continue.....');
  Wait;
  WriteLnP('');
  WriteLnP('When you start BiTRIS<no_tm> you find yourself in the MAINMENU');
  WriteLnP('and you see the game settings in two colorful windows.        ');
  WriteLnP('The MAINMENU gives you the possibility to change the game set-');
  WriteLnP('tings,  to display the Top 100 HighScoreList,  to display this');
  WriteLnP('help screen or to start the game.                             ');
  WriteLnP('                                                              ');
  WriteLnP('Here a little overwiev of the MAINMENU choices:               ');
  WriteLnP('                                                              ');
  WriteLnP('M)uzak              - Allows you to toggle if you want the an-');
  WriteLnP('                      noying music during the game.           ');
  Write(LF + LF + 'Hit the [ANYKEY] to continue.....');
  Wait;
  WriteLnP('');
  WriteLnP('S)eparator          - Allows you to toggle if you want a sepa-');
  WriteLnP('                      rator bar in the game board. A separator');
  WriteLnP('                      will make the game more interesting.    ');
  WriteLnP(LF + 'R)andom bricks      - Allows you to toggle if you want  BiTRIS');
  WriteLnP('                      to add little evil blocks in  the  board');
  WriteLnP('                      during the game.                        ');
  WriteLnP(LF + 'L)evel              - Allows you to enter the starting gamele-');
  WriteLnP('                      level. The level influences the speed of');
  WriteLnP('                      the game. Remember that a high level gi-');
  WriteLnP('                      ves more points.  (Level : [0..400])    ');
  Write('Hit the [ANYKEY] to continue.....');
  Wait;
  WriteLnP('');
  WriteLnP('G)arbage            - Allows you to enter the level of garbage');
  WriteLnP('                      blocks on the board at the beginning  of');
  WriteLnP('                      the game.   The garbage level represents');
  WriteLnP('                      the initial height of garbage.          ');
  WriteLnP(LF + 'H)elp               - Diplays this Help-Screen.               ');
  WriteLnP(LF + 'T)op 100            - Displays the Top 100 HighScoreList.     ');
  WriteLnP(LF + 'P)lay               - Start the game. Have fun!               ');
  Write(LF + LF + 'Hit the [ANYKEY] to continue.....');
  Wait;
  Window(1, 1, 80, 25);
  ScreenPtr^ := ScreenBuffer^;
  WriteAT(10, 5,'╔════════════════════════════════════════════════════════════════╗');
  WriteAT(10, 6,'║ BiTRIS<no_tm> is a two_player_Tetris<tm>. Here the KeyMapping: ║');
  WriteAT(10, 7,'╟─────────────┬───────────────────────────────────┬──────────────╢');
  WriteAT(10, 8,'║ LEFT PLAYER │            function               │ RIGHT PLAYER ║');
  WriteAT(10, 9,'╟─────────────┼───────────────────────────────────┼──────────────╢');
  WriteAT(10,10,'║    [F]      │    shift brick to the left ('+#27+')    │      [4]     ║');
  WriteAT(10,11,'║    [H]      │    shift brick to the right ('+#26+')   │      [6]     ║');
  WriteAT(10,12,'║    [G]      │     rotate brick clockwise ('+#11+')    │      [5]     ║');
  WriteAT(10,13,'║ [TAB]|[SPC] │           drop brick ('+#31+')          │ [ENTER]|[0]  ║');
  WriteAT(10,14,'╟─────────────┴───────────────────────────────────┴──────────────╢');
  WriteAT(10,15,'║ [ESC] pauses the game. Resume with any other key except [ESC]  ║');
  WriteAT(10,16,'║ [ESC][ESC] terminates the game.                                ║');
  WriteAT(10,17,'║                                                                ║');
  WriteAT(10,18,'║ Hit the [ANYKEY] to return to the MAIN MENU.....               ║');
  WriteAT(10,19,'╚════════════════════════════════════════════════════════════════╝');
  GotoXY(61,18);
  Wait;
  ScreenPtr^ := ScreenBuffer^;
  Dispose(ScreenBuffer);
  TextAttr := OldColor;
END;

PROCEDURE DisplayCopyrights;
VAR
  ScreenBuffer : ^ScreenType;
  OldColor     : BYTE;

BEGIN
  New(ScreenBuffer);
  ScreenBuffer^ := ScreenPtr^;
  OldColor := TextAttr;
  TextAttr := CopyRightWindow[1];
  NormBox( 5, 4, 70, 19);
  WriteAT( 7, 4, ' BiTRIS<no_tm> Copyrights ');
  Window(7, 6, 69, 18);
  GotoXY(1,12);
  TextAttr := CopyRightWindow[2];
  WriteLnP('BiTRIS<no_tm>, v' + GetVersion + '  (c) ' + GetVERyear + ' by Jan Egner & Leo Moll');
  WriteLnP('');
  WriteLnP('USES ' + YEAstd.UnitNAME + ' v' + YEAstd.UnitVERSION + ' (c) ' + YEAstd.UnitMONTH + ' ' + YEAstd.UnitYEAR +
           ' by ' + YEAstd.UnitAUTHOR);
  WriteLnP('     ' + DATE.UnitNAME + ' v' + DATE.UnitVERSION + ' (c) ' + DATE.UnitMONTH + ' ' + DATE.UnitYEAR +
           ' by ' + DATE.UnitAUTHOR);
  WriteLnP('     ' + MUZ.UnitNAME + ' v' + MUZ.UnitVERSION + ' (c) ' + MUZ.UnitMONTH + ' ' + MUZ.UnitYEAR +
           ' by ' + MUZ.UnitAUTHOR);
  WriteLnP('     ' + CPU.UnitNAME + ' v' + CPU.UnitVERSION + ' (c) ' + CPU.UnitMONTH + ' ' + CPU.UnitYEAR +
           ' by ' + CPU.UnitAUTHOR);
  WriteLnP('     ' + NOISES.UnitNAME + ' v' + NOISES.UnitVERSION + ' (c) ' + NOISES.UnitMONTH + ' ' + NOISES.UnitYEAR +
           ' by ' + NOISES.UnitAUTHOR);
  WriteLnP('');
  WriteLnP('This program is NOT Public Domain. Please read carefully the');
  WriteLnP('license agreement in the BITRIS.DOC file. The most important');
  WriteLnP('is that you MUST send a postcard to the authors.');
  Write(LF + 'Hit the [ANYKEY] to continue.....');
  Wait;
  Window(1, 1, 80, 25);
  ScreenPtr^ := ScreenBuffer^;
  Dispose(ScreenBuffer);
  TextAttr := OldColor;
END;

PROCEDURE ShowOptions;
CONST
  YN     : ARRAY [BOOLEAN] OF STRING[3] = ('NO ', 'YES');
BEGIN
  TextAttr := OptionsWindow[1];
  WriteAT (23, 9, YN [Muzak]);
  SetMuzak(Muzak);
  WriteAT (23,10, YN [Separate]);
  WriteAT (23,11, YN [AddQuads]);
  TextAttr := OptionsWindow[2];
  WriteAT(73, 8, Strg(StartLevel,3));
  WriteAT(73, 9, Strg(GarbageLevel,3));
  TextAttr := MenueWindow[1];
END;

PROCEDURE GiveHelp;
BEGIN
  CopyRight;
  WriteLn;
  HighVideo;
  Write('USAGE: ');
  LowVideo;
  WriteLn('BITRIS {option {option....}}',LF);
  WriteLn('       Options:        Behaviour:',LF);
  WriteLn('       /NOCOLOR        Forces Black&White color set');
  WriteLn('       /COLOR          Forces normal color set');
  WriteLn('       /L:nnn          Sets starting speed level to nnn');
  WriteLn('       /G:nn           Sets starting garbage level to nn');
  WriteLn('       /M:OFF          Defaults muzak off');
  WriteLn('       /M:<filename>   Uses an alternate muazk-file');
  WriteLn('       /H:<filename>   Sets an alternate hiscorefile');
  WriteLn('       /PL:name_1      Sets a default name for the left player');
  WriteLn('       /PR:name_2      Sets a default name for the right player');
  WriteLn('                       A playername can be composed by more than one word but');
  WriteLn('                       words MUST be separated by undersores. e.g: /PL:Leo_Moll');
  WriteLn;
  Halt;
END;

PROCEDURE ParseCMDline;
VAR
  Zaehler : BYTE;
  BufferI : INTEGER;
  BufferS : STRING;
BEGIN
  FOR Zaehler := 1 TO ParamCount DO
  BEGIN
    IF Pos(Upper(ParamStr(Zaehler)), '/HELP /? ? -HELP -?') <> 0 THEN
      GiveHelp;
    IF Pos(Upper(ParamStr(Zaehler)), '/NOCOLOR -NOCOLOR') <> 0 THEN
      Mono := TRUE;
    IF Pos(Upper(ParamStr(Zaehler)), '/COLOR -COLOR') <> 0 THEN
      Mono := FALSE;
    IF (Copy(ParamStr(Zaehler),1,1) = '/') OR (Copy(ParamStr(Zaehler),1,1) = '-') THEN
    BEGIN
      IF Copy(Upper(ParamStr(Zaehler)),2,2) = 'L:' THEN
      BEGIN
        BufferI := Value(Copy(Upper(ParamStr(Zaehler)),4,3));
        IF (BufferI >= 0) AND (BufferI <= 400) THEN
          StartLevel := BufferI;
      END;
      IF Copy(Upper(ParamStr(Zaehler)),2,2) = 'G:' THEN
      BEGIN
        BufferI := Value(Copy(Upper(ParamStr(Zaehler)),4,2));
        IF (BufferI >= 0) AND (BufferI <= 15) THEN
          GarbageLevel := BufferI;
      END;
      IF Copy(Upper(ParamStr(Zaehler)),2,2) = 'M:' THEN
      BEGIN
        BufferS := Copy(Upper(ParamStr(Zaehler)),4,80);
        IF BufferS = 'OFF' THEN
          Muzak := FALSE
        ELSE
          IF FileExist(BufferS) THEN
            MuzakFileName := BufferS;
      END;
      IF Copy(Upper(ParamStr(Zaehler)),2,2) = 'H:' THEN
      BEGIN
        BufferS := Copy(Upper(ParamStr(Zaehler)),4,80);
        IF FileExist(BufferS) THEN
          HighScoreFileName := BufferS;
      END;
      IF Copy(Upper(ParamStr(Zaehler)),2,3) = 'PL:' THEN
        PlayerName1 := StripUnderScore(Copy(ParamStr(Zaehler),5,80));
      IF Copy(Upper(ParamStr(Zaehler)),2,3) = 'PR:' THEN
        PlayerName2 := StripUnderScore(Copy(ParamStr(Zaehler),5,80));
    END;
  END;
END;

PROCEDURE InitVars;
BEGIN
  SetPRGDefinition;
  PlayerName1       := '';
  PlayerName2       := '';
  Muzak             := TRUE;
  MuzakFileName     := StartPath + 'BITRIS.MUZ';
  HighScoreFileName := StartPath + 'BITRIS.TTL';
  Mono              := NOT IsColor;
  StartLevel        := 200;
  GarbageLevel      := 0;
  PlayerName1       := '';
  PlayerName2       := '';
  ParseCMDline;
  Muzak             := Muzak AND FileExist(MuzakFileName);
  Separate          := TRUE;
  AddQuads          := TRUE;
  {$IFDEF DEAD}
  IF (CPUtype < 2) AND (ApproxMHZ < 6) THEN
    SpeedDelay := 3
  ELSE
  {$ENDIF}
    SpeedDelay := 4;
  OldNumLock        := IsNumLock;
  OldCapsLock       := IsCapsLock;
  OldScrollLock     := IsScrollLock;
  SetColorVars(Mono);
END;

PROCEDURE OpeningWindow;
VAR
  Zaehler      : BYTE;
  ch           : BOOLEAN;
  OldColor     : BYTE;
  ScreenBuffer : ScreenType;
BEGIN
  OldColor     := TextAttr;
  ScreenBuffer := ScreenPtr^;
  TextAttr := CopyRightWindow[2];
  NormBox(17,10,57,18);
  TextAttr := CopyRightWindow[1];
  WriteAT(34,12, 'BiTRIS');
  WriteAT(31,14, 'Version '+GetVersion);
  WriteAT(23,15, 'Copyright (c) 1989, '+GetVERyear+' by');
  WriteAT(25,16, 'YEAsoft Int. & Jan Egner');
  SetNumLock(OFF);
  SetCapsLock(OFF);
  SetScrollLock(OFF);
  FOR Zaehler := 1 TO 3 DO
  BEGIN
    SwapNumLock;
    Sound(262 SHL 1);
    Delay(200);
    SwapNumLock;
    SwapCapsLock;
    Sound(330 SHL 1);
    Delay(200);
    SwapCapsLock;
    SwapScrollLock;
    Sound(392 SHL 1);
    Delay(200);
    SwapScrollLock;
  END;
  SwapNumLock;
  NoSound;
  ScreenPtr^ := ScreenBuffer;
  TextAttr   := OldColor;
END;

PROCEDURE MainWindow;
BEGIN
  SetTextColor(Black, LightGray);
  CopyRight;
  TextAttr := OptionsWindow[3];
  NormBox(5, 6, 30, 12);
  BoxLine(5,30,8);
  WriteAT(12,7, 'T o g g l e s');
  TextAttr := OptionsWindow[4];
  TextColor(LightGray);
  WriteAT(7, 9, 'Muzak         :');
  WriteAT(7,10, 'Separator     :');
  WriteAT(7,11, 'Random bricks :');
  TextAttr := OptionsWindow[5];
  NormBox(55, 5, 80, 10);
  BoxLine(55,80,7);
  WriteAT(63,6, 'L e v e l s');
  TextAttr := OptionsWindow[6];
  WriteAT(57, 8, 'Starting      :');
  WriteAT(57, 9, 'Garbage       :');
  TextAttr := MenueWindow[1];
  NormBox(20, 14, 76, 24);
  BoxLine(20, 76, 16);
  BoxLine(20, 76, 22);
  TextAttr := MenueWindow[2];
  WriteAT(37, 15, 'BITRIS<no_tm> MAIN MENU');
  WriteAT(22, 17, 'M');
  WriteAT(50, 17, 'H');
  WriteAT(22, 18, 'S');
  WriteAT(50, 18, 'T');
  WriteAT(22, 19, 'R');
  WriteAT(50, 19, 'C');
  WriteAT(22, 20, 'L');
  WriteAT(50, 20, ' ');
  WriteAT(22, 21, 'G');
  WriteAT(50, 21, 'P');
  TextAttr := MenueWindow[3];
  WriteAT(23, 17, ')uzak..........(toggle)');
  WriteAT(51, 17, ')elp..........(display)');
  WriteAT(23, 18, ')eparator......(toggle)');
  WriteAT(51, 18, ')op 100.......(display)');
  WriteAT(23, 19, ')andom bricks..(toggle)');
  WriteAT(51, 19, ')opyrights....(display)');
  WriteAT(23, 20, ')evel...........(level)');
  WriteAT(51, 20, '                       ');
  WriteAT(23, 21, ')arbage.........(level)');
  WriteAT(51, 21, ')lay Bitris! || [ENTER]');
  WriteAT(22, 23, 'Make your choice or hit [ESC] to quit Bitris<tm>: ');
  ShowOptions;
END;

VAR
  key : CHAR;

BEGIN
  CheckBreak := FALSE;

  InitVars;

  MainWindow;

  OpeningWindow;

  LoadMuzakFile(MuzakFileName);
  LoadHighScoreFile(HighScoreFileName);

  REPEAT
    NichtGemogelt := TRUE;
    REPEAT
      ShowOptions;
      GotoXY(72,23);
      key := ReadKey;
      Write(UpCase(KEY));
      CASE UpCase (key) OF
      'M': Muzak := FileExist(StartPATH + 'BITRIS.MUZ') AND NOT Muzak;
      'S': Separate := NOT Separate;
      'R': AddQuads := NOT AddQuads;
      'H': Help;
      'C': DisplayCopyrights;
      'L': BEGIN
             TextAttr := OptionsWindow[5];
             DummySTR := Strg(StartLevel,3);
             NumGet(73, 8, 3, DummySTR, 0, 400);
             StartLevel := Value(DummySTR);
             TextAttr := MenueWindow[1];
           END;
      'G': BEGIN
             Inc(GarbageLevel);
             GarbageLevel := GarbageLevel AND $0F;
           END;
      'T': ShowHighScores(0);
      END;
      WriteAT(72,23,' ');
    UNTIL (UpCase(key) = 'P') OR (key = #27) OR (key = #13);
    IF key = #27 THEN
    BEGIN
      SetTextColor(Black, LightGray);
      ClrScr;
      WriteLn (LF, '**** Hope to see you again soon...', LF);
      SetNumLock(OldNumLock);
      SetCapsLock(OldCapsLock);
      SetScrollLock(OldScrollLock);
      Exit
    END;
    LinkMuzak(ON);
    HighScoreProcess := Main;
    LinkMuzak(OFF);
    IF NichtGemogelt THEN
    BEGIN
      NoSound;
      IF HighScoreProcess THEN
      BEGIN
        TextAttr := FootLine[1];
        WHILE KeyPressed DO
          key := ReadKey;
        WriteAT (27, 25, 'Press [ANYKEY] to continue...');
        REPEAT
        UNTIL KeyPressed;
        key := ReadKey;
        UpdateHighScores (Punkte[1], Punkte[2]);
      END;
    END
    ELSE
    BEGIN
      LeoClrScr;
      SetTextColor(Black, LightGray);
      CopyRight;
      TextAttr := WarningWindow[1];
      NormBox(10, 6, 70, 20);
      BoxLine(10,70,8);
      TextAttr := WarningWindow[2];
      WriteAT(21, 7, 'T h e   R I G H T   p u n i s h i n g !');
      TextAttr := WarningWindow[1];
      WriteAT(12,10, 'I found that you have changed the Speed of the processor');
      WriteAT(12,11, 'clock while playing this game.');
      WriteAT(12,12, 'This is NOT the right way to make a HighScore!');
      WriteAT(33,14, 'WHAT A BLAME !');
      WriteAT(12,16, 'The next time  I find you changing your processor speed,');
      WriteAT(12,17, 'I will format your hard disk !   [GRIN]');
      WriteAT(12,19, 'Toggle back the processor speed and hit [ESC].');
      NoSound;
      ErrorSound;
      REPEAT
        ch := ReadKey;
      UNTIL ch = #27;
    END;
    MainWindow;
  UNTIL FALSE;
END.
