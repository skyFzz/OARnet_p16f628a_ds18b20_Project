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
  #define _XTAL_FREQ 16000000	; Crystal frequency
  
  ORG 0x00		; Changes the value of the location counter within the current psect
  CLRF STATUS		; Clear bits in PORTB
  BSF STATUS, 5		; Slect Bank 1 for I/O set up
  MOVLW 0X00		; Move literal to W
  MOVWF TRISB		; MOve W to F
  BCF STATUS, 5		; Select Bank 0
  
Loop:
    BSF PORTB, 3	; Set 3rd pin to 1
    CALL Delay		; Subroutine call
    BCF PORTB, 3	; Set 3rd pin to 0, LED off
    CALL Delay		; Subroutine call
    GOTO Loop		; Iterate
    
Delay:			; Subroutine
    MOVLW 0xff		; Write to the wreg reg
    MOVWF 0x20		; Write to the 0x20 reg
    CALL Delay_loop	; Couting subroutine
    RETURN
    
Delay_loop:
    DECFSZ 0x20, F	; Decrement and skip if zero
    GOTO Delay_loop	; Iterate
    RETURN
    
    END