.data

railfence: 	.space 		1096
message: 	.asciiz		"Defend the east coast"
encrypted:	.space		128
decrypted:	.space		128

.text

main:

	la 		$a0, message
	li 		$a1, 5
	jal 	encrypt_railfence


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

		# if the accumulation of the offsets is greater than the
		# length of the string, then we're done for this row
		slt 	$t6, $s1, $t4
		bne 	$t6, $00, encrypt_railfence_done

		# Fetch character from message
		lb		$t6, 0($t1)

		# Append the character to the encryption
		sb		$t6, 0($s2)
		addi 	$s2, $s2, 1 			# increment address for next byte

		# Calulate offset for next character
		
		# Case for last row
		beq		$t3, $t5, after_cond 	# current offset == max offset
		sub		$t3, $t5, $t3			# current offset = max offset - current offset
			
		# After if-else condition
		after_cond:
		add 	$t1, $t1, $t3			# add current offset to current address

		add 	$t4, $t4, $t3			# add the offset to the offset accumulation

		# Go back to start of the loop
		j 		encrypt_railfence_row

	encrypt_railfence_done:

		# Check to see if it was the last row
		beq 	$t8, $t0, last_row

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

		bne 	$t3, $00, offset_not_zero
		move 	$t3, $t5				# if offset is zero, then we use max offset

		
		offset_not_zero:
		sub 	$t3, $t5, $t3			# subtract again so the functin uses the appropriate offset first
		j 		encrypt_railfence_row

		last_row:
			sb		$00, 0($s2)				# add null character to the end of string
			la 		$v0, encrypted 			# return the starting address of the enrypted message
			jr 		$31 					# exit function
			






		