#GCC = gcc217
GCC = gcc

all: fibc fibs

clean:
	rm -f *.o fibs fibc meminfo*.out

fibc: fib.o bigintadd.o bigint.o
	$(GCC) fib.o bigintadd.o bigint.o -o fibc

fibs: fib.o bigintadds.o bigint.o
	#$(GCC) -D NDEBUG -O fib.o bigintadds.o bigint.o -o fibs
	$(GCC) -D NDEBUG -O fib.c bigintadd.s bigint.c -o fibs

fib.o: fib.c bigint.h
	$(GCC) -c fib.c bigint.h

bigintadd.o: bigintadd.c bigint.h bigintprivate.h
	$(GCC) -c bigintadd.c bigint.h bigintprivate.h

bigintadds.o: bigintadd.s bigint.h bigintprivate.h
	$(GCC) -c bigintadd.c bigint.h bigintprivate.h

bigint.o: bigint.c bigint.h bigintprivate.h
	$(GCC) -c bigint.c bigint.h bigintprivate.h