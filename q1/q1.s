.section .text
.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sw a0, 4(sp)       

    li a0, 24          # size of struct Node
    call malloc

    mv t0, a0          # t0 = new node pointer
    lw t1, 4(sp)       

    sw t1, 0(t0)       # node->val = val
    sd zero, 8(t0)     # node->left = NULL
    sd zero, 16(t0)    # node->right = NULL

    # a0 already holds the returned node pointer from malloc/t0
    
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

insert:
    addi sp, sp, -32    
    sd ra, 24(sp)
    sd a0, 16(sp)       # save root

    beq a0, zero, insert_make

    lw t0, 0(a0)        # root->val

    blt a1, t0, left_case
    bgt a1, t0, right_case

    j insert_done       # if equal, do nothing

left_case:
    ld t1, 8(a0)        # root->left
    mv a0, t1
    call insert

    ld t2, 16(sp)       # restore root
    sd a0, 8(t2)        # root->left = returned node
    mv a0, t2
    j insert_done

right_case:
    ld t1, 16(a0)       # root->right
    mv a0, t1
    call insert

    ld t2, 16(sp)       # restore root
    sd a0, 16(t2)       # root->right = returned node
    mv a0, t2
    j insert_done

insert_make:
    mv a0, a1           # pass val
    call make_node      # returns new node in a0, which is correct for insert_done

insert_done:
    ld ra, 24(sp)
    addi sp, sp, 32     
    ret

get:
    beq a0, zero, not_found

    lw t0, 0(a0)        # root->val

    beq t0, a1, found
    blt a1, t0, go_left

go_right:
    ld a0, 16(a0)
    j get

go_left:
    ld a0, 8(a0)
    j get

found:
    ret

not_found:
    li a0, 0
    ret

getAtMost:
    li t0, -1           # result = -1

loop_atmost:
    beq a1, zero, done_atmost

    lw t1, 0(a1)        # current node value

    ble t1, a0, update  # if node <= val

go_left_atmost:
    ld a1, 8(a1)
    j loop_atmost

update:
    mv t0, t1           # save best valid candidate so far
    ld a1, 16(a1)       # go right to try to find a larger valid candidate
    j loop_atmost

done_atmost:
    mv a0, t0
    ret