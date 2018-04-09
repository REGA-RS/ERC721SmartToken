// 
// MIT License
// 
// Copyright (c) 2018 REGA Risk Sharing
//   
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 
// Author: Sergei Sevriugin
// Version: 0.0.1
//

pragma solidity ^0.4.17;

import './interfaces/IERC721.sol';

/// ERC721 non-fungible token
contract ERC721 is IERC721 {
    /// @dev token name and symbol
    string _name; 
    /// @dev token symbol
    string _symbol;
    /// @dev stateBlocked
    uint256 constant StateBlocked = uint256(1024);
    /// @dev interface signature ERC165
    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256("supportsInterface(bytes4)"));
    /// @dev interface signature ERC721
    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256("name()")) ^
        bytes4(keccak256("symbol()")) ^
        bytes4(keccak256("totalSupply()")) ^
        bytes4(keccak256("balanceOf(address)")) ^
        bytes4(keccak256("ownerOf(uint256)")) ^
        bytes4(keccak256("approve(address,uint256)")) ^
        bytes4(keccak256("transfer(address,uint256)")) ^
        bytes4(keccak256("transferFrom(address,address,uint256)")) ^
        bytes4(keccak256("tokensOfOwner(address)")) ^
        bytes4(keccak256("tokenMetadata(uint256,string)"));
    /// @dev NFT token data : value, metadata, kind, level and state
    /// @param value ERC20 token value
    /// @param metadata NFT metadata
    /// @param kind NFT token type / kind
    /// @param level NFT token level
    /// @param state token state
    struct NFT {
        uint256 value;          // NFT value 
        string  metadata;       // ... metadata: IPFS path
        uint256 kind;           // ... type
        uint256 level;          // ... activities level
        uint256 state;          // ... state
    }
    /// @dev contract owner
    address public owner;       // Smart contract owner
    /// @dev NFT token array
    NFT[] nfts;                 // tokens
    /// owner address
    mapping (uint256 => address) public tokenIndexToOwner;              // NFT ID --> owner address
    /// NFT token owner
    mapping (address => uint256) ownershipTokenCount;                   // owner address --> NFT index
    /// new owner address
    mapping (uint256 => address) public tokenIndexToApproved;           // case ID --> new owner approved address
    /// allowance amount
    mapping (address => mapping (address => uint256)) public allowance; // transfer allowance
    /// ERC721 events
    /// @dev transfer event
    /// @param from address transfer from
    /// @param to address transfer to
    /// @param tokenId NFT token ID to transfer
    event Transfer(address from, address to, uint256 tokenId);
    /// ERC721 events
    /// @dev approval event
    /// @param owner NFT token owner address
    /// @param approved address to approve
    /// @param tokenId NFT token ID to approve
    event Approval(address owner, address approved, uint256 tokenId);
    /// ERC721 events
    /// @dev birth event
    /// @param value NFT token value
    /// @param metadata NFT token metadata
    /// @param kind NFT token kind
    /// @param owner NFT token owner
    event Birth(uint256 value, string  metadata, uint256 kind, address owner);
    /// ERC721 Helpers
    /// @dev transfer NFT token from one address to another
    /// @param _from address to transfer from
    /// @param _to address to transfer to
    /// @param _tokenId NFT token ID to transfer
    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        assert(nfts[_tokenId].state != StateBlocked);
        
        ownershipTokenCount[_to]++;
        tokenIndexToOwner[_tokenId] = _to;

        // _from == 0 for new NFT there is not any current owner
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            
            delete tokenIndexToApproved[_tokenId];
        }
        // Fire event
        Transfer(_from, _to, _tokenId);
    }
    /// ERC721 Helpers
    /// @dev create new NFT token
    /// @param _value NFT token value
    /// @param _metadata NFT token metadata
    /// @param _kind NFT token kind
    /// @param _owner NFT token owner
    function _createNFT(uint256 _value, string  _metadata, uint256 _kind, address _owner) internal returns (uint) {   
        // allocate new NFT
        NFT memory _nft = NFT({
            value: _value,
            metadata: _metadata,
            kind: _kind,
            level: uint256(0),
            state: uint256(0)
        });
        // save new NFT in array and get token Id
        uint256 newId = nfts.push(_nft) - 1; // push returns new array length, so caseId starts from 0
        if (newId == uint32(0)) {
            // we need to reserve index 0 as null, so let's push another copy and make it 1
            newId = nfts.push(_nft) - 1;
        }
        require(newId == uint256(uint32(newId)));
        // emit the birth event
        Birth(_value, _metadata, _kind, _owner);
        // transfer to the Owner
        _transfer(0, _owner, newId);
        // return new token Id > 0
        return newId;
    }
    /// @dev if address is owner for the specific NFT token
    /// @param _claimant address to check
    /// @param _tokenId NFT token ID to check
    /// @return TRUE is _claimant is _tokenId owner
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToOwner[_tokenId] == _claimant;
    }
    /// @dev check if NFT token is approved to specific address
    /// @param _claimant address to check
    /// @param _tokenId NFT address to check
    /// @return TRUE is _claimant is approved for _tokenId
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToApproved[_tokenId] == _claimant;
    }
    /// @dev approve address to the specific token
    /// @param _tokenId NFT token ID to approve
    /// @param _approved address to approve
    function _approve(uint256 _tokenId, address _approved) internal {
        tokenIndexToApproved[_tokenId] = _approved;
    }
    /// @dev NFT tokens for specific address
    /// @param _owner owner address
    /// @return array of NFT tokens belonging to the _owner
    function _tokensOfOwner(address _owner) view internal returns(uint256[] ownerTokens) {
        require(_owner != address(0));
        uint256 tokenCount = balanceOf(_owner);
        
        if (tokenCount == 0) {
            return new uint256[](0);    // Return an empty array
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalCases = totalSupply(); // totalSupply is cases.lenght -1, 0 index is reserved
            uint256 resultIndex = 0;

            for (uint256 id = 1; id <= totalCases; id++) {
                if (tokenIndexToOwner[id] == _owner) {
                    result[resultIndex++] = id;
                }
            }
            return result;
        }
    }
    /// ERC721 Public
    /// @dev return token name
    /// @return token name
    function name() public view returns (string) {
        return _name;
    }
    /// ERC721 Public
    /// @dev return token symbol
    /// @return token symbol
    function symbol() public view returns (string) {
        return _symbol;
    }
    /// ERC721 Public
    /// @dev Check if interface is supported by smart contract
    /// @param _interfaceID interface signature to check
    /// @return TRUE is _interfaceID is supported 
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }
    /// ERC721 Public
    /// @dev Get number of NFT tokens for given owner address
    /// @param _owner owner address 
    /// @return number of NFT for _owner
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }
    /// ERC721 Public
    /// @dev Get value of NFT token 
    /// @param _tokenId NFT token ID
    /// @return value for _tokenId
    function valueOf(uint256 _tokenId) public view returns (uint256 value) {
        return nfts[_tokenId].value;
    }
    /// ERC721 Public
    /// @dev transfer NFT token to new owner
    /// @param _to new owner address
    /// @param _tokenId NFT token ID to transfer
    function transfer(address _to, uint256 _tokenId) external {
        require(_to != address(0));
        require(_to != address(this));

        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
    /// ERC721 Public
    /// @dev approve transfer of NFT token to a new owner
    /// @param _to new owner address to be approved 
    /// @param _tokenId NFT token ID to be approved
    function approve(address _to, uint256 _tokenId) external {
        require(_owns(msg.sender, _tokenId));

        _approve(_tokenId, _to);
        Approval(msg.sender, _to, _tokenId);
    }
    /// ERC721 Public
    /// @dev transfer token from current owner to new one. The transfer must be approved before
    /// @param _from curren owner address 
    /// @param _to new owner address to transfer
    /// @param _tokenId NFT token ID to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        _transfer(_from, _to, _tokenId);
    }
    /// ERC721 Public
    /// @dev Get total supply for NFT token 
    /// @return number of NFT issued
    function totalSupply() public view returns (uint) {
        uint result = nfts.length;
        if (result > 0) {
            result = result - 1;
        }
        return result;
    }
    /// ERC721 Public
    /// @dev Get current NFT token owner address 
    /// @param _tokenId NFT token ID to get owner
    /// @return address _tokenId owner 
    function ownerOf(uint256 _tokenId) external view returns (address) {
        address _owner = tokenIndexToOwner[_tokenId];

        require(_owner != address(0));
        return _owner;
    }
    /// ERC721 Public
    /// @dev Get all NFT tokens for owner address 
    /// @param _owner NFT owner address
    /// @return array of NFT token IDs
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        return _tokensOfOwner(_owner);
    }
    /// ERC721 Public
    /// @dev Get  NFT token metadate
    /// @param _tokenId NFT ID to get metadata
    /// @return metadata for _tokenId
    function tokenMetadata(uint256 _tokenId) public constant returns (string infoUrl) {
        return nfts[_tokenId].metadata;
    }
    /// ERC721 Public
    /// @dev Constructor
    /// @param _n NFT token name
    /// @param _s NFT token symbol
    function ERC721(string _n, string _s) public {
        owner = msg.sender; _name = _n; _symbol = _s;
    }
}
