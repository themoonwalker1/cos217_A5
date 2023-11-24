GCC = gcc217
#GCC = gcc

all: fibc fibs

clean:
	rm -f *.o fibs fibc meminfo*.out

fibc: fib.o bigintadd.o bigint.o
	$(GCC) fib.o bigintadd.o bigint.o -o fibc

fibs: fib.c bigintadd.s bigint.c
	$(GCC) -D NDEBUG -O fib.c bigintadd.s bigint.c -o fibs

fib.o: fib.c bigint.h
	$(GCC) -c fib.c bigint.h

bigintadd.o: bigintadd.c bigint.h bigintprivate.h
	$(GCC) -c bigintadd.c bigint.h bigintprivate.h

bigint.o: bigint.c bigint.h bigintprivate.h
	$(GCC) -c bigint.c bigint.h bigintprivate.h