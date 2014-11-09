%{
#include <stdio.h>
#include "context.h"
#include "parser.h"

void cslayouterror(void *scanner, CSLAYOUT_AST **astpp, char *s);
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
#include "context.h"

#define YYSTYPE CSLAYOUTSTYPE
}

%token ATTR;
%token NUMBER;
%token PERCENTAGE;
%token COORD;

%left  '+' '-'
%left  '*' '/'
%right '='

%%

expr: %empty
    | ATTR '=' expr { *astpp = $$ = cslayout_create_ast('=', $1, $3); }
    | rval          { *astpp = $$ = $1; }
    ;
rval: rval '+' item { *astpp = $$ = cslayout_create_ast('+', $1, $3); }
    | rval '-' item { *astpp = $$ = cslayout_create_ast('-', $1, $3); }
    | item          { *astpp = $$ = $1; }
    ;
item: item '*' atom { *astpp = $$ = cslayout_create_ast('*', $1, $3); }
    | item '/' atom { *astpp = $$ = cslayout_create_ast('/', $1, $3); }
    | atom          { *astpp = $$ = $1; }
    ;
atom: NUMBER        { *astpp = $$ = $1; }
    | PERCENTAGE    { *astpp = $$ = $1; }
    | COORD         { *astpp = $$ = $1; }
    ;

%%

void cslayouterror(void *scanner, CSLAYOUT_AST **astpp, char *s) {
  fprintf(stderr, "%s\n", s);
}
