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

import './TokenContainer.sol';
/// TokenPool is TokenContainer with 4 level pool structure: 
/// Super Pool (Level 0), Pool (Level 1), Sub Pool (Level 2) and Token (Level 3)
/// Level       Container / Member
/// ------------------------------------------------
///   0         SuperPool
///   1              |______Pool
///   2                      |______SubPool
///   3                                |_______Token
contract TokenPool is TokenContainer {
    /// @dev Pool defines pool structure
    /// @param level Pool level: 0,1,2,3
    /// @param maxNumber Maximum number of pools on this lavel
    /// @param maxMember Maximum number of members for the pool
    /// @param number Pool number for this level
    /// @param last NFT ID for last availible pool (with member capacity)
    struct Pool {
        uint8   level;      // Pool level: 0,1,2,3
        uint256 maxNumber;  // Maximum number of pools on this lavel
        uint256 maxMember;  // Maximum number of members for the pool
        uint256 number;     // Pool number for this level
        uint256 last;       // NFT ID for last availible pool (with member capacity)
        uint256 share;      // Pool share from token investment
    }
    /// @dev Pool structure 
    Pool[] pools;           // Pool structure
    function TokenPool(string _name, string _symbol) TokenContainer(_name, _symbol) public { 
        maxLevel = 4;
        // SuperPool configuration
        Pool memory superPool = Pool({
            level: uint8(0),
            maxNumber: uint256(1),
            maxMember: uint256(10),
            number: uint256(0),
            last: uint256(0),
            share: uint256(10)
        });
        pools.push(superPool);
        // Pool configuration 
        Pool memory pool = Pool({
            level: uint8(1),
            maxNumber: uint256(10),
            maxMember: uint256(100),
            number: uint256(0),
            last: uint256(0),
            share: uint256(20)
        });
        pools.push(pool);
        // SubPool configuration 
        Pool memory subPool = Pool({
            level: uint8(2),
            maxNumber: uint256(1000),
            maxMember: uint256(100),
            number: uint256(0),
            last: uint256(0),
            share: uint256(50)
        });
        pools.push(subPool);
    }
}