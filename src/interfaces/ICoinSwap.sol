// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinSwap {
    event Swap(address indexed user, string base, string quote, uint256 payout);

    function dataFeed(string memory) external view returns (address);
    function tokenAddress(string memory) external view returns (address);

    function swapTokensForTokens(
        string memory _base,
        string memory _quote,
        uint256 _amount
    ) external;

    function swapTokensForETH(string memory _base, uint256 _amount) external;

    function swapETHForTokens(string memory _quote) external payable;
}
