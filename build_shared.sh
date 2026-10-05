#!/usr/bin/env bash
# Compile omqqiskit as a shared library for Python ctypes
clang -O2 -fPIC -shared omqqiskit.c -o libomqqiskit.so -lm
echo "Shared library libomqqiskit.so built successfully."
