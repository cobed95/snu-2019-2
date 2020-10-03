##################################################
# test12
#

    #-----------------------------------------
    # text section
    #
    .text
    .align 4

    # entry point and pre-defined functions
    .global main
    .extern DIM
    .extern DOFS
    .extern ReadInt
    .extern WriteInt
    .extern WriteStr
    .extern WriteChar
    .extern WriteLn

    # scope Int
Int:
    # stack offsets:                        
#          -16(%ebp)   4 [ $i        <int> %ebp-16 ]

    # prologue                        
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $8, %esp                # # make room for locals
    cld                             # # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $8, %ecx               
    mov     %esp, %edi             
    rep     stosl                  
