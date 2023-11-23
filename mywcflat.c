/*--------------------------------------------------------------------*/
/* mywc.c                                                             */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {
    FALSE, TRUE
};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void) {
whileCharLoop:
    iChar = getchar();
    if (iChar == EOF) goto endWhileCharLoop;

    lCharCount++;

    if (!isspace(iChar)) goto else1;
    if (!iInWord) goto endIf2;
    lWordCount++;
    iInWord = FALSE;
endIf2:
    goto endIf1;
else1:
    if (iInWord) goto endIf3;
    iInWord = TRUE;
endIf3:
endIf1:

    if (iChar != '\n') goto endIf4;
    lLineCount++;

endIf4:

    goto whileCharLoop;

endWhileCharLoop:

    if (!iInWord) goto endIf5;
    lWordCount++;
endIf5:

    printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
    return 0;
}
