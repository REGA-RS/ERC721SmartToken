pragma solidity ^0.4.17;

import './ERC721.sol';
import './interfaces/IERC20.sol';
import './ERC20Controller.sol';
import './Owned.sol';

contract ERC721SmartToken is ERC721, ERC20Controller, Owned() {
    
    // ERC20Controller methods
    function cTotalSupply() public view returns (uint256) {
        uint256 balance = uint256(0);
        uint256 count = nfts.length;

        for (uint256 id = 1; id < count; id++) {
            balance = balance + nfts[id].value;
        }
        return balance;
    }
    function cBalanceOf(address _owner) public view returns (uint256) {
        uint256[] memory tokenIds = _tokensOfOwner(_owner);
        uint256 balance = uint256(0);
        uint256 count = tokenIds.length;

        for (uint256 i = 0; i < count; i++) {
            balance = balance + nfts[tokenIds[i]].value;
        }
        return balance;
    }

    // ERC20Controller helpers
    function transfer(address _from, uint256 _fromId, address _to, uint256 _toId, uint256 _value) internal {
        require(_owns(_from, _fromId));
        require(_owns(_to, _toId));
        require(_value != uint256(0));
        require(_fromId != _toId);
        require(nfts[_fromId].value >= _value);

        nfts[_fromId].value = nfts[_fromId].value - _value;
        nfts[_toId].value = nfts[_toId].value + _value;
    }
    function defaultId(address _owner) internal returns (uint256 id) {
        uint256[] memory tokenIds = _tokensOfOwner(_owner);
        uint256 count = tokenIds.length;
        if (count == uint256(0)) {
            return uint256(0);
        }
        return tokenIds[0];
    }
    function addValue(address _to, uint256 _toId, uint256 _value) internal {
        require(_owns(_to, _toId));
        require(_value != uint256(0));
        nfts[_toId].value = nfts[_toId].value + _value;
    }
    function removeValue(address _from, uint256 _fromId, uint256 _value) internal {
        require(_owns(_from, _fromId));
        require(_value != uint256(0));
        require(nfts[_fromId].value >= _value);
        nfts[_fromId].value = nfts[_fromId].value - _value;
    }
    function setLevel(address _to, uint256 _toId, uint256 _level) ownerOnly public {
        require(_owns(_to, _toId));
        nfts[_toId].level = _level;
    }
    function increaseLevel(address _to, uint256 _toId) ownerOnly public {
        require(_owns(_to, _toId));
        nfts[_toId].level = nfts[_toId].level + 1;
    }
    function getLevel(address _to, uint256 _toId) public view returns (uint256) {
        require(_owns(_to, _toId));
        return nfts[_toId].level;
    }
    function ERC721SmartToken(string _name, string _symbol) ERC721(_name, _symbol) public {}
}
