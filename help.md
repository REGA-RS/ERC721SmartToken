












# ERC721SmartToken

### ERC721SmartToken contract implements non-fungible tokens based on ERC721 standard that also supports ERC20 interface.



## Functions



### Constant functions

#### allowance




##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||allowance|


#### allowanceAmt




##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||allowanceAmt|


#### allowanceIds




##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||allowanceIds|


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




##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||tokenIndexToApproved|


#### tokenIndexToOwner




##### Inputs

empty list


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|return0|[object Object]||tokenIndexToOwner|


#### tokenMetadata




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_tokenId|uint256|||


##### Returns

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|infoUrl|string|||






### State changing functions

#### acceptOwnership




##### Inputs

empty list


#### approve




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address|||
|1|_tokenId|uint256|||


#### balanceOf




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_owner|address|||


#### cAllowance




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_owner|address|||
|1|_spender|address|||


#### cApprove




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_spender|address|||
|1|_value|uint256|||


#### cApproveFrom




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_fromId|uint256|||
|1|_spender|address|||
|2|_toId|uint256|||
|3|_value|uint256|||


#### cBalanceOf

return balance for specific address. Note that for each address there are numner of NFT tokens


##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_owner|address||The owner address|


#### cDestroy




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_from|address|||
|1|_fromId|uint256|||
|2|_amount|uint256|||


#### cIssue




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address|||
|1|_toId|uint256|||
|2|_amount|uint256|||


#### cTotalSupply

ERC20Controller methods


##### Inputs

empty list


#### cTransfer




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address|||
|1|_value|uint256|||


#### cTransferFrom




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_from|address|||
|1|_to|address|||
|2|_value|uint256|||


#### getLevel




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address|||
|1|_toId|uint256|||


#### increaseLevel




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address|||
|1|_toId|uint256|||


#### name




##### Inputs

empty list


#### owner




##### Inputs

empty list


#### ownerOf




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_tokenId|uint256|||


#### setLevel




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address|||
|1|_toId|uint256|||
|2|_level|uint256|||


#### supportsInterface




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_interfaceID|bytes4|||


#### symbol




##### Inputs

empty list


#### tokensOfOwner




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_owner|address|||


#### totalSupply




##### Inputs

empty list


#### transfer




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_to|address|||
|1|_tokenId|uint256|||


#### transferFrom




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_from|address|||
|1|_to|address|||
|2|_tokenId|uint256|||


#### transferOwnership




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_newOwner|address|||


#### valueOf




##### Inputs

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_tokenId|uint256|||






### Events

#### Transfer




##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|from|address|||
|1|to|address|||
|2|tokenId|uint256|||


#### Approval




##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|owner|address|||
|1|approved|address|||
|2|tokenId|uint256|||


#### Birth




##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|value|uint256|||
|1|metadata|string|||
|2|kind|uint256|||
|3|owner|address|||


#### OwnerUpdate




##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|_prevOwner|address|||
|1|_newOwner|address|||





### Enums




### Structs

#### NFT




##### Params

|#  |Param|Type|TypeHint|Description|
|---|-----|----|--------|-----------|
|0|value|uint256|||
|1|metadata|string|||
|2|kind|uint256|||
|3|level|uint256|||
|4|state|uint256|||




