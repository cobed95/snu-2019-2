##################################################
# test02
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

    # scope test02
main:
    # stack offsets:
    #    -16(%ebp)   4  [ $t0       <ptr(4) to <array 10 of <int>>> %ebp-16 ]
    #    -20(%ebp)   4  [ $t1       <int> %ebp-20 ]
    #    -24(%ebp)   4  [ $t10      <int> %ebp-24 ]
    #    -28(%ebp)   4  [ $t11      <int> %ebp-28 ]
    #    -32(%ebp)   4  [ $t12      <int> %ebp-32 ]
    #    -36(%ebp)   4  [ $t13      <int> %ebp-36 ]
    #    -40(%ebp)   4  [ $t14      <ptr(4) to <array 10 of <int>>> %ebp-40 ]
    #    -44(%ebp)   4  [ $t15      <int> %ebp-44 ]
    #    -48(%ebp)   4  [ $t16      <ptr(4) to <array 10 of <int>>> %ebp-48 ]
    #    -52(%ebp)   4  [ $t17      <int> %ebp-52 ]
    #    -56(%ebp)   4  [ $t18      <int> %ebp-56 ]
    #    -60(%ebp)   4  [ $t19      <int> %ebp-60 ]
    #    -64(%ebp)   4  [ $t2       <ptr(4) to <array 10 of <int>>> %ebp-64 ]
    #    -68(%ebp)   4  [ $t20      <int> %ebp-68 ]
    #    -72(%ebp)   4  [ $t3       <int> %ebp-72 ]
    #    -76(%ebp)   4  [ $t4       <int> %ebp-76 ]
    #    -80(%ebp)   4  [ $t5       <int> %ebp-80 ]
    #    -84(%ebp)   4  [ $t6       <int> %ebp-84 ]
    #    -88(%ebp)   4  [ $t7       <ptr(4) to <array 10 of <int>>> %ebp-88 ]
    #    -92(%ebp)   4  [ $t8       <int> %ebp-92 ]
    #    -96(%ebp)   4  [ $t9       <ptr(4) to <array 10 of <int>>> %ebp-96 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $84, %esp               # make room for locals

    cld                             # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $21, %ecx              
    mov     %esp, %edi             
    rep     stosl                  

    # function body
    leal    a, %eax                 #   0:     &()    t0 <- a
    movl    %eax, -16(%ebp)        
    movl    $0, %eax                #   1:     mul    t1 <- 0, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -20(%ebp)        
    leal    a, %eax                 #   2:     &()    t2 <- a
    movl    %eax, -64(%ebp)        
    movl    -64(%ebp), %eax         #   3:     param  0 <- t2
    pushl   %eax                   
    call    DOFS                    #   4:     call   t3 <- DOFS
    addl    $4, %esp               
    movl    %eax, -72(%ebp)        
    movl    -20(%ebp), %eax         #   5:     add    t4 <- t1, t3
    movl    -72(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -76(%ebp)        
    movl    -16(%ebp), %eax         #   6:     add    t5 <- t0, t4
    movl    -76(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -80(%ebp)        
    movl    $1, %eax                #   7:     assign @t5 <- 1
    movl    -80(%ebp), %edi        
    movl    %eax, (%edi)           
    movl    $1, %eax                #   8:     assign i <- 1
    movl    %eax, i                
l_test02_3_while_cond:
    movl    i, %eax                 #  10:     if     i < 10 goto 4_while_body
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    jl      l_test02_4_while_body  
    jmp     l_test02_2              #  11:     goto   2
l_test02_4_while_body:
    movl    $10, %eax               #  13:     sub    t6 <- 10, i
    movl    i, %ebx                
    subl    %ebx, %eax             
    movl    %eax, -84(%ebp)        
    leal    a, %eax                 #  14:     &()    t7 <- a
    movl    %eax, -88(%ebp)        
    movl    i, %eax                 #  15:     mul    t8 <- i, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -92(%ebp)        
    leal    a, %eax                 #  16:     &()    t9 <- a
    movl    %eax, -96(%ebp)        
    movl    -96(%ebp), %eax         #  17:     param  0 <- t9
    pushl   %eax                   
    call    DOFS                    #  18:     call   t10 <- DOFS
    addl    $4, %esp               
    movl    %eax, -24(%ebp)        
    movl    -92(%ebp), %eax         #  19:     add    t11 <- t8, t10
    movl    -24(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -28(%ebp)        
    movl    -88(%ebp), %eax         #  20:     add    t12 <- t7, t11
    movl    -28(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -32(%ebp)        
    movl    -84(%ebp), %eax         #  21:     assign @t12 <- t6
    movl    -32(%ebp), %edi        
    movl    %eax, (%edi)           
    movl    i, %eax                 #  22:     add    t13 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -36(%ebp)        
    movl    -36(%ebp), %eax         #  23:     assign i <- t13
    movl    %eax, i                
    jmp     l_test02_3_while_cond   #  24:     goto   3_while_cond
l_test02_2:
    movl    $0, %eax                #  26:     assign i <- 0
    movl    %eax, i                
l_test02_9_while_cond:
    movl    i, %eax                 #  28:     if     i < 10 goto 10_while_body
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    jl      l_test02_10_while_body 
    jmp     l_test02_8              #  29:     goto   8
l_test02_10_while_body:
    leal    a, %eax                 #  31:     &()    t14 <- a
    movl    %eax, -40(%ebp)        
    movl    i, %eax                 #  32:     mul    t15 <- i, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -44(%ebp)        
    leal    a, %eax                 #  33:     &()    t16 <- a
    movl    %eax, -48(%ebp)        
    movl    -48(%ebp), %eax         #  34:     param  0 <- t16
    pushl   %eax                   
    call    DOFS                    #  35:     call   t17 <- DOFS
    addl    $4, %esp               
    movl    %eax, -52(%ebp)        
    movl    -44(%ebp), %eax         #  36:     add    t18 <- t15, t17
    movl    -52(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -56(%ebp)        
    movl    -40(%ebp), %eax         #  37:     add    t19 <- t14, t18
    movl    -56(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -60(%ebp)        
    movl    -60(%ebp), %edi        
    movl    (%edi), %eax            #  38:     param  0 <- @t19
    pushl   %eax                   
    call    WriteInt                #  39:     call   WriteInt
    addl    $4, %esp               
    movl    i, %eax                 #  40:     add    t20 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -68(%ebp)        
    movl    -68(%ebp), %eax         #  41:     assign i <- t20
    movl    %eax, i                
    jmp     l_test02_9_while_cond   #  42:     goto   9_while_cond
l_test02_8:

l_test02_exit:
    # epilogue
    addl    $84, %esp               # remove locals
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

    # scope: test02
a:                                  # <array 10 of <int>>
    .long    1
    .long   10
    .skip   40
b:                                  # <bool>
    .skip    1
    .align   4
c:                                  # <array 2 of <bool>>
    .long    1
    .long    2
    .skip    2
    .align   4
i:                                  # <int>
    .skip    4

    # end of global data section
    #-----------------------------------------

    .end
##################################################
