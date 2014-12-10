#include <stdio.h>
#include <stdlib.h>
#include "COSLayoutParser.h"

void coslayout_print_ast(COSLAYOUT_AST *astp) {
    if (astp != NULL) { 
        coslayout_print_ast(astp->l);
        coslayout_print_ast(astp->r);
        printf("node type: %d\n", astp->node_type);
    }
}

int main(int argc, char **argv) {
    COSLAYOUT_AST *ast = NULL;
    int result = coslayout_parse_rule("tt = bb = rr = ll = 50% + %f", &ast);

    coslayout_print_ast(ast);
    coslayout_destroy_ast(ast);

    return 0;
}
