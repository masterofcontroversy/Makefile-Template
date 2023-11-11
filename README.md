# Makefile-Template
Simple makefile template usable for Windows and Linux systems

## Build requirements
- Devkitpro must be installed and listed in your PATH
- python 3 must be installed, and the following python packages must be installed:  
  six, tmx, lzss
- mono runtime (For Linux systems)

## Build instructions
Place a clean Fire Emblem The Sacred Stones USA ROM in the root directory and name it `FE8_clean.gba`.  
Run `make` in the root directory.  

The output, named `Hack.gba` by default, will be placed in the `Dist` folder.

## Credits
- Ronan portrait by Stitch
- Fighter map sprites by L95
- Skip Huffman Decompression by Zane Avernathy
- Event Assembler by CrazyColorz
- Portrait Formatter by CrazyColorz
- Sym Tool by Snakey1
- ea-dep by StanHash
- TMX2EA by circleseverywhere
- C library by StanHash
- C2EA by circleseverywhere
