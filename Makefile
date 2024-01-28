default:
	bison -d parser.y -Wcounterexamples && lex lexer.l && gcc lex.yy.c parser.tab.c -o mylang

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h mylang