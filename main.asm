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
	BCF	    	TRISB, 1		; Pull the bus low, in Tx mode
	CALL	    delay_loop
	BSF	    	TRISB, 1		; Release the bus, in Rx mode
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
	CALL	    read_byte_2	    ; Read byte 2
	CALL	    read_byte_3	    ; Read byte 3
	CALL	    read_byte_4	    ; Read byte 4
	CALL	    read_byte_5	    ; Read byte 5
	CALL	    read_byte_6	    ; Read byte 6
	CALL	    read_byte_7	    ; Read byte 7
	CALL	    read_byte_8	    ; Read byte 8
	RETURN

    write_1:
	BANKSEL	    TRISB
	BCF	    	TRISB, 1	    ; Pull the bus low
	CALL	    delay_io_1us
	BSF	    	TRISB, 1	    ; Release the bus
	CALL	    delay_io_60us
	RETURN
	
    write_0:
	BANKSEL	    TRISB
	BCF	    	TRISB, 1
	CALL	    delay_io_60us   ; Continue holding bus low without release
	BSF	    	TRISB, 1	    ; Release the bus
	CALL	    delay_io_1us    ; 1us recovery time between slots
	RETURN

    ; A complete read time slot for reading one bit
    read_bit:
	BANKSEL	    TRISB
	BCF	    	TRISB, 1	    ; Pulling the bus low
	CALL	    delay_io_1us    
	BSF	    	TRISB, 1	    ; Release the bus
	CALL	    delay_io_10us   ; Locate the master sample time towards end
	RETURN

    ; Read byte 0, stored in 0xA4, value = TEMERATURE LSB
    read_byte_0:
	MOVLW	    8
	MOVWF	    0xAD	    		; Loop variable
	MOVLW	    0
	MOVWF	    0xA4	    		; Initialize the reg storing data
	CALL	    read_bit			; Generate one read time slot
	CALL		bit_sample_byte_0	; Sampling the bus state
	DECFSZ	    0xAD, F				; if (--i == 0) SKIP;
	GOTO	    $-3					; Read the next bit
	RETURN

    ; Sample the bit transmitted by the sensor
    bit_sample_byte_0:
	BTFSS	    TRISB, 1	    ; Sample the bus state within 15us, skip if set
	GOTO	    $+3		    
	BSF			0XA4, 7	    	; Set bit 7 and shift right
	RRF	    	0XA4, F
	BCF	    	0XA4, 7	    	; Clear bit 7 and shift right
	RRF	    	0XA4, F
	CALL		delay_io_60us	; Make time slot duration at least 60 us
	RETURN
   
	; Read byte 1, stored in 0xA5, value = TEMPERATUE MSB 
    read_byte_1:
	MOVLW	    8
	MOVWF	    0xAD	 
	MOVLW	    0
	MOVWF	    0xA5	  
	CALL	    read_bit
	CALL		bit_sample_byte_1
	DECFSZ	    0xAD, F
	GOTO	    $-3
	RETURN

    bit_sample_byte_1:
	BTFSS	    TRISB, 1	   
	GOTO	    $+3		    
	BSF			0XA5, 7	    
	RRF	    	0XA5, F
	BCF	    	0XA5, 7	   
	RRF	    	0XA5, F
	CALL		delay_io_60us
	RETURN

	; Read byte 2, stored in 0xA6, value = HIGH ALARM TRIGGER REGISTER (EEPROM)
    read_byte_2:
	MOVLW	    8
	MOVWF	    0xAD	    
	MOVLW	    0
	MOVWF	    0xA6	   
	CALL	    read_bit
	CALL		bit_sample_byte_2
	DECFSZ	    0xAD, F
	GOTO	    $-3
	RETURN
	
    bit_sample_byte_2:
	BTFSS	    TRISB, 1	
	GOTO	    $+3		    
	BSF			0XA6, 7	   
	RRF	    	0XA6, F
	BCF	    	0XA6, 7	  
	RRF	    	0XA6, F
	CALL		delay_io_60us	
	RETURN

	; Read byte 3, stored in 0xA7, value = LOW ALARM TRIGGER REGISTER (EEPROM)
    read_byte_3:
	MOVLW	    8
	MOVWF	    0xAD	    
	MOVLW	    0
	MOVWF	    0xA7	   
	CALL	    read_bit
	CALL		bit_sample_byte_3
	DECFSZ	    0xAD, F
	GOTO	    $-3
	RETURN

    bit_sample_byte_3:
	BTFSS	    TRISB, 1	  
	GOTO	    $+3		    
	BSF			0XA7, 7	    
	RRF	    	0XA7, F
	BCF	    	0XA7, 7	   
	RRF	    	0XA7, F
	CALL		delay_io_60us
	RETURN

	; Read byte 4, stored in 0xA8, value = CONFIGURATION REGISTER (EEPROM)
    read_byte_4:
	MOVLW	    8
	MOVWF	    0xAD	    
	MOVLW	    0
	MOVWF	    0xA8	   
	CALL	    read_bit
	CALL		bit_sample_byte_4
	DECFSZ	    0xAD, F
	GOTO	    $-3
	RETURN
	
    bit_sample_byte_4:
	BTFSS	    TRISB, 1
	GOTO	    $+3		    
	BSF			0XA8, 7
	RRF	    	0XA8, F
	BCF	    	0XA8, 7
	RRF	    	0XA8, F
	CALL		delay_io_60us	
	RETURN

	; Read byte 5, stored in 0xA9, value = RESERVED 
    read_byte_5:
	MOVLW	    8
	MOVWF	    0xAD	    
	MOVLW	    0
	MOVWF	    0xA9	   
	CALL	    read_bit
	CALL		bit_sample_byte_5
	DECFSZ	    0xAD, F
	GOTO	    $-3
	RETURN

    bit_sample_byte_5:
	BTFSS	    TRISB, 1	    
	GOTO	    $+3		    
	BSF			0XA9, 7	    	
	RRF	    	0XA9, F
	BCF	    	0XA9, 7	    	
	RRF	    	0XA9, F
	CALL		delay_io_60us	
	RETURN

	; Read byte 6, stored in 0xAA, value = RESERVED
    read_byte_6:
	MOVLW	    8
	MOVWF	    0xAD	    
	MOVLW	    0
	MOVWF	    0xAA	   
	CALL	    read_bit
	CALL		bit_sample_byte_7
	DECFSZ	    0xAD, F
	GOTO	    $-3
	RETURN

    bit_sample_byte_6:
	BTFSS	    TRISB, 1
	GOTO	    $+3		    
	BSF			0XA4, 7
	RRF	    	0XA4, F
	BCF	    	0XA4, 7
	RRF	    	0XA4, F
	CALL		delay_io_60us	
	RETURN

	; Read byte 7, stored in 0xAB, value = RESERVED
    read_byte_7:
	MOVLW	    8
	MOVWF	    0xAD	    
	MOVLW	    0
	MOVWF	    0xAB	   
	CALL	    read_bit
	CALL		bit_sample_byte_8
	DECFSZ	    0xAD, F
	GOTO	    $-3
	RETURN

    bit_sample_byte_7:
	BTFSS	    TRISB, 1
	GOTO	    $+3		    
	BSF			0XAB, 7
	RRF	    	0XAB, F
	BCF	    	0XAB, 7
	RRF	    	0XAB, F
	CALL		delay_io_60us	
	RETURN

	; Read byte 8, stored in 0xAC, value = CRC
    read_byte_8:
	MOVLW	    8
	MOVWF	    0xAD	    
	MOVLW	    0
	MOVWF	    0xAC	   
	CALL	    read_bit
	CALL		bit_sample_byte_8
	DECFSZ	    0xAD, F
	GOTO	    $-3
	RETURN
    
    bit_sample_byte_8:
	BTFSS	    TRISB, 1
	GOTO	    $+3		    
	BSF			0XAC, 7
	RRF	    	0XAC, F
	BCF	    	0XAC, 7	    	
	RRF	    	0XAC, F
	CALL		delay_io_60us
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
	BSF	    	TRISB, 2
	; Initialize the SPBRG register for the appropriate baud rate
	BANKSEL	    TXSTA
	BCF	    	TXSTA, 2	; BRGH = 0 (low speed baud rate)
	BCF	    	TXSTA, 4	; Clear bit SYNC to enable serial port
	MOVLW	    32			; SPBRG = 32 for 20 MHz, 25 for 16 MHz
	BANKSEL	    SPBRG
	MOVWF	    SPBRG		; Initialize SPBRG reg for the baud rate
	; Enable the async serial port
	BANKSEL	    RCSTA		; Select Bank 0
	BSF	    	RCSTA, 7	; Set bit SPEN to enable serial port
	; Enable the transmissionOne
	BANKSEL	    TXSTA
	BSF	    	TXSTA, 5	; Set bit TXEN to enable transmission
	; Start transmission
	CALL	    load
	RETURN

    ; Load data to the TXREG register and start transmission
    load:
	MOVF	    0xA4, W		; Current byte read from the sensor
	CALL	    tx
	MOVLW	    0X0D		; CR
	CALL	    tx
	MOVLW	    0x0A		; LF
	CALL	    tx
	RETURN

    ; Transmit a byte
    tx:
	BANKSEL	    TXSTA		; Select Bank 1
	BTFSS	    TXSTA, 1	; Test if if TSR is empty
	GOTO	    $-1			; Continue checking until success
	BANKSEL	    TXREG
	MOVWF	    TXREG
	RETURN

    ; Decode the two byte read from the temperature register
    ; 0xB0 - int part
    extract_temp:
	; Extract <7:4> from LS byte and <3:0> from MS byte to form the int part
	BANKSEL	    0xA4
	RRF	    	0xA4, W		; W = LS_temp >> 1
	RRF	    	0xA4, W		; W = LS_temp >> 1
	RRF	    	0xA4, W		; W = LS_temp >> 1
	RRF	    	0xA4, W		; W = LS_temp >> 1
	CLRF	    0xB0		; int_part = 0
	MOVWF	    0xB0		; int_part = W
	  
	RLF	    	0xA5, W		; W = MS_temp << 1
	RLF	    	0xA5, W		; W = MS_temp << 1
	RLF	    	0xA5, W		; W = MS_temp << 1
	RLF	    	0xA5, W		; W = MS_temp << 1
	IORWF	    0xB0, F		; int_part |= W
	BTFSS		STATUS, 2	; if (C == 1) skip
	GOTO		$-2

	CALL		get_ones_place
	CALL		get_tens_place

	// Convert the placements to ASCII 
	CALL		compute_table
	
	// Start from 0xD0 (0000) to 0xD9 (1001) and check for equality using XOR
	// 0xB6
	// 0xB7
	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD0
	CALL		compare
	MOVWF		0xB7
	DECFSZ		0xB7, F
	GOTO		$+2
	CALL		load

	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD1
	CALL		compare
	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD1
	CALL		compare
	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD1
	CALL		compare
	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD1
	CALL		compare
	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD1
	CALL		compare
	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD1
	CALL		compare
	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD1
	CALL		compare
	MOVF		0xB5
	MOVWF		0xB6
	MOVF		0xD1
	CALL		compare
	
	compare:
	XORWF		0xB6, F		; 0xB6 = 0xB6 ^ W
	BTFSS		0xB6, 0
	GOTO		$+2
	RETLW		0			; Return with 0 in W, indicating a dismatch
	BTFSS		0xB6, 1
	GOTO		$+2
	RETLW		0
	BTFSS		0xB6, 2
	GOTO		$+2
	RETLW		0
	BTFSS		0xB6, 3
	GOTO		$+2
	RETLW		0
	RETLW		1			; Return with 1 in W, indicating XOR resulted 0000. A match is found 

	; 0xB2 has ones place	
	get_ones_place:
	MOVF		0xB0, W		; W = 0xB0
	MOVWF		0xB1		; 0xB1 = 0xB0
	MOVLW		10			; W = 10

	SUBWF		0xB1, F		; 0xB1 -= W
	BTFSC		STATUS, 0
	GOTO		$+3			; Jump to check if Z == 0
	ADDWF		0xB1, F		; if (0xB1 < 0) 0xB1 += 10
	RETURN

	BTFSS		STATUS, 2
	GOTO		$-6			; if (0xB1 > 0) continue minus 10
	MOVLW		0			; if (0xB1 == 0) return 0 
	MOVWF		0xB2
	RETURN

	; 0xB4 has 0xB0 // 10
	; 0xB5 has tens place
	get_tens_place:
	MOVF		0xB0, W		; W = 0xB0
	MOVWF		0xB3		; 0xB3 = 0xB0
	CLRF		0xB4		; 0xB4 = 0 = Quotient
	MOVLW		10	

	SUBWF		0xB3, F		; 0xB3 -= 10
	BTFSS		STATUS, 0
	GOTO		$+3
	INCF		0xB4, F		; 0xB4 += 1 if 0xB3 - 10 >= 0
	GOTO		$-4
	MOVF		0xB4, W		; W = 0xB4 = 12
	MOVWF		0xB5		; 0xB5 = W = 12
	MOVLW		10			; W = 10

	SUBWF		0xB5, F		; 0xB5 -= W
	BTFSC		STATUS, 0
	GOTO		$+3			; Jump to check if Z == 0
	ADDWF		0xB5, F		; if (0xB5 < 0) 0xB5 += 10	
	RETURN

	BTFSS		STATUS, 2
	GOTO		$-6			; if (0xB5 > 0) continue minus 10
	MOVLW		0			; if (0xB5 == 0)
	MOVWF		0xB5		; 0xB5 = 0
	RETURN
			
    ; Preload the digit table	
    ; 0xD0 - zero
    ; 0xD1 - one
    ; ...
    ; 0xD9 - nine
    compute_table:
	MOVLW		0			; W = 0
	MOVWF	    0xD0		; 0xD0: 0x00
	ADDLW	    1		 
	MOVWF	    0xD1		
	ADDLW	    1		
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
	ADDLW	    1			
	MOVWF	    0xD9		; 0xD9: 0x09
	RETURN
    
	END resetVec

	
