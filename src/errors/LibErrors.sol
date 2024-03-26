// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibErrors {
    error CANNOT_SWAP_ZERO_AMOUNT();
    error INSUFFICIENT_TOKEN_ALLOWANCE();
    error INSUFFICIENT_PAYOUT_BALANCE();
    error SWAP_TRANSFER_FAILED();
    error PAYOUT_TRANSFER_FAILED();
}
