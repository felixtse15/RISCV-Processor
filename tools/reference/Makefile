# Makefile

CC := gcc
CFLAGS := -Wall -Wextra -Wpedantic -g -fstack-protector-all
TARGET ?= main
FILES ?= $(wildcard *.c)


OBJS := $(FILES:.c=.o)


all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^


clean:
	rm -f *.o $(TARGET)
