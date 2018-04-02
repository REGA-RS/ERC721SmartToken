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
import './interfaces/IERC20Adapter.sol';
/// ERC20 Adapter
contract ERC20Adapter is IERC20Adapter {
    /// ERC20 Controller 
    IERC20Controller public controller;
    /// ERC20 Standard
    string public standard = "Token 0.1";
    /// ERC20 Token name
    string public name = "";
    /// ERC20 Token symbol
    string public symbol = "";
    /// ERC20 Token decimals 
    uint8 public decimals = 0;
    /// ERC20 total supply
    /// @return total ERC20 supply
    function totalSupply() public view returns (uint256) {
        require(controller != address(0));

        return controller.cTotalSupply();
    }
    /// ERC20 balance 
    /// @param _owner token owner
    /// @return token owner balance
    function balanceOf(address _owner) public view returns (uint256) {
        require(controller != address(0));
        require(_owner != address(0));

        return controller.cBalanceOf(_owner);
    }
    /// ERC20 allowance 
    /// @param _owner token owner
    /// @param _spender spender address 
    /// @return allowance amount
    function allowance(address _owner, address _spender) public view returns (uint256) { 
        require(controller != address(0));
        require(_owner != address(0));
        require(_spender != address(0));

        return controller.cAllowance(_owner, _spender);
    }
    /// ERC20 transfer 
    /// @param _to adress to transfer
    /// @param _value transfer amount 
    /// @return TRUE if transfer is succesuful 
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(controller != address(0));
        require(_to != address(0));
        require(_value != uint256(0));

        return controller.cTransfer(_to, _value);
    }
    /// ERC20 transfer from
    /// @param _from address to transfer from 
    /// @param _to adress to transfer to 
    /// @param _value transfer amount 
    /// @return TRUE if transfer is succesuful 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(controller != address(0));
        require(_to != address(0));
        require(_from != address(0));
        require(_value != uint256(0));

        return controller.cTransferFrom(_from, _to, _value);
    }
    /// ERC20 transfer approve
    /// @param _spender address to approve
    /// @param _value amount to approve
    /// @return TRUE if transfer is succesuful 
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(controller != address(0));
        require(_spender != address(0));
        require(_value != uint256(0));

        return controller.cApprove(_spender, _value);
    }
    /// ERC20 / ERC721 transfer approve 
    /// @param _fromId NFT token ID to send value
    /// @param _spender address to approve
    /// @param _toId NFT token to recieve value
    /// @param _value amount to approve
    /// @return TRUE if transfer is succesuful 
    function approveFrom(uint256 _fromId, address _spender, uint256 _toId, uint256 _value) public returns (bool success) {
        require(controller != address(0));
        require(_fromId != uint256(0));
        require(_spender != address(0));
        require(_toId != uint256(0));
        require(_value != uint256(0));
        require(_fromId != _toId);

        return controller.cApproveFrom(_fromId, _spender, _toId, _value);
    }
    /// Constructor 
    /// @param _controller ERC20 Controller
    /// @param _name ERC20 token name
    /// @param _symbol ERC20 token symbol
    /// @param _decimals ERC20 token decimals
    function ERC20Adapter(IERC20Controller _controller, string _name, string _symbol, uint8 _decimals) public {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0); // validate input

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        controller = _controller;
    }

}