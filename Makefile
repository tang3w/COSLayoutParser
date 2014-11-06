parser: main.c parser.c lex.o
	cc -o $@ $^

parser.c parser.h: parser.y
	bison -d -o parser.c $^

lex.o: lex.c parser.h
	cc -c -o $@ $<

lex.c: lex.l
	flex -o $@ $<

clean:
	rm -f lex.h lex.c lex.o parser.h parser.c parser
