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

{FUNCTION} {
        printf("TOKEN FUNCTION: %s\n", yytext);
        columnNumber += yyleng;
}

{INTEGER} {
        printf("TOKEN INTEGER: %s\n", yytext);
        columnNumber += yyleng;
}

{SEMICOLON} {
        printf("TOKEN SEMICOLON: %s\n", yytext);
        columnNumber += yyleng;
}

{IDENTIFIER} {
        printf("TOKEN IDENTIFIER: %s\n", yytext);
        columnNumber += yyleng;
}

{COMMENT} {
        printf("TOKEN COMMENT: %s\n", yytext);
        columnNumber += yyleng;
}

{WHITESPACE} {
        columnNumber += yyleng;
}

{NEWLINE} {
        columnNumber = 0;
        lineNumber++;
}

. { 
        printf("UNRECOGNIZED TOKEN AT LINE %d, COLUMN %d: %s\n", lineNumber, columnNumber, yytext); 
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
