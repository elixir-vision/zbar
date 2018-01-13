# Variables to override
#
# CC            C compiler
# CROSSCOMPILE  crosscompiler prefix, if any
# CFLAGS        compiler flags for compiling all C files
# LDFLAGS       linker flags for linking all binaries

# Initialize some variables if not set
LDFLAGS ?=
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -g
CC ?= $(CROSSCOMPILE)-gcc

DEFAULT_TARGETS ?= priv priv/zbar_scanner

# Link in all of the VideoCore libraries
LDFLAGS +=-lzbar -ljpeg

SRC=src/zbar_scanner.c
OBJ=$(SRC:.c=.o)

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
