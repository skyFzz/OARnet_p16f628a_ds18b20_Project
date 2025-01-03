;File:   newAsm.asm
;Description: Read the temperature off a DS18B20 sensor
;Author: Haoling Zhou
;Created on November 20, 2024, 3:34 PM
    
; CONFIG
    CONFIG  FOSC = HS             ; Oscillator Selection bits (HS oscillator: High-speed crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
    CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
    CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
    CONFIG  MCLRE = OFF           ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is digital input, MCLR internally tied to VDD)
    CONFIG  BOREN = OFF           ; Brown-out Detect Enable bit (BOD disabled)
    CONFIG  LVP = OFF             ; Low-Voltage Programming Enable bit (RB4/PGM pin has digital I/O function, HV on MCLR must be used for programming)
    CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
    CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

    #include <xc.inc>
    PSECT resetVec, class=CODE, delta=2
    
    resetVec:			
    ; Start address
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
	CALL	    uart_transmit
	
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
	CALL	    read_byte_0	    ; Read byte 0
	CALL	    read_byte_1	    ; Read byte 1
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
    read_byte_0:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xA4	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN

    read_byte_1:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xA5	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN

    read_byte_2:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xA6	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN
	
    read_byte_3:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xA7	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN

    read_byte_4:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xA8	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN
	
    read_byte_5:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xA9	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN

    read_byte_7:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xAA	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN

    read_byte_8:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xAB	    ; Initialize the reg storing data
	CALL	    read_bit
	DECFSZ	    0xAD, F
	GOTO	    $-2
	RETURN

    read_byte_9:
	MOVLW	    8
	MOVWF	    0xAD	    ; Loop variable
	MOVLW	    0
	MOVWF	    0xAC	    ; Initialize the reg storing data
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
	GOTO	    $+3		    
	BSF	    0XA4, 7	    ; Set bit 7 and shift right
	RRF	    0XA4, F
	BCF	    0XA4, 7	    ; Clear bit 7 and shift right
	RRF	    0XA4, F
	RETURN
   
    delay_io_60us:
	MOVLW	    99
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
	CALL	    load
	RETURN

    ; Load data to the TXREG register and start transmission
    load:
	MOVF	    0xA4, W	; Current byte read from the sensor
	CALL	    tx
	MOVLW	    0X0D	; CR
	CALL	    tx
	MOVLW	    0x0A	; LF
	CALL	    tx
	RETURN

    ; Transmit a byte
    tx:
	BANKSEL	    TXSTA	; Select Bank 1
	BTFSS	    TXSTA, 1	; Test if if TSR is empty
	GOTO	    $-1		; Continue checking until success
	BANKSEL	    TXREG
	MOVWF	    TXREG
	RETURN

    ; Decode the two byte read from the temperature register
    ; 0xB0 - LS byte raw
    ; 0xB1 - MS byte raw
    ; 0xC0 - int part
    ; 0xC1 - LS byte fraction
    ; 0xC2 - MS byte fraction
    decode_temp:
	; Extract <7:4> from LS byte and <3:0> from MS byte to form the int part
	BANKSEL	    0xA4
	RRF	    0xA4, W	; W = LS_temp >> 1
	RRF	    0xA4, W	; W = LS_temp >> 1
	RRF	    0xA4, W	; W = LS_temp >> 1
	RRF	    0xA4, W	; W = LS_temp >> 1
	CLRF	    0xC0	; int_part = 0
	MOVWF	    0xC0	; int_part = W
	  
	RLF	    0xA5, W	; W = MS_temp << 1
	RLF	    0xA5, W	; W = MS_temp << 1
	RLF	    0xA5, W	; W = MS_temp << 1
	RLF	    0xA5, W	; W = MS_temp << 1
	IORWF	    0xC0, F	; int_part |= W
	
	; Check for MS byte bit 3 for +/-
	BANKSEL	    0xA5
	BTFSS	    0xA5, 3
	; ...

    ; 0xE0 - remainder
    ; 0xE2 - copy of int part
    mod_by_10:
	MOVF	    0xC0	; W = int_part
	MOVWF	    0xE2	; copy_int_part = W
	MOVLW	    10		; W = 10
	SUBWF	    0xE2, W 	; W = copy_int_part - 10
	BTFSC	    STATUS, 0	; if (copy_int_part < 0) return;
	RETURN			;	
	MOVWF	    0xE0	; remainder = W  
	GOTO	    mod_by_10	;
	
    ; 0xE1 - quotient
    divide_by_10:
	SUBLW	    10
	BTFSS	    STATUS, 0
	RETURN
	INCF	    0xE1, F
	GOTO	    divide_by_10
	
	
    ; Preload the digit table	
    ; 0xD0 - zero
    ; 0xD1 - one
    ; ...
    ; 0xD9 - nine
    compute_digit_table:
	CLRW
	ADDLW	    0x30	; W += 0x30
	MOVWF	    0xD0	; zero = W
	ADDLW	    1		; W += 1
	MOVWF	    0xD1	; one = W
	ADDLW	    1		; ...
	MOVWF	    0xD2
	ADDLW	    1
	MOVWF	    0xD3
	ADDLW	    1
	MOVWF	    0xD4
	ADDLW	    1
	MOVWF	    0xD5
	ADDLW	    1
	MOVWF	    0xD6
	ADDLW	    1
	MOVWF	    0xD7
	ADDLW	    1
	MOVWF	    0xD8
	ADDLW	    1		; W += 1
	MOVWF	    0xD9	; nine = W
    
	END resetVec

	
