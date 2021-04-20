/*
	The Symbol class
*/
// Importing relevent files and libraries

#ifndef SYMBOL_H
#define SYMBOL_H
#include <string>

namespace std{

	// Defining Symbol class. The indivisual functions are defined in detail in Symbol.cpp
	class Symbol
	{
	private:
		// Name of Symbol
		string * name;
		// Value of string
		string * value_s;
		// Value of Integer
		int value_i;
		// Value of Float
		float value_f;
		// Type of Symbol
		int type;
		// Stack pointer
		int stack_pointer;
	public:
		// Constructor Function
		Symbol(string* name_v, string* value_v, int type_t, int stack_p);
		// Destructor Function
		virtual ~Symbol();
		string * get_name();
		string * get_value();
		int get_type();
		int get_stack_pointer();

	};
}
#endif
