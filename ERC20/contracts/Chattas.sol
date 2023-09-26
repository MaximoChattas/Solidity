//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../artifacts/@openzeppelin/contracts/token/ERC20/ERC20.sol";  // OpenZeppelin package contains implementation of the ERC 20 standard, which our NFT smart contract will inherit

contract Chattas is ERC20 {
    uint constant _initial_supply = 10000 * (10**18);  // setting variable for how many of your own tokens are initially put into your wallet, feel free to edit the first number but make sure to leave the second number because we want to make sure our supply has 18 decimals

    /* ERC 20 constructor takes in 2 strings, feel free to change the first string to the name of your token name, and the second string to the corresponding symbol for your custom token name */
    constructor() ERC20("Chattas", "Chs") public {
        _mint(msg.sender, _initial_supply);
    }
}