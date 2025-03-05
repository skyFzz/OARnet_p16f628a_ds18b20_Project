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

uint8_t pad[9];

struct tmp {
	uint8_t int_part;
	float	dec_part;
}

struct tmp temp;

int main(void) {
	memset(pad, 0, 9);	

	reset();
	issueCmd(SKIP_ROM);
	issueCmd(CONVERT_T);

	reset();
	issueCmd(SKIP_ROM);
	issueCmd(READ_PAD);
	readPad();			// read the whole scratchpad

	decode_tmp();		// perform temp conversion 

    return 0;
}

/* Reset command */
void reset() {
	TRISB1 = 0;
	__delay_us(500);
	TRISB1 = 1;
	__delay_us(500);
}

/* Send arbitrary command bit by bit */
void issueCmd(unsigned char cmd) {
	for (int i = 0; i < 8; i++) {
		if (cmd & (1 << i)) {	// start transmission with the LS bit
			write1();
		} else {
			write0();
		}
	}
}

/* Read the contents of the scratchpad */
void readPad() {
	for (int i = 0; i < 9; i++) {
		uint8_t byte = 0;
		for (int j = 0; j < 8; j++) {
			if (read_bit()) byte |= (1 << j);
		}
		pad[i] = byte;
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
	__delay_us(15);		// add pullup resistor delay 
	if (RB1) b = 1;		// sampling the bit transmitted from the sensor
	__delay_us(50);
	return b;
}

/* Perform temperature conversion */
void decode_tmp() {
    // Read LSB and MSB from DS18B20 scratchpad
    uint8_t lsb = pad[0];
    uint8_t msb = pad[1];

    // Combine into a signed 16-bit value
    int16_t raw_temp = (msb << 8) | lsb;

    // Convert raw value to Celsius, each bit in decimal is 0.0625
    float tempC = raw_temp * 0.0625;

    // Extract integer and decimal parts
    temp.int_part = (int8_t)tempC;
    temp.dec_part = tempC - temp.int_part;
}
