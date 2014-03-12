struct sym
{
	char	*name;
	int		type;
	union {
		int	var;
		//char* info;
		char* (*fnctptr)(char*, int);
		char* translate_to;
	} value;
	struct sym *next;
} ;

typedef struct sym sym;

struct token_info
{
	char *value;
	int  info;
};

typedef struct token_info token_info;

extern sym *sym_table;

sym *put_sym(const char *, int);
sym *get_sym(const char *);

