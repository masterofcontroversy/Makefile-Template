.SUFFIXES:
.PHONY:

ifeq ($(OS),Windows_NT)
  EXE := .exe
else
  EXE :=
endif

ifeq ($(UNAME),Darwin)
  SHELL := /bin/bash
endif

# Making sure we are using python 3
ifeq ($(shell python -c 'import sys; print(int(sys.version_info[0] > 2))'),1)
  export PYTHON3 := python
else
  export PYTHON3 := python3
endif

# Making sure devkitpro exists and is set up.
ifeq ($(strip $(DEVKITPRO)),)
	$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitPRO")
endif

SOURCE_ROM			:= $(abspath .)/FE8_clean.gba
TARGET_ROM			:= $(abspath .)/Dist/Hack.gba
TARGET_SYM			:= $(abspath .)/Dist/Hack.sym
DIST_FOLDER			:= $(abspath .)/Dist
MAIN_EVENT			:= $(abspath .)/ROMBuildfile.event
EA					:= $(abspath .)/Tools/EventAssembler
EADEP				:= $(realpath .)/Tools/EventAssembler/ea-dep$(EXE)
COLORZCORE 			:= $(realpath .)/Tools/EventAssembler/ColorzCore$(EXE)
TABLES				:= $(abspath .)/Tables

# text
TEXT_FOLDER 		:= $(realpath .)/Text
TEXT_INSTALLER 		:= $(TEXT_FOLDER)/InstallTextData.event
TEXT_MAIN			:= $(TEXT_FOLDER)/text_buildfile.txt
ALL_TEXTFILES		:= $(shell $(EADEP) $(TEXT_MAIN) --add-missings)
TEXT_DEFINITIONS	:= $(TEXT_FOLDER)/Text/TextDefinitions.event

PORTRAIT_DMPS		:= $(abspath .)/Graphics/Portraits/dmp
MAPSPRITES_DMPS		:= $(abspath .)/Graphics/MapSprites/dmp

# tools
GRIT 				:= $(DEVKITPRO)/tools/bin/grit$(EXE)
PORTRAITFORMATTER 	:= $(realpath .)/Tools/EventAssembler/Tools/PortraitFormatter$(EXE)
COMPRESS			:= $(realpath .)/Tools/EventAssembler/Tools/compress$(EXE)
PARSEFILE			:= $(realpath .)/Tools/EventAssembler/Tools/ParseFile$(EXE)
C2EA				:= $(PYTHON3) $(realpath .)/Tools/C2EA/c2ea.py
TMX2EA				:= $(PYTHON3) $(realpath .)/Tools/tmx2ea/tmx2ea.py
TEXT_PROCESS		:= $(PYTHON3) $(realpath .)/Tools/TextProcess/text-process-classic.py
SYMCOMBO			:= $(PYTHON3) $(realpath .)/Tools/sym/SymCombo.py
S2EA				:= $(PYTHON3) $(realpath .)/Tools/s2ea.py
VANILLASYM			:= $(abspath .)/Tools/sym/VanillaOffsets.sym

EVENT_DEPENDS		:= $(shell $(EADEP) $(MAIN_EVENT) -I $(EA) --add-missings)

GRIT4BPPLZ77ARGS	:= -gu 16 -gzl -gB 4 -p! -m! -ft bin -fh!
GRIT8BPPLZ77ARGS	:= -gu 16 -gzl -gB 8 -p! -m! -ft bin -fh!
GRIT4BPPARGS		:= -gu 16 -gB 4 -p! -m! -ft bin -fh!
GRIT2BPPARGS		:= -gu 16 -gb -gB 2 -p! -m! -ft bin -fh!
GRITPALETTEARGS		:= -g! -m! -p -ft bin -fh!


hack: $(TARGET_ROM)

.PHONY: hack %.dmp

$(TARGET_ROM): $(TEXT_INSTALLER) $(MAIN_EVENT) $(EVENT_DEPENDS) $(SOURCE_ROM)
	@[ -d $(DIST_FOLDER) ] || mkdir $(DIST_FOLDER)
	@cp -f "$(SOURCE_ROM)" "$(TARGET_ROM)" || exit 2
	@$(COLORZCORE) A FE8 "-output:$(TARGET_ROM)" "-input:$(MAIN_EVENT)" "--nocash-sym:$(TARGET_SYM)" --build-times
	@$(SYMCOMBO) $(TARGET_SYM) $(TARGET_SYM) $(VANILLASYM)

%.event: %.csv %.nmm
	@echo | $(C2EA) -csv $*.csv -nmm $*.nmm -out $*.event $(SOURCE_ROM) > /dev/null

%.2bpp: %.png
	cd $(dir $<) && $(GRIT) $< $(GRIT2BPPARGS)
	@mv $(basename $<).img.bin $@

%.4bpp: %.png
	cd $(dir $<) && $(GRIT) $< $(GRIT4BPPARGS)
	@mv $(basename $<).img.bin $@

%.4bpp.lz77: %.png
	cd $(dir $<) && $(GRIT) $< $(GRIT4BPPLZ77ARGS)
	@mv $(basename $<).img.bin $@

%.8bpp.lz77: %.png
	cd $(dir $<) && $(GRIT) $< $(GRIT8BPPLZ77ARGS)
	@mv $(basename $<).img.bin $@

%.pal: %.png
	cd $(dir $<) && $(GRIT) $< $(GRITPALETTEARGS)
	@mv $(basename $<).pal.bin $@

%.portraitdmp: %.png
	$(PORTRAITFORMATTER) $< -o $@

%.fetxt.dmp: %.fetxt
	$(NOTIFY_PROCESS)
	$(PARSEFILE) $< -o $@ > /dev/null

$(TEXT_INSTALLER) $(TEXT_DEFINITIONS): $(TEXT_MAIN) $(ALL_TEXTFILES)
	cd $(TEXT_FOLDER) && $(TEXT_PROCESS) $(notdir $(TEXT_MAIN)) --installer $(notdir $(TEXT_INSTALLER)) --definitions $(notdir $(TEXT_DEFINITIONS)) --parser-exe $(PARSEFILE)

%.event %_data.dmp: %.tmx
	$(NOTIFY_PROCESS)
	@echo | $(TMX2EA) $< > /dev/null

%.dmp:
	: do nothing for $@
%.bin:
	: do nothing for $@


include Wizardry.mk

clean:
	@rm -rf Dist
	@rm -rf Graphics/MapSprites/dmp/*
	@rm -rf Graphics/Portraits/dmp/*
	@rm -rf Text/.TextEntries/ Text/TextDefinitions.event Text/InstallTextData.event
	@find . -name *.lz77 -type f -delete
	@find . -name *.4bpp -type f -delete
	@find . -name *.2bpp -type f -delete
	@find EngineHacks/ -name "*.lyn.event" -type f -delete

	@echo All clean!

.PHONY: clean
