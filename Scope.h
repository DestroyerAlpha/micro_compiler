//Acknowledgement: Qifan Chang and Zixian Lai
//Documentation done by Mehul Bose
/*
	The Scope class
*/
// Importing relevent files and libraries
#ifndef SCOPE_H
#define SCOPE_H
#include <string>
#include <utility>
#include <algorithm>
#include <map>
#include <vector>
#include "Symbol.h"


namespace std{
	// Defining Scope (for Symbol Table) class. The indivisual functions are defined in detail in Scope.cpp
	class Scope
	{
	private:
		// Name of Scope
		string name;
		// Scope Table : map of string and symbol
	 	std::map< string, Symbol*> ScopeTab;
		// Error Checker : vector of strings. This vector keeps track of which variables have been declared in this scope. 
		// The function insert_record appends to this vector.
	 	std::vector<std::string> err_checker;
	public:
		Scope(string name_v);
		virtual ~Scope();
		string get_name();
		std::map< string, Symbol*> get_tab();
		void insert_record(string ,Symbol*);

	};
}
#endif
