pragma circom 2.0.3;

// Include copy of circom library mimcsponge.circom

include "mimcsponge.circom";

// Borrowed template from Tornado Cash
template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = MiMCSponge(2, 220, 1);
    hasher.ins[0] <== left;
    hasher.ins[1] <== right;
    hasher.k <== 0;
    hash <== hasher.outs[0];
}



// Merkleroot: Given an array of size 2**y, where y is a reasonably small integer (2 or 3)
// calculate the merkle root of the array
template Merkleroot(exp) {

  signal input levels;
  signal input leaves[2**exp];
  signal output root;

  // This is the merkle tree storage array
  // Sized to fit parents of leaves and  root
  var n_items = 2**exp;    // the number of leaves given exponent of 2
  var len     = n_items-1; // Storage required for merkle tree hashes (not including leaves)
  var lvls    = levels-1;  // # of Levels above leaves

  component mtree[n_items-1]; // Store MiMC Sponge objects


    var strt   = 0; // start index for storing hashes in array
    var offset = 0; // add on to strt for storing level hashes
    var itms   = 0; // number of nodes in a level
    var i      = 0; // simple index variable
    var idx    = 0; // index variable used to source hash array

    // Process parent levels of the merkle chain
    for (var n = 0; n < exp; n++) {

      strt = strt + offset;      // set the starting index of hash array
      offset = 0;                // recalculate offset each level
      itms = n_items/(2**(n+1)); // Get the number of items in this level
      
      // Hash the leaves into the hash array
      if (n == 0) {
 
        for (var q = 0; q < itms; q++) {
          i = q + strt;
          offset++;
          mtree[i] = HashLeftRight();
          mtree[i].left  <== leaves[2*q];
          mtree[i].right <== leaves[2*q+1];
        }


      } 
      // Hash from the hash array to get parent hashes in the hash array
      else {
        for (var q = 0; q < itms; q++) {
          i = q + strt;
          idx = (i - 4) < 0? 0 : ((i - 4) * 2); // Calculate hash pair index
          offset++;
          mtree[i]         = HashLeftRight();
          mtree[i].left  <== mtree[idx].hash;
          mtree[i].right <== mtree[idx+1].hash;
        }

      }

    }


  root <== mtree[i].hash; // final i points to points to root hash

}

component main{public [levels, leaves]} = Merkleroot(3); // 2**2 = 4 leaves
