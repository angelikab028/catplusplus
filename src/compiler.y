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
int count_names = 0;

bool isError = false;

enum Type { Integer, Array, Void };

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  Type returnType;
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
void add_function_to_symbol_table(std::string &value, Type returnType) {
  Function f; 
  f.name = value;
  f.returnType = returnType;
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
    printf("function: %s, return type %d\n", symbol_table[i].name.c_str(), symbol_table[i].returnType);
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

// functions to create a temporary register and declare it(remember that we use three address code)
// taken from slides
std::string create_temp() {
        static int num = 0;
        std::ostringstream ss;
        ss << num;
        std::string value = "temp" + ss.str();
        num += 1;
        return value;
}

std::string declare_temp_code(std::string &temp) {
        return std::string(". ") + temp + std::string("\n");
}

std::string create_if() {
        static int num_if = 0;
        std::ostringstream ss;
        ss << num_if;
        std::string value = "if_statement" + ss.str();
        num_if += 1;
        return value;
}

std::string create_while() {
        static int num_while = 0;
        std::ostringstream ss;
        ss << num_while;
        std::string value = "while_loop" + ss.str();
        num_while += 1;
        return value;
}

std::string create_else() {
        static int num_else = 0;
        std::ostringstream ss;
        ss << num_else;
        std::string value = "else_statement" + ss.str();
        num_else += 1;
        return value;
}

std::string declare_label(std::string &temp) {
        return std::string(": ") + temp + std::string("\n");
}

bool findFunction(std::string& name, Type returnType)
{
        for (int i = 0; i < symbol_table.size(); i++)
        {
                if (symbol_table[i].name == name && symbol_table[i].returnType == returnType) return true;
        }
        return false;
}

struct CodeNode {
    std::string code; // generated code as a string.
    std::string name; // name of result register
};
%}

%union {
  char* op_val;
  struct CodeNode *node;
}

%define parse.error verbose
%start prog_start
%token FUNCTION INTEGER SEMICOLON BREAK CONTINUE IF PRINT READ RETURN WHILE ASSIGN SUB ADD MULT DIV MOD ELSE COMMA LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_CURLY RIGHT_CURLY EQUALS LESSTHAN GREATERTHAN LESSOREQUALS GREATOREQUALS NOTEQUALS VOID
%token <op_val> NUMBER IDENTIFIER
%type <op_val> function_identifier function_return_type add_to_symbol_table
%type <node> prog_start functions function statements statement statementsprime arguments argument argumentsprime parameter parameters parametersprime expression cond_exp add_exp mult_exp unary_exp primary_exp array_element function_call exp_st int_dec_st array_dec_st assignment_dec assign_int_st assign_array_st statement_block if_st else_st loop_st break_st continue_st return_exp return_st read_st print_st

%%
prog_start: functions {
                // printf("prog_start -> functions\n");
                std::string mainCheck = "main";
                if (!findFunction(mainCheck, Void))
                {
                        std::string errorMsg = "File must define a main function returning void.";
                        isError = true;
                        yyerror(errorMsg.c_str());
                }
                CodeNode *node = $1;
                std::string code = node->code;
                //printf("Generated Code:\n");
                if (!isError) printf("%s\n", code.c_str());
                //print_symbol_table();
        };
        
functions: function functions {
                // printf("function -> function functions\'\n");
                
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

function: FUNCTION add_to_symbol_table LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS statement_block {
                //printf("function -> FUNCTION function_return_type function_identifier LEFT_PARENTHESIS arguments RIGHT_PARENTHESIS statement_block\n");
                
                // Declare a new node to be passed up the parse tree.
                CodeNode *node = new CodeNode;

                // These lines get the function_identifier from non-terminal 3 as a string, since function_identifier is an op_val.
                char *c = $2;
                std::string function_identifier(c);

                // These lines get the arguments of the function. 
                CodeNode *arg = $4;
                node->code = function_identifier + arg->code;

                // These lines get the body of the function.
                CodeNode *body = $6;
                node->code += body->code;
                
                
                if (node->code.find("ret") == std::string::npos && get_function()->returnType == Integer)
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "In function \"" + funcName + "\": no return statement in function returning integer";
                        isError = true;
                        yyerror(errorMsg.c_str());
                }
                node->code += "endfunc\n";
                $$ = node;
        };

add_to_symbol_table: function_return_type function_identifier {
                char *returnType = $1;
                std::string ret(returnType);

                // These lines get the function_identifier from non-terminal 3 as a string, since function_identifier is an op_val.
                char *c = $2;
                std::string function_identifier(c);
                std::string functionName = function_identifier.substr(5, function_identifier.size() - 6);
                

                if (findFunction(functionName, Void) || findFunction(functionName, Integer))
                {
                                std::string errorMsg = "Cannot have two functions with the same name \"" + functionName + "\"";
                                isError = true;
                                yyerror(errorMsg.c_str());
                }
                
                if (ret == "Void")
                {       
                        add_function_to_symbol_table(functionName, Void);
                }
                else
                {
                        add_function_to_symbol_table(functionName, Integer);
                }
                $$ = $2;
        };

function_return_type: INTEGER {
                std::string intgr = "Integer";
                int strLen = intgr.size();
                char *c = new char[strLen + 1];
                std::copy(intgr.begin(), intgr.end(), c);
                c[strLen] = '\0';
                $$ = c;
        }
        | VOID {
                std::string vd = "Void";
                int strLen = vd.size();
                char *c = new char[strLen + 1];
                std::copy(vd.begin(), vd.end(), c);
                c[strLen] = '\0';
                $$ = c;
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

                //add_function_to_symbol_table(func_name);
                $$ = c;
        };

function_call: IDENTIFIER LEFT_PARENTHESIS parameters RIGHT_PARENTHESIS {
                //printf("function_call -> IDENTIFIER LEFT_PARENTHESIS parameters RIGHT_PARENTHESIS \n");
                std::string tempName = create_temp();
                std::string tempDeclaration = declare_temp_code(tempName);
                CodeNode *node = new CodeNode;
                node->code = tempDeclaration + $3->code;
                node->code +=  "call " + std::string($1) + ", " + tempName + "\n";
                node->name = tempName;
                $$ = node;
        };

parameters: parameter parametersprime {
                //printf("parameters -> IDENTIFIER parametersprime\n");
                CodeNode *node = new CodeNode;
                CodeNode *param = $1;
                CodeNode *paramprime = $2;

                node->code = param->code + paramprime->code;
                $$ = node;
        }
        | %empty {
                //printf("parameters -> epsilon\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

parametersprime: COMMA parameter parametersprime {
                //printf("parametersprime -> COMMA IDENTIFIER parametersprime\n");
                $$ = $2;
        }
        | %empty {
                //printf("parametersprime -> epsilon\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

parameter: add_exp {
                CodeNode *node = new CodeNode;
                CodeNode *param = $1;

                //std::string tempName = create_temp();
                //std::string tempDeclaration = declare_temp_code(tempName);
                
                std::string result = param->name;
                node->code += param->code + "param " + result + "\n";
                $$ = node;
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
                // NOTE: We should have done them one by one and passed them up rather than doing this :(
                        // We learned though :)
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
                        isError = true;
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
                $$ = $1;
        }
        | cond_exp LESSTHAN add_exp {
                //printf("cond_exp -> cond_exp LESSTHAN add_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "< " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        }
        | cond_exp GREATERTHAN add_exp {
                //printf("cond_exp -> cond_exp GREATERTHAN add_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "> " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        }
        | cond_exp GREATOREQUALS add_exp {
                //printf("cond_exp -> cond_exp GREATOREQUALS add_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += ">= " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        }
        | cond_exp LESSOREQUALS add_exp {
                //printf("cond_exp -> cond_exp LESSOREQUALS add_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "<= " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        }
        | cond_exp EQUALS add_exp {
                //printf("cond_exp -> cond_exp EQUALS add_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "== " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        }
        | cond_exp NOTEQUALS add_exp {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "!= " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;  
        };

add_exp: mult_exp {
                //printf("add_exp -> mult_exp\n");
                $$ = $1;
        } 
        | add_exp ADD mult_exp {
                //printf("add_exp -> add_exp ADD mult_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "+ " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        } 
        | add_exp SUB mult_exp {
                //printf("add_exp -> add_exp SUB mult_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "- " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        };


// CHECK /// 
mult_exp: unary_exp {
                //printf("mult_exp -> unary_exp\n");
                $$ = $1;
        }
        | mult_exp MULT unary_exp {
                //printf("mult_exp -> mult_exp MULT unary_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "* " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        }
        | mult_exp DIV unary_exp {
                //printf("mult_exp -> mult_exp DIV unary_exp\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "/ " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        }
        | mult_exp MOD unary_exp {
                //printf("mult_exp -> mult_exp MOD unary_exp\n");
                 std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + declare_temp_code(temp);
                node->code += "% " + temp + ", " + $1->name + ", " + $3->name + "\n";
                node->name = temp;
                $$ = node;
        };

unary_exp: primary_exp {
                //printf("unary_exp -> primary_exp\n");
                $$ = $1;
        };

primary_exp: NUMBER {
                //printf("primary_exp -> symbol\n");
                CodeNode *node = new CodeNode;
                std::string symbol($1);
                std::string temp = create_temp();
                node->name = temp;
                temp = declare_temp_code(temp); 
                node->code = temp + "= " + node->name + ", " + symbol + "\n";
                $$ = node;
        }
        | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS {
                //printf("primary_exp -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS\n");
                $$ = $2;
        }
        | array_element {
                //printf("primary_exp -> array_element\n");
                $$ = $1;
        }
        | function_call {
                // printf("primary_exp -> function_call\n");
                $$ = $1;
        }
        | IDENTIFIER {
                CodeNode *node = new CodeNode;
                std::string symbol($1);
                if (!find(symbol, Integer))
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "In function \"" + funcName + "\": use of unknown variable \"" + symbol + "\"" + " before declaration.";
                        isError = true;
                        yyerror(errorMsg.c_str());
                }
                node->name = symbol;
                $$ = node;
        };

// done :3 
array_element: IDENTIFIER LEFT_SQUARE_BRACKET NUMBER RIGHT_SQUARE_BRACKET {
        //printf("array_element -> IDENTIFIER LEFT_SQUARE_BRACKET add_exp RIGHT_SQUARE_BRACKET\n");
        CodeNode *node = new CodeNode;
        std::string symbol($3);
        std::string temp = create_temp();
        node->name = temp;
        std::string declareTemp = declare_temp_code(temp); 
        std::string array_name = $1;
        node->code = declareTemp + "=[] " + temp + ", " + array_name + ", " + symbol + "\n";
        $$ = node;
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
                $$ = $1;
        }
        | break_st {
                //printf("statement -> break_st\n");
                $$ = $1;
        }
        | continue_st {
                //printf("statement -> continue_st\n");
                $$ = $1;
        }
        | return_st {
                //printf("statement -> return_st\n");
                $$ = $1;
        } 
        | loop_st {
                //printf("statement -> loop_st\n");
                $$ = $1;
        }
        | if_st {
                //printf("statement -> if_st\n");
                $$ = $1;
        }
        | read_st {
                //printf("statement -> read_st\n");
                $$ = $1;
        }
        | print_st {
                //printf("statement -> print_st\n");
                $$ = $1;
        }
        | assign_int_st {
                //printf("statement -> assign_int_st\n");
                $$ = $1;
        } 
        | int_dec_st {
                //printf("statement -> int_dec_st\n");
                $$ = $1;
        }
        | array_dec_st {
                //printf("statement -> array_dec_st\n");
                $$ = $1;
        }
        | assign_array_st {
                //printf("statement -> assign_array_st\n");
                $$ = $1;
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
                        isError = true;
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
                        node->code += "= " + ident + ", " + $3->name + "\n";
                }

                $$ = node;
        };

// done :3 .[] name, n	declares a name for an array variable consisting of n (must be a positive whole number) elements, with name[0] being the first element
array_dec_st: INTEGER IDENTIFIER LEFT_SQUARE_BRACKET NUMBER RIGHT_SQUARE_BRACKET SEMICOLON {
                //printf("array_dec_st -> INTEGER IDENTIFIER LEFT_SQUARE_BRACKET NUMBER RIGHT_SQUARE_BRACKET SEMICOLON\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                std::string symbol($4);
                node->name = temp;
                temp = declare_temp_code(temp); 
                std::string array_name = $2;
                //need to make error message where array size cannot be less than 1 :P
                int index = 0;
                std::stringstream ss($4);
                ss >> index;
                if (index < 1) {
                        std::string funcName = get_function()->name;
                        std::string error_message = "In function: " + funcName + ", index must be a positive whole number.";
                        isError = true;
                        yyerror(error_message.c_str());    
                }
                
                //name  that already exists
                if (find(array_name, Array) || find(array_name, Integer)) {
                        std::string funcName = get_function()->name;
                        std::string error_message = "In function: " + funcName + ", array " + array_name + " already exists in the symbol table.";
                        isError = true;
                        yyerror(error_message.c_str());
                }
                add_variable_to_symbol_table(array_name, Array);
                node->code = temp + ".[] " + array_name + ", " + symbol + "\n";
                $$ = node;
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
                std::string srcRegister = $2->name;

                CodeNode *node = new CodeNode;
                node->code = expCode;
                node->name = srcRegister;
                $$ = node;
        };

assign_int_st: IDENTIFIER ASSIGN add_exp SEMICOLON {
                //printf("assign_int_st -> IDENTIFIER ASSIGN NUMBER SEMICOLON\n");
                CodeNode *node = new CodeNode;
                CodeNode *numba = $3;
                std::string int_name = $1;
                node->code = numba->code + "= " + int_name + ", " + numba->name + "\n";
                $$ = node;

                //error message assigning a variable that is not in symbo table
                if (find(int_name, Array))
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "In funtion \"" + funcName + "\": use of array variable \"" + int_name + "\"" + " without specifying index.";
                        isError = true;
                        yyerror(errorMsg.c_str());
                }
                else if (!find(int_name, Integer)) {
                        std::string funcName = get_function()->name;
                        std::string error_message = "In function " + funcName + ", integer variable " + int_name + " was used without declaration.";
                        isError = true;
                        yyerror(error_message.c_str());
                }
        };
/*

Array Access Statements
=[] dst, src, index	dst = src[index] (index can be an immediate)
[]= dst, index, src	dst[index] = src (index and src can be immediates)
*/

// done :3 []= dst, index, src	dst[index] = src (index and src can be immediates)
assign_array_st: IDENTIFIER LEFT_SQUARE_BRACKET NUMBER RIGHT_SQUARE_BRACKET ASSIGN add_exp SEMICOLON {
                //printf("assign_array_st -> IDENTIFIER LEFT_PARENTHESIS NUMBER RIGHT_PARENTHESIS ASSIGN add_exp SEMICOLON\n");
                std::string array_name($1);
                if (find(array_name, Integer))
                {
                        std::string funcName = get_function()->name;
                        std::string error_message = "In function " + funcName + ", use of integer variable " + array_name + " as array (specifying index for integer variable).";
                        isError = true;
                        yyerror(error_message.c_str());
                }
                else if (!find(array_name, Array)) {
                        std::string funcName = get_function()->name;
                        std::string error_message = "In function " + funcName + ", array " + array_name + " does not exist in the symbol table.";
                        isError = true;
                        yyerror(error_message.c_str());
                }
                std::string temp = create_temp();
                std::string temp2 = declare_temp_code(temp);
                CodeNode* node = new CodeNode;
                std::string symbol($1);
                std::string index($3);
                CodeNode* src = $6;
                node->name = temp;
                node->code = src->code + temp2 + "[]= " + array_name + ", " + index + ", " + src->name + "\n";  
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

/*

// initialize conditional register
// done in conditional statements, temp register saved in $3
. _temp0
< _temp0, a, b

// if-else statement
?:= if_true0, _temp0
:= else0

// branches
: if_true0
= c, b
:= endif0
// else
: else0
= c, a
: endif0

*/

if_st: IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block else_st { // TODO:
                //printf("if_st -> IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block else_st\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                std::string label = create_if();
                node->name = label;
                std::string declaration = declare_label(label);
                std::string endLabel = "end_" + label;
                std::string endDeclaration = declare_label(endLabel);
                CodeNode *exp = $3;
                CodeNode *statementBlock = $5; 
                CodeNode *elseStatement = $6;
                std::string gotoElse = "";
                if (!$6->code.empty())
                {
                        gotoElse = ":= " + $6->name;
                }
                std::string conditionalStatement = "?:= " + label + $3->name + "\n";
                node->code += exp->code + conditionalStatement + gotoElse + declaration + statementBlock->code + endDeclaration + elseStatement->code + ":= " + endLabel; 
                $$ = node;
        };

else_st: ELSE statement_block  { // TODO:
                //printf("else_st -> ELSE statement_block\n");
                CodeNode *node = new CodeNode;
                std::string label = create_else();
        }
        | %empty {
                //printf("else_st -> epsilon\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

loop_st: WHILE {/* add label 2 stack*/} LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block {/*pop that joint */}{ // TODO:
                //printf("loop_st -> WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_block\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

break_st: BREAK SEMICOLON { // TODO:
                //printf("break_st -> BREAK SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

continue_st: CONTINUE SEMICOLON { // TODO:
                //printf("continue_st -> CONTINUE SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
        };

// CHECK // 
return_st: RETURN return_exp SEMICOLON {
                //printf("return_st -> RETURN return_exp SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = $2->code + std::string("ret ") + $2->name + std::string("\n");
                $$ = node;
        };
// CHECK /// 
return_exp: add_exp {
                $$ = $1;
        };

/*
Input/Output Statements
.< dst	read a value into dst from standard in
.[]< dst, index	read a value into dst[index] from standard in
.> src	write the value of src into standard out
.[]> src, index	write the value of src[index] into standard out
*/

read_st: READ LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
                //printf("read_st -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON\n");
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $3->code + declare_temp_code(temp);
                node->code += ".< " + temp + "\n";
                node->name = temp;
                $$ = node;
        };
// CHECK //
print_st: PRINT LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
                //printf("print_st -> LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON\n");
                CodeNode *node = new CodeNode;
                node->code = $3->code + ".> " + $3->name + "\n";
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
    //printf("Ctrl + D to quit\n\n");
    // yylex();
    yyparse();
}

void yyerror (char const *s) {
   fprintf (stderr, "*** ERROR: On Line %d, column %d, at or near \"%s\"\n\t %s\n", line_number, column_number, yytext, s);
   yyclearin; // allows for continued parsing after error
   //exit(1);
}

// Need to turn in: src/compiler.y
// Testfiles for invalid syntax but proper tokens
