#include <stdio.h>
#include <stdlib.h>
#include "parser.h"
#include "lex.h"

int cslayoutparse(yyscan_t scanner);
int cslayoutlex_init(yyscan_t *scanner_ptr);
int cslayoutlex_destroy(yyscan_t scanner);

int main(int argc, char **argv) {
    void *scanner;

    cslayoutlex_init(&scanner);

    int result = (cslayoutparse(scanner));

    cslayoutlex_destroy(scanner);

    if (!result) fprintf(stdout, "Success!\n");

    return result;
}
