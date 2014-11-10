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
    int num = 0;
    CSLAYOUT_AST *ast = cslayout_parse_rule("tt = bb = rr = ll = 50% + 10.0f", &num);

    cslayout_print_ast(ast);
    cslayout_destroy_ast(ast);

    return 0;
}
