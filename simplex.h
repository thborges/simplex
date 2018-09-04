
#ifndef SIMPLEX_H
#define SIMPLEX_H

typedef struct {
	char *name;
} vname;

typedef struct {
	char *name;
	short aux;
	short slack;
} cname;

double get_tableaux(int row, int col);

void simplex(char maxmin, int rows, int cols, 
	vname namerows[rows], cname namecols[cols],
	double tableaux[rows][cols], int obj_row, int ignore_aux);

#endif

