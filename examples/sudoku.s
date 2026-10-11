.text 
start:
	li sp 0x10000
	la s0 inputcnt
	lw s0 0(s0)
	la s5 inputs

input_loop:
	add a0 s5 zero
	addi a1 zero 0
	jal solve

	addi s5 s5 16
	addi s0 s0 -1
	bnez s0 input_loop

	la s0 inputcnt
	lw s0 0(s0)
	la s1 inputs
	la s2 answers
loop_answers:
	li s3 16
	addi s4 zero 0

	loop_answer:
		lb t2 0(s1)
		lb t3 0(s2)
		beq t2 t3 skip_different

		addi s4 s4 1

		skip_different:
		addi s1 s1 1
		addi s2 s2 1
		addi s3 s3 -1
		bnez s3 loop_answer

	li t4 0x10000
	sw s4 0(t4)

	addi s0 s0 -1
	bnez s0 loop_answers
	hcf

#########################################
####### Modify this part! #############>>

solve:
    addi sp sp -32
    sw ra 28(sp)
    sw s0 24(sp)
    sw s1 20(sp)
    sw s2 16(sp)
    sw s3 12(sp)
    sw s4 8(sp)
    sw s5 4(sp)

    add s0 a0 zero

outer_pass:
    addi s1 zero 0
    addi s2 zero 0

cell_loop:
    addi t0 zero 16
    beq s2 t0 pass_done

    add t0 s0 s2
    lbu t1 0(t0)
    bnez t1 next_cell

    addi s3 zero 1
    addi s4 zero 0
    addi s5 zero 0

candidate_loop:
    addi t0 zero 5
    beq s3 t0 candidate_done

    add a0 s0 zero
    add a1 s2 zero
    add a2 s3 zero
    jal x1 can_place

    beq a0 zero next_candidate

    addi s4 s4 1
    add s5 s3 zero

next_candidate:
    addi s3 s3 1
    jal x0 candidate_loop

candidate_done:
    addi t0 zero 1
    bne s4 t0 next_cell

    add t0 s0 s2
    sb s5 0(t0)
    addi s1 s1 1

next_cell:
    addi s2 s2 1
    jal x0 cell_loop

pass_done:
    beq s1 zero solve_done
    jal x0 outer_pass

solve_done:
    lw s5 4(sp)
    lw s4 8(sp)
    lw s3 12(sp)
    lw s2 16(sp)
    lw s1 20(sp)
    lw s0 24(sp)
    lw ra 28(sp)
    addi sp sp 32
    ret
can_place:
    # Check row
    andi t0, a1, -4
    addi t1, t0, 4

row_loop:
    beq t0, t1, check_col
    add t2, a0, t0
    lbu t3, 0(t2)
    beq t3, a2, not_allowed
    addi t0, t0, 1
    jal x0, row_loop

check_col:
    # Check column
    andi t0, a1, 3
    addi t1, t0, 16

col_loop:
    beq t0, t1, check_box
    add t2, a0, t0
    lbu t3, 0(t2)
    beq t3, a2, not_allowed
    addi t0, t0, 4
    jal x0, col_loop

check_box:
    # Find the starting index of the 2x2 box
    andi t0, a1, 8
    andi t1, a1, 2
    add t0, t0, t1
    add t2, a0, t0

    # Check first cell
    lbu t3, 0(t2)
    beq t3, a2, not_allowed

    # Check second cell
    addi t2, t2, 1
    lbu t3, 0(t2)
    beq t3, a2, not_allowed

    # Check third cell
    addi t2, t2, 3
    lbu t3, 0(t2)
    beq t3, a2, not_allowed

    # Check fourth cell
    addi t2, t2, 1
    lbu t3, 0(t2)
    beq t3, a2, not_allowed

    li a0, 1
    ret

not_allowed:
    li a0, 0
    ret	

### Do not modify beyond this point! ##<<
#########################################


.data
inputcnt:
.word 3
inputs: 
.byte 0 4 3 0 0 0 4 2 0 2 0 0 3 0 0 0
.byte 0 0 3 0 0 4 0 2 0 0 2 0 0 2 0 3
.byte 0 3 0 4 0 0 2 0 4 0 3 0 0 0 0 2

answers:
.byte 2 4 3 1 1 3 4 2 4 2 1 3 3 1 2 4 
.byte 2 1 3 4 3 4 1 2 4 3 2 1 1 2 4 3 
.byte 2 3 1 4 1 4 2 3 4 2 3 1 3 1 4 2 
