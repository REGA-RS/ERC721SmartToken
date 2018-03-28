pragma solidity ^0.4.18;

import './IERC20Token.sol';
/*
    ERC20 Standard Token interface
*/
contract IERC20 is IERC20Token {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}