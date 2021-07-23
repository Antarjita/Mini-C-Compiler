#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ICG.h"


void get_next_label(){
    static int label_count = 0;
    sprintf(label_name, "L%d", label_count);
    label_count++;
}

void get_next_temp(){
    static int temp_count = 0;
    sprintf(temp_name, "t%d", temp_count);
    temp_count++;
}

//YYSTYPE *get_new_yylval(char *tok_val, char *loc_name){
YYSTYPE get_new_yylval(char *tok_val, char *loc_name){
    //YYSTYPE *new_yylval = (YYSTYPE *) malloc(sizeof(YYSTYPE));
    YYSTYPE new_yylval;
    strncpy(new_yylval.token_value, tok_val, YYSTYPE_SIZE);
    strncpy(new_yylval.loc_name, loc_name, YYSTYPE_SIZE);
    new_yylval.ir_rep = NULL;
    return new_yylval;
}




