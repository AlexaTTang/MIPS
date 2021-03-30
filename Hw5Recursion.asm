########################################################################
# Program: Comb      				Programmer: Alexa Tang 
# Due Date: December 15, 2019		Course: CS2640
########################################################################
# Overall Program Functional Description:
#	This recursive function will compute Comb(n,r), where n >= r and 
#       r >= 0.
#       Comb(n, r) = 1 if n ==r or r==0  (base case)
#       Comb(n, r) = Comb(n-1, r) + Comb(n-1, r-1)     
########################################################################
# Register usage in Main:
#  $sp -- stack pointer
#  $ra -- return address
#  $t0 -- holding value of n
#  $t1 -- holding value of r
#  $t2 -- holding the result from second recursive call
#  $t3 -- holding copy of recursive function results
########################################################################
# Pseudocode Description:
#       Allocates four spaces on the stack to push the return address,
#   n, r and the result of the first recursive call. Then checks if the 
#   base case was met and if so return 1, else call recurse function again.
#
########################################################################
        .data
n: .word 5
r: .word 3
result: .asciiz "Comb(5, 3) = "
        .globl main
        .text
main:
        lw		$t0, n 		            # loading t0 with value of n 
        lw		$t1, r 		            # loading t0 with value of n
        jal	    recurse                 # calling recursive function
        j       exit                    # jump to exit to print out result from recursion

baseCase:
        li      $v0, 1                  # load v0 with 1 to return 
        j done                          # jump to done
recurse:
        addi    $sp, $sp, -16            # saving four spaces in the stack, for return address, n, r, and n-1
        sw	$ra, 0($sp)		        # pushing the stack pointer to the stack
        sw      $t0, 4($sp)             # pushing n to the stack
        sw      $t1, 8($sp)             # pushing r to the stack
        
        beq     $t0, $t1, baseCase      # if n = r then jump to baseCase function
        beqz    $t1, baseCase           # if r = 0 then jump to baseCase function
        addi    $t0, $t0, -1            # n-1
        jal     recurse                 # first recusive call, Comb(n-1, r)
        sw		$v0, 12($sp)        	# pushing result of first recursion call
        addi    $t1, $t1, -1            # calculating r-1 for second recursive call
        
        
        jal		recurse				    # second recursive call, Comb(n-1, r-1)
        lw		$t2, 12($sp)		    # pop result of first recursive call
        add		$v0, $t2, $v0		    # adding results from both recursive calls

done:
        lw      $t0, 4($sp)             # popping n
        lw      $t1, 8($sp)             # popping r
        lw      $ra, 0($sp)             # restore return address
        addi    $sp, $sp, 16            # restoring the stack pointer
        jr      $ra
        
exit:
        move    $t3, $v0                # copying result so that it doesn't get overwritten
        la		$a0, result             # loading address of result prompt    
        li      $v0, 4                  # system call for printing a string
        syscall		 
        move    $a0, $t3                # moving result from recursion to $a0 for printing
        li      $v0, 1                  # system call for printing an integer
        syscall 
        li      $v0, 10                 # system call for exit
        syscall
