all: 
	bison -d myl.y
	flex myl.l 
	cc lex.yy.c myl.tab.c -lm -o myl 
