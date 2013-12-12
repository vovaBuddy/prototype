#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <unistd.h>

// Ограничение таблицы сигналов
#define maxSignalNumber 64

// TODO: Ограничение числа алгоритмов-подписчиков на один сигнал
const int maxSubscriberNumber = 8;

typedef char* signal_type;

// Значение cигнала
typedef int signal_value_t;
// Сигнал
typedef struct signal
{
	signal_type type;
	signal_value_t value;
	int number;
	
} signal;

// Таблица сигналов
static signal_value_t signalTable[maxSignalNumber+1]; // номера сигналов - положительные числа



// Алгоритм
typedef void (*algorithm_t) (signal);


static void algorithm(signal signal)
{
	enum sensors
	{
		sensor1 = 1
		,sensor2 = 2
		,sensor4 = 4
	};
	
	
	enum values
	{
		sensor1_value = 1 
		,sensor2_value = 2
		,sensor4_value = 4
	};
	
	signalTable[signal.number] = signal.value;
	printf("value in  signalTable[%d] changed to %d\n", signal.number, signal.value);
	
	
	//TODO нужна нормальная проверка
	if (sensor1_value == signalTable[sensor1] && sensor2_value == signalTable[sensor2] && sensor4_value == signalTable[sensor4])
	{
		printf("start algorithm 1 2 4\n");
	}
}

static void algorithm1(signal signal)
{
    int i; 

    // декларация алиаса сигнала, например так
    enum {
        sensor1 = 1
        ,sensor2 = 12
        ,sensor31 = 25
        ,gear1 = 33
        ,gear2
    };

    // декларация сета или сложного объекта, пример
    //const int motor[] = { sensor1, sensor2, sensor31, 0}; // 0 - несуществующий номер сигнала
    const int motor[] = { gear1, gear2, 0};

    if (sensor2 == signal.value) {
        // цикл foreach по приводам мотора
        for (i = 0; motor[i]; ++i) {
            signalTable[motor[i]] = 1;
        }
    }

    printf("algorithm1 %d\n", signal.number);
}

// Алгоритм2
static void algorithm2(signal signal)
{
    // TODO
    signalTable[signal.number] = signal.value;
    printf("algorithm2 %d\n", signal.number);
}

// Алгоритм3
static void algorithm4(signal signal)
{
    // TODO
	signalTable[signal.number] = signal.value;
    printf("algorithm3 %d\n", signal.number);
}

static void no_algorithm(signal signal)
{
    // TODO
	signalTable[signal.number] = signal.value;
	printf("value in  signalTable[%d] changed to %d\n", signal.number, signal.value);
    printf("this signal hasn't algorithms \n");
}

// Таблица алгоритмов
static algorithm_t handlers[] = {
	no_algorithm
    ,algorithm
    ,algorithm
    ,no_algorithm
    ,algorithm
    ,no_algorithm
};


const handlersNum = sizeof(handlers)/sizeof(algorithm_t);

signal signals_generator(char* buf)
{
    signal signal;
    fgets(buf, sizeof buf, stdin);
    signal.number = strtol(buf, NULL, 0);
    signal.value = signal.number;
    return signal;
}

int main()
{
    char buf[256];

    while (1) {
        
        signal signal = signals_generator(buf);
        
        if (signal.number < 0 || LONG_MAX == signal.number || signal.number > handlersNum) continue;
        
        // номеру сигнала соответствует номер обработчика из таблицы алгоритмов
        handlers[signal.number](signal);
        
    }

    return 0;
}

