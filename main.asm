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
	PAGESEL	    main
	GOTO	    main
	
    PSECT code
    
    main:
	; UART Rx Tx Set Up
	;CALL	    uart_receive_init
	;CALL	    uart_transmit_init
	
	; Temperature Conversion
	CALL	    reset_pulse
	CALL	    skip_rom
	CALL	    convert_t
	
	; Temperature Read
	CALL	    reset_pulse
	CALL	    skip_rom
	CALL	    read_scratchpad
	
	GOTO	    main
	
    ; Tansmits the reset pulse
    reset_pulse:
	BANKSEL	    TRISB
	BCF	    TRISB, 1		; Pull the bus low, in Tx mode
	CALL	    delay_loop
	BSF	    TRISB, 1		; Release the bus, in Rx mode
	CALL	    delay_loop
	RETURN
	
    ; Send CCh
    skip_rom:
	CALL	    write_0
	CALL	    write_0
	CALL	    write_1
	CALL	    write_1
	CALL	    write_0
	CALL	    write_0
	CALL	    write_1
	CALL	    write_1
	RETURN
	
    ; Send 44h
    convert_t:
	CALL	    write_0
	CALL	    write_0
	CALL	    write_1
	CALL	    write_0
	CALL	    write_0
	CALL	    write_0
	CALL	    write_1
	CALL	    write_0
	RETURN

    ; Send BEh
    read_scratchpad:
	CALL	    write_0
	CALL	    write_1
	CALL	    write_1
	CALL	    write_1
	CALL	    write_1
	CALL	    write_1
	CALL	    write_0
	CALL	    write_1
	RETURN

    write_1:
	BANKSEL	    TRISB
	BCF	    TRISB, 1	    ; Pull the bus low to initiate the write time slot
	CALL	    delay_io_6us
	BSF	    TRISB, 1	    ; Release the bus
	CALL	    delay_io_60us
	RETURN
	
    write_0:
	BANKSEL	    TRISB
	BCF	    TRISB, 1
	CALL	    delay_io_60us   ; Continue holding bus low without release
	BSF	    TRISB, 1	    ; Release the bus
	CALL	    delay_io_6us    ; 1us recovery time between slots
	RETURN

    ; 0xA4 - byte 0
    ; 0xA5 - byte 1
    ; ...
    ; 0xAC - byte 8
    read:
	BANKSEL	    TRISB
	BCF	    TRISB, 1
	CALL	    delay_io_6us
	BSF	    TRISB, 1
	CALL	    read_byte0

    read_byte0:
	MOVLW	    0
	MOVWF	    0XA4
	BTFSS	    TRISB, 1	    ; Sample the bus state within 15us from the start of the slot
	GOTO	    $+3		    ; Read 0 if the bus state is low
	BSF	    0XA4, 0	    ; Read 1 if the bus state is high
	RLF	    0XA4, F
	BCF	    0XA4, 0
	RLF	    0XA4, F
	
    read_byte1:
	MOVLW	    0
	MOVWF	    0XA5
	BTFSS	    TRISB, 1
	GOTO	    $+3	
	BSF	    0XA5, 0
	RLF	    0XA5, F
	BCF	    0XA5, 0
	RLF	    0XA5, F
	
    read_byte2:
	MOVLW	    0
	MOVWF	    0XA6
	BTFSS	    TRISB, 1	    
	GOTO	    $+3	
	BSF	    0XA6, 0	   
	RLF	    0XA6, F
	BCF	    0XA6, 0
	RLF	    0XA6, F
	
    read_byte3:
	MOVLW	    0
	MOVWF	    0XA7
	BTFSS	    TRISB, 1	 
	GOTO	    $+3		
	BSF	    0XA7, 0
	RLF	    0XA7, F
	BCF	    0XA7, 0
	RLF	    0XA7, F
	
    read_byte4:
	MOVLW	    0
	MOVWF	    0XA8
	BTFSS	    TRISB, 1	   
	GOTO	    $+3		    
	BSF	    0XA8, 0	  
	RLF	    0XA8, F
	BCF	    0XA8, 0
	RLF	    0XA8, F

    read_byte5:
	MOVLW	    0
	MOVWF	    0XA9
	BTFSS	    TRISB, 1	 
	GOTO	    $+3		
	BSF	    0XA9, 0
	RLF	    0XA9, F
	BCF	    0XA9, 0
	RLF	    0XA9, F
	
    read_byte6:
	MOVLW	    0
	MOVWF	    0XAA
	BTFSS	    TRISB, 1	    
	GOTO	    $+3		   
	BSF	    0XAA, 0	  
	RLF	    0XAA, F
	BCF	    0XAA, 0
	RLF	    0XAA, F
	
    read_byte7:
	MOVLW	    0
	MOVWF	    0XAB
	BTFSS	    TRISB, 1	    
	GOTO	    $+3		    
	BSF	    0XAB, 0	    
	RLF	    0XAB, F
	BCF	    0XAB, 0
	RLF	    0XAB, F
	
    read_byte8:
	MOVLW	    0
	MOVWF	    0XAC
	BTFSS	    TRISB, 1	    
	GOTO	    $+3		    
	BSF	    0XAC, 0	    
	RLF	    0XAC, F
	BCF	    0XAC, 0
	RLF	    0XAC, F
   
    delay_io_60us:
	MOVLW	    98
	MOVWF	    0xA3
	DECFSZ	    0xA3, F
	GOTO	    $-1
	RETURN
	
    ; 6 us delay
    delay_io_6us:
	MOVLW	    10
	MOVWF	    0xA2
	DECFSZ	    0xA2, F
	GOTO	    $-1
	RETURN
    
    ; m * (3n + 8) + 2 where m = A1h
    ; When A1h = 4, A0h = 255, total cycles around 3094 = 618.8 us
    delay_loop:
	MOVLW	    4
	MOVWF	    0xA1
	CALL	    delay
	RETURN
    
    ; 3n + 8 where n = A0h - 1
    delay:
	MOVLW	    255
	MOVWF	    0xA0
	DECFSZ	    0xA0, F
	GOTO	    $-1
	DECFSZ	    0xA1, F
	GOTO	    delay
	RETURN

    ; UART Rx Set Up
    uart_receive_init:
	BANKSEL	    TRISB
	BSF	    TRISB, 1
	BSF	    TRISB, 2
	BANKSEL	    TXSTA
	BCF	    TXSTA, 2
	BCF	    TXSTA, 4
	MOVLW	    25
	BANKSEL	    SPBRG
	MOVWF	    SPBRG
	BANkSEL	    RCSTA
	BSF	    RCSTA, 7
	BSF	    RCSTA, 4		; Set bit CREN to enable the reception
	RETURN
	
    ; UART Tx Set Up
    uart_transmit_init:
	; Initialize pins RX and TX, both should be set as inputs
	BANKSEL	    TRISB
	BSF	    TRISB, 1		; Set RB1 as input to read the entire scratchpad	
	BSF	    TRISB, 2
	; Initialize the SPBRG register for the appropriate baud rate
	BANKSEL	    TXSTA
	BCF	    TXSTA, 2		; Select low speed baud rate
	BCF	    TXSTA, 4		; Clear bit SYNC to enable async serial port
	MOVLW	    25		; Load the value for SPBRG, which controls the period of a 8-bit timer
	BANKSEL	    SPBRG
	MOVWF	    SPBRG		; Initialize SPBRG reg for the baud rate
	; Enable the async serial port
	BANKSEL	    RCSTA		; Select Bank 0
	BSF	    RCSTA, 7		; Set bit SPEN to enable async serial port
	; Enable the transmission
	BANKSEL	    TXSTA
	BSF	    TXSTA, 5		; Set bit TXEN to enable transmission
	RETURN
	
	
	END resetVec


