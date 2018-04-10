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
    /// Crowdsurance token ERC721 extention
    /// @param timeStamp join time stemp
    /// @param activated coverage activation time stamp
    /// @param duration crowdsurance coverage duration
    /// @param amount join amount
    /// @param claim claim amount
    /// @param paid paid claim amount
    /// @param score member score
    /// @param status crowdsurance status
    /// @param claimed claim time stamp
    /// @param timeToVote voting period
    /// @param positive votes to pay claims
    /// @param negative votes not to pay
    struct Crowdsurance {
        uint    timeStamp;  // join time stamp
        uint    activated;  // coverage activation time stamp
        uint    duration;   // risk coverage duration
        uint256 amount;     // join amount
        uint256 claim;      // claim amount
        uint256 paid;       // paid amoutn
        uint256 score;      // score
        uint    status;     // current status
        uint    claimed;    // claim time stamp
        uint8   timeToVote; // voting period
        uint8   positive;   // votes to pay claims
        uint8   negative;   // votes not to pay    
    }
    /// Crowdsurance voting 
    /// @param weight voter weight
    /// @param voted true if voted
    /// @param tokenId Crowdsurance NFT token ID to vote
    struct Voter {
        uint    weight;
        bool    voted;
        uint256 tokenId;
    }
    /// Crowdsurance template
    Crowdsurance public template;
    mapping (address => uint256) public addressToAmount;            // address to join amount mapping
    mapping (address => uint256) public addressToScore;             // address to scoring mapping
    mapping (uint256 => Crowdsurance) public tokenIdToExtension;    // crowdsurance extension mapping
    mapping (address => Voter) public voters;                       // crowdsurance voting
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
    /// TokenCrowdsurance Activate event
    /// @param id NFT Id to activate
    /// @param amount acowdsurance join amount
    /// @param score member scoring
    event Activate(uint256 id, uint256 amount, uint256 score);
    /// TokenCrowdsurance Activate event
    /// @param id NFT Id to activate
    /// @param claim claim amount
    event Claim(uint256 id, uint256 claim);
    /// TokenCrowdsurance Status
    enum Status {Init, Active, Claim, Approved, Rejected, Closed}
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
        // Create extension 
        Crowdsurance memory _crowdsurance = Crowdsurance ({
            timeStamp: now,
            activated: uint(0),
            duration: template.duration,
            amount: amount,
            claim: template.claim,
            paid: template.paid,
            score: score,
            status: template.status,
            claimed: uint(0),
            timeToVote: template.timeToVote,
            positive: uint8(0),
            negative: uint8(0)
        });
        // add extension
        tokenIdToExtension[id] = _crowdsurance;
        // now insert in the pool
        insertPool(id);
        cowdsuranceId = id;
        // emit event 
        Join(member, id, amount);
        // clear mapping
        delete addressToAmount[member];
        delete addressToScore[member];
    }
    /// activate function 
    /// @param _id NFT token ID to activate
    function activate(uint256 _id) public {
        require(_id != uint256(0));
        require(_owns(msg.sender, _id));
        require(tokenIdToExtension[_id].amount != uint256(0));

        nfts[_id].state = StateBlocked; // block transfer
        tokenIdToExtension[_id].status = uint(Status.Active);
        tokenIdToExtension[_id].activated = now;
        // emit event
        Activate(_id, tokenIdToExtension[_id].amount, tokenIdToExtension[_id].score);
    }
    /// claim function
    /// @param _id NFT token ID to claim payment 
    /// @param _claim claim amount
    function claim(uint256 _id, uint256 _claim) public returns(bool) {
        require(_id != uint256(0));
        require(_owns(msg.sender, _id));
        require(_claim != uint256(0));
        require(tokenIdToExtension[_id].status == uint(Status.Active));
        require((tokenIdToExtension[_id].claim + _claim) <= template.claim);

        tokenIdToExtension[_id].status = uint(Status.Claim);
        tokenIdToExtension[_id].claim = tokenIdToExtension[_id].claim + _claim;
        // emit event
        Claim(_id, _claim);
        return true;
    }
    function addVoter(address _jury, uint256 _id) ownerOnly public {
        require(_jury != address(0));
        require(_id != uint256(0));
        require(tokenIdToExtension[_id].status == uint(Status.Claim));
        uint votingEnd = tokenIdToExtension[_id].claimed + tokenIdToExtension[_id].timeToVote;
        require(votingEnd > now);
        
        Voter memory _voter = Voter({
            weight: 1,
            voted: false,
            tokenId: _id
        });
        voters[_jury] = _voter;
    }
    function TokenCrowdsurance(string _name, string _symbol) TokenPool(_name, _symbol) public {
        template.timeStamp = now;
        template.activated = uint(0);
        template.duration = uint(60*60*24*180);
        template.amount = 0.1 ether;                // default join amount
        template.claim = 10 ether;                  // max claim amount
        template.paid = 10 ether * 100 / 80;        // max paid amount
        template.score = uint256(100);
        template.status = uint(Status.Init);
        template.claimed = uint(0);
        template.timeToVote = uint8(60*60*24*2);
        template.positive = uint8(0);
        template.negative = uint8(0);
    }
}