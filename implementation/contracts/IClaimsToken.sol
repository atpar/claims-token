pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


interface IClaimsToken {

	/**
	 * @dev Returns the amount of funds a given address is able to withdraw currently.
	 * @param owner Address of ClaimsToken holder
	 * @return A uint256 representing the available funds for a given account
	 */
	function withdrawableFundsOf(address owner) external view returns (uint256);

	/**
	 * @dev Withdraws available funds for user.
	 */
	function withdrawFunds() external payable;

	/**
	 * @dev This event emits when new funds are getting distributed
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