#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <unistd.h>

// Ограничение таблицы сигналов
#define maxSignalNumber 64

// TODO: Ограничение числа алгоритмов-подписчиков на один сигнал
const maxSubscriberNumber = 8;

// Сигнал
typedef int signal_value_t;

// Таблица сигналов
static signal_value_t signalTable[maxSignalNumber+1]; // номера сигналов - положительные числа

// Алгоритм
typedef void (*algorithm_t) (signal_value_t);

// Алгоритм1
static void algorithm1(signal_value_t signal)
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

    if (sensor2 == signal) {
	// цикл foreach по приводам мотора
	for (i = 0; motor[i]; ++i) {
	    signalTable[motor[i]] = 1;
	}
    }

    printf("algorithm1 %d\n", signal);
}

// Алгоритм2
static void algorithm2(signal_value_t signal)
{
    // TODO
    signalTable[signal] = signalTable[signal];
    printf("algorithm2 %d\n", signal);
}

// Алгоритм3
static void algorithm3(signal_value_t signal)
{
    // TODO
    signalTable[signal] = signalTable[signal];
    printf("algorithm3 %d\n", signal);
}

// Таблица алгоритмов
static algorithm_t handlers[] = {
    algorithm1
    ,algorithm2
    ,algorithm3
};
const handlersNum = sizeof(handlers)/sizeof(algorithm_t);

int main()
{
    int i;
    char buf[256];

    while (1) {
	long signal;

	fgets(buf, sizeof buf, stdin);
	signal = strtol(buf, NULL, 0);
	if (signal < 0 || LONG_MAX == signal) continue;

	for (i = 0; i < handlersNum; ++i) {
	    handlers[i]((int)signal);
	}
    }

    return 0;
}

