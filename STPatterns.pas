unit STPatterns;

interface

type
  TPattern = record
    Length: integer;
    Tempo: integer;
    Name: string;
    Chan: array [1..2] of array [1..256] of byte;
    Drum: array [1..256] of byte;
    Sustain: array [1..2] of array [1..256] of byte;
  end;

  TPatternSVG = record
    Glissando: array [1..2] of array [1..256] of word;
    Skew: array [1..2] of array [1..256] of word;
    SkewXOR: array [1..2] of array [1..256] of word;
    Arpeggio: array [1..2] of array [1..256] of word;
    Warp: array [1..2] of array [1..256] of byte;
  end;

implementation

end.
