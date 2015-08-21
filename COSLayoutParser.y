%{
#include <stdio.h>
#include "COSLayoutParser.h"
#include "COSLayoutLex.h"

void coslayouterror(void *scanner, COSLAYOUT_AST **astpp, char *msg);
int coslayoutlex(YYSTYPE *lvalp, void *scanner, COSLAYOUT_AST **astpp);
%}

%define api.pure full
%lex-param {void *scanner}
%lex-param {COSLAYOUT_AST **astpp}
%parse-param {void *scanner}
%parse-param {COSLAYOUT_AST **astpp}
%define api.prefix {coslayout}
%define api.value.type {COSLAYOUT_AST *}

%code requires {
#define YYSTYPE COSLAYOUTSTYPE

#define YY_DECL int coslayoutlex \
    (YYSTYPE *yylval_param, yyscan_t yyscanner, COSLAYOUT_AST **astpp)

struct COSLAYOUT_AST {
    int node_type;
    struct COSLAYOUT_AST *l;
    struct COSLAYOUT_AST *r;
    union {
        float number;
        float percentage;
        char *coord;
    } value;
    void *data;
};

typedef struct COSLAYOUT_AST COSLAYOUT_AST;

COSLAYOUT_AST *coslayout_create_ast(int type, COSLAYOUT_AST *l, COSLAYOUT_AST *r);

int coslayout_parse_rule(char *rule, COSLAYOUT_AST **astpp);
void coslayout_destroy_ast(COSLAYOUT_AST *astp);
}

%token COSLAYOUT_TOKEN_ATTR;
%token COSLAYOUT_TOKEN_NUMBER;
%token COSLAYOUT_TOKEN_PERCENTAGE;
%token COSLAYOUT_TOKEN_PERCENTAGE_H;
%token COSLAYOUT_TOKEN_PERCENTAGE_V;
%token COSLAYOUT_TOKEN_COORD;
%token COSLAYOUT_TOKEN_COORD_PERCENTAGE;
%token COSLAYOUT_TOKEN_COORD_PERCENTAGE_H;
%token COSLAYOUT_TOKEN_COORD_PERCENTAGE_V;

%left  '+' '-'
%left  '*' '/'
%right '='

%%

expr: %empty
    | error                         { coslayout_destroy_ast(*astpp); *astpp = NULL; YYABORT; }
    | COSLAYOUT_TOKEN_ATTR '=' expr { *astpp = $$ = coslayout_create_ast('=', $1, $3); }
    | rval                          { *astpp = $$ = $1; }
    ;
rval: rval '+' item                 { *astpp = $$ = coslayout_create_ast('+', $1, $3); }
    | rval '-' item                 { *astpp = $$ = coslayout_create_ast('-', $1, $3); }
    | item                          { *astpp = $$ = $1; }
    ;
item: item '*' atom                 { *astpp = $$ = coslayout_create_ast('*', $1, $3); }
    | item '/' atom                 { *astpp = $$ = coslayout_create_ast('/', $1, $3); }
    | atom                          { *astpp = $$ = $1; }
    ;
atom: COSLAYOUT_TOKEN_ATTR          { *astpp = $$ = $1; }
    | COSLAYOUT_TOKEN_NUMBER        { *astpp = $$ = $1; }
    | COSLAYOUT_TOKEN_PERCENTAGE    { *astpp = $$ = $1; }
    | COSLAYOUT_TOKEN_PERCENTAGE_H  { *astpp = $$ = $1; }
    | COSLAYOUT_TOKEN_PERCENTAGE_V  { *astpp = $$ = $1; }
    | COSLAYOUT_TOKEN_COORD         { *astpp = $$ = $1; }
    | COSLAYOUT_TOKEN_COORD_PERCENTAGE   { *astpp = $$ = $1; }
    | COSLAYOUT_TOKEN_COORD_PERCENTAGE_H { *astpp = $$ = $1; }
    | COSLAYOUT_TOKEN_COORD_PERCENTAGE_V { *astpp = $$ = $1; }
    | '(' expr ')'                  { *astpp = $$ = $2; }
    ;

%%

void coslayouterror(void *scanner, COSLAYOUT_AST **astpp, char *msg) {
  fprintf(stderr, "COSLayout: %s\n", msg);
}

int coslayoutparse (void *scanner, COSLAYOUT_AST **astpp);
int coslayoutlex_init (yyscan_t* scanner);
int coslayoutlex_destroy (yyscan_t yyscanner);

COSLAYOUT_AST *coslayout_create_ast(int type, COSLAYOUT_AST *l, COSLAYOUT_AST *r) {
    COSLAYOUT_AST *astp = (COSLAYOUT_AST *)malloc(sizeof(COSLAYOUT_AST));

    astp->node_type = type;
    astp->l = l;
    astp->r = r;
    astp->value.coord = NULL;
    astp->data = NULL;

    return astp;
}

int coslayout_parse_rule(char *rule, COSLAYOUT_AST **astpp) {
    yyscan_t scanner;
    coslayoutlex_init(&scanner);
    YY_BUFFER_STATE state = coslayout_scan_string(rule, scanner);

    int result = coslayoutparse(scanner, astpp);

    coslayout_delete_buffer(state, scanner);
    coslayoutlex_destroy(scanner);

    if (result) {
        coslayout_destroy_ast(*astpp);
        *astpp = NULL;
    }

    return result;
}

void coslayout_destroy_ast(COSLAYOUT_AST *astp) {
    if (astp != NULL) {
        coslayout_destroy_ast(astp->l);
        coslayout_destroy_ast(astp->r);

        int type = astp->node_type;
        char *coord = astp->value.coord;

        if ((type == COSLAYOUT_TOKEN_ATTR || type == COSLAYOUT_TOKEN_COORD) && coord != NULL)
            free(coord);

        free(astp);
    }
}
