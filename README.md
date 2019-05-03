# Claims Token

* DRAFT IMPLEMENTATION. NOT AUDITED. DO NOT USE FOR TOKENS WITH REAL VALUE AT THIS TIME *

A token that can represent claims on any type of crypto cash flow. 

Usage examples are cash flows of assets such as dividends, loan repayments, fee or revenue shares among large numbers of token holders. Anyone can deposit funds, token holders can withdraw their claims.

Based on [EIP1726](https://github.com/ethereum/EIPs/issues/1726) and [EIP1843](https://github.com/ethereum/EIPs/issues/1843). Payments accounting based on the implementation of @roger-wu and foundational work of @arachnid.

## Main Features
- Scales to large numbers of transfers and large numbers of token holders
- Can distribute funds in Ether or ERC20 tokens
- Mintable/Burnable -> variable supply
- ERC1400 compatible

## Roadmap
- Multi-token support (payments in multiple tokens can be distributed among token holders)
- Create ERC1400 module
- ERC777 support
- Propose EIP

## Interface
```solidity
pragma solidity ^0.5.2;


interface IClaimsToken is IERC20 {

	/**
	 * @dev Returns the total amount of funds a given address is able to withdraw currently.
	 * @param owner Address of ClaimsToken holder
	 * @return A uint256 representing the available funds for a given account
	 */
	function withdrawableFundsOf(address owner) external view returns (uint256);

	/**
	 * @dev Withdraws all available funds for a claims token holder.
	 */
	function withdrawFunds() external payable;

	/**
	 * @dev This event emits when new funds are distributed
	 * @param by the address of the sender who distributed funds
	 * @param fundsDistributed contains the amount of funds received for distribution
	 */
	event FundsDistributed(address indexed by, uint256 fundsDistributed);

	/**
	 * @dev This event emits when distributed funds are withdrawn by a token holder.
	 * @param by contains the address of the receiver of funds
	 * @param fundsWithdrawn contains the amount of funds that were withdrawn
	 */
	event FundsWithdrawn(address indexed by, uint256 fundsWithdrawn);
}
```

## Architecture
- Claims Token base contract
    - contains methods for calculating distributions according to the amount of Claims Tokens a user owns
- Claims Token extension contracts
    - contains specific methods for depositing and withdrawing tokens

### Flavors
1. **Single Token Claims Token**
    - one time instantiation of Claims Token contract with ETH / ERC20
2. **Multi Token Claims Token**
    - multiple tokens (ETH / ERC20) can be distributed through this contract at the same time
    - new tokens can be added or removed during the lifecycle of the Claims Token contract

### Claims Token Extensions
- define how depositing and withdrawing is handled
- compatibility for different token standards (ERC20, ERC223, ERC777, ERC1400)

