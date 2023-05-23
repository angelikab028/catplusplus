all: catnip
compiler.tab.c compiler.tab.h: compiler.y
	bison -t -v -d compiler.y
lex.yy.c: lexer.lex compiler.tab.h
	flex lexer.lex
catnip: lex.yy.c compiler.tab.c compiler.tab.h
	g++ -o catnip compiler.tab.c lex.yy.c -lfl

$(info ******************* RUN USING ./catnip filename.meow *******************)
clean:
	rm -f a.out catnip lex.yy.c compiler.tab.c compiler.tab.h compiler.output compiler.tab.c compiler.tab.h test.mil