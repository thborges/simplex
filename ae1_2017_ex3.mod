
var x1 >= 0;
var x2 >= 0;

minimize z: 4*x1 + 10*x2;

s.t. a: 80*x1 + 20*x2 <= 200;
s.t. b: 10*x1 + 18*x2 >= 50;
s.t. c: 0.6*x1 + 0.8*x2 >= 1.8;

end;
