GCC = gcc217
#GCC = gcc

all: fibc fibs fibso fibsoo

clean:
	rm -f *.o fibs fibc fibso fibsoo meminfo*.out *.gch

fibc: fib.c bigintadd.c bigint.c
	$(GCC) -D NDEBUG -O fib.c bigintadd.c bigint.c -o fibc

fibs: fib.c bigintadd.s bigint.c
	$(GCC) -D NDEBUG -O fib.c bigintadd.s bigint.c -o fibs

fibso: fib.c bigintaddopt.s bigint.c
	$(GCC) -D NDEBUG -O fib.c bigintaddopt.s bigint.c -o fibso

fibsoo: fib.c bigintaddopt.s bigint.c
	$(GCC) -D NDEBUG -O fib.c bigintaddoptopt.s bigint.c -o fibsoo