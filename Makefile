
CC      = gcc -std=c99 -pedantic -Wall -Wextra
CFLAGS  = -g
LDFLAGS = -g

.PHONY: clean

clean:
	$(RM) $(shell find . -name '*~')
