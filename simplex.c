
#include <stdio.h>
#include <float.h>
#include <assert.h>
#include <string.h>

#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"

typedef struct {
	char name[10];
} vname;

void printtableaux(int rows, int cols, 
	vname namerows[rows], vname namecols[cols],
	double tableaux[rows][cols],
	int enter_col, int leave_row) {

	printf("           |");
	for(int c = 0; c < cols; c++) {
		if (c == enter_col) printf(KMAG);
		printf("%10s |", namecols[c].name);
		if (c == enter_col) printf(KNRM);
	}
	printf("\n");

	for(int r = 0; r < rows; r++) {
		if (r == leave_row) printf(KRED);
		printf("%10s |", namerows[r].name);
		if (r == leave_row) printf(KNRM);

		for(int c = 0; c < cols; c++) {
			printf("%10.2f |", tableaux[r][c]);
		}
		printf("\n");
	}

	printf("\n");
}

void simplex(char maxmin, int rows, int cols, 
	vname namerows[rows], vname namecols[cols],
	double tableaux[rows][cols]) {

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
			printf("Non-basic: %s\n", namecols[c].name);
			nonbasic[c] = 1;
		}
	}
	
	do {
		
		int enter_col = -1;
		double current = maxmin == '>' ? DBL_MAX : DBL_MIN;
		for(int c = 0; c < cols; c++) {
			int aux = 
				(maxmin == '>' && tableaux[0][c] < current) ||
				(maxmin == '<' && tableaux[0][c] > current);
			if (aux && nonbasic[c]) {
				current = tableaux[0][c];
				enter_col = c;
			}
		}

		if (enter_col == -1) {
			printtableaux(rows, cols, namerows, namecols, tableaux, cols, rows);
			printf("\nOptimal solution found: %f \n", tableaux[0][cols-1]);
			for(int r = 1; r < rows; r++)
				printf("\t %s: %f\n", namerows[r].name, tableaux[r][cols-1]);
			break;
		}
		
		int leave_row = 0;
		double mincoef = DBL_MAX;
		for(int r = 1; r < rows; r++) {
			if (tableaux[r][enter_col] == 0)
				continue;

			double coefvalue = tableaux[r][cols-1] / tableaux[r][enter_col];
			if (coefvalue <= 0)
				continue;

			if (coefvalue < mincoef) {
				mincoef = coefvalue;
				leave_row = r;
			}
		}
		assert(leave_row != 0 && "Leave row could not be z!\n");

		printtableaux(rows, cols, namerows, namecols, tableaux, enter_col, leave_row);
		sprintf(namerows[leave_row].name, "%s", namecols[enter_col].name);
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


int main() {

	char maxmin;

	int rows, cols;

	scanf("%c %d %d", &maxmin, &rows, &cols);

	double tableaux[rows][cols];
	vname namerows[rows];
	vname namecols[cols];

	for(int r = 0; r < rows; r++)
		scanf("%s", namerows[r].name);

	for(int c = 0; c < cols; c++)
		scanf("%s", namecols[c].name);
	
	for(int r = 0; r < rows; r++) {
		for(int c = 0; c < cols; c++) {
			scanf("%lf", &tableaux[r][c]);
		}
	}

	simplex(maxmin, rows, cols, namerows, namecols, tableaux);
}


