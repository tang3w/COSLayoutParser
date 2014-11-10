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
attr tt|tb|ll|lr|bb|bt|rr|rl|ct|cl
digit [-+]?{i}
float [-+]?({i}\.{i}?|{i}?\.{i})
number {digit}|{float}[fF]?
percentage ({digit}|{float})%
coord_name {attr}|width|height
coord %{coord_name}

%%

[ \n\r\t]

"="          { return '='; }
"+"          { return '+'; }
"-"          { return '-'; }
"*"          { return '*'; }
"/"          { return '/'; }

{attr}       {
                 CSLAYOUT_AST *ast = *yylval = cslayout_create_ast(ATTR, NULL, NULL);

                 ast->value.coord = (char *)malloc((strlen(yytext) + 1) * sizeof(char));
                 strcpy(ast->value.coord, yytext);

                 return ATTR;
             }

{number}     {
                 CSLAYOUT_AST *ast = *yylval = cslayout_create_ast(NUMBER, NULL, NULL);

                 ast->value.number = atof(yytext);

                 return NUMBER;
             }

{percentage} {
                 CSLAYOUT_AST *ast = *yylval = cslayout_create_ast(PERCENTAGE, NULL, NULL);

                 ast->value.percentage = atof(yytext);

                 return PERCENTAGE;
             }

{coord}      {
                 CSLAYOUT_AST *ast = *yylval = cslayout_create_ast(COORD, NULL, NULL);

                 ast->value.coord = (char *)malloc((strlen(yytext + 1) + 1) * sizeof(char));
                 strcpy(ast->value.coord, yytext + 1);
                 *argc += 1;

                 return COORD;
             }

.            { lex_error(yytext); }

%%

void lex_error(char *text) {
    fprintf(stderr, "Unrecognized text %s\n", text);
}
