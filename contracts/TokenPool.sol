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
    /// TokenPool insertPool event
    /// @param id inserted token ID
    /// @param poolId pool ID
    /// @param level pool level
    event InsertPool(uint256 id, uint256 poolId, uint8 level);
    /// TokenPool value distribution event
    /// @param id NFT token ID for value distribution 
    /// @param superPoolValue SuperPool Share
    /// @param poolValue Pool Share
    /// @param subPoolValue SubPool Share
    /// @param comission Comission = the rest after all pools 
    event DistributeValue(uint256 id, uint256 superPoolValue, uint256 poolValue, uint256 subPoolValue, uint256 comission);
    /// TokenPool Second Tier Call event
    /// @param id NFT token ID that emits event
    /// @param value 2nd tier capital call value
    event SecondTierCall(uint256 id, uint256 value);
    /// TokenPool ShortOfFunds event
    /// @param id NFT token ID that emits event
    /// @param poolId pool ID that can't pay
    /// @param value that pool can't pay
    /// @param level pool level that can't 
    event ShortOfFunds(uint256 id, uint256 poolId, uint256 value, uint8 level);
    /// TokenPool Payment Value event
    /// @param id NFT token ID that emits event
    /// @param value paid value
    /// @param level pool level that paid
    event PaymentValue(uint256 id, uint256 value, uint8 level);
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
    /// inset new member in the pool
    /// @param _id NFT token ID to inserr
    /// @param _level Pool level to insert
    /// @return TRUE if insert is done 
    function _getParent(uint256 _id, uint8 _level) internal view returns (uint256 parentId) {
        // by default returns pools[_level].last but must be overloaded to use score to calculate right pool
        _id;
        parentId = pools[_level].last;
    }
    function _getCapacity(uint256 _id, uint8 _level) internal view returns (uint256 parentId) {
        // by default returns pools[_level].maxMember - 1; but can be overloaded to use score to calculate right pool capacity
        _id;
        parentId = pools[_level].maxMember - 1;
    }
    function _insertPool(uint256 _id, uint8 _level) internal returns (bool) {
        uint256 parentId = _getParent(_id, _level); // pool NFT token ID
        uint256 size = _getPoolSize(parentId);      // current pool size
        uint256 max = _getCapacity(_id, _level);    // max pool size - 1
        // check if there is a place to insert 
        if (size < max) {
            // simple insert
            addToken(_id, parentId); // add to pool 
            InsertPool(_id, parentId, _level); // event 
            return true;
        }
        else {
            // no capacity in the current pool, so, need to add new pool
            // check if it's possible
            if(pools[_level].number == pools[_level].maxNumber) {
                // no capacity to add new pool at this lavel
                return false;
            }
            else {
                // make a copy from the last pool
                uint newPool = _createNFT(uint256(0), nfts[parentId].metadata, nfts[parentId].kind, owner);
                if (newPool != uint(0)) { 
                    // insert pool in the pool structure
                    if (_insertPool(newPool, _level-1)) {
                        // insert token to the new pool
                        addToken(_id, newPool); // add to pool
                        InsertPool(_id, newPool, _level); // event 
                        // record new pool data in the structure 
                        pools[_level].last = newPool; // new pool is last one
                        pools[_level].number++;
                        // new pool and member are inserted 
                        return true;
                    }
                    else {
                        return false;
                    }
                }
                else {
                    return false;
                }
            }
        }
    }
    /// distribute value of the token _id to pools
    /// @dev make it as simmple as possible for fixed pool staructure
    /// @param _id NFT token ID to distribute value
    /// @return TRUE if distribution is complited 
    function _distributeValue(uint256 _id) internal returns (bool) {
        // need to make sure that _id is terminal node in the structure 
        require(_id != uint256(0) && _id < nfts.length);
        require(nfts[_id].level == maxLevel - 1);
        // now we can check then the path has all pools
        uint256 subPoolId = tokenIndexToPoolToken[_id];
        require(subPoolId != uint256(0)); // SubPool
        uint256 poolId = tokenIndexToPoolToken[subPoolId];
        require(poolId != uint256(0)); // Pool
        uint256 superPoolId = tokenIndexToPoolToken[poolId];
        require(superPoolId != uint256(0)); // SuperPool
        // calculate values to distribute based of pool structure shares
        uint256 subPoolValue = nfts[_id].value * pools[2].share / 100;
        require(subPoolValue != uint256(0));
        uint256 poolValue = nfts[_id].value * pools[1].share / 100;
        require(poolValue != uint256(0));
        uint256 superPoolValue = nfts[_id].value * pools[0].share / 100;
        require(superPoolValue != uint256(0));
        uint256 commission = nfts[_id].value - subPoolValue - poolValue - superPoolValue;
        require(commission != uint256(0));
        // ready to distribute
        nfts[subPoolId].value = nfts[subPoolId].value + subPoolValue;
        nfts[poolId].value = nfts[poolId].value + poolValue;
        nfts[superPoolId].value = nfts[superPoolId].value + superPoolValue;
        // we will keep comission in the reserved token with ID = 0
        nfts[0].value = nfts[0].value + commission;
        // the distribution is done 0 --> _id value
        nfts[_id].value = uint256(0);
        DistributeValue(_id, superPoolValue, poolValue, subPoolValue, commission);
        return true;
    }
    /// insert token in pool structure
    /// @param _id NFT token ID to insert
    /// @return TRUE if insert is done 
    function insertPool(uint256 _id) ownerOnly public returns(bool) {
        require(_id != uint256(0) && _id < nfts.length);
        // call internal function
        assert(_insertPool(_id, 2));
        // if inserted then make value distribution 
        assert(_distributeValue(_id));
        return true;
    }
    /// insert token in pool structure
    /// @param _id NFT token ID to insert
    /// @return TRUE if insert is done 
    function _addTokenToSubPool(uint256 _id) internal returns(bool) {
        require(_id != uint256(0) && _id < nfts.length);
        // call internal function
        assert(_insertPool(_id, 2));
        // if inserted then make value distribution 
        assert(_distributeValue(_id));
        return true;
    }
    /// get collected comission
    /// @return commission commission value
    function getComission() public view returns(uint256 commission) {
        commission = nfts[0].value;
    }
    /// get value distribution except commission 
    /// @return distribution [0] = SuperPool, [1] = Pool, [2] = SubPool and [3] = Tokens (must be 0)
    function getDistribution() public view returns(uint256[4] distribution)
    {
        uint8 _level;
        distribution[0] = uint256(0);   // Super Pool Value
        distribution[1] = uint256(0);   // Pool Value
        distribution[2] = uint256(0);   // SubPool Value
        distribution[3] = uint256(0);   // Tokens Value (must be 0)

        for (uint256 id = 1; id < nfts.length; id++) {
            _level = uint8(nfts[id].level);
            if(_level < maxLevel) {
                distribution[_level] = distribution[_level] + nfts[id].value;
            }
            else {
                distribution[3] = distribution[3] + nfts[id].value; // if something wrong w/ level add to tokens
            }
        }
    }
    function _payValue(uint256 _id, uint256 _value) internal returns(uint256[4] distribution) {
        require(_id != uint256(0) && _id < nfts.length);
        require(_value != uint256(0));
        distribution[0] = uint256(0);   // Super Pool Value
        distribution[1] = uint256(0);   // Pool Value
        distribution[2] = uint256(0);   // SubPool Value
        distribution[3] = uint256(0);   // Tokens Value (must be 0)
        // now we can check then the path has all pools
        uint256 subPoolId = tokenIndexToPoolToken[_id];
        require(subPoolId != uint256(0)); // SubPool
        uint256 poolId = tokenIndexToPoolToken[subPoolId];
        require(poolId != uint256(0)); // Pool
        uint256 superPoolId = tokenIndexToPoolToken[poolId];
        require(superPoolId != uint256(0)); // SuperPool
        if(_value <= nfts[subPoolId].value) {
            distribution[2] = _value;
            nfts[subPoolId].value = nfts[subPoolId].value - distribution[2];

            PaymentValue(_id, _value, uint8(2));
        }
        else if (_value <= nfts[poolId].value + nfts[subPoolId].value) {
            ShortOfFunds(_id, subPoolId, _value, uint8(2));

            distribution[2] = nfts[subPoolId].value;
            distribution[1] = _value - nfts[subPoolId].value;
            nfts[subPoolId].value = nfts[subPoolId].value - distribution[2];
            nfts[poolId].value = nfts[poolId].value - distribution[1];

            PaymentValue(_id, _value, uint8(1));
        }
        else if (_value <= nfts[superPoolId].value + nfts[poolId].value + nfts[subPoolId].value) {
            ShortOfFunds(_id, poolId, _value, uint8(1));

            distribution[2] = nfts[subPoolId].value;
            distribution[1] = nfts[poolId].value;
            distribution[0] = _value - nfts[subPoolId].value - nfts[poolId].value;
            nfts[subPoolId].value = nfts[subPoolId].value - distribution[2];
            nfts[poolId].value = nfts[poolId].value - distribution[1];
            nfts[superPoolId].value = nfts[superPoolId].value - distribution[0];

            PaymentValue(_id, _value, uint8(0));
        }
        else {
            ShortOfFunds(_id, superPoolId, _value, uint8(0));
            SecondTierCall(_id, _value);
        }
    }
    function _checkPayment(uint256 _id, uint256 _value) internal view returns(bool possible) {
        possible = false;
        uint256 subPoolId = tokenIndexToPoolToken[_id];
        require(subPoolId != uint256(0)); // SubPool
        uint256 poolId = tokenIndexToPoolToken[subPoolId];
        require(poolId != uint256(0)); // Pool
        uint256 superPoolId = tokenIndexToPoolToken[poolId];
        require(superPoolId != uint256(0)); // SuperPool
        if(_value <= nfts[subPoolId].value) {
            possible = true;
        }
        else if (_value <= nfts[poolId].value + nfts[subPoolId].value) {
            possible = true;
        }
        else if (_value <= nfts[superPoolId].value + nfts[poolId].value + nfts[subPoolId].value) {
            possible = true;
        }
    }

    function checkPaymentAmount(uint256 _id, uint256 _value) public view returns(uint8 level, uint256 amtSubPool, uint256 amtPool, uint256 amtSuperPool, uint256 balance) {
        level = uint8(4);
        uint256[4] memory distribution;
        distribution[0] = uint256(0);   // Super Pool Value
        distribution[1] = uint256(0);   // Pool Value
        distribution[2] = uint256(0);   // SubPool Value
        distribution[3] = uint256(0);   // Tokens Value (must be 0)
        
        require(_id != uint256(0) && _id < nfts.length);
        require(_value != uint256(0));
        require(_owns(msg.sender, _id));
        
        uint256 subPoolId = tokenIndexToPoolToken[_id];
        require(subPoolId != uint256(0)); // SubPool
        uint256 poolId = tokenIndexToPoolToken[subPoolId];
        require(poolId != uint256(0)); // Pool
        uint256 superPoolId = tokenIndexToPoolToken[poolId];
        require(superPoolId != uint256(0)); // SuperPool

        level = uint8(3);

        if(_value <= nfts[subPoolId].value) {
            level = uint8(2);
            distribution[2] = _value;
        }
        else if (_value <= nfts[poolId].value + nfts[subPoolId].value) {
            level = uint8(1);
            distribution[2] = nfts[subPoolId].value;
            distribution[1] = _value - nfts[subPoolId].value;
        }
        else if (_value <= nfts[superPoolId].value + nfts[poolId].value + nfts[subPoolId].value) {
            level = uint8(0);
            distribution[2] = nfts[subPoolId].value;
            distribution[1] = nfts[poolId].value;
            distribution[0] = _value - nfts[subPoolId].value - nfts[poolId].value;
        }

        amtSubPool = distribution[2];
        amtPool = distribution[1];
        amtSuperPool = distribution[0];
        
        balance = address(this).balance;
    }

    /// TokenPool Constructor
    function TokenPool(string _name, string _symbol) TokenContainer(_name, _symbol) public { 
        maxLevel = 4; // FIXED DO NOT CHANGE!

        // Creating templates
        uint superPoolId = _createNFT(10 ether, "SuperPool", uint256(1), owner);    // fix initial capital for 10 Ether
        uint poolId = _createNFT(uint256(0), "Pool", uint256(1), owner);
        uint subPoolId = _createNFT(uint256(0), "SubPool", uint256(2), owner);

        // Build initil structure SubPool --> Pool --> SuperPool
        addToken(poolId, superPoolId);
        addToken(subPoolId, poolId);

        // Build configuration 
        // SuperPool configuration
        Pool memory superPool = Pool({
            level: uint8(0),
            maxNumber: uint256(1),
            maxMember: uint256(10),
            number: uint256(1),
            last: uint256(superPoolId),
            share: uint256(10)
        });
        pools.push(superPool);
        // Pool configuration 
        Pool memory pool = Pool({
            level: uint8(1),
            maxNumber: uint256(10),
            maxMember: uint256(100),
            number: uint256(1),
            last: uint256(poolId),
            share: uint256(20)
        });
        pools.push(pool);
        // SubPool configuration 
        Pool memory subPool = Pool({
            level: uint8(2),
            maxNumber: uint256(1000),
            maxMember: uint256(100),
            number: uint256(1),
            last: uint256(subPoolId),
            share: uint256(50)
        });
        pools.push(subPool);
        // set comission to 0
        nfts[0].value = uint256(0);
    }
}