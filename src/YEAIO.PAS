UNIT YEAIO;

INTERFACE

PROCEDURE Comment (X,Y:BYTE; CommText:STRING);
PROCEDURE WriteAT (X,Y:BYTE; CommText:STRING);
PROCEDURE Box(X1, Y1, X2, Y2 : BYTE; BoxFrame : STRING);
PROCEDURE NormBox(X1, Y1, X2, Y2 : BYTE);
PROCEDURE BoxLine(X1, X2, Y : BYTE);
PROCEDURE Wait;
PROCEDURE Get(X,Y,Len:BYTE; VAR Eingabe:STRING);
PROCEDURE NumGet(X,Y,Len:BYTE; VAR Eingabe:STRING; MinSize, MaxSize : LongINT);
FUNCTION  GetYN(Default:BOOLEAN) : BOOLEAN;
FUNCTION  ReadValidKEY(ValidString : STRING) : CHAR;
PROCEDURE Alert(X,Y : BYTE; AlertSTR : STRING);
{$IFNDEF STDIO}
FUNCTION  IsColor : BOOLEAN;
PROCEDURE SetTextColor(Back, Fore : BYTE);
PROCEDURE HideCursor;
PROCEDURE ShowCursor;

TYPE
  ScreenType = ARRAY [0..24, 0..79] OF RECORD
                                         Zeichen  : CHAR;
                                         Attribut : BYTE
                                       END;

VAR
  ScreenPTR     : ^ScreenType;
  ScreenSEG     : WORD;

{$ENDIF}

IMPLEMENTATION

{$IFDEF STDIO}
USES YEASTD, DOS, STDIO;
{$ELSE}
USES YEASTD, DOS, CRT;

VAR
  {$IFDEF DEAD}
  CGAScreen      : ScreenType ABSOLUTE $B800:0000;
  MDAScreen      : ScreenType ABSOLUTE $B000:0000;
  {$ELSE}
  CGAScreen      : ScreenType;
  MDAScreen      : ScreenType;
  {$ENDIF}
{$ENDIF}

PROCEDURE Comment (X,Y : BYTE; CommText : STRING);
BEGIN
  HighVideo;                 {Outputs a highlighted text}
  GotoXY (X,Y);
  Write (CommText);
  LowVideo
END;

PROCEDURE WriteAT (X,Y : BYTE; CommText : STRING);
BEGIN
  GotoXY (X,Y);              {Outputs a text at the given position}
  Write (CommText);
END;

PROCEDURE Box(X1, Y1, X2, Y2 : BYTE; BoxFrame : STRING);
VAR
  Counter : BYTE;
  Filler  : STRING;
BEGIN
  IF Length(BoxFrame) > 7 THEN
  BEGIN
    GotoXY(X1,Y1);
    Write(BoxFrame[1] + Replicate(BoxFrame[2], X2 - X1 - 1) + BoxFrame[3]);
    IF Length(BoxFrame) > 8 THEN
      Filler := BoxFrame[8] + Replicate(BoxFrame[9], X2 - X1 - 1) + BoxFrame[4]
    ELSE
      Filler := BoxFrame[8] + Replicate(#32, X2 - X1 - 1) + BoxFrame[4];
    FOR Counter := Y1 + 1 TO Y2 - 1 DO
    BEGIN
      GotoXY(X1, Counter);
      Write(Filler);
    END;
    GotoXY(X1, Y2);
    Write(BoxFrame[7] + Replicate(BoxFrame[6], X2 - X1 - 1) + BoxFrame[5]);
  END;
END;

PROCEDURE NormBox(X1, Y1, X2, Y2 : BYTE);
BEGIN
  Box(X1, Y1, X2, Y2, 'ÉÍ¸³ÙÄÓº');
END;

PROCEDURE BoxLine(X1, X2, Y : BYTE);
BEGIN
  GotoXY(X1, Y);
  Write('Ç' + Replicate('Ä', X2 - X1 - 1) + '´');
END;

PROCEDURE Wait;
VAR
  ch : CHAR;
BEGIN
  ch := ReadKEY;
END;

PROCEDURE Get(X,Y,Len : BYTE; VAR Eingabe : STRING);
VAR
  AktX      : BYTE;          {A wonderful STRING-Input routine!}
  MomChar   : CHAR;
  INS_Modus : BOOLEAN;
BEGIN
  IF Len < Length(Eingabe) THEN
    Eingabe := Copy(Eingabe,1,Len);
  AktX := X {+Length(Eingabe)};
  INS_Modus := FALSE;
  GotoXY(X,Y);
  Write(Eingabe+' ');
  GotoXY(AktX,Y);
  MomChar := #0;
  WHILE MomChar<>#13 DO
  BEGIN
    MomChar := ReadKEY;
    CASE MomChar OF
      #0      : BEGIN                                          {Special Keys}
                  MomChar := ReadKEY;
                  CASE MomChar OF
                    #71 : AktX := X;                                   {Home}
                    #79 : AktX := X + Length(Eingabe);                  {End}
                    #75 : IF AktX > X THEN                             {Left}
                            Dec(AktX);
                    #77 : IF AktX < X + Length(Eingabe) THEN          {Right}
                            Inc(AktX);
                    #82 : INS_Modus := NOT INS_Modus;                   {Ins}
                    #83 : Delete(Eingabe, (AktX-X+1), 1);               {Del}
            {Eingabe := Copy(Eingabe,1,AktX-X) + Copy(Eingabe,AktX-X+2,Len);}
                  END;
                END;
      #1..#3  : ;                                   {Strip some Garbage}
      ^D      : IF AktX < X + Length(Eingabe) THEN  {CTRL-D Right}
                  Inc(AktX);
      #5..#7  : ;
      #8      : IF AktX > X THEN                    {BackSpace}
                BEGIN
                  Delete(Eingabe, (AktX-X), 1);
                  Dec(AktX);
                END;
      #9..#12 : ;                                   {Strip some other Garbage}

      #13     : ;                       {Do you want a CR in your String????}

      ^S      : IF AktX > X THEN                    {CTRL-S Left}
                  Dec(AktX);
      #22     : INS_Modus := NOT INS_Modus;         {CTRL-V Ins}
      #25     : BEGIN                               {CTRL-Y Kill Line}
                  AktX := X;
                  Eingabe := '';
                  WriteAT(X,Y, Space(Len));
                END;
      #14..#31: ;                                  {Strip some other Garbage}
    ELSE                                                    {All otheChars}
    BEGIN
      IF (Len > Length(Eingabe)) OR (AktX < X+Len) THEN
      BEGIN
        IF INS_Modus AND (Len > Length(Eingabe)) THEN
          Eingabe := Copy(Eingabe,1,AktX-X) + MomChar + Copy(Eingabe,Succ(AktX-X),Len)
        ELSE
          Eingabe := Copy(Eingabe,1,AktX-X) + MomChar + Copy(Eingabe,AktX-X+2,Len);
        Inc(AktX);
      END
    END;
    END;
    GotoXY(X,Y);
    Write(Eingabe+' ');
    GotoXY(AktX,Y)
  END;
END;

PROCEDURE NumGet(X,Y,Len:BYTE; VAR Eingabe:STRING; MinSize, MaxSize : LongINT);
VAR
  AktX      : BYTE;          {A wonderful NUMERIC-Input routine!}
  MomChar   : CHAR;
  INS_Modus : BOOLEAN;
BEGIN
  IF Len < Length(Eingabe) THEN
    Eingabe := Copy(Eingabe,1,Len);
  AktX := X +Length(Eingabe);
  INS_Modus := FALSE;
  WriteAT(X,Y,Space(Len));
  WriteAT(X,Y,Eingabe+' ');
  GotoXY(AktX,Y);
  MomChar := #0;
  WHILE (MomChar <> #27) AND ((MomChar<>#13) OR (Value(Eingabe) < MinSize) OR (Value(Eingabe) > MaxSize)) DO
  BEGIN
    MomChar := ReadKEY;
    CASE MomChar OF
      #0      : BEGIN                                          {Special Keys}
                  MomChar := ReadKEY;
                  CASE MomChar OF
                    #71 : AktX := X;                                   {Home}
                    #79 : AktX := X + Length(Eingabe);                  {End}
                    #75 : IF AktX > X THEN                             {Left}
                            Dec(AktX);
                    #77 : IF AktX < X + Length(Eingabe) THEN          {Right}
                            Inc(AktX);
                    #82 : INS_Modus := NOT INS_Modus;                   {Ins}
                    #83 : Delete(Eingabe, (AktX-X+1), 1);    {Del}
            {Eingabe := Copy(Eingabe,1,AktX-X) + Copy(Eingabe,AktX-X+2,Len);}
                  END;
                END;
      #1..#3  : ;                                   {Strip some Garbage}
      ^D      : IF AktX < X + Length(Eingabe) THEN  {CTRL-D Right}
                  Inc(AktX);
      #5..#7  : ;
      #8      : IF AktX > X THEN                    {BackSpace}
                BEGIN
                  Delete(Eingabe, (AktX-X), 1);
                  Dec(AktX);
                END;
      #9..#12 : ;                                   {Strip some other Garbage}

      #13     : ;                       {Do you want a CR in your String????}

      ^S      : IF AktX > X THEN                    {CTRL-S Left}
                  Dec(AktX);
      #22     : INS_Modus := NOT INS_Modus;         {CTRL-V Ins}
      #25     : BEGIN                               {CTRL-Y Kill Line}
                  AktX := X;
                  Eingabe := '';
                  WriteAT(X,Y, Space(Len));
                END;
      #14..#26: ;                                  {Strip some other Garbage}
      #27     : Eingabe := '';
      #28..#47: ;
      #58..#255:;
    ELSE                                           {All other Chars}
    BEGIN
      IF (Len > Length(Eingabe)) OR (AktX < X+Len) THEN
      BEGIN
        IF INS_Modus AND (Len > Length(Eingabe)) THEN
          Eingabe := Copy(Eingabe,1,AktX-X) + MomChar + Copy(Eingabe,Succ(AktX-X),Len)
        ELSE
          Eingabe := Copy(Eingabe,1,AktX-X) + MomChar + Copy(Eingabe,AktX-X+2,Len);
        Inc(AktX);
      END
    END;
    END;
    GotoXY(X,Y);
    Write(Eingabe+' ');
    GotoXY(AktX,Y)
  END;
END;

FUNCTION  GetYN(Default : BOOLEAN) : BOOLEAN;
VAR
  ch : CHAR;
BEGIN
  ch := ' ';
  WHILE (ch <> 'Y') AND (ch <> 'N') AND (ch <> #13) DO
    ch := UpCase(ReadKEY);
  IF ch = #13 THEN
  BEGIN
    IF Default THEN
      ch := 'Y'
    ELSE
      ch := 'N';
  END;
  Write(ch);
  GetYN := (ch = 'Y');
END;

FUNCTION  ReadValidKEY(ValidString : STRING) : CHAR;
VAR
  ch : CHAR;
BEGIN
  REPEAT
    ch := UpCase(ReadKEY);
  UNTIL (Pos(ch, ValidString) <> 0);
  ReadValidKey := ch;
END;

{$IFNDEF STDIO}
PROCEDURE SetTextColor(Back, Fore : BYTE);
BEGIN
  TextAttr := (Back SHL 4) + Fore;
END;
{$ENDIF}

PROCEDURE Alert(X,Y : BYTE; AlertSTR : STRING);
VAR
  OldColor : BYTE;
  ScrSave  : ARRAY[1..480] OF BYTE;
BEGIN
{$IFNDEF STDIO}
  OldColor := TextAttr;
  Move(ScreenPTR^[Y-1,X-1], ScrSave[1], 2 * (Length(AlertSTR) + 4));
  Move(ScreenPTR^[Y  ,X-1], ScrSave[1 + 2 * (Length(AlertSTR) + 4)],  2 * (Length(AlertSTR) + 4));
  Move(ScreenPTR^[Y+1,X-1], ScrSave[1 + 4 * (Length(AlertSTR) + 4)],  2 * (Length(AlertSTR) + 4));
  IF IsColor THEN
    TextATTR := (Red SHL 4) OR White
  ELSE
    TextATTR := (LightGray SHL 4) OR Black;
  NormBox(X, Y, X + Length(AlertSTR) + 3, Y + 2);
  WriteAT(X + 2, Y + 1, AlertSTR + #7);
  TextATTR := TextATTR OR Blink;
  WriteAT(X + 2, Y, ' Error ');
  Wait;
  Move(ScrSave[1],                              ScreenPTR^[Y-1,X-1], 2 * (Length(AlertSTR) + 4));
  Move(ScrSave[1 + 2 * (Length(AlertSTR) + 4)], ScreenPTR^[Y  ,X-1], 2 * (Length(AlertSTR) + 4));
  Move(ScrSave[1 + 4 * (Length(AlertSTR) + 4)], ScreenPTR^[Y+1,X-1], 2 * (Length(AlertSTR) + 4));
  TextAttr := OldColor;
{$ENDIF}
END;

{$IFNDEF STDIO}

{$IFDEF DEAD}
FUNCTION  IsColor : BOOLEAN;
VAR Regs : REGISTERS;
BEGIN
  Regs.ah := 15;
  Intr($10, Regs);
  IsColor := (Regs.al <> 7);
END;

PROCEDURE HideCursor;
VAR
  Regs : REGISTERS;
BEGIN
  Regs.AH := 1;
  Regs.CX := $FFFF;
  Intr ($10, Regs)
END;

PROCEDURE ShowCursor;
VAR
  Regs : REGISTERS;
BEGIN
  Regs.AH := 1;
  IF IsColor THEN
    Regs.CX := $0607
  ELSE
    Regs.CX := $0B0C;
  Intr ($10, Regs)
END;
{$ELSE}
FUNCTION  IsColor : BOOLEAN;
BEGIN
END;

PROCEDURE HideCursor;
BEGIN
END;

PROCEDURE ShowCursor;
BEGIN
END;
{$ENDIF}

{$ENDIF}

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