#ifndef CS_LAYOUT_CONTEXT_H
#define CS_LAYOUT_CONTEXT_H

#define YY_DECL int cslayoutlex \
    (YYSTYPE *yylval_param, yyscan_t yyscanner, CSLAYOUT_AST **astpp)

struct CSLAYOUT_AST {
    int node_type;
    struct CSLAYOUT_AST *l;
    struct CSLAYOUT_AST *r;
    union {
        float number;
        float percentage;
        char *coord;
    } value;
    void *data;
};

typedef struct CSLAYOUT_AST CSLAYOUT_AST;

CSLAYOUT_AST *cslayout_create_ast(int type, CSLAYOUT_AST *l, CSLAYOUT_AST *r);

CSLAYOUT_AST *cslayout_parse_rule(char *rule);
void cslayout_destroy_ast(CSLAYOUT_AST *astp);

void cslayout_print_ast(CSLAYOUT_AST *astp);

#endif
