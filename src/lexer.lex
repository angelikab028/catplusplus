%{
#include <stdio.h>
#include "compiler.tab.h"
int line_number = 1; 
int column_number  = 0;
extern char *identToken;
extern int numberToken;
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
IDENTIFIER [a-zA-Z][a-zA-Z0-9]*
INVALIDIDENTIFIER [0-9]+{IDENTIFIER}

%%

[+-]?{DIGIT}+ {
        // printf("TOKEN NUMBER: %s\n", yytext);
        column_number += yyleng;
        yyless(yyleng);
        char * token = new char[yyleng];
        strcpy(token, yytext);
        yylval.op_val = token;
        numberToken = atoi(yytext); 
        return NUMBER;
}

{FUNCTION} {
        // printf("TOKEN FUNCTION: %s\n", yytext);
        column_number += yyleng;
        return FUNCTION;
}

{INTEGER} {
        // printf("TOKEN INTEGER: %s\n", yytext);
        column_number += yyleng;
        return INTEGER;
}

{SEMICOLON} {
        // printf("TOKEN SEMICOLON: %s\n", yytext);
        column_number += yyleng;
        return SEMICOLON;
}

{BREAK} {
        // printf("TOKEN BREAK: %s\n", yytext);
        column_number += yyleng;
        return BREAK;
}

{CONTINUE} {
        // printf("TOKEN CONTINUE: %s\n", yytext);
        column_number += yyleng;
        return CONTINUE;
}

{IF} {
        // printf("TOKEN IF: %s\n", yytext);
        column_number += yyleng;
        return IF;
}

{PRINT} {
        // printf("TOKEN PRINT: %s\n", yytext);
        column_number += yyleng;
        return PRINT;
}

{READ} {
        // printf("TOKEN READ: %s\n", yytext);
        column_number += yyleng;
        return READ;
}

{RETURN} {
        // printf("TOKEN RETURN: %s\n", yytext);
        column_number += yyleng;
        return RETURN;
}

{WHILE} {
        // printf("TOKEN WHILE: %s\n", yytext);
        column_number += yyleng;
        return WHILE;
}

{ASSIGN} {
        // printf("TOKEN ASSIGN: %s\n", yytext);
        column_number += yyleng;
        return ASSIGN;
}

{SUB} {
        // printf("TOKEN SUB: %s\n", yytext);
        column_number += yyleng;
        return SUB;
}

{ADD} {
        // printf("TOKEN ADD: %s\n", yytext);
        column_number += yyleng;
        return ADD;
}

{MULT} {
        // printf("TOKEN MULT: %s\n", yytext);
        column_number += yyleng;
        return MULT;
}

{DIV} {
        // printf("TOKEN DIV: %s\n", yytext);
        column_number += yyleng;
        return DIV;
}

{MOD} {
        // printf("TOKEN MOD: %s\n", yytext);
        column_number += yyleng;
        return MOD;
}

{ELSE} {
        // printf("TOKEN ELSE: %s\n", yytext);
        column_number += yyleng;
        return ELSE;
}

{COMMA} {
        // printf("TOKEN COMMA: %s\n", yytext);
        column_number += yyleng;
        return COMMA;
}

{LEFT_PARENTHESIS} {
        // printf("TOKEN LEFT_PARENTHESIS: %s\n", yytext);
        column_number += yyleng;
        return LEFT_PARENTHESIS;
}

{RIGHT_PARENTHESIS} {
        // printf("TOKEN RIGHT_PARENTHESIS: %s\n", yytext);
        column_number += yyleng;
        return RIGHT_PARENTHESIS;
}

{LEFT_SQUARE_BRACKET} {
        // printf("TOKEN LEFT_SQUARE_BRACKET: %s\n", yytext);
        column_number += yyleng;
        return LEFT_SQUARE_BRACKET;
}

{RIGHT_SQUARE_BRACKET} {
        // printf("TOKEN RIGHT_SQUARE_BRACKET: %s\n", yytext);
        column_number += yyleng;
        return RIGHT_SQUARE_BRACKET;
}

{LEFT_CURLY} {
        // printf("TOKEN LEFT_CURLY: %s\n", yytext);
        column_number += yyleng;
        return LEFT_CURLY;
}

{RIGHT_CURLY} {
        // printf("TOKEN RIGHT_CURLY: %s\n", yytext);
        column_number += yyleng;
        return RIGHT_CURLY;
}

{EQUALS} {
        // printf("TOKEN EQUALS: %s\n", yytext);
        column_number += yyleng;
        return EQUALS;
}

{LESSTHAN} {
        // printf("TOKEN LESSTHAN: %s\n", yytext);
        column_number += yyleng;
        return LESSTHAN;
}

{GREATERTHAN} {
        // printf("TOKEN GREATERTHAN: %s\n", yytext);
        column_number += yyleng;
        return GREATERTHAN;
}

{LESSOREQUALS} {
        // printf("TOKEN LESSOREQUAL: %s\n", yytext);
        column_number += yyleng;
        return LESSOREQUALS;
}

{GREATOREQUALS} {
        // printf("TOKEN GREATOREQUAL: %s\n", yytext);
        column_number += yyleng;
        return GREATOREQUALS;
}

{IDENTIFIER} {
        // printf("TOKEN IDENTIFIER: %s\n", yytext);
        column_number += yyleng;
        char * token = new char[yyleng];
        strcpy(token, yytext);
        yylval.op_val = token;
        identToken = yytext; 
        return IDENTIFIER;
}

{INVALIDIDENTIFIER} {
        printf("INVALID IDENTIFIER ERROR (CANNOT BEGIN WITH NUMBER) AT LINE %d, COLUMN %d: %s\n", line_number, column_number, yytext);
        exit(1);
}

{COMMENT} {
        // printf("TOKEN COMMENT: %s\n", yytext);
        column_number += yyleng;
}

{WHITESPACE} {
        column_number += yyleng;
}

{NEWLINE} {
        column_number = 0;
        line_number++;
}

. { 
        printf("UNRECOGNIZED SYMBOL ERROR AT LINE %d, COLUMN %d: %s\n", line_number, column_number, yytext);
        exit(1); 
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
