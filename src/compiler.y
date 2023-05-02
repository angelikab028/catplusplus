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
          | function functionsprime {printf("functionsprime -> functions functions\'\n");}
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

argumentsprime: COMMA argument argumentsprime {printf("argumentsprime -> COMMA arguments argumentsprime\n");}
              | %empty {printf("argumentsprime -> epsilon\n");}
              ;

argument: INTEGER IDENTIFIER {printf("argument -> INTEGER IDENTIFIER\n");}
        ;

statements: statement statementsprime {printf("statements -> statement statementsprime\n");}
          ;

statementsprime: %empty {printf("statementsprime -> epsilon\n");}
               | statement statementsprime {printf("statementsprime -> statement statementsprime\n");}

statement: exp_st             {printf("statement -> exp_st\n");}
         | break_st           {printf("statement -> break_st\n");}
         | continue_st        {printf("statement -> continue_st\n");}
         | return_st          {printf("statement -> return_st\n");} 
         | loop_st            {printf("statement -> loop_st\n");}
         | if_st              {printf("statement -> if_st\n");}
         | else_st            {printf("statement -> else_st\n");}
         | statement_block    {printf("statement -> statement_block\n");}
         | read_st            {printf("statement -> read_st\n");}
         | print_st           {printf("statement -> print_st\n");}
         | assign_int_st      {printf("statement -> assign_int_st\n");} 
         | int_dec_st         {printf("statement -> int_dec_st\n");} 
         ;

exp_st: expression SEMICOLON {printf("exp_st -> expression SEMICOLON\n");}
      ;

int_dec_st: INTEGER IDENTIFIER assignment_dec SEMICOLON {printf("INTEGER IDENTIFIER assignment_dec SEMICOLON\n");}
          ;

assignment_dec: %empty {printf("assignment_dec -> epsilon\n");}
              | ASSIGN NUMBER {printf("assignment_dec -> ASSIGN NUMBER\n");}
              ;
assign_int_st: IDENTIFIER ASSIGN NUMBER SEMICOLON {printf("IDENTIFIER ASSIGN NUMBER SEMICOLON\n");}
             ;

statement_block: LEFT_CURLY statements RIGHT_CURLY {printf("statement_block -> LEFT_CURLY statements RIGHT_CURLY\n");}
               ;

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
