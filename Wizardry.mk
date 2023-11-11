.SUFFIXES:
.PHONY:

# Including devkitARM tool definitions
include $(DEVKITARM)/base_tools

# defining path of lyn reference
LYN 	:= $(abspath .)/Tools/EventAssembler/Tools/lyn$(EXE)
LYNREF 	:= $(abspath .)/Tools/FE-CLib/reference/FE8U-20190316.o

# setting up compilation flags
ARCH	:= -mcpu=arm7tdmi -mthumb -mthumb-interwork
CFLAGS	:= $(ARCH) -Wall -O2 -mtune=arm7tdmi

# header files location
HEADER_FILES := $(abspath .)/Tools/FE-CLib/include

# C to ASM rule
%.s: %.c
	$(CC) $(CFLAGS) -S $< -I $(HEADER_FILES) -o $@ -fverbose-asm -mlong-calls

# ASM to OBJ
%.o: %.s
	$(AS) $(ARCH) $< -I $(dir $<) -o $@

# OBJ to EVENT rule
%.lyn.event: %.o $(LYNREF)
	@$(LYN) $< $(LYNREF) > $@

# .PRECIOUS: %.s
