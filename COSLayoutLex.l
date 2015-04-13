%{
#include <stdio.h>
#include "COSLayoutParser.h"
%}

%option noyywrap
%option reentrant
%option bison-bridge
%option prefix="coslayout"
%option header-file="COSLayoutLex.h"
%option noinput
%option nounput

i [0-9]+
digit [-+]?{i}
float [-+]?({i}\.{i}?|{i}?\.{i})
number {digit}|{float}[fF]?
percentage ({digit}|{float})%
name tt|tb|ll|lr|bb|bt|rr|rl|ct|cl|cb|cr
attr {name}|minw|maxw|minh|maxh
coord %({name}|w|h|f|p|\^f|\^p)

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
                 COSLAYOUT_AST *ast = *yylval = coslayout_create_ast(COSLAYOUT_TOKEN_ATTR, NULL, NULL);

                 ast->value.coord = (char *)malloc((strlen(yytext) + 1) * sizeof(char));
                 strcpy(ast->value.coord, yytext);

                 return COSLAYOUT_TOKEN_ATTR;
             }

{number}     {
                 COSLAYOUT_AST *ast = *yylval = coslayout_create_ast(COSLAYOUT_TOKEN_NUMBER, NULL, NULL);

                 ast->value.number = atof(yytext);

                 return COSLAYOUT_TOKEN_NUMBER;
             }

{percentage} {
                 COSLAYOUT_AST *ast = *yylval = coslayout_create_ast(COSLAYOUT_TOKEN_PERCENTAGE, NULL, NULL);

                 ast->value.percentage = atof(yytext);

                 return COSLAYOUT_TOKEN_PERCENTAGE;
             }

{coord}      {
                 COSLAYOUT_AST *ast = *yylval = coslayout_create_ast(COSLAYOUT_TOKEN_COORD, NULL, NULL);

                 ast->value.coord = (char *)malloc((strlen(yytext + 1) + 1) * sizeof(char));
                 strcpy(ast->value.coord, yytext + 1);

                 return COSLAYOUT_TOKEN_COORD;
             }

.            {
                 fprintf(stderr, "COSLayout: unrecognized text %s\n", yytext);
             }

%%
