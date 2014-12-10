parser: main.c COSLayoutParser.c COSLayoutLex.o
	cc -o $@ $^

COSLayoutParser.c COSLayoutParser.h: COSLayoutParser.y
	bison -d -o COSLayoutParser.c $^

COSLayoutLex.o: COSLayoutLex.c COSLayoutParser.h
	cc -c -o $@ $<

COSLayoutLex.c: COSLayoutLex.l
	flex -o $@ $<

clean:
	rm -f COSLayoutLex.h COSLayoutLex.c COSLayoutLex.o COSLayoutParser.h COSLayoutParser.c parser
