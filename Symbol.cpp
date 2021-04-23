// Acknowledgement: See README.md 
// Importing relevent files and libraries
#include "Symbol.h"

namespace std{
	// Constructor Function for Symbol
	Symbol::Symbol(string* name_v, string* value_v, int type_t, int stack_p){
		// Setting the Name
		name = name_v;
		// Setting the Value 
		value_s = value_v;
		// Setting the Type
		type = type_t;
		// Setting the stack pointer
		stack_pointer = stack_p;
	}

	// Destructor Function for Symbol
	Symbol::~Symbol(){

	}

	// Fetch name
	string * Symbol::get_name(){
		return name;
	}

	// Fetch value
	string * Symbol::get_value(){
		return value_s;
	}

	// Fetch type
	int Symbol::get_type(){
		return type;
	}

	// Fetch Stack Pointer
	int Symbol::get_stack_pointer(){
		return stack_pointer;
	}
}
