# CSCI 424, Homework 2

# switch to the Data segment
.data
# global data is defined here
# Don't forget the backslash-n (newline character)
Homework:
.asciiz "CSCI 424 Homework 2\n"
Name_1:
.asciiz "Tyler\n"
Name_2:
.asciiz "Reid\n"


# switch to the Text segment
	.text
# the program is defined here
	.globl main
main:
# Whose program is this?
	la $a0, Homework
	jal Print_string
	la $a0, Name_1
	jal Print_string
	la $a0, Name_2
	jal Print_string

# int i, n = 2;
# for (i = 0; i <= 16; i++)
# {
# ... calculate n from i
# ... print i and n
# }

# register assignments
# $s0 i
# $s1 n
# $a0 argument to Print_integer, Print_string
# add to this list if you use any other registers

# initialization
li $s1, 0 # n = 2

# for (i = 0; i <= 16; i++)
li $s0, 0 # i = 0
bgt $s0, 16, bottom
# calculate n from i

top:
# Your part starts here
add $t1, $zero, $zero #initialize the 1 counter to 0, aka bit_counter
addi $t3, $zero, 32 #initialize loop limit
add $t2, $zero, $zero #initialize loop counter to 0
add $t4, $s0, $zero #make a copy of i for later use
loop:
add $t0, $s0, $zero #copy $s0, which is i, to $t0
sll $t0, $t0, 31 #shift bits all the way to the left
beq $t0, $zero, even #jumps to even if the bit is equal to 0. If bit == 1, add 1 to bit_counter
addi $t1, $t1, 1 #this adds 1 to bit_counter
even:
addi $t2, $t2, 1 #increment loop counter
beq $t2, $t3, exit #test if loop counter is equivalent to loop limit. If it is, exit loop
srl $s0, $s0, 1
j loop



exit:
add $s1, $t1, $zero #copy bit counter to $s1
add $s0, $t4, $zero #copy old i back in
# Your part ends here

# print i and n
move $a0, $s0 # i
jal Print_integer
la $a0, sp # space
jal Print_string
move $a0, $s1 # n
jal Print_integer
la $a0, cr # newline
jal Print_string

# for (i = 0; i <= 16; i++)
add $s0, $s0, 1 # i++
ble $s0, 16, top # i <= 16
bottom:

la $a0, done # mark the end of the program
jal Print_string

jal Exit # end the program, no explicit return status


# switch to the Data segment
.data
# global data is defined here
sp:
.asciiz " "
cr:
.asciiz "\n"
done:
.asciiz "All done!\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
# Wrapper functions around some of the system calls
# See P&H COD, Fig. A.9.1, for the complete list.

# switch to the Text segment
	.text

	.globl Print_integer
Print_integer: # print the integer in register a0. Loading one into $v0 from addi makes syscall print
	addi $v0, $zero, 1
	syscall
	jr $ra

	.globl Print_string
Print_string: # print the string whose starting address is in register a0
	addi $v0, $zero, 4
	syscall
	jr $ra

	.globl Exit
Exit: # end the program, no explicit return status
	addi $v0, $zero, 10
	syscall
	jr $ra

	.globl Exit2
Exit2: # end the program, with return status from register a0
	addi $v0, $zero, 17
	syscall
	jr $ra
