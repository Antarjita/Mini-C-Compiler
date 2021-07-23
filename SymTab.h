union Data 
{
    int numb;
    float decimal;
    char ch;
    char str[20];
};

typedef struct node
{
    char name[10];
    union Data data;
    //int value;
    char type[10];
    //int scope;
    int line;
    struct node* next;
}NODE;


typedef struct symbol_table_head
{
    NODE* head;
    int entries;
    struct symbol_table_head *prev_ptr;
}TABLE_H;

typedef struct chained_sym_tab{
    TABLE_H *sym_tab;
} CHAINED_SYM_TAB_H;

void init(CHAINED_SYM_TAB_H *sym_ptr);
TABLE_H *create_sym_tab(CHAINED_SYM_TAB_H *sym_chain_ptr, TABLE_H*  parent_tab);
void insert_node(TABLE_H* cur_tab, char* name, char* value, char* type, int lineno);
void sym_print(TABLE_H* sym_tab);
int exists(TABLE_H* cur_tab, char* name);
int update(TABLE_H* cur_tab, char* name, char* val);
void free_symbol_table(TABLE_H *s_ptr);
int check_type(char* i_name);

CHAINED_SYM_TAB_H sym_chain;
TABLE_H *top;
TABLE_H *saved;