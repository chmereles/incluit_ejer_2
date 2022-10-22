// SPDX-License-Identifier: MIT
// Christian Mereles

pragma solidity ^0.8.17;

contract User {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract Payer is User {
    constructor(string memory _name) User(_name) {}
}

contract Employee is User {
    constructor(string memory _name) User(_name) {}

    receive() external payable {}

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
