// SPDX-License-Identifier: MIT
// Christian Mereles

pragma solidity ^0.8.17;

enum TypeOfService {
    Sueldos,
    Arreglos,
    Servicios,
    Otros
}

contract Service {
    TypeOfService public typeOfService;

    constructor(TypeOfService _typeOfService) {
        typeOfService = _typeOfService;
    }

    receive() external payable {}

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
