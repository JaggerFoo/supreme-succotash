#!/bin/bash

# Parameters:
# Root file name for circom file

# Generate witness
echo "Start Generating witness for $1"
node $1_js/generate_witness.js $1_js/$1.wasm input.json $1.wtns
echo "Generating witness for $1 completed"
