// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICyberWayNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./utils/Random.sol";


contract LootBoxFactory is Ownable, Random {

    struct LootBox {
        uint256 colorFrame;
        uint256 rand;
        uint256 price;
    }

    ICyberWayNFT public nft;

    LootBox[] public boxes;

    address payable public seller;

    constructor(address _nft) {
        nft = ICyberWayNFT(_nft);
        seller = payable(msg.sender);
    }

    function buyBox(uint256 _boxId) public payable {
        // require(boxes[_boxId].price == msg.value);
        _rand(_boxId);
        //nft.mint(msg.sender); - параметры токена
        Address.sendValue(seller, msg.value);
    }

    function addNewBox(uint256 colorFrame_, uint256 rand_, uint256 price_)public onlyOwner {
        LootBox memory box = LootBox(colorFrame_, rand_, price_);
        boxes.push(box);
    }

    function modifyBox(uint256 _boxId,
                        uint256 newColorFrame_,
                        uint256 newRand_,
                        uint256 newPrice_) public onlyOwner {
        boxes[_boxId] = LootBox(newColorFrame_, newRand_, newPrice_);
    }

   // function removeBox(uint256 _boxId) public onlyOwner {
   //     delete boxes[_boxId];
        //boxes.pop(_boxId);
   // }

    function getBox(uint256 boxId_) public view returns(LootBox memory) {
        return boxes[boxId_];
    }


    function updateSellerAddress(address payable newSeller_) public onlyOwner {
        require(newSeller_ != address(0x0));
        seller = newSeller_;
    }

    function _rand(uint256 _amount) internal returns(uint256) {
        return randMod(_amount);
        // должен вернуть 3 параметра токенов которые печатаем
    }
}
/**

contract RacersBoxFactory is TreasurerMigratable, Random, WhitelistMigratable {

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

        // TODO temporary unuse
        // price[3] = 9600000000000000000; // part common
        // price[4] = 1200000000000000000; // part plus
        // price[5] = 9600000000000000000; // part pro
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


    function setBoxPrices(uint16 _type, uint256 _price) public onlyOwner {
        price[_type] = _price;
    }


    function getBoxPrices() public view returns(uint256, uint256, uint256) {
        return(price[1], price[2], price[3]);
    }


    function () public payable {
        revert();
    }


    function withdrawFactoryBalance() external onlyTreasurer {
        uint256 balance = address(this).balance;

        treasurer.transfer(balance);
    }


    function _issue(address _to, uint16 _boxType) internal view {
        uint16[3] memory elements;


        // Box with rarity Cars
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

    uint256[50] private ______gap;
}
*/