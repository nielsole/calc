%{
#include <stdio.h>
void yyerror(char *s);
int yylex();
int result;
%}

%union {int num;}
%start lines
%token NUMBER END
%type <num> expression number NUMBER addexpr multexpr divexpr minusexpr parenthesis
%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

lines : line lines
        | line END

line : expression END { printf("%d\n", $1); } ;

expression : multexpr 
           | divexpr
           | addexpr
           | minusexpr
           | parenthesis
           | number
           ;

parenthesis : '(' expression ')' { $$ = $2; }
    ;
multexpr : expression '*' expression { $$ = $1 * $3; } ;
divexpr : expression '/' expression { $$ = $1 / $3; } ;
addexpr : expression '+' expression { $$ = $1 + $3; } ;
minusexpr : expression '-' expression { $$ = $1 - $3; } ;

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
