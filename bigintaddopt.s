//----------------------------------------------------------------------
// bigintadd.s
// Author: Praneeth Bhandaru
//----------------------------------------------------------------------

        .section .rodata

        // Nothing

//----------------------------------------------------------------------

        .section .data

        // Nothing

//----------------------------------------------------------------------

        .section .bss

        // Nothing

//----------------------------------------------------------------------

        .section .text

        .equ    FALSE, 0
        .equ    TRUE, 1
        .equ    MAX_DIGITS, 32768

        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //
        // static long BigInt_larger(long lLength1, long lLength2)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32

        // Local Variable offsets
        LLARGER     .req x21 // Callee-saved

        // Parameter offsets
        LLENGTH2    .req x20 // Callee-saved
        LLENGTH1    .req x19 // Callee-saved

BigInt_larger:
        // Prolog
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]

        mov     x0, LLENGTH1
        mov     x1, LLENGTH2

        // long lLarger;

        // if (lLength1 <= lLength2) goto else1;
        cmp     LLENGTH1, LLENGTH2
        bls     else1

        // lLarger = lLength1;
        mov     LLARGER, LLENGTH1

        // goto if1;
        b       if1

else1:
        // lLarger = lLength2;
        mov     LLARGER, LLENGTH2

if1:
        // Epilog & return lLarger;
        mov     x0, LLARGER
        ldr     x21, [sp, 24]
        ldr     x20, [sp, 16]
        ldr     x19, [sp, 8]
        ldr     x30, [sp]
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret

        .size   BigInt_larger, (. - BigInt_larger)

        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should
        // be distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if
        // an overflow occurred, and 1 (TRUE) otherwise.
        //
        // int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2,
        //                BigInt_T oSum)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    ADD_STACK_BYTECOUNT, 64

        // Local Variable offsets
        .equ    LSUMLENGTH, 8
        .equ    LINDEX, 16
        .equ    ULSUM, 24
        .equ    ULCARRY, 32

        // Parameter offsets
        .equ    OSUM, 40
        .equ    OADDEND2, 48
        .equ    OADDEND1, 56

        // BigInt_T struct offsets
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8

        .global BigInt_add
BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, OADDEND1]
        str     x1, [sp, OADDEND2]
        str     x2, [sp, OSUM]

        // unsigned long ulCarry;
        // unsigned long ulSum;
        // long lIndex;
        // long lSumLength;

        // lSumLength = BigInt_larger(oAddend1->lLength,
        //                            oAddend2->lLength);
        ldr     x0, [sp, OADDEND1]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, OADDEND2]
        ldr     x1, [x1, LLENGTH]
        bl      BigInt_larger
        str     x0, [sp, LSUMLENGTH]

        // if (oSum->lLength <= lSumLength) goto if2;
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        bls     if2

        // memset(oSum->aulDigits, 0,
        //        MAX_DIGITS * sizeof(unsigned long));
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        mov     x1, #0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

if2:
        // ulCarry = 0;
        mov     x0, #0
        str     x0, [sp, ULCARRY]

        // lIndex = 0;
        mov     x0, #0
        str     x0, [sp, LINDEX]

startForLoop:
        // if (lIndex >= lSumLength) goto endForLoop;
        ldr     x0, [sp, LINDEX]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        bge     endForLoop

        // ulSum = ulCarry;
        ldr     x0, [sp, ULCARRY]
        str     x0, [sp, ULSUM]

        // ulCarry = 0;
        mov     x0, #0
        str     x0, [sp, ULCARRY]

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND1]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x1, [x1, x2, LSL #3]
        add     x0, x0, x1
        str     x0, [sp, ULSUM]

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto if3;
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND1]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x1, [x1, x2, LSL #3]
        cmp     x0, x1
        bhs     if3

        // ulCarry = 1;
        mov     x0, #1
        str     x0, [sp, ULCARRY]

if3:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND2]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x1, [x1, x2, LSL #3]
        add     x0, x0, x1
        str     x0, [sp, ULSUM]

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto if4;
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND2]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x1, [x1, x2, LSL #3]
        cmp     x0, x1
        bhs     if4

        // ulCarry = 1;
        mov     x0, #1
        str     x0, [sp, ULCARRY]

if4:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OSUM]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        str     x0, [x1, x2, LSL #3]

        // lIndex++;
        ldr     x0, [sp, LINDEX]
        add     x0, x0, #1
        str     x0, [sp, LINDEX]

        // goto startForLoop;
        b       startForLoop

endForLoop:
        // if (ulCarry != 1) goto if5;
        ldr     x0, [sp, ULCARRY]
        cmp     x0, #1
        bne     if5

        // if (lSumLength != MAX_DIGITS) goto if6;
        ldr     x0, [sp, LSUMLENGTH]
        cmp     x0, MAX_DIGITS
        bne     if6

        // Epilog & return FALSE;
        mov     x0, FALSE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

if6:
        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, 1
        ldr     x1, [sp, OSUM]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LSUMLENGTH]
        str     x0, [x1, x2, LSL #3]

        // lSumLength++;
        ldr     x0, [sp, LSUMLENGTH]
        add     x0, x0, #1
        str     x0, [sp, LSUMLENGTH]

if5:
        // oSum->lLength = lSumLength;
        ldr     x0, [sp, OSUM]
        ldr     x1, [sp, LSUMLENGTH]
        str     x1, [x0, LLENGTH]

        // Epilog & return TRUE
        mov     x0, TRUE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)

