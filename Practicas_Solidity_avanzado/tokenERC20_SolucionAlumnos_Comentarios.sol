// SPDX-License-Identifier: MIT

// Versión del compilador de Solidity.
pragma solidity ^0.8.0;

// Importa la interfaz ERC20 del paquete OpenZeppelin.
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Definición del contrato MyToken que implementa la interfaz ERC20.
contract MyToken is IERC20 {
    // Variables para almacenar el nombre, símbolo y decimales del token.
    string private _name;     // TODO: Rellenar con el nombre del token.
    string private _symbol;   // TODO: Rellenar con el símbolo del token.
    uint8 private _decimals;  // TODO: Rellenar con la cantidad de decimales del token.

    // Mappings para almacenar balances y asignaciones permitidas.
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Variable para almacenar el suministro total de tokens.
    uint256 private _totalSupply;

    // Constructor del contrato que establece el nombre, símbolo y suministro total.
    constructor(string memory name_, string memory symbol_, address initialAccount) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _totalSupply = 1000000 * 10**uint256(_decimals);
        _balances[initialAccount] = _totalSupply;
        emit Transfer(address(0), initialAccount, _totalSupply);
    }


    // Funciones para obtener el nombre, símbolo, decimales y suministro total del token.
    function name() public view returns (string memory) {
        return _name;   // TODO: Devolver el nombre del token.
    }

    function symbol() public view returns (string memory) {
        return _symbol;   // TODO: Devolver el símbolo del token.
    }

    function decimals() public view returns (uint8) {
        return _decimals;   // TODO: Devolver la cantidad de decimales del token.
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;   // TODO: Devolver el suministro total del token.
    }

    // Funciones para obtener el balance, realizar transferencias, y consultar asignaciones permitidas.
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];   // TODO: Devolver el balance de la dirección proporcionada.
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);   // TODO: Llamar a la función de transferencia interna.
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];   // TODO: Devolver la asignación permitida para el spender desde el owner.
    }

    // Funciones para aprobar transferencias y realizar transferencias desde.
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);   // TODO: Llamar a la función interna de aprobación.
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);   // TODO: Llamar a la función de transferencia interna.
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);   // TODO: Actualizar la asignación permitida.
        return true;
    }

    // Funciones para aumentar y disminuir asignaciones permitidas.
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);   // TODO: Aumentar la asignación permitida.
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);   // TODO: Disminuir la asignación permitida.
        return true;
    }

    // Función interna para realizar la transferencia de tokens.
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Sender cannot be the zero address");   // Verificar que el remitente no sea la dirección cero.
        require(recipient != address(0), "Recipient cannot be the zero address");   // Verificar que el destinatario no sea la dirección cero.

        _balances[sender] -= amount;   // Restar el monto del remitente.
        _balances[recipient] += amount;   // Sumar el monto al destinatario.
        emit Transfer(sender, recipient, amount);   // Emitir el evento de transferencia.
    }

    // Función interna para aprobar asignaciones permitidas.
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");   // Verificar que el propietario no sea la dirección cero.
        require(spender != address(0), "ERC20: approve to the zero address");   // Verificar que el spender no sea la dirección cero.

        _allowances[owner][spender] = amount;   // Establecer la asignación permitida.
        emit Approval(owner, spender, amount);   // Emitir el evento de aprobación.
    }
}
