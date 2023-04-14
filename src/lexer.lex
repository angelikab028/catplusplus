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
FUNCTION "purr"
INTEGER "meow"
SEMICOLON ":3"
BREAK "neuter"
CONTINUE "keep_going"
IF "purrhaps"
FOR "fur"
TRUE "furreal"
FALSE "hiss"
COMMENT "O_O"([ \t]?.)*
PRINT "scratch"
READ "litter"
RETURN "knead"
WHILE "hunt"
MOD "%"
ELSE "else"
COMMA ","
LEFT_SQUARE_BRACKET "["
RIGHT_SQUARE_BRACKET "]"
LEFT_CURLY "{"
RIGHT_CURLY "}"
EQUALS "=="
LESSTHAN "<"
GREATERTHAN ">"
LESSOREQUAL "<="
GREATOREQUAL ">="
VOID "hairball"
IDENTIFIER [a-zA-z]([a-zA-z]|[0-9])*
NUMBER [\+-]?[0-9]+


%%
{COMMENT} {
        printf("TOKEN COMMENT: %s", yytext);
        columnNumber += yyleng;
}

{NEWLINE} {
        columnNumber = 0;
        lineNumber++;
}

.+ { 
        printf("UNRECOGNIZED TOKEN %s AT LINE %d, COLUMN %d\n", yytext, lineNumber, columnNumber); 
        //return; 
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
