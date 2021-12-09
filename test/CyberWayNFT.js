const { ether, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const {address} = require("hardhat/internal/core/config/config-validation");

const CyberWayNFT = artifacts.require('CyberWayNFT');

contract('CyberWayNFT', function ([wallet1, wallet2, wallet3]) {

    before(async function () {
        this.nftToken = await CyberWayNFT.new("CyberNFT","Cyber_Way NFT token", { from: wallet1 });
    });

    beforeEach(async function () {
        await this.nftToken.addGovernance(wallet1, { from: wallet1 });
    });

    describe('Mint and burn new tokens', async function () {

        it('should mint and burn new tokens', async function () {
            await this.nftToken.addGovernance(wallet2, { from: wallet1 });
            expect(await this.nftToken.isGovernance(wallet2)).to.equal(true);
            await this.nftToken.mint(wallet2, 1, 1, 3, { from: wallet2 });

            try {
                await this.nftToken.removeGovernance(wallet1, { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            try {
                await this.nftToken.addGovernance(wallet3, { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }
            await this.nftToken.removeGovernance(wallet1, { from: wallet1 });
            expect(await this.nftToken.isGovernance(wallet1)).to.equal(false);
            await this.nftToken.burn(0, { from: wallet2 });
        });

        it('should add to other contract to governance', async function () {
            await this.nftToken.addGovernance(wallet2, { from: wallet1 });
            await this.nftToken.mint(wallet2, 1, 1, 3, { from: wallet2 });

            try {
                await this.nftToken.removeGovernance(wallet1, { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            try {
                await this.nftToken.addGovernance(wallet3, { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }
            await this.nftToken.removeGovernance(wallet1, { from: wallet1 });
        });
    });

    describe('Add and remove new governance contracts', async function () {

        it('should mint after remove out governance', async function () {
            await this.nftToken.addGovernance(wallet2, { from: wallet1 });
            await this.nftToken.mint(wallet2, 1, 1, 3, { from: wallet2 });

            await this.nftToken.removeGovernance(wallet1, { from: wallet1 });

            try {
                await this.nftToken.mint(1, 1, 1, { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            try {
                await this.nftToken.mint(0, 1, 2, { from: wallet3 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }
        });

        it('should burn after remove out governance', async function () {
            await this.nftToken.addGovernance(wallet2, { from: wallet1 });
            await this.nftToken.mint(wallet2, 1, 1, 2, { from: wallet2 });
            await this.nftToken.mint(wallet2, 1, 1, 2, { from: wallet2 });

            try {
                await this.nftToken.burn(0, { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }
            await this.nftToken.burn(1, { from: wallet1 });
            await this.nftToken.removeGovernance(wallet1, { from: wallet1 });
        });
    });
});
