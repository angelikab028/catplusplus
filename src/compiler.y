%{
#include <stdio.h>
extern FILE* yyin;
%}
%start prog_start
%token NUMBER FUNCTION INTEGER SEMICOLON BREAK CONTINUE IF FOR TRUE FALSE PRINT READ RETURN WHILE VOID ASSIGN SUB ADD MULT DIV MOD ELSE COMMA LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_CURLY RIGHT_CURLY EQUALS LESSTHAN GREATERTHAN LESSOREQUAL GREATOREQUAL IDENTIFIER

%%
prog_start: %empty {printf("prog_start -> epsilon\n");}
          | functions {printf("prog_start -> functions\n");}
          ;
functions: function {printf("function -> function\n");}
          | function functions {printf("function -> function functions\n");}
          ;

function: FUNCTION INTEGER IDENTIFIER LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY
          {printf("function -> FUNCTION INT IDENTIFIER LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY\n");}
          ;

arguments: %empty {printf("arguments -> epsilon\n");}
         | argument repeat_arguments {printf("arguments -> argument COMMA arguments\n");}  
         ;

repeat_arguments: %empty
                | COMMA argument repeat_arguments

argument: INTEGER IDENTIFIER {printf("argument -> INT IDENTIFIER");}
        ;

statements: %empty {printf("statements -> epsilon"\n);}
          | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}

statement: declaration
         | function_call
         ;

declaration: INTEGER IDENTIFIER
           ;

function_call: IDENTIFIER LEFT_PARENTHESIS params RIGHT_PARENTHESIS
             ;
            
params: %empty
      ;
%% 
/* UNCOMMENT THIS!
int main(int argc, char* argv[]) {
    ++argv;
    --argc;
     if ( argc > 0 )
            yyin = fopen( argv[0], "r" );
    else
            yyin = stdin;
    printf("Ctrl + D to quit\n");
    // yylex();
    yyparse();
}
Need to turn in: src/compiler.y
Testfiles for invalid syntax but proper tokens
*/