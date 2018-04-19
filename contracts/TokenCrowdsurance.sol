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
    /// @param paid paid claim amount
    /// @param score member score
    /// @param claimNumber number of claims
    /// @param status crowdsurance status
    struct Crowdsurance {
        uint        timeStamp;          // join time stamp
        uint        activated;          // coverage activation time stamp
        uint        duration;           // risk coverage duration
        uint256     amount;             // join amount
        uint256     paid;               // paid amount
        uint256     score;              // score
        uint8       claimNumber;        // number of claims
        uint8       status;             // crowdsurance status
    }
    /// Crowdsurance claim
    /// @param amount claim amount
    /// @param timeStamp claim time stamp
    /// @param duration voting period
    /// @param positive votes to pay claims
    /// @param negative votes not to pay
    /// @param number member number
    /// @param members
    struct Request {
        uint256     amount;             // claim amount
        uint        timeStamp;          // claim time stamp
        uint        duration;           // voting duration
        uint8       positive;           // number of positive votes
        uint8       negative;           // number of negative votes
        uint8       number;             // juries number
        address[5]  members;            // jury members 
    }
    /// Crowdsurance parameters
    /// @param joinAmount default join amount
    /// @param coverageDuration default coverage duration
    /// @param maxClaimAmount maximum claim amount
    /// @param maxClaimNumber maximum number of claims
    /// @param paymentRatio %% from claim to be paid
    /// @param maxPaymentAmount maximum paid amount for all claims for the covarage
    /// @param minJuriesNumber minimum number of juries to coint votes
    /// @param votingDuration duration of jury voting process in sec
    /// @param juriesNumber default juriesNumber - must correspond with Request members array lenght
    struct Parameters {
        uint256     joinAmount;         // default join amount
        uint        coverageDuration;   // coverage duration
        uint256     maxClaimAmount;     // max claim amount
        uint8       maxClaimNumber;     // max claim number for the contract
        uint8       paymentRatio;       // claim to payment patio
        uint256     maxPaymentAmount;   // max payment amount for the contract
        uint8       minJuriesNumber;    // min juries number to count voting 
        uint        votingDuration;     // juries voting duration
        uint8       juriesNumber;       // number of juries
    }
    /// Crowdsurance parameters
    Parameters public parameters;
    mapping (address => uint256) public addressToAmount;            // address to join amount mapping
    mapping (address => uint256) public addressToScore;             // address to scoring mapping
    mapping (uint256 => Crowdsurance) public extensions;            // crowdsurance extension mapping
    mapping (address => uint256) public voters;                     // crowdsurance voting
    mapping (uint256 => Request) public requests;                   // crowdsurance token Id to Claim
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
    /// @param number total claims number incuding this one
    event Claim(uint256 id, uint256 claim, uint8 number);
    /// TokenCrowdsurance vote event
    /// @param jury voter
    /// @param id NFT token id to vote
    /// @param positive voting result
    event Vote(address jury, uint256 id, bool positive);
    /// TokenCrowdsurance payment event
    /// @param reciever reciever of the p[ayment
    /// @param id NFT id for crowdsurance token
    /// @param amount mayment amount
    /// @param status payment status (Approved, Rejected, Closed)
    event Payment(address reciever, uint256 id, uint256 amount, uint8 status);
    /// TokenCrowdsurance Status
    enum Status {Init, Active, Claim, Approved, Rejected, Closed}
    /// scoring function
    /// @param _member address of the member to score
    /// @param _score member scoroing result
    /// @param _amount join amount calculated based on score
    function scoring(address _member, uint256 _score, uint256 _amount) ownerOnly public {
        require(_member != address(0));
        require(_score != uint256(0));
        require(_amount != uint256(0) && _amount >= parameters.joinAmount);
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
    function _join(address _member, uint256 _score, uint256 _amount) internal returns(uint256) {
        uint256 id = _createNFT(_amount, "Crowdsurance", uint256(0), _member);
        // Create extension 
        Crowdsurance memory _crowdsurance = Crowdsurance ({
            timeStamp: now,
            activated: uint(0),
            duration: parameters.coverageDuration,
            amount: _amount,
            paid: uint256(0),
            score: _score,
            claimNumber: uint8(0),
            status: uint8(Status.Init)
        });
        // add extension
        extensions[id] = _crowdsurance;
        // now insert in the pool
        insertPool(id);
        // emit event 
        Join(_member, id, _amount);
        // clear mapping
        delete addressToAmount[_member];
        delete addressToScore[_member];
        // return NFT token ID
        return id;
    } 
    /// join function
    /// @return cowdsuranceId NFT token ID for created crowdsurance
    function join() public payable returns(uint256 cowdsuranceId) {
        uint256 amount = msg.value;
        address member = msg.sender;
        uint256 score = addressToScore[member];
        require(amount != uint256(0) && amount >= parameters.joinAmount);
        require(score != uint256(0));
        require(amount == addressToAmount[member]);
        // call internal _join after all checkups 
        cowdsuranceId = _join(member, score, amount);
    }
    /// activate function 
    /// @param _id NFT token ID to activate
    function activate(uint256 _id) public {
        require(_id != uint256(0));
        require(_owns(msg.sender, _id));
        require(extensions[_id].amount != uint256(0));

        nfts[_id].state = StateBlocked; // block transfer
        extensions[_id].status = uint8(Status.Active);
        extensions[_id].activated = now;
        // emit event
        Activate(_id, extensions[_id].amount, extensions[_id].score);
    }
    /// claim function
    /// @param _id NFT token ID to claim payment 
    /// @param _claim claim amount
    function claim(uint256 _id, uint256 _claim) public returns(bool) {
        // check all conditions before accept the claim
        require(_id != uint256(0));
        require(_owns(msg.sender, _id));
        require(_claim != uint256(0));
        require(extensions[_id].status == uint(Status.Active));
        require(extensions[_id].claimNumber < parameters.maxClaimNumber);
        uint256 _payment = _claim * 100 / parameters.paymentRatio;
        require((extensions[_id].paid + _payment) <= parameters.maxPaymentAmount);
        uint coverageEnd = extensions[_id].activated + extensions[_id].duration;
        require(coverageEnd >= now);
        // now ready to accept the claim request
        Request memory _request;
        _request.amount = _claim;
        _request.timeStamp = now;
        _request.duration = parameters.votingDuration;
        _request.number = uint8(0);
        // change status
        requests[_id] = _request;
        extensions[_id].claimNumber++;
        extensions[_id].status = uint8(Status.Claim);
        // emit event
        Claim(_id, _claim, extensions[_id].claimNumber);
        return true;
    }
    /// add voter function
    /// @param _jury voter address
    /// @param _id NFT id for claim voting 
    function addVoter(address _jury, uint256 _id) ownerOnly public {
        require(_jury != address(0));
        require(_id != uint256(0));
        require(extensions[_id].status == uint(Status.Claim));
        Request storage _request = requests[_id];
        require(_request.amount != uint256(0));
        uint votingEnd = _request.timeStamp + _request.duration;
        require(votingEnd >= now);
        uint8 _number = _request.number;
        require(_number < parameters.juriesNumber);

        _request.members[_number] = _jury;
        _request.number++;
        voters[_jury] = _id;
    }
    /// vote function
    /// @param _id NFT id for claim voting
    /// @param _positive true if positive to pay claims
    function vote(uint256 _id, bool _positive) public {
        require(_id != uint256(0));
        require(_id == voters[msg.sender]);
        require(extensions[_id].status == uint8(Status.Claim));
        Request storage _request = requests[_id];
        uint votingEnd = _request.timeStamp + _request.duration;
        require(votingEnd >= now);

        if(_positive) {
            _request.positive++;
        } else {
            _request.negative++;
        }
        delete voters[msg.sender]; // deliting prevent the second time voting
        // emit event
        Vote(msg.sender, _id, _positive);
    }
    /// check claim voting status
    /// @param _id NFT token to check
    function votingStatus(uint256 _id) public view returns (bool votingEnded, uint8 positive, uint8 negative) {
        require(_id != uint256(0));
        require(extensions[_id].status == uint(Status.Claim));
        Request storage _request = requests[_id];
        uint votingEnd = _request.timeStamp + _request.duration;
        votingEnded = votingEnd <= now;
        positive = _request.positive;
        negative = _request.negative;
    }
    /// get payment function
    /// @param _id NFT token to get payment
    function payment(uint256 _id) public {
        require(_id != uint256(0));
        require(_owns(msg.sender, _id));
        require(extensions[_id].status == uint(Status.Claim));
        Request storage _request = requests[_id];
        uint votingEnd = _request.timeStamp + _request.duration;
        require(votingEnd <= now);
        if(_request.positive > _request.negative) {
            // pay claims
            uint256 _payment = _request.amount * 100 / parameters.paymentRatio;
            msg.sender.transfer(_payment);
            extensions[_id].status = uint8(Status.Approved);
            extensions[_id].paid = extensions[_id].paid + _payment;
            // emit event
            Payment(msg.sender, _id, _payment, uint8(Status.Approved));
        } else if   (_request.positive == _request.negative || 
                    (_request.positive + _request.negative) < parameters.minJuriesNumber ) {
            // pay back join amount
            msg.sender.transfer(extensions[_id].amount);
            extensions[_id].status = uint8(Status.Closed);
            extensions[_id].paid = extensions[_id].paid + extensions[_id].amount;
            // emit event
            Payment(msg.sender, _id, extensions[_id].amount, uint8(Status.Closed));
        } else {
            // no payment
            extensions[_id].status = uint8(Status.Rejected);
            // emit event
            Payment(msg.sender, _id, uint256(0), uint8(Status.Rejected));
        }
        // now time to clean voting enviroment
        for(uint i; i < _request.number; i++) {
            delete voters[_request.members[i]];
        }
        delete requests[_id];
    }
    /// status count function
    /// @param _member address of token owner
    /// @param _status status to check
    function statusCount(address _member, uint8 _status) view public returns (uint256 count) {
        uint256[] memory tokenIds = _tokensOfOwner(_member);
        count = uint256(0);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (extensions[tokenIds[i]].status == _status) {
                count++;
            }
        }
    }
    function TokenCrowdsurance(string _name, string _symbol) TokenPool(_name, _symbol) public {
        // setup default crowdsurance product parameters
        parameters.joinAmount = 0.1 ether;                  // default join amount
        parameters.coverageDuration = uint(60*60*24*180);   // coverage duration in sec
        parameters.maxClaimAmount = 10 ether;               // max claim amount
        parameters.maxClaimNumber = 1;                      // max claim number for the contract
        parameters.paymentRatio = 80;                       // claim to payment patio
        parameters.maxPaymentAmount = 10 ether;             // max payment amount for the contract
        parameters.minJuriesNumber = 3;                     // min juries number to count voting 
        parameters.votingDuration = uint8(60*60*24*2);      // juries voting duration in sec
        parameters.juriesNumber = 5;                        // juries number -- not more than 5
    }
}