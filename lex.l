%{
#include <stdio.h>
#include "parser.h"

void lex_error(char *text);
%}

%option noyywrap
%option reentrant
%option bison-bridge
%option prefix="cslayout"
%option header-file="lex.h"
%option noinput
%option nounput

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
.            { lex_error(yytext); }

%%

void lex_error(char *text) {
    fprintf(stderr, "Unrecognized text %s\n", text);
}
