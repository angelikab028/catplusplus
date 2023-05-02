%{
#include <stdio.h>
#include "y.tab.h"
int line_number = 1; 
int column_number  = 0;
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
LESSOREQUALS "<="
GREATOREQUALS ">="
VOID "hairball"
IDENTIFIER [a-zA-Z][a-zA-Z0-9]*
INVALIDIDENTIFIER [0-9]+{IDENTIFIER}

%%

[+-]?{DIGIT}+ {
        // printf("TOKEN NUMBER: %s\n", yytext);
        columnNumber += yyleng;
        yyless(yyleng);
        return NUMBER;
}

{FUNCTION} {
        // printf("TOKEN FUNCTION: %s\n", yytext);
        columnNumber += yyleng;
        return FUNCTION;
}

{INTEGER} {
        // printf("TOKEN INTEGER: %s\n", yytext);
        columnNumber += yyleng;
        return INTEGER;
}

{SEMICOLON} {
        // printf("TOKEN SEMICOLON: %s\n", yytext);
        columnNumber += yyleng;
        return SEMICOLON;
}

{BREAK} {
        // printf("TOKEN BREAK: %s\n", yytext);
        columnNumber += yyleng;
        return BREAK;
}

{CONTINUE} {
        // printf("TOKEN CONTINUE: %s\n", yytext);
        columnNumber += yyleng;
        return CONTINUE;
}

{IF} {
        // printf("TOKEN IF: %s\n", yytext);
        columnNumber += yyleng;
        return IF;
}

{FOR} {
        // printf("TOKEN FOR: %s\n", yytext);
        columnNumber += yyleng;
        return FOR;
}

{TRUE} {
        // printf("TOKEN TRUE: %s\n", yytext);
        columnNumber += yyleng;
        return TRUE;
}

{FALSE} {
        // printf("TOKEN FALSE: %s\n", yytext);
        columnNumber += yyleng;
        return FALSE;
}

{PRINT} {
        // printf("TOKEN PRINT: %s\n", yytext);
        columnNumber += yyleng;
        return PRINT;
}

{READ} {
        // printf("TOKEN READ: %s\n", yytext);
        columnNumber += yyleng;
        return READ;
}

{RETURN} {
        // printf("TOKEN RETURN: %s\n", yytext);
        columnNumber += yyleng;
        return RETURN;
}

{WHILE} {
        // printf("TOKEN WHILE: %s\n", yytext);
        columnNumber += yyleng;
        return WHILE;
}

{VOID} {
        // printf("TOKEN VOID: %s\n", yytext);
        columnNumber += yyleng;
        return VOID;
}

{ASSIGN} {
        // printf("TOKEN ASSIGN: %s\n", yytext);
        columnNumber += yyleng;
        return ASSIGN;
}

{SUB} {
        // printf("TOKEN SUB: %s\n", yytext);
        columnNumber += yyleng;
        return SUB;
}

{ADD} {
        // printf("TOKEN ADD: %s\n", yytext);
        columnNumber += yyleng;
        return ADD;
}

{MULT} {
        // printf("TOKEN MULT: %s\n", yytext);
        columnNumber += yyleng;
        return MULT;
}

{DIV} {
        // printf("TOKEN DIV: %s\n", yytext);
        columnNumber += yyleng;
        return DIV;
}

{MOD} {
        // printf("TOKEN MOD: %s\n", yytext);
        columnNumber += yyleng;
        return MOD;
}

{ELSE} {
        // printf("TOKEN ELSE: %s\n", yytext);
        columnNumber += yyleng;
        return ELSE;
}

{COMMA} {
        // printf("TOKEN COMMA: %s\n", yytext);
        columnNumber += yyleng;
        return COMMA;
}

{LEFT_PARENTHESIS} {
        // printf("TOKEN LEFT_PARENTHESIS: %s\n", yytext);
        columnNumber += yyleng;
        return LEFT_PARENTHESIS;
}

{RIGHT_PARENTHESIS} {
        // printf("TOKEN RIGHT_PARENTHESIS: %s\n", yytext);
        columnNumber += yyleng;
        return RIGHT_PARENTHESIS;
}

{LEFT_SQUARE_BRACKET} {
        // printf("TOKEN LEFT_SQUARE_BRACKET: %s\n", yytext);
        columnNumber += yyleng;
        return LEFT_SQUARE_BRACKET;
}

{RIGHT_SQUARE_BRACKET} {
        // printf("TOKEN RIGHT_SQUARE_BRACKET: %s\n", yytext);
        columnNumber += yyleng;
        return RIGHT_SQUARE_BRACKET;
}

{LEFT_CURLY} {
        // printf("TOKEN LEFT_CURLY: %s\n", yytext);
        columnNumber += yyleng;
        return LEFT_CURLY;
}

{RIGHT_CURLY} {
        // printf("TOKEN RIGHT_CURLY: %s\n", yytext);
        columnNumber += yyleng;
        return RIGHT_CURLY;
}

{EQUALS} {
        // printf("TOKEN EQUALS: %s\n", yytext);
        columnNumber += yyleng;
        return EQUALS;
}

{LESSTHAN} {
        // printf("TOKEN LESSTHAN: %s\n", yytext);
        columnNumber += yyleng;
        return LESSTHAN;
}

{GREATERTHAN} {
        // printf("TOKEN GREATERTHAN: %s\n", yytext);
        columnNumber += yyleng;
        return GREATERTHAN;
}

{LESSOREQUALS} {
        // printf("TOKEN LESSOREQUAL: %s\n", yytext);
        columnNumber += yyleng;
        return LESSOREQUALS;
}

{GREATOREQUALS} {
        // printf("TOKEN GREATOREQUAL: %s\n", yytext);
        columnNumber += yyleng;
        return GREATOREQUALS;
}

{IDENTIFIER} {
        // printf("TOKEN IDENTIFIER: %s\n", yytext);
        columnNumber += yyleng;
        return IDENTIFIER;
}

{INVALIDIDENTIFIER} {
        printf("INVALID IDENTIFIER ERROR (CANNOT BEGIN WITH NUMBER) AT LINE %d, COLUMN %d: %s\n", lineNumber, columnNumber, yytext);
        return;
}

{COMMENT} {
        // printf("TOKEN COMMENT: %s\n", yytext);
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
// Remove main, move to Bison
/*
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
*/
