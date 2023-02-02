%{

#include <stdio.h>
#include "sintatico.h"

char buffer[100];

char *str_remove_space(char *text) {
	int b = 0;	
	while (*text) {
		if (*text != ' ')
			buffer[b++] = *text;
		text++;
	}
	buffer[b] = 0;
	return buffer;
}

%}

%%

"#".*$     { }
"maximize" { return TOK_MAX; }
"minimize" { return TOK_MIN; }
">="       { return TOK_GE; }
"<="       { return TOK_LE; }
"="        { return TOK_EQ; }
";"		   { return ';'; }

[a-zA-Z]+[a-zA-Z0-9]*     { yylval.string = strdup(yytext); 
					  return TOK_STRING; }

[+-]?[ ]*[0-9]+		{ yylval.integer = atoi(str_remove_space(yytext));
					  return TOK_INTEGER; }

[+-]?[ ]*[0-9]+\.[0-9]+	{ yylval.dbl = atof(str_remove_space(yytext));
						  return TOK_DOUBLE; }

"+"         { return '+'; }
"-"         { return '-'; }

[ \t\n]	{}

.		{ printf("Caracter nao esperado: %s\n", yytext); 
		  exit(1);
		}

%%

int yywrap() {
	return 1;
}


