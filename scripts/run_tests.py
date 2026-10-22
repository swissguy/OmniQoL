#!/usr/bin/env python3
"""
OmniQoL Test Suite Runner
Discovers and executes all unit tests, schema validations, and parity checks
for OmniQoL across supported generations.
"""

import os
import sys
import time
import unittest

def run():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tests_dir = os.path.join(root_dir, "tests")

    print("=" * 70)
    print("OmniQoL (Cross-Generation) — Test Suite")
    print("=" * 70)

    loader = unittest.TestLoader()
    suite = loader.discover(start_dir=tests_dir, pattern="test_*.py")

    start_time = time.time()
    runner = unittest.TextTestRunner(verbosity=2 if "-v" in sys.argv or "--verbose" in sys.argv else 1)
    result = runner.run(suite)
    elapsed = time.time() - start_time

    print("-" * 70)
    total = result.testsRun
    failed = len(result.failures)
    errored = len(result.errors)
    skipped = len(result.skipped)
    passed = total - failed - errored - skipped

    if result.wasSuccessful():
        print(f"RESULT: ALL {total} TESTS PASSED in {elapsed:.2f}s! [PASSED]")
        print("=" * 70)
        return 0
    else:
        print(f"RESULT: {failed} FAILED, {errored} ERRORED out of {total} tests in {elapsed:.2f}s. [FAILED]")
        print("=" * 70)
        return 1

if __name__ == "__main__":
    sys.exit(run())
