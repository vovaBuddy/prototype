#include <stdio.h>
#include <stdlib.h>
#include <time.h>  
#include "queue.h"

void event_generator(void* some)
{
	srand ( time(NULL) );
	int random_number = rand() % 4;
	Queue *tmp = (Queue*) some;
	put(tmp, random_number);
}

void one_hendler()
{
	printf("Hendling 1 event!\n");
}

void two_hendler()
{
	printf("Hendling 2 event!\n");
}

void three_hendler()
{
	printf("Hendling 3 event!\n");
}

int main()
{
	void (*fptr[10])();
	
	fptr[0] = event_generator;
	fptr[1] = one_hendler;
	fptr[2] = two_hendler;
	fptr[3] = three_hendler;
	
	
	int t;
	Queue q;
	init_queue(&q);
	int i = 0;
	
	
	while(++i < 20)
	{
		sleep(1);
		printf("Step\n");
		(*fptr[0])((void*)&q);
		
		t = get(&q);
		if (t != 0)
		{
			(*fptr[t])();
		}
		
	}
	
	return 0;
}

