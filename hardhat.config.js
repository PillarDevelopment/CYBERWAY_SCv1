require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require('hardhat-deploy');
require('hardhat-abi-exporter');
require("@nomiclabs/hardhat-etherscan");

const {PROD_PRIVATE_KEY, TEST_PRIVATE_KEY,ETHERSCAN_API_KEY} = process.env;

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


module.exports = {
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000000,
      },
    },
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    bsctestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      accounts: [`${TEST_PRIVATE_KEY}`],
      chainId: 97,
      saveDeployments: true,
      gasMultiplier: 2
    },
    bsc: {
      url: 'https://bsc-dataseed.binance.org/',
      accounts: [`${PROD_PRIVATE_KEY}`],
      chainId: 56,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
      gasMultiplier: 2
    }
  },
  gasReporter: {
    enable: true,
    currency: 'USD',
    showTimeSpent: true,
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },

};
