Generates a pached bios for the Asus KGPE-D16 dual socket Opteron motherboard.

The KGPE-D16 only supports the Opteron 6300 series cpus after a certain bios update, which are the cpus I have. Instead of analyzing all bioses to see if I could just flash a single bios version (i.e. bioses aren't deltas, but complete), I elected to assume that the bioses were deltas and to merge patches of all bios versions into a single bios. This method worked for me.

This script relies on `bsdiff` / `bspatch` to do binary diffing and patching. On Fedora 36 (at the time of this writing), the package is `bsdiff`.

This script does the following:
- creates a directory called `$HOME/KGPE-D16/`
- downloads all the bios archives to the above directory
- extracts them, but leaves the embedded EXE file
- renames the bioses to numbers padded to two places
- incrementally patches the earlies bios with the next bios
- incrementally applies this patch to the earliest bios
- continues until the most recent bios, and produces `patched-final.rom`
