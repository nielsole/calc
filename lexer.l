%option noyywrap
%{
#include <string.h>
#include "parser.tab.h"
%}

%%

[0-9]+([.][0-9]+)?  { yylval.num = atof(yytext); return NUMBER; }
[a-zA-Z]+           { yylval.s = strdup(yytext); return CONSTANT; }
[ \t]               ; /* Skip whitespace */
\n                  { return END; }
.                   { return yytext[0]; }

%%
