##################################################
# test09
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

    # scope test
test:
    # stack offsets:
    #    -32(%ebp)  18  [ $a        <array 10 of <bool>> %ebp-32 ]
    #    -36(%ebp)   4  [ $i        <int> %ebp-36 ]
    #    -37(%ebp)   1  [ $t0       <bool> %ebp-37 ]
    #    -44(%ebp)   4  [ $t1       <ptr(4) to <array 10 of <bool>>> %ebp-44 ]
    #    -48(%ebp)   4  [ $t10      <ptr(4) to <array 10 of <bool>>> %ebp-48 ]
    #    -52(%ebp)   4  [ $t11      <int> %ebp-52 ]
    #    -56(%ebp)   4  [ $t12      <int> %ebp-56 ]
    #    -60(%ebp)   4  [ $t13      <int> %ebp-60 ]
    #    -64(%ebp)   4  [ $t14      <int> %ebp-64 ]
    #    -68(%ebp)   4  [ $t2       <int> %ebp-68 ]
    #    -72(%ebp)   4  [ $t3       <ptr(4) to <array 10 of <bool>>> %ebp-72 ]
    #    -76(%ebp)   4  [ $t4       <int> %ebp-76 ]
    #    -80(%ebp)   4  [ $t5       <int> %ebp-80 ]
    #    -84(%ebp)   4  [ $t6       <int> %ebp-84 ]
    #    -88(%ebp)   4  [ $t7       <int> %ebp-88 ]
    #    -92(%ebp)   4  [ $t8       <ptr(4) to <array 10 of <bool>>> %ebp-92 ]
    #    -96(%ebp)   4  [ $t9       <int> %ebp-96 ]

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
    movl    $1,-32(%ebp)            # local array 'a': 1 dimensions
    movl    $10,-28(%ebp)           #   dimension 1: 10 elements

    # function body
    movl    $0, %eax                #   0:     assign i <- 0
    movl    %eax, -36(%ebp)        
l_test_2_while_cond:
    movl    -36(%ebp), %eax         #   2:     if     i < 10 goto 3_while_body
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    jl      l_test_3_while_body    
    jmp     l_test_1                #   3:     goto   1
l_test_3_while_body:
    movl    -36(%ebp), %eax         #   5:     if     i > 2 goto 5
    movl    $2, %ebx               
    cmpl    %ebx, %eax             
    jg      l_test_5               
    jmp     l_test_6                #   6:     goto   6
l_test_5:
    movl    $1, %eax                #   8:     assign t0 <- 1
    movb    %al, -37(%ebp)         
    jmp     l_test_7                #   9:     goto   7
l_test_6:
    movl    $0, %eax                #  11:     assign t0 <- 0
    movb    %al, -37(%ebp)         
l_test_7:
    leal    -32(%ebp), %eax         #  13:     &()    t1 <- a
    movl    %eax, -44(%ebp)        
    movl    -36(%ebp), %eax         #  14:     mul    t2 <- i, 1
    movl    $1, %ebx               
    imull   %ebx                   
    movl    %eax, -68(%ebp)        
    leal    -32(%ebp), %eax         #  15:     &()    t3 <- a
    movl    %eax, -72(%ebp)        
    movl    -72(%ebp), %eax         #  16:     param  0 <- t3
    pushl   %eax                   
    call    DOFS                    #  17:     call   t4 <- DOFS
    addl    $4, %esp               
    movl    %eax, -76(%ebp)        
    movl    -68(%ebp), %eax         #  18:     add    t5 <- t2, t4
    movl    -76(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -80(%ebp)        
    movl    -44(%ebp), %eax         #  19:     add    t6 <- t1, t5
    movl    -80(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -84(%ebp)        
    movzbl  -37(%ebp), %eax         #  20:     assign @t6 <- t0
    movl    -84(%ebp), %edi        
    movb    %al, (%edi)            
    movl    -36(%ebp), %eax         #  21:     add    t7 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -88(%ebp)        
    movl    -88(%ebp), %eax         #  22:     assign i <- t7
    movl    %eax, -36(%ebp)        
    jmp     l_test_2_while_cond     #  23:     goto   2_while_cond
l_test_1:
    movl    $0, %eax                #  25:     assign i <- 0
    movl    %eax, -36(%ebp)        
l_test_11_while_cond:
    movl    -36(%ebp), %eax         #  27:     if     i < 10 goto 12_while_body
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    jl      l_test_12_while_body   
    jmp     l_test_10               #  28:     goto   10
l_test_12_while_body:
    leal    -32(%ebp), %eax         #  30:     &()    t8 <- a
    movl    %eax, -92(%ebp)        
    movl    -36(%ebp), %eax         #  31:     mul    t9 <- i, 1
    movl    $1, %ebx               
    imull   %ebx                   
    movl    %eax, -96(%ebp)        
    leal    -32(%ebp), %eax         #  32:     &()    t10 <- a
    movl    %eax, -48(%ebp)        
    movl    -48(%ebp), %eax         #  33:     param  0 <- t10
    pushl   %eax                   
    call    DOFS                    #  34:     call   t11 <- DOFS
    addl    $4, %esp               
    movl    %eax, -52(%ebp)        
    movl    -96(%ebp), %eax         #  35:     add    t12 <- t9, t11
    movl    -52(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -56(%ebp)        
    movl    -92(%ebp), %eax         #  36:     add    t13 <- t8, t12
    movl    -56(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -60(%ebp)        
    movl    -60(%ebp), %edi        
    movzbl  (%edi), %eax            #  37:     if     @t13 = 1 goto 14_if_true
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test_14_if_true      
    jmp     l_test_15_if_false      #  38:     goto   15_if_false
l_test_14_if_true:
    movl    $1, %eax                #  40:     param  0 <- 1
    pushl   %eax                   
    call    WriteInt                #  41:     call   WriteInt
    addl    $4, %esp               
    jmp     l_test_13               #  42:     goto   13
l_test_15_if_false:
    movl    $0, %eax                #  44:     param  0 <- 0
    pushl   %eax                   
    call    WriteInt                #  45:     call   WriteInt
    addl    $4, %esp               
l_test_13:
    movl    -36(%ebp), %eax         #  47:     add    t14 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -64(%ebp)        
    movl    -64(%ebp), %eax         #  48:     assign i <- t14
    movl    %eax, -36(%ebp)        
    jmp     l_test_11_while_cond    #  49:     goto   11_while_cond
l_test_10:

l_test_exit:
    # epilogue
    addl    $84, %esp               # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope test09
main:
    # stack offsets:

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $0, %esp                # make room for locals

    # function body
    call    test                    #   0:     call   test

l_test09_exit:
    # epilogue
    addl    $0, %esp                # remove locals
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



    # end of global data section
    #-----------------------------------------

    .end
##################################################
