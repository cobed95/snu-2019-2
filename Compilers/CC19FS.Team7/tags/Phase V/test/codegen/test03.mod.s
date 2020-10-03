##################################################
# test03
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

    # scope test03
main:
    # stack offsets:
    #    -13(%ebp)   1  [ $t0       <bool> %ebp-13 ]
    #    -14(%ebp)   1  [ $t1       <bool> %ebp-14 ]
    #    -15(%ebp)   1  [ $t2       <bool> %ebp-15 ]

    # prologue
    pushl   %ebp                   
    movl    %esp, %ebp             
    pushl   %ebx                    # save callee saved registers
    pushl   %esi                   
    pushl   %edi                   
    subl    $4, %esp                # make room for locals

    xorl    %eax, %eax              # memset local stack area to 0
    movl    %eax, 0(%esp)          

    # function body
    movl    $1, %eax                #   0:     assign a <- 1
    movb    %al, a                 
    movl    $0, %eax                #   1:     assign b <- 0
    movb    %al, b                 
    movzbl  a, %eax                 #   2:     if     a = 1 goto 6
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_6             
    jmp     l_test03_4              #   3:     goto   4
l_test03_6:
    movzbl  b, %eax                 #   5:     if     b = 1 goto 3
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_3             
    jmp     l_test03_4              #   6:     goto   4
l_test03_3:
    movl    $1, %eax                #   8:     assign t0 <- 1
    movb    %al, -13(%ebp)         
    jmp     l_test03_5              #   9:     goto   5
l_test03_4:
    movl    $0, %eax                #  11:     assign t0 <- 0
    movb    %al, -13(%ebp)         
l_test03_5:
    movzbl  -13(%ebp), %eax         #  13:     assign c <- t0
    movb    %al, c                 
    movzbl  c, %eax                 #  14:     if     c = 1 goto 8_if_true
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_8_if_true     
    jmp     l_test03_9_if_false     #  15:     goto   9_if_false
l_test03_8_if_true:
    movl    $1, %eax                #  17:     param  0 <- 1
    pushl   %eax                   
    call    WriteInt                #  18:     call   WriteInt
    addl    $4, %esp               
    jmp     l_test03_7              #  19:     goto   7
l_test03_9_if_false:
    movl    $0, %eax                #  21:     param  0 <- 0
    pushl   %eax                   
    call    WriteInt                #  22:     call   WriteInt
    addl    $4, %esp               
l_test03_7:
    movzbl  a, %eax                 #  24:     if     a = 1 goto 13
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_13            
    movzbl  b, %eax                 #  25:     if     b = 1 goto 13
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_13            
    jmp     l_test03_14             #  26:     goto   14
l_test03_13:
    movl    $1, %eax                #  28:     assign t1 <- 1
    movb    %al, -14(%ebp)         
    jmp     l_test03_15             #  29:     goto   15
l_test03_14:
    movl    $0, %eax                #  31:     assign t1 <- 0
    movb    %al, -14(%ebp)         
l_test03_15:
    movzbl  -14(%ebp), %eax         #  33:     assign c <- t1
    movb    %al, c                 
    movzbl  c, %eax                 #  34:     if     c = 1 goto 18_if_true
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_18_if_true    
    jmp     l_test03_19_if_false    #  35:     goto   19_if_false
l_test03_18_if_true:
    movl    $1, %eax                #  37:     param  0 <- 1
    pushl   %eax                   
    call    WriteInt                #  38:     call   WriteInt
    addl    $4, %esp               
    jmp     l_test03_17             #  39:     goto   17
l_test03_19_if_false:
    movl    $0, %eax                #  41:     param  0 <- 0
    pushl   %eax                   
    call    WriteInt                #  42:     call   WriteInt
    addl    $4, %esp               
l_test03_17:
    movzbl  a, %eax                 #  44:     if     a = 1 goto 24
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_24            
    movzbl  b, %eax                 #  45:     if     b = 1 goto 24
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_24            
    movl    $1, %eax                #  46:     assign t2 <- 1
    movb    %al, -15(%ebp)         
    jmp     l_test03_25             #  47:     goto   25
l_test03_24:
    movl    $0, %eax                #  49:     assign t2 <- 0
    movb    %al, -15(%ebp)         
l_test03_25:
    movzbl  -15(%ebp), %eax         #  51:     assign c <- t2
    movb    %al, c                 
    movzbl  c, %eax                 #  52:     if     c = 1 goto 28_if_true
    movl    $1, %ebx               
    cmpl    %ebx, %eax             
    je      l_test03_28_if_true    
    jmp     l_test03_29_if_false    #  53:     goto   29_if_false
l_test03_28_if_true:
    movl    $1, %eax                #  55:     param  0 <- 1
    pushl   %eax                   
    call    WriteInt                #  56:     call   WriteInt
    addl    $4, %esp               
    jmp     l_test03_27             #  57:     goto   27
l_test03_29_if_false:
    movl    $0, %eax                #  59:     param  0 <- 0
    pushl   %eax                   
    call    WriteInt                #  60:     call   WriteInt
    addl    $4, %esp               
l_test03_27:

l_test03_exit:
    # epilogue
    addl    $4, %esp                # remove locals
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

    # scope: test03
a:                                  # <bool>
    .skip    1
b:                                  # <bool>
    .skip    1
c:                                  # <bool>
    .skip    1
    .align   4
i:                                  # <int>
    .skip    4

    # end of global data section
    #-----------------------------------------

    .end
##################################################
