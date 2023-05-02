%{
#include <stdio.h>
extern FILE* yyin;
void yyerror(char const *msg);
%}
%start prog_start
%token NUMBER FUNCTION INTEGER SEMICOLON BREAK CONTINUE IF FOR TRUE FALSE PRINT READ RETURN WHILE VOID ASSIGN SUB ADD MULT DIV MOD ELSE COMMA LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_CURLY RIGHT_CURLY EQUALS LESSTHAN GREATERTHAN LESSOREQUAL GREATOREQUAL IDENTIFIER

%%
prog_start: %empty {printf("prog_start -> epsilon\n");}
          | functions {printf("prog_start -> functions\n");}
          ;
functions: function functionsprime {printf("function -> function functions\'\n");}
          ;     

functionsprime: %empty {printf("functionsprime -> epsilon\n");}
          | functions functionsprime {printf("functionsprime -> functions functions\'\n");}
          ;

function: FUNCTION function_return_type IDENTIFIER LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY 
          {printf("function -> FUNCTION function_return_type IDENTIFIER LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY\n");}
          ;

function_return_type: INTEGER {printf("function_return_type -> INTEGER\n");}
                    | VOID {printf("function_return_type -> VOID\n");}
                    ;

arguments: argument argumentsprime {printf("arguments -> argument argumentsprime\n");}
         | %empty {printf("arguments -> epsilon\n");}
         ;

argumentsprime: COMMA arguments argumentsprime {printf("argumentsprime -> COMMA arguments argumentsprime\n");}
              | %empty {printf("argumentsprime -> epsilon\n");}
              ;

argument: INTEGER IDENTIFIER {printf("argument -> INTEGER IDENTIFIER\n");}
        ;

statements: %empty;

%%
// UNCOMMENT THIS!

 void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
 }

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
// Need to turn in: src/compiler.y
// Testfiles for invalid syntax but proper tokens
