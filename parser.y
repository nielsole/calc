%{
#include <stdio.h>
void yyerror(char *s);
int yylex();
int result;
%}

%union {int num;}
%start line
%token NUMBER END
%type <num> expression number NUMBER addexpr multexpr divexpr minusexpr
%left '+' '-'
%left '*' '/'

%%

line : expression END { printf("%d", $1); } ;

expression : multexpr 
           | divexpr
           | addexpr
           | minusexpr
           | number
           ;


multexpr : expression '*' expression { $$ = $1 * $3; } ;
divexpr : expression '/' expression { $$ = $1 / $3; } ;
addexpr : expression '+' expression { $$ = $1 + $3; } ;
minusexpr : expression '-' expression { $$ = $1 + $3; } ;

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
