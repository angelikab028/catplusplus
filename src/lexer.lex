%{
#include <stdio.h>
// #define YY_USER_ACTION ++ctr[yy_act];
// int ctr[YY_NUM_RULES];
int lineNumber = 1; 
int columnNumber = 0;
%}

DIGIT [0-9]
PLUS "+"
MINUS "-"
MULT "*"
DIV "/"
LEFT_PARENTHESIS "("
RIGHT_PARENTHESIS ")"
ASSIGN "="
NEWLINE "\n"
WHITESPACE [ \t]

%%  
.             { 
                printf("UNRECOGNIZED TOKEN %s AT LINE %d\n", yytext, lineNumber++); 
                return; 
              }
%%

int main(int argc, char* argv[]) {
    ++argv;
    --argc;
     if ( argc > 0 )
            yyin = fopen( argv[0], "r" );
    else
            yyin = stdin;
    printf("Ctrl + D to quit\n");
    yylex();
}
