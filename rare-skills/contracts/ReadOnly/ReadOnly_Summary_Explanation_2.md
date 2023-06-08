## DeFi Contract Exploit Explanation

The vulnerability we're dealing with here is a `timing attack` between the `removeLiquidity` function of `ReadOnlyPool` and the `snapshotPrice` function of `VulnerableDeFiContract`. This is a classic example of a `reentrancy-like` attack, but not in the direct sense, as we'll see in a moment.

# Exploit

The attacker deploys a `PoolAttacker` contract, which initially deposits some ETH into `ReadOnlyPool`. When the attack function is called, it triggers the `removeLiquidity` function, withdrawing the initial deposit. This withdrawal then triggers the `receive` function in `PoolAttacker`, which calls the `snapshotPrice` function in `VulnerableDeFiContract`. The key here is the timing of this call. It captures the `LP token price` at a time when the ETH has been withdrawn but the corresponding LP tokens have not been burned yet.

```solidity
function removeLiquidity() external nonReentrant {
    uint256 numLPTokens = balanceOf(msg.sender);
    uint256 totalLPTokens = totalSupply();
    uint256 profitShare = (numLPTokens + totalLPTokens) / totalLPTokens;
    uint256 ethToReturn = originalStake[msg.sender] * profitShare;

    (bool ok, ) = msg.sender.call{value: ethToReturn}("");
    require(ok, "eth transfer failed");

    // Here's where the timing issue occurs: the ETH has been transferred,
    // but the sender's LP tokens haven't been burned yet.
    _burn(msg.sender, numLPTokens);
}

```

In the `removeLiquidity` function, after the contract has calculated the share of profits and attempted to transfer the ETH, the msg.sender's LP tokens are yet to be burned."

```solidity
function attack() external {
    pool.removeLiquidity();
}

receive() external payable {
    target.snapshotPrice();
}
```

The `PoolAttacker` contract, upon triggering the attack function, calls the removeLiquidity function in the `ReadOnlyPool` contract. This withdrawal then triggers the receive function in `PoolAttacker`, which calls snapshotPrice function in `VulnerableDeFiContract`. It captures the LP token price at a time when the ETH has been withdrawn but the corresponding LP tokens have not been burned yet."

# Effect of the exploit

The consequence of this timing manipulation is that an inflated LP token price is captured in `VulnerableDeFiContract`. This could allow an attacker to sell their LP tokens at this inflated price before the market adjusts, potentially causing other users to suffer a loss.

It's important to mention that the `ReadOnlyPool` contract uses the `ReentrancyGuard` modifier, which is meant to prevent reentrancy attacks. However, it does not prevent this particular exploit, because the `PoolAttacker` contract makes an external call to `VulnerableDeFiContract`, not directly back to the `ReadOnlyPool`.
