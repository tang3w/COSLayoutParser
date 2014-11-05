%{
#include "common.h"
%}

%token NAME;

%%

rule: rule ',' expr
    | expr
    ;
expr: NAME '=' term
    |
    ;
term: NAME '=' term
    | rval
    ;
rval: '0' ;

%%

void yyerror (char const *s) {
  fprintf(stderr, "%s\n", s);
}

int main(int argc, char **argv) {
    if(!yyparse()) {
        fprintf(stdout, "Success!\n");
    }

    return 0;
}
