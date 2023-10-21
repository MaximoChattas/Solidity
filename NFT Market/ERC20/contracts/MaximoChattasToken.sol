//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // OpenZeppelin package contains implementation of the ERC 20 standard, which our NFT smart contract will inherit

contract MaximoChattasToken is ERC20 {
    uint constant _initial_supply = 10000000 * (10 ** 18); // 10.000.000 MCT

    constructor() public ERC20("MaximoChattasToken", "MCT") {
        _mint(msg.sender, _initial_supply);
    }
}
