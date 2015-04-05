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

#test: 	.asciiz		"Defend the east coast"

linefeed: 	.asciiz		"\n"
message: 	.space		128
encrypted:	.space		128
decrypted:	.space		128

xor_ekey: 	.word		4
rail_ekey: 	.word		5
xor_dkey: 	.word		4
rail_dkey: 	.word		5

.text

main:

	# ============ User Inputs ============= #

	# Print string prompt
	la 		$a0, prompt_string
	li 		$v0, 4
	syscall

	# Get input from user
	la 		$a0, message				
	la 		$a1, 128
	li 		$v0, 8
	syscall

	# Print XOR key prompt
	la 		$a0, prompt_xor_ekey
	li 		$v0, 4
	syscall

	# Get input from user
	li 		$v0, 5
	syscall
	la 		$t0, xor_ekey
	sw 		$v0, 0($t0)

	# Print Railfence key prompt
	la 		$a0, prompt_rail_ekey
	li 		$v0, 4
	syscall

	# Get input from user
	li 		$v0, 5
	syscall
	la 		$t0, rail_ekey
	sw 		$v0, 0($t0)

	# Print linefeed
	la 		$a0, linefeed
	li 		$v0, 4
	syscall

	# ======== Railfence Encryption ======== #

	la 		$a0, rail_encrypt_msg
	li 		$v0, 4
	syscall

	la 		$a0, message
    la      $t0, rail_ekey
    lw      $a1, 0($t0)
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	encrypt_railfence
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space

	move 	$a0, $v0
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	printline
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space

	# =========== ROT Encryption =========== #

	la 		$a0, rot_encrypt_msg
	li 		$v0, 4
	syscall

	la 		$a0, encrypted
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	ROT_encrypt
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space

	move 	$a0, $v0
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	printline
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space

	# =========== XOR Encryption =========== #

	la 		$a0, xor_encrypt_msg
	li 		$v0, 4
	syscall

    la      $a0, encrypted
    la      $t0, xor_ekey
    lw      $a1, 0($t0)
    addi    $sp, $sp, -4            # Decrement stack pointer to make space
    sw      $31, 0($sp)             # Store address in the stack
    jal     XOR_encrypt
    lw      $31, 0($sp)             # Load address from the stack
    addi    $sp, $sp, 4             # Increment stack pointer to free space

    move    $a0, $v0
    addi    $sp, $sp, -4            # Decrement stack pointer to make space
    sw      $31, 0($sp)             # Store address in the stack
    jal     printline
    lw      $31, 0($sp)             # Load address from the stack
    addi    $sp, $sp, 4             # Increment stack pointer to free space

	# ============ User Inputs ============= #

	# Print  linefeed
    la 		$a0, linefeed
	li 		$v0, 4
	syscall

	# Get xor decryption key
	la 		$a0, prompt_xor_dkey
	li 		$v0, 4
	syscall

	li 		$v0, 5
	syscall

	la 		$t0, xor_dkey
	sw 		$v0, 0($t0)

	# Get railfence decryption key
	la 		$a0, prompt_rail_dkey
	li 		$v0, 4
	syscall

	li 		$v0, 5
	syscall
	
	la 		$t0, rail_dkey
	sw 		$v0, 0($t0)

	# Print  linefeed
	la 		$a0, linefeed
	li 		$v0, 4
	syscall

	# =========== XOR Decryption =========== #

	la 		$a0, xor_decrypt_msg
	li 		$v0, 4
	syscall

    la      $a0, encrypted
    la      $t0, xor_ekey
    lw      $a1, 0($t0)
    addi    $sp, $sp, -4            # Decrement stack pointer to make space
    sw      $31, 0($sp)             # Store address in the stack
    jal     XOR_decrypt
    lw      $31, 0($sp)             # Load address from the stack
    addi    $sp, $sp, 4             # Increment stack pointer to free space
    
    move    $a0, $v0
    addi    $sp, $sp, -4            # Decrement stack pointer to make space
    sw      $31, 0($sp)             # Store address in the stack
    jal     printline
    lw      $31, 0($sp)             # Load address from the stack
    addi    $sp, $sp, 4

	# =========== ROT Decryption =========== #

	la 		$a0, rot_decrypt_msg
	li 		$v0, 4
	syscall

	la 		$a0, encrypted
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	ROT_decrypt
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space
	
	move 	$a0, $v0
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	printline
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4

    # ======== Railfence Decryption ======== #
	
	la 		$a0, rail_decrypt_msg
	li 		$v0, 4
	syscall
	
    la      $a0, encrypted
    la      $t0, rail_dkey
    lw      $a1, 0($t0)
    addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	decrypt_railfence
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space

	move 	$a0, $v0
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	printline
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4

	jr 		$31


# ========================================================================================================= #
# ============================================= Helper Functions ========================================== #
# ========================================================================================================= #

# Prints intput string with a linefeed
#
# Args: 	Base address of string to be printed in $a0
#
# Regs:		$a0, $v0

printline:
	
	li 		$v0, 4
	syscall

	la 		$a0, linefeed
	li 		$v0, 4
	syscall

	jr 		$31

# Use to calculate the length of a string
#
# Args:		Base address of a null terminated string to be encrypted in $a0
# 			Return address to be present in return register
# Return: 	Length of the string in $v0
#
# Regs:		Only uses the temporary registers $t0, $t1, $t2

len:
	
	li 		$t0, 0						# t0 shall hold the length
	
	len_loop:

		add 	$t1, $a0, $t0 			# t1 shall hold the new address after adding the offset.
		lb		$t2, 0($t1)				# load next character
		beq		$t2, $0, len_return		# If it is null, go to return label
		addi 	$t0, $t0, 1 			# incrememnt the length variable
		j		len_loop


	len_return:
		move 	$v0, $t0				# Place the length into the register
		jr		$31						# Jump to the value of the register



# ========================================================================================================= #
# ============================================== RAILFENCE ENCRYPTION ===================================== #
# ========================================================================================================= #

# Encrypts given message using the railfence algorithm
#
# Args: 	Base address of the string to be encrypted in $a0
#			Encryption key (number of rows) in $a1
#			Return address to be present in return register
#
# Return:	Base address of encrypted message in $v0

encrypt_railfence:

#	Consider the following example with a 17 character string
#	and key 5. What I want you to note is the space between
#	characters in the same row.
#
#	X . . . . . . . X . . . . . . . X		8 - 8
#	. X . . . . . X . X . . . . . X .		6 - 2
#	. . X . . . X . . . X . . . X . .		4 - 4
#	. . . X . X . . . . . X . X . . .		2 - 6
#	. . . . X . . . . . . . X . . . .		8 - 8
#
#	What's interesting is that the spacing increases like this
#	creating a series of even numbers.
#
#	We know the formula for even numbers using integers is 2N
#	where N is our key. But you'll notice if we plug in the key
#	in the formula we won't get the correct spacing. Instead it
#	gives us the spacing for the NEXT key. This can be easily
#	sovled by changing the formula to 2N-2. Now we'll get the
#	correct spacing for all values of the key.
#
#	Register Information:
#	$s0		base address of the message
#	$s1		length of message
#	$s2		current address of the encrypted message
#	$t0		encryption key
#	$t1		current address (calculated result)
#	$t2		offset of the starting character
#	$t3		current offset between elements
#	$t4 	accumulation of all offsets
#	$t5		max offset
#	$t6		temporary calculations
#	$t7		temporary calculations
# 	$t8		current row number (for first = 1, for last = key)
	
	move 	$s0, $a0				# Move the base address to a different register
	la 		$s2, encrypted			# Load address of the reserved memory location

	# Call for length function
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$a1, 0($sp)				# Store encryption key in the stack
	jal 	len 					# Call function
	
	# Restore jump address
	lw		$t0, 0($sp)				# Load the encryption key from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space
	
	# Store the length in the register
	move 	$s1, $v0
	addi 	$s1, $s1, -1 			# decrememnt the length variable

	# Clear temporary registers
	li 		$t1, 0
	li 		$t2, 0
	li 		$t3, 0
	li 		$t4, 0
	li 		$t5, 0

	li 		$t8, 1 					# first row

	# Caluclate the max offset 2*(key - 1)
	addi 	$t5, $t0, -1 			# key - 1
	addi 	$t6, $00,  2 			# 2
	multu 	$t5, $t6 				# 2*(key - 1)
	mflo	$t5						# fetch multiplication result
	addi 	$t6, $00,  0 			# clear $t6 register

	# Load address of first character into $t1
	move 	$t1, $s0

	# The first offset will always be the max offset calculated
	move 	$t3, $t5

	# Encryption of one section of the message
	encrypt_railfence_row:

		# If the accumulation of the offsets is greater than the
		# length of the string, then we're done for this row.
		# If accumulation is not less than the total length then branch
		slt 	$t6, $t4, $s1
		li 		$t7, 1	
		bne 	$t6, $t7, encrypt_railfence_done
		
		# Fetch character from message
		lb		$t6, 0($t1)

		# Append the character to the encryption
		sb		$t6, 0($s2)
		addi 	$s2, $s2, 1 			# increment address for next byte

		# Calulate offset for next character
		
		# Case for last row
		beq		$t3, $t5, encrypt_railfence_after_cond 	# current offset == max offset
		sub		$t3, $t5, $t3			# current offset = max offset - current offset
			
		# After if-else condition
		encrypt_railfence_after_cond:
		add 	$t1, $t1, $t3			# add current offset to current address

		add 	$t4, $t4, $t3			# add the offset to the offset accumulation

		# Go back to start of the loop
		j 		encrypt_railfence_row

	encrypt_railfence_done:

		# Check to see if it was the last row
		beq 	$t8, $t0, encrypt_railfence_last_row

		# Increment the starting character offset
		addi 	$t2, $t2, 1
		move 	$t4, $t2 				# initialize the accumulation of offsets with it

		# Reset the message starting address
		add 	$t1, $s0, $t2

		# Calculate the next offset ( max offset - 2*(current row - 1) )
		li 	 	$t6, 2 					# load 2 into the temp register for mult
		multu 	$t6, $t8				# 2 * (current row - 1) (since the register has 
										# not yet been updated for the new row)

		mflo 	$t6 					# fetch the multiplication result
		
		addi 	$t8, $t8, 1 			# increment row number

		sub 	$t3, $t5, $t6			# current offset = max offset - 2*(current row - 1)

		bne 	$t3, $00, encrypt_railfence_offset_not_zero
		move 	$t3, $t5				# if offset is zero, then we use max offset

		encrypt_railfence_offset_not_zero:
			sub 	$t3, $t5, $t3			# subtract again so the functin uses the appropriate offset first
			j 		encrypt_railfence_row

		encrypt_railfence_last_row:
			sb		$00, 0($s2)				# add null character to the end of string
			la  	$v0, encrypted			# return the starting address of the enrypted message
			jr 		$31 					# exit function

			
# Decrypt given encrypted message using the railfence algorithm
#
# Args: 	Base address of the string to be decrypted in $a0
#			Decryption key (number of rows) in $a1
#			Return address to be present in return register
#
# Return:	Base address of decrypted message in $v0

decrypt_railfence:

#	Register Information:
#	$s0		base address of the decrypted message
#	$s1		length of message
#	$s2		current address of the encrypted message
#	$t0		decryption key
#	$t1		current address (calculated result)
#	$t2		offset of the starting character
#	$t3		current offset between elements
#	$t4 	accumulation of all offsets
#	$t5		max offset
#	$t6		temporary calculations
#	$t7		temporary calculations
# 	$t8		current row number (for first = 1, for last = key)

	move 	$s2, $a0				# Move the base address to a different register
	la 		$s0, decrypted			# Load address of the reserved memory location

	# Call for length function
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	addi 	$sp, $sp, -4			# Decrement stack pointer to make space
	sw		$a1, 0($sp)				# Store decryption key in the stack
	jal 	len 					# Call function
	
	# Restore jump address
	lw		$t0, 0($sp)				# Load the decryption key from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space
	lw		$31, 0($sp)				# Load address from the stack
	addi 	$sp, $sp, 4				# Increment stack pointer to free space
	
	# Store the length in the register
	move 	$s1, $v0

	# Clear temporary registers
	li 		$t1, 0
	li 		$t2, 0
	li 		$t3, 0
	li 		$t4, 0
	li 		$t5, 0

	li 		$t8, 1 					# first row

	# Caluclate the max offset 2*(key - 1)
	addi 	$t5, $t0, -1 			# key - 1
	addi 	$t6, $00,  2 			# 2
	multu 	$t5, $t6 				# 2*(key - 1)
	mflo	$t5						# fetch multiplication result
	addi 	$t6, $00,  0 			# clear $t6 register

	# Load address of first character into $t1
	move 	$t1, $s0

	# The first offset will always be the max offset calculated
	move 	$t3, $t5

	# Decryption of one section of the message
	decrypt_railfence_row:

		# If the accumulation of the offsets is greater than the
		# length of the string, then we're done for this row.
		# If accumulation is not less than the total length then branch
		slt 	$t6, $t4, $s1
		li 		$t7, 1
		bne 	$t6, $t7, decrypt_railfence_done
		
		# Fetch character from message
		lb		$t6, 0($s2)
		addi 	$s2, $s2, 1 			# increment address for next byte

		# Append the character to the decryption
		sb		$t6, 0($t1)
		
		# Calulate offset for next character
		
		# Case for last row
		beq		$t3, $t5, decrypt_railfence_after_cond 	# current offset == max offset
		sub		$t3, $t5, $t3			# current offset = max offset - current offset
			
		# After if-else condition
		decrypt_railfence_after_cond:
		add 	$t1, $t1, $t3			# add current offset to current address

		add 	$t4, $t4, $t3			# add the offset to the offset accumulation

		# Go back to start of the loop
		j 		decrypt_railfence_row

	decrypt_railfence_done:

		# Check to see if it was the last row
		beq 	$t8, $t0, decrypt_railfence_last_row

		# Increment the starting character offset
		addi 	$t2, $t2, 1
		move 	$t4, $t2 				# initialize the accumulation of offsets with it

		# Reset the message starting address
		add 	$t1, $s0, $t2

		# Calculate the next offset ( max offset - 2*(current row - 1) )
		li 	 	$t6, 2 					# load 2 into the temp register for mult
		multu 	$t6, $t8				# 2 * (current row - 1) (since the register has 
										# not yet been updated for the new row)

		mflo 	$t6 					# fetch the multiplication result
		
		addi 	$t8, $t8, 1 			# increment row number

		sub 	$t3, $t5, $t6			# current offset = max offset - 2*(current row - 1)

		bne 	$t3, $00, decrypt_railfence_offset_not_zero
		move 	$t3, $t5				# if offset is zero, then we use max offset

		
		decrypt_railfence_offset_not_zero:
			sub 	$t3, $t5, $t3			# subtract again so the functin uses the appropriate offset first
			j 		decrypt_railfence_row

		decrypt_railfence_last_row:
			sb		$00, 0($s2)				# add null character to the end of string
			move	$v0, $s0	 			# return the starting address of the enrypted message
			jr 		$31 					# exit function

# ========================================================================================================= #
# ========================================== ROT Encryption =============================================== #
# ========================================================================================================= #

ROT_encrypt:

			# Loop over all characters
    		move    $t1, $a0    			#$t1:the current address that gets modified
    		li 		$t2, 0

rot_en1:	lb  	$t0, ($t1)  				#$t0: the current value (char)
    		beq 	$t0, $t2, out     			# while `$t1 != '\n'
    		li 		$t3, 64
    		bge 	$t3, $t0, rot_en2       	# if `$t0 <= 64: jump to rot_en2
    		li 		$t3, 123
    		bge 	$t0, $t3, rot_en2       	# if `$t0 >= 123: jump to rot_en2
    		li 		$t3, 90
    		bge 	$t3, $t0, big     			# if `$t0 <= 90: jump to big
    		li 		$t3, 96
    		bge 	$t3, $t0, rot_en2       	# if `$t0 <= 96: jump to rot_en2
    		li 		$t3, 122
    		bge 	$t3,$t0, small    			# if `$t0 <= 122: jump to small


rot_en2:	addi 	$t1, $t1, 1  				# $t1++
    		j rot_en1                			# endwhile 

small:
    		addi    $t0, -84   					# -97 + 13
    		rem     $t0, $t0, 26 				# $`t0 %= 26
    		addi    $t0, 97
    		sb      $t0, ($t1)
    		j rot_en2

big:
    		addi    $t0, -52   					# -65 + 13
    		rem     $t0, $t0, 26 				# `$t0 %= 26
    		addi    $t0, 65
    		sb      $t0, ($t1)
    		j rot_en2

out:
			la		$v0, encrypted
			jr		$31


ROT_decrypt:

    		# Loop over all characters
    		move    $t1, $a0    			#$t1:the current address that gets modified
    		li 		$t2, 0

rot_de1:	lb  	$t0, ($t1)  				#t0: the current value (char)
    		beq 	$t0, $t2, out1     			# while `$t1 != '\n'
    		li 		$t3, 64
    		bge 	$t3, $t0, rot_de2       	# if `$t0 <= 64: jump to rot_de2
    		li 		$t3, 123
    		bge 	$t0, $t3, rot_de2       	# if `$t0 >= 123: jump to rot_de2
    		li 		$t3, 90
    		bge 	$t3, $t0, big1 				# if `$t0 <= 90: jump to big
    		li 		$t3, 96
    		bge 	$t3, $t0, rot_de2       	# if `$t0 <= 96: jump to rot_de2
    		j small1


rot_de2:	addi 	$t1, $t1, 1  				# $t1++
    		j rot_de1                			# /endwhile 

small1:
    		addi    $t0, -84   					# -97 + 13
    		rem     $t0, $t0, 26 				# $`t0 %= 26
    		addi    $t0, 97
    		sb      $t0, ($t1)
    		j rot_de2

big1:
    		addi    $t0, -52   					# -65 + 13
    		rem     $t0, $t0, 26 				# `$t0 %= 26
    		addi    $t0, 65
    		sb      $t0, ($t1)
    		j rot_de2

out1:
    		la 		$v0, encrypted
    		jr      $31


XOR_encrypt:

    li      $t2, 0                 # Stop by \n
    move    $t1, $a0
    move    $s4, $a1

    # Loop over all characters

en1:
    lb      $t0, ($t1)  			#$`t0: the current value (char)
    beq     $t0, $t2, ot     		# while `$t1 != '\n'
    li      $t3, 122
    bge     $t3,$t0,en2    			# jump to en2

en2:
    xor     $t0, $t0, $s4
    sb      $t0, ($t1)
    addi    $t1, $t1, 1  			# $t1++
    j en1                    		# /endwhile 

ot:
    la      $v0, encrypted
    jr      $ra


XOR_decrypt:

    li      $t2, 0        		# Stop by \n
    move    $t1, $a0
    move    $s5, $a1

    # Loop over all characters

de1:
    lb      $t0, ($t1)  			#$t0: the current value (char)
    beq     $t0, $t2, ot1     		# while `$t1 != '\n'
    li      $t3, 122
    bge     $t3, $t0, de2  			# jump to de2

de2:
    xor     $t0, $t0, $s5
    sb      $t0, ($t1)
    addi    $t1, $t1, 1  			# $t1++
    j de1                           # /endwhile  

ot1:
    la      $v0, encrypted
    jr      $ra
