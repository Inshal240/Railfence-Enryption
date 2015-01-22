.data

railfence: 	.space 		1096
message: 	.asciiz		"Defend the east coast"
encrypted:	.space		128
decrypted:	.space		128

.code

main:

	

# Encrypts given message using the railfence algorithm
#
# Args: 	Base address of the string to be encrypted in $a0
#			Encryption key (number of rows) in $a1
#			Return address to be present on top of stack
#
# Return:	Base address of encrypted message in $v0
#
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

mov $s0, $a0		# Move the base address to a different register
mov 