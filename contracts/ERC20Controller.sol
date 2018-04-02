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
pragma solidity ^0.4.18;

import './interfaces/IERC20Controller.sol';

/// ERC20 Controller  
contract ERC20Controller is IERC20Controller {
    /// @dev transfer allowance fot IDs
    /// from given address
    mapping (address => mapping (address => uint256)) public allowanceIds; // transfer allowance
    /// @dev transfer allowance amount
    /// from given address
    mapping (address => mapping (address => uint256)) public allowanceAmt; // transfer allowance
    /// @dev Need to implement in NFT Token smartcontract
    function transfer(address _from, uint256 _fromId, address _to, uint256 _toId, uint256 _value) internal;
    function defaultId(address _owner) internal returns (uint256 id);
    function addValue(address _to, uint256 _toId, uint256 _value) internal;
    function removeValue(address _from, uint256 _fromId, uint256 _value) internal;
    /// approve NFT token value transfer
    /// @param _fromId NFT token ID to transfer value
    /// @param _spender token owner address
    /// @param _toId NFT token ID to recieve value
    /// @param _value value to approve for transfer
    /// @return TRUE if transfer is approved
    function cApproveFrom(uint256 _fromId, address _spender, uint256 _toId, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        require(_fromId != _toId);
        require(_fromId != uint256(0));
        require(_toId != uint256(0));
        require(_value != uint256(0));
        address _sender = msg.sender;

        allowanceIds[_sender][_spender] = _toId;
        allowanceIds[_sender][_sender] = _fromId;
        allowanceAmt[_sender][_spender] = _value;

        return true;
    }
    /// approve NFT token value transfer for default token ID
    /// @param _spender token owner address
    /// @param _value value to approve for transfer
    /// @return TRUE if transfer is approved
    function cApprove(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        require(_value != uint256(0));
        address _sender = msg.sender;
        uint256 _fromId = defaultId(_sender);
        uint256 _toId = defaultId(_spender);
        require(_fromId != _toId);
        require(_fromId != uint256(0));
        require(_toId != uint256(0));

        allowanceIds[_sender][_spender] = _toId;
        allowanceIds[_sender][_sender] = _fromId;
        allowanceAmt[_sender][_spender] = _value;

        return true;
    }
    /// return value that is approved for transfer
    /// @param _owner NFT token owner that approved transfer
    /// @param _spender NFT token owner that approved to recive the value
    /// @return approved value
    function cAllowance(address _owner, address _spender) public view returns (uint256) {
        require(_spender != address(0));
        require(_owner != address(0));

        return allowanceAmt[_owner][_spender];
    }
    /// transfer value from one NFT token to another one. The transfer must be approved before 
    /// @param _from NFT owner address that approved the transfer
    /// @param _to value reciever address 
    /// @param _value value to transfer
    /// @return TRUE if the transfer was successuful 
    function cTransferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value != uint256(0));
        address _sender = _from;

        uint256 _toId = allowanceIds[_sender][_to];
        uint256 _fromId = allowanceIds[_sender][_sender];
        uint256 _amount = allowanceAmt[_sender][_to];
        require(_toId != _fromId);
        require(_toId != uint256(0));
        require(_fromId != uint256(0));
        require(_amount != uint256(0));
        require(_amount >= _value);

        transfer(_sender, _fromId, _to, _toId, _value);
        allowanceAmt[_sender][_to] = allowanceAmt[_sender][_to] - _value;
        if (allowanceAmt[_sender][_to] == uint256(0)) {
            delete allowanceAmt[_sender][_to];
            delete allowanceIds[_sender][_sender];
            delete allowanceIds[_sender][_to];
        }
        return true;
    }
    /// transfer value from NFT token that belongs to sender to another one. The transfer must be approved before 
    /// @param _to value reciever address 
    /// @param _value value to transfer
    /// @return TRUE if the transfer was successuful
    function cTransfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value != uint256(0));
        address _from = msg.sender;

        return cTransferFrom(_from, _to, _value);
    }
    /// increase value for NFT token
    /// @param _to address of token owner
    /// @param _toId NFT token ID
    /// @param _amount amount to add
    function cIssue(address _to, uint256 _toId, uint256 _amount) public {
        require(_to != address(0));
        require(_amount != uint256(0));
        uint256 id = _toId;
        if (id == uint256(0)) {
            id = defaultId(_to);
        }
        require(id != uint256(0));
        addValue(_to, id, _amount);
    }
    /// decrease value for NFT token
    /// @param _from address of token owner
    /// @param _fromId NFT token ID
    /// @param _amount amount to decrease
    function cDestroy(address _from, uint256 _fromId, uint256 _amount) public {
        require(_from != address(0));
        require(_amount != uint256(0));
        uint256 id = _fromId;
        if (id == uint256(0)) {
            id = defaultId(_from);
        }
        require(id != uint256(0));
        removeValue(_from, id, _amount);
    }
}
