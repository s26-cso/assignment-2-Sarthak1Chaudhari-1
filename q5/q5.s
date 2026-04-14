.section .data
filename: .asciz "input.txt"
yes_msg:  .asciz "Yes\n"
no_msg:   .asciz "No\n"

.section .text
.globl main
main:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    sd s2, 32(sp)
    sd s3, 24(sp)

    # open file
    la a0, filename
    li a1, 0
    call open
    mv s0, a0        # s0 = file descriptor

    # get file size using lseek(fd, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2         # SEEK_END
    call lseek
    mv s1, a0        # s1 = size

    li s2, 0         # s2 = left index
    addi s3, s1, -1  # s3 = right index

loop:
    bge s2, s3, is_palindrome

    # read left char at s2
    mv a0, s0
    mv a1, s2
    li a2, 0         # SEEK_SET
    call lseek
    mv a0, s0
    mv a1, sp
    li a2, 1
    call read
    lb t0, 0(sp)     # t0 = left char

    # read right char at s3
    mv a0, s0
    mv a1, s3
    li a2, 0         # SEEK_SET
    call lseek
    mv a0, s0
    mv a1, sp
    li a2, 1
    call read
    lb t1, 0(sp)     # t1 = right char

    bne t0, t1, not_palindrome
    addi s2, s2, 1
    addi s3, s3, -1
    j loop

is_palindrome:
    la a0, yes_msg
    call printf
    j done

not_palindrome:
    la a0, no_msg
    call printf

done:
    mv a0, s0
    call close
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    addi sp, sp, 64
    li a0, 0
    ret

