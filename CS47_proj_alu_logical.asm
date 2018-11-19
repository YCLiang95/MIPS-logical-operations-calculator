.include "./cs47_proj_macro.asm"

.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return 	
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
	beq	$a2,	42,	au_logical_multipication
	beq	$a2,	43,	au_logical_plus
	beq	$a2,	45,	au_logical_minus
	beq	$a2,	47,	au_logical_division
	
au_logical_plus:
	addi	$sp,	$sp,	-36
	sw	$fp,	36($sp)
	sw	$ra,	32($sp)
	sw	$s0,	28($sp)
	sw	$s1,	24($sp)
	sw	$s2,	20($sp)
	sw	$a0,	16($sp)
	sw	$a1,	12($sp)
	sw	$a2,	8($sp)
	addi	$fp,	$sp,	36

	or	$s2,	$zero,	$zero	#i
	or	$s0,	$zero,	$zero	#carry
	or	$s1,	$zero,	$zero	#result
loop_plus:
	beq	$s2,	32,	end_plus
	
	extract_nth_bit($a0,	$s2)
	or	$t1,	$v0,	$zero
	extract_nth_bit($a1,	$s2)
	or	$t2,	$v0,	$zero
	
	xor	$t4,	$t1,	$t2	#A xor B
	and	$t6,	$t1,	$t2	#A and B	
	and	$t7,	$s0,	$t4	#CI(A xor B)
	
	xor	$t5,	$s0,	$t4	#CI xor (A xor B)
	or	$s0,	$t6,	$t7	#carry over,	CI(A xor B) + AB
	insert_to_nth_bit($s1,	$s2,	$t5)
	or	$s1,	$v0,	$zero
	
	addi	$s2,	$s2,	1	# i++
	j	loop_plus
end_plus:
	or	$v1,	$s0,	$zero	#overflow detection, won't do anything though
	or	$v0,	$s1,	$zero
	
	lw	$fp,	36($sp)
	lw	$ra,	32($sp)
	lw	$s0,	28($sp)
	lw	$s1,	24($sp)
	lw	$s2,	20($sp)
	lw	$a0,	16($sp)
	lw	$a1,	12($sp)
	lw	$a2,	8($sp)
	addi	$sp,	$sp,	36
	jr	$ra
	
###########################################################################
	
au_logical_minus:
	addi	$sp,	$sp,	-20
	sw	$fp,	20($sp)
	sw	$ra,	16($sp)
	sw	$a0,	12($sp)
	sw	$a1,	8($sp)
	addi	$fp,	$sp,	20

	not	$a1,	$a1
	jal	au_logical_plus
	or	$a0,	$v0,	$zero
	li	$a1,	1
	jal	au_logical_plus
	
	lw	$fp,	20($sp)
	lw	$ra,	16($sp)
	lw	$a0,	12($sp)
	lw	$a1,	8($sp)
	addi	$sp,	$sp,	20
	
	jr	$ra

############################################################################

au_logical_multipication:
	addi	$sp,	$sp,	-36
	sw	$fp,	36($sp)
	sw	$ra,	32($sp)
	sw	$s0,	28($sp)
	sw	$s1,	24($sp)
	sw	$s2,	20($sp)
	sw	$a0,	16($sp)
	sw	$a1,	12($sp)
	sw	$a2,	8($sp)
	addi	$fp,	$sp,	36
	
	or	$s0,	$a0,	$zero
	or	$s1,	$a1,	$zero
	
	or	$s2,	$zero,	$zero
	bgez	$s0,	invert_1
	not	$a0,	$s0
	not	$s2,	$s2
	li	$a1,	1
	jal	au_logical_plus
	or	$s0,	$v0,	$zero
invert_1:
	bgez	$s1,	invert_2
	not	$a0,	$s1
	not	$s2,	$s2
	li	$a1,	1
	jal	au_logical_plus
	or	$s1,	$v0,	$zero
invert_2:
	or	$a0,	$s0,	$zero
	or	$a1,	$s1,	$zero
	jal	au_logical_multipication_unsigned
	or	$s0,	$v0,	$zero
	or	$s1,	$v1,	$zero
	beqz	$s2,	end_signed_mul
	
#Restore the sign on the product
	not	$a0,	$s0
	not	$s1,	$s1
	li	$a1,	1
	jal	au_logical_plus
	or	$s0,	$v0,	$zero
#using the overflow detection of addition operation, if Lo overflow, add 1 to Hi. If not, just inverted no need to add 1
	blez	$v1,	end_signed_mul
	or	$a0,	$s1,	$zero
	li	$a1,	1
	jal	au_logical_plus
	or	$s1,	$v0,	$zero

end_signed_mul:
	or	$v0,	$s0,	$zero
	or	$v1,	$s1,	$zero
	
	lw	$fp,	36($sp)
	lw	$ra,	32($sp)
	lw	$s0,	28($sp)
	lw	$s1,	24($sp)
	lw	$s2,	20($sp)
	lw	$a0,	16($sp)
	lw	$a1,	12($sp)
	lw	$a2,	8($sp)
	addi	$sp,	$sp,	36
	
	jr	$ra

au_logical_multipication_unsigned:
	addi	$sp,	$sp,	-56
	sw	$fp,	56($sp)
	sw	$ra,	52($sp)
	sw	$s0,	48($sp)
	sw	$s1,	44($sp)
	sw	$s2,	40($sp)
	sw	$s3,	36($sp)
	sw	$s4,	32($sp)#temp_Lo
	sw	$s5,	28($sp)#temp_Hi
	sw	$s6,	24($sp)
	sw	$s7,	20($sp)
	sw	$a0,	16($sp)
	sw	$a1,	12($sp)
	sw	$a2,	8($sp)
	addi	$fp,	$sp,	56	
	
	or	$s6,	$a0,	$zero
	or	$s7,	$a1,	$zero
	
	or	$s2,	$zero,	$zero	#i
	or	$s0,	$zero,	$zero	#Hi
	or	$s1,	$zero,	$zero	#Lo
	or	$s4,	$zero,	$zero
	or	$s5,	$zero,	$zero
loop_multipication:
	beq	$s2,	32,	end_multipication
	extract_nth_bit($s7,	$s2)
	beq	$v0,	$zero,	mul_zero
	
	or	$s4,	$s6,	$zero
	or	$s3,	$zero,	$zero	#j
	or	$s5,	$zero	$zero
loop_multipication_HiLo:	#divided Hi and Lo
	beq	$s3,	$s2,	end_HiLo_Loop
	
	li	$t1,	31
	extract_nth_bit($s4,	$t1)
	
	sll	$s4,	$s4,	1
	sll	$s5,	$s5,	1
	insert_to_nth_bit($s5,	$zero,	$v0)
	or	$s5,	$v0,	$zero
	
	addi	$s3,	$s3,	1	#j++
	j	loop_multipication_HiLo
	
end_HiLo_Loop:
	or	$a0,	$s0,	$zero
	or	$a1,	$s5,	$zero
	jal	au_logical_plus
	or	$s0,	$v0,	$zero
	
	or	$a0,	$s1,	$zero
	or	$a1,	$s4,	$zero
	jal	au_logical_plus
	or	$s1,	$v0,	$zero
	
mul_zero:
	addi	$s2,	$s2,	1	#i++
	j	loop_multipication
	
end_multipication:
	or	$v0,	$s1,	$zero
	or	$v1,	$s0,	$zero
	
	lw	$fp,	56($sp)
	lw	$ra,	52($sp)
	lw	$s0,	48($sp)
	lw	$s1,	44($sp)
	lw	$s2,	40($sp)
	lw	$s3,	36($sp)
	lw	$s4,	32($sp)#temp_Lo
	lw	$s5,	28($sp)#temp_Hi
	lw	$s6,	24($sp)
	lw	$s7,	20($sp)
	lw	$a0,	16($sp)
	lw	$a1,	12($sp)
	lw	$a2,	8($sp)
	addi	$sp,	$sp,	56
	
	jr	$ra
	
#######################################################3#

au_logical_division:
	addi	$sp,	$sp,	40
	sw	$fp,	40($sp)
	sw	$ra,	36($sp)
	sw	$s0,	32($sp)
	sw	$s1,	28($sp)
	sw	$s2,	24($sp)
	sw	$s3,	20($sp)
	sw	$a0,	16($sp)
	sw	$a1,	12($sp)
	sw	$a2,	8($sp)
	addi	$fp,	$sp,	40
	
	or	$s0,	$a0,	$zero
	or	$s1,	$a1,	$zero
	
	or	$s2,	$zero,	$zero
	or	$s3,	$zero,	$zero
	
	
	bgez	$s0,	invert_1_div
	not	$a0,	$s0
	not	$s2,	$s2
	not	$s3,	$s3
	li	$a1,	1
	jal	au_logical_plus
	or	$s0,	$v0,	$zero
invert_1_div:
	bgez	$s1,	invert_2_div
	not	$a0,	$s1
	not	$s2,	$s2
	li	$a1,	1
	jal	au_logical_plus
	or	$s1,	$v0,	$zero
invert_2_div:
	or	$a0,	$s0,	$zero	
	or	$a1,	$s1,	$zero
	jal	au_logical_unsigned_division
	or	$s0,	$v0,	$zero
	or	$s1,	$v1,	$zero
	
	beqz	$s2,	invert_3
	not	$a0,	$s0
	li	$a1,	1
	jal	au_logical_plus
	or	$s0,	$v0,	$zero
invert_3:
	bgez	$s3,	end_signed_div
	not	$a0,	$s1
	li	$a1,	1
	jal	au_logical_plus
	or	$s1,	$v0,	$zero

end_signed_div:
	or	$v0,	$s0,	$zero
	or	$v1,	$s1,	$zero
	
	lw	$fp,	40($sp)
	lw	$ra,	36($sp)
	lw	$s0,	32($sp)
	lw	$s1,	28($sp)
	lw	$s2,	24($sp)
	lw	$s3,	20($sp)
	lw	$a0,	16($sp)
	lw	$a1,	12($sp)
	lw	$a2,	8($sp)
	addi	$sp,	$sp,	40
	
	jr	$ra
	
au_logical_unsigned_division:

	addi	$sp,	$sp,	-44
	sw	$fp,	44($sp)
	sw	$ra,	40($sp)
	sw	$s0,	36($sp)
	sw	$s1,	32($sp)
	sw	$s2,	28($sp)
	sw	$s3,	24($sp)
	sw	$s4,	20($sp)
	sw	$a0,	16($sp)
	sw	$a1,	12($sp)
	sw	$a2,	8($sp)
	addi	$fp,	$sp,	44

	or	$s0,	$a0,	$zero
	or	$s1,	$a1,	$zero
	or	$s2,	$zero,	$zero	#i
	or	$s3,	$zero,	$zero	#R
	
loop_div:
	beq	$s2,	32,	end_unsigned_division
	sll	$s3,	$s3,	1	#	R = R << 1
	
	li	$s4,	31
	extract_nth_bit($s0,	$s4)
	#insert_to_nth_bit($s3,	$zero,	$v0)
	#move	$s3,	$v0
	or	$s3,	$s3,	$v0
	sll	$s0,	$s0,	1
	
	or	$a0,	$s3,	$zero
	or	$a1,	$s1,	$zero
	jal	au_logical_minus
	#move	$s4,	$v0	#	S = R - D
	bltz	$v0,	skip	#	if D < 0 
	or	$s3,	$v0,	$zero
	li	$t0,	1
	insert_to_nth_bit($s0,	$zero,	$t0)
	or	$s0,	$v0,	$zero
skip:
	addi	$s2,	$s2,	1	#i++
	j	loop_div
end_unsigned_division:	
	or	$v0,	$s0,	$zero
	or	$v1,	$s3,	$zero

	
	lw	$fp,	44($sp)
	lw	$ra,	40($sp)
	lw	$s0,	36($sp)
	lw	$s1,	32($sp)
	lw	$s2,	28($sp)
	lw	$s3,	24($sp)
	lw	$s4,	20($sp)
	lw	$a0,	16($sp)
	lw	$a1,	12($sp)
	lw	$a2,	8($sp)
	addi	$sp,	$sp,	44
	
	jr	$ra
	
#################################################################
#I wrote this utility after I finished the project and realized I could really have one
#But spending time on replacing the existing code would be against the purpose, so I didn't use it
twos_complement_invertor:
	not	$a0,	$a0
	li	$a1,	1
	jal	au_logical_plus
	jr	$ra
