
CC= gcc

CFLAGS=`pkg-config --cflags opencv`
LDFLAGS=`pkg-config --libs opencv`



all: tracking.h
	$(CC) tracking.cpp -o tracking.o -Wall $(LDFLAGS)
clean:
	-rm *.o
