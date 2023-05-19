%{
#include <stdio.h>
#include <string>
#include <vector>
#include <string.h>
#include <stdlib.h>
#include <sstream> // using sstream instead of to_string because stdlib on bolt doesn't have to_string in the stl (why?)

extern FILE* yyin;
extern int line_number;
extern int column_number;
extern char* yytext;
void yyerror(char const *msg);
extern int yylex(void);

char *identToken;
int numberToken;
int  count_names = 0;

enum Type { Integer, Array };

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;

// remember that Bison is a bottom up parser: that it parses leaf nodes first before
// parsing the parent nodes. So control flow begins at the leaf grammar nodes
// and propagates up to the parents.
Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

// find a particular variable using the symbol table.
// grab the most recent function, and linear search to
// find the symbol you are looking for.
// you may want to extend "find" to handle different types of "Integer" vs "Array"
bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

// when you see a function declaration inside the grammar, add
// the function name to the symbol table
void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

// when you see a symbol declaration inside the grammar, add
// the symbol name as well as some type information to the symbol table
void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

// a function to print out the symbol table to the screen
// largely for debugging purposes.
void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

// a function to create a temporary register (remember that we use three address code)
// taken from slides
std::string create_temp() {
        static int num = 0;
        std::ostringstream ss;
        ss << num;
        std::string value = "_temp" + ss.str();
        num += 1;
        return value;
}

struct CodeNode {
    std::string code; // generated code as a string.
    std::string name;
};
%}

%union {
  char *op_val;
  struct CodeNode *node;
}

%define parse.error verbose
%start prog_start
%token FUNCTION INTEGER SEMICOLON BREAK CONTINUE IF PRINT READ RETURN WHILE VOID ASSIGN SUB ADD MULT DIV MOD ELSE COMMA LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_CURLY RIGHT_CURLY EQUALS LESSTHAN GREATERTHAN LESSOREQUALS GREATOREQUALS FOR TRUE FALSE
%token <op_val> NUMBER
%token <op_val> IDENTIFIER
%type <op_val> symbol
%type <op_val> function_identifier
%type <node> prog_start
%type <node> functions
%type <node> function
%type <node> statements
%type <node> statement

%%
prog_start: functions {
                printf("prog_start -> functions\n");
                //CodeNode *node = $1;
                //std::string code = node->code;
                //printf("Generated Code:\n");
                //printf("%s\n", code.c_str());
        };
        
functions: function functions {
                printf("function -> function functions\'\n");
                // The "functions" non-terminal contains all the *functions*, and the code they all contain.
                // Since our langauge requires all of our code to be in functions, this non-terminal basically holds all the code.
                //CodeNode *func = $1;
                //CodeNode *funcs = $2;
                //std::string code = func->code + funcs->code;
                //CodeNode *node = new CodeNode;
                //node->code = code;
                //$$ = node;
         }
         | %empty {
                printf("functions -> epsilon\n");
         };

function: FUNCTION function_return_type function_identifier LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS statement_block {
                printf("function -> FUNCTION function_return_type function_identifier LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS statement_block\n");
        };

function_identifier: IDENTIFIER {
                printf("function_identifier -> IDENTIFIER\n");
                std::string func_name = $1;
                //add_function_to_symbol_table(func_name);
                //print_symbol_table();

                //$$ = $1;
        };

function_return_type: INTEGER {
                //printf("function_return_type -> INTEGER\n");
        }
        | VOID {
                //printf("function_return_type -> VOID\n");
        };

function_call: IDENTIFIER LEFT_PARENTHESIS parameters RIGHT_PARENTHESIS {
                printf("function_call -> IDENTIFIER LEFT_PARENTHESIS parameters RIGHT_PARENTHESIS \n");
        };

parameters: expression parametersprime {
                printf("parameters -> IDENTIFIER parametersprime\n");
        }
        | %empty {
                printf("parameters -> epsilon\n");
        };

parametersprime: COMMA expression parametersprime {
                printf("parametersprime -> COMMA IDENTIFIER parametersprime\n");
        }
        | %empty {
                printf("parametersprime -> epsilon\n");
        };

arguments: argument argumentsprime {
                printf("arguments -> argument argumentsprime\n");
        }
        | %empty {
                printf("arguments -> epsilon\n");
        };

argumentsprime: COMMA argument argumentsprime {
                printf("argumentsprime -> COMMA arguments argumentsprime\n");
        }
        | %empty {
                printf("argumentsprime -> epsilon\n");
        };

argument: INTEGER IDENTIFIER {
                printf("argument -> INTEGER IDENTIFIER\n");
        };

expression: cond_exp {
                printf("expression -> cond_exp\n");
        };

cond_exp: add_exp {
                printf("cond_exp -> add_exp\n");
        }
        | cond_exp LESSTHAN add_exp {
                printf("cond_exp -> cond_exp LESSTHAN add_exp\n");
        }
        | cond_exp GREATERTHAN add_exp {
                printf("cond_exp -> cond_exp GREATERTHAN add_exp\n");
        }
        | cond_exp GREATOREQUALS add_exp {
                printf("cond_exp -> cond_exp GREATOREQUALS add_exp\n");
        }
        | cond_exp LESSOREQUALS add_exp {
                printf("cond_exp -> cond_exp LESSOREQUALS add_exp\n");
        }
        | cond_exp EQUALS add_exp {
                printf("cond_exp -> cond_exp EQUALS add_exp\n");
        };

add_exp: mult_exp {
                printf("add_exp -> mult_exp\n");
        } 
        | add_exp ADD mult_exp {
                printf("add_exp -> add_exp ADD mult_exp\n");
        } 
        | add_exp SUB mult_exp {
                printf("add_exp -> add_exp SUB mult_exp\n");
        };

mult_exp: unary_exp {
                printf("mult_exp -> unary_exp\n");
        }
        | mult_exp MULT unary_exp {
                printf("mult_exp -> mult_exp MULT unary_exp\n");
        }
        | mult_exp DIV unary_exp {
                printf("mult_exp -> mult_exp DIV unary_exp\n");
        }
        | mult_exp MOD unary_exp {
                printf("mult_exp -> mult_exp MOD unary_exp\n");
        };

unary_exp: primary_exp {
                printf("unary_exp -> primary_exp\n");
        };

primary_exp: symbol {
                printf("primary_exp -> symbol\n");
        }
        | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS {
                printf("primary_exp -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS\n");
        }
        | array_element {
                printf("primary_exp -> array_element\n");
        }
        | function_call {
                printf("primary_exp -> function_call\n");
        };

array_element: IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET {
        printf("array_element -> IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET\n");
};
    
symbol: NUMBER {
            printf("symbol -> NUMBER\n");
        }
        |
        IDENTIFIER {
            printf("symbol -> IDENTIFIER\n");
        };

statements: statement statementsprime {
                printf("statements -> statement statementsprime\n");
        };

statementsprime: %empty {
                printf("statementsprime -> epsilon\n");
        }
        | statement statementsprime {
                printf("statementsprime -> statement statementsprime\n");
        };

statement: exp_st {
                printf("statement -> exp_st\n");
        }
        | break_st {
                printf("statement -> break_st\n");
        }
        | continue_st {
                printf("statement -> continue_st\n");
        }
        | return_st {
                printf("statement -> return_st\n");
        } 
        | loop_st {
                printf("statement -> loop_st\n");
        }
        | if_st {
                printf("statement -> if_st\n");
        }
        | read_st {
                printf("statement -> read_st\n");
        }
        | print_st {
                printf("statement -> print_st\n");
        }
        | assign_int_st {
                printf("statement -> assign_int_st\n");
        } 
        | int_dec_st {
                printf("statement -> int_dec_st\n");
        }
        | array_dec_st {
                printf("statement -> array_dec_st\n");
        }
        | assign_array_st {
                printf("statement -> assign_array_st\n");
        };

exp_st: expression SEMICOLON {
                printf("exp_st -> expression SEMICOLON\n");
        };

int_dec_st: INTEGER IDENTIFIER assignment_dec SEMICOLON {
                printf("int_dec_st -> INTEGER IDENTIFIER assignment_dec SEMICOLON\n");
        };

array_dec_st: INTEGER IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET assignment_dec SEMICOLON {
                printf("array_dec_st -> INTEGER IDENTIFIER LEFT_SQUARE_BRACKET NUMBER RIGHT_SQUARE_BRACKET SEMICOLON\n");
        };

assignment_dec: %empty {
                printf("assignment_dec -> epsilon\n");
        }
        | ASSIGN add_exp {
                printf("assignment_dec -> ASSIGN NUMBER\n");
        };

assign_int_st: IDENTIFIER ASSIGN add_exp SEMICOLON {
                printf("assign_int_st -> IDENTIFIER ASSIGN NUMBER SEMICOLON\n");
        };

assign_array_st: IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET ASSIGN add_exp SEMICOLON {
                printf("assign_array_st -> IDENTIFIER LEFT_PARENTHESIS NUMBER RIGHT_PARENTHESIS ASSIGN add_exp SEMICOLON\n");
        };

statement_block: LEFT_CURLY statements RIGHT_CURLY {
                printf("statement_block -> LEFT_CURLY statements RIGHT_CURLY\n");
        }
        | LEFT_CURLY RIGHT_CURLY {
                printf("statement_block -> LEFT_CURLY RIGHT_CURLY\n");
        };

if_st: IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block else_st {
                printf("if_st -> IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block else_st\n");
        };

else_st: ELSE statement_block  {
                printf("else_st -> ELSE statement_block\n");
        }
        | ELSE if_st {
                printf("else_st -> ELSE if_st\n");
        }
        | %empty {
                printf("else_st -> epsilon\n");
        };

loop_st: WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block {
                printf("loop_st -> WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block\n");
        };

break_st: BREAK SEMICOLON {
                printf("break_st -> BREAK SEMICOLON\n");
        };

continue_st: CONTINUE SEMICOLON {
                printf("continue_st -> CONTINUE SEMICOLON\n");
        };

return_st: RETURN return_exp SEMICOLON {
                printf("return_st -> RETURN return_exp SEMICOLON\n");
        };

return_exp: add_exp {
                printf("return_exp -> add_exp\n");
        }
        | %empty {
                printf("return_exp -> epsilon\n");
        };

read_st: READ LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
                printf("read_st -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON\n");
        };

print_st: PRINT LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
                printf("print_st -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON\n");
        };
%%
// UNCOMMENT THIS!

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

void yyerror (char const *s) {
   fprintf (stderr, "Error: On Line %d, column %d: %s at or near: \"%s\" \n", line_number, column_number, s, yytext);
}

// Need to turn in: src/compiler.y
// Testfiles for invalid syntax but proper tokens
