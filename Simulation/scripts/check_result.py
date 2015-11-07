#!/usr/bin/env python
import sys
import filecmp
import difflib


print("INFO:\tChecking register file dump file...")

# check arguments
try:
    log = sys.argv[1]
    ref = sys.argv[2]
except IndexError:
    print("\nINFO:\tWrong number of arguments: ./check_result [log_file]"
          "[reference_log]\n")
    print("Abort.")
    sys.exit(1)

# compare the files
if not filecmp.cmp(log, ref):
    print("INFO:\tSimulation error. Register file has wrong values.")
    print("INFO:\tPrinting diff:\n")
    diff = difflib.unified_diff(open(log).readlines(),
                                open(ref).readlines(),
                                fromfile=ref,
                                tofile=log)
    print("".join(diff))
    print("INFO:\tSimulation failed.\n")
else:
    print("INFO:\tSimulation Ok.\n")
