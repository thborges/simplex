all:
	lex -o lexico.c simplex.l
	bison -d -o sintatico.c simplex.y
	#gcc -O3 simplex.c -o simplex
	gcc -O0 -ggdb lexico.c sintatico.c simplex.c -o parser

