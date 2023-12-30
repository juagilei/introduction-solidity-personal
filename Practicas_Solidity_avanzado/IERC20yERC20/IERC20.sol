// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Interfaz ERC-20 estándar, definida por OpenZeppelin.
interface IERC20 {
    // Devuelve el suministro total de tokens en circulación.
    function totalSupply() external view returns (uint);

    // Devuelve el balance de tokens de una dirección específica.
    function balanceOf(address account) external view returns (uint);

    // Transfiere una cantidad específica de tokens a la dirección del destinatario.
    function transfer(address recipient, uint amount) external returns (bool);

    // Devuelve la cantidad de tokens que el 'spender' tiene permiso para gastar en nombre del 'owner'.
    function allowance(address owner, address spender) external view returns (uint);

    // Permite al 'spender' gastar una cantidad específica de tokens en nombre del 'owner'.
    function approve(address spender, uint amount) external returns (bool);

    // Transfiere una cantidad específica de tokens desde el remitente original a la dirección del destinatario.
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    // Evento emitido cuando se realiza una transferencia de tokens.
    event Transfer(address indexed from, address indexed to, uint value);

    // Evento emitido cuando se aprueba una asignación de tokens.
    event Approval(address indexed owner, address indexed spender, uint value);
}
