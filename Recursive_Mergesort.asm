# switch to the Data segment
	.data
# global data is defined here


sp:
	.asciiz " "
cr:
	.asciiz "\n"
empty_array:
	.asciiz "\The Array is empty."
array_length:
	.asciiz "\Array Length: "
array_input:
	.asciiz "\Please type a single digit. Press enter after each. End array with -1 input.\n"
comma:
	.asciiz ", "
char: 
	.word 4
myArray:
	.space 256
myAux:
	.space 256

# Switch to the Text segment
        .text
        .globl  main
main: # The rest of the main program goes here
        lui $s7, 0xffff  # Set first half of $s7
        ori $s7, $s7, 0xffff # Set $s7 to compare with beq and exit input, $s7 = -1 now.
        addi $t3, $t3, 0 # Set counter for decrementing array later
        la $s1, myArray # Set base address of array to $s1
        la $s6, myAux # Set base address of aux array at $s6
        move $s0, $s6 # Copy start address of aux array
        la $a0, array_input # Print initialization string
        jal Print_string
        
input_loop: # Prompt user for input until -1 is entereed
	addi $v0, $zero, 5
	syscall
	move $t2, $v0
	beq $t2, $s7, begin_sort # Branch if input is equivalent to -1.
	#addi $t2, $t2, -48 # Account for newline char and ascii
	sw $t2, 0($s1) # Store char into array	
	addi $s1, $s1, 4 # Increment array address
	addi $t3, $t3, 1 # Increment array counter
	j input_loop # Jump back up when -1 not entered
	
begin_sort: # Begin recursively mergesort
	beq $t3, $zero, array_is_empty # Exit if no input entered and array is empty
	add $t6, $t3, $zero # Copy $t3 to $t6
	addi $t6, $t6, -1 # Correct for extra printed value
	la $a0, array_length # Print array length: X
	jal Print_string 
	move $a0, $t3
	jal Print_integer
	la $a0, cr
	jal Print_string
	sll $t3, $t3, 2 # Multiply length by 4
	sub $s1, $s1, $t3 # Subtract array counter to get to base
	add $a0, $s6, $zero # Array end address for s6
	jal array_converter # Make the indirect array	
	add $a1, $s6, $zero # Find array end address
	sub $s6, $s6, $t3 # Subtract array counter to get base
	add $t9, $zero, $zero # Initialize a counter for printing
	add $t0, $t3, $zero
	jal merge_sort # Call mergesort recursion
	jal print_loop # Print newly organized array
	
merge_sort: # Recursively calls merge_sort until
	addi $sp, $sp, -16 # Adjust stack pointer to access other a registers?
	sw $ra, 0($sp) # Store return address on the stack
	sw $a0, 4($sp) # Stores array start on the stack at 4
	sw $a1, 8($sp) # Stores array end on the stack at 8	
	sub $t0, $a1, $a0 # Calculate length between beginning array address and end array address	
	ble $t0, 4, Reset_pointer # Resets stack pointer if the array is only a single element
	jal binary_half # Calculate array length / 2
	add $a1, $a0, $t0 # Add newly calculated $t0 to first array address
	sw $a1, 12($sp) # Store midpoint address on the stack	
	jal merge_sort # Sort first half of the array
	lw $a0, 12($sp) # Load the midpoint address of array from stack
	lw $a1, 8($sp) # Load the end address from stack
	jal merge_sort # Sort the second half of the array
	jal load_array_address # Loads all array address necessary for subsequent merge
	jal merge # Merge both arrays
	lw $ra, 0($sp) # Load return address from stack
	addi $sp, $sp, 16 # Reset the stack pointer
	jr $ra # Jump to our current return address

merge: # Merge both arrays, load then merge_loop
	jal store_array_address	
	move $s1, $a0 # Create a copy of the first half of the array by pointing
	move $s2, $a1, # Create a copy of the second half of the array by pointing

merge_loop: # Necessary loop for merging all array values
	jal compare_pointer_values
	move $a0, $s2 # Make the first start address equivalent to the second array's address
	move $a1, $s1 # Make the second half's address equivalent to the first array's address
	jal swap	
	addi $s2, $s2, 4 # Increment second half index	
	
in_order: # Increment first half because it's already in numerical order
	addi $s1, $s1, 4 # Increment first half index	
	lw $a2, 12($sp) # Load end address of array
	bge $s1, $a2, merge_loop_exit # If halves are empty, exit
	bge $s2, $a2, merge_loop_exit # If halves are empty, exit
	j merge_loop 

merge_loop_exit: # Exit merge_loop, be sure to reset stack pointer first
	lw $ra, 0($sp) # Load the return address from stack
	addi $sp, $sp, 16 # Reset the stack pointer
	jr $ra # Jump to our current return address
	
swap: # Partially swap positions of lower value and higher value (eventually)
	ble $a0, $a1, Return_address # If second half's value is less than or equal to first half's, go back
	addi $s5, $a0, -4 # Point to previous value
	lw $s3, 0($a0) # Make $s3 the pointer for the second half array's first value
	lw $s4, 0($s5) # Make $s4 pointer of previous address
	sw $s3, 0($s5) # Make $s3 equal to the previous address
	sw $s4, 0($a0) # Swap $s4 pointer to second half array's first value
	move $a0, $s5 # Swap positions
	j swap
	
binary_half: # Calculates half of a value by shifting
	srl $t0, $t0, 3 # Shift right to divide by 8
	sll $t0, $t0, 2 # Multiply by 4 to get half of array size
	jr $ra

load_array_address: # Loads address of start, midpoint, and end.
	lw $a0, 4($sp) # Load array start address from stack
	lw $a1, 12($sp) # Load array midpoint address of array from stack
	lw $a2, 8($sp) # Load array end address from stack
	jr $ra

compare_pointer_values: # Compares values pointed then loaded, branches to in_order if they are numerical
	lw $t7, 0($s1) # Create a pointer for first half of address
	lw $t7, 0($t7) # Load first half first value
	lw $t8 0($s2) # Create a pointer for the second half of the address
	lw $t8, 0($t8) # Load second half first value
	bgt $t8, $t7, in_order	# Branch if already in numerical order	
	jr $ra

store_array_address: # Stores start, midpoint, and end address of the array
	addi $sp, $sp, -16
	sw $ra, 0($sp) # Store return address on stack	
	sw $a0, 4($sp) # Store array start address on stack
	sw $a1, 8($sp) # Store array midpoint address on stack
	sw $a2, 12($sp) # Store array end address on stack
	jr $ra	
			 
array_converter: # Create a pointer array for the dynamic array input
	add $t1, $zero, $zero # Clear $t1 and $t2, t1 will be counter
	add $t2, $zero, $zero
	srl $t2, $t3, 2 # Multiply by 4 to account for bytes
        add $s7, $s1, $zero
        
array_converter_loop: # Loop for pointer array creation
        beq $t2, $t1, Return_address # if counter is equivalent to array length, we done
        sw $s7, 0($s6)  # Store the pointer of the first value, 0x10010070 at 0x10010170, etc
        add $s6, $s6, 4 # increment array address for myAux
        add $s7, $s7, 4 # increment array address to correspond myArray
        addi $t1, $t1, 1 # Increment counter for loop
        j array_converter_loop # Jump back to loop start
        
print_loop: # Print the array
	lw $t5, 0($s0) # Load pointer to first array
	lw $t5, 0($t5) # Load the value of the pointer
	move $a0, $t5 # Store value for printing
	jal Print_integer
	beq $t6, $t9, Exit # Exit loop if we have displayed all array values
	la $a0, comma # Print a comma
	jal Print_string
	addi $s0, $s0, 4 # Increment array address by a single value
	addi $t9, $t9, 1 # Increment counter for array loop
	j print_loop
		
array_is_empty:	# Print string array is empty
	la $a0, empty_array 
	jal Print_string
	jal Exit
           
        .globl Return_address
Return_address: # Self explanatory
	jr $ra
        
        .globl Reset_pointer
Reset_pointer: # Resets stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra	
	        
	.globl Input
Input: # Gets a string from user into register
	addi $v0, $zero, 5
	syscall
	move $t2, $v0
	jr $ra
	
	.globl Print_integer
Print_integer: # Print the integer in register a0. Loading one into $v0 from addi makes syscall print
	addi $v0, $zero, 1
	syscall
	jr $ra

	.globl Print_string
Print_string: # Print the string whose starting address is in register a0
	addi $v0, $zero, 4
	syscall 
	jr $ra
	
	.globl Exit
Exit: # End the program, no explicit return status
	addi $v0, $zero, 10
	syscall
	jr $ra
