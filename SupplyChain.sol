// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Whitelist.sol";

contract SupplyChain is Whitelist {

    struct ProductLot {
        string productName;
        string lotId;
        uint256 totalQuantity;
        address manufacturer;
        address currentOwner;
        uint256 purchaseDate;
    }

    mapping(string => ProductLot) public productLots;
    string[] public lotIds;

    event ProductCreated(string lotId, string productName, address manufacturer, uint256 totalQuantity);
    event OwnershipTransferred(string lotId, address from, address to, uint256 date);

    function createProductLot(
        string memory productName,
        string memory lotId,
        uint256 totalQuantity
    ) public onlyWhitelisted {
        require(productLots[lotId].manufacturer == address(0), "Lot deja existe");

        productLots[lotId] = ProductLot({
            productName: productName,
            lotId: lotId,
            totalQuantity: totalQuantity,
            manufacturer: msg.sender,
            currentOwner: msg.sender,
            purchaseDate: block.timestamp
        });

        lotIds.push(lotId);
        emit ProductCreated(lotId, productName, msg.sender, totalQuantity);
    }

    function transferLotOwnership(string memory lotId, address newOwner) public onlyWhitelisted {
        ProductLot storage lot = productLots[lotId];
        require(lot.currentOwner == msg.sender, "Vous n'etes pas le proprietaire");

        address oldOwner = lot.currentOwner;
        lot.currentOwner = newOwner;
        lot.purchaseDate = block.timestamp;

        emit OwnershipTransferred(lotId, oldOwner, newOwner, block.timestamp);
    }

    function getLotDetails(string memory lotId) public view returns (
        string memory, string memory, uint256, address, address, uint256
    ) {
        ProductLot memory lot = productLots[lotId];
        return (
            lot.productName,
            lot.lotId,
            lot.totalQuantity,
            lot.manufacturer,
            lot.currentOwner,
            lot.purchaseDate
        );
    }

    function getAllLotIds() public view returns (string[] memory) {
        return lotIds;
    }
}