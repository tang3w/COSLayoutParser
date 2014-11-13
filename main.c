#include <stdio.h>
#include <stdlib.h>
#include "CSLayoutParser.h"

void cslayout_print_ast(CSLAYOUT_AST *astp) {
    if (astp != NULL) { 
        cslayout_print_ast(astp->l);
        cslayout_print_ast(astp->r);
        printf("node type: %d\n", astp->node_type);
    }
}

int main(int argc, char **argv) {
    CSLAYOUT_AST *ast = NULL;
    int result = cslayout_parse_rule("tt = bb = rr = ll = 50% + %f", &ast);

    cslayout_print_ast(ast);
    cslayout_destroy_ast(ast);

    return 0;
}
