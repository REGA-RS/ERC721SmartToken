pragma solidity ^0.4.18;

import './interfaces/IERC20Controller.sol';
import './interfaces/IERC20Adapter.sol';

contract ERC20Adapter is IERC20Adapter {
    IERC20Controller public controller;
    string public standard = "Token 0.1";
    string public name = "";
    string public symbol = "";
    uint8 public decimals = 0;

    function totalSupply() public view returns (uint256) {
        require(controller != address(0));

        return controller.cTotalSupply();
    }
    function balanceOf(address _owner) public view returns (uint256) {
        require(controller != address(0));
        require(_owner != address(0));

        return controller.cBalanceOf(_owner);
    }
    function allowance(address _owner, address _spender) public view returns (uint256) { 
        require(controller != address(0));
        require(_owner != address(0));
        require(_spender != address(0));

        return controller.cAllowance(_owner, _spender);
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(controller != address(0));
        require(_to != address(0));
        require(_value != uint256(0));

        return controller.cTransfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(controller != address(0));
        require(_to != address(0));
        require(_from != address(0));
        require(_value != uint256(0));

        return controller.cTransferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(controller != address(0));
        require(_spender != address(0));
        require(_value != uint256(0));

        return controller.cApprove(_spender, _value);
    }
    function approveFrom(uint256 _fromId, address _spender, uint256 _toId, uint256 _value) public returns (bool success) {
        require(controller != address(0));
        require(_fromId != uint256(0));
        require(_spender != address(0));
        require(_toId != uint256(0));
        require(_value != uint256(0));
        require(_fromId != _toId);

        return controller.cApproveFrom(_fromId, _spender, _toId, _value);
    }
    function ERC20Adapter(IERC20Controller _controller, string _name, string _symbol, uint8 _decimals) public {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0); // validate input

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        controller = _controller;
    }

}