const { ether, BN } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const {address} = require("hardhat/internal/core/config/config-validation");

const CyberWayNFT = artifacts.require('CyberWayNFT');
const LootBoxFactory = artifacts.require('LootBoxFactory');

contract('LootBoxFactory', function ([wallet1, wallet2, wallet3]) {

    before(async function () {
        this.nftToken = await CyberWayNFT.new("CyberNFT","Cyber_Way NFT token", { from: wallet1 });
        this.lootBox = await LootBoxFactory.new(this.nftToken.address, { from: wallet1 });
    });

    beforeEach(async function () {
        await this.nftToken.addGovernance(wallet1, { from: wallet1 });
        await this.nftToken.addGovernance(this.lootBox.address, { from: wallet1 });
    });

    describe('Update SellerAddress', async  function() {
        it('not owner', async function () {
            try {
                await this.lootBox.updateSellerAddress(wallet2, {from: wallet2});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('not owner') !== -1).equal(false);
            }
            await this.lootBox.updateSellerAddress(wallet2, {from: wallet1});
        });
    });

    describe('Withdraw Factory Balance', async  function() {
        it('not owner', async function () {
            try {
                await this.lootBox.withdrawFactoryBalance({from: wallet2});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('not owner') !== -1).equal(false);
            }
            await this.lootBox.withdrawFactoryBalance({from: wallet1});
        });
    });

    describe('Set Prices', async  function() {
        it('not owner', async function () {
            try {
                await this.lootBox.setPrices(20, 20, 20, 20, {from: wallet2});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('not owner') !== -1).equal(false);
            }
            await this.lootBox.setPrices(20, 20, 20, 20, {from: wallet1});
            const newPrice = await this.lootBox.getBoxPrice(0);
            expect(newPrice.toString()).to.equal('20');

        });

        it('zero amount', async function () {
            try {
                await this.lootBox.setPrices(0, 20, 20, 20, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('zero amount') !== -1).equal(false);
            }
            try {
                await this.lootBox.setPrices(10, 0, 20, 20, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('zero amount') !== -1).equal(false);
            }
            try {
                await this.lootBox.setPrices(1000, 200, 0, 2, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('zero amount') !== -1).equal(false);
            }
            try {
                await this.lootBox.setPrices(120, 230, 204, 0, {from: wallet1});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('zero amount') !== -1).equal(false);
            }
            await this.lootBox.setPrices(120, 230, 204, 1000, {from: wallet1});
        });
    });

    describe('Buy Box', async function() {

        it('buy box', async function () {
            await this.lootBox.setPrices(ether('1'), ether('2'), ether('3'), ether('4'), {from: wallet1});
            await this.lootBox.buyBox(0, { value: ether('1')});
            await this.lootBox.buyBox(1, { value: ether('2')});
            await this.lootBox.buyBox(2, { value: ether('3')});

            try {
                await web3.eth.sendTransaction({
                    from: wallet1,
                    to: this.lootBox.address,
                    value: web3.utils.toWei('1', 'ether')});
                expect(false).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('use buyBox') !== -1).equal(true);
            }

        });

        it('box is not exist', async function () {
            await this.lootBox.setPrices(ether('1'), ether('2'), ether('3'), ether('4'), {from: wallet1});

            try {
                await this.lootBox.buyBox(4, { value: ether('1')});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('box is not exist') !== -1).equal(false);
            }

            try {
                await this.lootBox.buyBox(5, { value: ether('1')});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('box is not exist') !== -1).equal(false);
            }

            try {
                await this.lootBox.buyBox(6, { value: ether('1')});
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('box is not exist') !== -1).equal(false);
            }

            await this.lootBox.buyBox(1, { value: ether('2')});
        });

        it('wrong purchase amount', async function () {
            await this.lootBox.setPrices(ether('1'), ether('2'), ether('3'), ether('4'), {from: wallet1});

            try {
                await this.lootBox.buyBox(1, { value: ether('0.001')});
                expect(true).equal(false);
            } catch (error) {
                expect(error.toString().indexOf('wrong purchase amount') !== -1).equal(true);
            }

            try {
                await this.lootBox.buyBox(2, { value: ether('0.00001')});
                expect(true).equal(false);
            } catch (error) {
                expect(error.toString().indexOf('wrong purchase amount') !== -1).equal(true);
            }

            try {
                await this.lootBox.buyBox(3, { value: ether('30')});
                expect(true).equal(false);
            } catch (error) {
                expect(error.toString().indexOf('wrong purchase amount') !== -1).equal(true);
            }

            await this.lootBox.buyBox(0, { value: ether('1')});
            await this.lootBox.buyBox(1, { value: ether('2')});
        });

        it('box limit is exhausted', async function () {
            await this.lootBox.setPrices(ether('0.01'), ether('0.02'), ether('0.03'), ether('0.04'), {from: wallet1});

            for (let i = 0; i < 400; i++) { // 396
                await this.lootBox.buyBox(3, { value: ether('0.04')});
                assert(true);
                this.enableTimeouts(false);
            }

            await this.lootBox.buyBox(1, { value: ether('0.02')});

            try {
                await this.lootBox.buyBox(3, { value: ether('0.04')});
                expect(true).equal(false);
            } catch (error) {
                expect(error.toString().indexOf('box limit is exhausted') !== -1).equal(true);
            }

            for (let i = 0; i < 4995; i++) { // 4995
                await this.lootBox.buyBox(1, { value: ether('0.02')});
                assert(true);
                this.enableTimeouts(false);
            }
            await this.lootBox.buyBox(1, { value: ether('0.02')});
            try {
                await this.lootBox.buyBox(1, { value: ether('0.02')});
                expect(true).equal(false);
            } catch (error) {
                expect(error.toString().indexOf('box limit is exhausted') !== -1).equal(true);
            }
        });

    });
});