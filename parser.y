%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
void yyerror(char *s);
int yylex();
int result;
%}

%union {double num;}
%start lines
%token NUMBER END
%type <num> expression number NUMBER addexpr multexpr divexpr minusexpr parenthesis prefix prefixes expexpr
%left '+' '-'
%left '*' '/'
%left '^'
%left '(' ')'

%%

lines : line END lines
        | line END

line : expression { printf("%.10g\n", $1); } ;

expression : multexpr 
           | divexpr
           | addexpr
           | minusexpr
           | expexpr
           | parenthesis
           | number
           ;

parenthesis : '(' expression ')' { $$ = $2; }
    ;
multexpr : expression '*' expression { $$ = $1 * $3; } ;
divexpr : expression '/' expression { $$ = $1 / $3; } ;
addexpr : expression '+' expression { $$ = $1 + $3; } ;
minusexpr : expression '-' expression { $$ = $1 - $3; } ;
expexpr : expression '^' expression { $$ = pow($1, $3); } ;

number : NUMBER
        | prefixes NUMBER { $$ = $1 * $2; }
       ;

prefixes: prefix prefixes { $$ = $1 * $2; }
    | prefix
    ;

prefix : '-' { $$ = -1; }
    | '+' { $$ = 1; }
    ;

%%
void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main (void)
{
  return yyparse ();
}
