#!/bin/bash

# Prove circuit
# Use 2**15 to accomodate 8 leaves in circuit
echo "Starting Groth16 trusted setup - Phase 1"
echo "Setup Powers of Tau for $1"
snarkjs powersoftau new bn128 15 pot12_0000.ptau -v

# Use pre-determined random entropy
echo "Contributing to PoT ceremony"
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v -e="lhdsfgdfgs"

echo "Starting Groth16 trusted setup - Phase 2" 
echo "Phase 2 - prepare"
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v 
# Start a new key
echo "Phase 2 - start a new key"
snarkjs groth16 setup $1.r1cs pot12_final.ptau $1_0000.zkey 

# Contribute to phase 2 of the ceremony
# Use pre-determined random entropy
echo "Phase 2 - contribute to phase 2 of the ceremony"
snarkjs zkey contribute $1_0000.zkey $1_0001.zkey --name="1st Contributor Name" -v -e="iuhnjiasfg"

# Export verification key
echo "Phase 2 - export verification key"
snarkjs zkey export verificationkey $1_0001.zkey verification_key.json

echo "Generating proof for $1"
snarkjs groth16 prove $1_0001.zkey $1.wtns proof.json public.json

echo "Verifying proof for $1"
snarkjs groth16 verify verification_key.json public.json proof.json

echo "Generating solidity verifier for $1"
snarkjs zkey export solidityverifier $1_0001.zkey $1_verifier.sol
