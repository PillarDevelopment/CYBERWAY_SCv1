const hre = require("hardhat");
const { ethers, upgrades, artifacts} = require("hardhat");
const NAME = "CYBER_NFT";
const SYMBOL = "CBRNF";
const CYBER_TOKEN = "0x869B409437ECF2cB7a5Fe9116E3a3d9E1ebe7F5D";

async function main() {
    console.log('Running deploy script');

    const nftFactory = await hre.ethers.getContractFactory("CyberWayNFT");
    const lootBoxFactory = await hre.ethers.getContractFactory("LootBoxFactory");
    const mergerFactory = await hre.ethers.getContractFactory("Merger");
    const farmingFactory = await hre.ethers.getContractFactory("Farming");

    // deploy NFT
    const nft = await nftFactory.deploy(NAME,SYMBOL);
    await nft.deployed();
    console.log("CyberWayNFT deployed to:", nft.address);

    // deploy LootBoxFactory
    const lootBox = await lootBoxFactory.deploy(nft.address);
    await lootBox.deployed();
    console.log("LootBoxFactory deployed to:", lootBox.address);

    // deploy Merger
    const merger = await mergerFactory.deploy(nft.address);
    await merger.deployed();
    console.log("Merger deployed to:", merger.address);

    // deploy Farming
    const farming = await farmingFactory.deploy(nft.address, CYBER_TOKEN);
    await farming.deployed();
    console.log("Farming deployed to:", farming.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
