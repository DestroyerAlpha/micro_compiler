//Acknowledgement: Qifan Chang and Zixian Lai

// the main c++ file for the compiler
// Importing relevant libraries
#include <bits/stdc++.h>
#include "main.h"
#include "microParser.hpp"

using namespace std;

// Define Global Variables
int var_ct = 0;
bool reg_only_flag = false;
std::map<string, string> var_dict;
std::map<string, string> reg_dict;
//std::vector<std::set<string>> GEN_vect;
//std::vector<std::set<string>> KILL_vect;

extern "C" FILE* yyin;
//extern char* yytext;
/*
std::map<yytokentype, std::string> typeName;
std::string typeName[TOKEN_INT] = "INT";
*/
int main(int argc, char **argv)
{
	//Open the scanner file in the read mode
	FILE *scanfile = fopen( argv[1], "r");
	//Check for successful opening
	if(!scanfile)
	{
		// Error opening file 
		printf("Can't open the file\n");
		// Exit with return status -1
		return -1;
	}

	// Pointer to the input file
	yyin = scanfile;

	//yyparse() returns 0 if parsing is successful
	int check = yyparse();

	if(check == 0)
	{
		// Accepted
	}

	// Defining a set of string to store temporary operands and operation result
	std::set<string> tempVarSet;
	for (int i = 0; i < IR_vector.size(); i++)
	{
		cout << ";";
		// Print operation type of the ith element of IR_vector
		cout << IR_vector[i]->get_op_type();
		//Get first operand
		if(IR_vector[i]->get_op1() != ""){
			//Print first operand
			cout << " op1:" << IR_vector[i]->get_op1();
			//Insert value associated with key 'T', in tempVarSet defined above if find returns value != -1
			if((IR_vector[i]->get_op1()).find('T') != std::string::npos){
				tempVarSet.insert(IR_vector[i]->get_op1());
			}
		}
		//Get second operand
		if(IR_vector[i]->get_op2() != ""){
			//Print second operand
			cout << " op2:" << IR_vector[i]->get_op2();
			//Insert value associated with key 'T', in tempVarSet defined above if find returns value != -1
			if((IR_vector[i]->get_op2()).find('T') != std::string::npos){
				tempVarSet.insert(IR_vector[i]->get_op2());
			}
		}
		//Get result
		if(IR_vector[i]->get_result() != ""){
			//Print result
			cout << " result:" << IR_vector[i]->get_result();
			//Insert value associated with key 'T', in tempVarSet defined above if find returns value != -1
			if((IR_vector[i]->get_result()).find('T') != std::string::npos){
				tempVarSet.insert(IR_vector[i]->get_result());
			}
		}
		cout << endl;
	}
		cout << endl;
		// Defining an iterator
		set<string>::iterator iter;
		// Iterate through the set of temporary variables stored above
		for(iter=tempVarSet.begin(); iter!=tempVarSet.end();++iter) {
			// Print variables
			cout << "var " << *iter << endl;
		}
//--------------------------Pre-Tiny code generation(for optimization)-----------------------
		// Defining an object Tiny	
		std::Tiny* optTiny = new std::Tiny(IR_vector);
		optTiny -> genTiny();

		//Detailed explaination of genTiny() in Tiny.cpp

			
		
		
	return 0;
}
