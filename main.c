/*
 * File:   main.c
 * Author: Haoling Zhou
 *
 * Created on November 8, 2024, 9:16 AM
 */
#include <xc.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// PIC16F628A Configuration Bit Settings
#pragma config FOSC = HS    // Oscillator Selection bits
#pragma config WDTE = OFF   // Watchdog Timer Enable bit
#pragma config PWRTE = OFF  // Power-up Timer Enable bit
#pragma config MCLRE = OFF  // RA5/MCLR/VPP Pin Function Select bit
#pragma config BOREN = OFF  // Brown-out Detect Enable bit
#pragma config LVP = OFF    // Low-Voltage Programming Enable bit
#pragma config CPD = OFF    // Data EE Memory Code Protection bit
#pragma config CP = OFF     // Flash Program Memory Code Protection bit

#define _XTAL_FREQ 20000000	// 20 MHz crystal, 200 ns per instruction

/* C style of BSF and BCF instructions */
#define bitset(var, bitno)	((var) |= 1UL << (bitno))
#define bitclr(var, bitno)	((var) &= ~(1UL << (bitno)))

/* ROM Commands */
#define SEARCH_ROM		0xF0
#define READ_ROM		0x33
#define MATCH_ROM		0x55
#define SKIP_ROM		0xCC
#define ALARM_SEARCH	0xEC

/* Function Commands */
#define CONVERT_T		0x44
#define	WRITE_PAD		0x4E
#define READ_PAD		0xBE
#define COPY_PAD		0x48
#define RECALL_EE		0xB8
#define READ_POWER		0xB4

void reset();
void issueCmd(unsigned char cmd);
void readPad();
void write0();
void write1();
int read_bit();

unsigned char pad[9];

int main(void) {
	memset(pad, 0, 9);	

	reset();
	issueCmd(SKIP_ROM);
	issueCmd(CONVERT_T);

	reset();
	issueCmd(SKIP_ROM);
	issueCmd(READ_PAD);
	readPad();			// read the whole scratchpad

    return 0;
}

void reset() {
	TRISB1 = 0;
	__delay_us(500);
	TRISB1 = 1;
	__delay_us(500);
}

void issueCmd(unsigned char cmd) {
	for (int i = 0; i < 8; i++) {
		if (cmd & (0x01 << i)) {	// start transmission with the LS bit
			write1();
		} else {
			write0();
		}
	}
}

/* Read the contents of the scratchpad */
void readPad() {
	for (int i = 0; i < 9; i++) {
		for (int j = 0; j < 8; j++) {
			if (read_bit()) {
				bitset(pad[i], j);
			} else {
				bitclr(pad[i], j);
			}
		}
	}
}

/* Write 1 Time Slot */
void write1() {
	TRISB1 = 0;
	__delay_us(5);
	TRISB1 = 1;
	__delay_us(90);
}

/* Write 0 Time Slot */
void write0() {
	TRISB1 = 0;
	__delay_us(90);
	TRISB1 = 1;
	__delay_us(5);
}

/* Read Time Slot */
int read_bit() {
	int b = 0;
	TRISB1 = 0;
	__delay_us(5);
	TRISB1 = 1;
	__delay_us(10);		// add pullup resistor delay 
	if (TRISB1) {		// sampling the bit transmitted from the sensor
		b = 1;
	}
	__delay_us(50);
	return b;
}

void decode() {
	
}
