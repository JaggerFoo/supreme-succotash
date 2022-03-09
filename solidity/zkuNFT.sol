// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/***
  Description: 
    zkuNFT is a contract to create an NFT contract with URI denoting Name and Description only.

    ERC721 Name: zkuNFT, Symbol: ZKU

    After creation of an NFT with zkuNFT, the following 4 attributes will be hashed and stored
    as a leaf in a Merkle tree contract (zkuMtree): msg.sender, receiver address, token ID, and token URI

  Note: 
    The zkuNFT contract must be deployed after the Merkle tree contract zkuMtree has been deployed,
    since the address of contract zkuMtree is a parameter of this contracts' constructor.

  Nice to Have: 
    It would be helpful to add a function to update the Merkle tree contract
    address. But given the life expectancy of this work, it can be ignored.

***/ 
contract zkuNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    address public mtreeContract;       // The address of Merkle tree contract zkuMtree
    uint256 public mtreeIdx;            // Holds the last leaf level node index on the Merkle tree

    Counters.Counter private _tokenIds; // Standard sequencer for Token ID

    // Initialize NFT contract and set Merkle tree contract address
    constructor(address _mtreeContract) ERC721("zkuNFT", "ZKU") {
        mtreeContract = _mtreeContract;
    }

    ////////////////////////////////////////////////////////////
    // Open Zeppelin standard function:
    //   * A new token is minted
    //   * Token ID and address of owner are stored in a mapping
    //   * URI of token is stored in a mapping
    ////////////////////////////////////////////////////////////

    function createItem(address nft_owner, string memory tokenURI)
        private
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(nft_owner, newItemId);       
        _setTokenURI(newItemId, tokenURI); 

        return newItemId;
    }

    /////////////////////////////////////////////////////////////////////////
    // This function calls the Merkle tree contract to add a leaf node.
    // The number of leaf nodes allowed is dependent on how contract zkuMtree
    // was deployed, since the size of the Merkle tree is set at deployment.
    //
    // Calls to this function after the leaf level nodes are full will fail.
    /////////////////////////////////////////////////////////////////////////
    function addLeafNode(address _mtree, address _sender, address _nft_owner, uint256 _tokenId) public  {
      string memory turi = tokenURI(_tokenId);
      mtreeIdx = zkuMtree(_mtree).addLeafNode(_sender, _nft_owner, _tokenId, turi);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // mintNFT collects receiver address, name, and description of the token
    // and mints a new NFT.
    //
    // The name and description are separate from the token Name and Symbol that
    // were set at deployment of zkuNFT. These attributes indicate the uniqueness
    // of the NFT given to the owner, like name:"Potion", description: "Health +100"
    //
    // Contract Calls:
    //   * zkuMtree.addLeafNode is called to add the new NFT to a Merkle tree
    //     in contract zkuMtree. If the leaf level is full, then the call will
    //     fail and the NFT will not be minted.
    ////////////////////////////////////////////////////////////////////////////////
    function mintNFT(address token_owner, string memory name, string memory description)
        public
    {
      // Build a URI that is a json object wirh name and description of NFT
      bytes memory dataURI = abi.encodePacked('{','"name": "', name, '", "description": "', description,'"', '}');
      uint256 nftId;
      string memory nftURI;
    
      nftURI = string(
                 abi.encodePacked(
                   "data:application/json;base64,",
                   Base64.encode(dataURI)
                 )
               );

      nftId = createItem(token_owner, nftURI);

      addLeafNode(mtreeContract, msg.sender, token_owner, nftId);

    }

}

/***
  Description:
    zkuMtree is a contract to build a Merkle tree of NFTs incrementally.
    Since there may be intermittant calls to this contract leaf nodes
    will be added one at a time.
  
  Deployment:
    Upon deployment a parameter "exp" must be provided that is the exponent
    of 2 to be used to calculate the Merkle tree size and attributes. Details
    are available in the contructor comments.

    This contract has been deployed and tested only with the exp parameters 1, 2, and 3.

  Logic:

    * leaf nodes are added on-by-one and added to a mapping that represent the Merkle tree.
    * After the last leaf node has been added, the rest of the Merkle tree is filled
      ending with the root node.

***/
contract zkuMtree  {

//  uint256 public exp_of_2;
  uint256 public leaves;
  // uint256 public levels;
  uint256 public nodes;

  bytes32 public nftHash;
  // bytes32 public noHash = 0x0000000000000000000000000000000000000000000000000000000000000000;

  uint256 public current_index = 0;
  // uint256 public current_level = 0;
  uint256 public addedCount    = 0;

  mapping(uint256 => bytes32) public mtree;

  ////////////////////////////////////////////////////////
  // Need a contructor to set the size of the Merkle tree
  // by passing an exponent of 2 to determine attributes
  // example:
  //   exp = 3
  //   #leaves = 2**3 = 8
  //   #levels = exp + 1 = 4
  //   #nodes in tree = 2**(n+1) - 1 = 15
  //   note: #nodes includes leaf nodes and root node
  ////////////////////////////////////////////////////////
  constructor(uint256 exp) {
    // exp_of_2 = exp;
    leaves   = 2**exp;             // number of leaf nodes in tree
    // levels   = exp + 1;
    nodes    = (2**(exp + 1) - 1); // total number of nodes in tree
  }

  ///////////////////////////////////////////////////////////
  // Hash NFT attributes to create a leaf for the Merkle tree
  ///////////////////////////////////////////////////////////
  function hashNFT
    (
     address        _sender
    ,address        _owner
    ,uint256        _tokenId
    ,string  memory _tokenURI
    )
  public pure returns (bytes32)
  {
    return keccak256(abi.encodePacked(_sender, _owner, _tokenId, _tokenURI));
  }

  ////////////////////////////////////////////
  // Incrementally add leaf to the Merkle tree
  // and return its index
  ////////////////////////////////////////////
  function addLeafNode
  (address        _sender
  ,address        _owner
  ,uint256        _tokenId
  ,string  memory _tokenURI)
  public returns (uint256)
  {
    // Check if the Merkle tree is full
    require(current_index < (leaves-1), "Sorry the leaf level is full");

    // First time do not increment current_index, so the tree starts with index 0
    // afterward the current index is incremented as each NFT is added to the tree
    if (addedCount > 0) {
      current_index = current_index + 1; // get the next leaf node index value
    }

    // Get the hash of the NFT leaf
    nftHash = hashNFT(_sender, _owner, _tokenId, _tokenURI);

    // Store the hash in the Merkle tree map, increment addedCount
    mtree[current_index] = nftHash;
    addedCount = addedCount+1;

    // Check if the leaf level is full, if so complete the Merkle tree
    if (addedCount == leaves) {
        // Complete the Merkle tree
        fillMtree();
    }

    return current_index;  // This returns the index of the last leaf-level node
  }

  /////////////////////////////////////////////////////////
  // Function to fill the Merkle tree to the root node
  // after all leaf nodes have been collected.
  /////////////////////////////////////////////////////////
  function fillMtree() private {
        uint256 leftIdx;
        uint256 emptyNodes = nodes - leaves;

        for (uint256 i=0; i < emptyNodes; i++) {
            current_index = current_index + 1;
            leftIdx = current_index - (leaves - i);
            mtree[current_index] = keccak256(abi.encodePacked(mtree[leftIdx], mtree[leftIdx+1]));
        }

  }
}
