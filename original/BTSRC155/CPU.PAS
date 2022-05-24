UNIT CPU;

INTERFACE

CONST
  UnitNAME    = 'The CPU      Unit';
  UnitVERSION = '1.00';
  UnitMONTH   = 'Jan';
  UnitYEAR    = '1990';
  UnitAUTHOR  = 'Tischer/Moll';

FUNCTION CPUtype : BYTE;
FUNCTION CPUname(CPUtypeNum : BYTE) : STRING;
FUNCTION FPUpresent : BOOLEAN;
FUNCTION ApproxMHZ : BYTE;
FUNCTION DelayCounter : WORD;

IMPLEMENTATION

USES CRT;

{ Referenzwerte:

  XT 4.77 MHz            98

  AT  6 Mhz 1 W         216
  AT  8 Mhz 1 W         297
  AT 10 Mhz 1 W         365
  AT 12 Mhz 1 W         456

  NEAT-AT 12 MHz 1 W    430
  NEAT-AT 16 MHz 1 W    594 }

FUNCTION CheckCPU: INTEGER;
VAR
  CPU: INTEGER;
BEGIN
  InLine (
          $DB/$E3/                  {  FINIT  }
          $C7/$86/CPU/$FF/$FF/      {  MOV     Word Ptr [BP+CPU],FFFF  }
          $D9/$BE/CPU/              {  FSTCW   [BP+CPU]  }
          $29/$DB/                  {  SUB     BX,BX  }
          $B8/$02/$00/              {  MOV     AX,0002  }
          $B1/$21/                  {  MOV     CL,21  }
          $D3/$E8/                  {  SHR     AX,CL  }
          $A9/$01/$00/              {  TEST    AX,0001  }
          $74/$08/                  {  JZ      Lab1  }
          $43/                      {  INC     BX  }
          $54/                      {  PUSH    SP  }
          $58/                      {  POP     AX  }
          $39/$E0/                  {  CMP     AX,SP  }
          $75/$01/                  {  JNZ     Lab1  }
          $43/                      {  INC     BX  }
{Lab1:}   $88/$9E/CPU               {  MOV     [BP+CPU],BL  }
         );
  CheckCPU := CPU; {Lo: 0-'86; 1-'186; 2-'286; 3-'386  Hi<>$FF-'87}
END;

FUNCTION CPUtype : BYTE;

BEGIN     { Maschinensprache-Routine zur Bestimmung des Prozessor-Typs }
 InLine(
        $9C/$51/$52/$57/$56/$06/$33/$C0/$50/$9D/$9C/$58/$25/$00/
        $F0/$3D/$00/$F0/$74/$13/$B2/$06/$B8/$00/$70/$50/$9D/$9C/
        $58/$25/$00/$70/$74/$36/$FE/$C2/$EB/$32/$90/$B2/$04/$B0/
        $FF/$B1/$21/$D2/$E8/$75/$12/$B2/$02/$FB/$BE/$00/$00/$B9/
        $FF/$FF/$F3/$26/$AC/$0B/$C9/$74/$02/$B2/$00/$0E/$07/$FD/
        $B0/$FB/$B9/$03/$00/$E8/$16/$00/$FA/$F3/$AA/$FC/$90/$90/
        $90/$42/$90/$FB/$88/$56/$FF/$07/$5E/$5F/$5A/$59/$9D/$EB/
        $07/$90/$5F/$83/$C7/$09/$EB/$E4
       );
END;

FUNCTION FPUpresent : BOOLEAN;
BEGIN
  FPUpresent := (Hi(CheckCPU) <> $FF)
END;

FUNCTION CPUname(CPUtypeNum : BYTE) : STRING;
TYPE
  ProNamen = ARRAY[0..7] OF STRING[11]; { Array mit Prozessornamen }
CONST
  ProzName : ProNamen = ( 'INTEL 8088',                   { Code 0 }
                          'INTEL 8086',                   { Code 1 }
                          'NEC V20',                      { Code 2 }
                          'NEC V30',                      { Code 3 }
                          'INTEL 80188',                  { Code 4 }
                          'INTEL 80186',                  { Code 5 }
                          'INTEL 80286',                  { Code 6 }
                          'INTEL 80386' );                { Code 7 }
BEGIN
  CPUname := ProzName[CPUtypeNum];
END;

FUNCTION ApproxMHZ : BYTE;
VAR
  DelayCount  : ^WORD;
  DelayBuffer : WORD;
  XT , AT     : BYTE;
BEGIN
  DelayCount  := Ptr(Seg(WindMax), Ofs(WindMax) + 2);
  DelayBuffer := DelayCount^ * 2;
  IF Lo(CheckCPU) = 0 THEN
    ApproxMHZ := DelayBuffer DIV 41
  ELSE
    ApproxMHZ := DelayBuffer DIV 65;
END;

FUNCTION DelayCounter : WORD;
VAR
  DelayCount  : ^WORD;
BEGIN
  DelayCount   := Ptr(Seg(WindMax), Ofs(WindMax) + 2);
  DelayCounter := DelayCount^;
END;

BEGIN
END.
