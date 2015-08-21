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
percentage ([HV]:)?({digit}|{float})%
attr [_a-z][_a-z0-9-]*
coord %(tt|tb|ll|lr|bb|bt|rr|rl|ct|cl|cb|cr|w|h|f|p|\^f|\^p|:f|:p)

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
                 float value = 0.0;
                 int   type  = COSLAYOUT_TOKEN_PERCENTAGE;

                 switch(yytext[0]) {
                 case 'H':
                     value = atof(yytext + 2);
                     type  = COSLAYOUT_TOKEN_PERCENTAGE_H;
                     break;

                 case 'V':
                     value = atof(yytext + 2);
                     type  = COSLAYOUT_TOKEN_PERCENTAGE_V;
                     break;

                 default:
                     value = atof(yytext);
                     break;
                 }

                 COSLAYOUT_AST *ast = *yylval = coslayout_create_ast(type, NULL, NULL);

                 ast->value.percentage = value;

                 return type;
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
