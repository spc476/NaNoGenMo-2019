
CC      = gcc -std=c99 -pedantic -Wall -Wextra
CFLAGS  = -g
LDFLAGS = -g

SHARED = -fPIC -shared

INSTALL         = /usr/bin/install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA    = $(INSTALL) -m 644

prefix      = /usr/local
libdir      = $(prefix)/lib
datarootdir = $(prefix)/share
dataroot    = $(datarootdir)

LUA         ?= lua
LUA_VERSION := $(shell $(LUA) -e "print(_VERSION:match '^Lua (.*)')")
LUADIR      ?= $(dataroot)/lua/$(LUA_VERSION)
LIBDIR      ?= $(libdir)/lua/$(LUA_VERSION)

ifneq ($(LUA_INCDIR),)
  override CFLAGS += -I$(LUA_INCDIR)
endif

# ===================================================

%.so : %.c
	$(CC) $(CFLAGS) $(SHARED) -o $@ $< $(LDFLAGS)

.PHONY: all install uninstall clean

all: LuaXML/LuaXML_lib.so


install: all
	$(INSTALL) -d $(DESTDIR)$(LUADIR)
	$(INSTALL) -d $(DESTDIR)$(LIBDIR)
	$(INSTALL_PROGRAM) LuaXML/LuaXML_lib.so $(DESTDIR)$(LIBDIR)
	$(INSTALL_DATA)    LuaXML/LuaXml.lua    $(DESTDIR)$(LUADIR)
	$(INSTALL_DATA)    Lua/lxpath.lua       $(DESTDIR)$(LUADIR)

uninstall:
	$(RM) $(DESTDIR)$(LIBDIR)/LuaXML_lib.so
	$(RM) $(DESTDIR)$(LUADIR)/LuaXml.lua
	$(RM) $(DESTDIR)$(LUADIR)/lxpath.lua

clean:
	$(RM) $(shell find . -name '*~')
	$(RM) LuaXML/LuaXML_lib.so


# ===================================================
