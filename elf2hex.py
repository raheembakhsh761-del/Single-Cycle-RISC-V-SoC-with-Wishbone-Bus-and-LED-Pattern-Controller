#!/usr/bin/env python3
"""Convert little-endian RISC-V binary to 32-bit hex for Verilog $readmemh.
The output is padded with NOPs to 512 words to avoid Icarus $readmemh warnings.
"""
import sys
from pathlib import Path

if len(sys.argv) != 3:
    print("Usage: python3 elf2hex.py input.bin output.hex")
    sys.exit(1)

inp = Path(sys.argv[1])
out = Path(sys.argv[2])
data = inp.read_bytes()

if len(data) % 4:
    data += b"\x00" * (4 - len(data) % 4)

words = []
for i in range(0, len(data), 4):
    words.append(int.from_bytes(data[i:i+4], byteorder="little"))

MAX_WORDS = 1024
if len(words) > MAX_WORDS:
    print(f"ERROR: program has {len(words)} words, but instruction memory supports {MAX_WORDS} words")
    sys.exit(1)

NOP = 0x00000013
while len(words) < MAX_WORDS:
    words.append(NOP)

with out.open("w") as f:
    for word in words:
        f.write(f"{word:08x}\n")
