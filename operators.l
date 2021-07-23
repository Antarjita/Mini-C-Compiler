%{
  /* definations to manifest
  LT,LE,EQ,NE,GT,GE,IF,THEN,ELSE,NUMBER,RELOP*/
  #include <stdio.h>
  #include "Token_Type.h" 
  #include "y.tab.h"
  

  #define YY_USER_ACTION         \
  offset += yyleng;            \
  yylloc.last_line = yylineno; \
  yylloc.last_column = offset; \
  

  //offset_t offset;
  int offset=0;
  extern YYLTYPE yylloc;
  extern FILE *lex_output_fp;
  
  extern YYSTYPE yylval;
  int fg=0;
  
%}

%option yylineno

/*regular defination */
digits  [0-9]+
number  {digits}(\.{digits})?(E[+-]?digit)?
id [A-Za-z_][A-Za-z0-9_]*
special_char [:\.!@#$%^&*()_~`? \\] 
/* strings \"(([0-9A-Za-z]|{special_char}|[0-9A-Za-z])*)\" */
/* strings \"[0-9A-Za-z_%: ]\" */
strings \"([0-9A-Za-z]|{special_char})*\"
characters \'[A-Za-z]\'

%%
  /* comments */
"/*"        {fg+=1;}
"*/"        {fg-=1;}
"//".*      ;


  /* INT/DOUBLE/CHAR */

"int"       {
              //printf("int matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "int");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "int_", yylval.token_value);
                return (int_);
              }
            }

"char"      {
              //printf("char matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "char");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "char_", yylval.token_value);
                return (char_);
              }
            }

"double"    {
              //printf(" double matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "double");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "double_", yylval.token_value);
                return (double_);
              }
            }
            
"void"      {
              //printf(" double matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "void");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "void_", yylval.token_value);
                return (void_);
              }
            }       
  /* IF/ELSE/FOR/WHILE */

"if"       {
              //printf(" if matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "if");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "if_", yylval.token_value);
                return (if_);
              }
            }

"else"       {
              //printf(" else matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "else");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "else_", yylval.token_value);
                return (else_);
              }
            }

"for"       {
              //printf(" for matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "for");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "for_", yylval.token_value);
                return (for_);
              }
            }

"while"     {
              //printf(" while matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "if");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "if_", yylval.token_value);
                return (while_);
              }
            }
"return"    {
              //printf(" return matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "return");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "return_", yylval.token_value);
                return (return_);
              }
            }
  /* Identifers*/
{id}    {
                //printf(" ID matched\n");
                if(fg == 0){
                strcpy(yylval.token_value,yytext);
                fprintf(lex_output_fp, "Token(%s, %s)\n", "id", yylval.token_value);
                return(id);
                }
              }

  /* Numeric constants  */
{number}    {
                //printf(" Numeric constant matched\n");
                if(fg == 0){
                strcpy(yylval.token_value,yytext);
                fprintf(lex_output_fp, "Token(%s, %s)\n", "numeric_constant", yylval.token_value);
                return(numeric_constant);
                }
            }

  /*LITERALS */
{characters}      {
              //printf(" else matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, yytext);
                fprintf(lex_output_fp, "Token(%s, %s)\n", "char_constant", yylval.token_value);
                return (char_constant);
              }
            }

{strings}    {
              //printf(" for matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, yytext);
                fprintf(lex_output_fp, "Token(%s, %s)\n", "str_constant", yylval.token_value);
                return (str_constant);
              }
            }

  /*Relational Operators */
"<"       {
              //printf(" less matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "<");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "less", yylval.token_value);
                return (less);
              }
            }

"<="      {
              //printf(" lessEqual than matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "<=");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "lessequal", yylval.token_value);
                return (lessequal);
              }
            }

"=="      {
              //printf(" equal matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "==");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "equalequal", yylval.token_value);
                return (equalequal);
              }
            }

">"       {
              //printf(" greater matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, ">");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "greater", yylval.token_value);
                return (greater);
              }
            }

">="      {
              //printf(" greaterequal matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, ">=");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "greaterequal", yylval.token_value);
                return (greaterequal);
              }
            }

"!="       {
              //printf(" exclaimequal matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "!=");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "exclaimequal", yylval.token_value);
                return (exclaimequal);
              }
            }


    /* Punctuation marks */
","         {
              //printf("comma matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, ",");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "comma", yylval.token_value);
                return (comma);
              }
            }
        
";"         {
              //printf("semi matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, ";");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "semi", yylval.token_value);
                return (semi);
              }
            } 
               
"("         {
              //printf("left paren matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "(");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "l_paren", yylval.token_value);
                return(l_paren);
              }
            }
            
")"         {
              //printf("right paren matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, ")");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "r_paren", yylval.token_value);
                return(r_paren);
              }
            }

"{"         {
              //printf("left curly matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "{");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "l_brace", yylval.token_value);
                return(l_brace);
              }
            }

"}"         {
              //printf("right curly matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "}");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "r_brace", yylval.token_value);
                return(r_brace);
              }
            }       
    /* Arithmetic Operators */
"+"         {
              //printf("plus matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "+");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "plus", yylval.token_value);
                return (plus);
              }
            }
"-"         {
              //printf("minus matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "-");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "minus", yylval.token_value);
                return (minus);
              }
            }
"*"         {
              //printf("star matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "*");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "star", yylval.token_value);
                return (star);
              }
            }
"/"         {
              //printf("slash matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "/");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "slash", yylval.token_value);
                return (slash);
              }
            }
"%"         {
              //printf("percent matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "%");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "percent", yylval.token_value);
                return (percent);
              }
            }
                  
  /* Assignment Operator */ 
"="         {
              //printf("equal matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "=");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "equal", yylval.token_value);
                return (equal);
              }
            } 
            
  /* Address Operator      */                                                                                        
"&"         {
              //printf("amp matched\n");
              if(fg == 0){
                strcpy(yylval.token_value, "&");
                fprintf(lex_output_fp, "Token(%s, %s)\n", "amp", yylval.token_value);
                return (amp);
              }
            }    
             
    /* End of File Marker */                
<<EOF>>     {
              //printf("end of file matched\n");
              strcpy(yylval.token_value, "");
              fprintf(lex_output_fp, "Token(%s, %s)\n", "eof", yylval.token_value);
              return YY_NULL;
              
            }  
                
[\t ]     
"\n"		{   
            //lineno++;
            offset = 0;
            }
.		    {
                printf("Lexer Error - Unrecognized Token : %s\n", yytext);
                printf("yyleng = %zu\n", yyleng);
            }

%%

int yywrap(){
  return(1);
}
