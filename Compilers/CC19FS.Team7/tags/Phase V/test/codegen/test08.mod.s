##################################################
# test08
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
    #    -60(%ebp)  48  [ $a        <array 10 of <int>> %ebp-60 ]
    #    -64(%ebp)   4  [ $i        <int> %ebp-64 ]
    #    -68(%ebp)   4  [ $t0       <ptr(4) to <array 10 of <int>>> %ebp-68 ]
    #    -72(%ebp)   4  [ $t1       <int> %ebp-72 ]
    #    -76(%ebp)   4  [ $t10      <int> %ebp-76 ]
    #    -80(%ebp)   4  [ $t11      <int> %ebp-80 ]
    #    -84(%ebp)   4  [ $t12      <int> %ebp-84 ]
    #    -88(%ebp)   4  [ $t13      <int> %ebp-88 ]
    #    -92(%ebp)   4  [ $t14      <ptr(4) to <array 10 of <int>>> %ebp-92 ]
    #    -96(%ebp)   4  [ $t15      <int> %ebp-96 ]
    #   -100(%ebp)   4  [ $t16      <ptr(4) to <array 10 of <int>>> %ebp-100 ]
    #   -104(%ebp)   4  [ $t17      <int> %ebp-104 ]
    #   -108(%ebp)   4  [ $t18      <int> %ebp-108 ]
    #   -112(%ebp)   4  [ $t19      <int> %ebp-112 ]
    #   -116(%ebp)   4  [ $t2       <ptr(4) to <array 10 of <int>>> %ebp-116 ]
    #   -120(%ebp)   4  [ $t20      <int> %ebp-120 ]
    #   -124(%ebp)   4  [ $t3       <int> %ebp-124 ]
    #   -128(%ebp)   4  [ $t4       <int> %ebp-128 ]
    #   -132(%ebp)   4  [ $t5       <int> %ebp-132 ]
    #   -136(%ebp)   4  [ $t6       <int> %ebp-136 ]
    #   -140(%ebp)   4  [ $t7       <ptr(4) to <array 10 of <int>>> %ebp-140 ]
    #   -144(%ebp)   4  [ $t8       <int> %ebp-144 ]
    #   -148(%ebp)   4  [ $t9       <ptr(4) to <array 10 of <int>>> %ebp-148 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $136, %esp              # make room for locals

    cld                             # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $34, %ecx              
    mov     %esp, %edi             
    rep     stosl                  
    movl    $1,-60(%ebp)            # local array 'a': 1 dimensions
    movl    $10,-56(%ebp)           #   dimension 1: 10 elements

    # function body
    leal    -60(%ebp), %eax         #   0:     &()    t0 <- a
    movl    %eax, -68(%ebp)        
    movl    $0, %eax                #   1:     mul    t1 <- 0, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -72(%ebp)        
    leal    -60(%ebp), %eax         #   2:     &()    t2 <- a
    movl    %eax, -116(%ebp)       
    movl    -116(%ebp), %eax        #   3:     param  0 <- t2
    pushl   %eax                   
    call    DOFS                    #   4:     call   t3 <- DOFS
    addl    $4, %esp               
    movl    %eax, -124(%ebp)       
    movl    -72(%ebp), %eax         #   5:     add    t4 <- t1, t3
    movl    -124(%ebp), %ebx       
    addl    %ebx, %eax             
    movl    %eax, -128(%ebp)       
    movl    -68(%ebp), %eax         #   6:     add    t5 <- t0, t4
    movl    -128(%ebp), %ebx       
    addl    %ebx, %eax             
    movl    %eax, -132(%ebp)       
    movl    $1, %eax                #   7:     assign @t5 <- 1
    movl    -132(%ebp), %edi       
    movl    %eax, (%edi)           
    movl    $1, %eax                #   8:     assign i <- 1
    movl    %eax, -64(%ebp)        
l_test_3_while_cond:
    movl    -64(%ebp), %eax         #  10:     if     i < 10 goto 4_while_body
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    jl      l_test_4_while_body    
    jmp     l_test_2                #  11:     goto   2
l_test_4_while_body:
    movl    $10, %eax               #  13:     sub    t6 <- 10, i
    movl    -64(%ebp), %ebx        
    subl    %ebx, %eax             
    movl    %eax, -136(%ebp)       
    leal    -60(%ebp), %eax         #  14:     &()    t7 <- a
    movl    %eax, -140(%ebp)       
    movl    -64(%ebp), %eax         #  15:     mul    t8 <- i, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -144(%ebp)       
    leal    -60(%ebp), %eax         #  16:     &()    t9 <- a
    movl    %eax, -148(%ebp)       
    movl    -148(%ebp), %eax        #  17:     param  0 <- t9
    pushl   %eax                   
    call    DOFS                    #  18:     call   t10 <- DOFS
    addl    $4, %esp               
    movl    %eax, -76(%ebp)        
    movl    -144(%ebp), %eax        #  19:     add    t11 <- t8, t10
    movl    -76(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -80(%ebp)        
    movl    -140(%ebp), %eax        #  20:     add    t12 <- t7, t11
    movl    -80(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -84(%ebp)        
    movl    -136(%ebp), %eax        #  21:     assign @t12 <- t6
    movl    -84(%ebp), %edi        
    movl    %eax, (%edi)           
    movl    -64(%ebp), %eax         #  22:     add    t13 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -88(%ebp)        
    movl    -88(%ebp), %eax         #  23:     assign i <- t13
    movl    %eax, -64(%ebp)        
    jmp     l_test_3_while_cond     #  24:     goto   3_while_cond
l_test_2:
    movl    $0, %eax                #  26:     assign i <- 0
    movl    %eax, -64(%ebp)        
l_test_9_while_cond:
    movl    -64(%ebp), %eax         #  28:     if     i < 10 goto 10_while_body
    movl    $10, %ebx              
    cmpl    %ebx, %eax             
    jl      l_test_10_while_body   
    jmp     l_test_8                #  29:     goto   8
l_test_10_while_body:
    leal    -60(%ebp), %eax         #  31:     &()    t14 <- a
    movl    %eax, -92(%ebp)        
    movl    -64(%ebp), %eax         #  32:     mul    t15 <- i, 4
    movl    $4, %ebx               
    imull   %ebx                   
    movl    %eax, -96(%ebp)        
    leal    -60(%ebp), %eax         #  33:     &()    t16 <- a
    movl    %eax, -100(%ebp)       
    movl    -100(%ebp), %eax        #  34:     param  0 <- t16
    pushl   %eax                   
    call    DOFS                    #  35:     call   t17 <- DOFS
    addl    $4, %esp               
    movl    %eax, -104(%ebp)       
    movl    -96(%ebp), %eax         #  36:     add    t18 <- t15, t17
    movl    -104(%ebp), %ebx       
    addl    %ebx, %eax             
    movl    %eax, -108(%ebp)       
    movl    -92(%ebp), %eax         #  37:     add    t19 <- t14, t18
    movl    -108(%ebp), %ebx       
    addl    %ebx, %eax             
    movl    %eax, -112(%ebp)       
    movl    -112(%ebp), %edi       
    movl    (%edi), %eax            #  38:     param  0 <- @t19
    pushl   %eax                   
    call    WriteInt                #  39:     call   WriteInt
    addl    $4, %esp               
    movl    -64(%ebp), %eax         #  40:     add    t20 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -120(%ebp)       
    movl    -120(%ebp), %eax        #  41:     assign i <- t20
    movl    %eax, -64(%ebp)        
    jmp     l_test_9_while_cond     #  42:     goto   9_while_cond
l_test_8:

l_test_exit:
    # epilogue
    addl    $136, %esp              # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope test08
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

l_test08_exit:
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
