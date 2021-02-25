# Author: Niha Imam
# CS465 S2019
# HW3 

################################
# DESCRIPTION OF ALGORITHM 

# Used an array where the number of instructions would be needed
# for a certain instruction to not be considered a dependency.
# Each instruction had an assigned value and with each passing
# instruction that value would be decremeted but 1 till it was 0.
# When the value is 0 that means the instruction can pass the needed
# value through forwarding.	

# END DESCRIPTION OF ALGORITHM
################################

.data # Start of Data Items
	INIT_INPUT:	.asciiz "How many instructions to process? "
	INSTR_SEQUENCE:	.asciiz "Please input instruction sequence:\n"
	i:		.asciiz "I"
	colon:		.asciiz ": "
	src:		.asciiz "Source registers: "
	dest:		.asciiz "    Destination registers: "
	depend:		.asciiz "    Dependencies: "
	open_bracket:	.asciiz "("
	close_bracket:	.asciiz ")"
	space:		.asciiz ", "
	none:		.asciiz "none"
	line:		.asciiz "-------------------------------------------\n"
	NEWLINE:	.asciiz "\n"
	INPUT:		.space 9
	instruction:	.word 0:50
	destination:	.word 0:50
	dest_valid:	.word 0:50
	source:		.word 0:2
# End of Data Items

.text
main:
	li	$v0, 4
	la	$a0, INIT_INPUT
	syscall 			# print out message asking for N instructions to process
	li	$v0, 5
	syscall 			# read in Int 
	addi	$s0, $v0, 0		# save number of instructions in $s0
	la	$s1, instruction	# base address of instructions array
	li	$v0, 4
	la 	$a0, INSTR_SEQUENCE
	syscall				# print out message prompting user to input instructions
	
	li	$t0, 0			# loop counter	
Loop:					# Read in N strings and store them 
	la	$a0, INPUT
	li	$a1, 9
	li	$v0, 8
	syscall 			# read in one string
	jal 	extract			# extract string
	sw	$v0,($s1)		# store in INPUT
	add	$s1, $s1, 4
	li	$v0, 4
	la	$a0, NEWLINE
	syscall 
	addi	$t0, $t0, 1		# increment loop ctr
	blt	$t0, $s0, Loop

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# use the instructions array to find all destinations and store into the destination array
# create and initialize the validity array used to determine dependencies

	# $s0 has # of instructions
	la	$s1, instruction	# base address of instruction array
	la	$s2, destination	# base address of destination array
	la	$s3, dest_valid		# base address of validity check array
	
	li 	$t5, 0			# ctr for the loop below
	li	$t6, 2			# validity for add/sub/addi/slt
	li	$t7, 3			# validity for lw/sw
dest_loop:
	lw	$a0, 0($s1)		# load word instruction[$s1] into $a0
	add	$s1, $s1, 4		# increment address
	jal	get_dest_reg
	move	$t0, $v0		# save dest in temp reg
	sw	$t0, 0($s2)		# store dest in destination array
	add	$s2, $s2, 4		# increment the address
	srl	$t4, $a0, 26		
	beq	$t4, 0x2b, lw_sw
	beq	$t4, 0x23, lw_sw
	beq	$t4, 0x04, beq_dest
	sw	$t6, 0($s3)		# store validity information in array
	add	$s3, $s3, 4		# increment the address
	add	$t5, $t5, 1		# increment the ctr
	blt	$t5, $s0, dest_loop	# while $t5<$s0 keep looping
	j	done_dest
lw_sw:
	sw	$t7, 0($s3)		# store validity information in array
	add	$s3, $s3, 4		# increment the address
	add	$t5, $t5, 1		# increment the ctr
	blt	$t5, $s0, dest_loop	# while $t5<$s0 keep looping
beq_dest:
	sw	$zero, 0($s3)		# store validity information in array
	add	$s3, $s3, 4		# increment the address
	add	$t5, $t5, 1		# increment the ctr
	blt	$t5, $s0, dest_loop	# while $t5<$s0 keep looping
done_dest:

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# loop through all the instructions and print out source, destination and dependencies

	# $s0 has # of instructions
	la	$s1, instruction	# base address of instruction array
	la	$s2, destination	# base address of destination array
	la	$s3, dest_valid		# base address of validity check array
	
	li	$t7, 0			# ctr for the mega loop
mega_loop:				# loop through and print everything
	li 	$v0, 4
	la	$a0, i
	syscall				# print "I"
	li	$v0, 1
	move	$a0, $t7
	syscall				# print the instruction number eg I0 / I1 / I2
	li	$v0, 4
	la	$a0, colon
	syscall				# print "I0: "
	li	$v0, 4
	la	$a0, src
	syscall				# print source prompt
	lw	$a0, 0($s1)		# load instruction[$s1]
	add	$s1, $s1, 4		# increment $s1 address
	jal	get_source_reg
	srl	$s5, $a0, 26		# extract opcode
	beq	$s5, 0x2b, one_src	# only one source
	beq	$s5, 0x23, one_src
	beq	$s5, 0x08, one_src
	move	$s6, $v0		# first source reg in $s6
	move	$s7, $v1		# second source reg in $s7
	la	$s4, source		# base address of source in $s4
	sw	$v0, 0($s4)		# store first source
	add	$s4, $s4, 4		# increment the address
	sw	$v1, 0($s4)		# store the second source
	li	$v0, 1
	move	$a0, $s6
	syscall				# print first src reg
	li	$v0, 4
	la 	$a0, space
	syscall				# print space between the source registers
	li	$v0, 1
	move	$a0, $s7
	syscall				# print second src reg
	j	continue
one_src:
	move	$s6, $v0		# first source reg in $s6
	#move	$s7, $v1		# second source reg in $s7
	la	$s4, source		# base address of source in $s4
	sw	$v0, 0($s4)		# store first source
	add	$s4, $s4, 4		# increment the address
	#sw	$v1, 0($s4)		# store the second source
	li	$v0, 1
	move	$a0, $s6
	syscall				# print first src reg
	#li	$v0, 4
	#la 	$a0, space
	#syscall				# print space between the source registers
	#li	$v0, 1
	#move	$a0, $s7
	#syscall				# print second src reg
continue:
	li	$v0, 4
	la	$a0, NEWLINE
	syscall				# print new line
	li	$v0, 4
	la	$a0, dest
	syscall				# print dest prompt
	lw	$t0, 0($s2)		# get the dest for the instruction
	add	$s2, $s2, 4		# increment address
	beq	$t0, 32, no_dest
	li	$v0, 1
	move	$a0, $t0
	syscall				# print the destination register
	j	next_line
no_dest:
	li	$v0, 4
	la	$a0, none
	syscall				# print out no destination
next_line:
	li	$v0, 4
	la	$a0, NEWLINE
	syscall				# print new line
	li	$v0, 4
	la	$a0, depend
	syscall				# print dependencies
	bgt	$t7, 0, depends		# if ctr > 0
no_depend:
	li	$v0, 4
	la	$a0, none		# print no dependencies
	syscall	
	li	$v0, 4
	la	$a0, NEWLINE
	syscall				# print new line
	li	$v0, 4
	la	$a0, line
	syscall				# print line to seperate
	add	$t7, $t7, 1		# increment ctr
	blt	$t7, $s0, mega_loop	# while ctr<$s0 keep looping through
	j exit
depends:
	la	$s4, source
	li	$t6, 0			# ctr for depend loop
depend_loop:
	lw	$a0, 0($s4)		# load the source
	jal 	dependency
	move 	$t1, $v0		# save the dependency in temp
	beq	$t1, 32, no_depend	# no dependencies
	li	$v0, 4
	la	$a0, open_bracket
	syscall				# print "("
	li 	$v0, 1
	lw	$a0, 0($s4)		# source reg 
	syscall				# print source reg
	li	$v0, 4
	la 	$a0, space
	syscall				# print space
	li	$v0, 4
	la 	$a0, i
	syscall				# print I
	li	$v0, 1
	move	$a0, $t1
	syscall				# print dependencies
	li	$v0, 4
	la 	$a0, space
	syscall				# print space
	li	$v0, 4
	la 	$a0, i
	syscall				# print I
	li	$v0, 1
	move	$a0, $t7
	syscall				# print current
	li	$v0, 4
	la	$a0, close_bracket
	syscall				# print ")"
	li	$v0, 4
	la 	$a0, space
	syscall				# print space
	jal	update_dependency
	add	$s4, $s4, 4		# increment address
	add	$t6, $t6, 1		# increment loop
	blt	$t6, 2, depend_loop
	li	$v0, 4
	la	$a0, line
	syscall				# print line to seperate
	add	$t7, $t7, 1		# increment ctr
	blt	$t7, $s0, mega_loop	# while ctr<$s0 keep looping through
	j exit
	
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check dependeny

dependency:
	li	$t1, 0			# ctr of the loop below
	la	$t2, destination		# base address of dest array in temp2
	la	$t3, dest_valid		# base address of valid array in temp3
new_loop:
	lw	$t4, 0($t2)		# $t4 = dest[$t2]
	add	$t2, $t2, 4		# increment address
	beq	$a0, $t4, check_valid	# if $a0 = dest check if dependency valid
	add	$t1, $t1, 1		# increment loop ctr
	blt	$t1, $t7, new_loop	# while ctr < megaloop ctr, keep looping
	li	$v0, 32			# not dependency found return 32
	jr	$ra
check_valid:
	add	$t3, $t3, $t1
	add	$t3, $t3, $t1
	add	$t3, $t3, $t1
	add	$t3, $t3, $t1		# valid address + ctr * 4 = valid address + ctr+ctr+ctr+ctr
	lw	$t4, 0($t3)		# load word from the new address
	bgtz	$t4, found_it		# if word > 0, it can be a dependency
	add	$t1, $t1, 1		# increment loop ctr
	blt	$t1, $t7, new_loop	# while ctr < megaloop ctr, keep looping
found_it:
	move	$v0, $t1		# return index/ctr
	jr	$ra
	
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# update the validity check array by decrementing
	
update_dependency:
	li	$t0, 0			# ctr for loop
valid_loop:
	j update			# jump to update
done:
	add	$t0, $t0, 1		# increment the ctr
	blt	$t0, $t7, valid_loop	# while $t0<$t7 keep looping
	jr	$ra
update:
	la	$t1, dest_valid		# load address of validity array
	li 	$t2, 0			# ctr for update
	beqz	$t0, update_once	# update the array only once
not_zero:
	lw	$t3, 0($t1)		# load the first number
	beqz	$t3, skip		# if zero leave it
	sub 	$t3, $t3, 1		# else decrement
	sw	$t3, 0($t1)		# store the new number
skip:
	add	$t1, $t1, 4		# increment address
	add	$t2, $t2, 1		# increment update ctr
	ble	$t2, $t0, not_zero
	j done
update_once:
	lw	$t3, 0($t1)		# load the first number
	beqz	$t3, skip_once		# if zero leave it
	sub	$t3, $t3, 1		# else decrement
	sw	$t3, 0($t1)		# store the new number
skip_once:
	j done
		
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# helper method to extract source reg

get_source_reg:
	move	$t0, $a0 		# store arg in temp variable
	li 	$t1, 0x03E00000		# first src reg
	and 	$t1, $t1, $t0		# bitwise and to extract dest
	srl 	$t1, $t1, 21		# shift right
	li 	$t2, 0x001F0000 	# second src reg
	and 	$t2, $t2, $t0		# bitwise and to extract dest
	srl 	$t2, $t2, 16		# shift right
	move	$v0, $t1		# return first source reg as $v0
	move 	$v1, $t2		# return second source reg as $v1
	jr 	$ra

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# helper method from hw 2 to get type

get_type:
	move 	$t0, $a0		# save arg0 in temp0
	srl 	$t0, $t0, 26		# shift bits to get the opcode
	beqz 	$t0, check		# if opcode = 0 check validity for r type
	beq 	$t0, 1, its_i		# return i type
	sge 	$t1, $t0, 4		# if opcode between 4 and 64
	slti	$t2, $t0, 64	
	and 	$t1, $t1, $t2
	beq 	$t1, 1, its_i		# return i type
check:
	sll 	$t3, $a0, 26		#shift to isolate funct
	srl 	$t3, $t3, 26	
	beq 	$t3, 0x20, its_r	# return r type
	beq 	$t3, 0x22, its_r	# return r type
	beq 	$t3, 0x2a, its_r	# return r type
its_r:
	li 	$v0, 1			# return 1 for r type
	jr 	$ra
its_i:
	li 	$v0, 2			# return 2 for i type
	jr 	$ra

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# helper method to extract dest reg

get_dest_reg:
	move 	$t0, $a0		# move instruction in temp0
	srl 	$t1, $t0, 26		# shift bits to get the opcode
	beq 	$t1, 0x04, none_dest	# beg has no dest reg
	beq 	$t1, 0x2b, none_dest	# sw has n dest reg
	beqz 	$t1, r_type_dest
	srl 	$t0, $t0, 16		# shift to right by 16 to get rid of the immediate
	and 	$t0, $t0, 0x1F		# bitwise and to isolate the dest reg
	move 	$v0, $t0
	jr 	$ra
r_type_dest:
	srl 	$t0, $t0, 11		# shift to right by 11 to get rid of funct + shamt
	and 	$t0, $t0, 0x1F		# bitwise and to isolate the dest reg
	move 	$v0, $t0
	jr 	$ra
none_dest:
	li	$v0, 32			# beq, sw
	jr 	$ra

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# helper method to extract string from hw 2

extract:
	li	$t2, 0	
 	li	$t3, 0		 
 	li	$t4, 0		 
 	li	$t5, 0	 
 	li	$t6, 0	 
hexcheck:
	add	$t6, $t6, 1		# ctr + 1
	beq	$t6, 9, end_hex 	# if ctr == 9; end_hex
	lb	$t2, 0($a0)		# t2 = a0[0]; first ascii val
	beqz	$t2, end_hex		# if t2 == 0; end_hex
	slti	$t3, $t2, 65		# check if less than 65
	beq	$t3, 0, letter		# if greater than 65; letter
	move	$t4, $zero		# t4 = 0
	move 	$t4, $t2		# move t3 = t1
	subi 	$t4, $t4, 48		# subtract 48 to get number
	sll	$t5, $t5, 4		# shift $t5 by 4 bits
	or 	$t5, $t5, $t4		# or $t5 and $t4
	addi 	$a0, $a0, 1		# increment $t0
	j 	hexcheck		# loop back	
letter:
	move	$t4, $zero		# t4 = 0
	move 	$t4, $t2		# move t4 = t2
	subi 	$t4, $t4, 65		# subtract 65
	addi 	$t4, $t4, 10		# add 10 to letter
	sll 	$t5, $t5, 4		# shift $t5 by 4 bits
	or 	$t5, $t5, $t4		# or $t5 and $t4
	addi 	$a0, $a0, 1		# increment $a0
	j 	hexcheck		# loop back to hexcheck
end_hex:
	move	$v0, $t5
	jr	$ra	 

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit:
	li $v0, 10
	syscall
