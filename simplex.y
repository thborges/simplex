%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/param.h>
#include "simplex.h"

extern int yylex (void);
extern int yyerror(const char *s);
extern FILE *yyin;

int vars_qtd = 0;
int aux_qtd = 0;
int slack_surplus_qtd = 0;
int constraints_qtd = 0;

int actualvar = 0;
int vars_seen_size = 0;
char **vars_seen = NULL;

// tableaux
char maxmin;
int rows, cols;
double *tableaux;
vname *namerows;
cname *namecols;

double *current_row;
int current_rowno = 1;

int get_var_index(char *name) {
	for(int i = 0; i < actualvar; i++)
		if(strcmp(name, vars_seen[i]) == 0)
			return i;
	return -1;
}

double get_tableaux(int row, int col) {
	return tableaux[row*cols + col];
}

void set_tableaux(int row, int col, double value) {
	tableaux[row*cols + col] = value;
}

void copy_to_row(int row, int signal) {
	for(int i = 0; i < cols; i++) {
		set_tableaux(row, i, current_row[i]*signal);
		current_row[i] = 0;
	}
}


%}

%token TOK_MAX TOK_MIN 
%token TOK_INTEGER TOK_DOUBLE TOK_STRING
%token TOK_GE TOK_LE TOK_EQ

%union {
	int integer;
	double dbl;
	char *string;
}

%type <dbl> constant TOK_DOUBLE
%type <integer> TOK_INTEGER
%type <string> TOK_STRING

%start modelo 

%%

modelo : objetivo restricoes    { }
	   ;

restricoes
	: restricoes restricao ';'   {  }
	| restricao ';'              {  }
	;

objetivo : TOK_MAX linear_expr ';'   
			{ maxmin = '>';
			  copy_to_row(0, -1);
			  namerows[0].name = "z";
			  printf("Maximize\n");
			}

		 | TOK_MIN linear_expr ';'   
			{ maxmin = '<';
			  copy_to_row(0, -1);
			  namerows[0].name = "z";
			  printf("Minimize\n");
			}
		 ;

restricao : linear_expr TOK_GE constant	
				{ current_row[cols-1] = $3;

				  aux_qtd++;
				  slack_surplus_qtd++;
				  char str[100];
				  sprintf(str, "_s%d", slack_surplus_qtd);
				  current_row[get_var_index(str)] = -1.0;
				  sprintf(str, "_a%d", aux_qtd);
				  int c = get_var_index(str);
				  current_row[c] = 1.0;
				  namerows[current_rowno].name = vars_seen[c];
				  set_tableaux(rows-1, c, -1); // r objective row

				  copy_to_row(current_rowno++, 1);
				}

		  | linear_expr TOK_LE constant 
				{ current_row[cols-1] = $3;

				  slack_surplus_qtd++;
				  char str[100];
				  sprintf(str, "_s%d", slack_surplus_qtd);
				  current_row[get_var_index(str)] = 1.0;
				  namerows[current_rowno].name = vars_seen[get_var_index(str)];

				  copy_to_row(current_rowno++, 1);
				}

		  | linear_expr TOK_EQ constant 
				{ current_row[cols-1] = $3;

				  aux_qtd++;
				  char str[100];
				  sprintf(str, "_a%d", aux_qtd);
				  int c = get_var_index(str);
				  current_row[c] = 1.0;
				  namerows[current_rowno].name = vars_seen[c];
				  set_tableaux(rows-1, c, -1); // r objective row

				  copy_to_row(current_rowno++, 1);
				}
		  ;

linear_expr
	: linear_expr term
	| term
	;

term : TOK_INTEGER TOK_STRING	{ current_row[get_var_index($2)] = $1; }
	 | TOK_DOUBLE TOK_STRING	{ current_row[get_var_index($2)] = $1; }
	 | '+' TOK_STRING			{ current_row[get_var_index($2)] = 1.0; }
	 | '-' TOK_STRING			{ current_row[get_var_index($2)] = -1.0; }
	 | TOK_STRING               { current_row[get_var_index($1)] = 1.0; }
	 ;

constant : TOK_INTEGER			{ $$ = $1; }
		 | TOK_DOUBLE			{ $$ = $1; }
		 ;

%%

// codigo C 

int yyerror(const char *s) {
	printf("error: %s\n", s);
	return 0;
}

void count_vars_and_constraints() {
	char str[100];

	// ignore whitespace in the begining
	int spaces = 0;
	str[1] = 0;
	while(fscanf(yyin, "%c", &str[0]) != EOF) {
		if (isspace(str[0]))
			spaces++;
		else
			break;
	}
	fseek(yyin, spaces, SEEK_SET);

	while(fscanf(yyin, "%[^;\r\n\t+. -]", str) != EOF) {
		//printf("Detected word is %s\n", str);

		if (vars_seen_size <= actualvar+2) {
			vars_seen_size = MAX(10, vars_seen_size * 2);
			vars_seen = (char**)realloc(vars_seen, vars_seen_size * sizeof(char*));
		}

		if (strcmp(str, "<=") == 0) {
			constraints_qtd++;
			vars_qtd++; // slack
			slack_surplus_qtd++;
			sprintf(str, "_s%d", slack_surplus_qtd);
			vars_seen[actualvar++] = strdup(str);
		}
		if (strcmp(str, "=") == 0) {
			constraints_qtd++;
			vars_qtd++; // auxiliary
			aux_qtd++;
			sprintf(str, "_a%d", aux_qtd);
			vars_seen[actualvar++] = strdup(str);
		}
		else if (strcmp(str, ">=") == 0) {
			constraints_qtd++;
			vars_qtd += 2; // surplus + auxiliary
			aux_qtd++;
			slack_surplus_qtd++;

			sprintf(str, "_s%d", slack_surplus_qtd);
			vars_seen[actualvar++] = strdup(str);
			sprintf(str, "_a%d", aux_qtd);
			vars_seen[actualvar++] = strdup(str);
		}
		else if (strcmp(str, "maximize") != 0
			  && strcmp(str, "minimize") != 0) {

			// ignore prefix numbers
			char *str2 = str;
			while (*str2 && *str2 >= '0' && *str2 <= '9')
				str2++;

			if (strlen(str2) > 0) { // only digits
				// TODO: a hash would be better.
				int seen = 0;
				for(int i = 0; i < actualvar; i++) {
					if (strcmp(str2, vars_seen[i]) == 0) {
						seen = 1;
						break;
					}
				}
				if (!seen) {
					vars_qtd++;
					vars_seen[actualvar++] = strdup(str2);
				}
			}
		}
		// ignore
		while (fscanf(yyin, "%[;\r\n\t+. -]", str) >= 1);
	}

	printf("Model has %d constraints and %d variables, %d auxiliary.\nVars: ", constraints_qtd, vars_qtd, aux_qtd);
	for(int i = 0; i < actualvar; i++)
		printf("%s ", vars_seen[i]);
	printf("\n");
}

int main(int argc, char *argv[]) {
	if (argc <= 1) {
		printf("Syntax: %s file\n", argv[0]);
		return 1;
	}

	yyin = fopen(argv[1], "r");
	count_vars_and_constraints();

	int two_phase = aux_qtd > 0;

	rows = constraints_qtd + 1;
	if (two_phase)
		rows++; // first phase objective line

	cols = vars_qtd + 1; // plus solution

	namerows = (vname*)calloc(rows, sizeof(vname));
	if (two_phase)
		namerows[rows-1].name = "r";

	namecols = (cname*)calloc(cols, sizeof(cname));
	tableaux = (double*)calloc(rows*cols, sizeof(double));
	current_row = (double*)calloc(cols, sizeof(double));

	aux_qtd = 0;
	slack_surplus_qtd = 0;
	freopen(argv[1], "r", yyin);
	yyparse();
	fclose(yyin);

	for(int i = 0; i < actualvar; i++) {
		namecols[i].name = vars_seen[i];
		if (strncmp("_a", vars_seen[i], 2) == 0)
			namecols[i].aux = 1;
		if (strncmp("_s", vars_seen[i], 2) == 0)
			namecols[i].slack = 1;
	}
	namecols[actualvar].name = "sol";

	if (two_phase) {
		printf("\n-----[First phase]------\n");
		for(int c = 0; c < cols; c++) {
			double new_obj = get_tableaux(rows-1, c);
			for(int i = 0; i < rows-1; i++) {
				if (strncmp("_a", namerows[i].name, 2) == 0) {
					new_obj += get_tableaux(i, c);
				}
			}
			set_tableaux(rows-1, c, new_obj);
		}
		
		simplex('<', rows, cols, namerows, namecols, tableaux, rows-1, 1);
		if (get_tableaux(rows-1, cols-1) > 0.000000000001) {
			printf("Solution > 0, not optimal while minimizing first phase.\n");
		} else {
			printf("\n-----[Second phase]------\n");
			simplex(maxmin, rows-1, cols, namerows, namecols, tableaux, 0, 0);
		}

	}
	else
		simplex(maxmin, rows, cols, namerows, namecols, tableaux, 0, 0);

	for(int i = 0; i < actualvar; i++)
		free(vars_seen[i]);
}

