// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../src/CoinSwap.sol";
import "../src/interfaces/ICoinSwap.sol";
import "../src/errors/LibErrors.sol";

contract CoinSwapTest is Test {
    CoinSwap public coinSwap;

    address ethDaiHolder = 0xd0aD7222c212c1869334a680e928d9baE85Dd1d0;
    address ethHolder = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address daiHolder = 0x906e04c0A81F973A619359652d853999546B6216;
    address linkHolder = 0x40Ebf16531B2b98A221d037c4aBd206CE5390AfE;

    function setUp() public {
        coinSwap = new CoinSwap();

        vm.deal(address(coinSwap), 20 ether);

        // transfer link to contract
        vm.startPrank(linkHolder);
        IERC20(coinSwap.tokenAddress("LINK")).transfer(
            address(coinSwap),
            20 ether
        );
        vm.stopPrank();

        // transfer dai to contract
        vm.startPrank(daiHolder);
        IERC20(coinSwap.tokenAddress("DAI")).transfer(
            address(coinSwap),
            40 ether
        );
        vm.stopPrank();
    }

    function testCoinSwapDeployment() public view {
        assert(
            coinSwap.dataFeed("ETH") ==
                0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        assert(
            coinSwap.dataFeed("LINK") ==
                0xc59E3633BAAC79493d908e63626716e204A45EdF
        );
        assert(
            coinSwap.dataFeed("DAI") ==
                0x14866185B1962B63C3Ea9E03Bc1da838bab34C19
        );
    }

    function testSwapEthToToken() public {
        IERC20 linkContract = IERC20(coinSwap.tokenAddress("LINK"));
        vm.startPrank(ethDaiHolder);
        uint256 linkBalance = linkContract.balanceOf(ethDaiHolder);
        // console2.log(ethDaiHolder.balance);
        // console2.log("linkBalance", linkBalance);
        coinSwap.swapETHForTokens{value: 0.05 ether}("LINK");
        vm.stopPrank();

        assert(linkContract.balanceOf(ethDaiHolder) > linkBalance);
    }

    function testSwapEthToTokenFailWithZeroEth() public {
        vm.startPrank(ethDaiHolder);
        vm.expectRevert(
            abi.encodeWithSelector(LibErrors.CANNOT_SWAP_ZERO_AMOUNT.selector)
        );
        coinSwap.swapETHForTokens{value: 0}("LINK");
        vm.stopPrank();
    }

    function testSwapETHToTokenFailWithoutEnoughPayoutAmount() public {
        vm.startPrank(ethHolder);
        vm.expectRevert(
            abi.encodeWithSelector(
                LibErrors.INSUFFICIENT_PAYOUT_BALANCE.selector
            )
        );
        coinSwap.swapETHForTokens{value: 200 ether}("LINK");
        vm.stopPrank();
    }

    function testSwapTokenToETH() public {
        vm.startPrank(ethDaiHolder);
        IERC20 daiContract = IERC20(coinSwap.tokenAddress("DAI"));

        uint256 daiBalance = daiContract.balanceOf(ethDaiHolder);
        uint256 ethBalance = ethDaiHolder.balance;
        // console2.log("eth balance", ethBalance);
        // console2.log("linkBalance", daiBalance);
        daiContract.approve(address(coinSwap), 1000 ether);
        coinSwap.swapTokensForETH("DAI", 1000 ether);
        vm.stopPrank();

        assert(daiContract.balanceOf(ethDaiHolder) < daiBalance);
        assert(ethDaiHolder.balance > ethBalance);
    }

    function testSwapTokenToETHFailWithoutApproval() public {
        vm.startPrank(ethDaiHolder);
        vm.expectRevert(
            abi.encodeWithSelector(
                LibErrors.INSUFFICIENT_TOKEN_ALLOWANCE.selector
            )
        );
        coinSwap.swapTokensForETH("DAI", 1000 ether);
        vm.stopPrank();
    }

    function testSwapTokenToETHFailWithoutEnoughPayoutAmount() public {
        IERC20 daiContract = IERC20(coinSwap.tokenAddress("DAI"));
        vm.startPrank(ethDaiHolder);

        daiContract.approve(address(coinSwap), 100_000 ether);

        vm.expectRevert(
            abi.encodeWithSelector(
                LibErrors.INSUFFICIENT_PAYOUT_BALANCE.selector
            )
        );
        coinSwap.swapTokensForETH("DAI", 100_000 ether);
        vm.stopPrank();
    }

    function testSwapTokenForToken() public {
        IERC20 daiContract = IERC20(coinSwap.tokenAddress("DAI"));
        IERC20 linkContract = IERC20(coinSwap.tokenAddress("LINK"));

        console2.log(
            "Contract link balance",
            linkContract.balanceOf(address(coinSwap))
        );

        vm.startPrank(ethDaiHolder);
        uint256 daiBalance = daiContract.balanceOf(ethDaiHolder);
        uint256 linkBalance = linkContract.balanceOf(ethDaiHolder);

        console2.log("Before dai balance", daiBalance);
        console2.log("Before link balance", linkBalance);

        daiContract.approve(address(coinSwap), 1 ether);
        coinSwap.swapTokensForTokens("DAI", "LINK", 1 ether);
        vm.stopPrank();

        console2.log("After dai balance", daiContract.balanceOf(ethDaiHolder));
        console2.log(
            "After link balance",
            linkContract.balanceOf(ethDaiHolder)
        );

        // assert(daiContract.balanceOf(ethDaiHolder) < daiBalance);
        // assert(linkContract.balanceOf(ethDaiHolder) > linkBalance);
    }
}
