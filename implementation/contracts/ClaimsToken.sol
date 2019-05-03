pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./math/SafeMathUint.sol";
import "./math/SafeMathInt.sol";

import "./IClaimsToken.sol";


/// @title Claims Token
/// @author Johannes Escherich
/// @author Johannes Pfeffer
/// @dev A  mintable token that can represent claims on cash flow of arbitrary assets such as dividends, loan repayments, 
///   fee or revenue shares among large numbers of token holders. Anyone can deposit funds, token holders can withdraw their claims.
///   Supports funds paid in Ether or an ERC20 token. Extensible to support standards like ERC777 or ERC223.
///   This file implements the base accounting. Extensions implement Ether or token specific functionality.
///   Based on EIP1726 and EIP1843. Payments accounting based on the implementation of @roger-wu and foundational work of @arachnid

contract ClaimsToken is IClaimsToken, ERC20Mintable {

	using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

	uint256 constant internal magnitude = 2**128; // optimize, see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
	uint256 internal magnifiedFundsPerShare; // use points terminology

	mapping(address => int256) internal magnifiedFundsCorrection;
  mapping(address => uint256) internal withdrawnFunds;


	// distributeDividends
  /// @notice Distributes received funds proportionally
  function _distributeFunds(uint256 value) internal {
    require(totalSupply() > 0);

    if (value > 0) {
      magnifiedFundsPerShare = magnifiedFundsPerShare.add(
        value.mul(magnitude) / totalSupply()
      );
      emit FundsDistributed(msg.sender, value);
    }
  }

	// withdrawDividend
  /// @notice Prepares funds withdrawal
	function _prepareWithdraw() internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableFundsOf(msg.sender);
	
    withdrawnFunds[msg.sender] = withdrawnFunds[msg.sender].add(_withdrawableDividend);
    
		emit FundsWithdrawn(msg.sender, _withdrawableDividend);

		return _withdrawableDividend;
  }

  // withdrawableDividendOf
  /// @notice View the amount of funds that an address can withdraw.
  function withdrawableFundsOf(address _owner) public view returns(uint256) {
    return accumulativeFundsOf(_owner).sub(withdrawnFunds[_owner]);
  }
  
  // withdrawnDividendOf
  /// @notice View the amount of funds that an address has withdrawn.
  function withdrawnFundsOf(address _owner) public view returns(uint256) {
    return withdrawnFunds[_owner];
  }

  // accumulativeDividendOf
  /// @notice View the amount of funds that an address has earned in total.
  function accumulativeFundsOf(address _owner) public view returns(uint256) {
    return magnifiedFundsPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedFundsCorrection[_owner]).toUint256Safe() / magnitude;
  }

  /// @dev Internal function that transfer tokens from one address to another.
  function _transfer(address from, address to, uint256 value) internal {
    super._transfer(from, to, value);

    int256 _magCorrection = magnifiedFundsPerShare.mul(value).toInt256Safe();
    magnifiedFundsCorrection[from] = magnifiedFundsCorrection[from].add(_magCorrection);
    magnifiedFundsCorrection[to] = magnifiedFundsCorrection[to].sub(_magCorrection);
  }

  /// @dev Internal function that mints tokens to an account.
  function _mint(address account, uint256 value) internal {
    super._mint(account, value);

    magnifiedFundsCorrection[account] = magnifiedFundsCorrection[account]
      .sub( (magnifiedFundsPerShare.mul(value)).toInt256Safe() );
  }
  
  /// @dev Internal function that burns an amount of the token of a given account.
  function _burn(address account, uint256 value) internal {
    super._burn(account, value);

    magnifiedFundsCorrection[account] = magnifiedFundsCorrection[account]
      .add( (magnifiedFundsPerShare.mul(value)).toInt256Safe() );
  }
}