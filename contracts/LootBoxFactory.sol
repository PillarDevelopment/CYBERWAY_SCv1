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

    address payable public seller;

    event NewBoxAdded(uint256 price, uint256 maxCount, uint256 boxId);
    event NewBoxBought(address buyer, uint256 boxId);
    event NewSeller(address payable newSeller);

    constructor(address _nft) {
        nft = ICyberWayNFT(_nft);
        seller = payable(msg.sender);
        _addBox([330, 33, 2, 570, 60, 5], 64000000000000000, 20000);
        _addBox([270, 90, 6, 470, 150, 14], 160000000000000000, 5000);
        _addBox([270, 180, 40, 270, 200, 40], 430000000000000000, 1000);
        _addBox([0, 250, 350, 0, 0, 400], 1050000000000000000, 400);
    }


    function buyBox(uint256 _boxId) public payable {
        require(_boxId < boxes.length, "LootBoxFactory: This box isn't exist");
        require(boxes[_boxId].price == msg.value, "LootBoxFactory: incorrect value");
        require(boxes[_boxId].currentCount + 1 < boxes[_boxId].maxCount, "LootBoxFactory: box limit is exhausted");

        (uint256 tokenKind, uint256 tokenColor, uint256 tokenRand) = _rand(_boxId); // got token parameters

        nft.mint(msg.sender, tokenKind, tokenColor, tokenRand);
        Address.sendValue(seller, msg.value);

        boxes[_boxId].currentCount += 1;
        emit NewBoxBought(msg.sender, _boxId);
    }


    receive() external payable {
        revert();
    }


    function getBox(uint256 boxId_) public view returns(LootBox memory) {
        return boxes[boxId_];
    }


    function updateSellerAddress(address payable newSeller_) public onlyOwner {
        require(newSeller_ != address(0x0));
        seller = newSeller_;
        emit NewSeller(newSeller_);
    }


    function addNewBox(uint16[6] memory rand_, uint256 price_, uint256 maxCount_) public onlyOwner {
        _addBox(rand_, price_, maxCount_);
        emit NewBoxAdded(price_, maxCount_, boxes.length);
    }


    function _addBox(uint16[6] memory rand_, uint256 price_, uint256 maxCount_) internal {
        LootBox memory newBox = LootBox({rand: rand_, price: price_, maxCount: maxCount_, currentCount:0});
        boxes.push(newBox);
    }


    /*
    Getting token parameters
    */
    function _rand(uint256 _amount) internal returns(uint256 kind, uint256 color, uint256 rand) {
        kind = randMod(_amount); // todo
        color =  randMod(_amount); // todo
        rand =  randMod(_amount); // todo
    }
}
/**
contract RacersBoxFactory {

    event NewBoxBought(address buyer, uint16 boxType);
    event BoxGifted(address sender, uint16 boxType);
    IRacersCar public car_;
    uint256[4] price;
    function initialize( address _carAddress) public isInitializer("RacersBoxFactory", "1.0.0") {
        // require(_partAddress != address(0), "address incorrect"); // TODO temporary unuse
        require(_carAddress != address(0), "address incorrect");

        Ownable.initialize(msg.sender);

        transferTreasurer(owner);

        setCarContract(_carAddress);

        price[1] = 300000000000000000; // car common
        price[2] = 600000000000000000; // car plus
        price[3] = 1200000000000000000; // car pro
    }


    function setCarContract(address _carAddress) public onlyOwner {
        car_ = IRacersCar(_carAddress);
    }


    function buyBox (uint16 _boxType) public payable {
        require(_boxType > 0 && _boxType <= 3, "Box type cannot be more than 3");
        require(msg.value >= price[_boxType], "Insufficient equity");

        _issue(msg.sender, _boxType);

        treasurer.transfer(balance);
        emit NewBoxBought(msg.sender, _boxType);
    }


    function giftBox (uint16 _boxType, address _to) public onlyWhitelisted() {
        require(_to != address(0), "incorrect address, try again");
        require(_boxType > 0 && _boxType <= 3, "Box type cannot be more than 3");
        _issue(_to, _boxType);

        emit BoxGifted(_to, _boxType);
    }


    function getBoxPrices() public view returns(uint256, uint256, uint256) {
        return(price[1], price[2], price[3]);
    }


    function withdrawFactoryBalance() external onlyTreasurer {
        uint256 balance = address(this).balance;

        treasurer.transfer(balance);
    }


    function _issue(address _to, uint16 _boxType) internal view {
        uint16[3] memory elements;


        if (_boxType == 1) {
            elements = _generateRarities( [750, 200, 48, 2] );
            _produceCarBox(_to, elements);
        }
        if (_boxType == 2) { // in plus garant 1 rare
            elements = _generateRarities([450, 400, 140, 10]);
            _produceCarBox(_to, _assureBoxWithRarity(elements, _boxType));
        }
        if (_boxType == 3) { // in pro garant 2
            elements = _generateRarities([100, 550, 300, 50]);
            _produceCarBox(_to, _assureBoxWithRarity(elements, _boxType));
        }

    }


    function _produceCarBox(address _to, uint16[3] _list ) internal view {
        for (uint i=0; i<3; i++) {
            car_.mintCar(_to, "CAR", uint8(_list[i]), _generateRandom(0,4), _generateRandom(0,9), 0);
        }
    }


    function _generateRarities ( uint16[4] memory _chances ) internal view returns ( uint16[3] ) {
        uint16[3] memory result;

        for (uint16 i=0; i<3; i++) {
            uint256 chance = _randRange(1,1000);
            if (chance <= _chances[0]) {
                result[i] = 0;
            }
            if (chance <= _chances[1]) {
                result[i] = 1;
            }
            if (chance <= _chances[2]) {
                result[i] = 2;
            }
            if (chance <= _chances[3]) {
                result[i] = 3;
            }
        }
        return result;
    }


    function _generateRandom(uint256 _begin, uint256 _end) internal view returns (uint8) {
        return uint8(_randRange(_begin, _end));
    }


    function _assureBoxWithRarity(uint16[3] memory _carLits, uint16 _garant) internal pure returns (uint16[3]){
        if (!_hasCarWithRarity(_carLits, _garant)) {
            uint16 min_rarity_idx = _findMinRarity(_carLits);
            _carLits[min_rarity_idx] = _garant;
        }
        return _carLits;
    }


    function _hasCarWithRarity(uint16[3] memory _carLits, uint16 _garant) internal pure returns (bool) {
        for (uint16 i = 1; i < 3; i++) {
            if (_carLits[i] >= _garant) {
                return true;
            } else
                return false;
        }
    }


    function _findMinRarity (uint16[3] memory _carLits) internal pure returns (uint16) {
        uint16 result = 0;

        for (uint16 i = 1; i < 3; i++) {
            if (_carLits[i] < _carLits[result]) {
                result = i;
            }
        }
        return result;
    }
}
*/