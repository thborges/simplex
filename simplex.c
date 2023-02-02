
#include <stdio.h>
#include <float.h>
#include <assert.h>
#include <string.h>
#include <stdbool.h>
#include "simplex.h"

#define KNRM  "\x1B[0m"
#define KBLD  "\x1B[1m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"
#define KINV  "\e[7m"

void printtableaux(int rows, int cols, 
	vname namerows[rows], cname namecols[cols],
	double tableaux[rows][cols],
	int enter_col, int leave_row, int first_phase) {

	printf(KBLD KNRM KINV"       |");
	for(int c = 0; c < cols; c++) {
		if (!first_phase && namecols[c].aux)
			continue;

		if (c == enter_col) printf(KBLD KMAG);
		else printf(KBLD KNRM KINV);
		printf("%6s |", namecols[c].name);
	}
	printf("\n");

	for(int r = 0; r < rows; r++) {
		bool opt_row = (first_phase && r == rows-1) ||  // r
					   (!first_phase && r == 0); // z

		if (r == leave_row)
			printf(KBLD KMAG KINV);
		else if (opt_row)
			printf(KBLD KCYN KINV);
		else
			printf(KBLD KNRM KINV);
		printf("%6s |", namerows[r].name);
		if (!opt_row)
			printf(KNRM);

		for(int c = 0; c < cols; c++) {
			if (!first_phase && namecols[c].aux)
				continue;
			printf("%6.2f |", tableaux[r][c]);
		}
		printf("\n");
	}

	printf(KNRM "\n");
}

void simplex(char maxmin, int rows, int cols, 
	vname namerows[rows], cname namecols[cols],
	double tableaux[rows][cols], int obj_row, int first_phase) {

	char nonbasic[cols];
	memset(nonbasic, 0, sizeof nonbasic);
	for(int c = 0; c < cols-1; c++) {
		int found = 0;
		for(int r = 0; r < rows; r++) {
			if (strcmp(namerows[r].name, namecols[c].name) == 0) {
				found = 1;
				break;
			}
		}
		if (!found) {
			//printf("Non-basic: %s\n", namecols[c].name);
			nonbasic[c] = 1;
		}
	}
	
	do {
		
		int enter_col = -1;
		double current = 0; //maxmin == '>' ? DBL_MAX : DBL_MIN;
		for(int c = 0; c < cols-1; c++) {
			if (!first_phase && namecols[c].aux)
				continue;

			int aux = 
				(maxmin == '>' && tableaux[obj_row][c] < current) ||
				(maxmin == '<' && tableaux[obj_row][c] > current);
			if (aux && nonbasic[c]) {
				current = tableaux[obj_row][c];
				enter_col = c;
			}
			//printf("Aux is %d: %f, current %d\n", c, tableaux[obj_row][c], enter_col);
		}

		// first phase: check if solution is zero and stop
		printf("Solution: %le\n", tableaux[obj_row][cols-1]);
		if (first_phase && tableaux[obj_row][cols-1] <= 0.000000000001) {
			printtableaux(rows, cols, namerows, namecols, tableaux, cols, rows, first_phase);
			break;
		}

		if (enter_col == -1) {
			printtableaux(rows, cols, namerows, namecols, tableaux, cols, rows, first_phase);
			printf("\nOptimal solution found: %15.4f \n", tableaux[obj_row][cols-1]);
			for(int r = 1; r < rows; r++)
				printf("\t %13s: %15.4f\n", namerows[r].name, tableaux[r][cols-1]);
			break;
		}
		
		int leave_row = obj_row;
		double mincoef = DBL_MAX;
		for(int r = 1; r < rows; r++) {
			if (r == obj_row)
				continue;

			// only positive coeficients on the enter_col are considered
			if (tableaux[r][enter_col] <= 0)
				continue;

			double coefvalue = tableaux[r][cols-1] / tableaux[r][enter_col];
			if (coefvalue < 0)
				continue;

			if (coefvalue < mincoef) {
				mincoef = coefvalue;
				leave_row = r;
			}
		}
		assert(leave_row != obj_row && "Leave row could not be objective row!\n");

		printtableaux(rows, cols, namerows, namecols, tableaux, enter_col, leave_row, first_phase);
		namerows[leave_row].name = namecols[enter_col].name;
		nonbasic[enter_col] = 0;

		// new pivo row
		double pivo = tableaux[leave_row][enter_col];
		for(int c = 0; c < cols; c++) {
			tableaux[leave_row][c] = tableaux[leave_row][c] / pivo;
		}

		for(int r = 0; r < rows; r++) {
			if (r == leave_row)
				continue;

			pivo = tableaux[r][enter_col];
			for(int c = 0; c < cols; c++) {
				tableaux[r][c] = tableaux[r][c] - pivo * tableaux[leave_row][c];
			}
		}
	} while (1);
}


int oldmain() {

	char maxmin;

	int rows, cols;

	scanf("%c %d %d", &maxmin, &rows, &cols);
	printf("%s, rows %d, cols %d\n", maxmin == '>' ? "Max" : "Min",
		rows, cols);

	double tableaux[rows][cols];
	vname namerows[rows];
	cname namecols[cols];

	for(int r = 0; r < rows; r++)
		scanf("%s", namerows[r].name);

	for(int c = 0; c < cols; c++)
		scanf("%s", namecols[c].name);
	
	for(int r = 0; r < rows; r++) {
		for(int c = 0; c < cols; c++) {
			scanf("%lf", &tableaux[r][c]);
		}
	}

	simplex(maxmin, rows, cols, namerows, namecols, tableaux, 0, 0);
	return 0;
}


