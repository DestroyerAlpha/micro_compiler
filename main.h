//Acknowledgement: Qifan Chang and Zixian Lai

//Importing relevant libraries
#include <stdio.h>
#include <stdlib.h>
#include <list>
#include <map>
#include <utility>
#include <algorithm>
#include "Symbol.h"
#include "Scope.h"
#include "ASTNode.h"
#include "Tiny.h"

// Creating Symbol Table, a vector of elements of scope class
extern std::vector<std::Scope*> SymTabHead;
// Creating IR_vector, a vector of elements of IR_code Class
extern std::vector<std::IR_code*> IR_vector;
