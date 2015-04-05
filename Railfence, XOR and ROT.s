.data

prompt_string: 		.asciiz		"Please enter string: "
prompt_xor_ekey:	.asciiz		"Enter XOR encryption key: "
prompt_rail_ekey:	.asciiz		"Enter Railfence encryption key: "
prompt_xor_dkey:	.asciiz		"Enter XOR decryption key: "
prompt_rail_dkey:	.asciiz		"Enter Railfence decryption key: "

rail_encrypt_msg:	.asciiz		"Railfence Encryption: "
rail_decrypt_msg:	.asciiz		"Railfence Decryption: "
rot_encrypt_msg:	.asciiz		"ROT Encryption: "
rot_decrypt_msg:	.asciiz		"ROT Decryption: "
xor_encrypt_msg:	.asciiz		"XOR Encryption: "
xor_decrypt_msg:	.asciiz		"XOR Decryption: "

message: 	.asciiz		"Defend the east coast"

linefeed: 	.asciiz		"\n"
;message: 	.space		128
encrypted:	.space		128
decrypted:	.space		128

xor_ekey: 	.word		4
rail_ekey: 	.word		5
xor_dkey: 	.word		4
rail_dkey: 	.word		5

;
; Memory Mapped I/O area
;
; Address of CONTROL and DATA registers
;
; Set CONTROL = 1, Set DATA to Unsigned Integer to be output
; Set CONTROL = 2, Set DATA to Signed Integer to be output
; Set CONTROL = 3, Set DATA to Floating Point to be output
; Set CONTROL = 4, Set DATA to address of string to be output
; Set CONTROL = 5, Set DATA+5 to x coordinate, DATA+4 to y coordinate, and DATA to RGB colour to be output
; Set CONTROL = 6, Clears the terminal screen
; Set CONTROL = 7, Clears the graphics screen
; Set CONTROL = 8, read the DATA (either an integer or a floating-point) from the keyboard
; Set CONTROL = 9, read one byte from DATA, no character echo.
;


CONTROL: .word32 0x10000
DATA:    .word32 0x10008

.text

main:
	
	lwu r22,DATA(r0)		; $t8 = address of DATA register
	lwu r23,CONTROL(r0)		; $t9 = address of CONTROL register

	; ============ User Inputs ============= ;

	; Print string prompt
	daddi	r4, r0, prompt_string
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	; Get input from user
	;daddi   r4, r0, message				
	;daddi	 r5, r0, 128
	;daddi	 r2, r0, 8
	;syscall

	; Print XOR key prompt
	daddi	r4, r0, prompt_xor_ekey
	sd 		r4, (r22)
	sd 		r9, (r23)

	; Get input from user
	daddi 	r9, r0, 8
    sd 		r9,0(r23)
    ld 		r9,0(r22)
	daddi   r8, r0, xor_ekey
	sw 		r9, 0(r8)

	; Print Railfence key prompt
	daddi	r4, r0, prompt_rail_ekey
	sd 		r4, (r22)
	sd 		r9, (r23)

	; Get input from user
	daddi 	r9, r0, 8
    sd 		r9,0(r23)
    ld 		r9,0(r22)
	daddi   r8, r0, rail_ekey
	sw 		r9, 0(r8)

	; Print linefeed
	daddi	r4, r0, linefeed
	sd 		r4, (r22)
	sd 		r9, (r23)

	; ======== Railfence Encryption ======== ;

	daddi	r4, r0, rail_encrypt_msg
	sd 		r4, (r22)
	sd 		r9, (r23)

	daddi	r4, r0, message
    daddi   r8, r0, rail_ekey
    lw      r5, 0(r8)
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	jal 	encrypt_railfence
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space

	dadd 	r4, r0, r2
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	jal 	printline
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space

	; =========== ROT Encryption =========== ;

	daddi	r4, r0, rot_encrypt_msg
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	daddi	r4, r0, encrypted
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	jal 	ROT_encrypt
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space

	dadd 	r4, r0, r2
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	jal 	printline
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space

	; =========== XOR Encryption =========== ;

	daddi	r4, r0, xor_encrypt_msg
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

    daddi   r4, r0, encrypted
    daddi   r8, r0, xor_ekey
    lw      r5, 0(r8)
    daddi    r29, r29, -4            ; Decrement stack pointer to make space
    sw      r31, 0(r29)             ; Store address in the stack
    jal     XOR_encrypt
    lw      r31, 0(r29)             ; Load address from the stack
    daddi    r29, r29, 4             ; Increment stack pointer to free space

    dadd    r4, r0, r2
    daddi   r29, r29, -4            ; Decrement stack pointer to make space
    sw      r31, 0(r29)             ; Store address in the stack
    jal     printline
    lw      r31, 0(r29)             ; Load address from the stack
    daddi    r29, r29, 4             ; Increment stack pointer to free space

	; ============ User Inputs ============= ;

	; Print  linefeed
    daddi   r4, r0, linefeed
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	; Get xor decryption key
	daddi   r4, r0, prompt_xor_dkey
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	daddi 	r9, r0, 8
    sd 		r9,0(r23)
    ld 		r9,0(r22)
	daddi   r8, r0, xor_dkey
	sw 		r9, 0(r8)

	; Get railfence decryption key
	daddi   r4, r0, prompt_rail_dkey
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	daddi 	r9, r0, 8
    sd 		r9,0(r23)
    ld 		r9,0(r22)
	daddi   r8, r0, rail_dkey
	sw 		r9, 0(r8)

	; Print  linefeed
	daddi   r4, r0, linefeed
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	; =========== XOR Decryption =========== ;

	daddi   r4, r0, xor_decrypt_msg
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

    daddi   r4, r0, encrypted
    daddi   r8, r0, xor_ekey
    lw      r5, 0(r8)
    daddi    r29, r29, -4            ; Decrement stack pointer to make space
    sw      r31, 0(r29)             ; Store address in the stack
    jal     XOR_decrypt
    lw      r31, 0(r29)             ; Load address from the stack
    daddi    r29, r29, 4             ; Increment stack pointer to free space
    
    dadd    r4, r0, r2
    daddi    r29, r29, -4            ; Decrement stack pointer to make space
    sw      r31, 0(r29)             ; Store address in the stack
    jal     printline
    lw      r31, 0(r29)             ; Load address from the stack
    daddi    r29, r29, 4

	; =========== ROT Decryption =========== ;

	daddi   r4, r0, rot_decrypt_msg
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	daddi   r4, r0, encrypted
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	jal 	ROT_decrypt
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space
	
	dadd 	r4, r2
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	jal 	printline
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4

    ; ======== Railfence Decryption ======== ;
	
	daddi   r4, r0, rail_decrypt_msg
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)
	
    daddi   r4, r0, encrypted
    daddi   r8, r0, rail_dkey
    lw      r5, 0(r8)
    daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	jal 	decrypt_railfence
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space

	dadd 	r4, r0, r2
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	jal 	printline
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4

	jr 		r31


; ========================================================================================================= ;
; ============================================= Helper Functions ========================================== ;
; ========================================================================================================= ;

; Prints intput string with a linefeed
;
; Args: 	Base address of string to be printed in r4
;
; Regs:		r4, r2

printline:
	
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	daddi   r4, r0, linefeed
	daddi 	r9, r0, 4
	sd 		r4, (r22)
	sd 		r9, (r23)

	jr 		r31

; Use to calculate the length of a string
;
; Args:		Base address of a null terminated string to be encrypted in r4
; 			Return address to be present in return register
; Return: 	Length of the string in r2
;
; Regs:		Only uses the temporary registers r8, r9, r10

len:
	
	daddi 		r8, r0, 0						; t0 shall hold the length
	
	len_loop:

		dadd 	r9, r4, r8 			; t1 shall hold the new address after adding the offset.
		lb		r10, 0(r9)				; load next character
		beq		r10, r0, len_return		; If it is null, go to return label
		daddi 	r8, r8, 1 			; incrememnt the length variable
		j		len_loop


	len_return:
		dadd 	r2, r0, r8				; Place the length into the register
		jr		r31						; Jump to the value of the register



; ========================================================================================================= ;
; ============================================== RAILFENCE ENCRYPTION ===================================== ;
; ========================================================================================================= ;

; Encrypts given message using the railfence algorithm
;
; Args: 	Base address of the string to be encrypted in r4
;			Encryption key (number of rows) in r5
;			Return address to be present in return register
;
; Return:	Base address of encrypted message in r2

encrypt_railfence:

;	Consider the following example with a 17 character string
;	and key 5. What I want you to note is the space between
;	characters in the same row.
;
;	X . . . . . . . X . . . . . . . X		8 - 8
;	. X . . . . . X . X . . . . . X .		6 - 2
;	. . X . . . X . . . X . . . X . .		4 - 4
;	. . . X . X . . . . . X . X . . .		2 - 6
;	. . . . X . . . . . . . X . . . .		8 - 8
;
;	What's interesting is that the spacing increases like this
;	creating a series of even numbers.
;
;	We know the formula for even numbers using integers is 2N
;	where N is our key. But you'll notice if we plug in the key
;	in the formula we won't get the correct spacing. Instead it
;	gives us the spacing for the NEXT key. This can be easily
;	sovled by changing the formula to 2N-2. Now we'll get the
;	correct spacing for all values of the key.
;
;	Register Information:
;	r16		base address of the message
;	r17		length of message
;	r18		current address of the encrypted message
;	r8		encryption key
;	r9		current address (calculated result)
;	r10		offset of the starting character
;	r11		current offset between elements
;	r12 	accumulation of all offsets
;	r13		max offset
;	r14		temporary calculations
;	r15		temporary calculations
; 	r24		current row number (for first = 1, for last = key)
	
	dadd 	r16, r0, r4				; move the base address to a different register
	daddi 	r18, r0, encrypted			; Load address of the reserved memory location

	; Call for length function
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r5, 0(r29)				; Store encryption key in the stack
	jal 	len 					; Call function
	
	; Restore jump address
	lw		r8, 0(r29)				; Load the encryption key from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space
	
	; Store the length in the register
	dadd 	r17, r0, r2
	daddi 	r17, r17, -1 			; decrememnt the length variable

	; Clear temporary registers
	daddi 		r9,  r0, 0
	daddi 		r10, r0, 0
	daddi 		r11, r0, 0
	daddi 		r12, r0, 0
	daddi 		r13, r0, 0

	daddi 		r24, r0, 1 					; first row

	; Caluclate the max offset 2*(key - 1)
	daddi 	r13, r8, -1 			; key - 1
	daddi 	r14, r00,  2 			; 2
	dmul 	r13, r13, r14 			; 2*(key - 1)
	daddi 	r14, r00,  0 			; clear r14 register

	; Load address of first character into r9
	dadd 	r9, r0, r16

	; The first offset will always be the max offset calculated
	dadd 	r11, r0, r13

	; Encryption of one section of the message
	encrypt_railfence_row:

		; If the accumulation of the offsets is greater than the
		; length of the string, then we're done for this row.
		; If accumulation is not less than the total length then branch
		slt 	r14, r12, r17
		daddi 	r15, r0, 1	
		bne 	r14, r15, encrypt_railfence_done
		
		; Fetch character from message
		lb		r14, 0(r9)

		; Append the character to the encryption
		sb		r14, 0(r18)
		daddi 	r18, r18, 1 			; increment address for next byte

		; Calulate offset for next character
		
		; Case for last row
		beq		r11, r13, encrypt_railfence_after_cond 	; current offset == max offset
		dsub		r11, r13, r11			; current offset = max offset - current offset
			
		; After if-else condition
		encrypt_railfence_after_cond:
		dadd 	r9, r9, r11			; dadd current offset to current address

		dadd 	r12, r12, r11			; dadd the offset to the offset accumulation

		; Go back to start of the loop
		j 		encrypt_railfence_row

	encrypt_railfence_done:

		; Check to see if it was the last row
		beq 	r24, r8, encrypt_railfence_last_row

		; Increment the starting character offset
		daddi 	r10, r10, 1
		dadd 	r12, r0, r10 				; initialize the accumulation of offsets with it

		; Reset the message starting address
		dadd 	r9, r16, r10

		; Calculate the next offset ( max offset - 2*(current row - 1) )
		daddi 	r14, r0, 2 					; load 2 into the temp register for mult
		dmul 	r14, r14, r24			; 2 * (current row - 1) (since the register has 
										; not yet been updated for the new row)
		
		daddi 	r24, r24, 1 			; increment row number

		dsub 	r11, r13, r14			; current offset = max offset - 2*(current row - 1)

		bne 	r11, r00, encrypt_railfence_offset_not_zero
		dadd 	r11, r0, r13				; if offset is zero, then we use max offset

		encrypt_railfence_offset_not_zero:
			dsub 	r11, r13, r11			; subtract again so the functin uses the appropriate offset first
			j 		encrypt_railfence_row

		encrypt_railfence_last_row:
			sb		r00, 0(r18)				; dadd null character to the end of string
			daddi  	r2, r0, encrypted			; return the starting address of the enrypted message
			jr 		r31 					; exit function

			
; Decrypt given encrypted message using the railfence algorithm
;
; Args: 	Base address of the string to be decrypted in r4
;			Decryption key (number of rows) in r5
;			Return address to be present in return register
;
; Return:	Base address of decrypted message in r2

decrypt_railfence:

;	Register Information:
;	r16		base address of the decrypted message
;	r17		length of message
;	r18		current address of the encrypted message
;	r8		decryption key
;	r9		current address (calculated result)
;	r10		offset of the starting character
;	r11		current offset between elements
;	r12 	accumulation of all offsets
;	r13		max offset
;	r14		temporary calculations
;	r15		temporary calculations
; 	r24		current row number (for first = 1, for last = key)

	dadd 	r18, r0, r4				; move the base address to a different register
	daddi 	r16, r0, decrypted			; Load address of the reserved memory location

	; Call for length function
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r31, 0(r29)				; Store address in the stack
	daddi 	r29, r29, -4			; Decrement stack pointer to make space
	sw		r5, 0(r29)				; Store decryption key in the stack
	jal 	len 					; Call function
	
	; Restore jump address
	lw		r8, 0(r29)				; Load the decryption key from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space
	lw		r31, 0(r29)				; Load address from the stack
	daddi 	r29, r29, 4				; Increment stack pointer to free space
	
	; Store the length in the register
	dadd 	r17, r0, r2

	; Clear temporary registers
	daddi 		r9, r0, 0
	daddi 		r10,r0, 0
	daddi 		r11,r0, 0
	daddi 		r12,r0, 0
	daddi 		r13,r0, 0

	daddi 		r24,r0, 1 					; first row

	; Caluclate the max offset 2*(key - 1)
	daddi 	r13, r8, -1 			; key - 1
	daddi 	r14, r00,  2 			; 2
	dmul 	r13, r13, r14 			; 2*(key - 1)
	daddi 	r14, r00,  0 			; clear r14 register

	; Load address of first character into r9
	dadd 	r9, r0, r16

	; The first offset will always be the max offset calculated
	dadd 	r11, r0, r13

	; Decryption of one section of the message
	decrypt_railfence_row:

		; If the accumulation of the offsets is greater than the
		; length of the string, then we're done for this row.
		; If accumulation is not less than the total length then branch
		slt 	r14, r12, r17
		daddi 	r15, r0, 1
		bne 	r14, r15, decrypt_railfence_done
		
		; Fetch character from message
		lb		r14, 0(r18)
		daddi 	r18, r18, 1 			; increment address for next byte

		; Append the character to the decryption
		sb		r14, 0(r9)
		
		; Calulate offset for next character
		
		; Case for last row
		beq		r11, r13, decrypt_railfence_after_cond 	; current offset == max offset
		dsub	r11, r13, r11			; current offset = max offset - current offset
			
		; After if-else condition
		decrypt_railfence_after_cond:
		dadd 	r9, r9, r11			; dadd current offset to current address

		dadd 	r12, r12, r11			; dadd the offset to the offset accumulation

		; Go back to start of the loop
		j 	decrypt_railfence_row

	decrypt_railfence_done:

		; Check to see if it was the last row
		beq 	r24, r8, decrypt_railfence_last_row

		; Increment the starting character offset
		daddi 	r10, r10, 1
		dadd 	r12, r0, r10 				; initialize the accumulation of offsets with it

		; Reset the message starting address
		dadd 	r9, r16, r10

		; Calculate the next offset ( max offset - 2*(current row - 1) )
		daddi 	r14, r0, 2 					; load 2 into the temp register for mult
		dmul 	r14, r14, r24			; 2 * (current row - 1) (since the register has 
										; not yet been updated for the new row)
		
		daddi 	r24, r24, 1 			; increment row number

		dsub 	r11, r13, r14			; current offset = max offset - 2*(current row - 1)

		bne 	r11, r00, decrypt_railfence_offset_not_zero
		dadd 	r11, r0, r13				; if offset is zero, then we use max offset

		
		decrypt_railfence_offset_not_zero:
			dsub 	r11, r13, r11			; subtract again so the functin uses the appropriate offset first
			j 		decrypt_railfence_row

		decrypt_railfence_last_row:
			sb		r00, 0(r18)				; dadd null character to the end of string
			dadd	r2, r0, r16	 			; return the starting address of the enrypted message
			jr 		r31 					; exit function

; ========================================================================================================= ;
; ========================================== ROT Encryption =============================================== ;
; ========================================================================================================= ;

ROT_encrypt:

			; Loop over all characters
    		dadd    r9, r0, r4    			;r9:the current address that gets modified
    		daddi	r10, r0, 0

rot_en1:	lb  	r8, (r9)  				;r8: the current value (char)
    		beq 	r8, r10, out     			; while `r9 != '\n'
    		daddi 	r11, r0, 64
    		bge 	r11, r8, rot_en2       	; if `r8 <= 64: jump to rot_en2
    		daddi 	r11, r0, 123
    		bge 	r8, r11, rot_en2       	; if `r8 >= 123: jump to rot_en2
    		daddi 	r11, r0, 90
    		bge 	r11, r8, big     			; if `r8 <= 90: jump to big
    		daddi 	r11, r0, 96
    		bge 	r11, r8, rot_en2       	; if `r8 <= 96: jump to rot_en2
    		daddi 	r11, r0, 122
    		bge 	r11, r8, small    			; if `r8 <= 122: jump to small


rot_en2:	daddi 	r9, r9, 1  				; r9++
    		j rot_en1                			; endwhile 

small:
    		daddi    r8, -84   					; -97 + 13
    		rem     r8, r8, 26 				; $`t0 %= 26
    		daddi    r8, 97
    		sb      r8, (r9)
    		j rot_en2

big:
    		daddi    r8, -52   					; -65 + 13
    		rem     r8, r8, 26 				; `r8 %= 26
    		daddi    r8, 65
    		sb      r8, (r9)
    		j rot_en2

out:
			daddi	r2, r0, encrypted
			jr		r31


ROT_decrypt:

    		; Loop over all characters
    		dadd    r9, r0, r4    			;r9:the current address that gets modified
    		daddi 	r10, r0, 0

rot_de1:	lb  	r8, (r9)  				;t0: the current value (char)
    		beq 	r8, r10, out1     			; while `r9 != '\n'
    		daddi 	r11, r0, 64
    		bge 	r11, r8, rot_de2       	; if `r8 <= 64: jump to rot_de2
    		daddi 	r11, r0, 123
    		bge 	r8, r11, rot_de2       	; if `r8 >= 123: jump to rot_de2
    		daddi 	r11, r0, 90
    		bge 	r11, r8, big1 				; if `r8 <= 90: jump to big
    		daddi	r11, r0, 96
    		bge 	r11, r8, rot_de2       	; if `r8 <= 96: jump to rot_de2
    		j small1


rot_de2:	daddi 	r9, r9, 1  				; r9++
    		j rot_de1                			; /endwhile 

small1:
    		daddi    r8, -84   					; -97 + 13
    		rem     r8, r8, 26 				; $`t0 %= 26
    		daddi    r8, 97
    		sb      r8, (r9)
    		j rot_de2

big1:
    		daddi    r8, -52   					; -65 + 13
    		rem     r8, r8, 26 				; `r8 %= 26
    		daddi    r8, 65
    		sb      r8, (r9)
    		j rot_de2

out1:
    		daddi	r2, r0, encrypted
    		jr      r31


XOR_encrypt:

    daddi   r10, r0, 0                 ; Stop by \n
    dadd    r9, r0, r4
    dadd    r20, r0, r5

    ; Loop over all characters

en1:
    lb      r8, (r9)  			;$`t0: the current value (char)
    beq     r8, r10, ot     		; while `r9 != '\n'
    daddi   r11, r0, 122
    bge     r11,r8,en2    			; jump to en2

en2:
    xor     r8, r8, r20
    sb      r8, (r9)
    daddi    r9, r9, 1  			; r9++
    j en1                    		; /endwhile 

ot:
    daddi   r2, r0, encrypted
    jr      r31


XOR_decrypt:

    daddi   r10, r0, 0        		; Stop by \n
    dadd    r9, r0, r4
    dadd    r21, r0, r5

    ; Loop over all characters

de1:
    lb      r8, (r9)  			;r8: the current value (char)
    beq     r8, r10, ot1     		; while `r9 != '\n'
    daddi   r11, r0, 122
    bge     r11, r8, de2  			; jump to de2

de2:
    xor     r8, r8, r21
    sb      r8, (r9)
    daddi   r9, r9, 1  			; r9++
    j de1                           ; /endwhile  

ot1:
    daddi   r2, r0, encrypted
    jr      r31
