// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/CoinSwap.sol";

contract CoinSwapScript is Script {
    function setUp() public {}

    function run() public {
        uint256 pK = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pK);
        CoinSwap coinSwap = new CoinSwap();
        console2.log("CoinSwap contract address: ", address(coinSwap));
        vm.stopBroadcast();
    }
}
