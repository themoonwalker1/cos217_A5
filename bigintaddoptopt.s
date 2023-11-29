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
        LSUMLENGTH  .req x25
        LINDEX      .req x24
        ULSUM       .req x23

        // Parameter offsets
        OSUM        .req x21
        OADDEND2    .req x20
        OADDEND1    .req x19

        // Parameter Constants (aulDigits)
        OSUM_AD     .req x28

        // BigInt_T struct offsets
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]
        str     x23, [sp, 32]
        str     x24, [sp, 40]
        str     x25, [sp, 48]
        str     x28, [sp, 56]

        mov     OSUM, x2

        // unsigned long ulCarry;
        // unsigned long ulSum;
        // long lIndex;
        // long lSumLength;

        // lSumLength = BigInt_larger(oAddend1->lLength,
        //                            oAddend2->lLength);
        ldr     x2, [x0, LLENGTH]
        ldr     x3, [x1, LLENGTH]

        // BigInt_larger
        cmp     x2, x3
        bls     else1

        // lSumLength = larger_length
        mov     LSUMLENGTH, x2

        // oAddEnd1 = Smaller Number
        // oAddEnd2 = Larger Number
        mov     OADDEND1, x1
        mov     OADDEND2, x0

        b       if1
else1:
        // lSumLength = larger_length
        mov     LSUMLENGTH, x3

        // oAddEnd1 = Smaller Number
        // oAddEnd2 = Larger Number
        mov     OADDEND1, x0
        mov     OADDEND2, x1
if1:
        add     OSUM_AD, OSUM, AULDIGITS

        // if (oSum->lLength <= lSumLength) goto if2;
        ldr     x0, [OSUM, LLENGTH]
        cmp     x0, LSUMLENGTH
        bls     if2

        // memset(oSum->aulDigits, 0,
        //        MAX_DIGITS * sizeof(unsigned long));
        mov     x0, OSUM_AD
        mov     x1, xzr
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

if2:
        // lIndex = 0;
        mov     LINDEX, xzr

        // ulSum = 0;
        mov     ULSUM, xzr

        // so we can compare to the byte-position index
        lsl     x1, LSUMLENGTH, #3
        add     x2, OADDEND1, AULDIGITS
        add     x3, OADDEND2, AULDIGITS


startForLoop:

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [x2, LINDEX]
        adds    ULSUM, ULSUM, x0

        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [x3, LINDEX]
        adcs     ULSUM, ULSUM, x0

        // oSum->aulDigits[lIndex] = ulSum;
        str     ULSUM, [OSUM_AD, LINDEX]

        // lIndex++;
        add     LINDEX, LINDEX, #8

        // ulSum = ulCarry; ulCarry = 0;
        adcs     ULSUM, xzr, xzr

        // if (lIndex < lSumLength) goto startForLoop;
        cmp     LINDEX, x1
        blt     startForLoop

endForLoop:
        // if (ulCarry != 1) goto if5;
        cmp     ULSUM, #1
        bne     if5

        // if (lSumLength != MAX_DIGITS) goto if6;
        cmp     LSUMLENGTH, MAX_DIGITS
        bne     if6

        // Epilog & return FALSE;
        mov     x0, FALSE
        ldr     x28, [sp, 56]
        ldr     x25, [sp, 48]
        ldr     x24, [sp, 40]
        ldr     x23, [sp, 32]
        ldr     x21, [sp, 24]
        ldr     x20, [sp, 16]
        ldr     x19, [sp, 8]
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

if6:
        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, #1
        str     x0, [OSUM_AD, LSUMLENGTH, LSL #3]

        // lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, #1

if5:
        // oSum->lLength = lSumLength;
        str     LSUMLENGTH, [OSUM, LLENGTH]

        // Epilog & return TRUE
        mov     x0, TRUE
        ldr     x28, [sp, 56]
        ldr     x25, [sp, 48]
        ldr     x24, [sp, 40]
        ldr     x23, [sp, 32]
        ldr     x21, [sp, 24]
        ldr     x20, [sp, 16]
        ldr     x19, [sp, 8]
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)
