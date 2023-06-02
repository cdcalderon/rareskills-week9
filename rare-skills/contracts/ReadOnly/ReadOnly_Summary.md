# DeFi Contract Exploit Explanation

This DeFi challenge involves two contracts, `ReadOnlyPool` and `VulnerableDeFiContract`, and a contract `PoolAttacker` that exploits a vulnerability between them.

## The Vulnerability

The vulnerability lies in a timing attack between the `removeLiquidity` function of `ReadOnlyPool` and the `snapshotPrice` function of `VulnerableDeFiContract`.

## The Exploit

When the `PoolAttacker` contract is deployed with some ETH, it deposits this ETH into `ReadOnlyPool`. On invoking the `attack` function, it triggers `removeLiquidity` in `ReadOnlyPool`, withdrawing the initially deposited ETH.

This withdrawal then invokes the fallback `receive` function in `PoolAttacker`, which calls `snapshotPrice` in `VulnerableDeFiContract`. The timing of this call captures the LP token price at a point when the ETH has been withdrawn but the corresponding LP tokens are not burned yet. This manipulation sets an incorrect LP token price in `VulnerableDeFiContract`.

## Conclusion

This exploit is a classic example of a reentrancy attack that leverages the timing of transactions and manipulates the function call order to exploit the DeFi contracts.
