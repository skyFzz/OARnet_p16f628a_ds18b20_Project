;File:   LED_blink.asm
;Author: hzhou1
;Created on November 20, 2024, 3:34 PM
    
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

    PROCESSOR 16F628A
    #include <xc.inc>
    
    PSECT resetVec,class=CODE,delta=2
    resetVec:			; Start address
	PAGESEL main		; jump to the main routine
	goto main
    
    PSECT code
    
    main:
	; LED light code
	BANKSEL TRISB		; Assembly directive, replacing the directive with the assembly code. It will select the correct bank TRISB is in
	CLRF TRISB		; Every bit in PORTB will be output
	BANKSEL PORTB		; Select Bank 0, where PORTB is in

    toggle:
	BSF PORTB, 3
	MOVLW 1
	MOVWF 21h
	CALL delay
	BCF PORTB, 3
	MOVLW 4
	MOVWF 21h
	CALL delay
	GOTO toggle

    ; Base = 1: 6 cycles = 1200ns = 1.2us
    ; Base = 2: 9 cycles = 1800ns = 1.8us
    ; Base = 3: 12 cycles = 2400ns = 2.4us
    ; Base = 4: 15 cycles = 3000ns = 3us
    ; Base = 255: 6 + 762 = 768 cycles = 153600ns = 153.6us
	; Total 768 cycles + 3 cycles = 771 cycles = 154200ns = 154.2us

    delay:
	MOVLW 255
	MOVWF 20h
	DECFSZ 20h, F
	GOTO $-1
	DECFSZ 21h, F
	GOTO delay
	RETURN
	
	END	resetVec
	


