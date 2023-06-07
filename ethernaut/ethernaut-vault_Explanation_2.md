## The Vulnerability

In Ethereum, the term `private` is somewhat misleading. While it restricts other contracts from accessing a variable directly, it doesn't hide or encrypt data from the blockchain. This means that our password, though marked private, is not really private. Anyone can view it.

# Exploiting the Vulnerability

So how can we access this 'private' password? We can do this by directly accessing the blockchain storage. In Ethereum, each contract's storage is essentially an open book, with every variable neatly placed at a specific storage slot. The password here is stored at storage slot 1. Using web3.js or ethers.js, we can directly retrieve the password.

The function `getStorageAt(contract.address, 1)` retrieves the password from the blockchain.
