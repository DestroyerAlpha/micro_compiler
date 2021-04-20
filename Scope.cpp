// Importing relevent files and libraries
#include "Scope.h"
#include <iostream>

namespace std{
	// Constructor Function for class Scope
	Scope::Scope(string name_v){
		name = name_v;
		//static std::map<std::Symbol*, int> newMap;
		static std::vector<std::string> newVector;
		err_checker = newVector;
		static std::map< string, Symbol*> newMap;
		ScopeTab = newMap;
	}

	// Destructor Function for class Scope
	Scope::~Scope(){

	}

	// Fetch Name
	string Scope::get_name(){
		return name;
	}

	// Fetch Table
	std::map< string, Symbol*> Scope::get_tab(){
		return ScopeTab;
	}

	// Insert Record 
	void Scope::insert_record(string key_name, Symbol* symRecord){
		// Fetch the name of the symbol
		string sym_name = *(symRecord -> get_name());
		// If the symbol has not been defined, we throw a declaration error
		if (std::find(err_checker.begin(), err_checker.end(), sym_name ) != err_checker.end()){
			//printf("DECLARATION ERROR %s%x%x", sym_name, 0x0D, 0x6E);
			cout << "DECLARATION ERROR " << sym_name << "\r\n";
			exit(1);
		}
		// Otherwise insert the symbol into the scope table
		ScopeTab[key_name] = symRecord;
		// Append the symbol to the err_checker array so we know the symbol has been declared (and fulfil the purpose of the function!)
		err_checker.push_back(*(symRecord -> get_name()));
	}
}
