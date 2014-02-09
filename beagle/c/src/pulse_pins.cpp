//============================================================================
// Name        : pulse_pins.cpp
// Author      : 
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
using namespace std;

int main(int argc, char *argv[]) {

	setbuf(stdout, NULL);

	if (argc < 5){
		printf("Usage pulse_pins num_pulses period path pin1 pin2  pin...\n");
		return 1;
	}

	int pulses;
	int period;
    pulses = atoi(argv[1]);
	period = atoi(argv[2]);

	char *path = argv[3];

	int num_pins;
	num_pins = argc-4;
	char pin_nums[num_pins][10];
	int j=0;
	for (int n=4; n<argc; n++){
		strcpy(pin_nums[j], argv[n]);
		j++;
	}

	char pin_paths[num_pins][200];
	for (int n=0; n < num_pins; n++) {
		strcpy(pin_paths[n], "");
		strcat(pin_paths[n], path);
		strcat(pin_paths[n], pin_nums[n]);
		strcat(pin_paths[n], "/value");
	}

	FILE *files[num_pins];
	for (int n=0; n < num_pins; n++){
		files[n] = fopen(pin_paths[n], "r+");
		if (files[n] == NULL){
			printf ("Error: cant open file: %s\n", pin_paths[n]);
			return 1 ;
		}
	}

	for (int i=0; i<pulses; i++){
		for (int f=0; f<num_pins; f++){
			fwrite("1", sizeof(char), 1, files[f]);
			fflush(files[f]);
		}
		usleep(period/2);
		for (int f=0; f<num_pins; f++){
			fwrite("0", sizeof(char), 1, files[f]);
			fflush(files[f]);
		}
		usleep(period/2);
	}
	for (int f=0; f<num_pins; f++){
		fclose(files[f]);
	}
    printf("%d", pulses);

	return 0;
}
