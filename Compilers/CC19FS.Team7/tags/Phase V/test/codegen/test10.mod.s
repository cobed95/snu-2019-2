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
    #      8(%ebp)   4  [ %n        <int> %ebp+8 ]
    #    -16(%ebp)   4  [ $t11      <int> %ebp-16 ]
    #    -20(%ebp)   4  [ $t12      <int> %ebp-20 ]
    #    -24(%ebp)   4  [ $t13      <int> %ebp-24 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $12, %esp               # make room for locals

    xorl    %eax, %eax              # memset local stack area to 0
    movl    %eax, 8(%esp)          
    movl    %eax, 4(%esp)          
    movl    %eax, 0(%esp)          

    # function body
    movl    8(%ebp), %eax           #   0:     if     n > 0 goto 1_if_true
    movl    $0, %ebx               
    cmpl    %ebx, %eax             
    jg      l_sum_rec_1_if_true    
    jmp     l_sum_rec_2_if_false    #   1:     goto   2_if_false
l_sum_rec_1_if_true:
    movl    8(%ebp), %eax           #   3:     sub    t11 <- n, 1
    movl    $1, %ebx               
    subl    %ebx, %eax             
    movl    %eax, -16(%ebp)        
    movl    -16(%ebp), %eax         #   4:     param  0 <- t11
    pushl   %eax                   
    call    sum_rec                 #   5:     call   t12 <- sum_rec
    addl    $4, %esp               
    movl    %eax, -20(%ebp)        
    movl    8(%ebp), %eax           #   6:     add    t13 <- n, t12
    movl    -20(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #   7:     return t13
    jmp     l_sum_rec_exit         
    jmp     l_sum_rec_0             #   8:     goto   0
l_sum_rec_2_if_false:
    movl    $0, %eax                #  10:     return 0
    jmp     l_sum_rec_exit         
l_sum_rec_0:

l_sum_rec_exit:
    # epilogue
    addl    $12, %esp               # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope sum_iter
sum_iter:
    # stack offsets:
    #    -16(%ebp)   4  [ $i        <int> %ebp-16 ]
    #      8(%ebp)   4  [ %n        <int> %ebp+8 ]
    #    -20(%ebp)   4  [ $sum      <int> %ebp-20 ]
    #    -24(%ebp)   4  [ $t11      <int> %ebp-24 ]
    #    -28(%ebp)   4  [ $t12      <int> %ebp-28 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $16, %esp               # make room for locals

    xorl    %eax, %eax              # memset local stack area to 0
    movl    %eax, 12(%esp)         
    movl    %eax, 8(%esp)          
    movl    %eax, 4(%esp)          
    movl    %eax, 0(%esp)          

    # function body
    movl    $0, %eax                #   0:     assign sum <- 0
    movl    %eax, -20(%ebp)        
    movl    $0, %eax                #   1:     assign i <- 0
    movl    %eax, -16(%ebp)        
l_sum_iter_3_while_cond:
    movl    -16(%ebp), %eax         #   3:     if     i <= n goto 4_while_body
    movl    8(%ebp), %ebx          
    cmpl    %ebx, %eax             
    jle     l_sum_iter_4_while_body
    jmp     l_sum_iter_2            #   4:     goto   2
l_sum_iter_4_while_body:
    movl    -20(%ebp), %eax         #   6:     add    t11 <- sum, i
    movl    -16(%ebp), %ebx        
    addl    %ebx, %eax             
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #   7:     assign sum <- t11
    movl    %eax, -20(%ebp)        
    movl    -16(%ebp), %eax         #   8:     add    t12 <- i, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -28(%ebp)        
    movl    -28(%ebp), %eax         #   9:     assign i <- t12
    movl    %eax, -16(%ebp)        
    jmp     l_sum_iter_3_while_cond #  10:     goto   3_while_cond
l_sum_iter_2:
    movl    -20(%ebp), %eax         #  12:     return sum
    jmp     l_sum_iter_exit        

l_sum_iter_exit:
    # epilogue
    addl    $16, %esp               # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope sum_alg
sum_alg:
    # stack offsets:
    #      8(%ebp)   4  [ %n        <int> %ebp+8 ]
    #    -16(%ebp)   4  [ $t11      <int> %ebp-16 ]
    #    -20(%ebp)   4  [ $t12      <int> %ebp-20 ]
    #    -24(%ebp)   4  [ $t13      <int> %ebp-24 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $12, %esp               # make room for locals

    xorl    %eax, %eax              # memset local stack area to 0
    movl    %eax, 8(%esp)          
    movl    %eax, 4(%esp)          
    movl    %eax, 0(%esp)          

    # function body
    movl    8(%ebp), %eax           #   0:     add    t11 <- n, 1
    movl    $1, %ebx               
    addl    %ebx, %eax             
    movl    %eax, -16(%ebp)        
    movl    8(%ebp), %eax           #   1:     mul    t12 <- n, t11
    movl    -16(%ebp), %ebx        
    imull   %ebx                   
    movl    %eax, -20(%ebp)        
    movl    -20(%ebp), %eax         #   2:     div    t13 <- t12, 2
    movl    $2, %ebx               
    cdq                            
    idivl   %ebx                   
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #   3:     return t13
    jmp     l_sum_alg_exit         

l_sum_alg_exit:
    # epilogue
    addl    $12, %esp               # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope ReadNumber
ReadNumber:
    # stack offsets:
    #    -16(%ebp)   4  [ $i        <int> %ebp-16 ]
    #      8(%ebp)   4  [ %str      <ptr(4) to <array of <char>>> %ebp+8 ]
    #    -20(%ebp)   4  [ $t11      <int> %ebp-20 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $8, %esp                # make room for locals

    xorl    %eax, %eax              # memset local stack area to 0
    movl    %eax, 4(%esp)          
    movl    %eax, 0(%esp)          

    # function body
    movl    8(%ebp), %eax           #   0:     param  0 <- str
    pushl   %eax                   
    call    WriteStr                #   1:     call   WriteStr
    addl    $4, %esp               
    call    ReadInt                 #   2:     call   t11 <- ReadInt
    movl    %eax, -20(%ebp)        
    movl    -20(%ebp), %eax         #   3:     assign i <- t11
    movl    %eax, -16(%ebp)        
    movl    -16(%ebp), %eax         #   4:     return i
    jmp     l_ReadNumber_exit      

l_ReadNumber_exit:
    # epilogue
    addl    $8, %esp                # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope test10
main:
    # stack offsets:
    #    -16(%ebp)   4  [ $t0       <ptr(4) to <array 25 of <char>>> %ebp-16 ]
    #    -20(%ebp)   4  [ $t1       <ptr(4) to <array 29 of <char>>> %ebp-20 ]
    #    -24(%ebp)   4  [ $t10      <int> %ebp-24 ]
    #    -28(%ebp)   4  [ $t2       <int> %ebp-28 ]
    #    -32(%ebp)   4  [ $t3       <ptr(4) to <array 16 of <char>>> %ebp-32 ]
    #    -36(%ebp)   4  [ $t4       <int> %ebp-36 ]
    #    -40(%ebp)   4  [ $t5       <ptr(4) to <array 16 of <char>>> %ebp-40 ]
    #    -44(%ebp)   4  [ $t6       <int> %ebp-44 ]
    #    -48(%ebp)   4  [ $t7       <ptr(4) to <array 16 of <char>>> %ebp-48 ]
    #    -52(%ebp)   4  [ $t8       <int> %ebp-52 ]
    #    -56(%ebp)   4  [ $t9       <ptr(4) to <array 29 of <char>>> %ebp-56 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $44, %esp               # make room for locals

    cld                             # memset local stack area to 0
    xorl    %eax, %eax             
    movl    $11, %ecx              
    mov     %esp, %edi             
    rep     stosl                  

    # function body
    leal    _str_1, %eax            #   0:     &()    t0 <- _str_1
    movl    %eax, -16(%ebp)        
    movl    -16(%ebp), %eax         #   1:     param  0 <- t0
    pushl   %eax                   
    call    WriteStr                #   2:     call   WriteStr
    addl    $4, %esp               
    leal    _str_2, %eax            #   3:     &()    t1 <- _str_2
    movl    %eax, -20(%ebp)        
    movl    -20(%ebp), %eax         #   4:     param  0 <- t1
    pushl   %eax                   
    call    ReadNumber              #   5:     call   t2 <- ReadNumber
    addl    $4, %esp               
    movl    %eax, -28(%ebp)        
    movl    -28(%ebp), %eax         #   6:     assign i <- t2
    movl    %eax, i                
l_test10_3_while_cond:
    movl    i, %eax                 #   8:     if     i > 0 goto 4_while_body
    movl    $0, %ebx               
    cmpl    %ebx, %eax             
    jg      l_test10_4_while_body  
    jmp     l_test10_2              #   9:     goto   2
l_test10_4_while_body:
    leal    _str_3, %eax            #  11:     &()    t3 <- _str_3
    movl    %eax, -32(%ebp)        
    movl    -32(%ebp), %eax         #  12:     param  0 <- t3
    pushl   %eax                   
    call    WriteStr                #  13:     call   WriteStr
    addl    $4, %esp               
    movl    i, %eax                 #  14:     param  0 <- i
    pushl   %eax                   
    call    sum_rec                 #  15:     call   t4 <- sum_rec
    addl    $4, %esp               
    movl    %eax, -36(%ebp)        
    movl    -36(%ebp), %eax         #  16:     param  0 <- t4
    pushl   %eax                   
    call    WriteInt                #  17:     call   WriteInt
    addl    $4, %esp               
    call    WriteLn                 #  18:     call   WriteLn
    leal    _str_4, %eax            #  19:     &()    t5 <- _str_4
    movl    %eax, -40(%ebp)        
    movl    -40(%ebp), %eax         #  20:     param  0 <- t5
    pushl   %eax                   
    call    WriteStr                #  21:     call   WriteStr
    addl    $4, %esp               
    movl    i, %eax                 #  22:     param  0 <- i
    pushl   %eax                   
    call    sum_iter                #  23:     call   t6 <- sum_iter
    addl    $4, %esp               
    movl    %eax, -44(%ebp)        
    movl    -44(%ebp), %eax         #  24:     param  0 <- t6
    pushl   %eax                   
    call    WriteInt                #  25:     call   WriteInt
    addl    $4, %esp               
    call    WriteLn                 #  26:     call   WriteLn
    leal    _str_5, %eax            #  27:     &()    t7 <- _str_5
    movl    %eax, -48(%ebp)        
    movl    -48(%ebp), %eax         #  28:     param  0 <- t7
    pushl   %eax                   
    call    WriteStr                #  29:     call   WriteStr
    addl    $4, %esp               
    movl    i, %eax                 #  30:     param  0 <- i
    pushl   %eax                   
    call    sum_alg                 #  31:     call   t8 <- sum_alg
    addl    $4, %esp               
    movl    %eax, -52(%ebp)        
    movl    -52(%ebp), %eax         #  32:     param  0 <- t8
    pushl   %eax                   
    call    WriteInt                #  33:     call   WriteInt
    addl    $4, %esp               
    call    WriteLn                 #  34:     call   WriteLn
    leal    _str_6, %eax            #  35:     &()    t9 <- _str_6
    movl    %eax, -56(%ebp)        
    movl    -56(%ebp), %eax         #  36:     param  0 <- t9
    pushl   %eax                   
    call    ReadNumber              #  37:     call   t10 <- ReadNumber
    addl    $4, %esp               
    movl    %eax, -24(%ebp)        
    movl    -24(%ebp), %eax         #  38:     assign i <- t10
    movl    %eax, i                
    jmp     l_test10_3_while_cond   #  39:     goto   3_while_cond
l_test10_2:

l_test10_exit:
    # epilogue
    addl    $44, %esp               # remove locals
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

    # scope: test10
_str_1:                             # <array 25 of <char>>
    .long    1
    .long   25
    .asciz "Sum of natural numbers\n\n"
    .align   4
_str_2:                             # <array 29 of <char>>
    .long    1
    .long   29
    .asciz "Enter a number (0 to exit): "
    .align   4
_str_3:                             # <array 16 of <char>>
    .long    1
    .long   16
    .asciz " recursive   : "
_str_4:                             # <array 16 of <char>>
    .long    1
    .long   16
    .asciz " iterative   : "
_str_5:                             # <array 16 of <char>>
    .long    1
    .long   16
    .asciz " algorithmic : "
_str_6:                             # <array 29 of <char>>
    .long    1
    .long   29
    .asciz "Enter a number (0 to exit): "
    .align   4
i:                                  # <int>
    .skip    4





    # end of global data section
    #-----------------------------------------

    .end
##################################################
