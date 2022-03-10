#!/bin/bash

# Parameters:
# 1. Name of circom template, which is used for the root file name
# example "merkle" creates a file named merkle.circom with a template named "merkle"
# 2. Power of two to use to get number of leaves. Example 3, for 8 leaves

# Need to set environment variable before running: ZK_BIN=~/projects/zku-week1/circom/scripts
echo "All started"
$ZK_BIN/gen_template_and_input.sh $1 $2
$ZK_BIN/compile_circuit.sh $1
$ZK_BIN/gen_witness.sh $1
$ZK_BIN/prove_circuit.sh $1
echo "All done."