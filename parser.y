%{
#include "common.h"
#include "parser.h"

void cslayouterror(void *scanner, char *s);
int cslayoutlex(YYSTYPE *lvalp, void *scanner);
%}

%define api.pure full
%lex-param {void *scanner}
%parse-param {void *scanner}
%define api.prefix {cslayout}

%token NAME;
%token NUMBER;
%token PERCENTAGE;
%token COORD;

%left  '+' '-'
%left  '*' '/'
%right '='

%%

rule: rule ',' expr
    | expr
    ;
expr: NAME '=' term
    | %empty
    ;
term: NAME '=' term
    | rval
    ;
rval: rval '+' item
    | rval '-' item
    | item
    ;
item: item '*' atom
    | item '/' atom
    | atom
    ;
atom: NUMBER
    | PERCENTAGE
    | COORD
    ;

%%

void cslayouterror(void *scanner, char *s) {
  fprintf(stderr, "%s\n", s);
}
