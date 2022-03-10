# ZKU - Week 1 Assignment

The week 1 repository contains information and code for Q1 and Q2 of the ZKU Week 1 Assignment.

## Directory Structure

* circom
  * runscripts - This is where the auto-gen scripts were run and includes most of the arifacts from all phases:
  from circom file generation to verifying proof and creating a solidity verifier.

  * screenshots - Contains screenshots of Groth16 failure and submission of the script to run all phases for circom.

  * scripts - All of the scripts used to generate and run all circom processes:
    * runAll.sh - Submits all of the scripts in sequence
    * gen_template_and_input.sh - Generate circom file and input.json file
    * compile_circuit.sh - Compiles the generated circom file
    * gen_witness.sh - Generate witness
    * prove_circuit.sh - Phase I and II of PoT, Generate proof, Verify proof, Generate Solidity verifier

  * templates - circom files
    * mimcsponge.circom - Library file used to hash nodes in the Merkle tree
    * Merkleroot.circom - File submitted for Question 1, Item 1.

* solidity

  * zkuNFT.sol - Solidity file that contains two contracts.
    * zkuNFT - Mints and NFT and submits it to the Merkle tree contract
    * zkuMtree - Hashes NFT attributes and adds the hash to a Merkle tree.
  
  * screenshots - Directory with all screenshots to fulfill Q2 requirements.

## Intro to Circom

#### 1. Construct a circuit

Directory circom/templates
* program file: Merkleroot.circom
  * This code was used to create compile, generate a witness, and prove the circuit
* program file: mimcsponge.circom
  * This code was required to generate the hashes used to populate the merkle tree.

#### 2. Generate a proof using 8 leaves instead of 4. Document any errors and how you fixed it.

* A screenshot of the error is provided
  * file: circom/screenshots/Groth16-Failure-2022-03-07.png

* A discussion is contained in the pdf file that was submitted. But the fix was to increase the max contraints parameter from 12 to 15.

#### 3. Discussion

* This is contained in the pdf file that was submitted.



### Solidity

#### Q2 - Minting an NFT and committing the mint data to a Merkle Tree

#### Items 1 and 2

  * zkuNFT.sol - Solidity file that contains two contracts.
    * zkuNFT - Mints and NFT and submits it to the Merkle tree contract
    * zkuMtree - Hashes NFT attributes and adds the hash to a Merkle tree.

#### Item 3

Screenshots for the requirement to mint two NFTs are in the solidity/screenshots directory:

* zkuMtree-pretest.png: Shows how the zkuMtree contract looks before minting an NFT.
* Mint1-FlipFlop-zkuNFT.png: Shows owner, uri and 275572 gas used.
* Mint1-FlipFlop-zkuMtree.png: Shows the state variables of the Merkle tree after the first NFT is added to the Merkle tree.
* Mint2-Potion-zkuNFT.png: Shows owner, uri and 299154 gas used. The additional gas was used to complete the Merkle tree after the last leaf node was added.
* Mint2-Potion-zkuMtree.png: Shows the state variables of the contract after the second NFT is added to the Merkle tree.
* Final-Root-zkuMtree.png: Shows the final root hash in the zkuMtree contract.
* Mint-Full-Tree-zkuNFT.png: Shows the error message given when trying to mint an NFT when the Merkle tree is already full.


