
var x1 >= 0;
var x2 >= 0;

maximize z: x1 + 1*x2;

s.t. r1: 5*x1 + 2*x2 <= 20;
s.t. r2: 2*x1 - 1*x2 >= 2;
s.t. r3: 3*x1 + 5*x2 >= 15;

end;

