	Files:       lexfile.l          // input of lex
		         stringtable.c      // hash table and string table
                 proj2.h,proj2.c    // defines the parse tree
                 grammar.y          // input of yacc
                 semantic.c         // creates the symbol table
                 proj3.h,proj3.c    // semantic analysis
				 proj4.h,proj4.c    // code generation
				 
	
        Note:
		 To run it using unix commands, follow the below steps:
                 1. yacc -d grammar.y
                 2. flex lexfile.l
                 3. gcc lex.yy.c y.tab.c stringtable.c proj2.c proj3.c proj4.c semantic.c -o temp
                 4. ./temp <filename

        