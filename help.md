












# ERC721SmartToken

### All function calls are currently implement without side effects

ERC721SmartToken contract implements non-fungible tokens based on ERC721 standard that also supports ERC20 interface.The contract is subclass of ERC721, ERC20Controller and Owned contracts

## Functions



### Constant functions

#### allowance

allowance amount


##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||allowance amount|


#### allowanceAmt

transfer allowance amount
from given address

##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||transfer allowance amount|


#### allowanceIds

transfer allowance fot IDs
from given address

##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||transfer allowance fot IDs|


#### newOwner




##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|address||newOwner|


#### owner




##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|address||owner|


#### tokenIndexToApproved

new owner address


##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||new owner address|


#### tokenIndexToOwner

owner address


##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||owner address|


#### tokenMetadata

Get  NFT token metadate
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_tokenId|uint256||NFT ID to get metadata|


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|infoUrl|string|||






### State changing functions

#### acceptOwnership




##### Inputs

empty list


#### approve

approve transfer of NFT token to a new owner
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address||new owner address to be approved|
|1|_tokenId|uint256||NFT token ID to be approved|


#### balanceOf

Get number of NFT tokens for given owner address
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_owner|address||owner address|


#### cAllowance

return value that is approved for transfer


##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_owner|address||NFT token owner that approved transfer|
|1|_spender|address||NFT token owner that approved to recive the value|


#### cApprove

approve NFT token value transfer for default token ID


##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_spender|address||token owner address|
|1|_value|uint256||value to approve for transfer|


#### cApproveFrom

approve NFT token value transfer


##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_fromId|uint256||NFT token ID to transfer value|
|1|_spender|address||token owner address|
|2|_toId|uint256||NFT token ID to recieve value|
|3|_value|uint256||value to approve for transfer|


#### cBalanceOf

return balance for specific address. Note that for each address there are numner of NFT tokens.
ERC20Controller method

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_owner|address||owner address|


#### cDestroy

decrease value for NFT token


##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_from|address||address of token owner|
|1|_fromId|uint256||NFT token ID|
|2|_amount|uint256||amount to decrease|


#### cIssue

increase value for NFT token


##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address||address of token owner|
|1|_toId|uint256||NFT token ID|
|2|_amount|uint256||amount to add|


#### cTotalSupply

return total supply of issued tokens
ERC20Controller method

##### Inputs

empty list


#### cTransfer

transfer value from NFT token that belongs to sender to another one. The transfer must be approved before


##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address||value reciever address|
|1|_value|uint256||value to transfer|


#### cTransferFrom

transfer value from one NFT token to another one. The transfer must be approved before


##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_from|address||NFT owner address that approved the transfer|
|1|_to|address||value reciever address|
|2|_value|uint256||value to transfer|


#### getLevel

return current level for NFT token
ERC20Controller helper

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address||NFT token owner address|
|1|_toId|uint256||NFT token ID that|


#### increaseLevel

increase level for NFT token for one
ERC20Controller helper

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address||NFT token owner address|
|1|_toId|uint256||NFT token ID that|


#### name

return token name
ERC721 Public

##### Inputs

empty list


#### owner




##### Inputs

empty list


#### ownerOf

Get current NFT token owner address
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_tokenId|uint256||NFT token ID to get owner|


#### setLevel

set level for NFT token
ERC20Controller helper

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address||NFT token owner address|
|1|_toId|uint256||NFT token ID that|
|2|_level|uint256||level to set|


#### supportsInterface

Check if interface is supported by smart contract
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_interfaceID|bytes4||interface signature to check|


#### symbol

return token symbol
ERC721 Public

##### Inputs

empty list


#### tokensOfOwner

Get all NFT tokens for owner address
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_owner|address||NFT owner address|


#### totalSupply

Get total supply for NFT token
ERC721 Public

##### Inputs

empty list


#### transfer

transfer NFT token to new owner
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address||new owner address|
|1|_tokenId|uint256||NFT token ID to transfer|


#### transferFrom

transfer token from current owner to new one. The transfer must be approved before
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_from|address||curren owner address|
|1|_to|address||new owner address to transfer|
|2|_tokenId|uint256||NFT token ID to transfer|


#### transferOwnership




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_newOwner|address|||


#### valueOf

Get value of NFT token
ERC721 Public

##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_tokenId|uint256||NFT token ID|






### Events

#### Transfer

ERC721SmartToken Transfer event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|from|address||NFT token owner address|
|1|fromId|uint256||NFT token ID for transfer|
|2|to|address||token owner to recieve the value|
|3|toId|uint256||NFT token ID to recieve the value|
|4|value|uint256||transfered value|


#### Approval

approval event
ERC721 events

##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|owner|address||NFT token owner address|
|1|approved|address||address to approve|
|2|tokenId|uint256||NFT token ID to approve|


#### Birth

birth event
ERC721 events

##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|value|uint256||NFT token value|
|1|metadata|string||NFT token metadata|
|2|kind|uint256||NFT token kind|
|3|owner|address||NFT token owner|


#### CApproveFrom

ERC20Controller CApproveFrom event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|fromId|uint256||NFT token ID to transfer value from|
|1|spender|address||NFT token owner for fromId|
|2|toId|uint256||NFT token ID to transfer value to|
|3|value|uint256||approved value|


#### CApprove

ERC20Controller CApprove event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|spender|address||NFT token owner to recieve value|
|1|value|uint256||approved value|


#### CTransferFrom

ERC20Controller CTransferFrom event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|from|address||NFT token owner address|
|1|fromId|uint256||NFT token ID to transfer value from|
|2|to|address||NFT token owner address to recieve the value|
|3|toId|uint256||NFT token ID to recieve the value|
|4|value|uint256||transfered value|
|5|allowance|uint256||remaining allowance amount|


#### CIssue

ERC20Controller CIssue event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|to|address||NFT token owner address|
|1|toId|uint256||NFT token ID to recieve amount|
|2|amount|uint256||issued amount|


#### CDestroy

ERC20Controller CDestroy event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|from|address||NFT token owner address|
|1|fromId|uint256||NFT token ID to decrease value|
|2|amount|uint256||decreased value amount|


#### OwnerUpdate




##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_prevOwner|address|||
|1|_newOwner|address|||


#### AddValue

ERC721SmartToken AddValue event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|to|address||token owner to recieve the value|
|1|toId|uint256||NFT token ID to recieve the value|
|2|value|uint256||transfered value|


#### RemoveValue

ERC721SmartToken RemoveValue event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|from|address||NFT token owner address|
|1|fromId|uint256||NFT token ID to decrease the value|
|2|value|uint256||value to decrease|


#### SetLevel

ERC721SmartToken SetLevel event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|to|address||NFT token owner address|
|1|toId|uint256||NFT token ID to set level|
|2|level|uint256||new token level|


#### IncreaseLevel

ERC721SmartToken IncreaseLevel event


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|to|address||NFT token owner address|
|1|toId|uint256||NFT token ID to increase level|





### Enums




### Structs

#### NFT

NFT token data : value, metadata, kind, level and state


##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|value|uint256||ERC20 token value|
|1|metadata|string||NFT metadata|
|2|kind|uint256||NFT token type / kind|
|3|level|uint256||NFT token level|
|4|state|uint256||token state|




