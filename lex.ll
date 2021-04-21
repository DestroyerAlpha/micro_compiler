%{
//Acknowledgement: Qifan Chang and Zixian Lai
// acknowlegdement for documentation Shivam, Brinal, Rutik and Mehul
#include <string>
#include <vector>
#include "main.h"
#include "microParser.hpp"
#include <stdio.h>
#include<iostream>

using namespace std;
// Defining broad classes:
// DIGIT - recognises a digit being read
// LETTER - recognises a letter being read
// ID - recognises format for ID and only accepts those formats.
// For Tokens: 
// returning the relevent token to microParser.yy

%}

DIGIT	[0-9]
LETTER	[A-Za-z]
ID		{LETTER}({LETTER}|{DIGIT})*

%option noyywrap
%option yylineno

%%
PROGRAM	{return TOKEN_PROGRAM; // Returns relevent token to microParser.yy
}
BEGIN	{return TOKEN_BEGIN; // Returns relevent token to microParser.yy
}
END	{return TOKEN_END; // Returns relevent token to microParser.yy
}
FUNCTION	{return TOKEN_FUNCTION; // Returns relevent token to microParser.yy
}
READ	{return TOKEN_READ; // Returns relevent token to microParser.yy
}
WRITE	{return TOKEN_WRITE; // Returns relevent token to microParser.yy
}
IF 	{return TOKEN_IF; // Returns relevent token to microParser.yy
}
ELSE	{return TOKEN_ELSE; // Returns relevent token to microParser.yy
}
FI 	{return TOKEN_FI; // Returns relevent token to microParser.yy
}
FOR	{return TOKEN_FOR; // Returns relevent token to microParser.yy
}
ROF	{return TOKEN_ROF; // Returns relevent token to microParser.yy
}
RETURN 	{return TOKEN_RETURN; // Returns relevent token to microParser.yy
}
INT 	{yylval.str = new string(yytext); return TOKEN_INT; // Returns relevent token to microParser.yy
}
VOID	{return TOKEN_VOID; // Returns relevent token to microParser.yy
}
STRING 	{yylval.str = new string(yytext); return TOKEN_STRING; // Returns relevent token to microParser.yy
}
FLOAT {yylval.str = new string(yytext); return TOKEN_FLOAT; // Returns relevent token to microParser.yy
}

{ID}					{yylval.str = new string(yytext); return TOKEN_IDENTIFIER; // Returns relevent token to microParser.yy and creates a object for the symbol table
}

{DIGIT}+				{yylval.str = new string(yytext); return TOKEN_INTLITERAL; // Returns relevent token to microParser.yy and creates a object for the symbol table
}

{DIGIT}*"."{DIGIT}+		{yylval.str = new string(yytext); return TOKEN_FLOATLITERAL; // Returns relevent token to microParser.yy and creates a object for the symbol table
}

":="	{return TOKEN_OP_NE; // Returns relevent token to microParser.yy
}
"+"	{return TOKEN_OP_PLUS; // Returns relevent token to microParser.yy
}
"-"	{return TOKEN_OP_MINS; // Returns relevent token to microParser.yy
}
"*"	{return TOKEN_OP_STAR; // Returns relevent token to microParser.yy
}
"/"	{return TOKEN_OP_SLASH; // Returns relevent token to microParser.yy
}
"="	{return TOKEN_OP_EQ; // Returns relevent token to microParser.yy
}
"!="	{return TOKEN_OP_NEQ; // Returns relevent token to microParser.yy
}
"<"	{return TOKEN_OP_LESS; // Returns relevent token to microParser.yy
}
">"	{return TOKEN_OP_GREATER; // Returns relevent token to microParser.yy
}
"("	{return TOKEN_OP_LP; // Returns relevent token to microParser.yy
}
")"	{return TOKEN_OP_RP; // Returns relevent token to microParser.yy
}
";"	{return TOKEN_OP_SEMIC; // Returns relevent token to microParser.yy
}
","	{return TOKEN_OP_COMMA; // Returns relevent token to microParser.yy
}
"<="	{return TOKEN_OP_LE; // Returns relevent token to microParser.yy
}
">=" {return TOKEN_OP_GE; // Returns relevent token to microParser.yy
}
"#".* {}
\"([^\"\n]|\"\")*\"			{yylval.str = new string(yytext); return TOKEN_STRINGLITERAL; // Returns relevent token to microParser.yy and creates a object for the symbol table
}
"--".*\n			{/* deleted */ // Comments
}
[ \t\n\r]+			{/* deleted */ // Tabs, Newlines etc
}



%%
