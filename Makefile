parser: parser.c lex.o
	cc -o $@ $^

parser.c parser.h: parser.y
	bison -d -o parser.c $^

lex.o: lex.c parser.h
	cc -c -o $@ $<

lex.c: lex.l
	flex -o $@ $<
