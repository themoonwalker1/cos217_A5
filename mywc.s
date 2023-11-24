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
        .equ    MAIN_STACK_BYTECOUNT, 16

        .equ    EOF, -1
        .equ    FALSE, 0
        .equ    TRUE, 1

        .global main


main:
        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

whileCharLoop:
        // iChar = getchar();
        adr     x0, iChar
        ldr     w0, [x0]
        bl      getchar

        // if (iChar == EOF) goto endWhileCharLoop
        cmp     w0, EOF
        beq     endWhileCharLoop

        // lCharCount++;
        adr     x1, lCharCount;
        ldr     x2, [x1]
        add     x2, x2, #1
        str     x2, [x1];

        // if (!isspace(iChar)) goto else1;
        mov     w3, w0
        bl      isspace
        cmp     x0, FALSE
        beq     else1

        // if (!iInWord) goto endIf2;
        adr     x4, iInWord
        ldr     w5, [x4]
        cmp     w5, TRUE
        bne     endIf2

        // lWordCount++;
        adr     x4, lWordCount
        ldr     x5, [x4]
        add     x5, x5, #1
        str     x5, [x4]

        // iInWord = FALSE;
        adr     x4, iInWord
        ldr     w5, [x4]
        mov     w5, FALSE
        str     w5, [x4]

endIf2:
        // goto endIf1;
        b       endIf1

else1:
        // if (iInWord) goto endIf3;
        adr     x4, iInWord
        ldr     w5, [x4]
        cmp     w5, TRUE
        beq     endIf3;

        // iInWord = TRUE;
        mov     w5, TRUE
        str     w5, [x4]

endIf3:
endIf1:
        // if (iChar != '\n') goto endIf4;
        mov     w0, w3
        cmp     w0, '\n'        // CAN WE PUT \n LIKE THIS?????
        bne     endIf4

        // lLineCount++;
        adr     x4, lLineCount
        ldr     x5, [x4]
        add     x5, x5, #1
        str     x5, [x4]

endIf4:
        // goto whileCharLoop;
        b       whileCharLoop;

endWhileCharLoop:
        // if (!iInWord) goto endIf5;
        adr     x4, iInWord
        ldr     w5, [x4]
        cmp     w5, TRUE
        bne     endIf5;

        // lWordCount++;
        adr     x4, lWordCount
        ldr     x5, [x4]
        add     x5, x5, #1
        str     x5, [x4]

endIf5:
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, wordCountResultFormatStr
        adr     x1, lLineCount
        adr     x2, lWordCount
        adr     x3, lCharCount
        ldr     x1, [x1]
        ldr     x2, [x2]
        ldr     x3, [x3]
        bl      printf

        // Epilog & return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)



