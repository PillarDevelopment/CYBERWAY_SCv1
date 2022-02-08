const hre = require("hardhat");
const { ethers, upgrades, artifacts} = require("hardhat");
const NAME = "CYBER_TOKEN";
const SYMBOL = "CBRT";


async function main() {
    console.log('Running deploy script');

    const tokenFactory = await hre.ethers.getContractFactory("TokenMock");


    // deploy TokenMOCK
    const token = await tokenFactory.deploy(NAME,SYMBOL);
    await token.deployed();
    console.log("TokenMOCK deployed to:", token.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
