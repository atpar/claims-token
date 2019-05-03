pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./math/SafeMathUint.sol";
import "./math/SafeMathInt.sol";

import "./IClaimsToken.sol";


contract ClaimsToken is IClaimsToken, ERC20Mintable {

	using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

	uint256 constant internal magnitude = 2**128;
	uint256 internal magnifiedFundsPerShare;

	mapping(address => int256) internal magnifiedFundsCorrection;
  mapping(address => uint256) internal withdrawnFunds;


	// distributeDividends
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
	function _prepareWithdraw() internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableFundsOf(msg.sender);
	
    withdrawnFunds[msg.sender] = withdrawnFunds[msg.sender].add(_withdrawableDividend);
    
		emit FundsWithdrawn(msg.sender, _withdrawableDividend);

		return _withdrawableDividend;
  }

  // withdrawableDividendOf
  function withdrawableFundsOf(address _owner) public view returns(uint256) {
    return accumulativeFundsOf(_owner).sub(withdrawnFunds[_owner]);
  }
  
  // withdrawnDividendOf
  function withdrawnFundsOf(address _owner) public view returns(uint256) {
    return withdrawnFunds[_owner];
  }

  // accumulativeDividendOf
  function accumulativeFundsOf(address _owner) public view returns(uint256) {
    return magnifiedFundsPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedFundsCorrection[_owner]).toUint256Safe() / magnitude;
  }

  function _transfer(address from, address to, uint256 value) internal {
    super._transfer(from, to, value);

    int256 _magCorrection = magnifiedFundsPerShare.mul(value).toInt256Safe();
    magnifiedFundsCorrection[from] = magnifiedFundsCorrection[from].add(_magCorrection);
    magnifiedFundsCorrection[to] = magnifiedFundsCorrection[to].sub(_magCorrection);
  }

  function _mint(address account, uint256 value) internal {
    super._mint(account, value);

    magnifiedFundsCorrection[account] = magnifiedFundsCorrection[account]
      .sub( (magnifiedFundsPerShare.mul(value)).toInt256Safe() );
  }

  function _burn(address account, uint256 value) internal {
    super._burn(account, value);

    magnifiedFundsCorrection[account] = magnifiedFundsCorrection[account]
      .add( (magnifiedFundsPerShare.mul(value)).toInt256Safe() );
  }
}