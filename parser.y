%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include <unistd.h>
#include <readline/readline.h>
#include <readline/history.h>

char *line_read = NULL;
void yyerror(char *s);
int yylex();
double result = 0;  // Initialize to 0
static int first_run = 1;  // Track if this is first calculation
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
        ;

line : expression { 
        result = $1;
        if (isatty(0)) {
            printf("%.10g\n🧮 ", $1);
            fflush(stdout);
        } else {
            printf("%.10g\n", $1);
        }
        first_run = 0;  // Mark that we've done at least one calculation
    }
     | /* empty */ { 
        if (isatty(0)) {
            printf("error\n🧮 ");
            fflush(stdout);
        } else {
            printf("error\n");
        }
        exit(1);
    }
     ;

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
           | '(' ')' { printf("error\n"); exit(1); }
           | '(' error ')' { printf("error\n"); exit(1); }
           ;

multexpr : expression '*' expression { $$ = $1 * $3; } ;

divexpr : expression '/' expression { 
            if ($3 == 0) {
                printf("error\n");
                exit(1);
            }
            $$ = $1 / $3; 
        } ;

addexpr : expression '+' expression { $$ = $1 + $3; } ;

minusexpr : expression '-' expression { $$ = $1 - $3; } ;

expexpr : expression '^' expression { $$ = pow($1, $3); } ;

modexpr : expression '%' expression { 
            if ($3 == 0) {
                printf("error\n");
                exit(1);
            }
            $$ = fmod($1, $3); 
        } ;

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
    if (isatty(0)) {
        printf("error\n🧮 ");
        fflush(stdout);
    } else {
        printf("error\n");
    }
    exit(1);
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
        if (first_run) {
            printf("error\n");
            exit(1);
        }
        return result;
    }
    printf("error\n");
    exit(1);
}

int main(void) {
    if (isatty(0)) {  /* If input is from terminal */
        // Initialize readline
        rl_bind_key('\t', rl_insert);
        using_history();
        printf("🧮 ");
        fflush(stdout);
    }
    return yyparse();
}
