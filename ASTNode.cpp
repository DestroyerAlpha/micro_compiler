// Acknowledgement: See README.md 
// Importing ASTNode.h, where the classes are defined.
#include "ASTNode.h"

namespace std{

	// ASTNode Constructor Class:
	ASTNode::ASTNode(){
		// Type of AST Node
		type = undefinded;
		// Left Child
		left_node = NULL;
		// Right Child
		right_node = NULL;
		// Type of operation
		Operation_type = 0;
		// Value of node
		value = "";
		// Name / ID of node
		id_name = "";
		// Is the node an integer or a float? int = true & float = false
		int_or_float = true;
		temp_count = "";
	}

	// Destructor function. 
	ASTNode::~ASTNode(){
	}

	// Changing node type to n_type
	void ASTNode::change_node_type(AST_Node_type n_type){
		type = n_type;
	}

	// Fetch node type
	AST_Node_type ASTNode::get_node_type(){
		return type;
	}

	// Change operation type to op_type
	void ASTNode::change_operation_type(int op_type){
		Operation_type = op_type;
	}

	// Fetch operation type
	int ASTNode::get_operation_type(){
		return Operation_type;
	}

	// Set name to name_string
	void ASTNode::add_name(string name_string){
		id_name = name_string;
	}

	// Set value to var_value
	void ASTNode::add_value(string var_value){
		value = var_value;
	}

	// Fetch name / ID
	string ASTNode::get_name(){
		return id_name;
	}

	// Fetch value
	string ASTNode::get_value(){
		return value;
	}

	// Set left child
	void ASTNode::add_left_child(ASTNode* left){
		left_node = left;
	}

	// Set right child
	void ASTNode::add_right_child(ASTNode* right){
		right_node = right;
	}

	// Fetch left child
	ASTNode* ASTNode::get_left_node(){
		return left_node;
	}

	// Fetch right child
	ASTNode* ASTNode::get_right_node(){
		return right_node;
	}

	// Set int_or_float
	void ASTNode::change_int_or_float(bool set){
		int_or_float = set;
	}

	// Fetch int_or_float
	bool ASTNode::get_int_or_float(){
		return int_or_float;
	}

	// Set temp_count
	void ASTNode::change_temp_count(string number){
		temp_count = number;
	}

	// Fetch temp_count
	string ASTNode::get_temp_count(){
		return temp_count;
	}

	// Constructor function for class IR_code
	IR_code::IR_code(string op_type, string op1, string op2, string result, int count){
		// set op_type
		op_type_code = op_type;
		// set op1 code 
		op1_code = op1;
		// set op2 code
		op2_code = op2;
		// set result_code
		result_code = result;
		// set reg_counter
		reg_counter = count;
	}

	// Destructor function for IR_code
	IR_code::~IR_code(){

	}

	// Fetch op_type
	string IR_code::get_op_type(){
		return op_type_code;
	}

	// Fetch op1_code
	string IR_code::get_op1(){
		return op1_code;
	}

	// Fetch op2_code
	string IR_code::get_op2(){
		return op2_code;
	}

	// Fetch result
	string IR_code::get_result(){
		return result_code;
	}

	// Fetch reg_counter
	int IR_code::get_reg_counter(){
		return reg_counter;
	}


}
