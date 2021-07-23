yacc -d --locations parser.y
lex operators.l
yacc --locations parser.y
cc  lex.yy.c y.tab.c ICG.c quad.c
