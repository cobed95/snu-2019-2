##################################################
# test04
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

    # scope test04
main:
    # stack offsets:
    #    -13(%ebp)   1  [ $t0       <bool> %ebp-13 ]
    #    -20(%ebp)   4  [ $t1       <ptr(4) to <array 10 of <bool>>> %ebp-20 ]
    #    -24(%ebp)   4  [ $t10      <ptr(4) to <array 10 of <bool>>> %ebp-24 ]
    #    -28(%ebp)   4  [ $t11      <int> %ebp-28 ]
    #    -32(%ebp)   4  [ $t12      <int> %ebp-32 ]
    #    -36(%ebp)   4  [ $t13      <int> %ebp-36 ]
    #    -40(%ebp)   4  [ $t14      <int> %ebp-40 ]
    #    -44(%ebp)   4  [ $t2       <int> %ebp-44 ]
    #    -48(%ebp)   4  [ $t3       <ptr(4) to <array 10 of <bool>>> %ebp-48 ]
    #    -52(%ebp)   4  [ $t4       <int> %ebp-52 ]
    #    -56(%ebp)   4  [ $t5       <int> %ebp-56 ]
    #    -60(%ebp)   4  [ $t6       <int> %ebp-60 ]
    #    -64(%ebp)   4  [ $t7       <int> %ebp-64 ]
    #    -68(%ebp)   4  [ $t8       <ptr(4) to <array 10 of <bool>>> %ebp-68 ]
    #    -72(%ebp)   4  [ $t9       <int> %ebp-72 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $60, %esp               # make room for locals

    cld                             # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $15, %ecx              
    mov     %esp, %edi             
    rep     stosl                  

    # function body
    movl    $0, %eax                #   0:     assign i <- 0
    movl    %eax, i                
l_test04_2_while_cond:
    movl    i, %eax                 #   2:     if     i < 10 goto 3_while_body
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    jl      l_test04_3_while_body  
    jmp     l_test04_1              #   3:     goto   1
l_test04_3_while_body:
    movl    i, %eax                 #   5:     if     i > 2 goto 5
    movl    $2, %ebx               
    cmpl    %ebx, %eax             
    jg      l_test04_5             
    jmp     l_test04_6              #   6:     goto   6
l_test04_5:
    movl    $1, %eax                #   8:     assign t0 <- 1
    movb    %al, -13(%ebp)         
    jmp     l_test04_7              #   9:     goto   7
l_test04_6:
    movl    $0, %eax                #  11:     assign t0 <- 0
    movb    %al, -13(%ebp)         
l_test04_7:
    leal    a, %eax                 #  13:     &()    t1 <- a
    movl    %eax, -20(%ebp)        
    movl    i, %eax                 #  14:     mul    t2 <- i, 1
    movl    $1, %ebx               
    imull   %ebx                   
    movl    %eax, -44(%ebp)        
    leal    a, %eax                 #  15:     &()    t3 <- a
    movl    %eax, -48(%ebp)        
    movl    -48(%ebp), %eax         #  16:     param  0 <- t3
    pushl   %eax                   
    call    DOFS                    #  17:     call   t4 <- DOFS
    addl    $4, %esp               
    movl    %eax, -52(%ebp)        
    movl    -44(%ebp), %eax         #  18:     add    t5 <- t2, t4
    movl    -52(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -56(%ebp)        
    movl    -20(%ebp), %eax         #  19:     add    t6 <- t1, t5
    movl    -56(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -60(%ebp)        
    movzbl  -13(%ebp), %eax         #  20:     assign @t6 <- t0
    movl    -60(%ebp), %edi        
    movb    %al, (%edi)            
    movl    i, %eax                 #  21:     add    t7 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -64(%ebp)        
    movl    -64(%ebp), %eax         #  22:     assign i <- t7
    movl    %eax, i                
    jmp     l_test04_2_while_cond   #  23:     goto   2_while_cond
l_test04_1:
    movl    $0, %eax                #  25:     assign i <- 0
    movl    %eax, i                
l_test04_11_while_cond:
    movl    i, %eax                 #  27:     if     i < 10 goto 12_while_body
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    jl      l_test04_12_while_body 
    jmp     l_test04_10             #  28:     goto   10
l_test04_12_while_body:
    leal    a, %eax                 #  30:     &()    t8 <- a
    movl    %eax, -68(%ebp)        
    movl    i, %eax                 #  31:     mul    t9 <- i, 1
    movl    $1, %ebx               
    imull   %ebx                   
    movl    %eax, -72(%ebp)        
    leal    a, %eax                 #  32:     &()    t10 <- a
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #  33:     param  0 <- t10
    pushl   %eax                   
    call    DOFS                    #  34:     call   t11 <- DOFS
    addl    $4, %esp               
    movl    %eax, -28(%ebp)        
    movl    -72(%ebp), %eax         #  35:     add    t12 <- t9, t11
    movl    -28(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -32(%ebp)        
    movl    -68(%ebp), %eax         #  36:     add    t13 <- t8, t12
    movl    -32(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -36(%ebp)        
    movl    -36(%ebp), %edi        
    movzbl  (%edi), %eax            #  37:     if     @t13 = 1 goto 14_if_true
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test04_14_if_true    
    jmp     l_test04_15_if_false    #  38:     goto   15_if_false
l_test04_14_if_true:
    movl    $1, %eax                #  40:     param  0 <- 1
    pushl   %eax                   
    call    WriteInt                #  41:     call   WriteInt
    addl    $4, %esp               
    jmp     l_test04_13             #  42:     goto   13
l_test04_15_if_false:
    movl    $0, %eax                #  44:     param  0 <- 0
    pushl   %eax                   
    call    WriteInt                #  45:     call   WriteInt
    addl    $4, %esp               
l_test04_13:
    movl    i, %eax                 #  47:     add    t14 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -40(%ebp)        
    movl    -40(%ebp), %eax         #  48:     assign i <- t14
    movl    %eax, i                
    jmp     l_test04_11_while_cond  #  49:     goto   11_while_cond
l_test04_10:

l_test04_exit:
    # epilogue
    addl    $60, %esp               # remove locals
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

    # scope: test04
a:                                  # <array 10 of <bool>>
    .long    1
    .long   10
    .skip   10
    .align   4
i:                                  # <int>
    .skip    4

    # end of global data section
    #-----------------------------------------

    .end
##################################################
