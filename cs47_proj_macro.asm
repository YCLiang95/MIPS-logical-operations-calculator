# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
.include "./cs47_common_macro.asm"

.macro extract_nth_bit($regS,	$regT)
	addi	$sp,	$sp,	-20
	sw	$fp,	20($sp)
	sw	$ra,	16($sp)
	sw	$regS,	12($sp)
	sw	$regT,	8($sp)
	addi	$fp,	$sp,	20
	
	srlv	$t0,	$regS,	$regT
	and	$v0,	$t0,	1
	
	lw	$fp,	20($sp)
	lw	$ra,	16($sp)
	lw	$regS,	12($sp)
	lw	$regT,	8($sp)
	addi	$sp,	$sp,	20
.end_macro

.macro insert_to_nth_bit($regD,	$regS,	$regT)
	addi	$sp,	$sp,	-24
	sw	$fp,	24($sp)
	sw	$ra,	20($sp)
	sw	$regD,	16($sp)
	sw	$regS,	12($sp)
	sw	$regT,	8($sp)
	addi	$fp,	$sp,	24
	
	li	$t0,	0x1
	sllv	$t1,	$t0,	$regS
	not	$t1,	$t1
	and	$regD,	$regD,	$t1
	
	sllv	$t1,	$regT,	$regS
	or	$v0,	$t1,	$regD
	
	lw	$fp,	24($sp)
	lw	$ra,	20($sp)
	lw	$regD,	16($sp)
	lw	$regS,	12($sp)
	lw	$regT,	8($sp)
	addi	$sp,	$sp,	24
.end_macro
