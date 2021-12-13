// import {ethers} from "ethers";

const hre = require('hardhat');
const { getChainId } = hre;

async function main() {
    const [deployer] = await ethers.getSigners();

    const CyberERC20 = process.env.CYBER_TOKEN

    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Token = await ethers.getContractFactory("Token");
    const nftToken = await Token.deploy();
    console.log("Token address:", token.address);

    const LootBoxFactiry = await ethers.getContractFactory("Token");
    const boxFactory = await LootBoxFactiry.deploy(nftToken.address);
    console.log("LootBoxFactiry address:", boxFactory.address);

    const Farming = await ethers.getContractFactory("Token");
    const farming = await Farming.deploy(nftToken.address, CyberERC20);
    console.log("Farming address:", farming.address);

    const Merger = await ethers.getContractFactory("Token");
    const merger = await Merger.deploy(nftToken.address);
    console.log("Merger address:", merger.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

//https://eth-rinkeby.alchemyapi.io/v2/pfhVl9K00SonEyjVmWo-Nl3bMBIqEc_y