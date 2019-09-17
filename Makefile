all:
	lex -o lexico.c simplex.l
	bison -d -o sintatico.c simplex.y
	#gcc -O3 simplex.c -o simplex
	gcc -O0 -ggdb -Wno-incompatible-pointer-types lexico.c sintatico.c simplex.c -o opt

