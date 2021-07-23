%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include "Token_Type.h"
	#include "SymTab.h"
    #include "ICG.h"
    
    #define FILE_LINE_LEN 256
    #define FILE_NAME_LEN 256

    YYSTYPE yylval;
    //char yylval[TOK_VAL_SIZE];
    int yyerror(const char *s);
    int yylex(void);

    FILE *yyin;
	int yylex();
	char* type;
	int err = 0;
	//FILE* fp;
	char fname[FILE_NAME_LEN];
	FILE *lex_output_fp;
	FILE *parser_output_fp;	
	
	int no_para=0;
	char para_no[10];
	int check_para=-1;

	
	//For Intermediate Code Generation
	#define TEMP_IR_BUF_SIZE 800
	#define BUF_SMALL 500
	#define BUF_BIG 1000
	#define BUF_MAX 1000000
	char temp_name[YYSTYPE_SIZE];
	char label_name[YYSTYPE_SIZE];
	char temp_label_name[YYSTYPE_SIZE];
	
	quad_list *quadruple_list;
	quadruple*q_var_dec; //used for setting prev_outer_unit_end in case of global vars
	char null_str[1]={'\0'}; //represents empty str
	
%}

%error-verbose
%token less lessequal equalequal greater greaterequal exclaimequal
%token numeric_constant double_constant 
%token if_ else_ for_ while_
%token comma semi l_paren r_paren l_brace r_brace
%token plus minus star slash percent 
%token equal amp 


//eof

//Tokens to implement Lex for

%token id char_constant str_constant
%token int_ char_ double_ void_
%token return_

//Token to handle error recovery
//%token error

//Disambiguating Rules - Precedence and Associativity

/* 
1.Diasambiguating if statement
Psuedo Token used to decide precedence in if...else statement
else should have a higher precedence as else is matched with the nearer if in C.
nonassoc sets that two or more then/else can not occur. Associativity between them can not be decided.
*/
%nonassoc reduce_if //Psuedo-token     
%nonassoc else_

/*
2. Disambiguating Relational Operators (Rule 47-49)
Must associate each rule with an associativity and precedence
*/

%left equalequal exclaimequal
%left less lessequal greater greaterequal

//%start Program

%start Start

%%

/* syntax of relational operators */

Start : Program  { 
    FILE *ir_fp;
    ir_fp = fopen("IR.txt", "w");
    if(! ir_fp){
        printf("Opening IR.txt failed\n");
        exit(1);
    }
    fputs($1.ir_rep, ir_fp);
    fclose(ir_fp);
    
    printf("QUADRUPLE\n");
    display_three_add(quadruple_list);
    write_three_add(quadruple_list, "ir_quad.txt");
    };

Program : Outer_most_unit Program  { $$.ir_rep = malloc(sizeof(char)*BUF_MAX); 
    sprintf($$.ir_rep, "%s\n%s", $1.ir_rep, $2.ir_rep); 
    //printf("PROG_IR\n"); 
    //printf("%s***\n", $$.ir_rep);
    
    /*
    Placing this in start so that file is opened and closed just once
    FILE *ir_fp;
    ir_fp = fopen("IR.txt", "w");
    if(! ir_fp){
        printf("Opening IR.txt failed\n");
        exit(1);
    }
    fputs($$.ir_rep, ir_fp);
    fclose(ir_fp);
    */
    }
| { $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); sprintf($$.ir_rep, "%s", ""); }
;

Outer_most_unit :Var_declaration {$$=$1; prev_outer_unit_end = q_var_dec; }
| Func_prototype {$$=$1;}
| Func_defn {$$=$1;}
;

/*
prev_outer_unit_end points to the end of the previous Outer_most_unit. Its used to insert "function begin", "prototype begin" and "return_type" in the correct positions. prev_outer_unit_end is updated on "function end" and "prototype end". It is also updated for global variables.
Updation of prev_outer_unit_end for global vars works as
In var_declaration, q_var_dec is used, which is global. If the var_declaration is got from the above Outer_most_unit production, and not from Function_body production, prev_outer_unit_end is set to q_var_dec.
*/

/*
Func_prototype : Proto_part1 Param_list Proto_part2 { sprintf(para_no, "%d,", no_para);
					insert_node(top,$2.token_value, strcat(para_no,$1.token_value) , "prototype", yylloc.first_line);
					no_para=0;
                    fprintf(parser_output_fp, "Function Prototype of %s() parsed\n", $2.token_value);
                    printf("prototype end %s\n", $1.token_value);
                     };

Proto_part1 : Type id l_paren   { printf("prototype begin %s\n", $1.token_value); printf("return %s\n", $1.token_value); }
| void_ id l_paren { printf("prototype begin %s\n", $1.token_value); printf("return %s\n", $1.token_value); }
;

Proto_part2 : r_paren semi ;
*/



Func_prototype : Type id l_paren Param_list r_paren semi    {

					sprintf(para_no, "%d,", no_para);
					insert_node(top,$2.token_value, strcat(para_no,$1.token_value) , "prototype", yylloc.first_line);
					no_para=0;
                    fprintf(parser_output_fp, "Function Prototype of %s() parsed\n", $2.token_value);
                    
                    //Generating IR
                    /* $$ = get_new_yylval("Relational_expr", temp_name); printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); */
                    
                    char func_begin[TEMP_IR_BUF_SIZE];
                    char func_end[TEMP_IR_BUF_SIZE];
                    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
                    sprintf(func_begin, "%s %s\n%s %s\n", "prototype begin", $2.token_value, "return_type", $1.token_value);
                    sprintf(func_end, "prototype end %s\n", $2.token_value);              
                    sprintf($$.ir_rep, "%s %s %s", func_begin, $4.ir_rep, func_end);
                    /*
                    printf("formal_param %s\n", $1.token_value);
                    printf("prototype end %s\n", $1.token_value);
                    */
                    
                    //printf("IR FOR Func_prototype\n");
                    //printf($$.ir_rep);
                    //printf("%s\n**\n", $$.ir_rep);
                    
                    free($4.ir_rep);
                    
                    quadruple *q = create_quadruple("return_type", $1.token_value, null_str, null_str);
                    //insert_quadruple(quadruple_list, q);
                    insert_func_begin(quadruple_list, q);
                    
                    q = create_quadruple("prototype begin", $2.token_value, null_str, null_str);
                    //insert_quadruple(quadruple_list, q);
                    insert_func_begin(quadruple_list, q);
                    
                    //q = create_quadruple("prototype end", $2.token_value, null_str, null_str);
                    //insert_quadruple(quadruple_list, q);
                    
                    prev_outer_unit_end = create_quadruple("prototype end", $2.token_value, null_str, null_str);
                    insert_quadruple(quadruple_list, prev_outer_unit_end);
                    
                }
| void_ id l_paren Param_list r_paren semi {
					//printf("in else");
					sprintf(para_no, "%d,", no_para);
					insert_node(top,$2.token_value, strcat(para_no,$1.token_value) , "prototype", yylloc.first_line);
					no_para=0;
                    fprintf(parser_output_fp, "Function Prototype of %s() parsed\n", $2.token_value);
                    
                    char func_begin[TEMP_IR_BUF_SIZE];
                    char func_end[TEMP_IR_BUF_SIZE];
                    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
                    sprintf(func_begin, "%s %s\n%s %s\n", "prototype begin", $2.token_value, "return_type", $1.token_value);
                    sprintf(func_end, "prototype end %s\n", $2.token_value);              
                    sprintf($$.ir_rep, "%s %s %s", func_begin, $4.ir_rep, func_end);
                    
                    //printf("IR FOR Func_prototype\n");
                    //printf("%s\n**\n", $$.ir_rep);
                    
                    //printf("Before freeing %s\n", $4.ir_rep);
                    free($4.ir_rep);
                    
                    quadruple *q = create_quadruple("prototype begin", $2.token_value, null_str, null_str);
                    insert_func_begin(quadruple_list, q);
                    
                    q = create_quadruple("return_type", $1.token_value, null_str, null_str);
                    //insert_quadruple(quadruple_list, q);
                    insert_func_begin(quadruple_list, q);
                    
                    //q = create_quadruple("prototype end", $2.token_value, null_str, null_str);
                    prev_outer_unit_end = create_quadruple("prototype end", $2.token_value, null_str, null_str);
                    insert_quadruple(quadruple_list, prev_outer_unit_end);
                    
                }				
;



Param_list : Has_args { $$.ir_rep = $1.ir_rep; //printf("In Param_list %s\n", $$.ir_rep);
}
|   { $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); strcpy($$.ir_rep, ""); }
;


Has_args :  Type id comma Has_args 
		{
			no_para+=1;
			insert_node(top,$2.token_value, "undef" , $1.token_value, yylloc.last_line);
			// undef is justified because the variables in function protoype have no value and for function definition it ts the value in function call
			//$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
			//printf("has-args-2 1-val %s, 2-val %s\n", $1.token_value, $2.token_value);
			//printf("%p\n", $$.ir_rep);
			$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
			if(!$$.ir_rep){
			    printf("ERROR malloc failed\n");
			    exit(1);
			}
			sprintf($$.ir_rep, "formal_parameter %s %s\n%s", $1.token_value, $2.token_value, $4.ir_rep);
			
			quadruple *q = create_quadruple("formal_parameter", $1.token_value, $2.token_value, null_str);
            insert_quadruple(quadruple_list, q);
                    
		}
| Type id 
		{
			insert_node(top,$2.token_value, "undef" , $1.token_value, yylloc.last_line);
			no_para+=1;
			
			//printf("formal_parameter %s %s\n", $1.token_value, $2.token_value);
			
			$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
			if(!$$.ir_rep){
			    printf("ERROR malloc failed\n");
			    exit(1);
			}
			//printf("has_args-1 1-val %s, 2-val %s\n", $1.token_value, $2.token_value);
			sprintf($$.ir_rep, "formal_parameter %s %s\n", $1.token_value, $2.token_value);
			//printf("$$-code %s\n", $$.ir_rep);
			
			quadruple *q = create_quadruple("formal_parameter",$1.token_value, $2.token_value, null_str);
            insert_quadruple(quadruple_list, q);
		}
;

Func_defn : Type id l_paren Param_list r_paren open Func_body close
		{
			if(exists(top,$2.token_value) || exists(top,"main")==0 || strcmp("main",$2.token_value)==0)
			{
				if(check_para!=no_para && strcmp("main",$2.token_value)!=0 && exists(top,$2.token_value))
				{
					printf("%s Mismatch of Function prototype and definition\n",$2.token_value);
					check_para=-1;
				}
				else
				{
					sprintf(para_no, "%d,", no_para);
					insert_node(top,$2.token_value, strcat(para_no,$1.token_value) , "func", yylloc.first_line);
				}
				no_para=0;
				fprintf(parser_output_fp, "Function Definition of %s() parsed\n", $2.token_value);
			}
			else
			{
				printf("Function prototype not defined\n");
			}
			
			char func_begin[TEMP_IR_BUF_SIZE];
            char func_end[TEMP_IR_BUF_SIZE];
            $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
            sprintf(func_begin, "%s %s\n%s %s\n", "function begin", $2.token_value, "return_type", $1.token_value);
            sprintf(func_end, "function end %s\n", $2.token_value);              
            sprintf($$.ir_rep, "%s%s%s%s", func_begin, $4.ir_rep, $7.ir_rep, func_end);
            //printf("_____FUNC DEFINITION______OF %s\n", $2.token_value);
            //printf("%s\n", $$.ir_rep);
            
			quadruple *q = create_quadruple("return_type", $1.token_value, null_str, null_str);
			//insert_quadruple(quadruple_list, q);
			insert_func_begin(quadruple_list, q);
			//q = create_quadruple("function end", $2.token_value, null_str, null_str);
			 //"return_type" should be inserted before "function begin" because only then will "function begin" quadruple be inserted above "return_type"
			q = create_quadruple("function begin", $2.token_value, null_str, null_str);
			insert_func_begin(quadruple_list, q);
			prev_outer_unit_end = create_quadruple("function end", $2.token_value, null_str, null_str);
			insert_quadruple(quadruple_list, prev_outer_unit_end);
			
		}
| void_ id l_paren Param_list r_paren open Func_body close
        {
			if(exists(top,$2.token_value) || exists(top,"main")==0 || strcmp("main",$2.token_value)==0)
			{
				if(check_para!=no_para && strcmp("main",$2.token_value)!=0 && exists(top,$2.token_value))
				{
					printf("%s Mismatch of Function prototype and definition\n",$2.token_value);
					check_para=-1;
				}
				else
				{
					sprintf(para_no, "%d,", no_para);
					insert_node(top,$2.token_value, strcat(para_no,$1.token_value) , "func", yylloc.first_line);
				}
				no_para=0;
				fprintf(parser_output_fp, "Function Definition of %s() parsed\n", $2.token_value);
			}
			else
			{
				printf("Function prototype not defined\n");
			}
			
			char func_begin[TEMP_IR_BUF_SIZE];
            char func_end[TEMP_IR_BUF_SIZE];
            $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
            sprintf(func_begin, "%s %s\n%s %s\n", "function begin", $2.token_value, "return_type", $1.token_value);
            sprintf(func_end, "function end %s\n", $2.token_value);              
            sprintf($$.ir_rep, "%s%s%s%s", func_begin, $4.ir_rep, $7.ir_rep, func_end);
            //printf("_____FUNC DEFINITION______OF %s\n", $2.token_value);
            //printf("%s\n", $$.ir_rep);
            
            //"return_type" should be inserted before "function begin" because only then will "function begin" quadruple be inserted above "return_type"
			quadruple *q = create_quadruple("return_type", $1.token_value, null_str, null_str);
			//insert_quadruple(quadruple_list, q);
			insert_func_begin(quadruple_list, q);
			//q = create_quadruple("function end", $2.token_value, null_str, null_str);
			 q = create_quadruple("function begin", $2.token_value, null_str, null_str);
			//insert_quadruple(quadruple_list, q);
			insert_func_begin(quadruple_list, q);
			prev_outer_unit_end = create_quadruple("function end", $2.token_value, null_str, null_str);
			insert_quadruple(quadruple_list, prev_outer_unit_end);
			
		}
;

/*| error r_brace {printf("Invalid function definition for function %s\n", $2.token_value); } */
;

Func_body : Statement_block Func_body {
        //printf("Fine before func_body:%s\n", $$.ir_rep);
        $$.ir_rep = malloc(sizeof(char)*BUF_BIG); 
        //printf("In func body: sb = %s, fb = %s\n", $1.ir_rep, $2.ir_rep);
        sprintf($$.ir_rep, "%s%s", $1.ir_rep, $2.ir_rep);
        free($1.ir_rep);
        free($2.ir_rep); 
        //TODO: Not sure why this gives free(): double free detected in tcache 2

        //printf("Fine in func_body:%s\n", $$.ir_rep);
    }
| { $$.ir_rep = malloc(sizeof(char)*BUF_BIG); sprintf($$.ir_rep, "%s", ""); }
//| error r_brace
;

Return_stmt : return_ Rval semi {
        $$.ir_rep = malloc(sizeof(char)*BUF_BIG); 
        sprintf($$.ir_rep, "%sreturn_val %s\n", $2.ir_rep, $2.loc_name);
        free($2.ir_rep);
        quadruple* q = create_quadruple("return_val", $2.loc_name, null_str, null_str);
        insert_quadruple(quadruple_list, q);
    }
;
/*| error semi { printf("Invalid return statement\n") ; };*/

Var_declaration : Type id semi 
		{

			if(check_type($2.token_value))
			{
				insert_node(top,$2.token_value, "", $1.token_value, yylloc.last_line);
				fprintf(parser_output_fp, "Var declaration of %s parsed\n",$2.token_value);
				$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
				sprintf($$.ir_rep, "%s %s\n", $1.token_value, $2.token_value);
				//printf("IR REP for vars:\n%s\n**\n", $$.ir_rep);
				//quadruple* q = create_quadruple($1.token_value, $2.token_value, "", "");
				//insert_quadruple(quadruple_list, q);
				q_var_dec = create_quadruple($1.token_value, $2.token_value, "", "");
				insert_quadruple(quadruple_list, q_var_dec);
			}
			else{
				printf("Illegal usage of identifiers : Keyword as identifier\n");
				$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
				sprintf($$.ir_rep, "%s", "");
				//Not generating IR for lines with syntax errors
			}

		}
| Type id equal Rval semi
		{
			if(check_type($2.token_value))
			{
				insert_node(top,$2.token_value, $4.token_value, $1.token_value,yylloc.last_line);
				fprintf(parser_output_fp, "Var declaration of %s parsed\n",$2.token_value);
				
				char var_dec_line[TEMP_IR_BUF_SIZE];
				$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
				//sprintf($$.ir_rep, "%s %s\n", $1.token_value, $2.token_value);
				//sprintf($$.ir_rep, "%s%s%s = %s\n", $4.ir_rep, $$.ir_rep, $2.token_value, $4.loc_name);
				sprintf(var_dec_line, "%s %s\n", $1.token_value, $2.token_value);
				quadruple* q = create_quadruple($1.token_value, $2.token_value, "", "");
				insert_quadruple(quadruple_list, q);				
				
				sprintf($$.ir_rep, "%s%s%s = %s\n", $4.ir_rep, var_dec_line, $2.token_value, $4.loc_name);
				//printf("IR REP for vars:\n%s\n", $$.ir_rep);
				//q = create_quadruple("=", $4.loc_name, "", $2.token_value);
				//insert_quadruple(quadruple_list, q);
				q_var_dec = create_quadruple("=", $4.loc_name, "", $2.token_value);
				insert_quadruple(quadruple_list, q_var_dec);
							
			}
			else{
				//printf("Illegal usage of identifiers : Keyword as identifier\n");
				
				$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
				sprintf($$.ir_rep, "%s", "");
				//Not generating IR for lines with syntax errors
			}
		}
/* | error semi { printf("Invalid declaration for variable %s\n", $2.token_value); } */
;

//Storing the name of the type, as I require to get the Return type of and parameter types of functions
Type : int_ { $$ = get_new_yylval($1.token_value, ""); //printf("(%s, %s)\n", $$.token_value, $$.loc_name);
//Type isn't stored anywhere, hence loc_name=""
 }
| char_     { $$ = get_new_yylval($1.token_value, "");  }
| double_   { $$ = get_new_yylval($1.token_value, "");  }
/*| error    { printf("Invalid Type %s\n", $$.token_value); } */
;



Statement_block : Statement { $$.ir_rep = $1.ir_rep; }
| open Many_Statements close { $$.ir_rep = $2.ir_rep; //printf("State_Block: %s\n", $2.ir_rep);
}
;

Many_Statements : Statement_block Many_Statements {
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG); 
    sprintf($$.ir_rep, "%s%s", $1.ir_rep, $2.ir_rep);  
    free($1.ir_rep);
    free($2.ir_rep);
    }
|   { 
    $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); 
    sprintf($$.ir_rep, "%s", ""); 
    }
;

open : l_brace {
	saved=top;
	top=create_sym_tab(&sym_chain, saved);
	//printf("%d",saved->head->data.numb);
	//printf("{\n");
};

close : r_brace {
	sym_print(top);
	//top=saved;
	top = top->prev_ptr;
	//printf("}\n");
};

Statement : Var_declaration { $$.ir_rep = $1.ir_rep; //printf("\nStatement: %s\n", $$.ir_rep); 
}
//{printf("Var_declaration parsed\n");}
| Func_calls                { $$.ir_rep = $1.ir_rep; }
                            //{printf("Func_calls parsed\n");}
| While_loop                //{printf("While_loop parsed\n");}
| For_loop                  //{printf("Fo_loop parsed\n");}
| If_stmt                   //{printf("If_stmt parsed\n");}
| Assign_stmt               { $$.ir_rep = $1.ir_rep; //printf("\nStatement: %s\n", $$.ir_rep); 
}
                            //{printf("Assign_stmt parsed\n");}
| Rval semi                 { $$.ir_rep = $1.ir_rep; //printf("\nStatement: %s\n", $$.ir_rep); 
}
                            //{printf("Rval semi parsed\n");}
| semi                      //No IR Code generated for null statements
                            //{printf("semi parsed\n");}
| Return_stmt    { $$.ir_rep = $1.ir_rep; }           
| error semi    { printf("Error in Statement. Ignoring till ;\n"); }
;

Assign_stmt : id equal Rval semi 
		{
			if(exists(top,$1.token_value) && check_type($1.token_value))
			{
				update(top,$1.token_value,$3.token_value);
				
				//printf("in assign statment %s\n",$1.token_value);
				//printf("%s\n",$1.token_value);
			}
			else if(check_type($1.token_value)==0)
			{
				printf("Illegal usage of identifiers : Keyword as identifier\n");
			}
			else
			{
				printf("Variable %s not declared\n",$1.token_value);
			}
			$$ = get_new_yylval("Term", $1.token_value); //printf("%s = %s\n", $$.loc_name, $3.loc_name); 
			
			$$.ir_rep = malloc(sizeof(char)*BUF_BIG);
			//printf("Rval in Assign: %s\n", $3.ir_rep);
			sprintf($$.ir_rep, "%s%s = %s\n", $3.ir_rep, $1.token_value, $3.loc_name);
			//printf("IR FOR Assign stat\n");
			//printf("%s\n",  $$.ir_rep);
			
			quadruple *q = create_quadruple("=", $3.loc_name, "", $1.token_value);
			insert_quadruple(quadruple_list, q);
			
		}
/* | error semi  { printf("Assignment statement is incorrect\n"); }	*/	
;


While_loop :while_ l_paren Rval {get_next_label(); $$ = get_new_yylval("While_loop", label_name); printf("%s]",$$.loc_name); 
$$.ir_rep = malloc(sizeof(char)*BUF_SMALL); sprintf($$.ir_rep, "%s]", $$.loc_name); } r_paren
	{
		get_next_label(); 
		$$ = get_new_yylval("While_loop", label_name);
		//printf("if false %s goto to %s\n",$3.loc_name,$$.loc_name);
		//$$.ir_rep=malloc(sizeof(char)*BUF_SMALL);
		//sprintf($$.ir_rep, "if false %s goto to %s\n",$3.loc_name,$$.loc_name);
		quadruple *q = create_quadruple("if false", $3.loc_name, $$.loc_name, null_str);
		insert_quadruple(quadruple_list, q);
		
	}
	{
		get_next_label(); 
		$$ = get_new_yylval("While_loop", label_name);
		//printf("if true %s goto to %s\n",$3.loc_name,$$.loc_name);
		//printf("%s]",$$.loc_name);
		//$$.ir_rep=malloc(sizeof(char)*BUF_SMALL);
		//sprintf($$.ir_rep, "if true %s goto to %s\n", $3.loc_name, $$.loc_name);
		quadruple *q = create_quadruple("if true", $3.loc_name, $$.loc_name, null_str);
		insert_quadruple(quadruple_list, q);
		q = create_quadruple("label", $$.loc_name, null_str, null_str);
		insert_quadruple(quadruple_list, q);
		
	}
Statement_block 
{
	fprintf(parser_output_fp, "While loop parsed\n"); 
	$$ = get_new_yylval("Factor", $5.loc_name);
	//printf("goto %s\n",$4.loc_name);
	//printf("%s] ",$6.loc_name);
	//$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
	//sprintf($$.ir_rep, "goto %s\n%s] ",$4.loc_name, $6.loc_name);
	//printf("\nWHILE LOOP CODE:\n%s\n", $$.ir_rep);
	quadruple *q = create_quadruple("goto", $4.loc_name, null_str, null_str);
	insert_quadruple(quadruple_list, q);
	q = create_quadruple("label", $6.loc_name, null_str, null_str);
    insert_quadruple(quadruple_list, q);
}
;

For_loop : for_ l_paren Multiple_assignments  Rval semi Rval r_paren  Statement_block 
;

Multiple_assignments : Assign_stmt Multiple_assignments  
| semi 
;


If_stmt : if_ l_paren Rval r_paren Statement_block      %prec reduce_if {
	fprintf(parser_output_fp, "If without Else parsed\n");
	}
| if_ l_paren Rval r_paren Statement_block else_ Statement_block {
	fprintf(parser_output_fp, "If with Else parsed\n");
}
;


Func_calls : id l_paren Func_call_args r_paren semi 
{
	sprintf(para_no, "%d", no_para);
	insert_node(top,$1.token_value, para_no, "call", yylloc.last_line);
	fprintf(parser_output_fp, "Function Call of %s parsed\n", $1.token_value);
	
	$$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
	char f_call_line[TEMP_IR_BUF_SIZE];
	sprintf(f_call_line, "call(%s, %d)\n", $1.token_value, no_para);
	sprintf($$.ir_rep, "%s%s", $3.ir_rep, f_call_line);
	//printf("IR CODE FOR function calls:%s\n", $$.ir_rep);	
	char no_para_str[TEMP_IR_BUF_SIZE];
	sprintf(no_para_str, "%d", no_para);
	
	quadruple *q = create_quadruple("call", $1.token_value, no_para_str, null_str);
	//0 = null = empty str
    insert_quadruple(quadruple_list, q);
    
    no_para=0;
	
}
| id equal id l_paren Func_call_args r_paren semi
 {
	sprintf(para_no, "%d", no_para);
	insert_node(top,$3.token_value, para_no, "call", yylloc.last_line);
	fprintf(parser_output_fp, "Function Call of %s parsed\n", $3.token_value);
	
    get_next_temp(); //Not assigning as loc_name of Func_calls. Bcoz Func_calls grammar arg isn't stored really
	char f_call_line[TEMP_IR_BUF_SIZE];
	sprintf(f_call_line, "%s = %s\n%s = call(%s, %d)\n", $1.token_value, temp_name, temp_name, $3.token_value, no_para);
    $$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
	sprintf($$.ir_rep, "%s%s", $3.ir_rep, f_call_line);
	//printf("IR CODE FOR function calls:%s\n", $$.ir_rep);
	char no_para_str[TEMP_IR_BUF_SIZE];
	sprintf(no_para_str, "%d", no_para);
	quadruple *q = create_quadruple("call", $1.token_value, no_para_str, temp_name);
    insert_quadruple(quadruple_list, q);
    
    no_para=0;
}
|Type id equal id l_paren Func_call_args r_paren semi
 {
	sprintf(para_no, "%d", no_para);
	insert_node(top,$4.token_value, para_no, "call", yylloc.last_line);
	
	get_next_temp(); //Not assigning as loc_name of Func_calls. Bcoz Func_calls grammar arg isn't stored really
	char f_call_line[TEMP_IR_BUF_SIZE];
	sprintf(f_call_line, "%s %s\n%s = %s\n%s = call(%s, %d)\n", $1.token_value, $2.token_value, $2.token_value, temp_name, temp_name, $4.token_value, no_para);
    $$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
	sprintf($$.ir_rep, "%s%s", $3.ir_rep, f_call_line);
	//printf("IR CODE FOR function calls:%s\n", $$.ir_rep);
	fprintf(parser_output_fp, "Function Call of %s parsed\n", $4.token_value);
	
	quadruple *q = create_quadruple($1.token_value, $2.token_value, null_str, null_str); //0 = null = empty str
    insert_quadruple(quadruple_list, q);
    char no_para_str[TEMP_IR_BUF_SIZE];
	sprintf(no_para_str, "%d", no_para);
    q = create_quadruple("call", $4.token_value, no_para_str, $2.token_value);
    insert_quadruple(quadruple_list, q);
    
    no_para=0;
}
;

Func_call_args :  At_least_one_arg { $$.ir_rep = $1.ir_rep;   }
{
	//no_para+=1;
}
|  { $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); sprintf($$.ir_rep, "%s", "");  } //Inserting empty str
;

//TODO: bug - Not able to get last parameter. Should be got from At_Least_one_arg->Rval
At_least_one_arg : Rval comma At_least_one_arg { $$.ir_rep = malloc(sizeof(char)*BUF_BIG); //printf("$s =%s*\n",$3.ir_rep); 
sprintf($$.ir_rep, "%sactual_parameter %s\n %s", $1.ir_rep, $1.loc_name, $3.ir_rep); no_para+=1;
    quadruple *q = create_quadruple("actual_parameter", $1.loc_name, null_str, null_str);
    insert_quadruple(quadruple_list, q);
    }
| Rval { $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); //printf("Rval.loc_name = %s\n", $1.loc_name); 
sprintf($$.ir_rep, "%sactual_parameter %s\n", $1.ir_rep, $1.loc_name); //printf("last_param = %s*\n", $$.ir_rep); 

    quadruple *q = create_quadruple("actual_parameter", $1.loc_name, null_str, null_str);
    insert_quadruple(quadruple_list, q);

}
{
	no_para+=1;
}
;


Rval : Arithmetic_expr  { $$ = get_new_yylval("Rval", $1.loc_name ); 
$$.ir_rep = $1.ir_rep;  }
//{ printf("Rval -> Arithmetic_expr\n") ; }
| str_constant     { get_next_temp(); $$ = get_new_yylval("Rval", temp_name); $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); sprintf($$.ir_rep, "%s=%s\n", $$.loc_name, $1.token_value); 
    quadruple *q = create_quadruple("=", $1.token_value, null_str, $$.loc_name);
    insert_quadruple(quadruple_list, q); }    
//{ printf("Rval -> str_constant\n") ; }
| Relational_expr   { $$ = get_new_yylval("Rval", $1.loc_name ); $$.ir_rep = $1.ir_rep; }
//{ printf("Rval -> Relational_expr\n") ; }
//| Func_calls
;

Relational_expr : Rval less Rval   
    { get_next_temp(); 
    $$ = get_new_yylval("Relational_expr", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
    sprintf($$.ir_rep, "%s%s%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    
    quadruple *q = create_quadruple("<", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    
    }
| Rval lessequal Rval	
    { 
    get_next_temp(); 
    $$ = get_new_yylval("Relational_expr", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
    sprintf($$.ir_rep, "%s%s%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    quadruple *q = create_quadruple("<=", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
     }
| Rval greater Rval	
    { 
    get_next_temp(); 
    $$ = get_new_yylval("Relational_expr", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); 
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
    sprintf($$.ir_rep, "%s%s%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    quadruple *q = create_quadruple(">", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| Rval greaterequal Rval	
    { 
    //printf("Rval1 = %s, Rval2 = %s\n", $1.ir_rep, $3.ir_rep);
    get_next_temp(); 
    $$ = get_new_yylval("Relational_expr", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
    sprintf($$.ir_rep, "%s%s%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    quadruple *q = create_quadruple(">=", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| Rval equalequal Rval	
    { 
    get_next_temp(); 
    $$ = get_new_yylval("Relational_expr", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); 
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
    sprintf($$.ir_rep, "%s%s%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    quadruple *q = create_quadruple("==", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| Rval exclaimequal Rval	
    { 
    get_next_temp(); 
    $$ = get_new_yylval("Relational_expr", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); 
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
    sprintf($$.ir_rep, "%s%s%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    quadruple *q = create_quadruple("!=", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
;


//changed
Arithmetic_expr : Arithmetic_expr plus Term 
    { get_next_temp(); $$ = get_new_yylval("Arithmetic_expr", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); 
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
    sprintf($$.ir_rep, "%s\n%s\n%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    
    quadruple *q = create_quadruple("+", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    
    }
| Arithmetic_expr minus Term { get_next_temp(); 
    $$ = get_new_yylval("Arithmetic_expr", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG);
    //sprintf($$.ir_rep, "%s = %s %s %s\n%s", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name, $3.ir_rep);
    sprintf($$.ir_rep, "%s\n%s\n%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name);
    
    quadruple *q = create_quadruple("-", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| Term  { $$.ir_rep = $1.ir_rep; }
;

Term : Term star Factor { 
    get_next_temp(); 
    $$ = get_new_yylval("Term", temp_name); // printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); 
    $$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
    sprintf($$.ir_rep, "%s%s%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); free($1.ir_rep); free($3.ir_rep);
    quadruple *q = create_quadruple("*", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| Term slash Factor 
    { get_next_temp(); $$ = get_new_yylval("Term", temp_name); 
    //printf("%s = %s %s %s\n", $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); 
    $$.ir_rep = malloc(sizeof(char)*BUF_SMALL);
    sprintf($$.ir_rep, "%s%s%s = %s %s %s\n", $1.ir_rep, $3.ir_rep, $$.loc_name, $1.loc_name, $2.token_value, $3.loc_name); free($1.ir_rep); free($3.ir_rep);
    quadruple *q = create_quadruple("/", $1.loc_name, $3.loc_name, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| Factor { $$.ir_rep = $1.ir_rep; }
;


Factor : id { 
    get_next_temp(); 
    $$ = get_new_yylval("Factor", temp_name); //printf("%s = %s\n", $$.loc_name, $1.token_value); 
    $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); 
    sprintf($$.ir_rep, "%s = %s\n", $$.loc_name, $1.token_value);
    quadruple *q = create_quadruple("=", $1.token_value, null_str, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| numeric_constant { 
    get_next_temp(); 
    $$ = get_new_yylval("Factor", temp_name); //printf("%s = %s\n", $$.loc_name, $1.token_value); 
    $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); 
    sprintf($$.ir_rep, "%s = %s\n", $$.loc_name, $1.token_value);
    quadruple *q = create_quadruple("=", $1.token_value, null_str, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| l_paren Arithmetic_expr r_paren {
    get_next_temp(); 
    $$ = get_new_yylval("Factor", temp_name); 
    $$.ir_rep = malloc(sizeof(char)*BUF_BIG); 
    sprintf($$.ir_rep, "%s%s = %s\n", $2.ir_rep, $$.loc_name, $2.loc_name); 
    quadruple *q = create_quadruple("=", $2.loc_name, null_str, $$.loc_name);
    insert_quadruple(quadruple_list, q);
    }
| char_constant {
   get_next_temp(); 
   $$ = get_new_yylval("Factor", temp_name); 
   $$.ir_rep = malloc(sizeof(char)*BUF_SMALL); 
   sprintf($$.ir_rep, "%s = %s\n", $$.loc_name, $1.token_value);
   quadruple *q = create_quadruple("=", $1.token_value, null_str, $$.loc_name);
  insert_quadruple(quadruple_list, q);
  }
//| error semi {printf("Invalid operand in arithmetic expression\n");}
;


    

%%

int yyerror(const char *s){
	extern int yylineno;
	int i;
	char line[FILE_LINE_LEN];
	FILE *err_fp;
    printf("[%d]Error Ocurred: %s \n",yylineno, s); 
    //printf("%d, %d, %d, %d\n", yylloc.first_line, yylloc.first_column, yylloc.last_line, yylloc.last_column);
    
    err_fp = fopen(fname, "r");
    if(!err_fp){
        printf("Error opening file: %s\n", fname);
        exit(1);
    }
    for(i=0; i<yylloc.last_line; i++){
        fgets(line, FILE_LINE_LEN, err_fp);
    }
    printf("line:\n%s", line);
    //Print spaces till index=last_column, then print ^ to mark token at which error ocurred
    for(i=0; i<yylloc.last_column-1; i++){
        printf(" ");
    }
    printf("^\n");
    fclose(err_fp);
    
	return 0;
}

int main(int argc, char* argv[])
{
    if(argc!=2){
        printf("INVALID USAGE\n");
        printf("Syntax ./a.out fileName\n");
        exit(1);
    }
	char c;
	strcpy(fname, argv[1]);
	//printf("fname = %s\n", fname);
	//yyin = fopen(argv[1], "r");
	yyin = fopen(fname, "r");
	if(!yyin){
	    printf("ERROR: Could not open %s\n", fname);
	    exit(1);
	}
	init(&sym_chain);
	top = create_sym_tab(&sym_chain, NULL);
	//printf("created\n");

	parser_output_fp = fopen("parser_output.txt", "w");
	if(! parser_output_fp){
	    printf("ERROR: Could not open parser_output.txt\n");
	    exit(1);
	}
	lex_output_fp = fopen("lexer_output.txt", "w");
	if(! lex_output_fp){
	    printf("ERROR: Could not open lex_output.txt\n");
	    exit(1);
	}
	
	FILE* sym_fp = fopen("symbol_table.txt","w");
	fclose(sym_fp);
    
    quadruple_list = malloc(sizeof(quad_list));
    quadruple_list->head = NULL;

	int status=yyparse();
	if(status)
	{
		printf("\nUnsuccessful \n");
	}
    else
	{
		printf("\nPARSING SUCCESSFUL!\n");
	}
	sym_print(top);
	
	optimisation(quadruple_list);
	
    free_symbol_table(top);
	//fclose(fp);
	fclose(parser_output_fp);
    fclose(lex_output_fp);
	return status;
}

void init(CHAINED_SYM_TAB_H *sym_chain_ptr)
{
	sym_chain_ptr->sym_tab = NULL;
}

TABLE_H *create_sym_tab(CHAINED_SYM_TAB_H *sym_chain_ptr, TABLE_H*  parent_tab)
{
	TABLE_H *new_sym_tab = (TABLE_H *) malloc(sizeof(TABLE_H));
	if(!new_sym_tab){
		printf("ERROR: malloc returned NULL\n");
	}
	new_sym_tab->head=NULL;
	new_sym_tab->entries=0;
	new_sym_tab->prev_ptr = parent_tab;
	if(parent_tab == NULL){
		sym_chain_ptr->sym_tab = new_sym_tab;
	}
	return new_sym_tab;
}

void insert_node(TABLE_H* cur_tab, char* name, char* value, char* type, int lineno)
{
	//Add code to check already declared
	
	NODE* new_node = (NODE*) malloc(sizeof(NODE));
	if(!new_node){
		printf("ERROR: malloc returned NULL inside insert_node()\n");
	}
	strcpy(new_node->name,name);
	new_node->next=NULL ;
	//test->scope=scope;
	new_node->line=lineno;
	strcpy(new_node->type, type);
	
	if(strcmp(value,"")!=0)
	{
		if(strcmp(type,"int")==0 )
			new_node->data.numb=atoi(value);
		else if(strcmp(type,"double")==0)
			new_node->data.decimal=atof(value);
		else if(strcmp(type,"char")==0)
			//strcpy(new_node->data.str,value);
			new_node->data.ch = value[0];
	    else if(strcmp(type,"func")==0 || strcmp(type,"prototype")==0)
			strcpy(new_node->data.str,value);
		else if(strcmp(type,"call")==0)
			new_node->data.numb=atoi(value);
	}
	else
	{
		if(strcmp(type,"int")==0 )
			new_node->data.numb=0;
		else if(strcmp(type,"double")==0)
			new_node->data.decimal=0.0;
		else if(strcmp(type,"char")==0)
		    new_node->data.ch='\0';
			//strcpy(new_node->data.str,value);
		else if(strcmp(type,"func")==0 || strcmp(type,"prototype")==0)
			strcpy(new_node->data.str,value);
		else if(strcmp(type,"call")==0)
			new_node->data.numb=0;
	}
	
	//printf("%s",test->data.str);
	NODE* h = cur_tab->head;

	if(h==NULL)
	{	
		cur_tab->head=new_node;
		//cur_tab->entries+=1;
		//print();
		//return;
	}
	else{
		while(h->next!=NULL)
		{
			h=h->next;
		}
		h->next=new_node;
	}
	cur_tab->entries+=1;
	//printf("entries = %d\n", cur_tab->entries);
	//print();
}

//void print(TABLE* s)
void sym_print(TABLE_H* sym_tab)
{
	//NODE* h = s->head;
	TABLE_H* s = sym_tab;
	NODE* h;
    int i;
    //FILE* sym_fp = fopen("symbol_table.txt","w");
    FILE* sym_fp = fopen("symbol_table.txt","a");
    if(!sym_fp){
    	printf("ERROR: symbol_table.txt couldn't be opened\n");
    }
    fprintf(sym_fp,"\nSymbol table \n%-30s%-30s%-30s%-30s","Name","Value","Type","Line Referred");
	while(s!=NULL){
	    fprintf(sym_fp,"\n-----------------------------------------------------------------------------------------------------------------------------------\n");
	    h = s->head;
	    for(i=0;i<s->entries; i++ )
	    while(h) {
		    if(strcmp(h->type,"int")==0)
			    fprintf(sym_fp,"%-30s%-30d%-30s%-30d\n", h->name, h->data.numb, h->type, h->line);
		    else if(strcmp(h->type,"double")==0)
			    fprintf(sym_fp,"%-30s%-30f%-30s%-30d\n", h->name, h->data.decimal, h->type, h->line);
		    else if(strcmp(h->type,"char")==0)
			    fprintf(sym_fp,"%-30s%-30s%-30s%-30d\n", h->name, h->data.str, h->type, h->line);
		    else if(strcmp(h->type,"func")==0)
			    fprintf(sym_fp,"%-30s%-30s%-30s%-30d\n", h->name, h->data.str, h->type, h->line);
		    else if(strcmp(h->type,"call")==0)
			    fprintf(sym_fp,"%-30s%-30d%-30s%-30d\n", h->name, h->data.numb, h->type, h->line);
		
		    h=h->next;
	    }
	    //printf("\n\n");
	    fprintf(sym_fp, "\n\n");
	    s = s->prev_ptr;
	}
	fclose(sym_fp);
}

int exists(TABLE_H* cur_tab, char* name){
    NODE *node = NULL;
    while(cur_tab != NULL){
         node = cur_tab->head;
         while(node != NULL){
            if(!strcmp(node->name, name)){
				if(strcmp(node->type,"prototype")==0)
				{
					check_para=atoi(strtok(node->data.str,","));
				}
                return 1;
            }
            node = node->next;
         }
         cur_tab = cur_tab->prev_ptr;
    }
    return 0;
}

//Returns 0 if name not found - update() failed
int update(TABLE_H* cur_tab, char* name, char* val)
{
	//NODE* temp = s->head;
	//printf("update\n");
    NODE* node;	
	
	while(cur_tab != NULL){
	    node = cur_tab->head;
	    while(node != NULL)
	    {
		    //printf("%s\n",temp->name);
		    if(strcmp(node->name,name) == 0){
			    //printf("current:%d\n",temp->data.numb);
			    if(strcmp(node->type,"int")==0){
				    node->data.numb = atoi(val);
				}
			    else if(strcmp(node->type,"double")==0){
				    node->data.decimal = atof(val);
				}
			    else if(strcmp(node->type,"char")==0) {
				    //strcpy(temp->data.str,val);
				    node->data.ch = val[0];
				}
				else if(strcmp(node->type,"func")==0) {
				    strcpy(node->data.str,val);
				    //node->data.ch = val;
				}
				else if(strcmp(node->type,"call")==0) {
				    //strcpy(temp->data.str,val);
				    node->data.numb = atoi(val);
				}
				return 1;
		    }
		    node = node->next;
		    //printf("%d",temp->data.numb);
	    }
	    cur_tab = cur_tab->prev_ptr;
	}
    return 0;
	//print();
}


void free_symbol_table(TABLE_H *s_ptr){
    NODE *cur_ptr, *next_ptr;
    cur_ptr = s_ptr->head;
    while(cur_ptr!=NULL){
        next_ptr = cur_ptr->next;
        //printf("Freeing %p\n", cur_ptr);
        free(cur_ptr);
        cur_ptr=next_ptr;
    }
    if(s_ptr){ //Check if table is empty
        free(s_ptr);
    }
}

int check_type(char* i_name)
{
	if((strcmp(i_name,"int") && strcmp(i_name,"char") && strcmp(i_name,"double"))==0 )
	{
		return 0;
	}
	return 1;
}








