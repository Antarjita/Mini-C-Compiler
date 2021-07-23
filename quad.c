#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "ICG.h"

//static quadruple* prev_func_end=NULL; //When prev_func_end = NULL, insert at beginning of quadruples table

quadruple* prev_outer_unit_end=NULL;

quadruple* create_quadruple(char* op, char* arg1, char* arg2, char* res) 
{
    quadruple* new_quadruple = (quadruple*)malloc(sizeof(quadruple));
    strcpy(new_quadruple->op,op);
    strcpy(new_quadruple->arg1,arg1);
    strcpy(new_quadruple->arg2,arg2);
    strcpy(new_quadruple->res,res);
    new_quadruple->next=NULL;
	//printf("%s\n",new_quadruple->op);
	//printf("Created quadruple record...\n");
    return new_quadruple;
}

void insert_func_begin(quad_list *list, quadruple* q1){
    quadruple *traverse=list->head;
    //quadruple *prev=NULL;
    if(traverse==NULL){
        list->head = q1;
        q1->next = NULL; //Not really necessary as create_quadruple() must have set next=NULL 
    }
    else{
        //if(prev_func_end == NULL){
        if(prev_outer_unit_end == NULL){
            //printf("1\n");
            q1->next = list->head;
            list->head=q1;
        }
        else{
            //while(traverse!=prev_func_end && traverse!=NULL){
            while(traverse!=prev_outer_unit_end && traverse!=NULL){
                //prev=traverse;
                traverse = traverse->next;
            }
            if(traverse==NULL){
                printf("ERROR: prev_func_end is invalid\n");
            }
            else{
                /*
                q1->next=NULL;
                prev->next=q1;
                */
                q1->next=traverse->next;
                traverse->next = q1;
            }
        }
    }
}

void insert_quadruple(quad_list *list, quadruple* q1) 
{
    quadruple *traverse=list->head;
    //printf("%p\n",traverse);
    //if(!strcmp(q1->op, "function end") || !strcmp(q1->op, "prototype end")){
        //printf("2\n");
    //    prev_func_end = q1;
    //}
    if(traverse==NULL) 
	{
        //printf("%p,%p\n",list->head,q1);
        //list->head = NULL;
        //printf("%p,%p\n",list->head,q1);
        //quadruple *q2=q1;
        //printf("%p,%p\n",list->head,q2);
        list->head = q1;
        //printf("entered");
    }
    else 
	{
        while (traverse->next !=NULL) 
		{
            traverse = traverse->next;
        }
        traverse->next = q1;
    }
    //printf("%s\n",traverse->arg2);
	//printf("Inserted quadruple record...\n");
}

void display_three_add(quad_list *list) {
    //printf("entered\n");
    printf("%-20s%-20s%-20s%-20s\n", "op", "arg1", "arg2", "res");
    quadruple *traverse = list->head;
    while(traverse!=NULL) {
        printf("%-20s%-20s%-20s%-20s\n",traverse->op,traverse->arg1,traverse->arg2,traverse->res);
        traverse=traverse->next;
    }
}

// returns 1 if temporary variable else returns 0
int check_temp(char* var)
{
    int l=strlen(var);
    char* after_t = var + 1;
    //printf("temp=%s\n",after_t);
    if(var[0]=='t' && check_digit(after_t)==1)
    {
        return 1;
    }
    return 0;
}

// deleteing with respect to res column as the key
void deleteNode(quad_list *list, char *key)
{
    quadruple *temp =list->head, *prev;
 
    if (temp != NULL && strcmp(temp->res,key)==0) 
    {
        list->head = temp->next; 
        free(temp); 
        return;
    }
 
    // Search for the key to be deleted, keep track of the
    // previous node as we need to change 'prev->next'
    while (temp != NULL && strcmp(temp->res,key)) 
    {
        prev = temp;
        temp = temp->next;
    }
 
    // If key was not present in linked list
    if (temp == NULL)
        return;
 
    // Unlink the node from linked list
    prev->next = temp->next;
 
    free(temp); // Free memory
}

// returns 1 if number
int check_digit(char *val)
{
    int j=0;
    if(strcmp(val,"")==0)
        return 0;
    while(j<strlen(val))
    {
        if(isdigit(val[j])==0)
            return 0;
        j++;
    }
    return 1;
}

//pass the node from which the propogation starts and the temp variable to replace and the value with which it will be replaced.
//donot have to check whether passed arg(temp_var) is temp or not

void replace_wth_val(quadruple *list, char *temp_var, char *temp_val)
{
    quadruple *temp =list->next;
    while(temp!=NULL)
    {
        if(strcmp(temp_var,temp->arg1)==0)
        {
            strcpy(temp->arg1,temp_val);
        }
        if(strcmp(temp_var,temp->arg2)==0)
        {
            strcpy(temp->arg2,temp_val);
        }
        temp=temp->next;
    }
}

//only allows of the form < = > < arg1 > <> < res > to be optimised
void scan_constprop_temp(quad_list *list)
{
    quadruple *temp =list->head;
    while(temp!=NULL)
    {
        if(strcmp(temp->op,"=")==0  && check_temp(temp->res)==1)
        {
            if(check_temp(temp->arg1)==1 || check_digit(temp->arg1))
            {
                replace_wth_val(temp,temp->res,temp->arg1);
                deleteNode(list,temp->res);
            }
        }
        temp=temp->next;
    }
}

// check for all matching columns except res and return 1 if matches else 0
int matching_records(quadruple *cur_nod,quadruple *node)
{
        if(strcmp(cur_nod->op,node->op)==0)
        {
            if(strcmp(cur_nod->arg1,node->arg1)==0 && strcmp(cur_nod->arg2,node->arg2)==0)
                return 1;
        }
        return 0;
}

// checks for a prev match of expression
char* check_before_exp(quad_list *list,quadruple *cur_nod)
{
    quadruple *temp =list->head;
    while(temp!=NULL)
    {
        if(strcmp(temp->res,cur_nod->res)==0)
            break;
        else if(matching_records(cur_nod,temp) && strcmp(temp->res,cur_nod->res)!=0)
        {
            return temp->res;
        }
        temp=temp->next;
    }
    return "";
    
}

void common_sub_exp(quad_list *list)
{
    quadruple *temp =list->head;
    char res[10];
    while(temp!=NULL)
    {
        strcpy(res,check_before_exp(list,temp));
        //printf("res=%s\n",res);
        if(strcmp(res,"")!=0)
        {
            replace_wth_val(temp,temp->res,res);
            deleteNode(list,temp->res);
        }
        temp=temp->next;
    }
}

double evaluate(char *op,char *arg1, char*arg2)
{
    double eval;
    if(strcmp(op,"*")==0)
    {
        eval=atof(arg1)*atof(arg2);
    }
    else if(strcmp(op,"+")==0)
    {
        eval=atof(arg1)+atof(arg2);
    }
    else if(strcmp(op,"/")==0)
    {
        if(atof(arg2)==0)
        {
            printf("division by zero error");
        }
        else
        {
            eval=atof(arg1)/atof(arg2);
        }
    }
    else if(strcmp(op,"-")==0)
    {
        eval=atof(arg1)-atof(arg2);
    }
    return eval;
}


void const_fold(quad_list *list)
{
    quadruple *temp =list->head;
    double eval;
    while(temp!=NULL)
    {
        if(check_digit(temp->arg1) && check_digit(temp->arg2))
        {
            eval=evaluate(temp->op,temp->arg1,temp->arg2);
            printf("%s=%f\n",temp->res,eval);
            strcpy(temp->op,"=");
            sprintf(temp->arg1,"%.2f",eval);
            strcpy(temp->arg2,"");
        }
        temp=temp->next;
    }
}

void write_three_add(quad_list *list, char *fname){
    FILE *fp = fopen(fname, "w");
    if(!fp){
        printf("ERROR: Could not open file %s\n", fname);
        exit(1);
    }
    fprintf(fp, "%-20s%-20s%-20s%-20s\n", "op", "arg1", "arg2", "res");
    quadruple *traverse = list->head;
    while(traverse!=NULL) {
        fprintf(fp, "%-20s%-20s%-20s%-20s\n",traverse->op,traverse->arg1,traverse->arg2,traverse->res);
        traverse=traverse->next;
    }
    fclose(fp);
}

void optimisation(quad_list *list)
{
    printf("OPTIMIZING INTERMEDIATE REPRESENTATION\n");
    
    //printf("\nchecking for replacement\n");
    printf("___Applying CONSTANT PROPAGATION & PACKING TEMPORARIES___\n");
    scan_constprop_temp(list);
    display_three_add(list);
    printf("\n\n");
    write_three_add(list, "opt1.txt");
    
    //printf("\nchecking for constant folding\n");
    printf("___Applying CONSTANT FOLDING___\n");
    const_fold(list);
    display_three_add(list);
    printf("\n\n");
    write_three_add(list, "opt2.txt");

    //printf("\nchecking for common sub expr\n");
    printf("___Applying COMMON SUBEXPRESSION REMOVALS___\n");
    common_sub_exp(list);
    display_three_add(list);
    printf("\n\n");
    write_three_add(list, "opt3.txt");
    
    //printf("\nchecking for replacement\n");
    printf("___Applying CONSTANT PROPAGATION & PACKING TEMPORARIES___\n");
    scan_constprop_temp(list);
    display_three_add(list);
    printf("\n\n");
    write_three_add(list, "opt4.txt");
    
    printf("___Applying CONSTANT FOLDING___\n");
    printf("\nchecking for constant folding\n");
    const_fold(list);
    display_three_add(list);
    printf("\n\n");
    write_three_add(list, "opt5.txt");
}



/*
int main()
{
    quad_list* list;
    quadruple* cur_quad_record;
    list=malloc(sizeof(quad_list));
    list->head=NULL;
    cur_quad_record=create_quadruple("*","a", "b","t1");
    insert_quadruple(list, cur_quad_record);
    //prev_func_end =cur_quad_record;
    cur_quad_record=create_quadruple("+","a", "b","t2");
    //prev_func_end =cur_quad_record;
    insert_quadruple(list, cur_quad_record);
    //prev_func_end =cur_quad_record;
    cur_quad_record=create_quadruple("-","a", "b","t3");
    //prev_func_end =cur_quad_record;
    insert_quadruple(list, cur_quad_record);
    cur_quad_record=create_quadruple("/","a", "b","t4");
    //printf("%s\n",cur_quad_record->op);
    //insert_quadruple(list, cur_quad_record);
    insert_func_begin(list, cur_quad_record);
    cur_quad_record=create_quadruple("%","a", "b","t4");
    insert_quadruple(list, cur_quad_record);
    cur_quad_record=create_quadruple("^","a", "b","t4");
    insert_quadruple(list, cur_quad_record);
    cur_quad_record=create_quadruple("function begin","a", "","");
    insert_func_begin(list, cur_quad_record);
    cur_quad_record=create_quadruple("function end","a", "","");
    insert_quadruple(list, cur_quad_record);
    cur_quad_record=create_quadruple("function begin","b", "","");
    insert_func_begin(list, cur_quad_record);
    cur_quad_record=create_quadruple("function end","b", "","");
    insert_quadruple(list, cur_quad_record);
    cur_quad_record=create_quadruple("function begin","c", "","");
    insert_func_begin(list, cur_quad_record);
    
    display_three_add(list);

    printf("avv=%d\n",check_temp("avv"));
    printf("t1=%d\n",check_temp("t1"));
    printf("tt11=%d\n",check_temp("tt11"));
}
*/

