
CC      = gcc -std=c99 -pedantic -Wall -Wextra
CFLAGS  = -g
LDFLAGS = -g

SHARED = -fPIC -shared

%.so : %.c
	$(CC) $(CFLAGS) $(SHARED) -o $@ $< $(LDFLAGS)

.PHONY: all clean

all: LuaXML/LuaXML.so

clean:
	$(RM) $(shell find . -name '*~')
