# ERC721SmartToken
ERC721 token with ERC20 adapter

ERC721SmartToken contract implements non-fungible tokens based on ERC721 standard 
that also supports ERC20 interface. The main idea is to create a token that can be both non-fungible and has transferable value. 

Inside ERC721 contract each not fungible token represented as a structure where there is a member element called ‘value’. 
This element holds ERC20 token inside ERC721 token. 

To work with ERC721 token as normal ERC20 token we need to create a ERC20Adapter that implements standard ERC20 methods, 
as for example, balanceOf(address _owner). But in our case due to ERC721 structure for each _owner there can be many 
non-fungible tokens belong to this particular address. To select particular token for ERC20 compatible operations like 
transfer token value to another address we need to implement new methods that will accept address and token ID as parameters.


