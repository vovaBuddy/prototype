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
  token_info *tkn_info;
}

%token <val>  NUM
%token <string> WORD
%token <tptr> SGNL FNCT ARRAY
%type <val>   exp
%type <string> function_definition
%type <string> argument
%type <string> definition_unit 
%type <string> body_unit
%type <string> body
%type <string> def_list
%type <string> def_item
%type <string> condition_block condition_unit switch_block when_block when_item
%type <string> call_functioin condition  tmp_var call_array logic_tokin compar_logic
%type <tkn_info> set_items 
%token TOKFUNCTION
%token TOKEND
%token DEFTOKEN
%token TOKENIF
%token DOTOKEN
%token TOKENELSE
%token TOKENELSEIF
%token TOKENLOGICOR
%token TOKENLOGICAND
%token TOKENSWITCH
%token TOKENCASE

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
      fprintf(file, "\tint i = 0;\n");
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
      char *body_u = malloc(strlen($1) + strlen($2) + 30);
      sprintf(body_u, "\t%s\n\t%s", $1, $2);
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
  | call_functioin
  {
    $$ = $1;
    printf("debug: call_functioin fined - %s.%s\n", $1);
  }
  | call_array
    {
      $$ = $1; 
      printf("debug: call_array fined - %s.%s\n", $1);
    }
  | condition_block
    {
      $$ = $1; 
      printf("debug: condition_block fined - %s.%s\n", $1);
    }
  | switch_block
    {
      $$ = $1; 
      printf("debug: switch_block fined - %s.%s\n", $1);
    }
  ;

switch_block 
  : TOKENSWITCH call_functioin when_block TOKEND
    {
      char *sw = malloc(10000*sizeof(char));
      printf("debug: TOKENSWITCH call_functioin when_block TOKEND \n");      
      sprintf(sw, "switch(%s) {\n\t%s\n\t}", $2, $3); 
      $$ = sw;
    }
  ;

when_block
  : when_item
  | when_block when_item
    {
      char *when_i = malloc(10000*sizeof(char));
      printf("debug: when_block when_item \n");      
      sprintf(when_i, "%s \n\t%s", $1, $2); 
      $$ = when_i;
    }
  ;

when_item
  :  TOKENCASE NUM body
    {
      char *when_i = malloc(10000*sizeof(char));
      printf("debug: TOKENCASE NUM body \n");      
      sprintf(when_i, "case %i: \n\t%s\n\tbreak;", $2, $3); 
      $$ = when_i;
    }
  |  TOKENCASE call_functioin body
    {
      char *when_i = malloc(10000*sizeof(char));
      printf("debug: TOKENCASE NUM body \n");      
      sprintf(when_i, "case %s: \n\t%s\n\tbreak;", $2, $3); 
      $$ = when_i;
    }
  |  TOKENELSE  body
    {
      char *when_i = malloc(10000*sizeof(char));
      printf("debug: TOKENCASE NUM body \n");      
      sprintf(when_i, "case default: \n\t%s\n\tbreak;", $2); 
      $$ = when_i;
    }
  ;

call_functioin
  : SGNL'.'FNCT'('NUM')'
    {
      char *fnct = malloc(10000*sizeof(char));
      printf("debug: распознан вызов функции - %s.%s\n", $1->name, $3->name);
      
      sprintf(fnct, "%s", (*($3->value.fnctptr))($1->value.translate_to, $5)); 
      $$ = fnct;
    }
  | SGNL'.'FNCT'('')'
    {
      char *fnct = malloc(10000*sizeof(char));
      printf("debug: распознан вызов функции - %s.%s\n", $1->name, $3->name);
      
      sprintf(fnct, "%s", (*($3->value.fnctptr))($1->value.translate_to, 0)); 
      $$ = fnct;
    }
  ;


call_array
  : ARRAY '.' FNCT DOTOKEN tmp_var body TOKEND
    {
      printf("debug: call_array "); 
      char *arr = malloc(1000*sizeof(char));
      printf("debug: call_array - %s.%s\n", $1->name, $3->name);     
      sprintf(arr, "for (i=0; i<%i;++i){\n\t\t%s\n\t}",$1->value.var, $6); 
      $$ = arr;
      remove_sym($5); // c учетом что всегда sym_table ссылается tmp_var !исправить

    }
  ;

tmp_var
  : '|' WORD '|'
    {
      char* str = malloc(strlen($<tptr>-3->name) + 15);
      sym *ptr = put_sym($2, SGNL);
      sprintf(str, "signalTable[%s[i]]", $<tptr>-3->name); // не сработает вариант цыкла в цыкле
      ptr->value.translate_to = str; 
      printf("debug: tmp_var%s\n", $2 );
      $$ = $2;
    }
  ;

condition_block
 : TOKENIF condition body TOKEND 
   { 
    char* def = malloc(sizeof(char) * 10000);
    sprintf(def, "if(%s) {\n\t\t%s\n\t}", $2, $3);
    $$ = def;
    printf("debug: condition_block\n%s\n", def );
    printf("debug: condition_block\n%s\n", $$ );
   }
  | TOKENIF condition body TOKENELSE body TOKEND 
   { 
    char* def = malloc(sizeof(char) * 10000);
    sprintf(def, "if(%s) {\n\t\t%s\n\t}\n\telse {\n\t\t%s\n\t}", $2, $3, $5);
    $$ = def;
    printf("debug: condition_block\n%s\n", def );
    printf("debug: condition_block\n%s\n", $$ );
   }
 ;

// elseif_body
//   : elseif_item
//   | elseif_body elseif_item
//     {
//       char *else_u = malloc(strlen($1) + strlen($2) + 3);
//       sprintf(else_u, "\t%s\n\t%s", $1, $2);
//       free($1);
//       free($2);
//       $$ = else_u;
//       printf("debug: else_body else_item finded - %s\n", $$);
//     }
//   ;

// elseif_item
//   : TOKENELSEIF body
//     {
//       char *else_u = malloc(strlen($2) + 21);    
//       sprintf(else_u, "else {\n\t\t%s\n\t}", $2); 
//       $$ = else_u;
//       printf("debug: DEFTOKEN def_list  - %s\n", else_u);  
//     }
//   ;

condition
 : condition_unit
 | condition logic_tokin condition_unit
 {
  char *def_u = malloc(strlen($2) + strlen($1) + strlen($3) + 30);    
  sprintf(def_u, "%s %s %s", $1, $2, $3); 
  $$ = def_u;
  printf("debug: condition logic_tokin  - %s\n", def_u);  
 }
 | condition logic_tokin '(' condition ')'
   {

      char *def_u = malloc(strlen($1) + strlen($2) + strlen($4) + 30);    
      sprintf(def_u, " %s %s ( %s )", $1, $2, $4); 
      $$ = def_u;
      printf("!!!!!!!!!!!!1debug: condition logic_tokin  - %s\n", def_u);  
   }
 | '(' condition ')' logic_tokin condition 
   {
      char *def_u = malloc(strlen($2) + strlen($4) + strlen($5) + 30);    
      sprintf(def_u, " ( %s ) %s %s ", $2, $4, $5); 
      $$ = def_u;
      printf("!!!!!!!!!!!!1debug: condition logic_tokin  - %s\n", def_u);  
   }
 | '(' condition ')' logic_tokin '(' condition ')'
   {
      char *def_u = malloc(strlen($2) + strlen($4) + strlen($6) + 30);    
      sprintf(def_u, " ( %s ) %s ( %s )", $2, $4, $6); 
      $$ = def_u;
      printf("!!!!!!!!!!!!1debug: condition logic_tokin  - %s\n", def_u);  
   }
 ;


logic_tokin
  : TOKENLOGICAND
    {
      $$ = "&&";
    }
  | TOKENLOGICOR
    {
      $$ = "||";
    }
  ;


condition_unit
 : call_functioin
 | call_functioin compar_logic NUM
   {
      char *def_u = malloc(strlen($1) + strlen($2) + 100);    
      sprintf(def_u, "%s %s %i", $1, $2, $3); 
      $$ = def_u;
      printf("1debug: call_functioin compar_logic NUM  - %s\n", def_u);  
   }
 | call_functioin compar_logic call_functioin
 ;

compar_logic
 : '<'
 {
  $$ = "<";
 }
 | '>'
 {
  $$ = ">";
 }
 | '>''='
 {
  $$ = ">=";
 }
 | '<''='
  {
   $$ = "<=";
  }
 | '!''='
  {
   $$ = "!=";
  }
 ;

definition_unit
  : DEFTOKEN def_list 
    { 
      char *def_u = malloc(strlen($2) + 21);    
      sprintf(def_u, "enum {\n\t\t%s\n\t};", $2); 
      $$ = def_u;
      printf("debug: DEFTOKEN def_list  - %s\n", def_u);  
    }

  | WORD '=' '[' set_items']'
    {
      sym *ptr = put_sym($1, ARRAY);     
      ptr->value.var = $4->info; 
      printf("!!!debug: definition_unit count  - %i\n", $4->info);   
      char *arr = malloc(strlen($1) + strlen($4->value) + 15);    
      sprintf(arr, "int %s[] = {%s};", $1, $4->value); 
      $$ = arr;
      printf("debug: array  - %s\n", arr);     
    }
  ;

set_items
  : SGNL
    {
      token_info *t = malloc(sizeof(token_info));
      char *sgnl = malloc(strlen($1->name) + 5);    
      sprintf(sgnl, "%s", $1->name); 
      t->value = sgnl;
      t->info = 1;
      $$ = t;
      printf("!!!debug:SGNL count  - %i\n", $$->info); 
      printf("debug: SGNL  - %s\n", sgnl);  
    }

  | set_items ',' SGNL
    {
      token_info *t = malloc(sizeof(token_info));
      char *sgnl = malloc(strlen($1->value) + strlen($3->name) + 5);    
      sprintf(sgnl, "%s, %s", $1->value, $3->name); 
      t->value = sgnl;
      t->info = $1->info + 1;
      $$ = t;
      printf("!!!debug: set_items count  - %i\n", $$->info); 

      printf("debug: set_items SGNL  - %s\n", sgnl);  
    }
  ;

def_list
  : def_item
  | def_list ',' def_item 
    { 
      char *def_u = malloc(strlen($1) + strlen($3) + 7);
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
      sym *ptr = put_sym($1, SGNL);  
      char* str = malloc(strlen($1) + 15);
      sprintf(str, "signalTable[%s]", $1);
      ptr->value.var = $2;
      ptr->value.translate_to = str;                                                          
      char buff [100];
      char *def_u = malloc(strlen($1) + 100);
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
  sprintf(str, "%s = %i;",name, value );

  return str;
}

char* getValue(char* name, int value)
{
  printf("debug: Start getValue for %s\n", name);
  char *str = malloc(sizeof(char) * 100);
  sym *rec;
  rec = get_sym(name);
  
  sprintf(str, "%s",name);

  return str;
}


char* equal(char* name, int value)
{
  printf("debug: Start equal for %s\n", name);
  char *str = malloc(sizeof(char) * 100);
  
  sprintf(str, "%s == %i",name, value);

  return str;
}

char* each(char* name, int value)
{
  printf("debug: Start each for %s\n", name);
  char *str = malloc(sizeof(char) * 100);
  
  sprintf(str, "%s == %i",name, value);

  return "none";
}

struct init
{
  char *fname;
  char* (*fnct)(char*, int);
};

struct init math_functions[] =
{
  "setValue", setValue,
  "getValue", getValue, 
  "equal?", equal,
  "each", each,
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

void remove_sym (const char *sym_name)
{
  sym *tmp = sym_table;
  sym_table = sym_table->next;
  free(tmp);
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