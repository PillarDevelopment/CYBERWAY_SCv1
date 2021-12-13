require('@nomiclabs/hardhat-etherscan');
require('@nomiclabs/hardhat-truffle5');
require('dotenv').config();
require('hardhat-deploy');
require('hardhat-gas-reporter');
require('solidity-coverage');
require("@nomiclabs/hardhat-waffle");

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const PROD_PRIVATE_KEY = process.env.PROD_PRIVATE_KEY;

module.exports = {
  solidity: {
    defaultNetwork: "rinkeby",
    networks: {
      rinkeby: {
        url: "https://eth-rinkeby.alchemyapi.io/v2/" + ALCHEMY_API_KEY,
        accounts: PROD_PRIVATE_KEY,
        gas: 2100000,
        gasPrice: 8000000000,
        saveDeployments: true,
      },
      localhost: {
        url: "http://127.0.0.1:8545"
      },
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
    showTimeSpent: true,
  },
};
