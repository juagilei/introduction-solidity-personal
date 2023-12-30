// Introducir cabecera contracto

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// Declarar “contract” BancoDescentralizado

contract BancoDescentralizado {

// Crear variable propietario
// Define una variable de estado llamada "propietario" de tipo address y haz que sea
// privada (private). Esta variable almacenará la dirección del propietario del contrato.

    address private propietario;

// Crea una función constructora (constructor) que establezca el valor de "propietario" como la dirección que despliega el contrato.

    constructor() {
        propietario = msg.sender;
    }

// Crea un mapeo llamado "saldos" que mapea la dirección de Ethereum del usuario 
// (de tipo address) con su saldo (de tipo entero). Este mapeo debe ser privado (private).

    mapping (address => uint256) private saldos;

// Implementar una función pública, de tipo payable (vamos a enviar ether al contrato inteligente) 
// llamada “depositar” sin parámetros de entrada.
// Descripción:
// ● Esta función debe permitir a cualquier usuario agregar saldo a su cuenta.
//      Para poder agregar saldo desde fuera del contrato la función debe de ser payable
// ● Asegúrate, de que el valor del mensaje / petición (msg.value) sea >0.
//      Utilizamos un require
// ● Finalmente, agrega la cantidad que ha enviado al mapping “saldos” del emisor del mensaje (msg.sender) 
//   con el valor en ether que ha enviado el propio usuario (msg.value).

function depositar() public payable {
    require (msg.sender != propietario, "El propietario no puede depositar fondos");
    require(msg.value > 0, "Envia Ether para tener saldo " );
    
    // Para usar el mapping primero necesito inicializar la clave, o sea decir una clave (en este caso address)
    // para asignar un valor (en este caso saldo) -> saldos[msg.sender]
    // Luego se asigno un saldo que viene de msg.value y para incrementarlo que sería 
    // (saldos[msg.sender] = saldos[msg.sender] +msg.value;) lo cambio por saldos[msg.sender] += msg.value

    saldos[msg.sender] += msg.value;

}

// Implementar una función pública llamada “retirar” (piensa en el tipo de mutabilidad).
// Parámetros de entrada:
//  ● Variable cantidad de tipo entero.
// Descripción:
//  ● Esta función NO debe permitir retirar fondos al propietario del contrato inteligente (propietario del banco).
//  ● Esta función debe comprobar que el saldo del emisor del mensaje (msg.sender)
//    es superior o igual (>=) a la cantidad que desea retirar.
//  ● El contrato debe actualizar el saldo del usuario restándole la cantidad que
//    desea retirar.
//  ● (EXTRA 1) Finalmente, usando la función “transfer()”, vamos a retirar saldo del
//    contrato inteligente (banco) y se lo vamos a devolver al usuario 
//    (esta parte la veremos en la clase de resolución de ejercicios, ya que vamos a utilizar funciones para retirar ether). 
//    De momento, copiar esto al final de la función.

function retirar(uint256 _cantidad) public  {

    require (msg.sender != propietario, "El propietario no puede retirar fondos de otras cuentas");
    require (saldos[msg.sender] >= _cantidad, "saldo insuficiente");
    saldos[msg.sender] -= _cantidad;
    
    // address payable solo esta en send y en transfer.
    // Por lo tanto la dirección address donde quiero enviar debe ser de tipo payable 
    // por lo que la tengo que convertir en payable.

    payable(msg.sender).transfer(_cantidad);

}
// Implementar una fucnión pública en la que pueda transferir fondos de una cuenta a otra dentro del contrato.

function transferir (address _receptor, uint256 _cantidad) public {

    require (msg.sender != propietario, "El propietario no puede retirar fondos de otras cuentas");
    require (saldos[msg.sender] >= _cantidad, "saldo insuficiente");
    require (saldos[_receptor] != 0, "La cuenta debe de estar en el Banco" );

    // Debo de comprobar si la cuenta donde hago la transferencia esta en el banco

    saldos[msg.sender] -= _cantidad;
    saldos[_receptor] += _cantidad;
}
// Implementar una función pública llamada obtenerSaldo (piensa en el tipo de mutabilidad). No precisa de parámetros de entrada.
// Descripción:
//  ● Esta función debe devolver el saldo de la persona emisora de la petición / mensaje (msg.sender)

function obtenerSaldo () public view returns(uint256) {

    return saldos[msg.sender];
}


}