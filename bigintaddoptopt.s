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
        ULCARRY     .req x22

        // Parameter offsets
        OSUM        .req x21
        OADDEND2    .req x20
        OADDEND1    .req x19

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
        str     x22, [sp, 32]
        str     x23, [sp, 40]
        str     x24, [sp, 48]
        str     x25, [sp, 56]

        mov     OADDEND1, x0
        mov     OADDEND2, x1
        mov     OSUM, x2

        // unsigned long ulCarry;
        // unsigned long ulSum;
        // long lIndex;
        // long lSumLength;

        // lSumLength = BigInt_larger(oAddend1->lLength,
        //                            oAddend2->lLength);
        ldr     x0, [OADDEND1, LLENGTH]
        ldr     x1, [OADDEND2, LLENGTH]

        // BigInt_larger + TEMP FIX
        cmp     x0, x1
        bls     else1
        mov     LSUMLENGTH, x0
        mov     x0, OADDEND2
        mov     OADDEND2, OADDEND1
        mov     OADDEND1, x0
        b       if1
else1:
        mov     LSUMLENGTH, x1
if1:

        // if (oSum->lLength <= lSumLength) goto if2;
        ldr     x0, [OSUM, LLENGTH]
        cmp     x0, LSUMLENGTH
        bls     if2

        // memset(oSum->aulDigits, 0,
        //        MAX_DIGITS * sizeof(unsigned long));
        add     x0, OSUM, AULDIGITS
        mov     x1, #0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

if2:
        // lIndex = 0;
        mov     LINDEX, #0

        // ulSum = 0;
        mov     ULSUM, xzr

startForLoop:

        // ulCarry = 0;
        adcs     x0, xzr, xzr // Clear carry flag

        // ulSum += oAddend1->aulDigits[lIndex];
        add     x1, OADDEND1, AULDIGITS
        ldr     x1, [x1, LINDEX, LSL #3]
        adcs    ULSUM, ULSUM, x1

        // ulSum += oAddend2->aulDigits[lIndex];
        add     x1, OADDEND2, AULDIGITS
        ldr     x1, [x1, LINDEX, LSL #3]
        adcs     ULSUM, ULSUM, x1

        // oSum->aulDigits[lIndex] = ulSum;
        add     x1, OSUM, AULDIGITS
        str     ULSUM, [x1, LINDEX, LSL #3]

        // lIndex++;
        add     LINDEX, LINDEX, #1

        // ulSum = ulCarry; ulCarry = 0;
        adcs     ULSUM, xzr, xzr

        // if (lIndex < lSumLength) goto startForLoop;
        cmp     LINDEX, LSUMLENGTH
        blt     startForLoop

endForLoop:
        // if (ulSum != 1) goto if5;
        cmp     ULSUM, #1
        bne     if5

        // if (lSumLength != MAX_DIGITS) goto if6;
        cmp     LSUMLENGTH, MAX_DIGITS
        bne     if6

        // Epilog & return FALSE;
        mov     x0, FALSE
        ldr     x25, [sp, 56]
        ldr     x24, [sp, 48]
        ldr     x23, [sp, 40]
        ldr     x22, [sp, 32]
        ldr     x21, [sp, 24]
        ldr     x20, [sp, 16]
        ldr     x19, [sp, 8]
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

if6:
        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, #1
        add     x1, OSUM, AULDIGITS
        str     x0, [x1, LSUMLENGTH, LSL #3]

        // lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, #1

if5:
        // oSum->lLength = lSumLength;
        str     LSUMLENGTH, [OSUM, LLENGTH]

        // Epilog & return TRUE
        mov     x0, TRUE
        ldr     x25, [sp, 56]
        ldr     x24, [sp, 48]
        ldr     x23, [sp, 40]
        ldr     x22, [sp, 32]
        ldr     x21, [sp, 24]
        ldr     x20, [sp, 16]
        ldr     x19, [sp, 8]
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)
