%{
#include <stdio.h>
#include "CSLayoutParser.h"
#include "CSLayoutLex.h"

void cslayouterror(void *scanner, CSLAYOUT_AST **astpp, char *msg);
int cslayoutlex(YYSTYPE *lvalp, void *scanner, CSLAYOUT_AST **astpp);
%}

%define api.pure full
%lex-param {void *scanner}
%lex-param {CSLAYOUT_AST **astpp}
%parse-param {void *scanner}
%parse-param {CSLAYOUT_AST **astpp}
%define api.prefix {cslayout}
%define api.value.type {CSLAYOUT_AST *}

%code requires {
#define YYSTYPE CSLAYOUTSTYPE

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

int cslayout_parse_rule(char *rule, CSLAYOUT_AST **astpp);
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
    | error                        { cslayout_destroy_ast(*astpp); *astpp = NULL; YYABORT; }
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

void cslayouterror(void *scanner, CSLAYOUT_AST **astpp, char *msg) {
  fprintf(stderr, "CSLayout: %s\n", msg);
}

int cslayoutparse (void *scanner, CSLAYOUT_AST **astpp);
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

int cslayout_parse_rule(char *rule, CSLAYOUT_AST **astpp) {
    yyscan_t scanner;
    cslayoutlex_init(&scanner);
    YY_BUFFER_STATE state = cslayout_scan_string(rule, scanner);

    int result = cslayoutparse(scanner, astpp);

    cslayout_delete_buffer(state, scanner);
    cslayoutlex_destroy(scanner);

    if (result) {
        cslayout_destroy_ast(*astpp);
        *astpp = NULL;
    }

    return result;
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
