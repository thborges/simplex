var x1 >= 0;
var x2 >= 0;

maximize z: 600*x1 + 800*x2;

s.t. area: x1 + x2 <= 100; 
s.t. homens_horas: 3*x1 + 2*x2 <= 240;
s.t. demanda_soja: x1 <= 60;
s.t. demanda_milho: x2 <= 80;

end;
