pragma solidity ^0.5.2;

import "./IClaimsToken.sol";
import "./ClaimsToken.sol";


contract ClaimsTokenETHExtension is IClaimsToken, ClaimsToken {

	/**
	 * @dev Withdraws available funds for user.
	 */
	function withdrawFunds() 
		external 
		payable 
	{
		uint256 withdrawableFunds = _prepareWithdraw();
		
		msg.sender.transfer(withdrawableFunds);
	}

	/**
	 * @dev Calls _distributeFunds(), 
	 * whereby magnifiedFundsPerShare gets updated.
	 */
	function () 
		external 
		payable 
	{
		if (msg.value > 0) {
			_distributeFunds(msg.value);
			emit FundsDistributed(msg.sender, msg.value);
		}
	}
}