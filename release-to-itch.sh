#! /bin/bash

# This should be run from a folder that contains four folders:
#     minima-linux/  minima-ms-win/  minima-osx/ minima-raspi/
# that each contain the contents of the PICO-8 binary export for the
# appropriate platform plus a docs folder with all supported Minima
# Manual formats.

butler push minima-linux feneric/minima:minima-linux --userversion 1.1.2
butler push minima-osx feneric/minima:minima-osx --userversion 1.1.2
butler push minima-ms-win feneric/minima:minima-ms-win --userversion 1.1.2
butler push minima-raspi feneric/minima:minima-raspi --userversion 1.1.2
butler status feneric/minima:minima-linux
butler status feneric/minima:minima-osx
butler status feneric/minima:minima-ms-win
butler status feneric/minima:minima-raspi

