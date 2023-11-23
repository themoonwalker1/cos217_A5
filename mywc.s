//----------------------------------------------------------------------
// mywc.s
// Author: Praneeth Bhandaru
//----------------------------------------------------------------------

        .section .rodata

wordCountResultFormatStr:
        .string "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------

        .section .data

lLineCount:
        .quad   0

lWordCount:
        .quad   0

lCharCount:
        .quad   0

iInWord:
        .word   0

//----------------------------------------------------------------------

        .section .bss

iChar:
        .skip   4

//----------------------------------------------------------------------

        .section .text

        //--------------------------------------------------------------
        // Write to stdout counts of how many lines, words, and
        // characters are in stdin. A word is a sequence of
        // non-whitespace characters. Whitespace is defined by the
        // isspace() function. Return 0.
        //
        // int main(void)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 64
        .equ    EOF, -1

        .global main


main:
whileCharLoop:
        ldr     x0, =iChar
        bl      getchar
        cmp     x0, #EOF
        beq     endWhileCharLoop

        ldr     x1, =lCharCount
        ldr     x2, [x1]
        add     x2, x2, 1
        str     x2, [x1]

        ldr     x3, =iChar
        ldr     x3, [x3]
        bl      isspace
        cmp     x0, #0
        bne     else1

        ldr     x4, =iInWord
        ldr     x4, [x4]
        cmp     x4, #0
        beq     endIf2

        ldr     x5, =lWordCount
        ldr     x6, [x5]
        add     x6, x6, 1
        str     x6, [x5]

        ldr     x4, =iInWord
        str     xzr, [x4]
endIf2:
        b       else1

else1:
        ldr     x7, =iInWord
        ldr     x7, [x7]
        cmp     x7, #0
        bne     endIf3

        ldr     x8, =iInWord
        str     #1, [x8]
endIf3:

        ldr     x3, =iChar
        ldr     x3, [x3]
        cmp     x3, #'\n'
        bne     endIf4

        ldr     x9, =lLineCount
        ldr     x10, [x9]
        add     x10, x10, 1
        str     x10, [x9]
endIf4:

        b       whileCharLoop

endWhileCharLoop:
        ldr     x11, =iInWord
        ldr     x11, [x11]
        cmp     x11, #0
        beq     endIf5

        ldr     x12, =lWordCount
        ldr     x13, [x12]
        add     x13, x13, 1
        str     x13, [x12]
endIf5:

        ldr     x14, =lLineCount
        ldr     x15, [x14]
        ldr     x16, =lWordCount
        ldr     x17, [x16]
        ldr     x18, =lCharCount
        ldr     x19, [x18]
        ldr     x20, =printfFormatStr
        bl      printf
        mov     x0, #0
        ret
