const ClaimsToken = artifacts.require('ClaimsTokenETHExtension')

contract('ClaimsTokenETH', (accounts) => {

  const ownerA = accounts[0]
  const ownerB = accounts[1]
  
  const payer = accounts[4]

  const depositAmount = 3

  before(async () => {
    this.ClaimsTokenInstance = await ClaimsToken.new(ownerA)
    this.totalSupply = await this.ClaimsTokenInstance.totalSupply()

    await this.ClaimsTokenInstance.transfer(ownerB, this.totalSupply.divn(2))
  })

  it('should', async () => {
    await web3.eth.sendTransaction({
      from: payer,
      to: this.ClaimsTokenInstance.address,
      value: depositAmount
    })

    await this.ClaimsTokenInstance.withdrawFunds({ from: ownerA })
    await this.ClaimsTokenInstance.withdrawFunds({ from: ownerB })

    const preLostFunds = await this.ClaimsTokenInstance.lostFunds()
    console.log(preLostFunds.toString())

    const preClaimsTokenBalance = await web3.eth.getBalance(this.ClaimsTokenInstance.address)
    console.log(preClaimsTokenBalance)

    await web3.eth.sendTransaction({
      from: payer,
      to: this.ClaimsTokenInstance.address,
      value: depositAmount
    })

    await this.ClaimsTokenInstance.withdrawFunds({ from: ownerA })
    await this.ClaimsTokenInstance.withdrawFunds({ from: ownerB })

    const postLostFunds = await this.ClaimsTokenInstance.lostFunds()
    console.log(postLostFunds.toString())

    const postClaimsTokenBalance = await web3.eth.getBalance(this.ClaimsTokenInstance.address)
    console.log(postClaimsTokenBalance)

    assert.isFalse(true)
  })
})