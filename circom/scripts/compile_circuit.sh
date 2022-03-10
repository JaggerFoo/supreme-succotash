#!/bin/bash

# Compile a circom template
echo "Compiling circom template $1"
circom $1.circom --r1cs --wasm --sym --c
echo "Compiling circom template $1 complete"
