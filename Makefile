# Variables to override
#
# CC            C compiler
# CROSSCOMPILE  crosscompiler prefix, if any
# CFLAGS        compiler flags for compiling all C files
# LDFLAGS       linker flags for linking all binaries
# MIX_COMPILE_PATH  path to the build's ebin directory

LDFLAGS += -lzbar -ljpeg
CFLAGS += -Wall -std=gnu99
CC ?= $(CROSSCOMPILE)-gcc

ifeq ($(MIX_COMPILE_PATH),)
  $(error MIX_COMPILE_PATH should be set by elixir_make!)
endif

PREFIX = $(MIX_COMPILE_PATH)/../priv
BUILD  = $(MIX_COMPILE_PATH)/../obj

SRC=src/zbar_scanner.c
OBJ=$(SRC:.c=.o)

DEFAULT_TARGETS ?= $(PREFIX) $(PREFIX)/zbar_scanner

calling_from_make:
	mix compile

all: $(BUILD) $(DEFAULT_TARGETS)

$(BUILD)/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD):
	mkdir -p $@

$(PREFIX):
	mkdir -p $@

$(PREFIX)/zbar_scanner: $(BUILD)/zbar_scanner.o
	$(CC) $^ $(LDFLAGS) -o $@

clean:
	rm -rf $(PREFIX)/* $(BUILD)/*

.PHONY: all clean calling_from_make
