void algorithm1 (signal_t s) {
	int i = 0;
							enum {
		signal1 = 5,
		signal2 = 10,
	};
	enum {
		signal3 = 11,
		signal4 = 23,
	};
	int array[] = {signal1, signal2, signal3, signal4};
	int array2[] = {signal3, signal4};
	for (i=0; i<4;++i){
		signalTable[array[i]] = 1;
	}
	if(signalTable[signal1] >= 10 && signalTable[signal1] != 15) {
		signalTable[signal2] = 10;
	}
	switch(signalTable[signal1]) {
	case 1: 
	signalTable[signal1] = 10;
	break; 
	case signalTable[signal3]: 
	signalTable[signal1] = 12;
	break; 
	case default: 
	for (i=0; i<4;++i){
		signalTable[array[i]] = 0;
	}
	break;
	}
	if( ( signalTable[signal1] == 10 || signalTable[signal2] == 11 ) && ( signalTable[signal3] == 1 || signalTable[signal2] == 11 )) {
		signalTable[signal4] = 10;
	}
	else {
		for (i=0; i<2;++i){
		if(signalTable[array2[i]] == 10) {
		signalTable[array2[i]] = 2;
	}
	}
	} 
} 
