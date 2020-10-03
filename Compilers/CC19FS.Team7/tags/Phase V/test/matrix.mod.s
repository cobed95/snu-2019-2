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

    # scope minit
minit:
    # stack offsets:
    #      8(%ebp)   4  [ %m        <ptr(4) to <array of <array of <int>>>> %ebp+8 ]
    #    -16(%ebp)   4  [ $t13      <int> %ebp-16 ]
    #    -20(%ebp)   4  [ $t14      <int> %ebp-20 ]
    #    -24(%ebp)   4  [ $t15      <int> %ebp-24 ]
    #    -28(%ebp)   4  [ $t16      <int> %ebp-28 ]
    #    -32(%ebp)   4  [ $t17      <int> %ebp-32 ]
    #    -36(%ebp)   4  [ $t18      <int> %ebp-36 ]
    #    -40(%ebp)   4  [ $t19      <int> %ebp-40 ]
    #    -44(%ebp)   4  [ $t20      <int> %ebp-44 ]
    #    -48(%ebp)   4  [ $t21      <int> %ebp-48 ]
    #    -52(%ebp)   4  [ $t22      <int> %ebp-52 ]
    #    -56(%ebp)   4  [ $v        <int> %ebp-56 ]
    #    -60(%ebp)   4  [ $x        <int> %ebp-60 ]
    #    -64(%ebp)   4  [ $y        <int> %ebp-64 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $52, %esp               # make room for locals

    cld                             # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $13, %ecx              
    mov     %esp, %edi             
    rep     stosl                  

    # function body
    movl    $1, %eax                #   0:     assign v <- 1
    movl    %eax, -56(%ebp)        
l_minit_2_while_cond:
    movl    -64(%ebp), %eax         #   2:     if     y < 8 goto 3_while_body
    movl    $8, %ebx               
    cmpl    %ebx, %eax             
    jl      l_minit_3_while_body   
    jmp     l_minit_1               #   3:     goto   1
l_minit_3_while_body:
    movl    $0, %eax                #   5:     assign x <- 0
    movl    %eax, -60(%ebp)        
l_minit_6_while_cond:
    movl    -60(%ebp), %eax         #   7:     if     x < 8 goto 7_while_body
    movl    $8, %ebx               
    cmpl    %ebx, %eax             
    jl      l_minit_7_while_body   
    jmp     l_minit_5               #   8:     goto   5
l_minit_7_while_body:
    movl    $2, %eax                #  10:     param  1 <- 2
    pushl   %eax                   
    movl    8(%ebp), %eax           #  11:     param  0 <- m
    pushl   %eax                   
    call    DIM                     #  12:     call   t13 <- DIM
    addl    $8, %esp               
    movl    %eax, -16(%ebp)        
    movl    -64(%ebp), %eax         #  13:     mul    t14 <- y, t13
    movl    -16(%ebp), %ebx        
    imull   %ebx                   
    movl    %eax, -20(%ebp)        
    movl    -20(%ebp), %eax         #  14:     add    t15 <- t14, x
    movl    -60(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #  15:     mul    t16 <- t15, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -28(%ebp)        
    movl    8(%ebp), %eax           #  16:     param  0 <- m
    pushl   %eax                   
    call    DOFS                    #  17:     call   t17 <- DOFS
    addl    $4, %esp               
    movl    %eax, -32(%ebp)        
    movl    -28(%ebp), %eax         #  18:     add    t18 <- t16, t17
    movl    -32(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -36(%ebp)        
    movl    8(%ebp), %eax           #  19:     add    t19 <- m, t18
    movl    -36(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -40(%ebp)        
    movl    -56(%ebp), %eax         #  20:     assign @t19 <- v
    movl    -40(%ebp), %edi        
    movl    %eax, (%edi)           
    movl    -56(%ebp), %eax         #  21:     add    t20 <- v, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -44(%ebp)        
    movl    -44(%ebp), %eax         #  22:     assign v <- t20
    movl    %eax, -56(%ebp)        
    movl    -56(%ebp), %eax         #  23:     if     v = 10 goto 11_if_true
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    je      l_minit_11_if_true     
    jmp     l_minit_12_if_false     #  24:     goto   12_if_false
l_minit_11_if_true:
    movl    $0, %eax                #  26:     assign v <- 0
    movl    %eax, -56(%ebp)        
    jmp     l_minit_10              #  27:     goto   10
l_minit_12_if_false:
l_minit_10:
    movl    -60(%ebp), %eax         #  30:     add    t21 <- x, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -48(%ebp)        
    movl    -48(%ebp), %eax         #  31:     assign x <- t21
    movl    %eax, -60(%ebp)        
    jmp     l_minit_6_while_cond    #  32:     goto   6_while_cond
l_minit_5:
    movl    -64(%ebp), %eax         #  34:     add    t22 <- y, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -52(%ebp)        
    movl    -52(%ebp), %eax         #  35:     assign y <- t22
    movl    %eax, -64(%ebp)        
    jmp     l_minit_2_while_cond    #  36:     goto   2_while_cond
l_minit_1:

l_minit_exit:
    # epilogue
    addl    $52, %esp               # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope madd
madd:
    # stack offsets:
    #     12(%ebp)   4  [ %a        <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp+12 ]
    #     16(%ebp)   4  [ %b        <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp+16 ]
    #      8(%ebp)   4  [ %sum      <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp+8 ]
    #    -16(%ebp)   4  [ $t13      <int> %ebp-16 ]
    #    -20(%ebp)   4  [ $t14      <int> %ebp-20 ]
    #    -24(%ebp)   4  [ $t15      <int> %ebp-24 ]
    #    -28(%ebp)   4  [ $t16      <int> %ebp-28 ]
    #    -32(%ebp)   4  [ $t17      <int> %ebp-32 ]
    #    -36(%ebp)   4  [ $t18      <int> %ebp-36 ]
    #    -40(%ebp)   4  [ $t19      <int> %ebp-40 ]
    #    -44(%ebp)   4  [ $t20      <int> %ebp-44 ]
    #    -48(%ebp)   4  [ $t21      <int> %ebp-48 ]
    #    -52(%ebp)   4  [ $t22      <int> %ebp-52 ]
    #    -56(%ebp)   4  [ $t23      <int> %ebp-56 ]
    #    -60(%ebp)   4  [ $t24      <int> %ebp-60 ]
    #    -64(%ebp)   4  [ $t25      <int> %ebp-64 ]
    #    -68(%ebp)   4  [ $t26      <int> %ebp-68 ]
    #    -72(%ebp)   4  [ $t27      <int> %ebp-72 ]
    #    -76(%ebp)   4  [ $t28      <int> %ebp-76 ]
    #    -80(%ebp)   4  [ $t29      <int> %ebp-80 ]
    #    -84(%ebp)   4  [ $t30      <int> %ebp-84 ]
    #    -88(%ebp)   4  [ $t31      <int> %ebp-88 ]
    #    -92(%ebp)   4  [ $t32      <int> %ebp-92 ]
    #    -96(%ebp)   4  [ $t33      <int> %ebp-96 ]
    #   -100(%ebp)   4  [ $t34      <int> %ebp-100 ]
    #   -104(%ebp)   4  [ $t35      <int> %ebp-104 ]
    #   -108(%ebp)   4  [ $t36      <int> %ebp-108 ]
    #   -112(%ebp)   4  [ $x        <int> %ebp-112 ]
    #   -116(%ebp)   4  [ $y        <int> %ebp-116 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $104, %esp              # make room for locals

    cld                             # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $26, %ecx              
    mov     %esp, %edi             
    rep     stosl                  

    # function body
    movl    $0, %eax                #   0:     assign y <- 0
    movl    %eax, -116(%ebp)       
l_madd_2_while_cond:
    movl    -116(%ebp), %eax        #   2:     if     y < 8 goto 3_while_body
    movl    $8, %ebx               
    cmpl    %ebx, %eax             
    jl      l_madd_3_while_body    
    jmp     l_madd_1                #   3:     goto   1
l_madd_3_while_body:
    movl    $0, %eax                #   5:     assign x <- 0
    movl    %eax, -112(%ebp)       
l_madd_6_while_cond:
    movl    -112(%ebp), %eax        #   7:     if     x < 8 goto 7_while_body
    movl    $8, %ebx               
    cmpl    %ebx, %eax             
    jl      l_madd_7_while_body    
    jmp     l_madd_5                #   8:     goto   5
l_madd_7_while_body:
    movl    $2, %eax                #  10:     param  1 <- 2
    pushl   %eax                   
    movl    12(%ebp), %eax          #  11:     param  0 <- a
    pushl   %eax                   
    call    DIM                     #  12:     call   t13 <- DIM
    addl    $8, %esp               
    movl    %eax, -16(%ebp)        
    movl    -116(%ebp), %eax        #  13:     mul    t14 <- y, t13
    movl    -16(%ebp), %ebx        
    imull   %ebx                   
    movl    %eax, -20(%ebp)        
    movl    -20(%ebp), %eax         #  14:     add    t15 <- t14, x
    movl    -112(%ebp), %ebx       
    addl    %ebx, %eax             
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #  15:     mul    t16 <- t15, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -28(%ebp)        
    movl    12(%ebp), %eax          #  16:     param  0 <- a
    pushl   %eax                   
    call    DOFS                    #  17:     call   t17 <- DOFS
    addl    $4, %esp               
    movl    %eax, -32(%ebp)        
    movl    -28(%ebp), %eax         #  18:     add    t18 <- t16, t17
    movl    -32(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -36(%ebp)        
    movl    12(%ebp), %eax          #  19:     add    t19 <- a, t18
    movl    -36(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -40(%ebp)        
    movl    $2, %eax                #  20:     param  1 <- 2
    pushl   %eax                   
    movl    16(%ebp), %eax          #  21:     param  0 <- b
    pushl   %eax                   
    call    DIM                     #  22:     call   t20 <- DIM
    addl    $8, %esp               
    movl    %eax, -44(%ebp)        
    movl    -116(%ebp), %eax        #  23:     mul    t21 <- y, t20
    movl    -44(%ebp), %ebx        
    imull   %ebx                   
    movl    %eax, -48(%ebp)        
    movl    -48(%ebp), %eax         #  24:     add    t22 <- t21, x
    movl    -112(%ebp), %ebx       
    addl    %ebx, %eax             
    movl    %eax, -52(%ebp)        
    movl    -52(%ebp), %eax         #  25:     mul    t23 <- t22, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -56(%ebp)        
    movl    16(%ebp), %eax          #  26:     param  0 <- b
    pushl   %eax                   
    call    DOFS                    #  27:     call   t24 <- DOFS
    addl    $4, %esp               
    movl    %eax, -60(%ebp)        
    movl    -56(%ebp), %eax         #  28:     add    t25 <- t23, t24
    movl    -60(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -64(%ebp)        
    movl    16(%ebp), %eax          #  29:     add    t26 <- b, t25
    movl    -64(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -68(%ebp)        
    movl    -40(%ebp), %edi        
    movl    (%edi), %eax            #  30:     add    t27 <- @t19, @t26
    movl    -68(%ebp), %edi        
    movl    (%edi), %ebx           
    addl    %ebx, %eax             
    movl    %eax, -72(%ebp)        
    movl    $2, %eax                #  31:     param  1 <- 2
    pushl   %eax                   
    movl    8(%ebp), %eax           #  32:     param  0 <- sum
    pushl   %eax                   
    call    DIM                     #  33:     call   t28 <- DIM
    addl    $8, %esp               
    movl    %eax, -76(%ebp)        
    movl    -116(%ebp), %eax        #  34:     mul    t29 <- y, t28
    movl    -76(%ebp), %ebx        
    imull   %ebx                   
    movl    %eax, -80(%ebp)        
    movl    -80(%ebp), %eax         #  35:     add    t30 <- t29, x
    movl    -112(%ebp), %ebx       
    addl    %ebx, %eax             
    movl    %eax, -84(%ebp)        
    movl    -84(%ebp), %eax         #  36:     mul    t31 <- t30, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -88(%ebp)        
    movl    8(%ebp), %eax           #  37:     param  0 <- sum
    pushl   %eax                   
    call    DOFS                    #  38:     call   t32 <- DOFS
    addl    $4, %esp               
    movl    %eax, -92(%ebp)        
    movl    -88(%ebp), %eax         #  39:     add    t33 <- t31, t32
    movl    -92(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -96(%ebp)        
    movl    8(%ebp), %eax           #  40:     add    t34 <- sum, t33
    movl    -96(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -100(%ebp)       
    movl    -72(%ebp), %eax         #  41:     assign @t34 <- t27
    movl    -100(%ebp), %edi       
    movl    %eax, (%edi)           
    movl    -112(%ebp), %eax        #  42:     add    t35 <- x, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -104(%ebp)       
    movl    -104(%ebp), %eax        #  43:     assign x <- t35
    movl    %eax, -112(%ebp)       
    jmp     l_madd_6_while_cond     #  44:     goto   6_while_cond
l_madd_5:
    movl    -116(%ebp), %eax        #  46:     add    t36 <- y, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -108(%ebp)       
    movl    -108(%ebp), %eax        #  47:     assign y <- t36
    movl    %eax, -116(%ebp)       
    jmp     l_madd_2_while_cond     #  48:     goto   2_while_cond
l_madd_1:

l_madd_exit:
    # epilogue
    addl    $104, %esp              # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope mprint
mprint:
    # stack offsets:
    #    -16(%ebp)   4  [ $M        <int> %ebp-16 ]
    #    -20(%ebp)   4  [ $N        <int> %ebp-20 ]
    #      8(%ebp)   4  [ %m        <ptr(4) to <array of <array of <int>>>> %ebp+8 ]
    #    -24(%ebp)   4  [ $t13      <int> %ebp-24 ]
    #    -28(%ebp)   4  [ $t14      <int> %ebp-28 ]
    #    -32(%ebp)   4  [ $t15      <ptr(4) to <array 10 of <char>>> %ebp-32 ]
    #    -36(%ebp)   4  [ $t16      <ptr(4) to <array 3 of <char>>> %ebp-36 ]
    #    -40(%ebp)   4  [ $t17      <ptr(4) to <array 3 of <char>>> %ebp-40 ]
    #    -44(%ebp)   4  [ $t18      <ptr(4) to <array 8 of <char>>> %ebp-44 ]
    #    -48(%ebp)   4  [ $t19      <int> %ebp-48 ]
    #    -52(%ebp)   4  [ $t20      <int> %ebp-52 ]
    #    -56(%ebp)   4  [ $t21      <int> %ebp-56 ]
    #    -60(%ebp)   4  [ $t22      <int> %ebp-60 ]
    #    -64(%ebp)   4  [ $t23      <int> %ebp-64 ]
    #    -68(%ebp)   4  [ $t24      <int> %ebp-68 ]
    #    -72(%ebp)   4  [ $t25      <int> %ebp-72 ]
    #    -76(%ebp)   4  [ $t26      <ptr(4) to <array 4 of <char>>> %ebp-76 ]
    #    -80(%ebp)   4  [ $t27      <int> %ebp-80 ]
    #    -84(%ebp)   4  [ $t28      <ptr(4) to <array 3 of <char>>> %ebp-84 ]
    #    -88(%ebp)   4  [ $t29      <int> %ebp-88 ]
    #    -92(%ebp)   4  [ $t30      <ptr(4) to <array 4 of <char>>> %ebp-92 ]
    #     12(%ebp)   4  [ %title    <ptr(4) to <array of <char>>> %ebp+12 ]
    #    -96(%ebp)   4  [ $x        <int> %ebp-96 ]
    #   -100(%ebp)   4  [ $y        <int> %ebp-100 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $88, %esp               # make room for locals

    cld                             # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $22, %ecx              
    mov     %esp, %edi             
    rep     stosl                  

    # function body
    movl    $1, %eax                #   0:     param  1 <- 1
    pushl   %eax                   
    movl    8(%ebp), %eax           #   1:     param  0 <- m
    pushl   %eax                   
    call    DIM                     #   2:     call   t13 <- DIM
    addl    $8, %esp               
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #   3:     assign M <- t13
    movl    %eax, -16(%ebp)        
    movl    $2, %eax                #   4:     param  1 <- 2
    pushl   %eax                   
    movl    8(%ebp), %eax           #   5:     param  0 <- m
    pushl   %eax                   
    call    DIM                     #   6:     call   t14 <- DIM
    addl    $8, %esp               
    movl    %eax, -28(%ebp)        
    movl    -28(%ebp), %eax         #   7:     assign N <- t14
    movl    %eax, -20(%ebp)        
    movl    12(%ebp), %eax          #   8:     param  0 <- title
    pushl   %eax                   
    call    WriteStr                #   9:     call   WriteStr
    addl    $4, %esp               
    leal    _str_2, %eax            #  10:     &()    t15 <- _str_2
    movl    %eax, -32(%ebp)        
    movl    -32(%ebp), %eax         #  11:     param  0 <- t15
    pushl   %eax                   
    call    WriteStr                #  12:     call   WriteStr
    addl    $4, %esp               
    movl    -16(%ebp), %eax         #  13:     param  0 <- M
    pushl   %eax                   
    call    WriteInt                #  14:     call   WriteInt
    addl    $4, %esp               
    movl    $120, %eax              #  15:     param  0 <- 120
    pushl   %eax                   
    call    WriteChar               #  16:     call   WriteChar
    addl    $4, %esp               
    movl    -20(%ebp), %eax         #  17:     param  0 <- N
    pushl   %eax                   
    call    WriteInt                #  18:     call   WriteInt
    addl    $4, %esp               
    call    WriteLn                 #  19:     call   WriteLn
    leal    _str_3, %eax            #  20:     &()    t16 <- _str_3
    movl    %eax, -36(%ebp)        
    movl    -36(%ebp), %eax         #  21:     param  0 <- t16
    pushl   %eax                   
    call    WriteStr                #  22:     call   WriteStr
    addl    $4, %esp               
l_mprint_10_while_cond:
    movl    -100(%ebp), %eax        #  24:     if     y < M goto 11_while_body
    movl    -16(%ebp), %ebx        
    cmpl    %ebx, %eax             
    jl      l_mprint_11_while_body 
    jmp     l_mprint_9              #  25:     goto   9
l_mprint_11_while_body:
    leal    _str_4, %eax            #  27:     &()    t17 <- _str_4
    movl    %eax, -40(%ebp)        
    movl    -40(%ebp), %eax         #  28:     param  0 <- t17
    pushl   %eax                   
    call    WriteStr                #  29:     call   WriteStr
    addl    $4, %esp               
    movl    -100(%ebp), %eax        #  30:     param  0 <- y
    pushl   %eax                   
    call    WriteInt                #  31:     call   WriteInt
    addl    $4, %esp               
    leal    _str_5, %eax            #  32:     &()    t18 <- _str_5
    movl    %eax, -44(%ebp)        
    movl    -44(%ebp), %eax         #  33:     param  0 <- t18
    pushl   %eax                   
    call    WriteStr                #  34:     call   WriteStr
    addl    $4, %esp               
    movl    $0, %eax                #  35:     assign x <- 0
    movl    %eax, -96(%ebp)        
l_mprint_17_while_cond:
    movl    -96(%ebp), %eax         #  37:     if     x < N goto 18_while_body
    movl    -20(%ebp), %ebx        
    cmpl    %ebx, %eax             
    jl      l_mprint_18_while_body 
    jmp     l_mprint_16             #  38:     goto   16
l_mprint_18_while_body:
    movl    $2, %eax                #  40:     param  1 <- 2
    pushl   %eax                   
    movl    8(%ebp), %eax           #  41:     param  0 <- m
    pushl   %eax                   
    call    DIM                     #  42:     call   t19 <- DIM
    addl    $8, %esp               
    movl    %eax, -48(%ebp)        
    movl    -100(%ebp), %eax        #  43:     mul    t20 <- y, t19
    movl    -48(%ebp), %ebx        
    imull   %ebx                   
    movl    %eax, -52(%ebp)        
    movl    -52(%ebp), %eax         #  44:     add    t21 <- t20, x
    movl    -96(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -56(%ebp)        
    movl    -56(%ebp), %eax         #  45:     mul    t22 <- t21, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -60(%ebp)        
    movl    8(%ebp), %eax           #  46:     param  0 <- m
    pushl   %eax                   
    call    DOFS                    #  47:     call   t23 <- DOFS
    addl    $4, %esp               
    movl    %eax, -64(%ebp)        
    movl    -60(%ebp), %eax         #  48:     add    t24 <- t22, t23
    movl    -64(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -68(%ebp)        
    movl    8(%ebp), %eax           #  49:     add    t25 <- m, t24
    movl    -68(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -72(%ebp)        
    movl    -72(%ebp), %edi        
    movl    (%edi), %eax            #  50:     param  0 <- @t25
    pushl   %eax                   
    call    WriteInt                #  51:     call   WriteInt
    addl    $4, %esp               
    leal    _str_6, %eax            #  52:     &()    t26 <- _str_6
    movl    %eax, -76(%ebp)        
    movl    -76(%ebp), %eax         #  53:     param  0 <- t26
    pushl   %eax                   
    call    WriteStr                #  54:     call   WriteStr
    addl    $4, %esp               
    movl    -96(%ebp), %eax         #  55:     add    t27 <- x, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -80(%ebp)        
    movl    -80(%ebp), %eax         #  56:     assign x <- t27
    movl    %eax, -96(%ebp)        
    jmp     l_mprint_17_while_cond  #  57:     goto   17_while_cond
l_mprint_16:
    leal    _str_7, %eax            #  59:     &()    t28 <- _str_7
    movl    %eax, -84(%ebp)        
    movl    -84(%ebp), %eax         #  60:     param  0 <- t28
    pushl   %eax                   
    call    WriteStr                #  61:     call   WriteStr
    addl    $4, %esp               
    movl    -100(%ebp), %eax        #  62:     add    t29 <- y, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -88(%ebp)        
    movl    -88(%ebp), %eax         #  63:     assign y <- t29
    movl    %eax, -100(%ebp)       
    jmp     l_mprint_10_while_cond  #  64:     goto   10_while_cond
l_mprint_9:
    leal    _str_8, %eax            #  66:     &()    t30 <- _str_8
    movl    %eax, -92(%ebp)        
    movl    -92(%ebp), %eax         #  67:     param  0 <- t30
    pushl   %eax                   
    call    WriteStr                #  68:     call   WriteStr
    addl    $4, %esp               

l_mprint_exit:
    # epilogue
    addl    $88, %esp               # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope test04
main:
    # stack offsets:
    #    -16(%ebp)   4  [ $t0       <ptr(4) to <array 16 of <char>>> %ebp-16 ]
    #    -20(%ebp)   4  [ $t1       <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-20 ]
    #    -24(%ebp)   4  [ $t10      <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-24 ]
    #    -28(%ebp)   4  [ $t11      <ptr(4) to <array 8 of <char>>> %ebp-28 ]
    #    -32(%ebp)   4  [ $t12      <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-32 ]
    #    -36(%ebp)   4  [ $t2       <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-36 ]
    #    -40(%ebp)   4  [ $t3       <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-40 ]
    #    -44(%ebp)   4  [ $t4       <ptr(4) to <array 2 of <char>>> %ebp-44 ]
    #    -48(%ebp)   4  [ $t5       <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-48 ]
    #    -52(%ebp)   4  [ $t6       <ptr(4) to <array 2 of <char>>> %ebp-52 ]
    #    -56(%ebp)   4  [ $t7       <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-56 ]
    #    -60(%ebp)   4  [ $t8       <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-60 ]
    #    -64(%ebp)   4  [ $t9       <ptr(4) to <array 8 of <array 8 of <int>>>> %ebp-64 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $52, %esp               # make room for locals

    cld                             # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $13, %ecx              
    mov     %esp, %edi             
    rep     stosl                  

    # function body
    leal    _str_1, %eax            #   0:     &()    t0 <- _str_1
    movl    %eax, -16(%ebp)        
    movl    -16(%ebp), %eax         #   1:     param  0 <- t0
    pushl   %eax                   
    call    WriteStr                #   2:     call   WriteStr
    addl    $4, %esp               
    call    WriteLn                 #   3:     call   WriteLn
    leal    A, %eax                 #   4:     &()    t1 <- A
    movl    %eax, -20(%ebp)        
    movl    -20(%ebp), %eax         #   5:     param  0 <- t1
    pushl   %eax                   
    call    minit                   #   6:     call   minit
    addl    $4, %esp               
    leal    B, %eax                 #   7:     &()    t2 <- B
    movl    %eax, -36(%ebp)        
    movl    -36(%ebp), %eax         #   8:     param  0 <- t2
    pushl   %eax                   
    call    minit                   #   9:     call   minit
    addl    $4, %esp               
    leal    C, %eax                 #  10:     &()    t3 <- C
    movl    %eax, -40(%ebp)        
    movl    -40(%ebp), %eax         #  11:     param  0 <- t3
    pushl   %eax                   
    call    minit                   #  12:     call   minit
    addl    $4, %esp               
    leal    _str_9, %eax            #  13:     &()    t4 <- _str_9
    movl    %eax, -44(%ebp)        
    movl    -44(%ebp), %eax         #  14:     param  1 <- t4
    pushl   %eax                   
    leal    A, %eax                 #  15:     &()    t5 <- A
    movl    %eax, -48(%ebp)        
    movl    -48(%ebp), %eax         #  16:     param  0 <- t5
    pushl   %eax                   
    call    mprint                  #  17:     call   mprint
    addl    $8, %esp               
    leal    _str_10, %eax           #  18:     &()    t6 <- _str_10
    movl    %eax, -52(%ebp)        
    movl    -52(%ebp), %eax         #  19:     param  1 <- t6
    pushl   %eax                   
    leal    B, %eax                 #  20:     &()    t7 <- B
    movl    %eax, -56(%ebp)        
    movl    -56(%ebp), %eax         #  21:     param  0 <- t7
    pushl   %eax                   
    call    mprint                  #  22:     call   mprint
    addl    $8, %esp               
    leal    B, %eax                 #  23:     &()    t8 <- B
    movl    %eax, -60(%ebp)        
    movl    -60(%ebp), %eax         #  24:     param  2 <- t8
    pushl   %eax                   
    leal    A, %eax                 #  25:     &()    t9 <- A
    movl    %eax, -64(%ebp)        
    movl    -64(%ebp), %eax         #  26:     param  1 <- t9
    pushl   %eax                   
    leal    C, %eax                 #  27:     &()    t10 <- C
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #  28:     param  0 <- t10
    pushl   %eax                   
    call    madd                    #  29:     call   madd
    addl    $12, %esp              
    leal    _str_11, %eax           #  30:     &()    t11 <- _str_11
    movl    %eax, -28(%ebp)        
    movl    -28(%ebp), %eax         #  31:     param  1 <- t11
    pushl   %eax                   
    leal    C, %eax                 #  32:     &()    t12 <- C
    movl    %eax, -32(%ebp)        
    movl    -32(%ebp), %eax         #  33:     param  0 <- t12
    pushl   %eax                   
    call    mprint                  #  34:     call   mprint
    addl    $8, %esp               

l_test04_exit:
    # epilogue
    addl    $52, %esp               # remove locals
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
A:                                  # <array 8 of <array 8 of <int>>>
    .long    2
    .long    8
    .long    8
    .skip  256
B:                                  # <array 8 of <array 8 of <int>>>
    .long    2
    .long    8
    .long    8
    .skip  256
C:                                  # <array 8 of <array 8 of <int>>>
    .long    2
    .long    8
    .long    8
    .skip  256
_str_1:                             # <array 16 of <char>>
    .long    1
    .long   16
    .asciz "Matrix\t Adder\n\n"
_str_10:                            # <array 2 of <char>>
    .long    1
    .long    2
    .asciz "B"
    .align   4
_str_11:                            # <array 8 of <char>>
    .long    1
    .long    8
    .asciz "C = A+B"
_str_2:                             # <array 10 of <char>>
    .long    1
    .long   10
    .asciz ". Matrix "
    .align   4
_str_3:                             # <array 3 of <char>>
    .long    1
    .long    3
    .asciz "[\n"
    .align   4
_str_4:                             # <array 3 of <char>>
    .long    1
    .long    3
    .asciz "  "
    .align   4
_str_5:                             # <array 8 of <char>>
    .long    1
    .long    8
    .asciz ":  [   "
_str_6:                             # <array 4 of <char>>
    .long    1
    .long    4
    .asciz "   "
_str_7:                             # <array 3 of <char>>
    .long    1
    .long    3
    .asciz "]\n"
    .align   4
_str_8:                             # <array 4 of <char>>
    .long    1
    .long    4
    .asciz "]\n\n"
_str_9:                             # <array 2 of <char>>
    .long    1
    .long    2
    .asciz "A"




    # end of global data section
    #-----------------------------------------

    .end
##################################################
