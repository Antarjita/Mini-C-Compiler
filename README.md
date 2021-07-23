# Mini-C-Compiler
The front end of a compiler using LEX, YACC to make a C compiler focusing mostly on function.

This project includes the lexical,syntax,semantics and IR phase of the compiler. 
In IR phase we have used quadruple datastructure to store our 3 address code representation.
We have also performed optimizations of our IR representation like 
* constant folding 
* constant propogation
* common sub expression elimination
* packing temporaries

To run the code : run the Compile.sh file on your terminal.

eg in MAC systems: ```sh Compile.sh ```
