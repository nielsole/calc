%option noyywrap
%{
#include "parser.tab.h"
%}

%%

[0-9]+([.][0-9]+)?  { yylval.num = atof(yytext); return NUMBER; }
[A-Z]+              { yylval.s = yytext; return CONSTANT; }
\n      { return END; }
.       { return yytext[0]; }

%%
