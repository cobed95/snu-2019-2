##################################################
# test01
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

    # scope test01
main:
    # stack offsets:                        
#            0(%ebp)   4 [ *DIM(<ptr(4) to <NULL>>,<int>) --> <int> ]
#            0(%ebp)   4 [ *DOFS(<ptr(4) to <NULL>>) --> <int> ]
#            0(%ebp)   4 [ *ReadInt() --> <int> ]
#            0(%ebp)   0 [ *WriteChar(<char>) --> <NULL> ]
#            0(%ebp)   0 [ *WriteInt(<int>) --> <NULL> ]
#            0(%ebp)   0 [ *WriteLn() --> <NULL> ]
#            0(%ebp)   0 [ *WriteStr(<ptr(4) to <array of <char>>>) --> <NULL> ]
#            0(%ebp)   4 [ @a        <int> ]
#            0(%ebp)   4 [ @b        <int> ]
#            0(%ebp)   4 [ @c        <int> ]
#            0(%ebp)   0 [ main     <NULL> ]
#          -16(%ebp)   4 [ $t0       <int> %ebp-16 ]
#          -20(%ebp)   4 [ $t1       <int> %ebp-20 ]
#          -24(%ebp)   4 [ $t2       <int> %ebp-24 ]
#          -28(%ebp)   4 [ $t3       <int> %ebp-28 ]

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
    movl    $2, %eax                #   0:     assign a <- 2
    movl    %eax, a                
    movl    $5, %eax                #   1:     assign b <- 5
    movl    %eax, b                
    movl    a, %eax                 #   2:     add    t0 <- a, b
    movl    b, %ebx                
    addl    %ebx, %eax             
    movl    %eax, -16(%ebp)        
    movl    -16(%ebp), %eax         #   3:     assign c <- t0
    movl    %eax, c                
    movl    c, %eax                 #   4:     param  0 <- c
    pushl   %eax                    #   4:     param  0 <- c
    call    WriteInt                #   5:     call   WriteInt
    popl    %edx                    #   5:     call   WriteInt
    movl    a, %eax                 #   6:     mul    t1 <- a, b
    movl    b, %ebx                
    imull   %ebx                   
    movl    %eax, -20(%ebp)        
    movl    -20(%ebp), %eax         #   7:     assign c <- t1
    movl    %eax, c                
    movl    c, %eax                 #   8:     param  0 <- c
    pushl   %eax                    #   8:     param  0 <- c
    call    WriteInt                #   9:     call   WriteInt
    popl    %edx                    #   9:     call   WriteInt
    movl    b, %eax                 #  10:     neg    t2 <- b
    negl    %eax                   
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #  11:     add    t3 <- t2, a
    movl    a, %ebx                
    addl    %ebx, %eax             
    movl    %eax, -28(%ebp)        
    movl    -28(%ebp), %eax         #  12:     assign c <- t3
    movl    %eax, c                
    movl    c, %eax                 #  13:     param  0 <- c
    pushl   %eax                    #  13:     param  0 <- c
    call    WriteInt                #  14:     call   WriteInt
    popl    %edx                    #  14:     call   WriteInt

l_test01_exit:
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

    # scope: test01
a:                                  # <int>
    .skip    4
b:                                  # <int>
    .skip    4
c:                                  # <int>
    .skip    4

    # end of global data section
    #-----------------------------------------

    .end
##################################################
