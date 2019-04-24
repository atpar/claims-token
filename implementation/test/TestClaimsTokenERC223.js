const BigNumber = require('bignumber.js')

const ERC223SampleToken = artifacts.require('ERC223SampleToken')
const ClaimsTokenERC223 = artifacts.require('ClaimsTokenERC223Extension')


contract('ClaimsTokenERC223', (accounts) => {

  const ownerA = accounts[0]
  const ownerB = accounts[1]
  const ownerC = accounts[2]
  const ownerD = accounts[3]
  
  const payer = accounts[4]

  const depositAmount = 100 * 10 ** 18

  beforeEach(async () => {
    this.ERC223SampleTokenInstance = await ERC223SampleToken.new()
    this.ClaimsTokenERC223Instance = await ClaimsTokenERC223.new(ownerA, this.ERC223SampleTokenInstance.address)

    this.totalSupply = await this.ClaimsTokenERC223Instance.totalSupply() 

    await this.ClaimsTokenERC223Instance.transfer(ownerB, this.totalSupply.divn(4))
    await this.ClaimsTokenERC223Instance.transfer(ownerC, this.totalSupply.divn(4))
    await this.ClaimsTokenERC223Instance.transfer(ownerD, this.totalSupply.divn(4))    

    // first deposit
    await this.ERC223SampleTokenInstance.transfer(this.ClaimsTokenERC223Instance.address, web3.utils.toHex(depositAmount))
  })

  it('should increment <totalReceivedFunds> after deposit', async () => {
    const claimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)
    const totalReceivedFunds = await this.ClaimsTokenERC223Instance.totalReceivedFunds()

    assert.equal(claimsTokenERC223Balance.toString(), totalReceivedFunds.toString())
  })

  it('should withdraw <newFundsReceived> amount for user', async () => {
    const totalReceivedFunds = await this.ClaimsTokenERC223Instance.totalReceivedFunds()
    const preClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)

    await this.ClaimsTokenERC223Instance.withdrawFunds({ from: ownerD })

    const postClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)

    assert.equal(preClaimsTokenERC223Balance - (totalReceivedFunds / 4), postClaimsTokenERC223Balance)    
  })

  it('should withdraw <claimedToken> amount for new owner after token transfer', async () => {
    const totalReceivedFunds = await this.ClaimsTokenERC223Instance.totalReceivedFunds()
    const tokenBalanceOfOwnerA = await this.ClaimsTokenERC223Instance.balanceOf(ownerA)

    const preClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)

    await this.ClaimsTokenERC223Instance.transfer(ownerD, tokenBalanceOfOwnerA.divn(2))

    // console.log((await this.ClaimsTokenERC223Instance.claimedFunds(ownerD)).toString())
    // console.log((await this.ClaimsTokenERC223Instance.processedFunds(ownerD)).toString())

    await this.ClaimsTokenERC223Instance.withdrawFunds({ from: ownerD })

    const postClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)

    assert.equal(preClaimsTokenERC223Balance - (totalReceivedFunds / 4), postClaimsTokenERC223Balance)    
  })

  it('should withdraw <claimedFunds> amount for previous owner after token transfer', async () => {
    const totalReceivedFunds = await this.ClaimsTokenERC223Instance.totalReceivedFunds()
    const tokenBalanceOfOwnerA = await this.ClaimsTokenERC223Instance.balanceOf(ownerA)

    const preClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)

    await this.ClaimsTokenERC223Instance.transfer(ownerD, tokenBalanceOfOwnerA.divn(2))
    await this.ClaimsTokenERC223Instance.withdrawFunds({ from: ownerA })

    const postClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)

    assert.equal(preClaimsTokenERC223Balance - (totalReceivedFunds / 4), postClaimsTokenERC223Balance)    
  })

  it('should withdraw <claimedFunds> + <newFundsReceived> amount for user after token transfer and second deposit', async () => {
    const tokenBalanceOfOwnerA = await this.ClaimsTokenERC223Instance.balanceOf(ownerA)
    const preClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)
    const preTotalReceivedFunds = await this.ClaimsTokenERC223Instance.totalReceivedFunds()

    await this.ClaimsTokenERC223Instance.transfer(ownerD, tokenBalanceOfOwnerA.divn(2))

    // second deposit
    await this.ERC223SampleTokenInstance.transfer(this.ClaimsTokenERC223Instance.address, web3.utils.toHex(depositAmount))

    await this.ClaimsTokenERC223Instance.withdrawFunds({ from: ownerD })

    const postClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)

    const claimedFunds = preTotalReceivedFunds / 4
    const newReceivedFundsFraction = depositAmount / 4 + (depositAmount / 4) / 2
  
    assert.equal((Number(preClaimsTokenERC223Balance) + depositAmount) - (claimedFunds + newReceivedFundsFraction), postClaimsTokenERC223Balance)    
  })

  it('should withdraw <claimedFunds> + <newFundsReceived> for user after token transfers from multiple parties and second deposit', async () => {
    const preClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)
    
    const tokenBalanceOfOwnerA = await this.ClaimsTokenERC223Instance.balanceOf(ownerA)
    const tokenBalanceOfOwnerB = await this.ClaimsTokenERC223Instance.balanceOf(ownerB)
    const tokenBalanceOfOwnerC = await this.ClaimsTokenERC223Instance.balanceOf(ownerC)
    const tokenBalanceOfOwnerD = await this.ClaimsTokenERC223Instance.balanceOf(ownerD)

    await this.ClaimsTokenERC223Instance.transfer(ownerA, tokenBalanceOfOwnerB.divn(2), { from: ownerB }) // 12.5
    await this.ClaimsTokenERC223Instance.transfer(ownerA, tokenBalanceOfOwnerC.divn(3), { from: ownerC }) // 8.33333333333333
    
    const expectedPreTokenBalanceOfOwnerA = tokenBalanceOfOwnerA.add(tokenBalanceOfOwnerB.divn(2).add(tokenBalanceOfOwnerC.divn(3)))

    // second deposit
    await this.ERC223SampleTokenInstance.transfer(this.ClaimsTokenERC223Instance.address, web3.utils.toHex(depositAmount))


    await this.ClaimsTokenERC223Instance.transfer(ownerA, tokenBalanceOfOwnerD.divn(4), { from: ownerD }) // 6.25

    await this.ClaimsTokenERC223Instance.withdrawFunds({ from: ownerA })

    const expectedFractionOfTotalSupplyOfOwnerA = new BigNumber(expectedPreTokenBalanceOfOwnerA).div(this.totalSupply)
    const expectedAmountWithdrawnByOwnerA = new BigNumber(depositAmount).dividedBy(4).plus(expectedFractionOfTotalSupplyOfOwnerA.multipliedBy(depositAmount))
    const expectedPostClaimsERC223Balance = new BigNumber(depositAmount).plus(preClaimsTokenERC223Balance).minus(expectedAmountWithdrawnByOwnerA)

    const postClaimsTokenERC223Balance = await this.ERC223SampleTokenInstance.balanceOf(this.ClaimsTokenERC223Instance.address)

    assert.equal(expectedPostClaimsERC223Balance.toString(), postClaimsTokenERC223Balance)
  })
})