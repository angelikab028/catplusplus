all:
	flex lexer.lex
	bison -v -d	--file-prefix=y compiler.y
	gcc lex.yy.c y.tab.c -lfl
	$(info ******************* RUN USING ./a.out filename.meow *******************)
clean:
	rm -f a.out lex.yy.c y.tab.c y.tab.h y.output