%option noyywrap
%{
#include "y.tab.h"
%}

%%

[0-9]+  { yylval = atoi(yytext); return NUMBER; }
\n      { return END; }
.       { return yytext[0]; }

%%
