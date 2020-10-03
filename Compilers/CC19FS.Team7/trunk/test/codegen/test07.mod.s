##################################################
# test07
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

    # scope test07
main:
    # stack offsets:                        
#            0(%ebp)   4 [ *DIM(<ptr(4) to <NULL>>,<int>) --> <int> ]
#            0(%ebp)   4 [ *DOFS(<ptr(4) to <NULL>>) --> <int> ]
#          -20(%ebp)   8 [ =HelloWorld <array of <char>> ]
#            0(%ebp)   4 [ *ReadInt() --> <int> ]
#            0(%ebp)   0 [ *WriteChar(<char>) --> <NULL> ]
#            0(%ebp)   0 [ *WriteInt(<int>) --> <NULL> ]
#            0(%ebp)   0 [ *WriteLn() --> <NULL> ]
#            0(%ebp)   0 [ *WriteStr(<ptr(4) to <array of <char>>>) --> <NULL> ]
#            0(%ebp)  22 [ @_str_1   <array 14 of <char>> ]
#            0(%ebp)  22 [ @_str_2   <array 14 of <char>> ]
#            0(%ebp)   0 [ main     <NULL> ]
#          -24(%ebp)   4 [ $t0       <ptr(4) to <array 14 of <char>>> %ebp-24 ]
#          -28(%ebp)   4 [ $t1       <ptr(4) to <array 14 of <char>>> %ebp-28 ]

    # prologue                        
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $20, %esp               # # make room for locals
    cld                             # # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $8, %ecx               
    mov     %esp, %edi             
    rep     stosl                  

    # function body                        
    movl    _str_2, %ebx            #   0:     &()    t0 <- _str_2
    leal    (%ebx), %eax           
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #   1:     param  0 <- t0
    pushl   %eax                    #   1:     param  0 <- t0
    call    WriteStr                #   2:     call   WriteStr
    popl    %edx                    #   2:     call   WriteStr
    call    WriteLn                 #   3:     call   WriteLn
    movl    _str_1, %ebx            #   4:     &()    t1 <- _str_1
    leal    (%ebx), %eax           
    movl    %eax, -28(%ebp)        
    movl    -28(%ebp), %eax         #   5:     param  0 <- t1
    pushl   %eax                    #   5:     param  0 <- t1
    call    WriteStr                #   6:     call   WriteStr
    popl    %edx                    #   6:     call   WriteStr
    call    WriteLn                 #   7:     call   WriteLn

l_test07_exit:
    # epilogue                        
    addl    $20, %esp               # # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # end of text section
    #-----------------------------------------

    #-----------------------------------------
    # global data section
    #
    .data
    .align 4

    # scope: test07
_str_1:                             # <array 14 of <char>>
    .long    1
    .long   14
    .asciz "Hello, world!"
    .align   4
_str_2:                             # <array 14 of <char>>
    .long    1
    .long   14
    .asciz "Hello, world!"

    # end of global data section
    #-----------------------------------------

    .end
##################################################
