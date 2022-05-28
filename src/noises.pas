{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
UNIT Noises;

INTERFACE

USES CRT;

CONST
  UnitNAME    = 'The NOISES   Unit';
  UnitVERSION = '1.00';
  UnitMONTH   = 'Dec';
  UnitYEAR    = '1989';
  UnitAUTHOR  = 'Leo Moll';

CONST
  ON          = TRUE;
  OFF         = FALSE;

PROCEDURE SetNoises(OnOff : BOOLEAN);
PROCEDURE Police(HowMany : BYTE);
PROCEDURE FirePhasers(HowMany, PhaserType : BYTE);
PROCEDURE Explosion(HowMany, ExplosionType : BYTE);
PROCEDURE GoodBeep;
PROCEDURE BadBeep;
PROCEDURE NiceBeep;
PROCEDURE ErrorSound;

IMPLEMENTATION

VAR
  K , I       : WORD;
  NoiseStatus : BOOLEAN;

PROCEDURE SetNoises(OnOff : BOOLEAN);
BEGIN
  NoiseStatus := OnOff;
END;

PROCEDURE Police (HowMany : BYTE);
BEGIN
  IF NoiseStatus THEN
  BEGIN
    FOR I := 1 TO HowMany DO
    BEGIN
      FOR K := 150 TO 400 DO
      BEGIN
        Sound (K);
        Delay (1)
      END;
      FOR K := 400 DOWNTO 81 DO
      BEGIN
        {$IFDEF DEAD}
        Dec (K);
        {$ENDIF}
        Sound (K);
        Delay (1)
      END;
    END;
    NoSound;
  END;
END;

PROCEDURE FirePhasers(HowMany, PhaserType : BYTE);
BEGIN
  IF NoiseStatus THEN
  BEGIN
    FOR I := 1 TO HowMany DO
    BEGIN
      FOR K := 0 TO 400 DO
      BEGIN
        Sound (Random (1000)+100+K*4);
        Delay (1)
      END;
    END;
    NoSound;
  END;
END;

PROCEDURE Explosion(HowMany, ExplosionType : BYTE);
BEGIN
  IF NoiseStatus THEN
  BEGIN
    FOR I := 1 TO HowMany DO
    BEGIN
      FOR K := 0 TO 400 DO
      BEGIN
        Sound (Random (400)+400-K);
        Delay (2)
      END;
    END;
    NoSound;
  END;
END;

PROCEDURE BadBeep;
BEGIN
  Sound (261);
  Delay (100);
  NoSound;
  Sound (311);
  Delay (300);
  NoSound;
END;

PROCEDURE ErrorSound;
BEGIN
  IF NoiseStatus THEN
  BEGIN
    Sound(262);
    Delay(600);
    NoSound;
    Delay(30);
    Sound(262);
    Delay(400);
    NoSound;
    Delay(30);
    Sound(262);
    Delay(100);
    NoSound;
    Delay(30);
    Sound(262);
    Delay(600);
    NoSound;
    Delay(30);
    Sound(311);
    Delay(400);
    NoSound;
    Delay(30);
    Sound(293);
    Delay(100);
    NoSound;
    Delay(30);
    Sound(293);
    Delay(400);
    NoSound;
    Delay(30);
    Sound(262);
    Delay(100);
    NoSound;
    Delay(30);
    Sound(262);
    Delay(400);
    NoSound;
    Delay(30);
    Sound(246);
    Delay(100);
    NoSound;
    Delay(30);
    Sound(262);
    Delay(600);
    NoSound;
  END
  ELSE
    BadBeep;
END;

PROCEDURE GoodBeep;
BEGIN
  IF NoiseStatus THEN
  BEGIN
    Sound (130);
    Delay (65);
    Sound (164);
    Delay (65);
    Sound (196);
    Delay (65);
    Sound (261);
    Delay (65);
    Sound (329);
    Delay (65);
    Sound (392);
    Delay (65);
    Sound (523);
    Delay (65);
    NoSound;
  END;
END;

PROCEDURE Fanfare;
  PROCEDURE Pause;
  BEGIN
    NoSound;
    Delay (45);
  END;
BEGIN
  IF NoiseStatus THEN
  BEGIN
    Sound (392);
    Delay (125);
    Pause;
    Sound (523);
    Delay (375);
    Pause;
    Sound (523);
    Delay (125);
    Pause;
    Sound (523);
    Delay (125);
    Pause;
    Sound (523);
    Delay (250);
    Pause; (**)
    Sound (392);
    Delay (125);
    Pause;
    Sound (523);
    Delay (125);
    Pause;
    Sound (659);
    Delay (250);
    Pause;
    Sound (659);
    Delay (125);
    Pause;
    Sound (659);
    Delay (125);
    Pause;
    Sound (659);
    Delay (250);
    Pause; (**)
    Sound (523);
    Delay (125);
    Pause;
    Sound (659);
    Delay (125);
    Pause;
    Sound (784);
    Delay (250);
    Pause;
    Sound (392);
    Delay (125);
    Pause;
    Sound (392);
    Delay (125);
    Pause;
    Sound (392);
    Delay (250);
    Pause; (**)
    Sound (392);
    Delay (375);
    Pause;
    Sound (523);
    Delay (625);
    Pause; (**)
  END;
END;

PROCEDURE NiceBeep;
BEGIN
  Sound (1760);
  Delay (50);
  NoSound;
  Delay (50);
END;

BEGIN
  NoiseStatus := ON;
END.
