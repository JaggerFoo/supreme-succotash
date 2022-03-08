// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract zkuNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    bytes32 public tmpHash;
    address public mtreeContract;

    Counters.Counter private _tokenIds;

    ////////////////////////////////////////////////////////////////////
    // Initial NFT contract and set initial merkle tree contract address
    ////////////////////////////////////////////////////////////////////
    constructor(address _mtreeContract) ERC721("zkuNFT", "ZKU") {
        mtreeContract = _mtreeContract;
    }

    function createItem(address nft_owner, string memory tokenURI)
        private
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(nft_owner, newItemId);
        _setTokenURI(newItemId, tokenURI); // ERC721URIStorage.sol

        return newItemId;
    }

    function hashNFT(address hasher, address _sender, address _nft_owner, uint256 _tokenId) public  {
      string memory turi = tokenURI(_tokenId);
      tmpHash = zkuMtree(hasher).hashNFT(_sender, _nft_owner, _tokenId, turi);
    }

    function buildNFT(address token_owner, string memory name, string memory description)
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

      hashNFT(mtreeContract, msg.sender, token_owner, nftId);

    }

}

/***
Contract to build a Merkle tree for NFTs incrementally.

Need to decide on deployment the size of the Merkle tree

***/
contract zkuMtree  {

  uint256 public exp_of_2;
  uint256 public leaves;
  uint256 public levels;
  uint256 public nodes;

  bytes32 public nftHash;

  uint256 public current_index = 0;
  uint256 public current_level = 0;

  mapping(uint256 => bytes32) public mtree;

  ////////////////////////////////////////////////////////
  // Need a contructor to set the size of the Merkle tree
  // by passing an exponent of 2, to determine attributes
  // example:
  //   exp = 3
  //   #leaves = 2**3 = 8
  //   #levels = exp + 1 = 4
  //   #nodes in tree = 2**(n+1) - 1 = 15
  //   note: #nodes includes leaf nodes
  ////////////////////////////////////////////////////////
  constructor(uint256 exp) {
    exp_of_2 = exp;
    leaves   = 2**exp;
    levels   = exp + 1;
    nodes    = (2**(exp + 1) - 1);
  }

  ///////////////////////////////////////////////////////////
  // Hash NFT attributes to create a leaf for the Merkle tree
  ///////////////////////////////////////////////////////////
  function hashNFT
  (address _sender
  ,address _owner
  ,uint256 _tokenId
  ,string  memory _tokenURI)
  public pure returns (bytes32)
  {
    return keccak256(abi.encodePacked(_sender, _owner, _tokenId, _tokenURI));
  }

//   // Funciton to add an NFT to a Merkle tree
//   function buildLeaf
//   (address memory sender
//   ,address memory owner
//   ,uint256 memory tokenId
//   ,string  memory tokeURI) 
//   {

//   }



}
