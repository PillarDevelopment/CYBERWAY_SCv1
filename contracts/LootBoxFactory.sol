// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./ICyberWayNFT.sol";
import "./utils/Random.sol";

contract LootBoxFactory is Ownable, Random {

    struct LootBox {
        uint16[6] rand;
        uint256 price;
        uint256 maxCount;
        uint256 currentCount;
    }

    ICyberWayNFT public nft;
    LootBox[] public boxes;
    uint16 characters;
    uint16 cars;

    address payable public seller;

    event NewBoxBought(address buyer, uint256 tokenId);
    event NewSeller(address payable newSeller);

    constructor(address _nft) {
        nft = ICyberWayNFT(_nft);
        seller = payable(msg.sender);
        _addBox([330, 363, 365, 935, 995, 1000], 64000000000000000, 20000);
        _addBox([270, 360, 366, 836, 986, 1000], 160000000000000000, 5000);
        _addBox([270, 450, 490, 760, 960, 1000], 430000000000000000, 1000);
        _addBox([0, 250, 600, 600, 600, 1000], 1050000000000000000, 400);
        cars = 4;
        characters = 10;
    }


    receive() external payable {
        revert("LootBoxFactory: use buyBox");
    }

    // 0, 1, 2, 3
    function buyBox(uint256 _boxId) public payable {
        require(_boxId < boxes.length, "LootBox: This box isn't exist");
        require(boxes[_boxId].price == msg.value, "LootBox: wrong purchase amount");
        require(boxes[_boxId].currentCount < boxes[_boxId].maxCount, "LootBox: box limit is exhausted");

        (uint8 tokenKind, uint8 tokenPerson, uint8 tokenRand) = _rand(_boxId); // got token parameters

        uint256 tokenId = nft.mint(msg.sender, tokenKind, tokenPerson, tokenRand);
        Address.sendValue(seller, msg.value);

        boxes[_boxId].currentCount += 1;
        emit NewBoxBought(msg.sender, tokenId);
    }


    function setPrices(uint256 boxOnePrice,
                        uint256 boxTwoPrice,
                        uint256 boxThreePrice,
                        uint256 boxFourPrice) public onlyOwner {
        require(boxOnePrice > 0 && boxTwoPrice > 0 && boxThreePrice > 0 && boxFourPrice > 0,"LootBox: incorrect price");

        boxes[0].price = boxOnePrice;
        boxes[1].price = boxTwoPrice;
        boxes[2].price = boxThreePrice;
        boxes[3].price = boxFourPrice;
    }


    function updateSellerAddress(address payable newSeller_) public onlyOwner {
        require(newSeller_ != address(0x0), "LootBox: zero address");
        seller = newSeller_;
        emit NewSeller(newSeller_);
    }

    function updateCarsCount(uint16 count) public onlyOwner {
        require(count >= 0, "Error count");
        cars = count;
    }

    function updateCharactersCount(uint16 count) public onlyOwner {
        require(count >= 0, "Error count");
        characters = count;
    }


    function withdrawFactoryBalance() public onlyOwner {
        Address.sendValue(seller, address(this).balance);
    }


    function getBox(uint256 boxId_) public view returns(LootBox memory) {
        return boxes[boxId_];
    }


    function getBoxPrice(uint256 boxId_) public view returns(uint256) {
        return boxes[boxId_].price;
    }

    function getCarsCount() public view returns(uint16) {
        return cars;
    }

    function getCharactersCount() public view returns(uint16) {
        return characters;
    }

    function _addBox(uint16[6] memory rand_, uint256 price_, uint256 maxCount_) private {
        LootBox memory newBox = LootBox({rand: rand_, price: price_, maxCount: maxCount_, currentCount:0});
        boxes.push(newBox);
    }


    function _rand(uint256 _boxId) private returns(uint8 kind, uint8 person, uint8 rand) {
        uint8[2] memory result_ = _generateRarities(boxes[_boxId].rand);
        kind = result_[0];
        rand = result_[1];
        person = 0;
        if (kind == 0) {
            person =  _generateCharacter();
        }
        if (kind == 1) {
            person =  _generateCar();
        }
    }


    function _generateRarities(uint16[6] memory _chances) private returns(uint8[2] memory) {
        uint8[2] memory result_; // kind / rand
        uint256 chance = _randMod(1000);

        if (chance <= _chances[0]) {
            result_ = [0,0]; // character Common
        }
        if (chance <= _chances[1]) {
            result_ = [0,1]; // character Uncommon
        }
        if (chance <= _chances[2]) {
            result_ = [0,2]; // character Rare
        }
        if (chance <= _chances[3]) {
            result_ = [1,0]; // car Common
        }
        if (chance <= _chances[4]) {
            result_ = [1,1]; //  car Uncommon
        }
        if (chance <= _chances[5]) {
            result_ = [1,2]; // car Rare
        }
        return result_;
    }


    function _generateCar() private returns(uint8) {
        require(cars > 0, "Error cars count eq 0");
        return _randMod(cars - 1);
    }

    function _generateCharacter() private returns(uint8) {
        require(characters > 0, "Error cars count eq 0");
        return _randMod(characters - 1);
    }
}
