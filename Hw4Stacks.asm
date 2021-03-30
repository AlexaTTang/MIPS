########################################################################
# Program: Frequency      		Programmer: Alexa Tang 
# Due Date: December 13, 2019		Course: CS2640
########################################################################
# Overall Program Functional Description:
# The program will read a string from the keyboard and store it in memory. 
# It then counts and prints the number of times each letter (from A to Z) appears in the string. 
# When counting a letter, count both the uppercase and lowercase version. 
# It will not print the cases where the count is zero.
########################################################################
# Register usage in Main:
#  $a1 -- specifying the length of the buffer
#  $a0 -- used for subroutine linkage
#  $s0 -- holding copy of stack pointer 
#  $s1 -- holding a char from user inputted string
#  $v1 -- used to recieve results from subroutines
########################################################################
# Pseudocode Description:
#	1. Prompt user to enter a string
#	2. Read user inputted string onto the stack
#       3. Call the function that calculates the length of string
#       4. Call the function that calculates the frequencies of each
#          letter in user inputted string
#	4. After returning from counting and printing the frequencies,
#          exit program
########################################################################
		.data
prompt:  .asciiz "Please enter a string (max of 55 characters): "
freq1:   .asciiz "Number of "
freq2:   .asciiz "'s: "
tab:     .asciiz "\n"
numChar: .asciiz "the number of chars are: "
end:     .asciiz "\nprogram ended"
	 .globl main
	 .text
main:
        li          $v0, 4                  # Call the Print String I/O Service to print
        la	    $a0, prompt		    # the prompt asking for values for the array
        syscall
        addiu       $sp, $sp, -55           # allocate space on top of the stack
        sw          $ra, 51($sp)            # storing return address on stack
        move        $a0, $sp                # Initialize $a0 as the pointer to the buffer
        li          $a1, 55 	            # $a1 = 55 specify the length of the buffer 
                                                # (50 bytes for characters, 4 for return address, 1 for zero
                                                # $a0 = address of buffer (copied from stack pointer, $sp), $a1 = length of buffer
        li          $v0, 8                  # System call code for Read String 
        syscall      

        move        $s0, $sp                # copy stack pointer  to $s0

        move        $a0, $sp                # copy stack pointer for access in stringLength()
        jal	    stringLength	    # jump to stringLength and save position to $ra

        ##### Calling the frequency function ####
        move        $a0, $sp                # copy stack pointer for access in frequency()
        move        $a1, $v1                # copy the string length for frequency()
        jal	    frequency				# jump to frequency and save position to $ra
        
        ##### Calling the printBackwards function ####
        move        $a0, $sp                # copy stack pointer for access in printBackwards()
        move        $a1, $v1                # copy the string length for printBackwards()
        jal	    printBackwards	    # jump to stringLength and save position to $ra  

exit:
        li          $v0, 4                  # Call the Print String I/O Service to print
        la	    $a0, end		    # the prompt asking for values for the array
        syscall
        li          $v0, 10                 # System call for exit
	syscall                             
########################################################################
# Function Name: int stringLength(int)
########################################################################
# Functional Description:
#	This routine counts the number of characters in the 
#	user inputted string and returns the value
########################################################################
# Register Usage in the Function:
#	$a0 -- for subroutine linkage and general calculations
#	$t0 -- a temporary register used to hold stack pointer
#       $t1 -- temporary counter
#       $t2 -- holding ascii value for new line
#       $t3 -- temp register used to hold current char while parsing stack
#       $v1 -- return value, number of characters in string
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Initialize a character counter, load the value 10, used to 
#          indicate end of the string, and copy the stack pointer 
#	2. Loop through the string 
#               a. Load current character
#               b. Compare with the value 10
#               c. If character is not equal to ten, then increment the 
#                   stack pointer and character counter then loop back
#               d. If the character is equal to ten, jump to done
#	3. Return to main with string length in $v1
########################################################################
        .data
charCounter: .asciiz "Char counter: "
        .text
stringLength: 
        li      $t1,0                   # initialize counter 
        li      $t2, 10                 # used to know when the end of the string is reached, 10 = new line  
        move    $t0, $a0                # copy stack pointer from $a0 to $t0

loop:
        lb      $t3,0($t0)              # loading char into temp register $t3
        beq     $t2, $t3, done          # checking if loop has hit end of string
        addi    $t0,$t0,1               # incrementing the stack counter
        addi    $t1,$t1,1               # incrementing the character counter
        j       loop                    # continue counting character

done: 
        move    $v1, $t1                # copy number of characters from temp register to 
                                        # $v0 to return to main
        jr      $ra                     # return to main
        
########################################################################
# Function Name: void printBackwards(int stack_pointer,  int string_length)
########################################################################
# Functional Description:
#	This function loops through the string letter by letter starting
#	from the end to print the user inputted string out backwards.
#
########################################################################
# Register Usage in the Function:
#	$v0, #a0 -- for subroutine linkage and general calculations
#	$t0 -- a temporary register used to hold stack pointer
#       $t1 -- a temporary register used to hold the string length
#       $t2 -- a temp register used to hold the current character while
#               parsing the stack
# 
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Loading stack pointer and string length into registers
#	2. Adding the length to the pointer to begin at the end of the string
#	3. Loop:
#               a. Load current character from stack
#               b. Print character
#               c. Check if register holding string length equals zero
#                    if not then decrement string length and 
#                    the stack pointer to fetch the next char
#               d. Repeat loop until string length is zero
#	4. Tab to a new line then return to main
#######################################################################
printBackwards: 
        move        $t0, $a0                # copying the stack pointer to a temp register
        move        $t1, $a1                # copying the string length to temp register
        add	    $t0, $t1, $t0	    # $t1 + $t0 = $t0 to start at the end of the string
next:
        lb          $t2, 0($t0)             # loading current character of user inputted string into $t2
        move        $a0, $t2                # move to $a0 to print character
        li          $v0, 11                 # system call to print character
        syscall
        beqz        $t1, return  
        addi        $t1, $t1, -1            # decrementing string length for loop
        addi        $t0, $t0, -1            # decrementing the stack pointer                
        j           next
return: 
        li          $v0, 4                  # Call the Print String I/O Service to print
        la	    $a0, tab	            # the tab
        syscall
        jr	    $ra		            # jump to    $ra and save position to $ra

########################################################################
# Function Name: void frequency(int stack_pointer,  int string_length)
########################################################################
# Functional Description:
#	This function counts the frequency of each character in the 
#	user inputted string and prints out a message indicating 
#       the letters that appear in the string and their frequency
#
########################################################################
# Register Usage in the Function:
#	$v0, #a0 -- for subroutine linkage and general calculations
#	$t0 -- a temporary register used to hold stack pointer
#       $t1 -- a temporary register used to hold the string length
#       $t2 -- a temp register used to hold the current character while
#               parsing the stack
#       $t3 -- a temp register holding 90 to check letter case
#       $t4 -- a temp register holding the address of FreqArr 
#       $t6 -- holds the value 65 to calculate index in array for upper case letters
#       $t7 -- holds the value 97 to calculate index in array for lower case letters
#       $t8 -- holding the calulated index for array 
#       $t9 -- used for loading elements from frequency array
#       $s6 -- register used to hold the char
#       $s7 -- used for holding the address of the character array 
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Loading stack pointer, string length, the value 65, the value 
#          97,and the value 90 into registers
#	2. Loop to input frequency:
#               a. To load the first character from string and check to see if it is
#                  capital or lower case by comparing with value 91
#               b. If greater than then the letter is lower case so
#                  value 97 is subtracted from ascii value of letter
#               c. If less than then the letter is upper case so the value 65
#                  is subtracted from the ascii value of the letter
#               d. Then the index is multiplied by four and the element is 
#                  accessed, incremented and stored back into the array
#               e. Decrement string length and check if reached the 
#                  end of the string, if so jump to print frequencies
#                  else fetch the next character
#	3. Loop to print frequency:
#               a. Check to see if the end of the character array has 
#                  been reached
#               b. Load a frequency, if zero fetch the next frequency
#               c. If not zero, print message about the letter and 
#                  its frequency
#               d. Repeat loop until array length is zero
#	4. Tab to a new line then return to main
#######################################################################
         .data
CharArr: .byte 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' 
FreqArr: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0     
ArraySize:.word 26    # same number of elements for frequency array to line up with character array
FreqMessage: .asciiz "\nThe number of "
letter: .asciiz "'s are: "
enter: .asciiz "\n"
         .text

frequency:
        move        $t0, $a0                # ($t0 = stack pointer) copying the stack pointer to a temp register
                # setting up registers for loop calculations
        move        $t1, $a1                # ($t0 = string length)copying the string length to temp register
        li          $t3, 91                 # used to compare chars, if greater than, then lower case, else upper case
        li          $t6, 65                 # used to calculate index in charArray for uppercase letters (65-90)
        li          $t7, 97                 # used to calculate index in charArray for lowercase letters (97-122)          
        # NOTE: loop starts at the beginning of string 

fetch:
        la          $t4, FreqArr	    # loading pointer to array that will hold the frequency of each letter in string
                                                   # update the array pointer by multiplying by four since each word is 4 bytes 
        li          $t9, 0                  # reseting to hold a new frequency
        lb          $t2, 0($t0)             # loading current character of user inputted string into $t2          
        bgt         $t2, $t3, lowerC        # if $t2 > $t3 then current char is lower case, 
                                                # since ascii values for lower case letters range from 97 - 122
        sub         $t8, $t2, $t6           # finding index of upper case character. letter ($t2) - 65 ($t6)

indexArr:
        sll         $t8, $t8, 2             # shift left logical 2 positions is the same as multiplying 
                                                # by four (since integers are four bytes each)
        add         $t4, $t8, $t4           # adding the calculated index to the freqArr pointer 
                                                # to calculate the index in the frequency array
        lw          $t9, 0($t4)             # load element from frequency array into $t9 to increment
        addi        $t9, $t9, 1             # incrementing element
        sw          $t9, 0($t4)             # store back in frequency array
        addi        $t0, $t0, 1             # incrementing stack pointer to point to next character        
        addi        $t1, $t1, -1            # decrementing string length
        beqz        $t1, printFrequency     # check if string length is zero, meaning function 
                                                #  has counted the frequency of the last char
        j           fetch    

lowerC: 
        sub         $t8, $t2, $t7           # finding index of lower case character. letter ($t2) - 97 ($t7)
        j           indexArr

printFrequency:
        move        $t1, $a1                # ($t0 = string length)copying the string length to temp register 
                                                # (again in case if got wiped in the inputFreq section)
        lw          $t5, ArraySize          # ($t5 = number of elements in both CharArr and FreqArr) 
                                                # used to parse array
        la          $t4, FreqArr            # incase it was wiped or changed from previous section
                                                # resetting pointer to first element in frequency array
        la          $s7, CharArr            # loading address of charArray into $s7 (ran out of temp registers :(, but ok since main is 
                                                # not using this one) 
printFreqLoop:
        beqz        $t5, leave
        addi        $t5, $t5, -1            # decrementing array size
        lw          $t9, 0($t4)             # loading $t9 with frequency                 
        beqz        $t9, fetchNext          # if the frequency of a letter is zero, fetch the next frequency
        lb          $s6, 0($s7)             # load letter into $s6

        li          $v0, 4                  # system call to print a string
        la          $a0, FreqMessage
        syscall

        move        $a0, $s6                # system call to print a letter
        li          $v0, 11
        syscall

        li          $v0, 4                  # system call to print a string
        la          $a0, letter
        syscall

        move        $a0, $t9                # moving frequency to $a0 for printing
        li          $v0, 1                  # system call to print an int
        syscall

        li          $v0, 4                  # Call the Print String I/O Service to print
        la	    $a0, tab	            # the tab
        syscall



        addi        $s7, $s7, 1             # incrementing char array pointer by 1 since it's an array of bytes
        addi        $t4, $t4, 4             # incrementing freq array pointer by 4 since an array of integers
        j           printFreqLoop

fetchNext:
        addi        $s7, $s7, 1             # incrementing char array pointer by 1 since it's an array of bytes
        addi        $t4, $t4, 4             # incrementing freq array pointer by 4 since an array of integers
        j           printFreqLoop

leave: 
        li          $v0, 4                  # Call the Print String I/O Service to print
        la	    $a0, tab	            # the tab
        syscall
        jr	    $ra			    # jump back to main
