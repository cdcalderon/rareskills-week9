const { expect } = require("chai");
const { ethers, deployments } = require("hardhat");

let accounts;
let eoa;
let challenge;
let tx;

before(async () => {
  accounts = await ethers.getSigners();
  [eoa] = accounts;

  const ChallengeFactory = await ethers.getContractFactory("Vault");

  // Deploy the contract with a password of our choosing
  const password = ethers.utils.formatBytes32String("secret");
  challenge = await ChallengeFactory.deploy(password);
  await challenge.deployed();
});

it("solves the challenge", async function () {
  // Read password from storage
  // Password is at storage slot 1
  const password = await eoa.provider.getStorageAt(challenge.address, 1);
  console.log(
    `password = ${password} "${Buffer.from(password.slice(2), `hex`)}"`
  );

  tx = await challenge.unlock(password);
  await tx.wait();
  expect(await challenge.locked()).to.equal(false);
});

after(async () => {
  // Check if the vault is unlocked after the tests
  expect(await challenge.locked(), "vault is still locked").to.equal(false);
});
