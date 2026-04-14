
.text
.globl main

main:
    # save ra and all s-registers we plan to use
    addi    sp, sp, -64
    sd      ra, 56(sp)
    sd      s0, 48(sp)
    sd      s1, 40(sp)
    sd      s2, 32(sp)
    sd      s3, 24(sp)
    sd      s4, 16(sp)
    sd      s5, 8(sp)
    sd      s6, 0(sp)

    # a0 = argc, a1 = argv
    addi    s0, a0, -1          # n = argc - 1
    mv      s5, a1              # save argv pointer

    blez    s0, exit_program    # if n <= 0, exit gracefully

    # give/allocat arr[n]
    slli    a0, s0, 2           # bytes = n * 4
    call    malloc
    mv      s1, a0              # s1 = arr

    # allocate result[n]
    slli    a0, s0, 2
    call    malloc
    mv      s2, a0              # s2 = result

    # initialize result array to
    li      s6, 0               # i = 0
init_array:
    bge     s6, s0, done_init
    slli    t0, s6, 2
    add     t0, s2, t0
    li      t1, -1
    sw      t1, 0(t0)           # result[i] = -1
    addi    s6, s6, 1
    j       init_array
done_init:

    # allocate stk[n]
    slli    a0, s0, 2
    call    malloc
    mv      s3, a0              # s3 = stk
    li      s4, -1              # s4 = stktop (-1)

    # Parse argv and populate arr
    li      s6, 0               # i = 0
read_args:
    bge     s6, s0, done_reading
    addi    t0, s6, 1           # argv index = i + 1
    slli    t0, t0, 3           # 8 bytes per pointer in 64-bit
    add     t0, s5, t0
    ld      a0, 0(t0)           # a0 = string pointer
    
    call    atoi                # convert to int
    
    slli    t1, s6, 2
    add     t1, s1, t1
    sw      a0, 0(t1)           # arr[i] = integer value
    addi    s6, s6, 1
    j       read_args
done_reading:

    # NGE Algorithm
    addi    s6, s0, -1          # i = n - 1 start from right
calc_nge:
    bltz    s6, done_nge        # loop until i < 0

    slli    t0, s6, 2
    add     t0, s1, t0
    lw      t1, 0(t0)           # t1 = arr[i]

    # Pop elements from stack that are <= arr[i]
clean_stack:
    bltz    s4, assign_result   # stack empty? break pop loop
    slli    t2, s4, 2
    add     t2, s3, t2
    lw      t2, 0(t2)           # t2 = stk[stktop] (index)
    
    slli    t3, t2, 2
    add     t3, s1, t3
    lw      t3, 0(t3)           # t3 = arr[stk.top()]
    
    bgt     t3, t1, assign_result # if arr[top] > arr[i], stop popping
    
    addi    s4, s4, -1          # pop from stack
    j       clean_stack

assign_result:
    bltz    s4, push_current    # if stack empty, leave result as -1
    slli    t2, s4, 2
    add     t2, s3, t2
    lw      t2, 0(t2)           # t2 = stk.top() index
    
    slli    t3, s6, 2
    add     t3, s2, t3
    sw      t2, 0(t3)           # result[i] = index of next greater

push_current:
    addi    s4, s4, 1           # increment top
    slli    t2, s4, 2
    add     t2, s3, t2
    sw      s6, 0(t2)           # stk[stktop] = i

    addi    s6, s6, -1          # i--
    j       calc_nge
done_nge:

    # print Output
    li      s6, 0               # i = 0
display_results:
    bge     s6, s0, finish_print

    slli    t0, s6, 2
    add     t0, s2, t0
    lw      a1, 0(t0)           # load result[i]
    la      a0, str_int
    call    printf

    # Print space only if not the last element
    addi    t1, s0, -1
    bge     s6, t1, skip_space
    la      a0, str_space
    call    printf

skip_space:
    addi    s6, s6, 1
    j       display_results

finish_print:
    la      a0, str_nl
    call    printf

exit_program:
    li      a0, 0               # return code 0
    # Epilogue: restore saved registers
    ld      ra, 56(sp)
    ld      s0, 48(sp)
    ld      s1, 40(sp)
    ld      s2, 32(sp)
    ld      s3, 24(sp)
    ld      s4, 16(sp)
    ld      s5, 8(sp)
    ld      s6, 0(sp)
    addi    sp, sp, 64
    ret

# Read-Only Data strings
.section .rodata
str_int:    .string "%d"
str_space:  .string " "
str_nl:     .string "\n"