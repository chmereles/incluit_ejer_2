// SPDX-License-Identifier: MIT
// Christian Mereles

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./User.sol";
import "./Service.sol";

contract Consorcio is Ownable {
    event PaymentMade(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    mapping(address => Payer) private _payers;

    Employee[] private _employees;
    Service[] private _services;

    /**
     * @dev Crea un instancia de `Consorcio`
     *
     * Agrega los servicios a `services`.
     */
    constructor() payable {
        _addServices();
    }

    /**
     * @dev Verifica que sea un usuario pagador con responsabilidad de
     * pagar expensas
     *
     * Para que el address sea valida, tiene que estar agregada en el
     * `_payers`.
     *
     * @param _addr address a controlar
     */
    modifier isPayingUser(address _addr) {
        require(
            address(_payers[_addr]) != address(0),
            "Consorcio: El usuario no puede realizar pagos"
        );
        _;
    }

    /**
     * @dev Verifica una cantidad y el balance del contrato
     *
     * `Requerimientos`
     * - `_amount` tiene que ser mayor a cero
     * - el balace del contrato tienen que se mayor que `_amount`
     *
     * @param _amount cantidad a controlar
     */
    modifier isAmountAndBalaceOk(uint256 _amount) {
        require(_amount > 0, "Consorcio: El monto debe ser mayor a cero");
        require(
            address(this).balance > _amount,
            "Consorcio: Saldo insuficiente"
        );
        _;
    }

    /**
     * @dev Emite el evento `isPaymentOk`, despues que se ejectue la funcion
     *
     * @param _to address a la que se le realiza un pago
     * @param _amount monto del pago
     */
    modifier isPaymentOk(address _to, uint256 _amount) {
        _;
        emit PaymentMade(_to, _amount);
    }

    /**
     * @dev Pagar expensas
     *
     * Se valida que la transferencia se realiza correctamente, con el modificador `isPaymentOk`
     *
     * `Requerimientos`
     * - El usuario tiene que tener la responsabilidad de pagar expensas
     */
    function payExpenses()
        public
        payable
        isPayingUser(msg.sender)
        isPaymentOk(msg.sender, msg.value)
    {}

    /**
     * @dev Agregar al contrato, un usuario con responsabilidad de pagar expensas.
     *
     * `Requerimientos`
     * - solo el admin puede agregar usuarios
     *
     * @param _addr El address del usuario.
     * @param _name Nombre del usuario.
     */
    function addPayerUser(address _addr, string memory _name) public onlyOwner {
        _payers[_addr] = new Payer(_name);
    }

    /**
     * @dev Devuelve el balace el contrato.
     *
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Agregar al contrato, un usuario tipo empleado, que pueda recibir pagos.
     *
     * `Requerimientos`
     * - solo el admin puede agregar usuarios
     *
     * @param _emp El usuario de tipo `Employee`.
     */
    function addEmployeeUser(Employee _emp) public onlyOwner {
        _employees.push(_emp);
    }

    /**
     * @dev Pagar a los empleados.
     *
     * `Requerimientos`
     * - solo el admin puede realizar el pago
     * - la cantidad a pagar y el balace del contrato, tienen que ser correctos
     * - solo se puede pagar a los empleados que se agreguen al array `_employees`
     *
     * @param _index El indice del array `_employees`.
     * @param _amount La cantidad a pagar.
     */
    function payEmployee(uint256 _index, uint256 _amount)
        public
        onlyOwner
        isAmountAndBalaceOk(_amount)
    {
        require(_index < _employees.length, "Consorcio: El empleado no existe");

        payable(_employees[_index]).transfer(_amount);
    }

    /**
     * @dev Pagar a los servicios de la lista.
     *
     * Se valida que la transferencia se realiza correctamente, con el modificador `isPaymentOk`
     *
     * `Requerimientos`
     * - solo el admin puede realizar el pago
     * - la cantidad a pagar y el balace del contrato, tienen que ser correctos
     * - solo se puede pagar servicios que se encuentren en `_services`
     *
     * @param _serviceIndex El indice del array `_employees`.
     * @param _amount La cantidad a pagar.
     */
    function payService(uint256 _serviceIndex, uint256 _amount)
        public
        onlyOwner
        isAmountAndBalaceOk(_amount)
        isPaymentOk(address(_services[_serviceIndex]), _amount)
    {
        require(
            _serviceIndex < _services.length,
            "Consorcio: El servicio no existe"
        );

        payable(_services[_serviceIndex]).transfer(_amount);
    }

    /**
     * @dev Pagar cosas puntuales.
     *
     * Se valida que la transferencia se realiza correctamente, con el modificador `isPaymentOk`
     *
     * `Requerimientos`
     * - solo el admin puede realizar el pago
     * - la cantidad a pagar y el balace del contrato, tienen que ser correctos
     *
     * @param _to El address a la cual se realiza el pago.
     * @param _amount La cantidad a pagar.
     */
    function specificPayment(address payable _to, uint256 _amount)
        public
        onlyOwner
        isAmountAndBalaceOk(_amount)
        isPaymentOk(_to, _amount)
    {
        _to.transfer(_amount);
    }

    /**
     * @dev Agregar servicios a array `_services`.
     */
    function _addServices() private {
        _services.push(new Service(TypeOfService.Sueldos));
        _services.push(new Service(TypeOfService.Arreglos));
        _services.push(new Service(TypeOfService.Servicios));
        _services.push(new Service(TypeOfService.Otros));
    }

    function getService(uint _serviceIndex) public view returns(Service) {
        return _services[_serviceIndex];
    }
}
