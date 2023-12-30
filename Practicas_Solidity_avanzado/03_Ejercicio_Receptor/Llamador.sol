// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Llamador {

    event LlamadaExitosa(address indexed llamador, address indexed receptor, uint256 monto);

    function llamarYPagar(address payable receptor) external payable {
        require ( msg.value > 0, "Se debe de introducir alguna cantidad ");

         (bool success, ) = receptor.call{value: msg.value}("");
        
        require(success, "Error al realizar la llamada");

        emit LlamadaExitosa(msg.sender, receptor,msg.value);
    }
    
}