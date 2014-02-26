struct sym
{
	char	*name;
	int		type;
	union {
		double	var;
		char* (*fnctptr)(char*, int);
	} value;
	struct sym *next;
} ;

typedef struct sym sym;

extern sym *sym_table;

sym *put_sym(const char *, int);
sym *get_sym(const char *);

