##################################################
# test10
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

    # scope sum_rec
sum_rec:
    # stack offsets:                        
#            8(%ebp)   4 [ %n        <int> %ebp+8 ]
#          -16(%ebp)   4 [ $t11      <int> %ebp-16 ]
#          -20(%ebp)   4 [ $t12      <int> %ebp-20 ]
#          -24(%ebp)   4 [ $t13      <int> %ebp-24 ]

    # prologue                        
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $16, %esp               # # make room for locals
    cld                             # # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $8, %ecx               
    mov     %esp, %edi             
    rep     stosl                  
