// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    enum Role { None, Fabricant, Transporteur, Revendeur, Client }

    struct Participant {
        bool authorized;
        Role role;
    }

    struct ProductLot {
        string productName;
        string lotId;
        uint256 totalQuantity;
        address manufacturer;
        address currentOwner;
        uint256 purchaseDate;
    }

    struct Transfer {
        address from;
        address to;
        uint256 date;
    }

    address public owner;

    mapping(address => Participant) public participants;
    mapping(string => ProductLot) public productLots;
    mapping(string => Transfer[]) public transferHistory;
    string[] public lotIds;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized() {
        require(participants[msg.sender].authorized, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function setParticipant(address account, Role role, bool status) external onlyOwner {
        participants[account] = Participant({authorized: status, role: role});
    }

    function getParticipantRole(address account) external view returns (Role) {
        return participants[account].role;
    }

    function createProductLot(string memory productName, string memory lotId, uint256 totalQuantity) public onlyAuthorized {
        require(participants[msg.sender].role == Role.Fabricant, "Not a fabricant");
        require(productLots[lotId].manufacturer == address(0), "Lot already exists");

        productLots[lotId] = ProductLot({
            productName: productName,
            lotId: lotId,
            totalQuantity: totalQuantity,
            manufacturer: msg.sender,
            currentOwner: msg.sender,
            purchaseDate: block.timestamp
        });

        lotIds.push(lotId);
        transferHistory[lotId].push(Transfer({from: address(0), to: msg.sender, date: block.timestamp}));
    }

    function transferLotOwnership(string memory lotId, address newOwner) public onlyAuthorized {
        ProductLot storage lot = productLots[lotId];
        require(lot.currentOwner == msg.sender, "Not current owner");
        require(participants[newOwner].authorized, "Recipient not authorized");

        lot.currentOwner = newOwner;
        lot.purchaseDate = block.timestamp;

        transferHistory[lotId].push(Transfer({from: msg.sender, to: newOwner, date: block.timestamp}));
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

    function getTransferHistory(string memory lotId) public view returns (Transfer[] memory) {
        return transferHistory[lotId];
    }

    function getAllLotIds() public view returns (string[] memory) {
        return lotIds;
    }
} 
