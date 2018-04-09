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

/// ERC721SmartToken contract implements non-fungible tokens based on ERC721 standard that also supports ERC20 interface. 
/// The contract is subclass of ERC721, ERC20Controller and Owned contracts

/// @dev All function calls are currently implement without side effects
contract ERC721SmartToken is ERC721, ERC20Controller, Owned() {
    /// ERC721SmartToken Transfer event
    /// @param from NFT token owner address 
    /// @param fromId NFT token ID for transfer
    /// @param to token owner to recieve the value
    /// @param toId NFT token ID to recieve the value
    /// @param value transfered value
    event Transfer(address from, uint256 fromId, address to, uint256 toId, uint256 value);
    /// ERC721SmartToken AddValue event
    /// @param to token owner to recieve the value
    /// @param toId NFT token ID to recieve the value
    /// @param value transfered value
    event AddValue(address to, uint256 toId, uint256 value);
    /// ERC721SmartToken RemoveValue event
    /// @param from NFT token owner address
    /// @param fromId NFT token ID to decrease the value
    /// @param value value to decrease
    event RemoveValue(address from, uint256 fromId, uint256 value);
    /// ERC721SmartToken SetLevel event
    /// @param to NFT token owner address
    /// @param toId NFT token ID to set level
    /// @param level new token level
    event SetLevel(address to, uint256 toId, uint256 level);
    /// ERC721SmartToken IncreaseLevel event
    /// @param to NFT token owner address
    /// @param toId NFT token ID to increase level
    event IncreaseLevel(address to, uint256 toId);
    /// ERC20Controller method
    /// @dev return total supply of issued tokens
    /// @return total supply
    function cTotalSupply() public view returns (uint256) {
        uint256 balance = uint256(0);
        uint256 count = nfts.length;

        for (uint256 id = 1; id < count; id++) {
            balance = balance + nfts[id].value;
        }
        return balance;
    }
    /// ERC20Controller method
    /// @dev return balance for specific address. Note that for each address there are numner of NFT tokens.
    /// @param _owner owner address
    /// @return total balance
    function cBalanceOf(address _owner) public view returns (uint256) {
        uint256[] memory tokenIds = _tokensOfOwner(_owner);
        uint256 balance = uint256(0);
        uint256 count = tokenIds.length;

        for (uint256 i = 0; i < count; i++) {
            balance = balance + nfts[tokenIds[i]].value;
        }
        return balance;
    }
    /// ERC20Controller helper
    /// @dev transfer NFS token value from one (address, id) pair to another one 
    /// @param _from address to transfer value from
    /// @param _fromId non-fungible token ID to transfer value from, must belong to address _from
    /// @param _to address to transfer value to
    /// @param _toId non-fungible token ID to transfer value to, must belong to address _to
    /// @param _value value to transfer
    function transfer(address _from, uint256 _fromId, address _to, uint256 _toId, uint256 _value) internal {
        require(_owns(_from, _fromId));
        require(_owns(_to, _toId));
        require(_value != uint256(0));
        require(_fromId != _toId);
        require(nfts[_fromId].value >= _value);
        require(nfts[_fromId].state != StateBlocked);

        nfts[_fromId].value = nfts[_fromId].value - _value;
        nfts[_toId].value = nfts[_toId].value + _value;

        Transfer(_from, _fromId, _to, _toId, _value);
    }
    /// ERC20Controller helper
    /// @dev return default NFT token ID for specific address
    /// @param _owner owner address
    /// @return default NFT token ID
    function defaultId(address _owner) internal returns (uint256 id) {
        uint256[] memory tokenIds = _tokensOfOwner(_owner);
        uint256 count = tokenIds.length;
        if (count == uint256(0)) {
            return uint256(0);
        }
        return tokenIds[0];
    }
    /// ERC20Controller helper
    /// @dev increase NFT token value
    /// @param _to NFT token owner address
    /// @param _toId NFT token ID that
    /// @param _value value to add
    function addValue(address _to, uint256 _toId, uint256 _value) internal {
        require(_owns(_to, _toId));
        require(_value != uint256(0));
        nfts[_toId].value = nfts[_toId].value + _value;

        AddValue(_to, _toId, _value);
    }
    /// ERC20Controller helper
    /// @dev decrease NFT token value
    /// @param _from NFT token owner address
    /// @param _fromId NFT token ID that
    /// @param _value value to decrease
    function removeValue(address _from, uint256 _fromId, uint256 _value) internal {
        require(_owns(_from, _fromId));
        require(_value != uint256(0));
        require(nfts[_fromId].value >= _value);
        nfts[_fromId].value = nfts[_fromId].value - _value;

        RemoveValue(_from, _fromId, _value);
    }
    /// ERC20Controller helper
    /// @dev set level for NFT token
    /// @param _to NFT token owner address
    /// @param _toId NFT token ID that
    /// @param _level level to set
    function setLevel(address _to, uint256 _toId, uint256 _level) ownerOnly public {
        require(_owns(_to, _toId));
        nfts[_toId].level = _level;

        SetLevel(_to, _toId, _level);
    }
    /// ERC20Controller helper
    /// @dev increase level for NFT token for one 
    /// @param _to NFT token owner address
    /// @param _toId NFT token ID that
    function increaseLevel(address _to, uint256 _toId) ownerOnly public {
        require(_owns(_to, _toId));
        nfts[_toId].level = nfts[_toId].level + 1;

        IncreaseLevel(_to, _toId);
    }
    /// ERC20Controller helper
    /// @dev return current level for NFT token
    /// @param _to NFT token owner address
    /// @param _toId NFT token ID that
    /// @return NFT level
    function getLevel(address _to, uint256 _toId) public view returns (uint256) {
        require(_owns(_to, _toId));
        return nfts[_toId].level;
    }
    /// Constructor
    /// @dev calls ERC721 constructor 
    /// @param _name NFT token name
    /// @param _symbol NFT token symbol
    function ERC721SmartToken(string _name, string _symbol) ERC721(_name, _symbol) public {}
}
