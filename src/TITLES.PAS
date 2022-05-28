UNIT TITLES;

INTERFACE

CONST
  UnitNAME    = 'The TITLES   Unit';
  UnitVERSION = '1.00';
  UnitMONTH   = 'Dec';
  UnitYEAR    = '1989';
  UnitAUTHOR  = 'Leo Moll';

PROCEDURE SetVersion(Vrs : STRING);
FUNCTION  GetVersion : STRING;
PROCEDURE SetLicense(Lic : STRING);
FUNCTION  GetLicense : STRING;
PROCEDURE SetRelease(Rls : STRING);
FUNCTION  GetRelease : STRING;
PROCEDURE SetPRGname(Pna : STRING);
FUNCTION  GetPRGname : STRING;
PROCEDURE SetPRGdescription(Pde : STRING);
FUNCTION  GetPRGdescription : STRING;
PROCEDURE SetPRGauthor(Pau : STRING);
FUNCTION  GetPRGauthor : STRING;
PROCEDURE SetVERdescription (Vde : STRING);
FUNCTION  GetVERdescription : STRING;
PROCEDURE SetVERyear (Vye : STRING);
FUNCTION  GetVERyear : STRING;
PROCEDURE SetBUGreporter (Bre : STRING);
FUNCTION  GetBUGreporter : STRING;
PROCEDURE CopyRight;
PROCEDURE ShortCopyRight(Y : BYTE);
PROCEDURE ShortDescription(Y : BYTE);
PROCEDURE SetColorMode(How : BOOLEAN);
PROCEDURE PostCard(ExitError : BYTE);

IMPLEMENTATION

{$IFDEF STDIO}
USES YEASTD, STDIO;
{$ELSE}
USES YEASTD, CRT, YEAIO;
{$ENDIF}

VAR
  Version        : STRING[20];
  License        : STRING[50];
  Release        : STRING[20];
  PRGname        : STRING[8];
  PRGdescription : STRING[70];
  PRGauthor      : STRING[50];
  VERdescription : STRING[20];
  VERyear        : STRING[4];
  BUGreporter    : STRING[50];
  ColorMode      : BOOLEAN;
  Spaces         : STRING;

CONST
  ON  = TRUE;
  OFF = FALSE;

{$IFNDEF DEAD}
PROCEDURE SetTextColor(c1 : BYTE; c2 : BYTE);
BEGIN
  TextColor(c1);
  TextBackground(c2);
END;
{$ENDIF}

PROCEDURE CopyRight;
BEGIN                        {Displays the "Copyright" of this program}
  ClrScr;
  TextColor (White);
  WriteLn('The ', PRGname, ' ', PRGdescription, ', v', Version);
  WriteLn(VERdescription, ' version. Written ', VERyear, ' by ', PRGauthor);
  TextColor (LightGray);
  WriteLn('Please send bug reports to ', BUGreporter);
  WriteLn('This version is ', License, ' - Released ',Release);
  WriteLn
END;


PROCEDURE PostCard(ExitError : BYTE);
BEGIN                        {What would you expect this to do?}
  SetTextColor (Black, White);
  WriteLn(#13#10, '*** Have you sent a postcard to the Author ??!!',#13#10#10);
  Write('Remember: ');
  HighVideo;
  WriteLn(Copy(PRGauthor, 1, Pos(',', PRGauthor)-1));
  WriteLn('          Zieglersteraáe 11');
  WriteLn('          D-5100 Aachen');
  WriteLn('          West Germany');
  WriteLn;
  LowVideo;
  Halt(ExitError)
END;

PROCEDURE SetVersion(Vrs : STRING);
BEGIN
  Version := Vrs;
END;

FUNCTION GetVersion : STRING;
BEGIN
  GetVersion := Version;
END;

PROCEDURE SetLicense(Lic : STRING);
BEGIN
  License := Lic;
END;

FUNCTION GetLicense : STRING;
BEGIN
  GetLicense := License;
END;

PROCEDURE SetRelease(Rls : STRING);
BEGIN
  Release := Rls;
END;

FUNCTION GetRelease : STRING;
BEGIN
  GetRelease := Release;
END;

PROCEDURE SetPRGname(Pna : STRING);
BEGIN
  PRGname := Pna;
END;

FUNCTION GetPRGname : STRING;
BEGIN
  GetPRGname := PRGname;
END;

PROCEDURE SetPRGdescription(Pde : STRING);
BEGIN
  PRGdescription := Pde;
END;

FUNCTION GetPRGdescription : STRING;
BEGIN
  GetPRGdescription := PRGdescription;
END;

PROCEDURE SetPRGauthor(Pau : STRING);
BEGIN
  PRGauthor := Pau;
END;

FUNCTION GetPRGauthor : STRING;
BEGIN
  GetPRGauthor := PRGauthor;
END;

PROCEDURE SetVERdescription(Vde : STRING);
BEGIN
  VERdescription := Vde;
END;

FUNCTION GetVERdescription : STRING;
BEGIN
  GetVERdescription := VERdescription;
END;

PROCEDURE SetVERyear(Vye : STRING);
BEGIN
  VERyear := Vye;
END;

FUNCTION GetVERyear : STRING;
BEGIN
  GetVERyear := VERyear;
END;

PROCEDURE SetBUGreporter(Bre : STRING);
BEGIN
  BUGreporter := Bre;
END;

FUNCTION GetBUGreporter : STRING;
BEGIN
  GetBUGreporter := BUGreporter;
END;

PROCEDURE ShortCopyRight(Y : BYTE);
VAR
  TextLen : BYTE;
BEGIN
  TextLen := Length(PRGname) + 22 + Pos(',', PRGauthor) + Length(Version);
  GotoXY(1,Y);
  IF ColorMode THEN
    SetTextColor(Blue, White)
  ELSE
    SetTextColor(LightGray, Black);
  Write(PRGname);
  Spaces[0] := Char((80 - TextLen) DIV 2);
  Write(Spaces);
  IF ColorMode THEN
    TextColor(LightCyan);
  Write('Copyright (C) ', VERyear, ' by ', Copy(PRGauthor, 1, Pos(',', PRGauthor) - 1));
  IF ((80 - TextLen) AND $01) <> 0 THEN
    Inc(Spaces[0]);
  Write(Spaces);
  IF ColorMode THEN
    TextColor(White);
  Write('v', Version);
END;

PROCEDURE ShortDescription(Y : BYTE);
BEGIN
  GotoXY(1,Y);
  IF ColorMode THEN
    SetTextColor(Blue, White)
  ELSE
    SetTextColor(LightGray, Black);
  Write(CenterNorm(PRGdescription, 80));
END;

PROCEDURE SetColorMode(How : BOOLEAN);
BEGIN
  ColorMode := How;
END;

BEGIN
  Version        := '0.00átest';
  License        := 'MILITANTLY PUBLIC DOMAIN!';
  Release        := '01.01.1980';
  PRGname        := 'NONAME';
  PRGdescription := 'Nothing_doing_program';
  PRGauthor      := 'Leo Moll, SysOp of 2:242/2';
  VERdescription := 'Junky';
  VERyear        := '1980';
  BUGreporter    := 'Leo Moll, 2:242/2 YFTN West_Germany';
  ColorMode      := OFF;
  FillChar(Spaces[1], 255, #32);
END.
