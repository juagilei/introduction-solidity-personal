# Ejercicios solidity avanzado

	Vamos a realizar ejercicios con el estandar ERC20 para crear tokens y demas cosas.

	El estandar exige un interfaz tipo el cual lo importaremos en los contratos normalmente de la siguinete forma:

```
import "./IERC20.sol";
```

El archivo IERC20.sol tiene el siguiente codigo:
```
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
```
Os podéis ayudar con la información por ejemplo proporcionada por OpenZepellin en

[https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20)

o

[https://docs.openzeppelin.com/contracts/5.x/api/token/erc20](https://docs.openzeppelin.com/contracts/5.x/api/token/erc20)



