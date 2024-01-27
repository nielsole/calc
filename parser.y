%{
#include <stdio.h>
void yyerror(char *s);
int yylex();
int result;
%}

%union {int num;}
%start line
%token NUMBER END
%type <num> expression number NUMBER addexpr multexpr
%left '+'
%left '*'

%%

line : expression END { printf("%d", $1); } ;

expression : multexpr 
           | addexpr
           | number
           ;


multexpr : expression '*' expression { $$ = $1 * $3; } ;
addexpr : expression '+' expression { $$ = $1 + $3; } ;

number : NUMBER
       ;

%%
void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main (void)
{
  return yyparse ();
}
