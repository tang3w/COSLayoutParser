%{
#include <stdio.h>
#include "CSLayoutParser.h"
#include "CSLayoutLex.h"

void cslayouterror(void *scanner, CSLAYOUT_AST **astpp, int *argc, char *s);
int cslayoutlex(YYSTYPE *lvalp, void *scanner, CSLAYOUT_AST **astpp, int *argc);
%}

%define api.pure full
%lex-param {void *scanner}
%lex-param {CSLAYOUT_AST **astpp}
%lex-param {int *argc}
%parse-param {void *scanner}
%parse-param {CSLAYOUT_AST **astpp}
%parse-param {int *argc}
%define api.prefix {cslayout}
%define api.value.type {CSLAYOUT_AST *}

%code requires {
#define YYSTYPE CSLAYOUTSTYPE

#define YY_DECL int cslayoutlex \
    (YYSTYPE *yylval_param, yyscan_t yyscanner, CSLAYOUT_AST **astpp, int *argc)

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

CSLAYOUT_AST *cslayout_parse_rule(char *rule, int *argc);
void cslayout_destroy_ast(CSLAYOUT_AST *astp);
}

%token CSLAYOUT_TOKEN_ATTR;
%token CSLAYOUT_TOKEN_NUMBER;
%token CSLAYOUT_TOKEN_PERCENTAGE;
%token CSLAYOUT_TOKEN_COORD;

%left  '+' '-'
%left  '*' '/'
%right '='

%%

expr: %empty
    | CSLAYOUT_TOKEN_ATTR '=' expr { *astpp = $$ = cslayout_create_ast('=', $1, $3); }
    | rval                         { *astpp = $$ = $1; }
    ;
rval: rval '+' item                { *astpp = $$ = cslayout_create_ast('+', $1, $3); }
    | rval '-' item                { *astpp = $$ = cslayout_create_ast('-', $1, $3); }
    | item                         { *astpp = $$ = $1; }
    ;
item: item '*' atom                { *astpp = $$ = cslayout_create_ast('*', $1, $3); }
    | item '/' atom                { *astpp = $$ = cslayout_create_ast('/', $1, $3); }
    | atom                         { *astpp = $$ = $1; }
    ;
atom: CSLAYOUT_TOKEN_ATTR          { *astpp = $$ = $1; }
    | CSLAYOUT_TOKEN_NUMBER        { *astpp = $$ = $1; }
    | CSLAYOUT_TOKEN_PERCENTAGE    { *astpp = $$ = $1; }
    | CSLAYOUT_TOKEN_COORD         { *astpp = $$ = $1; }
    | '(' expr ')'                 { *astpp = $$ = $2; }
    ;

%%

void cslayouterror(void *scanner, CSLAYOUT_AST **astpp, int *argc, char *s) {
  fprintf(stderr, "%s\n", s);
}

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
