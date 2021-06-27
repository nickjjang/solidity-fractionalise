// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./FERC721/IFERC721.sol";

contract Marketplace {
    using SafeMath for uint256;
    struct Fractionalise {
        uint256 tokenId;
        address ownerAddress;
        uint256 fraction;
        uint256 buyBackPrice;
        uint256 initialPrice;
        address fundingTokenAddress;
        uint256 interestRate;
    }

    struct FractionaliseRequest {
        uint256 tokenId;
        uint256 fraction;
        uint256 buyBackPrice;
        uint256 initialPrice;
        address fundingTokenAddress;
        uint256 interestRate;
    }

    struct OfferRequest {
        uint256 tokenId;
        uint256 amount;
        address tokenAddress;
        uint256 price;
    }

    struct Offer {
        uint256 orderId;
        uint256 tokenId;
        string offerType;
        address creatorAddress;
        uint256 amount;
        address tokenAddress;
        uint256 price;
    }

    struct PodInstantiateRequest {
        Offer[] offerList;
        uint256 txnId;
    }

    struct DeleteOrderRequest {
        uint256 tokenId;
        uint256 orderId;
    }

    struct FractionRequest {
        uint256 tokenId;
        uint256 orderId;
        uint256 amount;
    }

    struct BuyBackRequest {
        uint256 tokenId;
    }

    uint256 _offerCount;
    uint256 _fractionaliseCount;
    IFERC721 ferc721;
    mapping(uint256 => Offer) internal _offers;
    mapping(uint256 => Fractionalise) internal _fractionalises;

    event Fractionalised(uint256 fractionaliseCount);
    event BuyOrdered(uint256 orderId);
    event SellOrdered(uint256 orderId);
    event BuyOrderDeleted(uint256 orderId);
    event SellOrderDeleted(uint256 orderId);
    event FractionBought(uint256 orderId);
    event FractionSold(uint256 orderId);

    constructor(address ferc721Address) {
        _offerCount = 0;
        _fractionaliseCount = 0;
        ferc721 = IFERC721(ferc721Address);
    }

    function fractionalise(FractionaliseRequest memory input) external {
        require(
            ferc721.balanceOf(msg.sender, input.tokenId) == input.fraction &&
                ferc721.fractionOf(input.tokenId) == input.fraction,
            "Marketplace.fractionalise: Please input equal fraction amount."
        );
        require(
            input.fraction > 0,
            "Marketplace.fractionalise: fraction can't be lower or equal to zero"
        );
        IERC20 fundingToken = IERC20(input.fundingTokenAddress);
        require(
            fundingToken.allowance(msg.sender, address(this)) >= input.fraction,
            "Marketplace.fractionalise: Owner has not approved"
        );

        ferc721.transferFrom(
            msg.sender,
            address(this),
            input.tokenId,
            input.fraction
        );
        Fractionalise memory fraction = Fractionalise({
            tokenId: input.tokenId,
            ownerAddress: msg.sender,
            fraction: input.fraction,
            buyBackPrice: input.buyBackPrice,
            initialPrice: input.initialPrice,
            fundingTokenAddress: input.fundingTokenAddress,
            interestRate: input.interestRate
        });
        _fractionalises[input.tokenId] = fraction;
        _fractionaliseCount++;

        Offer memory buying = Offer({
            orderId: _offerCount,
            tokenId: input.tokenId,
            offerType: "BUY",
            creatorAddress: msg.sender,
            amount: input.fraction,
            tokenAddress: input.fundingTokenAddress,
            price: input.initialPrice
        });
        _offers[_offerCount] = buying;
        _offerCount++;

        emit Fractionalised(_fractionaliseCount);
    }

    function newBuyOrder(OfferRequest memory input) external {
        IERC20 token = IERC20(input.tokenAddress);
        uint256 amountprice = input.amount * input.price;
        require(
            input.price > 0,
            "Marketplace.newBuyOrder: price can't be lower or equal to zero."
        );
        require(
            input.amount > 0,
            "Marketplace.newBuyOrder: amount can't be lower or equal to zero."
        );
        require(
            token.balanceOf(msg.sender) >= amountprice,
            "Marketplace.newBuyOrder: Your balance is not enough."
        );
        require(
            token.allowance(msg.sender, address(this)) >= amountprice,
            "Marketplace.newBuyOrder: Owner has not approved."
        );

        token.transferFrom(msg.sender, address(this), amountprice);

        Offer memory buying = Offer({
            orderId: _offerCount,
            tokenId: input.tokenId,
            offerType: "BUY",
            creatorAddress: msg.sender,
            amount: input.amount,
            tokenAddress: input.tokenAddress,
            price: input.price
        });
        _offers[_offerCount] = buying;
        _offerCount++;
        emit BuyOrdered(_offerCount);
    }

    function newSellOrder(OfferRequest memory input) external {
        // Fractionalise memory fraction = _fractionalises[input.tokenId];
        // IERC20 fundToken = IERC20(fraction.fundingTokenAddress);
        // IERC20 token = IERC20(fraction.fundingTokenAddress);
        require(
            input.amount > 0,
            "Marketplace.newSellOrder: amount can't be lower or equal to zero"
        );
        require(
            ferc721.balanceOf(msg.sender, input.tokenId) >= input.amount,
            "Marketplace.newSellOrder: Your balance is not enough"
        );
        require(
            ferc721.allowance(msg.sender, address(this), input.tokenId) >=
                input.amount,
            "Marketplace.newSellOrder: Owner has not approved"
        );
        ferc721.transferFrom(
            msg.sender,
            address(this),
            input.tokenId,
            input.amount
        );

        Offer memory selling = Offer({
            orderId: _offerCount,
            tokenId: input.tokenId,
            offerType: "SELL",
            creatorAddress: msg.sender,
            amount: input.amount,
            tokenAddress: input.tokenAddress,
            price: input.price
        });
        _offers[_offerCount] = selling;
        _offerCount++;
        emit SellOrdered(_offerCount);
    }

    function deleteBuyOrder(DeleteOrderRequest memory input) external {
        Offer memory offer = _offers[input.orderId];
        IERC20 token = IERC20(offer.tokenAddress);
        uint256 amountprice = offer.price * offer.amount;
        require(
            offer.creatorAddress == msg.sender,
            "Marketplace.deleteBuyOrder: should be owner"
        );
        require(
            offer.tokenId == input.tokenId,
            "Marketplace.deleteBuyOrder: should be the same tokenId"
        );
        require(
            keccak256(abi.encodePacked(offer.offerType)) ==
                keccak256(abi.encodePacked("BUY")),
            "Marketplace.deleteBuyOrder: should be the buying offer"
        );
        require(
            token.balanceOf(address(this)) >= amountprice,
            "Marketplace.deleteBuyOrder: you don't have enough balance"
        );
        require(
            token.allowance(address(this), msg.sender) >= amountprice,
            "Marketplace.deleteBuyOrder: Owner has not approved"
        );

        delete _offers[input.orderId];
        token.transferFrom(address(this), msg.sender, amountprice);
        emit BuyOrderDeleted(input.orderId);
    }

    function deleteSellOrder(DeleteOrderRequest memory input) external {
        Offer memory offer = _offers[input.orderId];
        require(
            offer.creatorAddress == msg.sender,
            "Marketplace.deleteSellOrder: should be owner"
        );
        require(
            offer.tokenId == input.tokenId,
            "Marketplace.deleteSellOrder: should be the same tokenId"
        );
        require(
            keccak256(abi.encodePacked(offer.offerType)) ==
                keccak256(abi.encodePacked("SELL")),
            "Marketplace.deleteSellOrder: should be the selling offer"
        );
        require(
            ferc721.balanceOf(address(this), input.tokenId) >= offer.amount,
            "Marketplace.deleteSellOrder: you don't have enough balance"
        );
        require(
            ferc721.allowance(address(this), msg.sender, input.tokenId) >=
                offer.amount,
            "Marketplace.deleteSellOrder: Owner has not approved"
        );

        delete _offers[input.orderId];
        ferc721.transferFrom(
            address(this),
            msg.sender,
            input.tokenId,
            offer.amount
        );
        emit SellOrderDeleted(input.orderId);
    }

    function buyFraction(FractionRequest memory input) external {
        Offer storage offer = _offers[input.orderId];
        IERC20 offerToken = IERC20(offer.tokenAddress);
        uint256 amountprice = offer.price * input.amount;
        require(
            offer.tokenId == input.tokenId,
            "Marketplace.buyFraction: should be the same tokenId"
        );
        require(
            keccak256(abi.encodePacked(offer.offerType)) ==
                keccak256(abi.encodePacked("SELL")),
            "Marketplace.buyFraction: should be the selling offer"
        );
        require(
            offerToken.balanceOf(msg.sender) >= amountprice,
            "Marketplace.buyFraction: you don't have enough balance"
        );
        require(
            offerToken.allowance(msg.sender, offer.creatorAddress) >=
                amountprice,
            "Marketplace.buyFraction: Owner has not approved"
        );
        require(
            ferc721.balanceOf(address(this), input.tokenId) >= input.amount,
            "Marketplace.buyFraction: you don't have enough balance"
        );
        require(
            ferc721.allowance(address(this), msg.sender, input.tokenId) >=
                input.amount,
            "Marketplace.buyFraction: Owner has not approved"
        );

        offer.amount.sub(input.amount);
        if (offer.amount == 0) {
            delete _offers[input.orderId];
        }
        offerToken.transferFrom(msg.sender, offer.creatorAddress, amountprice);
        ferc721.transferFrom(
            address(this),
            msg.sender,
            input.tokenId,
            input.amount
        );
        delete _offers[input.orderId];

        emit FractionBought(input.orderId);
    }

    function sellFraction(FractionRequest memory input) external {
        Offer storage offer = _offers[input.orderId];
        IERC20 offerToken = IERC20(offer.tokenAddress);
        uint256 amountprice = offer.price * input.amount;

        require(
            offer.tokenId == input.tokenId,
            "Marketplace.sellFraction: should be the same tokenId"
        );
        require(
            keccak256(abi.encodePacked(offer.offerType)) ==
                keccak256(abi.encodePacked("BUY")),
            "Marketplace.sellFraction: should be the selling offer"
        );
        require(
            offerToken.balanceOf(address(this)) >= amountprice,
            "Marketplace.sellFraction: you don't have enough balance"
        );
        require(
            offerToken.allowance(address(this), msg.sender) >= amountprice,
            "Marketplace.sellFraction: Owner has not approved"
        );
        require(
            ferc721.balanceOf(address(this), input.tokenId) >= input.amount,
            "Marketplace.sellFraction: you don't have enough balance"
        );
        require(
            ferc721.allowance(address(this), msg.sender, input.tokenId) >=
                input.amount,
            "Marketplace.sellFraction: Owner has not approved"
        );

        offer.amount.sub(input.amount);
        if (offer.amount == 0) {
            delete _offers[input.orderId];
        }
        offerToken.transferFrom(address(this), msg.sender, amountprice);
        ferc721.transferFrom(
            msg.sender,
            offer.creatorAddress,
            input.tokenId,
            input.amount
        );

        emit FractionSold(input.orderId);
    }

    function buyFractionalisedBack(BuyBackRequest memory input) external {
        Fractionalise memory fraction = _fractionalises[input.tokenId];
        IERC20 fundingToken = IERC20(fraction.fundingTokenAddress);
        require(
            fraction.ownerAddress == msg.sender,
            "Marketplace.buyFractionlisedBack: operation not allowed for the given address"
        );
        require(
            fundingToken.balanceOf(fraction.ownerAddress) >=
                fraction.buyBackPrice,
            "Marketplace.buyFractionalisedBack: insuficient amount to reconstruct the fractionalised token"
        );
        address[] memory holders = ferc721.ownersOf(input.tokenId);
        for (uint256 i = 0; i < holders.length; i++) {
            address holder = holders[i];
            if (holder == fraction.ownerAddress) {
                continue;
            }

            uint256 balance = ferc721.balanceOf(holder, input.tokenId);
            if (balance == 0) {
                continue;
            }
            ferc721.transferFrom(
                holder,
                fraction.ownerAddress,
                input.tokenId,
                balance
            );
            fundingToken.transferFrom(
                fraction.ownerAddress,
                holder,
                balance * fraction.buyBackPrice
            );
        }
    }
}
