pragma solidity ^0.4.18;

import './interfaces/IERC20Controller.sol';

contract ERC20Controller is IERC20Controller {

    mapping (address => mapping (address => uint256)) public allowanceIds; // transfer allowance
    mapping (address => mapping (address => uint256)) public allowanceAmt; // transfer allowance

    // Need to implement in NFT Token smartcontract
    function transfer(address _from, uint256 _fromId, address _to, uint256 _toId, uint256 _value) internal;
    function defaultId(address _owner) internal returns (uint256 id);
    function addValue(address _to, uint256 _toId, uint256 _value) internal;
    function removeValue(address _from, uint256 _fromId, uint256 _value) internal;

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

    function cAllowance(address _owner, address _spender) public view returns (uint256) {
        require(_spender != address(0));
        require(_owner != address(0));

        return allowanceAmt[_owner][_spender];
    }
    
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

    function cTransfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value != uint256(0));
        address _from = msg.sender;

        return cTransferFrom(_from, _to, _value);
    }

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
