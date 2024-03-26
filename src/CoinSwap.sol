// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LibCoinSwap.sol";
import "./interfaces/ICoinSwap.sol";
import "./errors/LibErrors.sol";

contract CoinSwap is ICoinSwap {
    // Data feeds
    // DAI 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19
    // LINK 0xc59E3633BAAC79493d908e63626716e204A45EdF
    // ETH 0x694AA1769357215DE4FAC081bf1f309aDC325306
    // LINK/ETH 0x42585eD362B3f1BCa95c640FdFf35Ef899212734

    // contract address
    // DAI 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6
    // LINK 0x779877A7B0D9E8603169DdbD7836e478b4624789
    uint8 constant _decimals = 8;

    mapping(string => address) public dataFeed;
    mapping(string => address) public tokenAddress;

    constructor() {
        dataFeed["DAI"] = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;
        dataFeed["LINK"] = 0xc59E3633BAAC79493d908e63626716e204A45EdF;
        dataFeed["ETH"] = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        // dataFeed["LINK/ETH"] = 0x42585eD362B3f1BCa95c640FdFf35Ef899212734;

        tokenAddress["DAI"] = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;
        tokenAddress["LINK"] = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    }

    function swapETHForTokens(string memory _quote) public payable {
        // swap logic
        if (msg.value == 0) {
            revert LibErrors.CANNOT_SWAP_ZERO_AMOUNT();
        }

        int256 _derivedPrice = LibCoinSwap.getDerivedPrice(
            dataFeed["ETH"],
            dataFeed[_quote],
            _decimals
        );

        uint256 _swapAmount = LibCoinSwap.calculatePayout(
            msg.value,
            uint256(_derivedPrice)
        );

        IERC20 _quoteToken = IERC20(tokenAddress[_quote]);

        if (_quoteToken.balanceOf(address(this)) < _swapAmount) {
            revert LibErrors.INSUFFICIENT_PAYOUT_BALANCE();
        }

        require(
            _quoteToken.transfer(msg.sender, _swapAmount),
            "Payout transfer failed"
        );

        emit Swap(msg.sender, "ETH", _quote, _swapAmount);
    }

    function swapTokensForETH(string memory _base, uint256 _amount) public {
        // swap logic
        if (_amount == 0) {
            revert LibErrors.CANNOT_SWAP_ZERO_AMOUNT();
        }

        int256 _derivedPrice = LibCoinSwap.getDerivedPrice(
            dataFeed[_base],
            dataFeed["ETH"],
            _decimals
        );

        uint256 _swapAmount = LibCoinSwap.calculatePayout(
            _amount,
            uint256(_derivedPrice)
        );

        IERC20 tokenContract = IERC20(tokenAddress[_base]);
        uint256 _allowance = tokenContract.allowance(msg.sender, address(this));
        if (_allowance < _amount) {
            revert LibErrors.INSUFFICIENT_TOKEN_ALLOWANCE();
        }

        if (address(this).balance < _swapAmount) {
            revert LibErrors.INSUFFICIENT_PAYOUT_BALANCE();
        }

        require(
            tokenContract.transferFrom(msg.sender, address(this), _amount),
            "Token transfer failed"
        );

        payable(msg.sender).transfer(_swapAmount);

        emit Swap(msg.sender, _base, "ETH", _swapAmount);
    }

    function swapTokensForTokens(
        string memory _base,
        string memory _quote,
        uint256 _amount
    ) public {
        if (_amount == 0) {
            revert LibErrors.CANNOT_SWAP_ZERO_AMOUNT();
        }

        int256 _derivedPrice = LibCoinSwap.getDerivedPrice(
            dataFeed[_base],
            dataFeed[_quote],
            _decimals
        );

        uint256 _swapAmount = LibCoinSwap.calculatePayout(
            _amount,
            uint256(_derivedPrice)
        );

        // Get user token
        IERC20 tokenContractA = IERC20(tokenAddress[_base]);
        uint256 _allowance = tokenContractA.allowance(
            msg.sender,
            address(this)
        );
        if (_allowance < _amount) {
            revert LibErrors.INSUFFICIENT_TOKEN_ALLOWANCE();
        }

        require(
            tokenContractA.transferFrom(msg.sender, address(this), _amount),
            "Token A transfer failed"
        );
        // Transfer payout
        IERC20 tokenContractB = IERC20(tokenAddress[_quote]);
        uint256 _balance = tokenContractB.balanceOf(address(this));

        if (_balance > _swapAmount) {
            revert LibErrors.INSUFFICIENT_PAYOUT_BALANCE();
        }

        require(
            tokenContractA.transferFrom(msg.sender, address(this), _amount),
            "Token B transfer failed"
        );

        emit Swap(msg.sender, _base, _quote, _swapAmount);
    }
}
