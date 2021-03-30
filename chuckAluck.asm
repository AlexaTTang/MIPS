########################################################################
# Program: chuck (Chuck-A-Luck)				Programmer: Alexa Tang 
# Due Date: Nov 14, 2019					Course: CS2640
########################################################################
# Overall Program Functional Description:
#	The program plays the Chuck-A-Luck game.  The player starts with
#	a purse of $500.  For each round, the player selects a wager, then
#	picks a number from 1 to 6.  The program then rolls three dice.
#	If none of the dice match the chosen number, the player loses the
#	wager.  For each dice that matches the chosen number, the player
#	earns the wager (so, for example, if two dice show the chosen number,
#	the player earns twice the wager).  The program ends when the
#	player enters a wager of 0.
#
########################################################################
# Register usage in Main:
#	$t9 -- maximum number of loops (3)
#	$t7 -- player's holdings (starts with 500)
#	$t6 -- player's wage
# 	$t5	-- player's guess (number between 1-6)
# 	$t4 -- random dice roll (number between 1-6)
# 	$t3 -- number of correct guesses
# 	$t2 -- number of failed guesses
# 	$t1	-- dice roll loop counter
########################################################################
# Pseudocode Description:
#	1. Print a welcome message***************
#	2. Get a value from the user, use it to seed the random number generator 
#	3. Seed the player's holdings with 500.************
#	4. Loop:
#		a. Print their holdings, receive the wager.  If 0, break the loop.****
#		b. Get the chosen number for this round.****
#		c. Looping 3 times:
#			1. Get a random dice roll
#			2. If it matches the chosen number, increment the success counter
#		d. Print a message based on the success counter, and adjust their
#			holdings based on this same counter.
#		e. If the holdings get to 0, print a 'bye' message.
#	5. Clean up, print a 'bye' message, and leave.
#
########################################################################
		.data
wMsg:   	.asciiz "Welcome to Chuck-a-Luck!\n\nEnter a seed number: "
byeMsg: 	.asciiz "\nThank you for playing!"
Plost: 		.asciiz "\n\nYour holdings are empty.\nYou can no longer wager."
numSuccess:	.asciiz "\n\nThe number of successful matches are: "
space: 		.asciiz " "
hold:		.word 500
		.globl main
		.text
main:
		li			$v0, 4 					# Call the Print String I/O Service to print
		la			$a0, wMsg 				# the welcome message
		syscall
		li			$v0, 5 					# Call the Read Integer I/O Service to get the seed number
		syscall 							
		move 		$a0, $v0		 		# move user inputted seed to $a0
		lw 			$t7, hold				# load player holdings in $t7, initializing to 500
		li			$t9, 3					# load the max number of die rolls 
loop:
		move		$a0, $t7				# move player's holdings to a0 for use in getwager function
		jal			getwager				# jump and link to getwager function (wager returns in $v0)
		beqz		$v0, bye				# if wage = 0, then quit game
		move		$t6, $v0				# move wage from $vo to $t6
		jal			getguess				# jump and link to getguess function (getguess() returns in $v0)
		move		$t5, $v0				# move guess from $v0 to $t5
rLoop:	
		jal 		rand					# jump and link to rand function (random dice roll returns in $v0)
		move		$t4, $v0				# move rand dice roll from $v0 into $t4
		move		$a0, $v0
		li			$v0, 1 					# system call to print an integer 
		syscall
		la		    $a0, space				# loading address of string in data 
		li			$v0, 4					# system call for printing a string 
		syscall
		beq			$t5, $t4, incSuccess	# compare player's guess with the random roll if equal then increment success counter
		j			incFailure				# if not equal then increment failure counter
incCount:
		addi		$t1, $t1, 1		 		# increase the number of times loop executed by 1
		beq			$t1, $t9, edthold		# compare the loop counter with max number of rolls (if die is rolled 3x), if equal then jump to edit holdings
		j			rLoop					# if die has not yet been rolled 3x then roll again
edthold:
		beq			$t2, $t9, subW			# if num of failed guesses = # dice rolls, then subtract wage
		blt			$t2, $t9, addW  		# if num of failed guesses < number of times dice is rolled then add wage 
edtCounters:
		li			$v0, 4					# Call the Print String I/O Service to print
		la			$a0, numSuccess			#  message about their sucessful matches
		syscall
		move		$a0, $v1				# Call the Print Integer I/O Service to 
		li			$v0, 1					#   print the value in $t3s
		syscall
		li			$t1, 0					# resetting the dice roll loop counter
		li			$t2, 0					# resetting the failed match counter
		li			$t3, 0					# resettingt the successful match counter
		j   		chkhold					# jump to check if holdings = 0
addW:
		add 		$t7, $t7, $t6			# add wage to holdings, put into holdings $t7
		move		$s0, $t7					# copy hold from t7 to s0	
		addi		$t3, $t3, -1			# decrease succes counter by 1
		bnez		$t3, addW 				# once the success counter is zero then stop adding wage
		j			edtCounters
subW:	
		neg			$t6, $t6				# negate wage to add to holdings
		addu		$t7, $t7, $t6			# add negated wage to holdings and load result into holdings
		j 			edtCounters
chkhold:
		beqz		$t7, broke				# if holdings = 0, quit game	
		j 			loop					# if holdings are not yet zero then begin another round		
incSuccess: 
		addi		$t3, $t3, 1				# increase number of matches by 1
		move		$v1, $t3				# make a copy of success counter to tell player how many successes in one round
		j			incCount				# jump to incCount to increase the loop counter by 1
incFailure:
		addi		$t2, $t2, 1				# increase number of failed guesses by 1	
		jal			incCount				# jump to incCount to increase the loop counter by 1
		
broke:	
		li			$v0, 4 					# Call the Print String I/O Service to print
		la			$a0, Plost 				# the goodbye message
		syscall
		li			$v0, 10 				# system call for exit
		syscall
bye:	
		li			$v0, 4 					# Call the Print String I/O Service to print
		la			$a0, byeMsg 			# the goodbye message
		syscall
		li			$v0, 10 				# system call for exit
		syscall
########################################################################
# Function Name: int getwager(holdings)
########################################################################
# Functional Description:
#	This routine is passed the player's current holdings, and will return
#	the player's wager, or the value 0 if the player wants to quit the
#	program.  It displays the holdings, then prompts for the wager.
#	It then checks to see if the wager is in the proper range.  If so,
#	it returns the wager.  Otherwise, it prints an error message, then
#	tries again.
#
########################################################################
# Register Usage in the Function:
#	$v0, $a0 -- for subroutine linkage and general calculations
#	$t8 -- a temporary register used to store the holdings
#
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Display the current holdings to the player
#	1. Print the prompt, asking for the wager
#	2. Read in the number
#	3. If the number is between 0 and holdings, return with that number
#	4. Otherwise print an error message and loop back to try again.
#
########################################################################
	.data
holdmsg:	.asciiz "\nYou currently have $"
wagermsg:	.asciiz "\nHow much would you like to wager? "
big:	.asciiz "\nThat bet is too big."
negtv:	.asciiz "\nYou can't bet a negative amount."
	.text
getwager:
	move 	$t8, $a0		# Save their holdings in $t8
again:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, holdmsg	#   message about their holdings
	syscall
	move	$a0, $t8		# Call the Print Integer I/O Service to 
	li		$v0, 1			#   print the value
	syscall
	li		$v0, 4			# Call the Print String I/O Service to 
	la		$a0, wagermsg	#  	ask for the wager
	syscall
	li		$v0, 5			# Call the Read Integer I/O Service to
	syscall					#   fetch the wager
	bgt		$v0, $t8, toobig	# If wager > holdings, go to error line
	bltz	$v0, toosmall	# If wager < 0, go to error line
	jr		$ra				# Return with the wager in $v0
toobig:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, big		#   that the wager was too big
	syscall
	j		again			# Jump back to try again
toosmall:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, negtv		#   that the wager was too small
	syscall
	j		again			# Jump back to try again

########################################################################
# Function Name: int getguess()
########################################################################
# Functional Description:
#	This routine asks the player to enter the chosen number, which
#	should be between 1 and 6.  If the value is out-of-range, the
#	routine will print a message and ask again, repeating until we
#	get a valid number.
#
########################################################################
# Register Usage in the Function:
#	$v0, #a0 -- for subroutine linkage and general calculations
#	$t0 -- a temporary register used in the calculations
#
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Print the prompt, asking for the chosen number
#	2. Read in the number
#	3. If the number is between 1 and 6, return with that number
#	4. Otherwise print an error message and loop back to try again.
#
########################################################################
	.data
dice:	.asciiz "\nWhat number do you want to bet on? "
limit:	.asciiz "\nThe number has to be between 1 and 6."
	.text
getguess:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, dice		#   request for their chosen number
	syscall
	li		$v0, 5			# Call the Read Integer I/O Service to get
	syscall					#   the number from the player
	blez	$v0, bad		# If the number is negative, it is bad
	li		$a0, 6			# If the number is greater than 6, it is bad
	bgt		$v0, $a0, bad
	jr		$ra				# Return with the valid number in $v0
bad:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, limit		#   that the number is out-of-bounds
	syscall
	j		getguess		# Loop back to try again

########################################################################
# Function Name: int rand()
########################################################################
# Functional Description:
#	This routine generates a pseudorandom number using the xorsum
#	algorithm.  It depends on a non-zero value being in the 'seed'
#	location, which can be set by a prior call to seedrand.  This
#	version of the routine always returns a value between 1 and 6.
#
########################################################################
# Register Usage in the Function:
#	$t0 -- a temporary register used in the calculations
#	$v0 -- the register used to hold the return value
#
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Fetch the current seed value into $v0
#	2. Perform these calculations:
#		$v0 ^= $v0 << 13
#		$v0 ^= $v0 >> 17
#		$v0 ^= $v0 << 5
#	3. Save the resulting value back into the seed.
#	4. Mask the number, then get the modulus (remainder) dividing by 6.
#	5. Add 1, so the value ranges from 1 to 6
#
########################################################################
		.data
seed:	.word 31415			# An initial value, in case seedrand wasn't called
		.text
rand:
	lw		$v0, seed		# Fetch the seed value
	sll		$t0, $v0, 13	# Compute $v0 ^= $v0 << 13
	xor		$v0, $v0, $t0
	srl		$t0, $v0, 17	# Compute $v0 ^= $v0 >> 17
	xor		$v0, $v0, $t0
	sll		$t0, $v0, 5		# Compute $v0 ^= $v0 << 5
	xor		$v0, $v0, $t0
	sw		$v0, seed		# Save result as next seed
	andi	$v0, $v0, 0xFFFF	# Mask the number (so we know its positive)
	li		$t0, 6			# Get result mod 6, plus 1.  We get a 6 into
	div		$v0, $t0		# $t0, then do a divide.  The reminder will be
	mfhi	$v0				# in the special register, HI.  Move to $v0.
	add		$v0, $v0, 1		# Increment the value, so it goes from 1 to 6.
	jr		$ra				# Return the number in $v0
	
########################################################################
# Function Name: seedrand(int)
########################################################################
# Functional Description:
#	This routine sets the seed for the random number generator.  The
#	seed is the number passed into the routine.
#
########################################################################
# Register Usage in the Function:
#	$a0 -- the seed value being passed to the routine
#
########################################################################
seedrand:
	sw $a0, seed
	jr $ra
