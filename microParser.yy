%{
	//Acknowledgement: Qifan Chang and Zixian Lai
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <vector>
	#include <utility>
	#include "main.h"
	//#include "Symbol.h"
	extern int yylex();
	extern char* yytext();
	extern int yyparse();
	extern int yylineno;
	using namespace std;

//std::string * global_name = new std::string("GLOBAL");
std::string global_name = "GLOBAL";
std::string block_name = "BLOCK";
std::string temp_name = "T";
std::string stack_sign = "$";
std::string lable_name = "label";
int block_counter = 0;
int temp_counter = -1;
int label_num = 0;
int scope_counter = 0;
int link_counter = 1;
int param_counter = 1;
int local_counter = 0;
bool in_function = false;
std::map<string, bool> func_var_map;
std::map<string, bool> func_type_map;
//int map_index = 0;


//---------------Global variables------------
	std::vector<std::Scope*> SymTabHead;
	std::vector<std::IR_code*> IR_vector;
	std::stack<int> label_counter;
	//std::ASTNode * test = new std::ASTNode();
	//------------ Local variables-------------
	std::map<Symbol*, int> newMap;
	std::map<Symbol*, int>* currMap = &newMap;
	std::vector<std::string*> scope_table;
	//----------------------------------------------


	void yyerror(char const* msg)
	{
		printf("Not accepted");
	}
%}

//%option yylineno

%token TOKEN_EOF
%token TOKEN_INTLITERAL
%token TOKEN_FLOATLITERAL

%token TOKEN_PROGRAM
%token TOKEN_BEGIN
%token TOKEN_END
%token TOKEN_FUNCTION
%token TOKEN_READ
%token TOKEN_WRITE
%token TOKEN_IF
%token TOKEN_ELSE
%token TOKEN_FI
%token TOKEN_FOR
%token TOKEN_ROF
%token TOKEN_RETURN
%token <tok_numer> TOKEN_INT
%token TOKEN_VOID
%token TOKEN_STRING
%token <tok_numer> TOKEN_FLOAT
%token TOKEN_OP_NE
%token TOKEN_OP_PLUS
%token TOKEN_OP_MINS
%token TOKEN_OP_STAR
%token TOKEN_OP_SLASH
%token TOKEN_OP_EQ
%token TOKEN_OP_NEQ
%token TOKEN_OP_LESS
%token TOKEN_OP_GREATER
%token TOKEN_OP_LP
%token TOKEN_OP_RP
%token TOKEN_OP_SEMIC
%token TOKEN_OP_COMMA
%token TOKEN_OP_LE
%token TOKEN_OP_GE

%token TOKEN_STRINGLITERAL
%token <str> TOKEN_IDENTIFIER
%start program

%union{
	std::string * str;
	int tok_numer;
	std::vector <std::string*> * svec;
	std::ASTNode* ast_node;
	std::vector <std::ASTNode*>* expr_vector;
}

%type <tok_numer> var_type compop any_type
%type <str> id str
%type <svec> id_tail id_list
%type <ast_node> primary factor_prefix postfix_expr mulop addop factor expr_prefix expr assign_expr call_expr
%type <expr_vector> expr_list_tail expr_list



%%
program:	TOKEN_PROGRAM id TOKEN_BEGIN{
	//Create a scope object by the name "GLOBAL"
	std::Scope * globalScope = new std::Scope(global_name);
	//Add the Global Scope to the Symbol table
	SymTabHead.push_back(globalScope);
	//add start of the IR code
	std::IR_code * start_code = new std::IR_code("IR", "code", "", "", temp_counter);
	//Add the first line of IR Code to the IR Code Vector
	IR_vector.push_back(start_code);

}
pgm_body TOKEN_END{};

id:			TOKEN_IDENTIFIER{
	//Return the ID name for the rule
	$$ = yylval.str;};

pgm_body:	decl{
				//Push the 4 registers to the stack
				std::IR_code * push_code = new std::IR_code("PUSH", "", "", "", temp_counter);
				IR_vector.push_back(push_code);
				IR_vector.push_back(push_code);
				IR_vector.push_back(push_code);
				IR_vector.push_back(push_code);
				IR_vector.push_back(push_code);
				//Add a Jump to Main (Executin starts from Main)
				std::IR_code * main_code = new std::IR_code("JSR", "", "", "main", temp_counter);
				IR_vector.push_back(main_code);
				//In case we skip a jump to main, halt the execution
				std::IR_code * halt_code = new std::IR_code("HALT", "", "", "", temp_counter);
				IR_vector.push_back(halt_code);

} func_declarations{};

decl:		string_decl decl{}
		|	var_decl decl{}
		|	;

string_decl:	TOKEN_STRING id TOKEN_OP_NE str TOKEN_OP_SEMIC{
	//Create a new symbol with name as id and value as str
	Symbol *newSym = new std::Symbol($2, $4, TOKEN_STRING, 0);
	//Insert it in the last scope of the Symbol Table
	SymTabHead.back() -> insert_record(*($2) ,newSym);
	//Create IR code for the string declaration
	std::IR_code * string_decl = new std::IR_code("STRING_DECL", *$2, "", *$4, temp_counter);
	if (in_function == false){
		//Add the IR code to the IR Code vector if not defined in function
		IR_vector.push_back(string_decl);
	}
	else{
		//Increment the link counter for the function
		link_counter = link_counter + 1;
	}
	func_var_map[*$2] = in_function;
	//IR_vector.push_back(string_decl);
};

str:		TOKEN_STRINGLITERAL{
	//Return the string name
	$$ = yylval.str;};

var_decl:	var_type id_list TOKEN_OP_SEMIC{
	std::string s_type = "";
	//Iterating over the number of variables in id_list
	for(int i = $2 -> size() -1; i >= 0; i--){
		//Reducing the local_counter from 0 to as this points to the location of the ID on stack
		//Stack grows in downwards direction
		if (in_function == true)
		{
			local_counter = local_counter - 1;
		}
		//Create new Symbol with value set to NULL, type set to var_type and local_counter points 
		//its location in stack
		std::Symbol * newSym = new std::Symbol((*$2)[i], NULL, $1, local_counter);
		//IR Code Comment for debugging
		cout << ";" <<  *( (*$2)[i] ) << " the local counter: " << local_counter <<endl;
		//Add the symbol to the last scope in the symbol table
		SymTabHead.back() -> insert_record(*( (*$2)[i] ) , newSym);
		func_var_map[*( (*$2)[i] )] = in_function;
		//Define the symbol type for the IR code
		if($1 == TOKEN_INT){
			s_type = "INT_DECL";
		}
		else if($1 == TOKEN_FLOAT){
			s_type = "FLOAT_DECL";
		}
		//Create the IR code
		std::IR_code * string_decl = new std::IR_code(s_type, *( (*$2)[i] ), "", "", temp_counter);
		if (in_function == false){
			//Push the IR code to the IR Code vector, if the variable declaration is not in function
			IR_vector.push_back(string_decl);
		}
		else{
			//Increment the link counter for the function
			link_counter = link_counter + 1;
		}
		//IR_vector.push_back(string_decl);
	}
};

var_type:	TOKEN_FLOAT{
	//Returns the type of the variable (FLOAT)
	$$ = TOKEN_FLOAT;}
		|	TOKEN_INT{
			//Returns the type of the variable (INT)
			$$ = TOKEN_INT; };

any_type:	var_type{
	//Returns the data type for function return
	$$ = $1;}
		|	TOKEN_VOID{
			//Returns VOID if function return type is VOID
			$$ = TOKEN_VOID;};


//declaring identifiers one here and other in id_tail
id_list:	id id_tail{
	//Return a vector of strings of id. Eg: a,b,c; returns vector{a,b,c}
						$$ = $2; $$ -> push_back($1);
						}

id_tail:	TOKEN_OP_COMMA id id_tail{
	//Same thing as above, recursively defined
	$$ = $3; $$ -> push_back($2);}
		|	{
			//Returns the vector to add the ID
			std::vector<std::string*>* temp = new std::vector<std::string*>; $$ = temp; };

// same grammer as id_list but used as parameters to function
// func_decl calls this grammer to have one or more parameter to declare
param_decl_list:	param_decl param_decl_tail{}
				|	;

// parameter declaration with variable type as var_type and identifier
param_decl:	var_type id{
	// defining new symbol
	std::Symbol * newSym = new std::Symbol($2, NULL, $1, ++param_counter);
	// updating SymTabHead with new symbol
	SymTabHead.back() -> insert_record(*($2) , newSym);
	// updating variable map with variable as in_function variable
	func_var_map[*($2)] = in_function;

};

// recursive grammer to declare zero or more parameters
param_decl_tail:	TOKEN_OP_COMMA param_decl param_decl_tail{}
				|	;

// recursive grammer to declare zero or more functions
func_declarations:   func_decl func_declarations{}
				|	;

// function declaration 
func_decl:	TOKEN_FUNCTION any_type id {
	//add function scope
	std::Scope * funcScope = new std::Scope(*$3);
	// updating SymTabHead with new function's scope
	SymTabHead.push_back(funcScope);
	//map_index = 0;
	//add label name
	// generating label for function in IR code
	std::IR_code *func_code = new std::IR_code("LABEL", "", "", *$3, temp_counter);
	// updating IR_vector with func_code
	IR_vector.push_back(func_code);
	// setting in_function true
	in_function = true;
	// updating map for function
	if($2 == TOKEN_INT){
		func_type_map[*($3)] = true;
	}
	else{
		func_type_map[*($3)] = false;
	}
	// generating rest of function body
	}TOKEN_OP_LP{param_counter = 1; local_counter = 0;
	// grammer for parameter list} 
	param_decl_list TOKEN_OP_RP {
	// function body beginning}
	TOKEN_BEGIN func_body{ 
	// exiting function and thus setting in_function variable to false}
	TOKEN_END{in_function = false;};

// grammer for function body declaration
func_body:	{link_counter = 1;}
			decl{
				std::string link_counter_str = std::to_string(static_cast<long long>(link_counter));
				// generating IR link code fot link_counter_str
				std::IR_code *link_code = new std::IR_code("LINK", link_counter_str, "", "", link_counter);
				// pushing IR code to IR_vector
				IR_vector.push_back(link_code);
			} stmt_list{};

// recursive grammer to generate statements 
stmt_list:	stmt stmt_list{};
		|

// broadly separating stmt into 3 categories
stmt:		base_stmt{}
		|	if_stmt{}
		|	for_stmt{};

base_stmt:	assign_stmt{}
		|	read_stmt{}
		|	write_stmt{}
		|	return_stmt{};

assign_stmt:	assign_expr TOKEN_OP_SEMIC{																/*print the 3 address code to vector*/
					if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){	/*This will return bool value whether it is int or float*/
						if(($1->get_right_node())->get_int_or_float() == true){		/*assign int value*/
							std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	/*Convert to string*/
							std::string s = temp_name + temp_counter_str;											/*concatenate string*/
							if(($1->get_right_node())->get_node_type() == name_value){								/*if node type is name_value*/
								s = ($1->get_right_node())->get_name();												/*s is assigned it's name*/
							}
							std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);	/*
							assign new IR Node*/
							IR_vector.push_back(assign_int);	/*Push that IRnode in Vector*/
						}
						else if(($1->get_right_node())->get_int_or_float() == false){	/*assign float value*/
							std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	/*Convert to string*/
							std::string s = temp_name + temp_counter_str;											/*concatenate string*/
							if(($1->get_right_node())->get_node_type() == name_value){								/*if node type is name_value*/
								s = ($1->get_right_node())->get_name();												/*s is assigned it's name*/
							}
							std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);	/*
							assign new IR Node*/
							IR_vector.push_back(assign_float);	/*Push that IR_node in Vector*/
						}
					}
					else{
						//assign type error
					}
	};

assign_expr:	id TOKEN_OP_NE expr{			/*Set the assigned Expr Node*/
									std::ASTNode * assign_node = new ASTNode();	/*create assign node*/
									assign_node->change_node_type(operator_value);	/*assign its node type*/
									assign_node->change_operation_type(TOKEN_OP_NE);	/*Assign operation type*/
									//create the id node
									std::ASTNode * id_node = new ASTNode();	/*Create the id node*/
									id_node -> change_node_type(name_value);	/*assign its node type*/
									std::string s = *($1);	/*store its pointer in the string*/

									//id_node -> add_name(*($1));
									//find out the type of the id by looking up the symbol table need to use for loop later
									int temp;
									if (func_var_map[*($1)])	/*if that variable is present or mapped then,*/
									{
										temp = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[*($1)] -> get_type() );	/*get the type of the symbol*/
										id_node -> change_int_or_float(temp == TOKEN_INT);	/*assign that token type to id_node*/

										int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() );	/*get the position*/
										std::string stack_label = std::to_string(static_cast<long long>(stack_num));	/*get lable from that position*/
										s = stack_sign + stack_label;	/*concatenate strings*/
										id_node -> add_name(s);		/*assign the name to id node*/
									}
									else{	/*if that variable is absent or not mapped then,*/
										temp = ( (SymTabHead.front()->get_tab())[*($1)] -> get_type() );	/*get the type of the symbol*/
										id_node -> change_int_or_float(temp == TOKEN_INT);	/*assign that token type to id_node*/
										id_node -> add_name(s);		/*add the string *($1)*/
									}
									id_node -> change_int_or_float(temp == TOKEN_INT);	/*assign that token type to id_node*/
									assign_node -> add_left_child(id_node);	/*add left child to assign_node*/
									assign_node -> add_right_child($3);		/*add right child to assign_node*/
									assign_node->change_int_or_float((temp == TOKEN_INT));	/*assign that token type to assign_node*/

									//set the assign_expr type
									$$ = assign_node; 	/*Set the assign expr type*/
};

read_stmt:		TOKEN_READ TOKEN_OP_LP id_list TOKEN_OP_RP TOKEN_OP_SEMIC{	/*print the 3-address read code to vector*/
				for(int i = ($3->size()) - 1; i >= 0; --i){
					std::string s_type = "";
					if(func_var_map[*( (*$3)[i] )]){	/*need to check the scope use loop later*/
						if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){ /*If symbol type is int*/
							s_type = "READI";																		/*assign it as read int*/
						}
						else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){	/*If symbol type is float*/
							s_type = "READF";																		/*assign it as read float*/
						}
					}
					else{	/*If not defined it will check the type from start*/
						if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
							s_type = "READI";
						}
						else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
							s_type = "READF";
						}
					}
					std::string s = *( (*$3)[i] );	/*store that into a string*/
					if (func_var_map[s])	/*check whether it is mapped or not*/
					{
						int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() );	/*get the position*/
						std::string stack_label = std::to_string(static_cast<long long>(stack_num));		/*get the label from that position*/
						s = stack_sign + stack_label;	/*concatenate the strings*/
					}
					std::IR_code * read_code = new IR_code(s_type, "", "", s, temp_counter);	/*ceate ner IR code as read code*/
					IR_vector.push_back(read_code);												/* Push that read code into the vector*/
				}
};

write_stmt:		TOKEN_WRITE TOKEN_OP_LP id_list TOKEN_OP_RP TOKEN_OP_SEMIC{		/*Write the 3-address code and store it in vector*/
				for(int i = ($3->size()) - 1; i >= 0; --i){
					std::string s_type = "";	/*Initialized empty string*/
					//need to check the scope use loop later
					if(func_var_map[*( (*$3)[i] )]){
						if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
							s_type = "WRITEI";	/*If token type is int then set op type is Write int*/
						}
						else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
							s_type = "WRITEF";	/*If token type is float then set op type is Write float*/
						}
						else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_STRING){
							s_type = "WRITES";	/*If token type is string then set op type is Write string*/
						}
					}
					else{
						if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
							s_type = "WRITEI";	/*If token type is int then set op type is Write int*/
						}
						else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
							s_type = "WRITEF";	/*If token type is float then set op type is Write float*/
						}
						else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_STRING){
							s_type = "WRITES";	/*If token type is string then set op type is Write string*/
						}
					}
					std::string s = *( (*$3)[i] );	/*store the op type */
					if (func_var_map[s])
					{
						int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() );	/*If mapped get location*/
						std::string stack_label = std::to_string(static_cast<long long>(stack_num));	/*get label from that location*/
						s = stack_sign + stack_label;		/*concatenate the sign and label*/
					}
					std::IR_code * write_code = new IR_code(s_type, s, "", "", temp_counter);	/*Create new IR node as write code*/
					IR_vector.push_back(write_code);	/*push that node ino the vector*/
				}
};

return_stmt:	TOKEN_RETURN expr TOKEN_OP_SEMIC{	/*Returns the status of execution*/
				//need to store the expr onto stack
				std::string return_name = "";		/*Initialization of empty return name,datatype,dstination*/
				std::string data_type = "";
				std::string dest = "";
				if ($2->get_node_type() == name_value){		/*If node type is name_value,*/
					return_name = $2->get_name();	/*Set return name as the identity of that node*/
				}
				else{
					std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	/*Store temp counter as string*/
					return_name = temp_name + temp_counter_str;		/*concatenate name and counter*/
				}
				if ($2->get_int_or_float()){	/*If int then true*/
					data_type = "STOREI";	/*Set data type as Store int*/
				}
				else{
					data_type = "STOREF";	/*Set data type as Store float*/
				}
				std::string param_counter_str = std::to_string(static_cast<long long>(param_counter+1));	/*increasing the parameter counter*/
				dest = stack_sign + param_counter_str;	/*initial + counter will point to destination to address*/
				std::IR_code * ret_addr = new IR_code(data_type, return_name, "", dest, temp_counter);	/*creating new IR node with dest address as return node*/
				IR_vector.push_back(ret_addr);	/*push return address into vector*/
				std::IR_code * unlink_code = new IR_code("UNLINK", "", "", "", temp_counter);	/*creating new IR node with temp counter as unlink node*/
				IR_vector.push_back(unlink_code);	/*push unlink code into vector*/
				std::IR_code * return_code = new IR_code("RET", "", "", "", temp_counter);	/*creating new IR node with data type RET as return node*/
				IR_vector.push_back(return_code);	/*push return code into vector*/
};

expr:			expr_prefix factor{
									if ($1 == NULL){
										//expr with only factor
										$$ = $2;
									}
									else{
											std::string s_op1 = "";
											std::string s_op2 = "" ;
											std::string s_result = "" ;
											std::string s_type = "" ;
											//Check if both prefix expression and factor are of the same type
											if($1->get_int_or_float() == $2->get_int_or_float()){
												//Assigns factor to be the right child of the ASTNode of prefix
												$1 -> add_right_child($2);
												//Check type of the prefix expression
												if($1->get_int_or_float()){
													//Operations on INT
													if($1->get_operation_type() == TOKEN_OP_PLUS){
														s_type = "ADDI";
													}
													else if($1->get_operation_type() == TOKEN_OP_MINS){
														s_type = "SUBI";
													}
												}
												else{
													//Operations on Float
													if($1->get_operation_type() == TOKEN_OP_PLUS){
														s_type = "ADDF";
													}
													else if($1->get_operation_type() == TOKEN_OP_MINS){
														s_type = "SUBF";
													}
												}
												
												if(($1->get_left_node())->get_node_type() == name_value){
													//If left node of prefix is of name_value type, set operand1 as the name
													s_op1 = ($1->get_left_node())->get_name();
												}
												else{
													//Else assign a temp to operand1
													s_op1 = ($1->get_left_node())->get_temp_count();
												}
												
												if(($1->get_right_node())->get_node_type() == name_value){
													//If right node of prefix is of name_value type, set operand2 as the name
													s_op2 = ($1->get_right_node())->get_name();
												}
												else{
													//Else assign a temp to operand2
													s_op2 = ($1->get_right_node())->get_temp_count();
												}
												//Create a temp to store the result
												std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
												s_result = temp_name + temp_counter_str;
												//set the temp counter in node factor
												$1->change_temp_count(s_result);
												//Create IR Code for the expression
												std::IR_code * add_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
												//Add IR Code to the IR Code vector
												IR_vector.push_back(add_code);
										}
										else{
											//wrong type
										}
									//Return the expression
									$$ = $1;
								}
							};

expr_prefix:	expr_prefix factor addop{
											if($1 == NULL){
												//If expr_prefix is NULL, initialise a addop ASTNode's
												//left child as factor. Right remains uninitialised
												$3 -> add_left_child($2);
												//Set datatype for the factor
												$3 -> change_int_or_float($2->get_int_or_float());
											}
											else{
												std::string s_op1 = "";
												std::string s_op2 = "" ;
												std::string s_result = "" ;
												std::string s_type = "" ;
												if($1->get_int_or_float() == $2->get_int_or_float()){
														//Right child is init to factor
														$1 -> add_right_child($2);
														//Left Child is init to prefix expression
														$3 -> add_left_child($1);
														//Data type for the resulting expression set
														$3 -> change_int_or_float($1->get_int_or_float());
														//Checking the type of the operation
														if($1->get_int_or_float()){
															//int op
															if($1->get_operation_type() == TOKEN_OP_PLUS){
																s_type = "ADDI";
															}
															else if($1->get_operation_type() == TOKEN_OP_MINS){
																s_type = "SUBI";
															}
														}
														else{
															//float op
															if($1->get_operation_type() == TOKEN_OP_PLUS){
																s_type = "ADDF";
															}
															else if($1->get_operation_type() == TOKEN_OP_MINS){
																s_type = "SUBF";
															}
														}
														
														if(($1->get_left_node())->get_node_type() == name_value){
															//If left ASTnode of prefix is a name_value type, set operand1 as its name
															s_op1 = ($1->get_left_node())->get_name();
														}
														else{
															//Else assign a temp as operand 1
															s_op1 = ($1->get_left_node())->get_temp_count();
														}
														if(($1->get_right_node())->get_node_type() == name_value){
															//If right ASTnode of prefix is a name_value type, set operand2 as its name
															s_op2 = ($1->get_right_node())->get_name();
														}
														else{
															//Else assign a temp as operand2
															s_op2 = ($1->get_right_node())->get_temp_count();
														}
														//Create a string to store a temp
														std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
														s_result = temp_name + temp_counter_str;
														//set the temp counter in node factor
														$1->change_temp_count(s_result);
														//Create IR Code for the expression
														std::IR_code * add_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
														//Add IR Code to the IR Code vector
														IR_vector.push_back(add_code);

												}
												else{
													//return error cant add int with float
												}
											}
											//Return the addop ASTNode
											$$ = $3;
										}
			|	{$$ = NULL;};

factor:			factor_prefix postfix_expr{
											if ($1 == NULL){
												$$ = $2;
											}
											else{
												std::string s_op1 = "";
												std::string s_op2 = "" ;
												std::string s_result = "" ;
												std::string s_type = "" ;
												if($1->get_int_or_float() == $2->get_int_or_float()){
													$1 -> add_right_child($2);
													if($1->get_int_or_float()){
														//int op
														if($1->get_operation_type() == TOKEN_OP_STAR){
															s_type = "MULI";
														}
														else if($1->get_operation_type() == TOKEN_OP_SLASH){
															s_type = "DIVI";
														}
													}
													else{
														//float op
														if($1->get_operation_type() == TOKEN_OP_STAR){
															s_type = "MULF";
														}
														else if($1->get_operation_type() == TOKEN_OP_SLASH){
															s_type = "DIVF";
														}
													}
													//set op1
													if(($1->get_left_node())->get_node_type() == name_value){
														s_op1 = ($1->get_left_node())->get_name();
													}
													else{
														s_op1 = ($1->get_left_node())->get_temp_count();
													}
													//set op2
													if(($1->get_right_node())->get_node_type() == name_value){
														s_op2 = ($1->get_right_node())->get_name();
													}
													else{
														s_op2 = ($1->get_right_node())->get_temp_count();
													}
													std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
													s_result = temp_name + temp_counter_str;
													//set the temp counter in node factor
													$1->change_temp_count(s_result);
													std::IR_code * factor_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
													IR_vector.push_back(factor_code);
													//cout << "if factor called " << $1->get_temp_count() << endl;
												}
												else{
													//wrong type
												}


												$$ = $1;
											}
										};

factor_prefix:	factor_prefix postfix_expr mulop{
												if($1 == NULL){
													$3 -> add_left_child($2);
													//set the node int_or_float type
													$3->change_int_or_float($2->get_int_or_float());

												}
												else{
													if($1->get_int_or_float() == $2->get_int_or_float()){
														$1 -> add_right_child($2);
														$3 -> add_left_child($1);
														$3 -> change_int_or_float($1->get_int_or_float());

														std::string s_op1 = "";
														std::string s_op2 = "" ;
														std::string s_result = "" ;
														std::string s_type = "" ;

														if($1->get_int_or_float()){
															//int op
															if($1->get_operation_type() == TOKEN_OP_STAR){
																s_type = "MULI";
															}
															else if($1->get_operation_type() == TOKEN_OP_SLASH){
																s_type = "DIVI";
															}
														}
														else{
															//float op
															if($1->get_operation_type() == TOKEN_OP_STAR){
																s_type = "MULF";
															}
															else if($1->get_operation_type() == TOKEN_OP_SLASH){
																s_type = "DIVF";
															}
														}

														if(($1->get_left_node())->get_node_type() == name_value){
															s_op1 = ($1->get_left_node())->get_name();
														}
														else{
															s_op1 = ($1->get_left_node())->get_temp_count();
															//cout << "test factor_prefix op1 " << s_type << " temp: " << s_op1 <<endl;
														}
														if(($1->get_right_node())->get_node_type() == name_value){
															s_op2 = ($1->get_right_node())->get_name();
														}
														else{
															s_op2 = ($1->get_right_node())->get_temp_count();
															//cout << "test factor_prefix op2 " << s_type << " temp: " << s_op2 <<endl;
														}
														std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
														s_result = temp_name + temp_counter_str;
														//set the temp counter in node factor
														$1->change_temp_count(s_result);
														std::IR_code * factor_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
														IR_vector.push_back(factor_code);

													}
													else{
													//	//return error cant add int with float
													}
												}
												$$ = $3;
												//try to add IR code

											}
			|	{$$ = NULL;};

postfix_expr:	primary{$$=$1;}
			|	call_expr{$$=$1;};

call_expr:		id TOKEN_OP_LP expr_list TOKEN_OP_RP{
				std::IR_code * push_code = new IR_code("PUSH", "", "", "", temp_counter);
				std::IR_code * push_reg = new IR_code("PUSHREG", "", "", "", temp_counter);
				IR_vector.push_back(push_reg);
				IR_vector.push_back(push_code);
				std::string s = "";
				for (int x = 0; x < $3->size(); x++)
				{
					if ((*$3)[x] -> get_node_type() == name_value)
					{
						s = (*$3)[x] -> get_name();
					}
					else{
						//int temp_num = (*$3)[x-1] -> get_temp_count();
						//std::string temp_counter_str = std::to_string(static_cast<long long>(temp_num));
						s = (*$3)[x] -> get_temp_count();
					}
					std::IR_code * push_para = new IR_code("PUSH", "", "", s, temp_counter);
					IR_vector.push_back(push_para);
				}
				//need to push the result of expr_list
				//
				std::IR_code * jump_func = new IR_code("JSR", "", "", *$1, temp_counter);
				IR_vector.push_back(jump_func);
				std::IR_code * pop_code = new IR_code("POP", "", "", "", temp_counter);
				std::IR_code * pop_reg = new IR_code("POPREG", "", "", "", temp_counter);

				IR_vector.push_back(pop_code);
				for (int x = 0; x < $3->size()-1; x++)
				{
					std::IR_code * pop_para = new IR_code("POP", "", "", "", temp_counter);
					IR_vector.push_back(pop_para);
				}
				std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
				s = temp_name + temp_counter_str;
				std::IR_code * pop_ret = new IR_code("POP", "", "", s, temp_counter);
				IR_vector.push_back(pop_ret);
				IR_vector.push_back(pop_reg);
				//need to pop the result of function into an temp
				//and store the temp into the call_expr node with the type of the function
				std::ASTNode * caller_node = new ASTNode();
				caller_node -> change_node_type(name_value);
				caller_node -> add_name(s);
				caller_node -> change_int_or_float(func_type_map[*($1)]);
				$$ = caller_node;
};

expr_list:		expr expr_list_tail{
				//cout << $1->get_name() << "-------------" <<endl;
				//std::IR_code * push_code = new IR_code("PUSH", "", "", s, temp_counter);
				$$ = $2;
				$$ -> push_back($1);
}
			|	{std::vector<std::ASTNode*>* temp = new std::vector<std::ASTNode*>; $$ = temp;};;

expr_list_tail:	TOKEN_OP_COMMA expr expr_list_tail{/*add the expr to the expr vector*/
				$$ = $3;
				$$ -> push_back($2);
		}
			|	{std::vector<std::ASTNode*>* temp = new std::vector<std::ASTNode*>; $$ = temp;};

primary:		TOKEN_OP_LP expr TOKEN_OP_RP{$$=$2;}
			|	id{
								std::ASTNode * id_node = new ASTNode();
								id_node -> change_node_type(name_value);
								//id_node -> add_name(*($1));
								std::string s = (*($1));
								if(func_var_map[*($1)] == true){
									int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() );
									std::string stack_label = std::to_string(static_cast<long long>(stack_num));
									s = stack_sign + stack_label;
									id_node -> add_name(s);
									//cout << "the primary: " << *$1 <<endl;
									//cout << "the size of the scope: " << SymTabHead.size() <<endl;
									//cout << (SymTabHead[SymTabHead.size() - 1]->get_tab())[*($1)] -> get_type() <<endl;
									int temp = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[*($1)] -> get_type() );
									id_node -> change_int_or_float(temp == TOKEN_INT);
								}
								else{
									int temp = ( (SymTabHead.front()->get_tab())[*($1)] -> get_type() );
									id_node -> change_int_or_float(temp == TOKEN_INT);
									id_node -> add_name(s);
								}
								$$ = id_node;
							}
			|	TOKEN_INTLITERAL{//AST node
								std::ASTNode * int_node = new ASTNode();
								int_node -> change_node_type(int_value);
								int_node -> add_value(*(yylval.str));
								int_node -> change_int_or_float(true);
								$$ = int_node;
								//try to store IR_code
								std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
								std::string s = temp_name + temp_counter_str;
								std::IR_code * int_code = new IR_code("STOREI", *(yylval.str), "", s , temp_counter);
								int_node -> change_temp_count(s);
								IR_vector.push_back(int_code);
							}
			|	TOKEN_FLOATLITERAL{//AST node
									std::ASTNode * float_node = new ASTNode();
									float_node -> change_node_type(float_value);
									float_node -> add_value(*(yylval.str));
									float_node -> change_int_or_float(false);
									//cout << float_node -> get_value() << " this is f value" << endl;
									$$ = float_node;
									//try to store IR_code
									std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
									std::string s = temp_name + temp_counter_str;
									std::IR_code * float_code = new IR_code("STOREF", *(yylval.str), "", s, temp_counter );
									//set the temp counter
									float_node -> change_temp_count(s);
									IR_vector.push_back(float_code);
								};

addop:			TOKEN_OP_PLUS{
								std::ASTNode * op_node = new ASTNode();
								op_node -> change_node_type(operator_value);
								op_node -> change_operation_type(TOKEN_OP_PLUS);
								$$ = op_node;
							}
			|	TOKEN_OP_MINS{
								std::ASTNode * op_node = new ASTNode();
								op_node -> change_node_type(operator_value);
								op_node -> change_operation_type(TOKEN_OP_MINS);
								$$ = op_node;
							};

mulop:			TOKEN_OP_STAR{
								std::ASTNode * op_node = new ASTNode();
								op_node -> change_node_type(operator_value);
								op_node -> change_operation_type(TOKEN_OP_STAR);
								$$ = op_node;
							}
			|	TOKEN_OP_SLASH{
								std::ASTNode * op_node = new ASTNode();
								op_node -> change_node_type(operator_value);
								op_node -> change_operation_type(TOKEN_OP_SLASH);
								$$ = op_node;
							};

if_stmt:		TOKEN_IF{//add if block
	/*std::string block_counter_str = std::to_string(static_cast<long long>(++block_counter));
	std::string s = block_name + " " + block_counter_str;
	std::Scope * if_blockScope = new std::Scope(s);
	SymTabHead.push_back(if_blockScope);*/
	label_num = label_num + 2;
	label_counter.push(label_num - 1);
	//map_index = 0;
} TOKEN_OP_LP cond TOKEN_OP_RP decl stmt_list{	//jump to the end of for
												std::string jump_label = std::to_string(static_cast<long long>(label_counter.top()+1));
												std::string jump_s = lable_name + jump_label;
												std::IR_code * jump_IR = new IR_code("JUMP", "", "", jump_s, temp_counter);
												IR_vector.push_back(jump_IR);
												//label for the beginning of the else
												std::string else_label = std::to_string(static_cast<long long>(label_counter.top()));
												std::string else_s = lable_name + else_label;
												std::IR_code * else_IR = new IR_code("LABEL", "", "", else_s, temp_counter);
												IR_vector.push_back(else_IR);
} else_part TOKEN_FI{
						std::string end_label = std::to_string(static_cast<long long>(label_counter.top()+1));
						std::string end_s = lable_name + end_label;
						std::IR_code * end_IR = new IR_code("LABEL", "", "", end_s, temp_counter);
						IR_vector.push_back(end_IR);
						label_counter.pop();
};

else_part:		TOKEN_ELSE{//add else block
	/*std::string block_counter_str = std::to_string(static_cast<long long>(++block_counter));
	std::string s = block_name + " " + block_counter_str;
	std::Scope * else_blockScope = new std::Scope(s);
	SymTabHead.push_back(else_blockScope);*/

} decl stmt_list{}
			|	;

cond:			expr compop expr{
									std::string compop_str = "";
									switch($2){
										case TOKEN_OP_LESS:
											compop_str = "GE";
											break;
										case TOKEN_OP_GREATER:
											compop_str = "LE";
											break;
										case TOKEN_OP_EQ:
											compop_str = "NE";
											break;
										case TOKEN_OP_NEQ:
											compop_str = "EQ";
											break;
										case TOKEN_OP_LE:
											compop_str = "GT";
											break;
										case TOKEN_OP_GE:
											compop_str = "LT";
											break;
									}
									std::string s1 = "";
									std::string s2 = "";
									int cmp_type = 0;
									if($1->get_int_or_float() == $3->get_int_or_float()){
										if($1->get_node_type() == name_value){
											s1 = $1->get_name();
											if (func_var_map[s1])
											{
												int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s1] -> get_stack_pointer() );
												std::string stack_label = std::to_string(static_cast<long long>(stack_num));
												s1 = stack_sign + stack_label;
											}
										}
										else{
											s1 = $1->get_temp_count();
										}
										if($3->get_node_type() == name_value){
											s2 = $3->get_name();
											if (func_var_map[s2])
											{
												int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s2] -> get_stack_pointer() );
												std::string stack_label = std::to_string(static_cast<long long>(stack_num));
												s2 = stack_sign + stack_label;
											}
										}
										else{
											s2 = $3->get_temp_count();
										}
										if($1->get_int_or_float() == true){
											cmp_type = 0;
										}
										else if($1->get_int_or_float() == false){
											cmp_type = 1;
										}
									}
									else{
										//compare different type data
									}
									std::string jump_label = std::to_string(static_cast<long long>(label_counter.top()));
									std::string jump_s = lable_name + jump_label;
									std::IR_code * cond_IR = new IR_code(compop_str, s1, s2, jump_s, cmp_type);
									IR_vector.push_back(cond_IR);

};

compop:			TOKEN_OP_LESS{$$ = TOKEN_OP_LESS;}
			|	TOKEN_OP_GREATER{$$ = TOKEN_OP_GREATER;}
			|	TOKEN_OP_EQ{$$ = TOKEN_OP_EQ;}
			|	TOKEN_OP_NEQ{$$ = TOKEN_OP_NEQ;}
			|	TOKEN_OP_LE{$$ = TOKEN_OP_LE;}
			|	TOKEN_OP_GE{$$ = TOKEN_OP_GE;};

init_stmt:		assign_expr{
							if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){
								if(($1->get_right_node())->get_int_or_float() == true){
								//cout << "assign to int" <<endl;
									std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
									std::string s = temp_name + temp_counter_str;
									if(($1->get_right_node())->get_node_type() == name_value){
										s = ($1->get_right_node())->get_name();
									}
									std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);
									IR_vector.push_back(assign_int);
								}
								else if(($1->get_right_node())->get_int_or_float() == false){
									std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
									std::string s = temp_name + temp_counter_str;
									if(($1->get_right_node())->get_node_type() == name_value){
										s = ($1->get_right_node())->get_name();
									}
									std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);
									IR_vector.push_back(assign_float);
								}
							}
							else{
								//assign type error
							}
}
			|	;

incr_stmt:		assign_expr{
							if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){
								if(($1->get_right_node())->get_int_or_float() == true){
								//cout << "assign to int" <<endl;
									std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
									std::string s = temp_name + temp_counter_str;
									if(($1->get_right_node())->get_node_type() == name_value){
										s = ($1->get_right_node())->get_name();
									}
									std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);
									IR_vector.push_back(assign_int);
								}
								else if(($1->get_right_node())->get_int_or_float() == false){
									std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
									std::string s = temp_name + temp_counter_str;
									if(($1->get_right_node())->get_node_type() == name_value){
										s = ($1->get_right_node())->get_name();
									}
									std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);
									IR_vector.push_back(assign_float);
								}
							}
							else{
								//assign type error
							}
}
			|	;

for_stmt:		TOKEN_FOR{//add for block
							/*std::string block_counter_str = std::to_string(static_cast<long long>(++block_counter));
							std::string s = block_name + " " + block_counter_str;
							std::Scope * for_blockScope = new std::Scope(s);
							SymTabHead.push_back(for_blockScope);*/

} TOKEN_OP_LP init_stmt TOKEN_OP_SEMIC{
										label_num = label_num + 2;
										label_counter.push(label_num);
										std::string label_counter_str = std::to_string(static_cast<long long>(label_counter.top() - 1));
										std::string label_s = lable_name + label_counter_str;
										std::IR_code * label_IR = new IR_code("LABEL", "", "", label_s, temp_counter);
										IR_vector.push_back(label_IR);
										std::IR_code * label_for = new IR_code("FOR_START", "", "", "", temp_counter);
										IR_vector.push_back(label_for);
} cond TOKEN_OP_SEMIC{/*start for the incr_stmt*/
															std::IR_code * incr = new IR_code("INCR_START", "", "", "", temp_counter);
															IR_vector.push_back(incr);
						} incr_stmt{/*end for the incr_stmt*/
									std::IR_code * jump_code = new IR_code("INCR_END", "", "", "", temp_counter);
									IR_vector.push_back(jump_code);
						} TOKEN_OP_RP decl stmt_list{/*end of the for loop*/
														std::IR_code * end_sig = new IR_code("FOR_END", "", "", "", label_counter.top());
														IR_vector.push_back(end_sig);
														std::string end_label = std::to_string(static_cast<long long>(label_counter.top()));
														std::string end_lable_s = lable_name + end_label;
														std::IR_code * end_code = new IR_code("LABEL", "", "", end_lable_s, temp_counter);
														IR_vector.push_back(end_code);
														label_counter.pop();
						} TOKEN_ROF{};


%%
