UNIT Date;

INTERFACE

USES DOS;

TYPE
  DATUM = STRING[8];

CONST
  DateVersion : STRING = 'YEAsoft''s date-unit, v1.01';
  UnitNAME    = 'The DATE     Unit';
  UnitVERSION = '1.01';
  UnitMONTH   = 'Jul';
  UnitYEAR    = '1989';
  UnitAUTHOR  = 'Leo Moll';


FUNCTION ValDate(Date2Check : DATUM) : BOOLEAN;
FUNCTION Today : DATUM;
FUNCTION ToNow : DATUM;
FUNCTION DtoC(DateNum : LongINT) : DATUM;
FUNCTION TtoC(TimeNum : LongINT) : DATUM;
FUNCTION TageSeit(Check : DATUM) : INTEGER;
FUNCTION TageBis (Check : DATUM) : INTEGER;
FUNCTION TagesDifferenz (Erstes, Zweites : DATUM) : INTEGER;
FUNCTION CDateLong (D2Conv : DATUM) : STRING;
FUNCTION CDateShort(D2Conv : DATUM) : STRING;
FUNCTION DateSum(Date2Start : DATUM; Days : INTEGER) : DATUM;
FUNCTION DateSub(Date2Start : DATUM; Days : INTEGER) : DATUM;
FUNCTION OpusLOGstring(LogSTAMP : BYTE; PrgMARK, LogTEXT : STRING) : STRING;
FUNCTION QbbsLOGstring(LogText : STRING) : STRING;

IMPLEMENTATION

CONST
  MonatsTage  : ARRAY[FALSE..TRUE,1..12] OF BYTE = ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
                                                    (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));
  MonatsNamen : ARRAY[1..12] OF STRING[15] = ('Januar', 'Februar', 'März',
                                              'April', 'Mai', 'Juni',
                                              'Juli', 'August', 'September',
                                              'Oktober', 'November', 'Dezember');
  KurzNamen   : ARRAY[1..12] OF STRING[3]  = ('Jan', 'Feb', 'Mar', 'Apr',
                                              'May', 'Jun', 'Jul', 'Aug',
                                              'Sep', 'Oct', 'Nov', 'Dec');
  JahresTage  : ARRAY[0..3]  OF WORD = (365, 366, 365, 365);

  MaxDayDate  : WORD = 7304;  (* 31.12.1999 *)

  LogTAGS     : ARRAY[1..6] OF CHAR = (' ', ':', '=', '#', '*', '!');

PROCEDURE DateErr(ErrCode : BYTE; Dte : DATUM);
BEGIN
  CASE ErrCode OF
  1 : WriteLn(#7,'Nicht interpretierbares Datum '+Dte);
  2 : WriteLn(#7,'Ungültiges Datum '+Dte);
  3 : WriteLn(#7,'Ungültige Tageszahl.');
  ELSE
    WriteLn(#7,'Undefined error.');
  END;
  Halt(1);
END;

FUNCTION ValDate(Date2Check : DATUM) : BOOLEAN;
VAR
  Tag, Monat, Jahr : BYTE;
  JUNK             : STRING[2];
  Fehler           : INTEGER;
  SchaltJahr       : BOOLEAN;
  DatErr           : BOOLEAN;
BEGIN
  DatErr := FALSE;
  JUNK := Copy(Date2Check,1,2);
  Val(JUNK, Tag, Fehler);
  DatErr := (Fehler > 0);
  JUNK := Copy(Date2Check,4,2);
  Val(JUNK, Monat, Fehler);
  DatErr := DatErr OR (Fehler > 0);
  JUNK := Copy(Date2Check,7,2);
  Val(JUNK, Jahr, Fehler);
  SchaltJahr := ((Jahr MOD 4) = 0);
  DatErr := DatErr OR (Fehler > 0);
  DatErr := DatErr OR ((Jahr < 80) OR (Jahr > 99));
  DatErr := DatErr OR ((Monat < 1) OR (Monat > 12));
  DatErr := DatErr OR ((Tag < 1) OR (Tag > MonatsTage[SchaltJahr, Monat]));
  ValDate := NOT DatErr;
END;

FUNCTION AbsTage(Heute : DATUM) : WORD;
VAR
  Tag, Monat, Jahr : BYTE;
  JUNK             : STRING[2];
  Fehler           : INTEGER;
  TageZaehler      : WORD;
  Counter          : WORD;
  SchaltJahr       : BOOLEAN;
BEGIN
  JUNK := Copy(Heute,1,2);
  Val(JUNK, Tag, Fehler);
  IF Fehler > 0 THEN
    DateErr(1, Heute);
  JUNK := Copy(Heute,4,2);
  Val(JUNK, Monat, Fehler);
  IF Fehler > 0 THEN
    DateErr(1, Heute);
  JUNK := Copy(Heute,7,2);
  Val(JUNK, Jahr, Fehler);
  IF Fehler > 0 THEN
    DateErr(1, Heute);
  IF (Jahr < 80) OR (Jahr > 99) THEN
    DateErr(2, Heute);
  SchaltJahr := ((Jahr MOD 4) = 0);
  IF (Monat < 1) OR (Monat > 12) THEN
    DateErr(2, Heute);
  IF (Tag < 1) OR (Tag > MonatsTage[SchaltJahr, Monat]) THEN
    DateErr(2, Heute);
  TageZaehler := 0;
  FOR Counter := 1 TO (Jahr-80) DO
    TageZaehler := TageZaehler + JahresTage[(Counter MOD 4)];
  FOR Counter := 1 TO (Monat-1) DO
    TageZaehler := TageZaehler + MonatsTage[SchaltJahr, Counter];
  AbsTage := TageZaehler + Tag - 1;
END;

FUNCTION DatStrZ(Nummer, Stellen:BYTE):DATUM;
VAR
  Puffer  : STRING;
  Counter : BYTE;
BEGIN
  Str(Nummer:Stellen, Puffer);
  FOR Counter := 1 TO Length(Puffer) DO
    IF Puffer[Counter] = ' ' THEN
      Puffer[Counter] := '0';
  DatStrZ := Puffer;
END;

FUNCTION ToDay : DATUM;
VAR Year, Month, Day, DayOfWeek : WORD;
BEGIN
  GetDate(Year, Month, Day, DayOfWeek);
  Year := Year - 1900;
  ToDay := DatStrZ(Day, 2) + '.' + DatStrZ(Month, 2) + '.' + DatStrZ(Year, 2);
END;

FUNCTION ToNow : DATUM;
VAR Hour, Minute, Second, SecHun : WORD;
BEGIN
  GetTime(Hour, Minute, Second, SecHun);
  ToNow := DatStrZ(Hour, 2) + ':' + DatStrZ(Minute, 2) + ':' + DatStrZ(Second, 2);
END;

FUNCTION DtoC(DateNum : LongINT) : DATUM;
VAR Buffer : DateTime;
BEGIN
  UnpackTime(DateNum, Buffer);
  Buffer.Year := Buffer.Year - 1900;
  DtoC := DatStrZ(Buffer.Day, 2) + '.' + DatStrZ(Buffer.Month, 2) + '.' + DatStrZ(Buffer.Year, 2);
END;

FUNCTION TtoC(TimeNum : LongINT) : DATUM;
VAR Buffer : DateTime;
BEGIN
  UnpackTime(TimeNum, Buffer);
  TtoC := DatStrZ(Buffer.Hour, 2) + '.' + DatStrZ(Buffer.Min, 2) + '.' + DatStrZ(Buffer.Sec, 2);
END;

FUNCTION TageSeit(Check : DATUM) : INTEGER;
VAR Heute, DerTag : INTEGER;
BEGIN
  Heute  := AbsTage(Today);
  DerTag := AbsTage(Check);
  TageSeit := Heute - DerTag
END;

FUNCTION TageBis (Check : DATUM) : INTEGER;
BEGIN
  TageBis := - TageSeit(Check);
END;

FUNCTION TagesDifferenz (Erstes, Zweites : DATUM) : INTEGER;
VAR ET, ZT : INTEGER;
BEGIN
  ET := AbsTage(Erstes);
  ZT := AbsTage(Zweites);
  TagesDifferenz := ET - ZT
END;

FUNCTION CDateLong (D2Conv : DATUM) : STRING;
VAR RetString, JUNK : STRING;
    Monat, Fehler   : INTEGER;
BEGIN
  IF ValDate(D2Conv) THEN
  BEGIN
    RetString := Copy(D2Conv,1,2);
    JUNK := Copy(D2Conv,4,2);
    Val(JUNK, Monat, Fehler);
    CDateLong := RetString + ' ' + MonatsNamen[Monat] + ' 19' + Copy(D2Conv,7,2);
  END
  ELSE
    CDateLong := '';
END;

FUNCTION CDateShort(D2Conv : DATUM) : STRING;
VAR RetString, JUNK : STRING;
    Monat, Fehler   : INTEGER;
BEGIN
  IF ValDate(D2Conv) THEN
  BEGIN
    RetString := Copy(D2Conv,1,2);
    JUNK := Copy(D2Conv,4,2);
    Val(JUNK, Monat, Fehler);
    CDateShort := RetString + ' ' + KurzNamen[Monat] + ' ' + Copy(D2Conv,7,2);
  END
  ELSE
    CDateShort := '';
END;

FUNCTION AbsDatum(Tage : INTEGER) : DATUM;
VAR Jahre, Monate       : BYTE;
    SchaltJahr          : BOOLEAN;
BEGIN
  IF (Tage < 0) OR (Tage > MaxDayDate) THEN
    DateErr(3, '');
  Jahre  := 0;
  WHILE (Tage >= 0) DO
  BEGIN
    Inc(Jahre);
    Dec(Tage, JahresTage[Jahre MOD 4]);
  END;
  Inc(Tage, JahresTage[Jahre MOD 4]);
  Dec(Jahre);
  Monate     := 0;
  SchaltJahr := ((Jahre MOD 4) = 0);
  WHILE (Tage >= 0) DO
  BEGIN
    Inc(Monate);
    Dec(Tage, MonatsTage[SchaltJahr, Monate]);
  END;
  Inc(Tage, MonatsTage[SchaltJahr, Monate]);
  AbsDatum := DatStrZ(Tage + 1, 2) + '.' + DatStrZ(Monate, 2) + '.' + DatStrZ(Jahre + 80, 2);
END;

FUNCTION DateSum(Date2Start : DATUM; Days : INTEGER) : DATUM;
VAR Puffer : INTEGER;
BEGIN
  IF NOT ValDate(Date2Start) THEN
    DateErr(2, Date2Start);
  Puffer := AbsTage(Date2Start) + Days;
  IF (Puffer < 0) OR (Puffer > MaxDayDate) THEN
    DateErr(4, '');
  DateSum := AbsDatum(Puffer);
END;

FUNCTION DateSub(Date2Start : DATUM; Days : INTEGER) : DATUM;
VAR Puffer : INTEGER;
BEGIN
  IF NOT ValDate(Date2Start) THEN
    DateErr(2, Date2Start);
  Puffer := AbsTage(Date2Start) - Days;
  IF (Puffer < 0) OR (Puffer > MaxDayDate) THEN
    DateErr(4, '');
  DateSub := AbsDatum(Puffer);
END;

FUNCTION OpusLOGstring(LogSTAMP : BYTE; PrgMARK, LogTEXT : STRING) : STRING;
BEGIN
  OpusLOGstring := LogTAGS[LogSTAMP] + ' ' + Copy(CDateShort(Today), 1, 6) + ' ' + ToNow + ' ' + PrgMARK + ' ' + LogTEXT;
END;

FUNCTION QbbsLOGstring(LogText : STRING) : STRING;
VAR Year, Month, Day, DayOfWeek : WORD;
BEGIN
  GetDate(Year, Month, Day, DayOfWeek);
  Year := Year - 1900;
  QbbsLOGstring := DatStrZ(Day, 2) + '-' + KurzNamen[Month] + '-' + DatStrZ(Year, 2) + ' ' +
                   Copy(ToNow, 1, 5) + '  ' + LogTEXT;
END;

BEGIN
END.