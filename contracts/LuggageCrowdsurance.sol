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

import './TokenCrowdsurance.sol';
import './interfaces/IERC20Token.sol';

/// Luggage crowdsurance protection product based on TokenCrowdsurance NFT token 
contract LuggageCrowdsurance is TokenCrowdsurance {
    /// REGA Risk Sharing Token smart contract address
    IERC20Token public  RST;                // RST smart contract address
    uint256     public  joinAmountRST;      // Join amount in RST
    bool        public  ETHOnly;            // Join only for RST tokens
    uint8       public  maxHold;            // Maximum number of toikens for one address
    uint256     public  rstETHRate;         // RST/ETH rate
    uint8       public  paybackRatio;       // Payback ratio

    mapping (uint256 => uint256) public payback;    // payback mapping
    /// join function
    /// @return cowdsuranceId NFT token ID for created crowdsurance
    function join() public payable returns(uint256 cowdsuranceId) {
        uint256 amount = msg.value;
        address member = msg.sender;
        uint256 score = addressToScore[member];
        require(score != uint256(0));

        if (!ETHOnly && msg.value == uint256(0)) {
            // now need to check that the member has approved the transfer joinAmountRST to join
            require(RST != address(0));                             // check that we have valid contract address
            require(joinAmountRST != uint256(0));                   // join RST amount must be > 0
            uint256 rstAmt = RST.allowance(member, this);           // check if the member has gave permision to spend some amount
            uint256 rstDecimals = uint256(RST.decimals());          // need RST decimals to convert RST to ETH based on the convertion rate
            require(rstAmt >= joinAmountRST);                       // ... and check if allowance is more then joinAmount
            amount = addressToAmount[member];                       // get join amount and check...
            uint256 rstAmtInETH = rstAmt * rstETHRate;              // ... and now calculate join amount from RST to ETH
            if (rstDecimals >= uint8(1)) {                          // ... check if RST decimals is not 0
                rstDecimals--;
                rstAmtInETH = rstAmtInETH / (10 ** rstDecimals);    // ... and use decimals to convert RST to ETH
            }
            require(rstAmtInETH >= amount && amount >= parameters.joinAmount);
            // transfer join RST amount to the owner account
            require(RST.transferFrom(member, owner, joinAmountRST));
        }
        else {
            require(amount != uint256(0) && amount >= parameters.joinAmount);
            require(amount == addressToAmount[member]);
        }
        // call internal _join after all checkups 
        cowdsuranceId = _join(member, score, amount);
    }
    /// set payback amount function
    /// @param _id crowdsurance token ID
    /// @param _amount payback amount to set
    /// @return true if successful 
    function setPayback(uint256 _id, uint256 _amount) ownerOnly public returns (bool) {
        require(_id != uint256(0));
        require(_amount != uint256(0));
        require(_amount <= parameters.joinAmount * paybackRatio / 100);
        require(extensions[_id].paid == uint256(0));
        uint coverageEnd = extensions[_id].activated + extensions[_id].duration;
        require(coverageEnd < now);
        payback[_id] = _amount;
        return true;
    }
    /// get payback function
    /// @param _id luggage protection token to get payback
    function getPayback(uint256 _id) public {
        require(_owns(msg.sender, _id));
        require(_id != uint256(0));
        uint256 _amount = payback[_id];
        require(_amount != uint256(0));
        require(extensions[_id].paid == uint256(0));
        extensions[_id].paid = _amount;
        msg.sender.transfer(_amount);
    }
    /// activate function 
    /// @param _id NFT token ID to activate
    function activate(uint256 _id) public {
        address member = msg.sender;
        // check if number of tokens is not more then maxHold
        require(statusCount(member, uint8(Status.Active)) < maxHold);   
        super.activate(_id);
    }
    /// get commission function
    function transferCommission() ownerOnly public {
        uint256 commission = nfts[0].value;
        require(commission != uint256(0)); 
        nfts[0].value = 0;
        msg.sender.transfer(commission);
    }
    function LuggageCrowdsurance(address _rst, uint256 _amount, bool _only, uint8 _max) 
                TokenCrowdsurance("Luggage Crowdsurance NFT", "LCS") public {
        // setting up contract parameters 
        RST = IERC20Token(_rst);
        parameters.joinAmount = 0.019 ether;
        parameters.maxClaimAmount = 4 ether; 
        if (_amount == uint256(0)) {
            joinAmountRST = 5000000000; 
        }
        else {
            joinAmountRST = _amount; 
        }
        if (_max == uint8(0)) {
            maxHold = 5;
        }
        else {
            maxHold = _max;
        }
        ETHOnly = _only;
        rstETHRate = 0.12 ether;
        paybackRatio = 80;
    }
}