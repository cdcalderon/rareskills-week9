# Solidity Challenge: Drain Tokens with a Reentrancy Attack

This challenge revolves around exploiting a reentrancy vulnerability in a contract to drain all the tokens.

## Contracts Overview

- `RewardToken`: An ERC20 token contract with a maximum cap of 1000 tokens, initially minting 100 tokens to the depositor.
- `NftToStake`: An ERC721 token contract, minting one NFT to the attacker.
- `Depositoor`: A contract that allows a user to stake their NFT to earn rewards from the `RewardToken` contract.

## Vulnerability Details

The problem is in the `Depositoor` contract, particularly in the `withdrawAndClaimEarnings` function. What this function does is it first gives out the RewardToken rewards to the person who staked their NFT. After that, it uses `safeTransferFrom` to send the staked NFT back. In the end, it removes the record of the staker's stake.

The problem happens because s`afeTransferFrom `can run any piece of code and may end up running the `onERC721Received` function on the attacker's contract. And because `safeTransferFrom` is called before the stakes entry is deleted, this creates a chance for what's known as a reentrancy attack.

## Exploitation Steps

1. In the attacker contract (`RewardTokenAttacker`), the attacker stakes their NFT in the `Depositoor` contract using the `deposit` function. This function approves the `Depositoor` contract to move the attacker's NFT, then calls `safeTransferFrom` to transfer the NFT to the `Depositoor` contract.

2. After a period (for example, 5 days), allowing significant reward to accrue, the attacker calls the `attack` function. This function triggers `withdrawAndClaimEarnings` on the `Depositoor` contract, initiating the payout and the transfer of the NFT back to the attacker.

3. The call to `safeTransferFrom` triggers `onERC721Received` in the `RewardTokenAttacker` contract, as it is the receiver of the NFT. This function immediately calls `claimEarnings` on the `Depositoor` contract. Because the `stakes` entry has not been deleted yet, this results in a second payout.

4. `Depositoor` then resumes the execution of `withdrawAndClaimEarnings`, deleting the `stakes` entry. However, by this time, the attacker has already received double the rewards.

## Test Script

```javascript
it("conduct your attack here", async function () {
  // Call the deposit function in the attacker contract.
  const depositTx = await attackerContract
    .connect(attackerWallet)
    .depositNFT(
      NFTToStakeContract.address,
      depositoorContract.address,
      rewardTokenContract.address
    );
  await depositTx.wait();

  // Increase the time by 5 days to simulate reward accumulation.
  await ethers.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]);
  await ethers.provider.send("evm_mine");

  // Trigger the exploit function in the attacker contract, effectively executing the reentrancy attack and withdrawing double the amount.
  const attackTx = await attackerContract
    .connect(attackerWallet)
    .triggerExploit(
      NFTToStakeContract.address,
      depositoorContract.address,
      rewardTokenContract.address
    );
  await attackTx.wait();
});
```
