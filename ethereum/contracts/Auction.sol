pragma solidity ^0.4.17;

import "./Loan.sol";
import "./Document.sol";

contract AuctionFactory {
    address[] public deployedAuctions;
    DocumentFactory documentFactory;

    constructor(address documentFactoryAddress) public {
        documentFactory = DocumentFactory(documentFactoryAddress);
    }

    function createAuction(
        address newAuctionItem,
        uint256 auctionExpiryDate,
        uint256 minimumBidValue
    ) public {
        address newAuction = new Auction(
            newAuctionItem,
            auctionExpiryDate,
            minimumBidValue
        );

        // Lock all documents
        Loan currentLoan = Loan(newAuctionItem);
        address[] memory documents = currentLoan.getDocuments();
        for (uint256 i = 0; i < documents.length; ++i) {
            documentFactory.toggleDocumentLock(documents[i]);
        }

        deployedAuctions.push(newAuction);
    }

    function getDeployedAuctions() public view returns (address[]) {
        return deployedAuctions;
    }

    function finalizeAuction(address currentLoanAddress, address newOwner)
        public
    {
        Loan loan = Loan(currentLoanAddress);
        address[] memory documents = loan.getDocuments();

        // Distribute money and unlock documents
        loan.distributeAmount();
        for (uint256 i = 0; i < documents.length; ++i) {
            documentFactory.toggleDocumentLock(documents[i]);
            documentFactory.changeDocumentOwner(documents[i], newOwner);
        }
    }
}

contract Auction {
    bool public isActive;
    uint256 public expiryDate;
    uint256 public currentBid;
    uint256 public minimumBid;
    address public loanAddress;
    address public currentBidder;
    address public auctionFactory;
    AuctionFactory factory;

    constructor(
        address newAuctionItem,
        uint256 auctionExpiryDate,
        uint256 minimumBidValue
    ) public {
        isActive = true;
        minimumBid = minimumBidValue;
        expiryDate = auctionExpiryDate;
        loanAddress = newAuctionItem;
        auctionFactory = msg.sender;
        factory = AuctionFactory(auctionFactory);
    }

    function bid(uint256 date) public payable {
        require(
            msg.value > currentBid &&
                msg.value > minimumBid &&
                date < expiryDate &&
                isActive
        );
        if (currentBid > 0) currentBidder.transfer(currentBid);
        currentBid = msg.value;
        currentBidder = msg.sender;
    }

    function auctionSummary()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            address,
            bool
        )
    {
        return (
            expiryDate,
            currentBid,
            minimumBid,
            loanAddress,
            currentBidder,
            isActive
        );
    }

    function endAuction() public {
        loanAddress.transfer(address(this).balance);
        factory.finalizeAuction(loanAddress, currentBidder);
        isActive = false;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }
}

