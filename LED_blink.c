#include <xc.h>

// PIC16F628A Configuration Bit Settings
#pragma config FOSC = HS    // Oscillator Selection bits
#pragma config WDTE = OFF   // Watchdog Timer Enable bit
#pragma config PWRTE = OFF  // Power-up Timer Enable bit
#pragma config MCLRE = OFF  // RA5/MCLR/VPP Pin Function Select bit
#pragma config BOREN = OFF  // Brown-out Detect Enable bit
#pragma config LVP = OFF    // Low-Voltage Programming Enable bit
#pragma config CPD = OFF    // Data EE Memory Code Protection bit
#pragma config CP = OFF     // Flash Program Memory Code Protection bit

#define _XTAL_FREQ 20000000     // Set the oscillator frequency to 20MHz

void main(void) {
    TRISB = 0;  // Set PORTB as output (all bits are output)

    while(1) {
        RB3 = 1;  // Set RB3 high (turn on the LED)
        __delay_ms(1000);           // Delay for 100 milliseconds
        
        RB3 = 0;  // Set RB3 low (turn off the LED)
        __delay_ms(1000);           // Delay for 100 milliseconds
    }
}

