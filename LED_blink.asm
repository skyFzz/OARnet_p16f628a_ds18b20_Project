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
	


