dev:
	@echo "Shivam Chaturvedi"
	@echo "180010032@iitdh.ac.in"
compiler:
	@bison -d -t -o microParser.cpp microParser.yy
	@flex lex.ll
	@g++ -o parser.o -c microParser.cpp
	@g++ -c -o scanner.o lex.yy.c
	@g++ -c -o main.o main.cpp
	@g++ -o compiler main.o scanner.o parser.o Symbol.cpp Scope.cpp ASTNode.cpp Tiny.cpp
	@chmod +x runme.sh
clean:
	@rm -f compiler *.c *.o microParser.hpp microParser.cpp