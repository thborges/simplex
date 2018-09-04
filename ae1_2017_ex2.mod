var a >= 0;
var b >= 0;
var c >= 0;
var d >= 0;

maximize z: 2*a + 4*b + 5*c + 3*d;

s.t. r1: 0.3*a + 0.3*b + 0.5*c + 0.4*d <= 40;
s.t. r2: 0.4*a + 0.3*b + 0.2*c + 0.4*d <= 40;
s.t. r3: 0.3*a + 0.4*b + 0.3*c + 0.2*d <= 60;

end;

