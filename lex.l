%{
#include "parser.h"
#include "common.h"

void lex_error(void);
%}

%option noyywrap
%option noinput
%option nounput
%option prefix="cslayout"

i [0-9]+
name tt|tb|ll|lr|bb|bt|rr|rl|ct|cl|cb|cr|cc
digit [-+]?{i}
float [-+]?({i}\.{i}?|{i}?\.{i})
number {digit}|{float}[fF]?
percentage ({digit}|{float})%
coord $\.{name}

%%

[ \n\r\t]
","          { return ','; }
"="          { return '='; }
"+"          { return '+'; }
"-"          { return '-'; }
"*"          { return '*'; }
"/"          { return '/'; }
{name}       { return NAME; }
{number}     { return NUMBER; }
{percentage} { return PERCENTAGE; }
{coord}      { return COORD; }
.            { lex_error(); }

%%

void lex_error(void) {
    fprintf(stderr, "unrecognized character %s\n", yytext);
    exit(1);
}
