##################################################
# test11
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

    # scope foo
foo:
    # stack offsets:                        
#          -16(%ebp)   4 [ $a        <int> %ebp-16 ]
#          -17(%ebp)   1 [ $b        <bool> %ebp-17 ]
#          -24(%ebp)   4 [ $c        <int> %ebp-24 ]
#          -25(%ebp)   1 [ $d        <char> %ebp-25 ]
#          -32(%ebp)   4 [ $e        <int> %ebp-32 ]
#          -33(%ebp)   1 [ $f        <bool> %ebp-33 ]
#          -84(%ebp)  48 [ $g        <array 10 of <int>> %ebp-84 ]
#          -85(%ebp)   1 [ $h        <bool> %ebp-85 ]
#         -100(%ebp)  15 [ $i        <array 7 of <char>> %ebp-100 ]
#         -104(%ebp)   4 [ $j        <int> %ebp-104 ]

    # prologue                        
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $96, %esp               # # make room for locals
    cld                             # # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $8, %ecx               
    mov     %esp, %edi             
    rep     stosl                  
