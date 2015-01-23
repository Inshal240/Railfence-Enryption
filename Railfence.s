.data

railfence: 	.space 		1096
message: 	.asciiz		"Defend the east coast"
encrypted:	.space		128
decrypted:	.space		128

.text

main:

	la 		$a0, message
	jal 	len


# Use to calculate the length of a string
#
# Args:		Base address of a null terminated string to be encrypted in $a0
# 			Return address to be present in return register
# Return: 	Length of the string in $v0

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

#	Consider the following example with a 9 character string
#	and key 5. What I want you to note is the space between
#	characters in the same row.
#
#	X . . . . . . . X		7
#	. X . . . . . X .		5
#	. . X . . . X . .		3
#	. . . X . X . . .		1
#	. . . . X . . . .		-
#
#	What's interesting is that the spacing increases like this
#	creating a series of odd numbers.
#
#	We know the formula for odd numbers using integers is 2N-1
#	where N is our key. But you'll notice if we plug in the key
#	in the formula we won't get the correct spacing. Instead it
#	gives us the spacing for the NEXT key. This can be easily
#	sovled by changing the formula to 2N-3. Now we'll get the
#	correct spacing for all values of the key.
#
#	Register Information:
#	$s0		base address of the message
#	$s1		length of message
#	$t0		encryption key
#	$t1		current offset to base address
	
	# Call for length function
	addi 	$sp, $sp -4				# Decrement stack pointer to make space
	sw		$31, 0($sp)				# Store address in the stack
	jal 	len 					# Call function
	
	move 	$s0, $a0				# Move the base address to a different register