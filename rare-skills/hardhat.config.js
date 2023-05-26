require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.16" },
      { version: "0.8.15" },
      { version: "0.8.13" },
      { version: "0.8.0" },
      { version: "0.7.3" },
    ],
  },
};
