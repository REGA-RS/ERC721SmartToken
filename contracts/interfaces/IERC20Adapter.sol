pragma solidity ^0.4.18;

import './IERC20.sol';

contract IERC20Adapter is IERC20 {
    function approveFrom(uint256 _fromId, address _spender, uint256 _toId, uint256 _value) public returns (bool success);
}