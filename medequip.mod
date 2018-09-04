var a >= 0;
var b >= 0;
var c >= 0;
var d >= 0;
var e >= 0;
var f >= 0;

minimize z: 600*a + 800*b + 700*c + 400*d + 900*e + 600*f;

s.t. c1: 1*a + 1*d = 300;
s.t. c2: 1*b + 1*e = 200;
s.t. c3: 1*c + 1*f = 400;

s.t. A: 1*a + 1*b + 1*c <= 400;
s.t. B: 1*d + 1*e + 1*f <= 500;

end;

