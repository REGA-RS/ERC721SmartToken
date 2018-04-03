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

import './ERC721SmartToken.sol';

/// TokenContainer is ERC721SmartToken that provide hierarchical structure for token pools
contract TokenContainer is ERC721SmartToken {
    /// TokenContainer AddToken event
    /// @param nodeId NFT token ID to be added
    /// @param parentId NFT token ID for pool token
    /// @param level new nodeId level
    event AddToken(uint256 nodeId, uint256 parentId, uint256 level);
    /// TokenContainer RemoveToken event
    /// @param nodeId NFT token ID to be removed
    /// @param level removed token level
    event RemoveToken(uint256 nodeId, uint256 level);
    /// max number of levels in  hierarchical structure
    uint256 public maxLevel;
    /// from NFT ID to NFT ID of pool token
    mapping (uint256 => uint256) public tokenIndexToPoolToken;
    
    function addToken(uint256 _nodeId, uint256 _parentId) public {
        require(_nodeId != uint256(0) && _nodeId < nfts.length);
        require(_parentId != uint256(0) && _parentId < nfts.length);
        require(nfts[_parentId].level < (maxLevel - 1));

        tokenIndexToPoolToken[_nodeId] = _parentId;
        nfts[_nodeId].level = nfts[_parentId].level + 1;

        AddToken(_nodeId, _parentId, nfts[_nodeId].level);
    }
    function removeToken(uint256 _nodeId) public {
        require(_nodeId != uint256(0) && _nodeId < nfts.length);
        uint256 poolSize = _getPoolSize(_nodeId);
        require(poolSize == uint256(0));

        delete tokenIndexToPoolToken[_nodeId];

        RemoveToken(_nodeId, nfts[_nodeId].level);
    }
    function getPath(uint256 _nodeId) external view returns(uint256[] path) {
        uint256 parentId;
        parentId = tokenIndexToPoolToken[_nodeId];

        for (uint256 id = 0; id < maxLevel; id++) {
            path[id] = parentId;
            parentId = tokenIndexToPoolToken[parentId];
        }
    }
    function _getPoolSize(uint256 _nodeId) view internal returns(uint256 size) {
        require(_nodeId != uint256(0) && _nodeId < nfts.length);

        uint256 total = totalSupply(); // totalSupply is cases.lenght -1, 0 index is reserved
        
        size = 0;

        for (uint256 id = 1; id <= total; id++) {
            if (tokenIndexToPoolToken[id] == _nodeId) {
                size++;
            }
        }
    }
    function _getPool(uint256 _nodeId) view internal returns(uint256[] pool) {
        require(_nodeId != uint256(0) && _nodeId < nfts.length);

        uint256 poolSize = _getPoolSize(_nodeId);
        uint256[] memory result = new uint256[](poolSize);
        uint256 total = totalSupply(); // totalSupply is cases.lenght -1, 0 index is reserved
        uint256 resultIndex = 0;

        for (uint256 id = 1; id <= total; id++) {
            if (tokenIndexToPoolToken[id] == _nodeId) {
                result[resultIndex++] = id;
            }
        }
        return result;
    }
    function TokenContainer(string _name, string _symbol) ERC721SmartToken(_name, _symbol) public { maxLevel = 4; }
}