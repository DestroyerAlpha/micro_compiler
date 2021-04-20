//Acknowledgement: Qifan Chang and Zixian Lai
/*
	The Tiny.h
*/
// Importing relevant libraries
#ifndef TINY_H
#define TINY_H
#include <string>
#include <utility>
#include <algorithm>
#include <map>
#include <vector>
#include <stack>
#include <iostream>
#include "main.h"

namespace std{
	//Defining Tiny class
	class Tiny{
	private:
		//For intermediate representation of source code
		std::vector<std::IR_code*> IR_vector;

		//For storing variables and it's values
		std::map<string, string> var_dict;

		//For storing registers and it's values
		std::map<string, string> reg_dict;

		//For activation record
		std::map<string, string> act_record;

		//For storing register prefix
		string reg_prefix;

		//For keeping register count
		int reg_counter;

		// For storing sequence of registers used
		string reg_counter_str;

		//Defining below variables for temporary purpose
		string s;
		size_t pos_t; // to store value by operator sizeof
		string temp_num;
	public:
		// Defining virtual function of constructor function Tiny()
		virtual ~Tiny();
		//Defining constructor function
		Tiny(std::vector<std::IR_code*> IR_vector_in);
		//Defining genTiny() for pre-tiny code generation
		void genTiny();
	};

}
#endif

