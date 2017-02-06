
# switch to the Data segment
.data
# global data is defined here
sp:
.asciiz " "
cr:
.asciiz "\n"
ask_input:
.asciiz "\Please enter a string to print!\n"
the_string:
.asciiz "\The string "
not_palindrome:
.asciiz "\ is not a palindrome.\n"
is_palindrome:
.asciiz "\ is a palindrome."
byte_space:
.space 1024 #makes space in memoy for a word

# switch to the Text segment
        .text
        .globl  main
main:
        # the rest of the main program goes here
              
la $a0, byte_space
li $a1, 1024
jal Input
move $s0, $a0, #stores the memory address of string into $s0 register
move $s6, $a0 #copy word into $s6
move $s5, $a0 #copy word into $s5

add $t9, $0, $0
add $s2, $0, $0 #initialize $s2 to 0 as counter to hold str len
addi $s3, $0, '\n' #now $s3 = '\n'

str_len:
lb $s1, 0($s0) #load char into $s1
beq $s1, $s3, end #break if byte is a newline char
addi $s2, $s2, 1 #increment loop counter, $s2
addi $s0, $s0, 1 #increment string address
j str_len

end:
sb $0, 0($s0) #replace newline with 0 so now we just have the string 'hello' or 'radar'
#add $s0, $s0, $s2

addi $s7, $zero, 2 #set $s7 to be 2 for division
div $s2, $s7 #divide str_len by 2 to see if even or odd
mfhi $s4 #store $hi to $s4,
mflo $t8 #store $lo into $t9 

add $t2, $0, $0 #initialize counters $t2, $t3
add $t3, $0, $s2
addi $t9, $s2, -1 #must account for last char, otherwise we will load 0x00
add $s6, $s6, $t9 #increment string address by the string length (str_len - 1 actually) to get the last letter
beq $s4, $zero, even #if its even, jump even, otherwise its odd
#div $t8, $s4, $s7 #calculate midpoint by adding one to $s4 from div earlier
addi $t8, $t8, 1 #increment the $lo to equal midpoint for beq to out

while:
lb $t1, 0($s6) #load last char into $t1
lb $t0, 0($s5) #load first char into $t0
bne $t0, $t1, NOPE #exit loop if first char and last char are not equivalent
beq $t2, $t8, YEP #exit loop if loop counter is equivalent to $t8, or str_len (1 + ($s2 / 2))
addi $s5, $s5, 1 #increment first letter string address 
addi $s6, $s6, -1 #decrement last letter string address
addi $t2, $t2, 1 #increment front loop counter
j while

even:
lb $t1, 0($s6) #load last char into $t1
lb $t0, 0($s5) #load first char into $t0
bne $t0, $t1, NOPE
bgt $t2, $t3, YEP
addi $s5, $s5, 1 #increment first letter string address 
addi $s6, $s6, -1 #decrement last letter string address
addi $t2, $t2, 1 #increment front loop counter
addi $t3, $t3, -1 #decrement back loop counter
j even

NOPE: #print the string X is not a palindrome
la $a0, the_string
jal Print_string
la, $a0, byte_space
jal Print_string
la $a0, not_palindrome
jal Print_string
j done

YEP: #print the string X is a palindrome
la $a0, the_string
jal Print_string
la $a0, byte_space
jal Print_string
la $a0, is_palindrome
jal Print_string 

done:
jal Exit #end program

	.globl Input
Input: # gets a string from user into register
	addi $v0, $zero, 8
	syscall #calls for input
	jr $ra
	
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