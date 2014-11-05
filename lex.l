%{
#include "parser.h"
#include "common.h"

void lex_error(void);
%}

%option noyywrap

name tt|tb|ll|lr|bb|bt|rr|rl|ct|cl|cb|cr|cc

%%

[ \n\r\t]
","    { return ','; }
"="    { return '='; }
{name} { return NAME; }
"0"    { return '0'; }
.      { lex_error(); }

%%

void lex_error(void) {
    fprintf(stderr, "unrecognized character %s\n", yytext);
    exit(1);
}
