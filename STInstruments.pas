unit STInstruments;

interface

type
  TP1DInstrument = record
    Multiple: byte;
    Detune: integer;
    Phase: byte;
  end;

  TSVGArpeggio = record
    Length: integer;
    Value: array[1..256] of byte;
  end;

implementation

end.
