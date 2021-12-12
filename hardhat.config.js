require('@nomiclabs/hardhat-etherscan');
require('@nomiclabs/hardhat-truffle5');
require('dotenv').config();
require('hardhat-deploy');
require('hardhat-gas-reporter');
require('solidity-coverage');
require("@nomiclabs/hardhat-waffle");

//const ALCHEMY_API_KEY = "pfhVl9K00SonEyjVmWo-Nl3bMBIqEc_y";
//const ROPSTEN_PRIVATE_KEY = "35fbab6513e2bbe03d5496aaa4f2812abbf6d72ce7162346959d82c4901700dc";

module.exports = {
  solidity: {
    defaultNetwork: "rinkeby",
    networks: {
      rinkeby: {
        url: "https://eth-rinkeby.alchemyapi.io/v2/123abc123abc123abc123abc123abcde",
        accounts: '35fbab6513e2bbe03d5496aaa4f2812abbf6d72ce7162346959d82c4901700dc',
        gas: 2100000,
        gasPrice: 8000000000,
        saveDeployments: true,
      },
      localhost: {
        url: "http://127.0.0.1:8545"
      },
      hardhat: {
        // See its defaults
      }
    },
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000000,
      },
    },
  },
  gasReporter: {
    enable: true,
    currency: 'USD',
  },
};
