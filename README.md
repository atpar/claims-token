# Claims Token

**DRAFT IMPLEMENTATION. NOT AUDITED. DO NOT USE FOR TOKENS WITH REAL VALUE AT THIS TIME**

A token that can represent claims on any type of crypto cash flow. 

Usage examples are cash flows of assets such as dividends, loan repayments, fee or revenue shares among large numbers of token holders. Anyone can deposit funds, token holders can withdraw their claims.

Based on [EIP1726](https://github.com/ethereum/EIPs/issues/1726) and [EIP1843](https://github.com/ethereum/EIPs/issues/1843). Payments accounting based on the implementation of @roger-wu and foundational work of @arachnid.

## Main Features
- Scales to large numbers of transfers and large numbers of token holders
- Can distribute funds in Ether or ERC20 tokens
- Mintable/Burnable -> variable supply
- ERC1400 compatible

## Roadmap
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
- Claims Token base contract:
    - implements the ERC20 standard interface
    - contains methods for calculating distributions according to the amount of Claims Tokens a user owns
- Claims Token extension contracts:
    - contain methods for depositing and withdrawing funds in Ether or according to a token standard
    - provide compatibility for current and future token standards such as ERC20, ERC223, ERC777 and ERC1400.

  
