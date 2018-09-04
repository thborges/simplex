
var x1 >= 0;
var x2 >= 0;
var x3 >= 0;

maximize z: x1 + 1.2*x2 + 1.5*x3;

s.t. r1: 4*x1 + x2 + 0.8*x3 <= 10;
s.t. r2: 0.9*x1 + x2 + 5*x3 <= 9.5;
s.t. r3: 1.2*x1 + 3*x2 + 1.5*x3 <= 11;

end;

