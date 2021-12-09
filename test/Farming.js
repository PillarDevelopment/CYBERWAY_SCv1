const { ether, BN } = require('@openzeppelin/test-helpers');
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
        await this.nftToken.mint(wallet1, 1, 3, 4, { from: wallet1 }); // 1
        await this.nftToken.mint(wallet2, 0, 2, 1, { from: wallet1 }); // 2
        await this.nftToken.mint(wallet2, 1, 1, 2, { from: wallet1 }); // 3
    });

    describe('Deposit NFT Farming Token', async function () {

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

    describe('Set basic params', async  function() {
        it('not owner', async function () {
            await this.farming.setBasicLockPeriod(100, {from: wallet1});
            try {
                await this.farming.setBasicLockPeriod(10, {from: wallet2});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('not owner') !== -1).equal(false);
            }
            await this.farming.setTokenPerBlock(100, {from: wallet1});
            const currentBlock = await this.farming.getCurrentBlockReward();
            expect(currentBlock.toString()).to.equal('100');

            try {
                await this.farming.setTokenPerBlock(20, {from: wallet2});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('not owner') !== -1).equal(false);
            }
        });

       it('zero amount', async function() {
           try {
               await this.farming.setBasicLockPeriod(10, {from: wallet2});
               expect(true).equal(true);
           } catch (error) {
               expect(error.toString().indexOf('Farming: zero amount') !== -1).equal(false);
           }
           await this.farming.setBasicLockPeriod(100, {from: wallet1});

           try {
               await this.farming.setTokenPerBlock(0, {from: wallet1});
               expect(true).equal(true);
           } catch (error) {
               expect(error.toString().indexOf('zero amount') !== -1).equal(false);
           }
           await this.farming.setTokenPerBlock(2, {from: wallet1});
           const currentBlock = await this.farming.getCurrentBlockReward();
           expect(currentBlock.toString()).to.equal('2');
       });
    });

    describe('Emergency withdraw NFT', async  function() {
        it('not owner', async function () {
            await this.nftToken.approve(this.farming.address, 3, { from: wallet2 });
            await this.farming.depositFarmingToken(3, {from: wallet2});

            try {
                await this.farming.emergencyWithdrawFarmingToken(3, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('Wallet1 is not owner') !== -1).equal(false);
            }
        });

        it('not deposit', async function() {
            await this.nftToken.mint(wallet2, 0, 1, 2, { from: wallet1 }); // 4
            await this.nftToken.approve(this.farming.address, 4, { from: wallet1 });

            try {
                await this.farming.emergencyWithdrawFarmingToken(3, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('not deposit') !== -1).equal(false);
            }
        });
    });

    describe('Withdraw NFT Farming Token', async  function() {
        it('period', async function() {
            await this.nftToken.mint(wallet2, 0, 0, 0, { from: wallet1 }); // 4
            await this.nftToken.approve(this.farming.address, 5, { from: wallet1 });
            await this.farming.depositFarmingToken(5, { from: wallet1 });
            try {
                await this.farming.withdrawFarmingToken(5, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('incorrect time') !== -1).equal(false);
            }

            await this.farming.setBasicLockPeriod(1, {from: wallet1});

            try {
                await this.farming.withdrawFarmingToken(5, {from: wallet3});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('not owner') !== -1).equal(false);
            }
            await this.farming.withdrawFarmingToken(5, {from: wallet1});
        });
    });

});
