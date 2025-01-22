/*
 * File:   main.c
 * Author: Haoling Zhou
 *
 * Created on November 8, 2024, 9:16 AM
 */
#include <xc.h>
#include <stdint.h>

// PIC16F628A Configuration Bit Settings
#pragma config FOSC = HS    // Oscillator Selection bits
#pragma config WDTE = OFF   // Watchdog Timer Enable bit
#pragma config PWRTE = OFF  // Power-up Timer Enable bit
#pragma config MCLRE = OFF  // RA5/MCLR/VPP Pin Function Select bit
#pragma config BOREN = OFF  // Brown-out Detect Enable bit
#pragma config LVP = OFF    // Low-Voltage Programming Enable bit
#pragma config CPD = OFF    // Data EE Memory Code Protection bit
#pragma config CP = OFF     // Flash Program Memory Code Protection bit

#define _XTAL_FREQ 16000000

void reset();
void skipRom();
void convertT();
void write0();
void write1();
int read();
void readPad();

int main(void) {
	unsigned char pad[9];

	reset();
	skipRom();
	convertT();

	reset();
	skipRom();
	readPad();

    return 0;
}

void reset() {
	TRISB1 = 0;
	__delay_us(500);
	TRISB1 = 1;
	__delay_us(500);
}

void skipRom() {
	write0();
	write0();
	write1();
	write1();
	write0();
	write0();
	write1();
	write1();	
}

void convertT() {
	write0();
	write0();
	write1();
	write0();
	write0();
	write0();
	write1();
	write0();
}

void readPad() {
	write0();
	write1();
	write1();
	write1();
	write1();
	write1();
	write0();
	write1();
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
int read() {
	TRISB1 = 0;
	__delay_us(5);
	TRISB1 = 1;
	__delay_us(90);
	return 0;
}








    
