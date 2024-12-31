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
	; Temperature Conversion
	CALL	    reset_pulse
	CALL	    skip_rom
	CALL	    convert_t
	
	; Temperature Read
	CALL	    reset_pulse
	CALL	    skip_rom
	CALL	    read_scratchpad
	
	; UART Tx
	;CALL	    uart_transmit
	
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
	CALL	    read_bit
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
	CALL	    read_byte	    ; Read byte 0
	CALL	    read_byte	    ; Read byte 1
	;CALL	    read_byte	    ; Read byte 2
	;CALL	    read_byte	    ; Read byte 3
	;CALL	    read_byte	    ; Read byte 4
	RETURN

    write_1:
	BANKSEL	    TRISB
	BCF	    TRISB, 1	    ; Pull the bus low
	CALL	    delay_io_1us
	BSF	    TRISB, 1	    ; Release the bus
	CALL	    delay_io_60us
	RETURN
	
    write_0:
	BANKSEL	    TRISB
	BCF	    TRISB, 1
	CALL	    delay_io_60us   ; Continue holding bus low without release
	BSF	    TRISB, 1	    ; Release the bus
	CALL	    delay_io_1us    ; 1us recovery time between slots
	RETURN

    ; 0xA4 - byte 0
    ; 0xA5 - byte 1
    ; ...
    ; 0xAC - byte 8
    ; Loop read_bit 8 times to read a byte
    read_byte:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xA4	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN
    
    ; A complete read time slot for reading one bit
    read_bit:
	BANKSEL	    TRISB
	BCF	    TRISB, 1	    ; Pulling the bus low
	CALL	    delay_io_1us    
	BSF	    TRISB, 1	    ; Release the bus
	CALL	    delay_io_10us   ; Locate the master sample time towards end
	CALL	    read
	CALL	    delay_io_60us   ; Make time slot duration at least 60 us
	RETURN

    ; Acutal sampling of the bit transmitted by the sensor
    read:
	BTFSS	    TRISB, 1	    ; Sample the bus state within 15us
	GOTO	    $+3		    ; Read 0 if the bus state is low
	BSF	    0XA4, 0	    ; Read 1 if the bus state is high
	RLF	    0XA4, F
	BCF	    0XA4, 0
	RLF	    0XA4, F
	RETURN
   
    delay_io_60us:
	MOVLW	    98
	MOVWF	    0xA3
	DECFSZ	    0xA3, F
	GOTO	    $-1
	RETURN

    ; 10.2 us delay
    delay_io_10us:
	MOVLW	    16
	MOVWF	    0xAE
	DECFSZ	    0xAE, F
	GOTO	    $-1
	RETURN
	
    ; 1.2 us delay
    delay_io_1us:
	MOVLW	    1
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

    ; UART Tx Set Up
    uart_transmit:
	; Initialize pin TX, both should be set as inputs
	BANKSEL	    TRISB		
	BSF	    TRISB, 2
	; Initialize the SPBRG register for the appropriate baud rate
	BANKSEL	    TXSTA
	BCF	    TXSTA, 2	; BRGH = 0 (low speed baud rate)
	BCF	    TXSTA, 4	; Clear bit SYNC to enable serial port
	MOVLW	    32		; SPBRG = 32 for 20 MHz, 25 for 16 MHz
	BANKSEL	    SPBRG
	MOVWF	    SPBRG	; Initialize SPBRG reg for the baud rate
	; Enable the async serial port
	BANKSEL	    RCSTA	; Select Bank 0
	BSF	    RCSTA, 7	; Set bit SPEN to enable serial port
	; Enable the transmissionOne
	BANKSEL	    TXSTA
	BSF	    TXSTA, 5	; Set bit TXEN to enable transmission
	; Start transmission
	CALL	    transmit
	RETURN

    ; Load data to the TXREG register and start transmission
    transmit:
        BANKSEL	    TXSTA	; Select Bank 1
	BTFSS	    TXSTA, 1	; Test if if TSR is empty
	goto	    $-1		; Continue checking until success
	BANKSEL	    TXREG	; Select Bank 0
	
	MOVF	    0xA4, W	; Current byte read from the sensor
	MOVWF	    TXREG			    
	MOVLW	    0X0D	; CR
	MOVWF	    TXREG
	MOVLW	    0x0A	; LF
	MOVWF	    TXREG
	RETURN

	END resetVec


