GCC = gcc217
#GCC = gcc

all: fibc fibs

clean:
	rm -f *.o fibs fibc meminfo*.out *.gch

fibc: fib.c bigintadd.c bigint.c
	$(GCC) fib.o bigintadd.o bigint.o -o fibc

fibs: fib.c bigintadd.s bigint.c
	$(GCC) -D NDEBUG -O fib.c bigintadd.s bigint.c -o fibs

fibso: fib.c bigintaddopt.s bigint.c
	$(GCC) -D NDEBUG -O fib.c bigintaddopt.s bigint.c -o fibso

fibsoo: fib.c bigintaddopt.s bigint.c
	$(GCC) -D NDEBUG -O fib.c bigintaddoptopt.s bigint.c -o fibsoo