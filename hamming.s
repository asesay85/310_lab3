.section .data

msg1:   .ascii "Please enter the first string to compare (255 characters max):\n"
len1 = . - msg1

msg2:   .ascii "Please enter the second string to compare (255 characters max):\n"
len2 = . - msg2

.section .bss
.lcomm buffer1, 256
.lcomm buffer2, 256
.lcomm outbuf, 16

.section .text
.globl _start  #make this function visible to c program

_start:
    # PROMPT FOR USER INPUT
    mov $1, %rax     # write
    mov $1, %rdi     # stdout 
    mov $msg1, %rsi   # buf
    mov $len1, %rdx   #len
    syscall


    mov $0, %rax             # requesting read operation from system
    mov $0, %rdi             # read from stdin (keyboard)
    mov $buffer1, %rsi       # where the input will be stored
    mov $256, %rdx           # max number of bytes to read
    syscall                  # Invoke the kernel
    mov %rax, %r12           # save length of string 1 right after the read

   
    # PROMPT FOR 2ND USER INPUT
    mov $1, %rax     # write
    mov $1, %rdi     # stdout 
    mov $msg2, %rsi   # buf
    mov $len2, %rdx   #len
    syscall


    mov $0, %rax             # requesting read operation from system
    mov $0, %rdi             # read from stdin (keyboard)
    mov $buffer2, %rsi       # where the input will be stored
    mov $256, %rdx           # max number of bytes to read
    syscall                  # Invoke the kernel
    mov %rax, %r13           # save length of string 2 right after the read


    # CALCULATION OF SHORTER STRING 
    dec %r12                # remove newline character from string1
    dec %r13                # remove newline character from string2

    mov %r12, %r14    # assume string stored in r12 (first string) to be shorter 
    cmp %r13, %r14    # r14 - r13 (only sets flags)
    jle post_calc     # jump if r14 <= r13 (ZF=1 or SF!=OF): assumption was correct, keep r14
                      # ZF = Zero Flag (oeprands were equal), SF != OF: negative result
    mov %r13, %r14    # assuumption was wrong, other string's length is shorter
    

post_calc:
    mov $buffer1, %rsi
    mov $buffer2, %rdi
    mov $0, %r8      # r8 register will count differences 
    mov $0, %r9      # r9 register will be the index we iterate with
    cmp $0, %r14     # case where the length of the string is 0, the hamming distance is 0

hamming_loop:
    movzbl (%rsi, %r9), %eax   # load 1 byte (1 character) from string 1
    movzbl (%rdi, %r9), %ebx   # load 1 byte (1 character) from string 2
    xor %ebx, %eax             # mask bits where they differ

bit_loop:
    mov %eax, %ecx      # copy the mask above: and overwrites its destination, but we still need the full mask to keep shifting bits
                        # also defines rcx
    and $1, %ecx        # isolate the lowest bit (0 or 1)
    add %rcx, %r8       # add that bit to the total
    shr $1, %eax        # shift the mask right by one
    jnz bit_loop        # repeat if the mask isn't all 0's yet

    inc %r9                     # i++
    cmp %r14, %r9               # compares our index against our short string length
    jl hamming_loop             # keep going while i < limit


print_result:                   # convert r8 to text, filling outbuf backward
    mov $outbuf+15, %rsi
    movb $10, (%rsi)            # trailing newline
    mov %r8, %rax               # number to convert
    mov $10, %rbx               # divisor

digit_loop:
    xor %rdx, %rdx              # div uses rdx:rax, so clear rdx
    div %rbx                    # rax = quotient, rdx = remainder
    add $48, %dl                # remainder -> ASCII digit
    dec %rsi
    mov %dl, (%rsi)
    test %rax, %rax
    jnz digit_loop              # stop when the quotient is 0

    mov $outbuf+16, %rdx
    sub %rsi, %rdx              # length = digits + newline
    mov $1, %rax
    mov $1, %rdi
    syscall


    mov $60, %rax    #exit
    mov $0, %rdi    # status
    syscall