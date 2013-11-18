struct Queue
{
	int q[100];
	int start, end;
};

typedef struct Queue Queue;

void init_queue(Queue *q)
{
	q->start = q->end = 0;
}

void put(Queue *q, int i)
{
	q->q[q->end] = i;
	++q->end;
}

int get(Queue *q)
{
	if (q->start == q->end)
	{
		return 0;
	}
	int tmp = q->q[q->start];
	++q->start;
	
	return tmp;
}
