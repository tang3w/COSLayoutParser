#include "context.h"
#include "parser.h"
#include "lex.h"

int cslayoutparse (void *scanner, CSLAYOUT_AST **astpp, int *argc);
int cslayoutlex_init (yyscan_t* scanner);
int cslayoutlex_destroy (yyscan_t yyscanner);

CSLAYOUT_AST *cslayout_create_ast(int type, CSLAYOUT_AST *l, CSLAYOUT_AST *r) {
    CSLAYOUT_AST *astp = (CSLAYOUT_AST *)malloc(sizeof(CSLAYOUT_AST));

    astp->node_type = type;
    astp->l = l;
    astp->r = r;
    astp->value.coord = NULL;
    astp->data = NULL;

    return astp;
}

CSLAYOUT_AST *cslayout_parse_rule(char *rule, int *argc) {
    CSLAYOUT_AST *astp = NULL;

    yyscan_t scanner;
    cslayoutlex_init(&scanner);
    YY_BUFFER_STATE state = cslayout_scan_string(rule, scanner);

    int failed = cslayoutparse(scanner, &astp, argc);

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

        int type = astp->node_type;
        char *coord = astp->value.coord;

        if ((type == CSLAYOUT_TOKEN_ATTR || type == CSLAYOUT_TOKEN_COORD) && coord != NULL)
            free(coord);

        free(astp);
    }
}
