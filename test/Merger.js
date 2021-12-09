const { ether, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const CyberWayNFT = artifacts.require('CyberWayNFT');
const Merger = artifacts.require('Merger');

contract('Merger', function ([wallet1, wallet2, wallet3]) {

    before(async function () {
        this.nftToken = await CyberWayNFT.new("CyberNFT","Cyber_Way NFT token", { from: wallet1 });
        this.merger = await Merger.new(this.nftToken.address, { from: wallet1 });
        await this.nftToken.addGovernance(this.merger.address, { from: wallet1 });
    });

    beforeEach(async function () {
        await this.nftToken.addGovernance(wallet1, { from: wallet1 });
        await this.nftToken.mint(wallet1, 1, 2, 3, { from: wallet1 }); // 0
        await this.nftToken.mint(wallet1, 1, 2, 3, { from: wallet1 }); // 1
        await this.nftToken.mint(wallet1, 1, 2, 3, { from: wallet1 }); // 2
        await this.nftToken.mint(wallet1, 1, 2, 2, { from: wallet1 }); // 3
        await this.nftToken.mint(wallet1, 1, 0, 4, { from: wallet1 }); // 4
        await this.nftToken.mint(wallet1, 1, 0, 4, { from: wallet1 }); // 5
        await this.nftToken.mint(wallet1, 1, 0, 4, { from: wallet1 }); // 6
        await this.nftToken.mint(wallet1, 1, 0, 0, { from: wallet1 }); // 7
        await this.nftToken.mint(wallet1, 0, 0, 0, { from: wallet1 }); // 8
        await this.nftToken.mint(wallet1, 1, 0, 0, { from: wallet1 }); // 9
    });

    describe('Merge', async function () {

        it('rand not equal', async function () {
            await this.nftToken.approve(this.merger.address, 0, { from: wallet1 });
            await this.nftToken.approve(this.merger.address, 1, { from: wallet1 });
            await this.nftToken.approve(this.merger.address, 3, { from: wallet1 });

            try {
                await this.merger.merge([0,1,3], { from: wallet1 }); // 1
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('rand Not equal') !== -1).equal(false);
            }
        });

        it('rand max', async function () {
            await this.nftToken.approve(this.merger.address, 4, { from: wallet1 });
            await this.nftToken.approve(this.merger.address, 5, { from: wallet1 });
            await this.nftToken.approve(this.merger.address, 6, { from: wallet1 });

            try {
                await this.merger.merge([4,5,6], { from: wallet1 }); // 1
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('rand max') !== -1).equal(false);
            }
        });

        it('kind notEqual', async function () {
            await this.nftToken.approve(this.merger.address, 7, { from: wallet1 });
            await this.nftToken.approve(this.merger.address, 8, { from: wallet1 });
            await this.nftToken.approve(this.merger.address, 9, { from: wallet1 });

            try {
                await this.merger.merge([7,8,9], { from: wallet1 }); // 1
                expect(true).equal(true);
            } catch (error) {
                expect(error.toString().indexOf('kind Not equal') !== -1).equal(false);
            }

        });

        it('merge', async function () {
            await this.nftToken.approve(this.merger.address, 0, { from: wallet1 });
            await this.nftToken.approve(this.merger.address, 1, { from: wallet1 });
            await this.nftToken.approve(this.merger.address, 2, { from: wallet1 });
            await this.merger.merge([0,1,2], { from: wallet1 }); // 1
        });
    });
});
