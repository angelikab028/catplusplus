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
bool find(std::string &value, Type t) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value && s->type == t) {
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
        std::string value = "temp" + ss.str();
        num += 1;
        return value;
}

// TODO: Create a bool function that returns whether or not a function is in the symbol table
// Parameter: std::string of function name.

struct CodeNode {
    std::string code; // generated code as a string.
    std::string name;
};
%}

// TODO: Potentially add another type for mathematical expression such that we can keep track of their type.
%union {
  char* op_val;
  struct CodeNode *node;
}

%define parse.error verbose
%start prog_start
%token FUNCTION INTEGER SEMICOLON BREAK CONTINUE IF PRINT READ RETURN WHILE ASSIGN SUB ADD MULT DIV MOD ELSE COMMA LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_CURLY RIGHT_CURLY EQUALS LESSTHAN GREATERTHAN LESSOREQUALS GREATOREQUALS
%token <op_val> NUMBER IDENTIFIER
%type <op_val> symbol function_identifier
%type <node> prog_start functions function statements statement statementsprime arguments argument argumentsprime parameters parametersprime expression cond_exp add_exp mult_exp unary_exp primary_exp array_element function_call exp_st int_dec_st array_dec_st assignment_dec assign_int_st assign_array_st statement_block if_st else_st loop_st break_st continue_st return_exp return_st read_st print_st

%%
prog_start: functions {
                printf("prog_start -> functions\n");
                CodeNode *node = $1;
                std::string code = node->code;
                printf("Generated Code:\n");
                printf("%s\n", code.c_str());
                print_symbol_table();
        };
        
functions: function functions {
                ////printf("function -> function functions\'\n");
                
                // The "functions" non-terminal contains all the *functions*, and the code they all contain.
                // Since our langauge requires all of our code to be in functions, this non-terminal basically holds all the code.
                // Declare nodes for both nonterminals, and concatenate their code. Pass it up to the root.
                CodeNode *func = $1;
                CodeNode *funcs = $2;
                std::string code = func->code + funcs->code;
                CodeNode *node = new CodeNode;
                node->code = code;
                $$ = node;
         }
         | %empty {
                //printf("functions -> epsilon\n");

                // If we have no more functions to add, pass up an empty node to prevent seg faulting.
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
         };

function: FUNCTION INTEGER function_identifier LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS statement_block {
                //printf("function -> FUNCTION function_return_type function_identifier LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS statement_block\n");
                
                // Declare a new node to be passed up the parse tree.
                CodeNode *node = new CodeNode;

                // These lines get the function_identifier from non-terminal 3 as a string, since function_identifier is an op_val.
                char *c = $3;
                std::string function_identifier(c);

                // These lines get the arguments of the function. 
                CodeNode *arg = $5;
                node->code = function_identifier + arg->code;

                // These lines get the body of the function.
                CodeNode *body = $7;
                node->code += body->code;

                $$ = node;
        };

function_identifier: IDENTIFIER {
                //printf("function_identifier -> IDENTIFIER\n");
                std::string func_name = $1;

                // Convert from std::string to c type string.
                // This was before we knew c_str() was a function
                std::string functionDeclaration = "func " + func_name + "\n";
                int strLen = functionDeclaration.size();
                char *c = new char[strLen + 1];
                std::copy(functionDeclaration.begin(), functionDeclaration.end(), c);
                c[strLen] = '\0';

                add_function_to_symbol_table(func_name);
                $$ = c;
        };

function_call: IDENTIFIER LEFT_PARENTHESIS parameters RIGHT_PARENTHESIS {
                //printf("function_call -> IDENTIFIER LEFT_PARENTHESIS parameters RIGHT_PARENTHESIS \n");
        };

parameters: expression parametersprime {
                //printf("parameters -> IDENTIFIER parametersprime\n");
        }
        | %empty {
                //printf("parameters -> epsilon\n");
        };

parametersprime: COMMA expression parametersprime {
                //printf("parametersprime -> COMMA IDENTIFIER parametersprime\n");
        }
        | %empty {
                //printf("parametersprime -> epsilon\n");
        };

arguments: argument argumentsprime {
                //printf("arguments -> argument argumentsprime\n");

                // The "arguments" non-terminal contains all the declarations of the arguments, 
                // taken from the synthesized attributes of argument and argumentsprime.
                // We must generate the actual assignments.
                
                CodeNode *node = new CodeNode;
                CodeNode *arg = $1;
                CodeNode *argprime = $2;

                // Extract the variable names from the generated code
                std::string variableDeclarations = arg->code + argprime->code;
                std::string variableAssignments = "";

                // Iterate through the generated code of the argument declarations.
                // Generate the assignments to those arguments, concatenate them to the declarations, and return.
                std::stringstream ss(variableDeclarations);
                std::ostringstream intConverter;
                std::string currLine;
                int currentParam = 0;
                
                while (std::getline(ss, currLine))
                {
                        std::string currVar;
                        if (currLine.substr(0, 2) == ". ")
                        {
                                currVar = currLine.substr(2);
                        }
                        intConverter << currentParam++;
                        variableAssignments += "= " + currVar + ", " + "$" + intConverter.str() + "\n";
                        intConverter.str("");
                        intConverter.clear();
                }
                
                node->code = variableDeclarations + variableAssignments;
                $$ = node;
                
        }
        | %empty {
                //printf("arguments -> epsilon\n");

                // No more arguments --> pass empty node
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
                
        };

argumentsprime: COMMA argument argumentsprime {
                //printf("argumentsprime -> COMMA arguments argumentsprime\n");

                // Pass all arguments up.
                CodeNode *node = $2;
                $$ = node;
        }
        | %empty {
                //printf("argumentsprime -> epsilon\n");

                // No more arguments --> pass empty node
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

argument: INTEGER IDENTIFIER {
                //printf("argument -> INTEGER IDENTIFIER\n");
                
                // Generates argument declarations, and passes it upward.
                CodeNode *node = new CodeNode;
                std::string ident = $2;
                if (find(ident, Integer))
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "In function \"" + funcName + "\": cannot have multiple arguments with the same name \"" + ident + "\"";
                        
                        yyerror(errorMsg.c_str());
                        
                }
                add_variable_to_symbol_table(ident, Integer);
                std::string variableDeclaration = ". " + ident + "\n";
                node->code = variableDeclaration;
                $$ = node;
        };

expression: cond_exp {
                //printf("expression -> cond_exp\n");
                $$ = $1;
        };

cond_exp: add_exp {
                //printf("cond_exp -> add_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | cond_exp LESSTHAN add_exp {
                //printf("cond_exp -> cond_exp LESSTHAN add_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | cond_exp GREATERTHAN add_exp {
                //printf("cond_exp -> cond_exp GREATERTHAN add_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | cond_exp GREATOREQUALS add_exp {
                //printf("cond_exp -> cond_exp GREATOREQUALS add_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | cond_exp LESSOREQUALS add_exp {
                //printf("cond_exp -> cond_exp LESSOREQUALS add_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | cond_exp EQUALS add_exp {
                //printf("cond_exp -> cond_exp EQUALS add_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

add_exp: mult_exp {
                //printf("add_exp -> mult_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        } 
        | add_exp ADD mult_exp {
                //printf("add_exp -> add_exp ADD mult_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        } 
        | add_exp SUB mult_exp {
                //printf("add_exp -> add_exp SUB mult_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

mult_exp: unary_exp {
                //printf("mult_exp -> unary_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | mult_exp MULT unary_exp {
                //printf("mult_exp -> mult_exp MULT unary_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | mult_exp DIV unary_exp {
                //printf("mult_exp -> mult_exp DIV unary_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | mult_exp MOD unary_exp {
                //printf("mult_exp -> mult_exp MOD unary_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

unary_exp: primary_exp {
                //printf("unary_exp -> primary_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

primary_exp: symbol {
                //printf("primary_exp -> symbol\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS {
                //printf("primary_exp -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | array_element {
                //printf("primary_exp -> array_element\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | function_call {
                //printf("primary_exp -> function_call\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

array_element: IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET {
        //printf("array_element -> IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET\n");
        CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
};
    
symbol: NUMBER {
            //printf("symbol -> NUMBER\n");
            $$ = $1;
        }
        |
        IDENTIFIER {
            //printf("symbol -> IDENTIFIER\n");
            $$ = $1;
        };

statements: statement statementsprime {
                //printf("statements -> statement statementsprime\n");

                // Same idea with arguments and functions: the "statements" non-terminal will
                // contain all the code within it's scope, since each line is being passed up from the leaf node
                // that it was synthesized from.
                CodeNode *statement = $1;
                CodeNode *statementsprime = $2;
                std::string code = statement->code + statementsprime->code;
                CodeNode *node = new CodeNode;
                node->code = code;
                $$ = node;
        };

statementsprime: %empty {
                //printf("statementsprime -> epsilon\n");

                // Empty rule that returns a node: make sure to actually return empty.
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | statement statementsprime {
                //printf("statementsprime -> statement statementsprime\n");

                // Simply pass upward to "statements": this rule just builds statements one by one.
                CodeNode *statement = $1;
                CodeNode *statementsprime = $2;
                std::string code = statement->code + statementsprime->code;
                CodeNode *node = new CodeNode;
                node->code = code;
                $$ = node;
        };

statement: exp_st {
                //printf("statement -> exp_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | break_st {
                //printf("statement -> break_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | continue_st {
                //printf("statement -> continue_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | return_st {
                //printf("statement -> return_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        } 
        | loop_st {
                //printf("statement -> loop_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | if_st {
                //printf("statement -> if_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | read_st {
                //printf("statement -> read_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | print_st {
                //printf("statement -> print_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | assign_int_st {
                //printf("statement -> assign_int_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        } 
        | int_dec_st {
                //printf("statement -> int_dec_st\n");
                CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
        }
        | array_dec_st {
                //printf("statement -> array_dec_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | assign_array_st {
                //printf("statement -> assign_array_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

exp_st: expression SEMICOLON {
                //printf("exp_st -> expression SEMICOLON\n");
                $$ = $1;
        };

int_dec_st: INTEGER IDENTIFIER assignment_dec SEMICOLON {
                //printf("int_dec_st -> INTEGER IDENTIFIER assignment_dec SEMICOLON\n");

                std::string ident = $2;

                if (find(ident, Integer))
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "In function \"" + funcName + "\": redeclaration of variable \"" + ident + "\"";
                        
                        yyerror(errorMsg.c_str());
                }

                add_variable_to_symbol_table(ident, Integer);

                CodeNode *assignment = $3;
                CodeNode *node = new CodeNode;

                std::string variableDeclaration = ". " + ident + "\n";
                node->code = variableDeclaration;

                // If the variable is initialized with a value
                if (!assignment->code.empty())
                {
                        node->code += assignment->code;
                }

                $$ = node;
        };

array_dec_st: INTEGER IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET assignment_dec SEMICOLON {
                //printf("array_dec_st -> INTEGER IDENTIFIER LEFT_SQUARE_BRACKET NUMBER RIGHT_SQUARE_BRACKET SEMICOLON\n");
        };

assignment_dec: %empty {
                //printf("assignment_dec -> epsilon\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | ASSIGN add_exp {
                //printf("assignment_dec -> ASSIGN NUMBER\n");
                std::string expCode = $2->code;

                // Explanation: possible cases for add_exp:
                // Applies to Case 1:
                // #
                // identifier
                // No need for temp variable here.

                // Applies to Case 2:
                // # op identifier
                // # op #
                // var op var
                // In this case, we need a temp variable to calculate the result, then assign it to the var.
                
                // This is case 2
                if (expCode.find_first_of("+-*/%") != std::string::npos) 
                {
                        // TODO: finish this
                }
        };

assign_int_st: IDENTIFIER ASSIGN add_exp SEMICOLON {
                //printf("assign_int_st -> IDENTIFIER ASSIGN NUMBER SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

assign_array_st: IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET ASSIGN add_exp SEMICOLON {
                //printf("assign_array_st -> IDENTIFIER LEFT_PARENTHESIS NUMBER RIGHT_PARENTHESIS ASSIGN add_exp SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

statement_block: LEFT_CURLY statements RIGHT_CURLY {
                //printf("statement_block -> LEFT_CURLY statements RIGHT_CURLY\n");
                $$ = $2;
        }
        | LEFT_CURLY RIGHT_CURLY {
                //printf("statement_block -> LEFT_CURLY RIGHT_CURLY\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

if_st: IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block else_st {
                //printf("if_st -> IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block else_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

else_st: ELSE statement_block  {
                //printf("else_st -> ELSE statement_block\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | ELSE if_st {
                //printf("else_st -> ELSE if_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        }
        | %empty {
                //printf("else_st -> epsilon\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

loop_st: WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block {
                //printf("loop_st -> WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

break_st: BREAK SEMICOLON {
                //printf("break_st -> BREAK SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

continue_st: CONTINUE SEMICOLON {
                //printf("continue_st -> CONTINUE SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

return_st: RETURN return_exp SEMICOLON {
                //printf("return_st -> RETURN return_exp SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

return_exp: add_exp {
                //printf("return_exp -> add_exp\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

read_st: READ LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
                //printf("read_st -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

print_st: PRINT LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
                //printf("print_st -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
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
    printf("Ctrl + D to quit\n\n");
    // yylex();
    yyparse();
}

void yyerror (char const *s) {
   fprintf (stderr, "*** ERROR: On Line %d, column %d, at or near \"%s\"\n\t %s\n", line_number, column_number, yytext, s);
   yyclearin;
   //exit(1);
}

// Need to turn in: src/compiler.y
// Testfiles for invalid syntax but proper tokens
