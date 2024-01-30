%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
void yyerror(char *s);
int yylex();
double result;
double get_constant(char *s);
%}

%union {double num; char *s;}
%start lines
%token NUMBER END CONSTANT
%type <num> expression number NUMBER addexpr multexpr divexpr minusexpr parenthesis prefix prefixes expexpr modexpr
%type <s>  CONSTANT
%left '+' '-'
%left '*' '/' '%'
%left '^'
%left '(' ')'

%%

lines : line END lines
        | line END

line : expression { result = $1; printf("%.10g\n", $1); } ;

expression : multexpr 
           | divexpr
           | addexpr
           | minusexpr
           | expexpr
           | modexpr
           | parenthesis
           | prefixes number { $$ = $1 * $2; }
           | number
           ;

parenthesis : '(' expression ')' { $$ = $2; }
    ;
multexpr : expression '*' expression { $$ = $1 * $3; } ;
divexpr : expression '/' expression { $$ = $1 / $3; } ;
addexpr : expression '+' expression { $$ = $1 + $3; } ;
minusexpr : expression '-' expression { $$ = $1 - $3; } ;
expexpr : expression '^' expression { $$ = pow($1, $3); } ;
modexpr : expression '%' expression { $$ = fmod($1, $3); } ;

number : NUMBER
       | CONSTANT { $$ = get_constant($1); }
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

void stringupper(char * temp) {
  char * name;
  name = strtok(temp,":");

  // Convert to upper case
  char *s = name;
  while (*s) {
    *s = toupper((unsigned char) *s);
    s++;
  }

}

double get_constant(char *s) {
    stringupper(s);
    if (strcmp(s, "PI") == 0) {
        return M_PI;
    }
    if (strcmp(s, "ANS") == 0) {
        return result;
    }
    yyerror(s);
    return 0.0d;
}

int main (void)
{
  return yyparse ();
}
