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
      char  *dest = malloc(strlen($2) + strlen(format) + 1);

      if (dest)
      {
        sprintf(dest, "%s%s", $2, format);            
      }
      file = fopen(dest,"wt");
      fprintf(file, "void %s (signal_t s) {\n", $2);
      fprintf(file, "%s \n", $6);
      fprintf(file, "} \n");
      free(dest);
      free($6);
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
      char *body_u = malloc(strlen($1) + strlen($2) + 3);
      sprintf(body_u, "%s\n%s", $1, $2);
      free($1);
      free($2);
      $$ = body_u;
      printf("debug: body body_unit finded - %s\n", $$);

    }
  ;

body_unit
  : definition_unit 
    {
      $$ = $1; 
      printf("debug: definition_unit fined - %s.%s\n", $1);
    }
  | SGNL'.'FNCT'('NUM')'
    {
      char *fnct = malloc(1000*sizeof(char));
      printf("debug: распознан вызов функции - %s.%s\n", $1->name, $3->name);
      
      sprintf(fnct, "\t%s\n", (*($3->value.fnctptr))($1->name, $5)); 
      $$ = fnct;
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
      char *def_u = malloc(1000*sizeof(char));
      char p2[100];
      strcpy(p2, $2);      
      sprintf(def_u, "\tenum {\n\t\t%s\n\t};", p2); 
      $$ = def_u;
      printf("debug: DEFTOKEN def_list  - %s\n", def_u);  
    }
  ;

def_list
  : def_item
  | def_list ',' def_item 
    { 
      char *def_u = malloc(1000*sizeof(char));
      printf("debug: def_list $1 - %s\n", $1);  
      printf("debug: def_list $3 - %s\n", $3);  
      sprintf(def_u, "%s\n\t\t%s", $1, $3);
      free($1);
      free($3);
      $$ = def_u;
    }
  ;

def_item
  : WORD NUM  
    {   
      put_sym($1, SGNL);                                                                   
      char buff [100];
      char *def_u = malloc(1000*sizeof(char));
      sprintf (buff, "%i", $2);
      sprintf(def_u, "%s = %s,", $1, buff); 
      $$ = def_u;   
      printf("debug: WORD NUM - %s\n", $$);  
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