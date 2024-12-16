;File:   newAsm.asm
;Author: hzhou1
;Created on November 20, 2024, 3:34 PM
    
; PIC16F628A Configuration Bit Settings

; Assembly source line config statements
    
; CONFIG
  CONFIG  FOSC = HS             ; Oscillator Selection bits (HS oscillator: High-speed crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is digital input, MCLR internally tied to VDD)
  CONFIG  BOREN = OFF           ; Brown-out Detect Enable bit (BOD disabled)
  CONFIG  LVP = OFF             ; Low-Voltage Programming Enable bit (RB4/PGM pin has digital I/O function, HV on MCLR must be used for programming)
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

 // config statements should precede project file includes.
    #include <xc.inc>
    PSECT resetVec, class=CODE, delta=2
    resetVec:			; Start address
	PAGESEL init
	GOTO init
  
    PSECT code
 
    init:
	; Initialize pins RX and TX, both should be set as inputs
	BANKSEL TRISB		; Select Bank 1
	BSF TRISB, 1		
	BSF TRISB, 2		
	; Initialize the SPBRG register for the appropriate baud rate
	BANKSEL TXSTA
	BCF TXSTA, 2		; Select low speed baud rate
	BCF TXSTA, 4		; Enable async mode
	MOVLW 25		; Load the value for SPBRG, which controls the period of a 8-bit timer
	BANKSEL SPBRG
	MOVWF SPBRG		; Initialize SPBRG reg for the baud rate
	; Enable the async serial port
	BANKSEL RCSTA		; Select Bank 0
	BSF RCSTA, 7		; Set bit SPEN to enable serial port
	; Enable the transmission
	BANKSEL TXSTA
	BSF TXSTA, 5
    
    ; Load data to the TXREG register (starts transmission)
    data:
	MOVLW 'O'
	CALL tx
	MOVLW 'H'
	CALL tx
	MOVLW 'I'
	CALL tx
	MOVLW 'O'
	CALL tx
	MOVLW 0X0D	; CR
	CALL tx
	MOVLW 0x0A	; LF
	CALL tx
	GOTO data

    tx:
	BANKSEL TXSTA		; Select Bank 1
	BTFSS TXSTA, 1		; Test if TRMT bit is set (if TSR is empty)
	goto $-1		; Continue checking until success
	BANKSEL TXREG		; Select Bank 0
	MOVWF TXREG		; Load the transmit buffer with data, start transmission
	RETURN

	 /*  
	; LED light code
	BANKSEL TRISB		; Assembly directive, replacing the directive with the assembly code. It will select the correct bank TRISB is in
	CLRF TRISB			; Every bit in PORTB will be output
	BANKSEL PORTB		; Select Bank 0, where PORTB is in

      toggle:
	BSF PORTB, 3
	CALL delay
	BCF PORTB, 3
	CALL delay
	GOTO toggle

      delay:
	MOVLW 0xFF
	MOVWF 20h
	DECFSZ 20h, F
	RETURN
	 */

    END resetVec


