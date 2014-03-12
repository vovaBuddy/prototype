%{
#include <stdio.h>
#include "myl.h"
#include "myl.tab.h"

%}
%%
[0-9]+                  yylval.val=atoi(yytext); return NUM;
def                		return TOKFUNCTION;
end						return TOKEND;
var						return DEFTOKEN;
if 						return TOKENIF;
else 					return TOKENELSE;
elsif 					return TOKENELSEIF;
do						return DOTOKEN;
[a-zA-Z0-9?]+			{yylval.string=strdup(yytext);
						 sym *rec = get_sym(yytext);
						 if( rec != 0)
						 {
						 	yylval.tptr = rec;
							return rec->type;
						 }

						 return WORD;
						}
\n                      /* игнорируем символ конца строки */;
[ \t]+                  /* игнорируем пробелы и символы табуляции */;
"("					 	return '('; 
")"						return ')'; 
","						return ','; 
"."						return '.'; 
"="						return '=';
"["						return '[';
"]"						return ']';
"|"						return '|';
%%