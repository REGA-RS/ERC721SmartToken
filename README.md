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
```TokenPool``` is ```TokenContainer``` with 4 level pool structure:
```solidity
Level     Container / Member
--------------------------------------------
  0       SuperPool
  1           |_____.Pool
  2                   |_____.SubPool
  3                             |_____.Token
```
The pool schema described by the following structure:
```solidity
struct Pool {
        uint8   level;      // Pool level: 0,1,2,3
        uint256 maxNumber;  // Maximum number of pools on this lavel
        uint256 maxMember;  // Maximum number of members for the pool
        uint256 number;     // Pool number for this level
        uint256 last;       // NFT ID for last availible pool (with member capacity)
        uint256 share;      // Pool share from token investment
 }
 ```
Use ```insertPool``` method to insert token in the pool structure:
```solidity
function insertPool(uint256 _id) public returns(bool);
```
This function calls ```_insertPool``` to insert the token and if needed also insert new pool in the structure:
```solidity
function _insertPool(uint256 _id, uint8 _level) internal returns (bool);
```
After the token is inserted in the pool structure the function ```insertPool``` calls the value distribution function:
```solidity
function _distributeValue(uint256 _id) internal returns (bool);
```
than distrubutes the token value between ```SuperPool```, ```Pool``` and ```SubPool``` based on ```Pool.share```. The rest of the token value after the pool distribution will go to commission. Use the following methods to get collected commission and current pool values:
```solidity
function getComission() public view returns(uint256 commission);
```
```solidity
function getDistribution() public view returns(uint256[4] distribution)
```
The last function returns the following values:
```solidity
distribution[0];         // Super Pool Value
distribution[1];         // Pool Value
distribution[2];         // SubPool Value
distribution[3];         // Tokens Value (must be 0)
```
To pay value the smart contract uses the following function:
```solidity
function _payValue(uint256 _id, uint256 _value) internal returns(uint256[4] distribution);
```
```__payValue``` returns distribution for the payment based on the same structure as ```getDistribution``` but in this case only one array element can have non zero value equal to ```_value```. For example, if Pool has made a payment then ```distribution[1] == _value``` and the rest of ```distribution[0,2,3] == 0```. If all elements have zero value then payment is not successful and all pool does not have enough  value to pay requested amount. In this case ```_payValue``` emits ```SecondTierCall``` event. If the payment went through then event ```PaymentValue``` was emited:
```solidity
 event PaymentValue(uint256 id, uint256 value, uint8 level);
 ```
 and it will return the pool level that has made the payment, in our example it will be ```level == 1```.

## TokenCrowdsurance

```TokenCrowdsurance``` is ```ERC721SmartToken``` for crowdsurance products. Crowdsurance, meaning people unite in communities to provide a guarantee of compensation for unexpected loss. Using ```ERC721SmartToken``` crowdsurance product can be 'tokenized' and can be availible as ERC20 token.
![pic](https://github.com/REGA-RS/ERC721SmartToken/blob/master/TokenCrowdsurance.png?raw=true "Crowdsurance")
The crowdsurance business process starting from ```apply``` function that returns application ID:
```solidity
 function apply() public returns(uint256 addId);
 ```
There is application queue supported by the smart contract and next application to process can be obtained by the following function:
```solidity
function getApplication() view public returns (address member, uint256 appId);
 ```
After that the scoring for the new member can be complited by the following call:
```solidity
function scoring(address _member, uint256 _score, uint256 _amount) ownerOnly public;
 ```
The ```scoring``` can be called only by contract owner. After recieve score a new member can join the Crowdsurance smart contract using ```join``` function. 
```solidity
function join() public payable returns(uint256 cowdsuranceId);
```
This function will return the Crowdsurance NFT token ID. The ```TokenCrowdsurance``` is ```ERC721``` token and can be transfered to another holder using standard ```ERC721``` methods. To activate crowdsurance coverage the token holder must call ```activate``` function:
```solidity
function activate(uint256 _id) public;
```
after then the coverage is activated and token transfer is prohibited. In case of risk realisation the token holder can submeet claim to recieve the payment:
```solidity
function claim(uint256 _id, uint256 _claim) public returns(bool);
```
In this function the token owner provides token id ```_id``` and ```_claim``` - the claim amount. The token status will be changed to ```Claim``` and the voting process will be initiated.
To conduct the voting process a juries must be selected randomly from ```RST``` token holders. Each jury member will be submeeted by contract owner:
```solidity
function addVoter(address _jury, uint256 _id) ownerOnly public;
```
and for each ```_jury``` will be specified the token ```_id``` for voting. Selected RST token holders could vote using the following method:
```solidity
function vote(uint256 _id, bool _positive) public;
``` 
providing the ```TokenCrowdsurance``` id and voting result ```_positive```. If ```_positive``` is ```true``` then the vote will be counted in favore of claim payment and if ```false``` then the vote will be counted as negative one. The current voting status can be recieved from the following function call:
```solidity
function votingStatus(uint256 _id) public view returns (bool votingEnded, uint8 positive, uint8 negative);
```
Need to say that the voting process have start and end time and votes can be counted only within this specific period.
When the voting process is finished the token owner can recieve the payment calling the following method:
```solidity
 function payment(uint256 _id) public;
 ```
 If the claim was approved by the juries then the payment amount will be transferred from ```TokenCrowdsurance``` smart contract account to the token holder account. If nobody has voted or number of votes less then the crowdsurance product ```minJuriesNumber``` parameter or ```positive``` is equal to ```negative``` then the token owner will receive join amount.
 There are number of parameters for crowdsurance product that can be utilized to adjust the product behaviour.
 ```solidity
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
  ``` 
## LuggageCrowdsurance

The luggage crowdsurance protection product is ```TokenCrowdsurance``` NFT721SmartToken with additional features:
1. New member could join crowdsurance smart contract make a transfer in **RST tokens**
1. Number of **activated** luggage protection token for each member is limited by smart contract parameter ```maxHold```
1. Join can be allowed **only with ETH** if smart contract parameter ```ETHOnly``` is set to ```true```
1. Member can receive a **payback** up to ```paybackRatio``` from join amount after the end of coverage  

If ```ETHOnly``` is ```false``` a new member can join the luggage crowdsurance smart contract using RST tokens. If this case the member should allow a transfer of ```joinAmountRST``` specified in the ```LuggageCrowdsurance``` smart contract to the contract ```owner``` using RST ERC20 standart method:
```solidity
function approve(address _spender, uint256 _value) returns (bool success)
```
Then the new member can call ```LuggageCrowdsurance``` ```join``` method with ```value == 0``` and in this case if ```ETHOnly == false``` the ```join``` will transfer ```joinAmountRST``` to the smart contract ```owner```. 

The ```LuggageCrowdsurance``` token has the following parameters:

Product parameter|Value
------------|-------------
ERC721 Name|Luggage Crowdsurance NFT
ERC721 Symbol|LCS
Default join amount|0.019 ETH
Default join RST amount|0.5 RST
Protection period|180 days
Default claim payment amount|4 ETH
Maximum number of claims|1
Maximun number of activated|5
RST / ETH Rate|0.12 ETH
Payback ratio|80%
Payback period|within 48 hours
Commission|20%

After the crowdsurance coverage period is ended the token owner can recieve payback up to ```Payback ratio``` from the join amount if he/she did not recieved a payment during the crowdsurance coverage period. To get payback the owner must call the following function:
```solidity
 function getPayback(uint256 _id) public;
 ```
 The payback amout must be seted by the contract owner before the ```getPayback``` call using:
 ```solidity
 function setPayback(uint256 _id, uint256 _amount) ownerOnly public returns (bool);
 ```
 

