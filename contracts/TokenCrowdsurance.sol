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

import './TokenPool.sol';
/// TokenCrowdsurance is ERC721SmartToken for crowdsurance products. 
/// Crowdsurance, meaning people unite in communities to provide a guarantee of compensation for unexpected loss. 
/// Using ERC721SmartToken crowdsurance product can be 'tokenized' and can be availible as ERC20 token.
contract TokenCrowdsurance is TokenPool {
    mapping (address => uint256) public addressToAmount;
    mapping (address => uint256) public addressToScore;
    /// TokenCrowdsurance Apply event
    /// @param member new member address
    /// @param score member score
    /// @param amount need to pay to join
    event Apply(address member, uint256 score, uint256 amount);
    /// TokenCrowdsurance Join event
    /// @param member new member addrsss
    /// @param id NFT token id for crowdsurance token
    /// @param amount paid to join
    event Join(address member, uint256 id, uint256 amount);
    /// TokenCrowdsurance Scoring event
    /// @param member new member addrsss
    /// @param score member scoring
    /// @param amount join amount
    event Scoring(address member, uint256 score, uint256 amount);
    /// TokenCrowdsurance Status
    enum Status {Init, Active, Claim, Closed}
    /// scoring function
    /// @param _member address of the member to score
    /// @param _score member scoroing result
    /// @param _amount join amount calculated based on score
    function scoring(address _member, uint256 _score, uint256 _amount) ownerOnly public {
        require(_member != address(0));
        require(_score != uint256(0));
        require(_amount != uint256(0));
        addressToAmount[_member] = _amount;
        addressToScore[_member] = _score;
        // emit scoring event
        Scoring(_member, _score, _amount);
    }
    /// apply function 
    /// @return join ampount - must be not zero to join
    function apply() public view returns(uint256 amount) {
        amount = addressToAmount[msg.sender];
        uint256 score = addressToScore[msg.sender];
        // emit Apply event
        Apply(msg.sender, score, amount);
    }
    /// join function
    /// @return cowdsuranceId NFT token ID for created crowdsurance
    function join() public payable returns(uint256 cowdsuranceId) {
        uint256 amount = msg.value;
        address member = msg.sender;
        uint256 score = addressToScore[member];
        require(amount != uint256(0));
        require(score != uint256(0));
        require(amount == addressToAmount[member]);
        uint256 id = _createNFT(amount, "Crowdsurance", uint256(0), member);
        require(id != uint(0));
        // set status
        nfts[id].state = uint256(Status.Init);
        // now insert in the pool
        insertPool(id);
        cowdsuranceId = id;
        // emit event 
        Join(member, id, amount);
        // clear mapping
        delete addressToAmount[member];
        delete addressToScore[member];
    }
    function TokenCrowdsurance(string _name, string _symbol) TokenPool(_name, _symbol) public {}
}