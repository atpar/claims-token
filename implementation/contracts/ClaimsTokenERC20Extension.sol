pragma solidity ^0.5.2;

import "./math/SafeMathUint.sol";
import "./math/SafeMathInt.sol";

import "./IClaimsToken.sol";
import "./ClaimsToken.sol";


contract ClaimsTokenERC20Extension is IClaimsToken, ClaimsToken {

	using SafeMathUint for uint256;
	using SafeMathInt for int256;

	// token in which the funds can be sent to the ClaimsToken
	IERC20 public fundsToken;
	
	// balance of fundsToken that the ClaimsToken currently holds
	uint256 public fundsTokenBalance;


	modifier onlyFundsToken () {
		require(msg.sender == address(fundsToken), "UNAUTHORIZED_SENDER");
		_;
	}

	constructor(IERC20 _fundsToken) 
		public 
		ClaimsToken()
	{
		require(address(_fundsToken) != address(0), "INVALID_FUNDS_TOKEN_ADDRESS");

		fundsToken = _fundsToken;
	}

	/**
	 * @notice Withdraws all available funds for a token holder
	 */
	function withdrawFunds() 
		external 
		payable 
	{
		require(msg.value == 0, "ETHER_NOT_ACCEPTED");

		uint256 withdrawableFunds = _prepareWithdraw();
		
		require(fundsToken.transfer(msg.sender, withdrawableFunds), "TRANSFER_FAILED");

		_updateFundsTokenBalance();
	}

	/**
	 * @dev Updates the current funds token balance 
	 * and returns the difference of new and previous funds token balances
	 * @return A int256 representing the difference of the new and previous funds token balance
	 */
	function _updateFundsTokenBalance() internal returns (int256) {
		uint256 prevFundsTokenBalance = fundsTokenBalance;
		
		fundsTokenBalance = fundsToken.balanceOf(address(this));

		return int256(fundsTokenBalance).sub(int256(prevFundsTokenBalance));
	}

	/**
	 * @notice Register a payment of funds in tokens. May be called directly after a deposit is made.
	 * @dev Calls _updateFundsTokenBalance(), whereby the contract computes the delta of the previous and the new 
	 * funds token balance and increments the total received funds (cumulative) by delta by calling _registerFunds()
	 */
	function updateFundsReceived() external {
		int256 newFunds = _updateFundsTokenBalance();

		if (newFunds > 0) {
			_distributeFunds(newFunds.toUint256Safe());
		}
	}
}