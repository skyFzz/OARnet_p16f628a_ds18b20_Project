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
    PAGESEL main
    GOTO main
  
  PSECT code
main:
    BANKSEL TRISB		; Select Bank 1
    BSF TRISB, 1		; Configure RB1 (RX)
    BSF TRISB, 2		; Configure RB2 (TX)
    
    BSF TXSTA, 5		; Set bit TXEN to enable the transmission
    BCF TXSTA, 4		; Clear bit SYNC to enable async mode
    
    BCF TXSTA, 2		; Prefer low speed (x64 rather x16) first
    MOVLW 25			; Load the value for SPBRG, which controls the period of a 8-bit timer
    MOVWF SPBRG			; Initialize SPBRG reg for the baud rate at 9600
    
    BANKSEL RCSTA		; Select Bank 0
    BSF RCSTA, 7		; Set bit SPEN to enable serial port
    
    MOVLW 0xff
    MOVWF TXREG
  
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
    RETURN
    
tx:
    MOVWF TXREG
    BANKSEL TXSTA
    BTFSS TXSTA, TRMT
    goto $-1
    BANKSEL TXREG
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


