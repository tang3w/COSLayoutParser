%{
#include "common.h"
%}

%define api.prefix {cs_layout_}

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

void cs_layout_error (char const *s) {
  fprintf(stderr, "%s\n", s);
}
