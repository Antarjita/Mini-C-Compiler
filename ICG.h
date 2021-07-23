
#ifndef YYSTYPE_IS_DECLARED
#include "Token_Type.h"
#endif

/*Data Structure to store quadruples*/
typedef struct quadruple{
    char op[30];
    char arg1[30];
    char arg2[30];
    char res[30];
    struct quadruple *next;
}quadruple;

typedef struct quad_list{
    quadruple* head;
}quad_list;

extern char label_name[YYSTYPE_SIZE];
extern char temp_name[YYSTYPE_SIZE];
extern quadruple* prev_outer_unit_end;

void get_next_temp(void);
void get_next_label(void);
//YYSTYPE *get_new_yylval(char *tok_val, char *loc_name);
YYSTYPE get_new_yylval(char *tok_val, char *loc_name);
quadruple* create_quadruple(char *op, char *arg1, char *arg2, char *res);
void insert_quadruple(quad_list *list, quadruple *q1);
void display_three_add(quad_list *list);
int check_temp(char* var);
void insert_func_begin(quad_list *list, quadruple* q1);
void deleteNode(quad_list *list, char *key);
int check_digit(char *val);
void replace_wth_val(quadruple *list, char *temp_var, char *temp_val);
int matching_records(quadruple *cur_nod,quadruple *node);
char* check_before_exp(quad_list *list,quadruple *cur_nod);
void common_sub_exp(quad_list *list);
void optimisation(quad_list *list);
void const_fold(quad_list *list);
double evaluate(char *op,char *arg1, char*arg2);
void write_three_add(quad_list *list, char *fname);



