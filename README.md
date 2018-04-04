# ERC721SmartToken
## ERC721 token with ERC20 adapter

```ERC721SmartToken``` contract implements non-fungible tokens based on [ERC721](https://github.com/ethereum/eips/issues/721) standard 
that also supports [ERC20](https://github.com/ethereum/eips/issues/20) interface. The main idea is to create a token that can be both non-fungible and has transferable value. 

Inside ERC721 contract each not fungible token represented as a NFT structure where there is a member element called ```value ```.
```solidity
struct NFT {
        uint256 value;          // NFT value 
        string  metadata;       // ... metadata: IPFS path
        uint256 kind;           // ... type
        uint256 level;          // ... activities level
        uint256 state;          // ... state
    }
```
This element holds ERC20 token inside ERC721 token. 

To work with ERC721 token as normal ERC20 token we need to create a ```ERC20Adapter``` that implements standard ERC20 methods, 
as for example ```balanceOf``` method.
```solidity
function balanceOf(address _owner) public view returns (uint256)
```
But in our case due to ERC721 structure for each ```_owner``` there can be many 
non-fungible tokens belong to this particular address. To select particular token for ERC20 compatible operations like 
transfer token value to another address we need to implement new methods that will accept address and token ID as parameters.
```solidity
function approveFrom(uint256 _fromId, address _spender, uint256 _toId, uint256 _value) public returns (bool success)
```
This method calls ```ERC20Controller``` method implemented by ```ERC721SmartToken``` contract that will use the following mappings to store information abount NFT tokens:
```solidity
mapping (address => mapping (address => uint256)) public allowanceIds; // transfer allowance
mapping (address => mapping (address => uint256)) public allowanceAmt; // transfer allowance
```
Now we can use ERC20 standard methods ```transfer``` and ```transferFrom``` to transfer values between two NFT tokens.

```ERC20Controller``` implements ```defaultId``` methods that provides a default NFT id for the ```_owner``` address.
```solidity
function defaultId(address _owner) internal returns (uint256 id);
```
So, we can use ERC20 standard method ```approve``` to approve transfer between two NFT default tokens for ```msg.sender``` and ```_spender```.

See [Help](https://github.com/REGA-RS/ERC721SmartToken/blob/master/help.md#events) for events description.

## TokenContainer 
```TokenContainer``` smart contract implements hierarchical structure for token pools. Now one NFT token can be a container for other NFT tokens in the same smart contract. Each token can belong only one container, ```token-container``` relationship supported by the following mapping:
```solidity
mapping (uint256 => uint256) public tokenIndexToPoolToken;
```
The public variable ```maxLevel``` defines the maximum number of levelels in hierarchical structure where the ```root``` must be al level ```0``` and a token with level ```maxLevel-1``` will be terminal node in the structure.

For each token we can find the path from this token to the ```root``` token using the following method:
```solidity
function getPath(uint256 _nodeId) external view returns(uint256[] path);
```
The ```path``` could contain number of token IDs starting from the first pool token that ```_nodeId``` belongs to. Plase note that NFT ID ```0``` is reserved and equal to ```null``` value. So, only not zeto IDs are counted as pool token IDs.

For each pool token we can check the pool size and recieve pool members array:
```solidity
function _getPoolSize(uint256 _nodeId) view internal returns(uint256 size);
function _getPool(uint256 _nodeId) view internal returns(uint256[] pool);
```
A NFT token can be added to pool token or can be removed from pool. In removal we will check if removing token ```nodeId``` does not have any pool members ```_getPoolSize(_nodeId) == 0``` and if not we will rise an exception.
```solidity
function addToken(uint256 _nodeId, uint256 _parentId) public;
function removeToken(uint256 _nodeId) public;
```
The ```TokenContainer``` constructur calls ```ERC721SmartToken``` constructur with token ```name``` and token ```symbol```.

## TokenPool
```TokenPool``` is TokenContainer with 4 level pool structure:
```solidity
Level     Container / Member
----------------------------------------------
  0       SuperPool
  1           I-----Pool
  2                   I------SubPool
  3                             I-------Token
```
