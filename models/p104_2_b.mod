
var x1 >= 0;
var x2 >= 0;

minimize z: 4*x1 + 3*x2;

s.t. a: 8*x1 + 3*x2 >= 24;
s.t. b: 5*x1 + 6*x2 >= 30;
s.t. c: x1 + 2*x2 >= 8;

end;

