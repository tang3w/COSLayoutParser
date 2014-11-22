%{
#include <stdio.h>
#include "CSLayoutParser.h"
%}

%option noyywrap
%option reentrant
%option bison-bridge
%option prefix="cslayout"
%option header-file="CSLayoutLex.h"
%option noinput
%option nounput

i [0-9]+
digit [-+]?{i}
float [-+]?({i}\.{i}?|{i}?\.{i})
number {digit}|{float}[fF]?
percentage ({digit}|{float})%
name tt|tb|ll|lr|bb|bt|rr|rl|ct|cl
attr {name}|minw|maxw|minh|maxh
coord %({name}|w|h|f)

%%

[ \n\r\t]

"="          { return '='; }
"+"          { return '+'; }
"-"          { return '-'; }
"*"          { return '*'; }
"/"          { return '/'; }
"("          { return '('; }
")"          { return ')'; }

{attr}       {
                 CSLAYOUT_AST *ast = *yylval = cslayout_create_ast(CSLAYOUT_TOKEN_ATTR, NULL, NULL);

                 ast->value.coord = (char *)malloc((strlen(yytext) + 1) * sizeof(char));
                 strcpy(ast->value.coord, yytext);

                 return CSLAYOUT_TOKEN_ATTR;
             }

{number}     {
                 CSLAYOUT_AST *ast = *yylval = cslayout_create_ast(CSLAYOUT_TOKEN_NUMBER, NULL, NULL);

                 ast->value.number = atof(yytext);

                 return CSLAYOUT_TOKEN_NUMBER;
             }

{percentage} {
                 CSLAYOUT_AST *ast = *yylval = cslayout_create_ast(CSLAYOUT_TOKEN_PERCENTAGE, NULL, NULL);

                 ast->value.percentage = atof(yytext);

                 return CSLAYOUT_TOKEN_PERCENTAGE;
             }

{coord}      {
                 CSLAYOUT_AST *ast = *yylval = cslayout_create_ast(CSLAYOUT_TOKEN_COORD, NULL, NULL);

                 ast->value.coord = (char *)malloc((strlen(yytext + 1) + 1) * sizeof(char));
                 strcpy(ast->value.coord, yytext + 1);

                 return CSLAYOUT_TOKEN_COORD;
             }

.            {
                 fprintf(stderr, "CSLayout: unrecognized text %s\n", yytext);
             }

%%
