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
 
;    init:
;	; Initialize pins RX and TX, both should be set as inputs
;	BANKSEL TRISB		; Select Bank 1
;	BSF TRISB, 1		
;	BSF TRISB, 2		
;	; Initialize the SPBRG register for the appropriate baud rate
;	BANKSEL TXSTA
;	BCF TXSTA, 2		; Select low speed baud rate
;	BCF TXSTA, 4		; Enable async mode
;	MOVLW 25		; Load the value for SPBRG, which controls the period of a 8-bit timer
;	BANKSEL SPBRG
;	MOVWF SPBRG		; Initialize SPBRG reg for the baud rate
;	; Enable the async serial port
;	BANKSEL RCSTA		; Select Bank 0
;	BSF RCSTA, 7		; Set bit SPEN to enable serial port
;	; Enable the transmission
;	BANKSEL TXSTA
;	BSF TXSTA, 5		; Set bit TXEN to enable transmission
;	; Enable the reception
;	BANKSEL RCSTA
;	BSF RCSTA, 4		; Set bit CREN to enable reception
    
    init:
	; Bus master transmits the reset pulse by pulling the 1-Wire bus low
	BANKSEL TRISB
	BCF TRISB, 1		; Set RB1 as output for transmission
	BANKSEL PORTB
	BCF PORTB, 1		; Pull the bus low
	CALL delay_480us
	; Bus master releases the bus and goes into receive mode
	BANKSEL TRISB
	BSF TRISB, 1		; Releases the bus by setting RB1 as input
	CALL delay_480us

    ; Master issues SKip ROM command (0xCC -> 11001100)
    ds18b20_ROM:
	BCF TRISB, 1
	BANKSEL PORTB
	BSF PORTB, 1
	CALL delay_60us
	BSF PORTB, 1
	CALL delay_60us
	BCF PORTB, 1
	CALL delay_60us
	BCF PORTB, 1
	CALL delay_60us
	BSF PORTB, 1
	CALL delay_60us
	BSF PORTB, 1
	CALL delay_60us
	BCF PORTB, 1
	CALL delay_60us
	BCF PORTB, 1
	CALL delay_60us
    
    ; Master issues Convert T command (0x44)
    ds18b20_convert:
	BCF PORTB, 1
	BSF PORTB, 1
	BCF PORTB, 1
	BCF PORTB, 1
	BCF PORTB, 1
	BSF PORTB, 1
	BCF PORTB, 1
	BCF PORTB, 1
	
    ; Master issues Read Scratchpad command (0xBE -> 10111110)
    ds18b20_read:
	BSF PORTB, 1
	BCF PORTB, 1
	BSF PORTB, 1
	BSF PORTB, 1
	BSF PORTB, 1
	BSF PORTB, 1
	BSF PORTB, 1
	BCF PORTB, 1
	
	BANKSEL TRISB
	BSF TRISB, 1		; Set RB1 as input to read the entire scratchpad
	
	GOTO ds18b20_init
	
    ; Generate 60us delay for each read/write time slot
    delay_60us:
	RETURN
    ; Generate 480us delay for initialization step
    delay_480us:
	MOVLW 0xFF
	MOVWF 0x20
	DECFSZ 0x20, F
	RETURN
	


	

    END resetVec


