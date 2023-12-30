// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Subasta {
    // entre estas llaves se escribe todoel contrato
    // Define una variable de estado llamada "propietario" de tipo address y haz que sea pública (public). 
    // Esta variable almacenará la dirección del propietario del contrato y de la subasta.
    address public propietario;

    // Define una variable de estado llamada "beneficiario" de tipo address payable y haz que
    // sea pública (public). Esta variable almacenará la dirección del beneficiario de la subasta.

    address payable public beneficiario;

    // Define una variable de estado llamada "finSubasta" de tipo entero y haz que sea pública (public). 
    // Esta variable almacenará el momento de finalización de la subasta.

    uint256 public finSubasta;

    // Define una variable de estado llamada "mejorPostor" de tipo address y haz que sea pública (public). 
    // Esta variable almacenará el address de la persona con la puja más alta.

    address public mejorPostor;

    // Define una variable de estado llamada "mejorOferta" de tipo entero y haz que sea pública (public).
    // Esta variable almacenará la cantidad de la puja más alta.

    uint256 public mejorOferta;

    // Define una variable de estado llamada "devolucionesPendientes" de tipo mapping que relacione address con un entero.
    // Esta variable almacenará el address de todos aquellos postores cuya puja ya no se encuentra vigente debido a alguna otra. 
    // El número entero representa la cantidad que se le debe devolver al propio postor 
    // (ya que ha enviado ether al contrato para poder realizar la puja y ahora debemos devolvérselo).

    mapping (address=>uint256) devolucionesPendientes;

    // Define una variable de estado llamada "finalizada" de tipo boolean que reflejará si la subasta ha terminado o no.

    bool finalizada;

    // Crea un evento (event) llamado " OfertaMasAltaIncrementada " con los siguientes datos:
    // ● postor (address)
    // ● cantidad (entero)
    // Evento para registrar el establecimiento de una nueva puja máxima.

    event OfertaMasAltaIncrementada (address indexed postor, uint256 cantidad);

    // Crea un evento (event) llamado " SubastaFinalizada" con los siguientes datos:
    // ● ganador (address)
    // ● cantidad (entero)
    // Evento para registrar al ganador definitivo de la subasta.

    event SubastaFinalizada (address indexed ganador, uint256 cantidad);

    // Creacion de errores.
    
    /// La subasta ya ha finalizado.
    error SubastaYaFinalizada();
    /// Ya existe una oferta igual o superior.
    error OfertaNoSuficientementeAlta(uint256 mejorOferta);
    /// La subasta aún no ha finalizado.
    error SubastaNoFinalizadaTodavia();
    /// La función auctionEnd ya ha sido llamada.
    error FinSubastaYaLlamado();

    // Crea un modificador (modifier) llamado " soloPropietario" con la siguiente condición:
    // ● Comprobamos que el emisor de la petición sea el propietario y sino devolvemos un mensaje de error.

    modifier soloPropietario () {
        require(msg.sender == propietario, "No eres el propietario");
        _;
    }

    // Crea una función constructora (constructor) que contenga:

	// Parámetros de entrada:

	// - Variable tiempoOferta de tipo entero. A través de esta pasaremos el tiempo en segundos que durará la oferta (e.g., si fuera 10 minutos deberíamos pasar = 10 min * 60 seg = 600 seg).

	// - Variable addressBeneficiario de tipo address payable, que representará la persona a la que se transferirán los fondos una vez que la subasta finalice.

    constructor(uint256 tiempoOferta, address payable addressBeneficiario) {

        propietario = msg.sender;
        beneficiario = addressBeneficiario;
        finSubasta = block.timestamp + tiempoOferta;
        
    }

    // Implementar la función “ofertar” pública y payable que permitirá establecer una puja en la subasta.

    function ofertar() public payable {
    // Comprobamos (mediante un if) que la subasta no ha terminado. 
    // Para ello, cogeremos el momento actual a nivel de fecha y tiempo (block.timestamp) veremos si es superior a la fecha de finSubasta.
    // Devolvemos el error anteriormente definido SubastaYaFinazada.

        if (block.timestamp > finSubasta) {
            revert SubastaYaFinalizada();
        }
    // Tras esto, comprobamos (mediante un if) si el valor recibido en ether es inferior o igual a la actual mejorOferta.
    // En caso de que la cantidad de ether enviada sea igual o menor, lanzaremos un revert con el error OfertaNoSuficientementeAlta().    
        if (msg.value <= mejorOferta) {
            revert OfertaNoSuficientementeAlta(mejorOferta);
        }
    // Finalmente, comprobamos (mediante un if) si la mejor oferta que nos han enviado es distinta de 0.
    // En caso de así sea, sumamos al mapping de devolucionesPendientes del mejorPostor actual la mejorOferta que realizó, 
    // ya que ha sido sobrepujado y habrá que devolverle la puja inicial.

        if (mejorOferta !=0 ) {
        // añado al mapping la dirección del mejor postor y le asigno el valor de la oferta
            devolucionesPendientes[mejorPostor] += mejorOferta;
        }
    // Una vez hemos realizado todas las comprobaciones, 
    // estableceremos la variable mejorPostor con el valor del nuevo ganador y la variable mejorOferta con el valor en ether que ha enviado el emisor.

    mejorPostor = msg.sender;
    mejorOferta = msg.value;

    // Finalmente, emitimos el evento OfertaMasAltaIncrementada con el emisor y la cantidad de ether enviado.

    emit OfertaMasAltaIncrementada(mejorPostor, mejorOferta);
    }

    // Implementar la función “retirar” pública que permitirá retirar al usuario que previamente ha pujado, 
    //  pero ya no es el ganador, la cantidad de ether enviada inicialmente.

    function retirar () public returns (bool) {
    // Inicialmente, crearemos una variable local llamada cantidad de tipo entero que sea igual a la cantidad pendiente de retirar 
    // por el emisor (recordar el mapping devolucionesPendientes).

    uint256 cantidad = devolucionesPendientes[msg.sender];

    // Comprobamos (mediante un if) si la cantidad es superior a 0.

    if (cantidad >0) {
        // Comprobamos (mediante un if) si no conseguimos realizar el <address_payable>.send(cantidad) al emisor de la petición de retirar.
		// - En caso de que esto sea false, es decir, que no consigamos enviar la cantidad pertinente mediante al función send, 
        // establecemos de nuevo devolucionesPendientes del emisor igual a la cantidad previa.
        if (!payable(msg.sender).send(cantidad)){
            return false;
        }
        // En caso afirmativo, dejamos a 0 la cantidad pendiente por devolver al emisor (devolucionesPendientes).
        devolucionesPendientes[msg.sender] = 0;
        // Finalmente, retornamos true al completar el proceso.
            return true;

    }
    return false;
    }

    // Implementar la función “finalizarSubasta” pública que permitirá poner fin al proceso de subasta y establecer el ganador final.
    //Modificador: soloPropietario.

    function finalizarSubasta() public soloPropietario {

        // Inicialmente, comprobaremos (mediante if) si el tiempo de finSubasta establecido es mayor que la fecha y tiempo actual.
        //  ○ En caso de que así sea, significará que la subasta aún no ha llegado a la fecha límite, por lo que lanzamos un revert con el error
        // SubastaNoFinalizadaTodavia().

        if (finSubasta>block.timestamp) {
            revert SubastaNoFinalizadaTodavia();
        }
        // Comprobamos (mediante if), si la variable finalizada está a true o false.
        // ○ En caso de estar a true, significaría que la subasta ya ha finalizado y lanzaríamos un revert con el error FinSubastaYaLlamado().

        if(finalizada){
            revert FinSubastaYaLlamado();
        }
        // Tras estas comprobaciones y sabiendo que la subasta ya puede finalizarse, establecemos la variable finalizada a true.

        finalizada = true;

        // transferimos los fondos de la subasta al beneficiario que habíamos establecido previamente (en esta ocasión utilizaremos transfer ya que no queremos
        // controlar los posibles errores por nuestra cuenta).

        beneficiario.transfer(mejorOferta);

        // Emitimos el evento SubastaFinalizada pasándole el mejorPostor y la mejorOferta.

        emit SubastaFinalizada(mejorPostor, mejorOferta);
    }
}