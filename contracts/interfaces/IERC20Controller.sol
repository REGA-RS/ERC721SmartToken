pragma solidity ^0.4.18;

/*
    ERC20 Controller interface for ERC721 Token (NFT)
*/
contract IERC20Controller {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function cTotalSupply() public view returns (uint256);
    function cBalanceOf(address _owner) public view returns (uint256);
    function cAllowance(address _owner, address _spender) public view returns (uint256);

    function cTransfer(address _to, uint256 _value) public returns (bool success);
    function cTransferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function cApprove(address _spender, uint256 _value) public returns (bool success);

    function cApproveFrom(uint256 _fromId, address _spender, uint256 _toId, uint256 _value) public returns (bool success);

    function cIssue(address _to, uint256 _toId, uint256 _amount) public;
    function cDestroy(address _from, uint256 _fromId, uint256 _amount) public;
}