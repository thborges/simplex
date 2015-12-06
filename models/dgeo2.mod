set PAIR;
set MACH;

var j{MACH, PAIR} <= 1;
var mksp;

param comunica{MACH,PAIR};
param weight{PAIR};

minimize z: sum{m in MACH, p in PAIR} comunica[m,p] * j[m,p] + card(MACH) * mksp;

s.t. oneserver{p in PAIR}: sum{m in MACH} j[m,p] = 1;
s.t. makespan{m in MACH}: sum{p in PAIR} weight[p] * j[m,p] <= mksp;

data;

set PAIR := p1, p2, p3, p4, p5;

set MACH := m1, m2;

param comunica(tr) :
	m1	m2 :=
p1	5	6
p2	4	3
p3	3	8
p4	6	7
p5	8	5;

param weight :=
p1	10
p2	7
p3	9
p4	8
p5	11;

end;

