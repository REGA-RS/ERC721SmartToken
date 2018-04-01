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

import './ERC721.sol';
import './interfaces/IERC20.sol';
import './ERC20Controller.sol';
import './Owned.sol';

/**
@dev ERC721SmartToken contract implements non-fungible tokens based on ERC721 standard that also supports ERC20 interface.
*/ 

contract ERC721SmartToken is ERC721, ERC20Controller, Owned() {
    
    /**
    @dev ERC20Controller methods
    */

    /**
    @dev cTotalSupply return total supply of issued tokens
    */
    function cTotalSupply() public view returns (uint256) {
        uint256 balance = uint256(0);
        uint256 count = nfts.length;

        for (uint256 id = 1; id < count; id++) {
            balance = balance + nfts[id].value;
        }
        return balance;
    }

    /**    
    @dev cBalanceOf return balance for specific address
    @dev for each address there are numner of NFT tokens
    @dev belonging to this address
    @param _owner owner address
    */
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

    /**   
    @dev transfer NFS token value from one (address, id) pair to another one 
    @param _from    address to transfer value from
    @param _fromId  non-fungible token ID to transfer value from, must belong to address _from
    @param _to      address to transfer value to
    @param _toId    non-fungible token ID to transfer value to, must belong to address _to
    @param _value   value to transfer
    */
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
