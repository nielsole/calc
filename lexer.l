%option noyywrap
%{
#include "parser.tab.h"
%}

%%

[0-9]+([.][0-9]+)?  { yylval.num = atof(yytext); return NUMBER; }
\n      { return END; }
.       { return yytext[0]; }

%%
