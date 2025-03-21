%option noyywrap
%{
#include <string.h>
#include <unistd.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "parser.tab.h"

extern char *line_read;
char *input_buffer = NULL;
int buffer_pos = 0;

/* Custom input function for flex using readline */
int custom_input(char *buf, int max_size) {
    static FILE *input_source = NULL;
    
    if (!input_source) {
        input_source = stdin;
    }
    
    if (!input_buffer || !input_buffer[buffer_pos]) {
        if (input_buffer) {
            free(input_buffer);
            input_buffer = NULL;
        }
        
        if (isatty(0)) {
            line_read = readline("");
            if (line_read && *line_read) {
                add_history(line_read);
                input_buffer = strdup(line_read);
                free(line_read);
                strcat(input_buffer, "\n");
            } else if (line_read) {
                free(line_read);
                input_buffer = strdup("\n");
            } else {
                return 0;
            }
        } else {
            char temp[1024];
            if (!fgets(temp, sizeof(temp), input_source)) {
                return 0;
            }
            input_buffer = strdup(temp);
        }
        
        buffer_pos = 0;
    }
    
    int n = strlen(input_buffer + buffer_pos);
    if (n > max_size) n = max_size;
    
    if (n > 0) {
        memcpy(buf, input_buffer + buffer_pos, n);
        buffer_pos += n;
    }
    
    return n;
}

#define YY_INPUT(buf,result,max_size) result = custom_input(buf, max_size)
%}

%%

[0-9]+([.][0-9]+)?  { yylval.num = atof(yytext); return NUMBER; }
[a-zA-Z]+           { yylval.s = strdup(yytext); return CONSTANT; }
[ \t]               ; /* Skip whitespace */
\n                  { return END; }
.                   { return yytext[0]; }

%%
