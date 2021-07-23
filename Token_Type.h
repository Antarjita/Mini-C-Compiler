#ifndef YYSTYPE_IS_DECLARED

#define YYSTYPE_SIZE 100

//We have declared yylval explicitly. Default yylval is of type int.
#define YYSTYPE_IS_DECLARED 

//#define CODE_BUF_SIZE 1000000

/*

//YYLVAL should be a char array. Enclosing the array in a struct because arrays can get confusing. Refer [5]
struct yystype{
    char token_value[YYSTYPE_SIZE];
    char loc_name[YYSTYPE_SIZE]; //Name of variable or temporary variable in which value is stored
};
typedef struct yystype YYSTYPE;

*/

/*
//YYLVAL should be a char array. Enclosing the array in a struct because arrays can get confusing. Refer [5]
struct yystype{
    char token_value[YYSTYPE_SIZE];
    char loc_name[YYSTYPE_SIZE]; //Name of variable or temporary variable in which value is stored
    char ir_rep[CODE_BUF_SIZE];
};
typedef struct yystype YYSTYPE;
*/

//YYLVAL should be a char array. Enclosing the array in a struct because arrays can get confusing. Refer [5]
struct yystype{
    char token_value[YYSTYPE_SIZE];
    char loc_name[YYSTYPE_SIZE]; //Name of variable or temporary variable in which value is stored
    char *ir_rep;
};

typedef struct yystype YYSTYPE;
/*
struct Node{
    YYSTYPE token;
    struct Node *left;
    struct Node *right;
};
typedef struct Node SYN_TREE_NODE;
*/

#endif
