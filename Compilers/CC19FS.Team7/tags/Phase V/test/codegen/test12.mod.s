##################################################
# test12
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

    # scope Int
Int:
    # stack offsets:
    #    -16(%ebp)   4  [ $i        <int> %ebp-16 ]

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
    movl    $75, %eax               #   0:     assign i <- 75
    movl    %eax, -16(%ebp)        
    movl    -16(%ebp), %eax         #   1:     return i
    jmp     l_Int_exit             

l_Int_exit:
    # epilogue
    addl    $4, %esp                # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope Char
Char:
    # stack offsets:
    #    -13(%ebp)   1  [ $c        <char> %ebp-13 ]

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
    movl    $66, %eax               #   0:     assign c <- 66
    movb    %al, -13(%ebp)         
    movzbl  -13(%ebp), %eax         #   1:     return c
    jmp     l_Char_exit            

l_Char_exit:
    # epilogue
    addl    $4, %esp                # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope Bool
Bool:
    # stack offsets:
    #    -13(%ebp)   1  [ $b        <bool> %ebp-13 ]

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
    movl    $1, %eax                #   0:     assign b <- 1
    movb    %al, -13(%ebp)         
    movzbl  -13(%ebp), %eax         #   1:     return b
    jmp     l_Bool_exit            

l_Bool_exit:
    # epilogue
    addl    $4, %esp                # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope Test
Test:
    # stack offsets:
    #    -13(%ebp)   1  [ $b        <bool> %ebp-13 ]
    #    -14(%ebp)   1  [ $c        <char> %ebp-14 ]
    #    -20(%ebp)   4  [ $i        <int> %ebp-20 ]
    #    -21(%ebp)   1  [ $t0       <bool> %ebp-21 ]
    #    -22(%ebp)   1  [ $t1       <char> %ebp-22 ]
    #    -28(%ebp)   4  [ $t2       <int> %ebp-28 ]

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
    call    Bool                    #   0:     call   t0 <- Bool
    movb    %al, -21(%ebp)         
    movzbl  -21(%ebp), %eax         #   1:     assign b <- t0
    movb    %al, -13(%ebp)         
    call    Char                    #   2:     call   t1 <- Char
    movb    %al, -22(%ebp)         
    movzbl  -22(%ebp), %eax         #   3:     assign c <- t1
    movb    %al, -14(%ebp)         
    call    Int                     #   4:     call   t2 <- Int
    movl    %eax, -28(%ebp)        
    movl    -28(%ebp), %eax         #   5:     assign i <- t2
    movl    %eax, -20(%ebp)        

l_Test_exit:
    # epilogue
    addl    $16, %esp               # remove locals
    popl    %edi                   
    popl    %esi                   
    popl    %ebx                   
    popl    %ebp                   
    ret                            

    # scope test12
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
    call    Test                    #   0:     call   Test

l_test12_exit:
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
