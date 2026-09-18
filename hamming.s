.section .data

msg1:   .ascii "Please enter the first string to compare (255 characters max):\n"
len1 = . - msg1

msg2:   .ascii "Please enter the second string to compare (255 characters max):\n"
len2 = . - msg2

.section .bss
.lcomm buffer1, 256
.lcomm buffer2, 256

.section .text
.globl _start  #make this function visible to c program

_start:
    # PROMPT FOR USER INPUT
    mov $1, %rax     # write
    mov $1, %rdi     # stdout 
    mov $msg1,%rsi   # buf
    mov $len1,%rdx   #len
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
    mov $msg2,%rsi   # buf
    mov $len2,%rdx   #len
    syscall


    mov $0, %rax             # requesting read operation from system
    mov $0, %rdi             # read from stdin (keyboard)
    mov $buffer2, %rsi       # where the input will be stored
    mov $256, %rdx           # max number of bytes to read
    syscall                  # Invoke the kernel
    mov %rax, %r13           # save length of string 2 right after the read


    # CALCULATION OF SHORTER STRING 
    mov %r12, %r14    # assume string stored in r12 (first string) to be shorter 
    cmp %r13, %r14    # r14 - r13 (only sets flags)
    jle hamming_loop  # jump if r14 <= r13 (ZF=1 or SF!=OF): assumption was correct, keep r14
                      # ZF = Zero Flag (oeprands were equal), SF != OF: negative result
    mov %r13, %r14
    
    hamming_loop:


    mov $60, %rax    #exit
    mov $0, %rdi    # status
    syscall