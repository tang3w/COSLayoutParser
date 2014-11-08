#include <stdio.h>
#include <stdlib.h>
#include "context.h"

int main(int argc, char **argv) {
    CSLAYOUT_AST *ast = cslayout_parse_rule("tt = bb = rr = ll = 50% + 10.0f * $.ll");

    cslayout_print_ast(ast);

    cslayout_destroy_ast(ast);

    return 0;
}
