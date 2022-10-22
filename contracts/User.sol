// SPDX-License-Identifier: MIT
// Christian Mereles

pragma solidity ^0.8.17;

/**
 * @dev Contrato base para los usuario de la dApp
 *
 */
contract User {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

/**
 * @dev Contrato que representa los usuarios que tengan responsabilidad de pagar expensas
 *
 */
contract Payer is User {
    constructor(string memory _name) User(_name) {}
}

/**
 * @dev Contrato que representa los usuarios que tengan que recibir un pago
 *
 */
contract Employee is User {
    constructor(string memory _name) User(_name) {}

    /**
     * @dev Permitir que el contrato pueda recibir dinero
     *
     */
    receive() external payable {}

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
