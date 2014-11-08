%{
#include <stdio.h>
#include "context.h"
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
"="          { return '='; }
"+"          { return '+'; }
"-"          { return '-'; }
"*"          { return '*'; }
"/"          { return '/'; }
{name}       { return NAME; }

{number}     {
                 CSLAYOUT_AST *ast = cslayout_create_ast(NUMBER, NULL, NULL);
                 ast->value.number = atof(yytext);
                 *yylval = ast;
                 return NUMBER;
             }

{percentage} {
                 CSLAYOUT_AST *ast = cslayout_create_ast(PERCENTAGE, NULL, NULL);
                 ast->value.percentage = atof(yytext);
                 *yylval = ast;
                 return PERCENTAGE;
             }

{coord}      {
                 CSLAYOUT_AST *ast = cslayout_create_ast(COORD, NULL, NULL);

                 ast->coord = (char *)malloc((strlen(yytext + 2) + 1) * sizeof(char));
                 strcpy(ast->coord, yytext + 2);

                 *yylval = ast;
                 return COORD;
             }

.            { lex_error(yytext); }

%%

void lex_error(char *text) {
    fprintf(stderr, "Unrecognized text %s\n", text);
}
