//Acknowledgement: Qifan Chang and Zixian Lai

// Importing Tiny.h, where the classes are defined.

#include "Tiny.h"

namespace std{
	// Initializing the class variables deined in Tiny.h
	Tiny::Tiny(std::vector<std::IR_code*> IR_vector_in){
		IR_vector = IR_vector_in;
		reg_counter = -1;
		reg_counter_str = "";
		s = "";
	}

	// Defining virtual function of Tiny()
	Tiny::~Tiny(){}

	//Defining gentiny()
	void Tiny::genTiny(){
		//Initialize register count to zero
		int regcnt = 0;
		// Current register number
		int curr_reg;
		// String for comparing value
		std::string cmpr_val;
		// Register stack
		std::stack<int> reg_stack;
		// Intermediate code representation stack
		std::stack<int> IR_ct_stack;
		// label stack
		std::stack<std::string> label_stack;
//--------------------------Pre-Tiny code generation(for optimization)-----------------------
		for (int i = 0; i < IR_vector.size(); i++)
		{
			// If operator type is STOREI or STOREF
			if (IR_vector[i]->get_op_type() == "STOREI" ||
				IR_vector[i]->get_op_type() == "STOREF"){
					if((IR_vector[i]->get_result()).find("!T") == std::string::npos){
						if (var_dict.find(IR_vector[i]->get_result()) != var_dict.end()){
							//creating reg_dict to store operand 1
							if((IR_vector[i]->get_op1()).find("!T") != std::string::npos){
								reg_dict[IR_vector[i]->get_op1()] = IR_vector[i]->get_result();
							}
							//cout << IR_vector[i]->get_op1() << " : " << reg_dict[IR_vector[i]->get_op1()] << endl;
						}
						else{
		 				   // creating var_dict to store temporary variables (operand 1 here)
							//   "r" + std::to_string(static_cast<long long>(regcnt++));
						   var_dict[IR_vector[i]->get_result()] = IR_vector[i]->get_result();
						   if((IR_vector[i]->get_op1()).find("!T") != std::string::npos){
						   	   reg_dict[IR_vector[i]->get_op1()] = IR_vector[i]->get_result();
						   }
						   //cout << IR_vector[i]->get_op1() << " : " << reg_dict[IR_vector[i]->get_op1()] << endl;
						   //cout << IR_vector[i]->get_result() << " : " << var_dict[IR_vector[i]->get_result()] << endl;
						}
					}
				}
			// If operator type is READI or READF	
			else if (IR_vector[i]->get_op_type() == "READI" ||
				IR_vector[i]->get_op_type() == "READF") {
				// Store it in the result part of IR_vector in var_dict
					if((IR_vector[i]->get_result()).find("!T") == std::string::npos){
						if (var_dict.find(IR_vector[i]->get_result()) == var_dict.end()){
							//var_dict[IR_vector[i]->get_result()] =
							//   "r" + std::to_string(static_cast<long long>(regcnt++));
							var_dict[IR_vector[i]->get_result()] = IR_vector[i]->get_result();
						}
					}
				}
		}
		//regcnt = 0;
//--------------------------generate tiny code-----------------------
		for (int i = 0; i < IR_vector.size(); i++)
		{
			// Object curr3ac of class IR_code to store current 3 address code
			std::IR_code* curr3ac = IR_vector[i];
			// Current operator type 
			string curr_op_type = IR_vector[i] -> get_op_type();
			// If operator type is INT or FLOAT, print it
			if( curr_op_type == "INT_DECL"){cout << "var " << IR_vector[i] -> get_op1() << endl;}
			if( curr_op_type == "FLOAT_DECL"){cout << "var " << IR_vector[i] -> get_op1() << endl;}
			// If operator type is STRING, print it
			if( curr_op_type == "STRING_DECL"){
				cout << "str " << IR_vector[i] -> get_op1() << " " << IR_vector[i] -> get_result() << endl;
			}
			// If operator type is ADDI, print 3ac for it along with the steps involved
			else if( curr_op_type == "ADDI"){
				// Move operand 2 to r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;

				// Add integer in operand 1 to r0
				cout << "addi " << curr3ac->get_op1() << " r0" << endl;

				// Store the result of the operation
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is SUBI, print 3ac for it along with the steps involved
			else if( curr_op_type == "SUBI"){
				// Move operand 2 to r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;

				// Subtract integer in operand 1 to r0
				cout << "subi " << curr3ac->get_op2() << " r0" << endl;

				// Store the result of the operation
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is MULI, print 3ac for it along with the steps involved
			else if( curr_op_type == "MULI"){
				// Move operand 2 to r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;

				// Multiply integer in operand 1 to r0
				cout << "muli " << curr3ac->get_op1() << " r0" << endl;

				// Store the result of the operation
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is DIVI, print 3ac for it along with the steps involved
			else if( curr_op_type == "DIVI"){
				// Move operand 1 to r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;

				// Divide integer in operand 2 to r0
				cout << "divi " << curr3ac->get_op2() << " r0" << endl;

				// Store the result of the operation
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is ADDF, print 3ac for it along with the steps involved
			else if( curr_op_type == "ADDF"){
				// Move operand 2 to r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;

				// Add float in operand 1 to r0
				cout << "addr " << curr3ac->get_op1() << " r0" << endl;

				// Store the result of the operation
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is SUBF, print 3ac for it along with the steps involved
			else if( curr_op_type == "SUBF"){
				// Move operand 1 to r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;

				// Subtract float in operand 2 to r0
				cout << "subr " << curr3ac->get_op2() << " r0" << endl;

				// Store the result of the operation
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is MULF, print 3ac for it along with the steps involved
			else if( curr_op_type == "MULF"){
				// Move operand 2 to r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;

				// Multiply float in operand 1 to r0
				cout << "mulr " << curr3ac->get_op1() << " r0" << endl;

				// Store the result of the operation
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is DIVF, print 3ac for it along with the steps involved
			else if( curr_op_type == "DIVF"){
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				cout << "divr " << curr3ac->get_op2() << " r0" << endl;

				// Store the result of the operation
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is LABEL, print 3ac for it along with the steps involved
			else if( curr_op_type == "LABEL"){
				if (curr3ac -> get_op1() == "main") {cout << "label " << curr3ac -> get_op1() << endl;}
				else{
					cout << "label " << curr3ac -> get_result() << endl;
					//cout << "heeere pre" << endl;
					if (i + 1< IR_vector.size()){
						if (IR_vector[i+1] -> get_op_type() == "FOR_START"){label_stack.push(curr3ac -> get_result());}
					}
					//cout << "heeere post" << endl;
				}
			}

			// If operator type is JUMP, print "jmp " + result of 3ac
			else if( curr_op_type == "JUMP"){
				cout << "jmp " << curr3ac->get_result() << endl;
			}

			// If operator type is FOR_START, do nothing
			else if( curr_op_type == "FOR_START"){}

			// If operator type is FOR_END,
			else if( curr_op_type == "FOR_END"){
				int temp_i = i;
				// get top element of the stack
				i = IR_ct_stack.top();
				// Pop the top element
				IR_ct_stack.pop();
				// push the old i in the stack
				IR_ct_stack.push(temp_i);
				
			}

			// If operator type is INCR_START, push i in the stack
			else if( curr_op_type == "INCR_START"){
				IR_ct_stack.push(i);
				int j = i;
				// Increase j till operator tyoe becomes INCR_END 
				while(IR_vector[j]->get_op_type() != "INCR_END"){j++;}
				i = j;
			}

			// If operator type is INCR_END, get top element of IR stack and pop it
			else if( curr_op_type == "INCR_END"){
				i = IR_ct_stack.top();
				IR_ct_stack.pop();
				cout << "jmp " << label_stack.top() << endl;
				label_stack.pop();
			}

			// If operator type is GT, print 3ac for it along with the steps involved
			else if( curr_op_type == "GT"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jgt " << curr3ac->get_result() << endl;
			}

			// If operator type is GE, print 3ac for it along with the steps involved
			else if( curr_op_type == "GE"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jge " << curr3ac->get_result() << endl;
			}

			// If operator type is LT, print 3ac for it along with the steps involved
			else if( curr_op_type == "LT"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jlt " << curr3ac->get_result() << endl;
			}

			// If operator type is LE, print 3ac for it along with the steps involved
			else if( curr_op_type == "LE"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jle " << curr3ac->get_result() << endl;
			}

			// If operator type is EQ, print 3ac for it along with the steps involved
			else if( curr_op_type == "EQ"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jeq " << curr3ac->get_result() << endl;
			}

			// If operator type is NE, print 3ac for it along with the steps involved
			else if( curr_op_type == "NE"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jne " << curr3ac->get_result() << endl;
			}

			// If operator type is PUSH
			else if( curr_op_type == "PUSH"){
				// Check if get_result of 3ac is empty
				if ( curr3ac->get_result().empty() ){
					cout << "push" << endl;
				}
				else{
					cout << "push " << curr3ac->get_result() << endl;
				}
			}

			// If operator type is POP, check if result of 3ac is empty
			else if( curr_op_type == "POP"){
				//Check get_result of 3ac is empty
				if ( curr3ac->get_result().empty() ){
					cout << "pop" << endl;
				}
				else{
					cout << "pop " << curr3ac->get_result() << endl;
				}
			}

			// If operator type is PUSHREG, print "push r0"
			else if( curr_op_type == "PUSHREG"){
				cout << "push r0\n";
			}

			// If operator type is POPREG, print pop r0
			else if( curr_op_type == "POPREG"){
				cout << "pop r0\n";
			}

			// If operator type is LINK, print "link"
			else if( curr_op_type == "LINK"){
				cout << "link" << " " << curr3ac->get_op1() << endl;
			}

			// If operator type is UNLINK, print "unlnk"
			else if( curr_op_type == "UNLINK"){
				cout << "unlink" << endl;
			}

			// If operator type is JSR, print jsr result of 3ac
			else if( curr_op_type == "JSR"){
				cout << "jsr " << curr3ac->get_result() << endl;
			}

			// If operator type is RET, print "ret"
			else if( curr_op_type == "RET"){
				cout << "ret" << endl;
			}

			// If operator type is HALT, print "sys halt"
			else if( curr_op_type == "HALT"){
				cout << "sys halt" << endl;
			}

			// If operator type is STOREI, print 3ac for it along with the steps involved
			else if( curr_op_type == "STOREI"){
				// move value in operand 1 to r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;

				// Store value of r0 in get_result
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is STOREF, print 3ac for it along with the steps involved
			else if( curr_op_type == "STOREF"){
				// move value in operand 1 to r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;

				// Store value of r0 in get_result
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operator type is READI, print 3ac for it along with the steps involved
			else if( curr_op_type == "READI"){
				cout << "sys readi " << IR_vector[i]->get_result() <<endl;
			}

			// If operator type is READF, print 3ac for it along with the steps involved
			else if( curr_op_type == "READF"){
				cout << "sys readr " << IR_vector[i]->get_result() <<endl;
			}

			// If operator type is WRITEI, print 3ac for it along with the steps involved
			else if( curr_op_type == "WRITEI"){
				cout << "sys writei " << IR_vector[i]->get_op1() <<endl;
			}

			// If operator type is WRITEF, print 3ac for it along with the steps involved
			else if( curr_op_type == "WRITEF"){
				cout << "sys writer " << IR_vector[i]->get_op1() <<endl;
			}

			// If operator type is WRITES, print 3ac for it along with the steps involved
			else if( curr_op_type == "WRITES"){
				cout << "sys writes " << IR_vector[i]->get_op1() <<endl;
			}

			// If operator type is COMPARISION, and one before it is STOREI or STOREF, increment i
			else if (IR_vector[i+2]->get_op_type() == "GT" ||
					IR_vector[i+2]->get_op_type() == "GE" ||
					IR_vector[i+2]->get_op_type() == "LT" ||
					IR_vector[i+2]->get_op_type() == "LE" ||
					IR_vector[i+2]->get_op_type() == "NE" ||
					IR_vector[i+2]->get_op_type() == "EQ"   ){
				if ( IR_vector[i+1]->get_op_type() == "STOREI" ||
					 IR_vector[i+1]->get_op_type() == "STOREF"){i++;}
			}
		}
		cout << "sys halt" <<endl;


	}


}
