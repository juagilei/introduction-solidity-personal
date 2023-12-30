// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importa la interfaz ERC-20 estándar.
import "./IERC20.sol";

// Contrato ERC-20 que implementa la interfaz ERC-20.
contract ERC20 is IERC20 {
    // Variable para almacenar el suministro total de tokens.
    uint public totalSupply;

    // Mapping para almacenar los saldos de las direcciones.
    mapping(address => uint) public balanceOf;

    // Mapping para almacenar las asignaciones permitidas.
    mapping(address => mapping(address => uint)) public allowance;

    // Variables para el nombre, símbolo y decimales del token.
    string public name = "BM Solidity";
    string public symbol = "BMS";
    uint8 public decimals = 18;

    // Constructor del contrato que asigna 100 tokens al desplegarlo.
    constructor() {
        totalSupply = 100; //* 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Función para realizar una transferencia de tokens.
    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Función para aprobar una asignación de tokens a un spender.
    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Función para realizar una transferencia de tokens desde una dirección a otra.
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Función para crear nuevos tokens y asignarlos al remitente.
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // Función para destruir tokens del remitente.
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
