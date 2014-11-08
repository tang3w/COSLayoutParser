#include "context.h"
#include "parser.h"
#include "lex.h"

int cslayoutparse (void *scanner, CSLAYOUT_AST **astpp);
int cslayoutlex_init (yyscan_t* scanner);
int cslayoutlex_destroy (yyscan_t yyscanner);

CSLAYOUT_AST *cslayout_create_ast(int type, CSLAYOUT_AST *l, CSLAYOUT_AST *r) {
    CSLAYOUT_AST *astp = (CSLAYOUT_AST *)malloc(sizeof(CSLAYOUT_AST));

    astp->type = type;
    astp->l = l;
    astp->r = r;
    astp->coord = NULL;

    return astp;
}

CSLAYOUT_AST *cslayout_parse_rule(char *rule) {
    CSLAYOUT_AST *astp = NULL;

    yyscan_t scanner;
    cslayoutlex_init(&scanner);
    YY_BUFFER_STATE state = cslayout_scan_string(rule, scanner);

    int failed = cslayoutparse(scanner, &astp);

    cslayout_delete_buffer(state, scanner);
    cslayoutlex_destroy(scanner);

    if (failed) {
        cslayout_destroy_ast(astp);
        astp = NULL;
    }

    return astp;
}

void cslayout_destroy_ast(CSLAYOUT_AST *astp) {
    if (astp != NULL) {
        cslayout_destroy_ast(astp->l);
        cslayout_destroy_ast(astp->r);

        if (astp->coord != NULL) free(astp->coord);

        free(astp);
    }
}

void cslayout_print_ast(CSLAYOUT_AST *astp) {
    if (astp->l != NULL) {
        cslayout_print_ast(astp->l);
    }
    if (astp->r != NULL) {
        cslayout_print_ast(astp->r);
    }

    printf("node type: %d\n", astp->type);
}
