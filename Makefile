# Variables to override
#
# CC            C compiler
# CROSSCOMPILE  crosscompiler prefix, if any
# CFLAGS        compiler flags for compiling all C files
# LDFLAGS       linker flags for linking all binaries

LDFLAGS += -lzbar -ljpeg
CFLAGS += -Wall -std=gnu99
CC ?= $(CROSSCOMPILE)-gcc

SRC=src/zbar_scanner.c
OBJ=$(SRC:.c=.o)

DEFAULT_TARGETS ?= priv priv/zbar_scanner

.PHONY: all clean

all: $(DEFAULT_TARGETS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

priv:
	mkdir -p priv

priv/zbar_scanner: $(OBJ)
	$(CC) $^ $(LDFLAGS) -o $@

clean:
	rm -f priv/zbar_scanner $(OBJ)
