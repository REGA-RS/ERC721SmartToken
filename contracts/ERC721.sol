pragma solidity ^0.4.17;

import './interfaces/IERC721.sol';

contract ERC721 is IERC721 {

    string _name; string _symbol;

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256("supportsInterface(bytes4)"));

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

    struct NFT {
        uint256 value;          // NFT value 
        string  metadata;       // ... metadata: IPFS path
        uint256 kind;           // ... type
        uint256 level;          // ... activities level
        uint256 state;          // ... state
    }

    address public owner;       // Smart contract owner 
    NFT[] nfts;                 // tokens

    // ERC721 mappings
    mapping (uint256 => address) public tokenIndexToOwner;              // NFT ID --> owner address
    mapping (address => uint256) ownershipTokenCount;                   // owner address --> NFT index
    mapping (uint256 => address) public tokenIndexToApproved;           // case ID --> new owner approved address
    mapping (address => mapping (address => uint256)) public allowance; // transfer allowance

    // ERC721 events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    event Birth(uint256 value, string  metadata, uint256 kind, address owner);

    // ERC721 Helpers
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
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

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToOwner[_tokenId] == _claimant;
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToApproved[_tokenId] == _claimant;
    }

    function _approve(uint256 _tokenId, address _approved) internal {
        tokenIndexToApproved[_tokenId] = _approved;
    }

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

    // ERC721 Public
    function name() public view returns (string) {
        return _name;
    }
    function symbol() public view returns (string) {
        return _symbol;
    }
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }
    function valueOf(uint256 _tokenId) public view returns (uint256 value) {
        return nfts[_tokenId].value;
    }
    function transfer(address _to, uint256 _tokenId) external {
        require(_to != address(0));
        require(_to != address(this));

        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
    function approve(address _to, uint256 _tokenId) external {
        require(_owns(msg.sender, _tokenId));

        _approve(_tokenId, _to);
        Approval(msg.sender, _to, _tokenId);
    }
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        _transfer(_from, _to, _tokenId);
    }
    function totalSupply() public view returns (uint) {
        uint result = nfts.length;
        if (result > 0) {
            result = result - 1;
        }
        return result;
    }
    function ownerOf(uint256 _tokenId) external view returns (address) {
        address _owner = tokenIndexToOwner[_tokenId];

        require(_owner != address(0));
        return _owner;
    }
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        return _tokensOfOwner(_owner);
    }
    
    function tokenMetadata(uint256 _tokenId) public constant returns (string infoUrl) {
        return nfts[_tokenId].metadata;
    }

    // Constructor
    function ERC721(string _n, string _s) public {
        owner = msg.sender; _name = _n; _symbol = _s;
    }
}
