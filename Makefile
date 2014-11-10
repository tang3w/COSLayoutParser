parser: main.c CSLayoutParser.c CSLayoutLex.o
	cc -o $@ $^

CSLayoutParser.c CSLayoutParser.h: CSLayoutParser.y
	bison -d -o CSLayoutParser.c $^

CSLayoutLex.o: CSLayoutLex.c CSLayoutParser.h
	cc -c -o $@ $<

CSLayoutLex.c: CSLayoutLex.l
	flex -o $@ $<

clean:
	rm -f CSLayoutLex.h CSLayoutLex.c CSLayoutLex.o CSLayoutParser.h CSLayoutParser.c parser
