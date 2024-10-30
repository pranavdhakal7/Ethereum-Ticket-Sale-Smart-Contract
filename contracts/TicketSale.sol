// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TicketSale {
    address public admin;               // Contract admin
    uint public ticketPrice;            // Price per ticket in wei
    uint public totalTickets;           // Total number of tickets available
    uint public ticketsSold;            // Count of tickets sold

    // Track ticket ownership (ticketId => owner address)
    mapping(uint => address) public ticketOwners;

    // Track swap offers (ticketId => address requesting the swap)
    mapping(uint => address) public swapOffers;

    // Structure to store resale details
    struct Resale {
        uint ticketId;
        uint resalePrice;
        address seller;
    }
    
    // Mapping to track tickets for resale (ticketId => resale details)
    mapping(uint => Resale) public resaleTickets;

    // Array to keep track of ticket IDs currently available for resale
    uint[] public resaleTicketIds;

    // Events for tracking contract activities
    event TicketPurchased(address indexed buyer, uint indexed ticketId);
    event SwapOffered(address indexed owner, uint indexed ticketId);
    event SwapAccepted(address indexed newOwner, uint indexed ticketId);
    event TicketListedForResale(address indexed seller, uint indexed ticketId, uint resalePrice);
    event TicketPurchasedFromResale(address indexed buyer, address indexed seller, uint indexed ticketId, uint price);

    // Modifier to restrict access to only the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action.");
        _;
    }

    // Constructor to initialize the contract with the number of tickets and price per ticket
    constructor(uint numTickets, uint price) {
        admin = msg.sender;
        totalTickets = numTickets;
        ticketPrice = price;
    }

    // Function to buy a ticket
    function buyTicket(uint ticketId) public payable {
        require(ticketId > 0 && ticketId <= totalTickets, "Invalid ticket ID.");
        require(ticketOwners[ticketId] == address(0), "Ticket already sold.");
        require(msg.value == ticketPrice, "Incorrect payment amount.");

        ticketOwners[ticketId] = msg.sender;
        ticketsSold++;

        emit TicketPurchased(msg.sender, ticketId);
    }

    // Function to get the ticket ID owned by a specific address
    function getTicketOf(address person) public view returns (uint) {
        for (uint i = 1; i <= totalTickets; i++) {
            if (ticketOwners[i] == person) {
                return i;
            }
        }
        return 0;  // Return 0 if the person doesn't own any ticket
    }

    // Function to offer a swap for a ticket
    function offerSwap(uint ticketId) public {
        require(ticketOwners[ticketId] == msg.sender, "You do not own this ticket.");
        swapOffers[ticketId] = msg.sender;

        emit SwapOffered(msg.sender, ticketId);
    }

    // Function to accept a swap offer for a ticket
    function acceptSwap(uint ticketId) public {
        address owner = swapOffers[ticketId];
        require(owner != address(0), "No swap offer for this ticket.");
        require(owner != msg.sender, "Cannot accept your own offer.");

        uint senderTicketId = getTicketOf(msg.sender);
        require(senderTicketId != 0, "You must own a ticket to swap.");

        // Swap ownership
        ticketOwners[ticketId] = msg.sender;
        ticketOwners[senderTicketId] = owner;

        // Clear the swap offer
        delete swapOffers[ticketId];

        emit SwapAccepted(msg.sender, ticketId);
    }

    // Function to list a ticket for resale
    function resaleTicket(uint price) public {
        uint ticketId = getTicketOf(msg.sender);
        require(ticketId != 0, "You do not own any ticket to resale.");

        resaleTickets[ticketId] = Resale(ticketId, price, msg.sender);
        resaleTicketIds.push(ticketId);

        emit TicketListedForResale(msg.sender, ticketId, price);
    }

    // Function to accept and purchase a resale ticket
    function acceptResale(uint ticketId) public payable {
        Resale memory resale = resaleTickets[ticketId];
        require(resale.seller != address(0), "Ticket not available for resale.");
        require(msg.value == resale.resalePrice, "Incorrect payment amount.");

        ticketOwners[ticketId] = msg.sender;
        payable(resale.seller).transfer(msg.value);

        // Remove resale listing
        delete resaleTickets[ticketId];
        for (uint i = 0; i < resaleTicketIds.length; i++) {
            if (resaleTicketIds[i] == ticketId) {
                resaleTicketIds[i] = resaleTicketIds[resaleTicketIds.length - 1];
                resaleTicketIds.pop();
                break;
            }
        }

        emit TicketPurchasedFromResale(msg.sender, resale.seller, ticketId, resale.resalePrice);
    }

    // Function to check available tickets for resale
    function checkResale() public view returns (uint[] memory) {
        return resaleTicketIds;
    }
}
