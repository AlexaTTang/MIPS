########################################################################
# Program: Input/Output				Programmer: Alexa Tang 
# Due Date: December 10, 2019		Course: CS2640
########################################################################
# Overall Program Functional Description:
#	The program will read 20 integers and store them in an array.
#       Then generate 3 outputs:
#       1. Print all of the numbers, one per line
#       2. Print all of the numbers in one line, separated by spaces
#       3. Ask the user to enter a number n,
#          then print the numbers n per line.
########################################################################
# Register usage in Main:
#  $t0 -- size of array
#  $t1 -- number of elements in array, used as a loop counter 
#  $t2 -- temporarily holding user inputted value 
#  $t3 -- address of array, used to interate through array
#  $t4 -- n loop counter
#  $t5 -- used to hold a copy of current element when $a0 gets overwritten
########################################################################
# Pseudocode Description:
#	1. Loop to collect the values for array: 
#               a. Print a message asking user to enter numbers to put into the array
#	        b. Read the value and put into the array.
#               c. Repeat for all 20 elements in array
#	2. Loop to print all the numbers, one per line:
#		a. Move cursor to new line
#		b. Print value at current index 
#               c. Move index to next element
#               d. Repeat for all 20 elements in array
#       3. Loop to print all the numbers on one line, separated by spaces:
#		a. Print value at current index
#               b. Print space
#               c. Move index to next element
#               d. Repeat for all 20 elements in array
#	4. Ask user how many times they want each element printed on one line
#               Loop to iterate through the array:
#               a. Load the first element in array
#                       Loop to print each element n times per line:
#                               i. Print the current element from array
#                               ii. Print a space
#                               iii. Return to outer loop to fetch next element in array
########################################################################
		.data
array: .space 80    # allocating 80 bytes of space for an array of 20 integers (4 bytes per integer)
size:  .word  20   # number of elements in the array 
prompt: .asciiz "\nPlease enter a number to put into the array: " 
newLn: .asciiz "\n"
space: .asciiz " "
endMsg: .asciiz "\n\nProgram has finished printing."
Nprompt: .asciiz "\nHow many times would you like the numbers in the array printed per line? "

		.globl main
		.text
main:
        lw          $t0, size               # counter for loop to collect the values from user
        li          $t1, 0                  # number of elements inputted to array
        la	    $t3, array              # loading address of array in $t3 (base pointing to start of array)            
collectingValues:     
        li          $v0, 4                  # Call the Print String I/O Service to print
        la	    $a0, prompt		    # the prompt asking for values for the array
        syscall
    
	li          $v0, 5 		    # Call the Read Integer I/O Service to get the array element
	syscall 	

	move        $t2, $v0		    # move user inputted value from register $v0 to $t2

	sw 	    $t2, ($t3)              # store word from $t2 to array in $t3
        addi	    $t3, $t3, 4	            # $t3 = $t3 + 4 (step to next cell in array, increase index by four since int = 4 bytes each)
        addi	    $t1, $t1, 1		    # $ t0 = $t1 + 1 (count the number of inputted values)
        
        beq         $t1, $t0, OnePerLine    # if the loop counter is zero leave loop to execute printouts, else execute next line
        j	    collectingValues	    # jump to collecting values to ask user for another number and store it in an array 
      
OnePerLine:
        lw          $t0, size               # Load the size of the array
        la          $t3, array              # Set the pointer to the first element
        li          $t1, 0                  # Initialize the loop counter
loop0: 
        beq         $t0, $t1, OnOneLine     # checking if loop has executed the for all elements in array
        li          $v0, 4                  # system call for printing a string
        la          $a0, newLn
        syscall
        lw          $a0, ($t3)              # Fetch the (next) value from array, put into $a0     
        li          $v0, 1                  #    system call for printing an integer
        syscall
        addi        $t1, $t1, 1             # Increment the loop counter
        addi        $t3, $t3, 4             # Point to the next element in the array
        j           loop0

OnOneLine:
        lw          $t0, size               # Load the size of the array
        la          $t3, array              # Set the pointer to the first element
        li          $t1, 0                  # Initialize the loop counter
        li          $v0, 4                  # system call for printing a string
        la          $a0, newLn
        syscall
        li          $v0, 4                  # system call for printing a string
        la          $a0, newLn
        syscall        
loop1: 
        beq         $t0, $t1, NperLine      # checking if loop has executed the for all elements in array
        lw          $a0, ($t3)              # Fetch the (next) value from array, put into $a0     
        li          $v0, 1                  #    system call for printing an integer
        syscall
        li          $v0, 4                  # system call for printing a string
        la          $a0, space
        syscall
        addi        $t1, $t1, 1             # Increment the loop counter
        addi        $t3, $t3, 4             # Point to the next element in the array
        j           loop1
        
NperLine:
        lw          $t0, size               # Load the size of the array
        la          $t3, array              # Set the pointer to the first element
        li          $t1, 0                  # Initialize the loop counter

        li          $v0, 4                  # system call for printing a string
        la          $a0, newLn
        syscall
        li          $v0, 4                  # system call for printing a string
        la          $a0, newLn
        syscall 

        li          $v0, 4                  # Call the Print String I/O Service to print
        la	    $a0, Nprompt	    # the prompt asking number to print each element per line
        syscall   

	li          $v0, 5 		    # Call the Read Integer I/O Service to get n value
	syscall 	

	move        $t2, $v0		    # move user inputted n value from register $v0 to $t2

loop2: 
        beq         $t0, $t1, end           # checking if loop has executed the for all elements in array   
        li          $t4, 0                  # n loop counter to stop loop when it has executed n times     
        addi        $t1, $t1, 1             # Increment the loop counter for interating through elements in array
        li          $v0, 4                  # system call for printing a string
        la          $a0, newLn              # move cursor to next line
        syscall 
        lw          $a0, ($t3)              # Fetch the (next) value from array, put into $a0
        addi        $t3, $t3, 4             # Point to the next element in the array
        move        $t5, $a0
inLoop:   
        li          $v0, 1                  # system call for printing an integer
        syscall        
        li          $v0, 4                  # system call for printing a string
        la          $a0, space
        syscall
        move        $a0, $t5                # copying value since $a0 gets overwritten doing system calls
        addi	    $t4, $t4, 1		    # Increment another counter for n value to know when to tab 
        beq         $t4, $t2, loop2         # if the value has been printed n times, move on to next value       
        j           inLoop                  # if not printed n times, print value again 
         
end:
        li          $v0, 4                 # Call the Print String I/O Service to print
        la          $a0, endMsg	           # the prompt saying the program has ended
	syscall
	li          $v0, 10 		   # System call for exit
	syscall        
        