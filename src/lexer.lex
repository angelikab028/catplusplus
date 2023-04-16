%{
#include <stdio.h>
// #define YY_USER_ACTION ++ctr[yy_act];
// int ctr[YY_NUM_RULES];
int lineNumber = 1; 
int columnNumber = 0;
%}

DIGIT [0-9]
ADD "+"
SUB "-"
MULT "*"
DIV "/"
LEFT_PARENTHESIS "("
RIGHT_PARENTHESIS ")"
ASSIGN "="
NEWLINE "\n"
WHITESPACE [ \t]+
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
IDENTIFIER [a-zA-Z][a-zA-Z0-9]*
INVALIDIDENTIFIER [0-9]+{IDENTIFIER}

%%

[+-]?{DIGIT}+ {
        printf("TOKEN NUMBER: %s\n", yytext);
        columnNumber += yyleng;
        yyless(yyleng);
}

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

{BREAK} {
        printf("TOKEN BREAK: %s\n", yytext);
        columnNumber += yyleng;
}

{CONTINUE} {
        printf("TOKEN CONTINUE: %s\n", yytext);
        columnNumber += yyleng;
}

{IF} {
        printf("TOKEN IF: %s\n", yytext);
        columnNumber += yyleng;
}

{FOR} {
        printf("TOKEN FOR: %s\n", yytext);
        columnNumber += yyleng;
}

{TRUE} {
        printf("TOKEN TRUE: %s\n", yytext);
        columnNumber += yyleng;
}

{FALSE} {
        printf("TOKEN FALSE: %s\n", yytext);
        columnNumber += yyleng;
}

{PRINT} {
        printf("TOKEN PRINT: %s\n", yytext);
        columnNumber += yyleng;
}

{READ} {
        printf("TOKEN READ: %s\n", yytext);
        columnNumber += yyleng;
}

{RETURN} {
        printf("TOKEN RETURN: %s\n", yytext);
        columnNumber += yyleng;
}

{WHILE} {
        printf("TOKEN WHILE: %s\n", yytext);
        columnNumber += yyleng;
}

{VOID} {
        printf("TOKEN VOID: %s\n", yytext);
        columnNumber += yyleng;
}

{ASSIGN} {
        printf("TOKEN ASSIGN: %s\n", yytext);
        columnNumber += yyleng;
}

{SUB} {
        printf("TOKEN SUB: %s\n", yytext);
        columnNumber += yyleng;
}

{ADD} {
        printf("TOKEN ADD: %s\n", yytext);
        columnNumber += yyleng;
}

{MULT} {
        printf("TOKEN MULT: %s\n", yytext);
        columnNumber += yyleng;
}

{DIV} {
        printf("TOKEN DIV: %s\n", yytext);
        columnNumber += yyleng;
}

{MOD} {
        printf("TOKEN MOD: %s\n", yytext);
        columnNumber += yyleng;
}

{ELSE} {
        printf("TOKEN ELSE: %s\n", yytext);
        columnNumber += yyleng;
}

{COMMA} {
        printf("TOKEN COMMA: %s\n", yytext);
        columnNumber += yyleng;
}

{LEFT_PARENTHESIS} {
        printf("TOKEN LEFT_PARENTHESIS: %s\n", yytext);
        columnNumber += yyleng;
}

{RIGHT_PARENTHESIS} {
        printf("TOKEN RIGHT_PARENTHESIS: %s\n", yytext);
        columnNumber += yyleng;
}

{LEFT_SQUARE_BRACKET} {
        printf("TOKEN LEFT_SQUARE_BRACKET: %s\n", yytext);
        columnNumber += yyleng;
}

{RIGHT_SQUARE_BRACKET} {
        printf("TOKEN RIGHT_SQUARE_BRACKET: %s\n", yytext);
        columnNumber += yyleng;
}

{LEFT_CURLY} {
        printf("TOKEN LEFT_CURLY: %s\n", yytext);
        columnNumber += yyleng;
}

{RIGHT_CURLY} {
        printf("TOKEN RIGHT_CURLY: %s\n", yytext);
        columnNumber += yyleng;
}

{EQUALS} {
        printf("TOKEN EQUALS: %s\n", yytext);
        columnNumber += yyleng;
}

{LESSTHAN} {
        printf("TOKEN LESSTHAN: %s\n", yytext);
        columnNumber += yyleng;
}

{GREATERTHAN} {
        printf("TOKEN GREATERTHAN: %s\n", yytext);
        columnNumber += yyleng;
}

{LESSOREQUAL} {
        printf("TOKEN LESSOREQUAL: %s\n", yytext);
        columnNumber += yyleng;
}

{GREATOREQUAL} {
        printf("TOKEN GREATOREQUAL: %s\n", yytext);
        columnNumber += yyleng;
}

{IDENTIFIER} {
        printf("TOKEN IDENTIFIER: %s\n", yytext);
        columnNumber += yyleng;
}

{INVALIDIDENTIFIER} {
        printf("INVALID IDENTIFIER ERROR AT LINE %d, COLUMN %d: %s\n", lineNumber, columnNumber, yytext);
        return;
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
        printf("UNRECOGNIZED SYMBOL ERROR AT LINE %d, COLUMN %d: %s\n", lineNumber, columnNumber, yytext);
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
