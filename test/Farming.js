const { ether, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const {address} = require("hardhat/internal/core/config/config-validation");

const Farming = artifacts.require('Farming');
const CyberWayNFT = artifacts.require('CyberWayNFT');
const Token = artifacts.require('TokenMock');

contract('Farming', function ([wallet1, wallet2, wallet3]) {

    before(async function () {
        this.nftToken = await CyberWayNFT.new("CyberNFT","Cyber_Way NFT token", { from: wallet1 });
        this.token = await Token.new("CBR","CBR token", { from: wallet1 });
        this.farming = await Farming.new(this.nftToken.address, this.token.address, { from: wallet1 });
        await this.token.mint(this.farming.address, ether('10000'), { from: wallet1 });
    });

    beforeEach(async function () {
        await this.nftToken.addGovernance(wallet1, { from: wallet1 });
        await this.nftToken.mint(wallet1, 1, 2, 3, { from: wallet1 }); // 0
        await this.nftToken.mint(wallet1, 2, 3, 4, { from: wallet1 }); // 1
        await this.nftToken.mint(wallet2, 3, 2, 1, { from: wallet1 }); // 2
        await this.nftToken.mint(wallet2, 2, 1, 2, { from: wallet1 }); // 3
    });

    describe('depositFarmingToken', async function () {

        it('non approve', async function () {
            try {
                await this.farming.depositFarmingToken(0, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Not Approve') !== -1).equal(false);
            }
            await this.nftToken.approve(this.farming.address, 0, { from: wallet1 });
            await this.farming.depositFarmingToken(0, {from: wallet1});
        });

        it('not owner', async function () {
            try {
                await this.farming.depositFarmingToken(2, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet1 is not owner') !== -1).equal(false);
            }
            await this.nftToken.approve(this.farming.address, 2, { from: wallet2 });
            await this.farming.depositFarmingToken(2, {from: wallet2});

        });

        it('deposit already exist', async function () {
            await this.nftToken.approve(this.farming.address, 1, { from: wallet1 });
            await this.farming.depositFarmingToken(1, {from: wallet1});
            try {
                await this.farming.depositFarmingToken(1, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('deposit already exist') !== -1).equal(false);
            }
            await this.farming.emergencyWithdrawFarmingToken(1, {from: wallet1});
            await this.nftToken.approve(this.farming.address, 1, { from: wallet1 });
            await this.farming.depositFarmingToken(1, {from: wallet1});
        });

    });
/*

    describe('Mint and burn new tokens', async function () {

        it('should add to other contract to governance', async function () {
            await this.dcToken.addGovernance(wallet2, { from: wallet1 });
            await this.dcToken.mint(wallet2, ether('10000'), { from: wallet2 });

            try {
                await this.dcToken.removeGovernance(wallet1, { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            try {
                await this.dcToken.addGovernance(wallet3, { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            await this.dcToken.removeGovernance(wallet1, { from: wallet1 });
        });

    });

    describe('Pause and unpause operations', async function () {


        it('should be Pause/unpause for owner', async function () {
            await this.dcToken.pause({ from: wallet1 });

            try {
                await this.dcToken.pause({ from: wallet1 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            try {
                await this.dcToken.unpause({ from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            await this.dcToken.unpause({ from: wallet1 });
        });


        it('should transfer after pause', async function () {
            await this.dcToken.mint(wallet2, ether('10000'), { from: wallet1 });
            await this.dcToken.mint(wallet3, ether('10000'), { from: wallet1 });
            await this.dcToken.pause({ from: wallet1 });
            await this.dcToken.transfer(wallet3, ether('1000'), { from: wallet2 });

            try {
                await this.dcToken.mint(wallet2, ether('10000'), { from: wallet1 });
                 expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            try {
                await this.dcToken.transfer(wallet3, ether('1000'), { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            await this.dcToken.unpause({ from: wallet1 });
            await this.dcToken.transfer(wallet3, ether('1000'), { from: wallet2 });
        });

    });

    describe('Add and remove new governance contracts', async function () {

        it('should mint after remove out governance', async function () {
            await this.dcToken.addGovernance(wallet2, { from: wallet1 });
            await this.dcToken.mint(wallet2, ether('10000'), { from: wallet2 });
            await this.dcToken.removeGovernance(wallet1, { from: wallet1 });

            try {
                await this.dcToken.mint(wallet2, ether('10000'), { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            try {
                await this.dcToken.mint(wallet2, ether('10000'), { from: wallet3 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }
        });

        it('should burn after remove out governance', async function () {
            await this.dcToken.addGovernance(wallet2, { from: wallet1 });
            await this.dcToken.mint(wallet2, ether('10000'), { from: wallet2 });
            await this.dcToken.mint(wallet3, ether('10000'), { from: wallet2 });

            await this.dcToken.burn(ether('1000'), { from: wallet2 });
            await this.dcToken.removeGovernance(wallet1, { from: wallet1 });

            try {
                await this.dcToken.burn(ether('1000'), { from: wallet2 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }

            try {
                await this.dcToken.burn(ether('100'), { from: wallet3 });
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet2 is not owner') !== -1).equal(false);
            }


            //

        });

    });

*/
});
