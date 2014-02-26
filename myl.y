%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "myl.h"

  extern FILE *yyin;

  void yyerror(const char *str)
  {
          fprintf(stderr,"ошибка: %s\n",str);
  }
   
  int yywrap()
  {
          return 1;
  } 
%}

%union {
  int  val;
  char    *string;
  sym  *tptr;
}

%token <val>  NUM
%token <string> WORD
%token <tptr> SGNL FNCT
%type <val>   exp
%type <string> function_definition
%type <string> argument
%type <string> definition_unit
%type <string> body_unit
%type <string> body
%type <string> def_list
%type <string> def_item

%token TOKFUNCTION
%token TOKEND
%token DEFTOKEN
%token TOKENIF

%start translation_unit

%%

translation_unit
  : declaration_unit
  | translation_unit declaration_unit
  | exp '\n'    { printf("%.10g\n", $1); }
  ;

exp:
  NUM       { $$ = $1; }
  ;

declaration_unit
  : function_definition
  ;

function_definition 
  : TOKFUNCTION WORD '(' arguments ')' body TOKEND 
    { 
      FILE * file;
      const char * format = ".h";
      char * dest;

      dest = malloc(strlen($2) + strlen(format) + 1);
      if (dest)
      {
        sprintf(dest, "%s%s", $2, format);            
      }
      file = fopen(dest,"wt");
      fprintf(file, "void %s (signal_t s) {\n", $2);
      fprintf(file, "%s \n", $6);
      fprintf(file, "} \n");
      free(dest);
    }
  ;

body
  : body_unit 
    {
      $$ = $1; 
      printf("debug: body_unit finded - %s\n", $1);
    }
  | body body_unit 
    { 
      sprintf($$, "%s\n%s", $1, $2);
      printf("debug: body body_unit finded - %s\n", $$);
    }
  ;

body_unit
  : definition_unit 
    {
      $$ = $1; 
    }
  | SGNL'.'FNCT'('NUM')'
    {
      printf("debug: распознан вызов функции - %s.%s\n", $1->name, $3->name);
      sprintf($$, "\t%s\n", (*($3->value.fnctptr))($1->name, $5)); 
      free($3->name);
    }
  ;

// condition_block
//         : TOKENIF condition body TOKEND { printf("condition\n" );}
//         ;

// condition
//         : condition_unit
//         | condition condition_unit
//         ;

// condition_unit
//         : WORD
//         ;

definition_unit
  : DEFTOKEN def_list 
    { 
      sprintf($$, "\tenum {\n\t\t%s\n\t};", $2); 
    }
  ;

def_list
  : def_item
  | def_list ',' def_item 
    { 
      sprintf($$, "%s\n\t\t%s", $1, $3);
    }
  ;

def_item
  : WORD NUM  
    {   
      put_sym($1, SGNL);                                                                   
      char buff [100];
      sprintf (buff, "%i", $2);
      sprintf($$, "%s = %s,", $1, buff);        
    }
  ;

arguments
  : argument
  | arguments ',' argument
  ;

argument
  : WORD 
    {
      $$ = $1;
    }
  ;


%%

void init_table(void);

main(int argc, char *argv[])
{
  init_table ();

  if ( argc > 1)
  {
      FILE *myfile = fopen(argv[1], "r");
    if (!myfile) {
      printf("Cant open \n");
      return -1;
    }
    yyin = myfile;
    
    do {
      yyparse();
    } while (!feof(yyin));
  } else
  {
    yyparse();
  }
} 

char* setValue(char* name, int value)
{
  printf("debug: Start setValue for %s\n", name);
  char *str = malloc(sizeof(char) * 100);
  sprintf(str, "signalTable[%s] = %i;",name, value );

  return str;
}

struct init
{
  char *fname;
  char* (*fnct)(char*, int);
};

struct init math_functions[] =
{
  "setValue", setValue,
  0, 0
};


sym *sym_table = (sym *) 0;

void init_table (void)
{
  int i;
  sym *ptr;
  for (i = 0; math_functions[i].fname != 0; i++)
    {
      ptr = put_sym (math_functions[i].fname, FNCT);
      ptr->value.fnctptr = math_functions[i].fnct;
    }
}

sym* put_sym (const char *sym_name, int sym_type)
{
  sym *ptr;
  ptr = (sym*) malloc(sizeof (sym));
  ptr->name = (char*) malloc(strlen (sym_name) + 1);
  strcpy (ptr->name,sym_name);
  ptr->type = sym_type;
  ptr->value.var = 0;
  ptr->next = (struct sym *)sym_table;
  sym_table = ptr;
  printf("debug: sym_tbl - %s\n", sym_name);
  return ptr;
}

sym * get_sym (const char *sym_name)
{
  sym *ptr;
  for (ptr = sym_table; ptr != (sym *) 0;
       ptr = (sym*)ptr->next)
    if (strcmp (ptr->name,sym_name) == 0)
      return ptr;
  return 0;
}