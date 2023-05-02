%{
#include <stdio.h>
extern FILE* yyin;
void yyerror(char const *msg);
%}
%start prog_start
%token NUMBER FUNCTION INTEGER SEMICOLON BREAK CONTINUE IF FOR TRUE FALSE PRINT READ RETURN WHILE VOID ASSIGN SUB ADD MULT DIV MOD ELSE COMMA LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_CURLY RIGHT_CURLY EQUALS LESSTHAN GREATERTHAN LESSOREQUALS GREATOREQUALS IDENTIFIER

%%
prog_start: %empty {printf("prog_start -> epsilon\n");}
          | functions {printf("prog_start -> functions\n");}
          ;
functions: function functionsprime {printf("function -> function functions\'\n");}
          ;     

functionsprime: %empty {printf("functionsprime -> epsilon\n");}
          | function functionsprime {printf("functionsprime -> functions functions\'\n");}
          ;

function: FUNCTION function_return_type IDENTIFIER LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS statement_block 
          {printf("function -> FUNCTION function_return_type IDENTIFIER LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS statement_block\n");}
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

expression: cond_exp {printf("expression -> cond_exp\n");}
          ;

cond_exp: add_exp                               {printf("cond_exp -> add_exp\n");}
        | cond_exp LESSTHAN add_exp             {printf("cond_exp -> cond_exp LESSTHAN add_exp\n");}
        | cond_exp GREATERTHAN add_exp          {printf("cond_exp -> cond_exp GREATERTHAN add_exp\n");}
        | cond_exp GREATOREQUALS add_exp        {printf("cond_exp -> cond_exp GREATOREQUALS add_exp\n");}
        | cond_exp LESSOREQUALS add_exp         {printf("cond_exp -> cond_exp LESSOREQUALS add_exp\n");}
        ;

add_exp: mult_exp               {printf("add_exp -> mult_exp\n");} 
       | add_exp ADD mult_exp   {printf("add_exp -> add_exp ADD mult_exp\n");} 
       | add_exp SUB mult_exp   {printf("add_exp -> add_exp SUB mult_exp\n");} 
       ;

mult_exp: unary_exp                     {printf("mult_exp -> unary_exp\n");}
        | mult_exp MULT unary_exp       {printf("mult_exp -> mult_exp MULT unary_exp\n");}
        | mult_exp DIV unary_exp        {printf("mult_exp -> mult_exp DIV unary_exp\n");}
        | mult_exp MOD unary_exp        {printf("mult_exp -> mult_exp MOD unary_exp\n");}
        ;

unary_exp: primary_exp          {printf("unary_exp -> primary_exp\n");}
         ;

primary_exp: NUMBER                                                             {printf("primary_exp -> NUMBER\n");}
           | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS                      {printf("primary_exp -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS\n");}
           | IDENTIFIER                                                         {printf("primary_exp -> IDENTIFIER\n");}
           | IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET        {printf("primary_exp -> IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET\n");}
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

if_st: IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block else_st {printf("if_st -> IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block else_st\n");}
     ;

else_st: ELSE statement_block  {printf("else_st -> ELSE statement_block\n");}
       | ELSE if_st            {printf("else_st -> ELSE if_st\n");}
       | %empty                {printf("else_st -> epsilon\n");}
       ;

loop_st: WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block {printf("loop_st -> WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block\n");}
       ;

break_st: BREAK SEMICOLON {printf("break_st -> BREAK SEMICOLON\n");}
        ;

continue_st: CONTINUE SEMICOLON {printf("continue_st -> CONTINUE SEMICOLON\n");}
           ;

return_st: RETURN return_exp SEMICOLON {printf("return_st -> RETURN return_exp SEMICOLON\n");}
         ;

return_exp: add_exp {printf("return_exp -> add_exp\n");}
          | %empty {printf("return_exp -> epsilon\n");}
          ;

read_st: READ LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {printf("READ LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON\n");}
       ;

print_st: PRINT LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {printf("PRINT LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON\n");}
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
