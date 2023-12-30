# 05 Ejercicio Subasta
Crea un nuevo contrato Solidity con el nombre "Subasta."

	Descripción del contrato: 

	La idea general del siguiente contrato de subasta es que todo el mundo puede enviar sus pujas durante un periodo estipulado de puja.

	- Las pujas ya incluyen el envío de alguna compensación, por ejemplo Ether, con el fin de vincular a los pujadores a su puja.

	- Si se sube la puja más alta, el anterior mejor postor recupera su Ether. 

	Una vez finalizado el periodo de pujas, el contrato tiene que ser llamado manualmente para que el beneficiario reciba su Ether - los contratos no pueden activarse por sí mismos.

## 1. Inroducimos la cabecera del contrato y declaramos el contrato subasta.
Recuerda que se declara como si fuera una clase y se le añaden las llaves para introducir dentro todo el contenido

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Subasta {
    // entre estas llaves se escribe todoel contrato
}
```
##  2. Declaración de variables.

1. Define una variable de estado llamada "propietario" de tipo address y haz que sea pública (public). Esta variable almacenará la dirección del propietario del contrato y de la subasta.

2. Define una variable de estado llamada "beneficiario" de tipo address payable y haz que sea pública (public). Esta variable almacenará la dirección del beneficiario de la subasta.

3. Define una variable de estado llamada "finSubasta" de tipo entero y haz que sea pública (public). Esta variable almacenará el momento de finalización de la subasta.

4. Define una variable de estado llamada "mejorPostor" de tipo address y haz que sea pública (public). Esta variable almacenará el address de la persona con la puja más alta.

5. Define una variable de estado llamada "mejorOferta" de tipo entero y haz que sea pública (public). Esta variable almacenará la cantidad de la puja más alta.

6. Define una variable de estado llamada "devolucionesPendientes" de tipo mapping que relacione address con un entero.

	- Esta variable almacenará el address de todos aquellos postores cuya puja ya no se encuentra vigente debido a alguna otra. El número entero representa la cantidad que se le debe devolver al propio postor (ya que ha enviado ether al contrato para poder realizar la puja y ahora debemos devolvérselo).


7. Define una variable de estado llamada "finalizada" de tipo boolean que reflejará si la subasta ha terminado o no.
```

address public propietario;

address payable public beneficiario; // 0x5828...

uint256 public finSubasta; // 1323423534231423 => 1 Nov 2023, 12:24:25

address public mejorPostor; // 0x5235...

uint256 public mejorOferta; // 3.5

mapping(address => uint256) devolucionesPendientes; // devolucionesPendientes['0x356'] => 3

bool finalizada;

```
## 3. Declaración de eventos.

1. Crea un evento (event) llamado " OfertaMasAltaIncrementada " con los siguientes datos:
	- postor (address)
	- cantidad (entero)

	Evento para registrar el establecimiento de una nueva puja máxima.

2. Crea un evento (event) llamado " SubastaFinalizada" con los siguientes datos:
	- ganador (address)
	- cantidad (entero)

	Evento para registrar al ganador definitivo de la subasta.

```

event OfertaMasAltaIncrementada(address indexed postor, uint256 cantidad);

event SubastaFinalizada(address indexed ganador, uint256 cantidad);

```
## 4. Crear errores.

	Es una forma de usar errores, en vez de usar require.
```
	/// La subasta ya ha finalizado.
    error SubastaYaFinalizada();
    /// Ya existe una oferta igual o superior.
    error OfertaNoSuficientementeAlta(uint256 mejorOferta);// devuelvo la cantidad de la mejor oferta
    /// La subasta aún no ha finalizado.
    error SubastaNoFinalizadaTodavia();
    /// La función auctionEnd ya ha sido llamada.
    error FinSubastaYaLlamado();
```
## 5. Declaración de modificadores.


	Crea un modificador (modifier) llamado " soloPropietario" con la siguiente condición:
	- Comprobamos que el emisor de la petición sea el propietario y sino devolvemos un mensaje de error.

```
modifier soloPropietario () {
        require(msg.sender == propietario, "No eres el propietario");
        _;
    }
```
## 6. Constructor.

Crea una función constructora (constructor) que contenga:

	Parámetros de entrada:

	- Variable tiempoOferta de tipo entero. A través de esta pasaremos el tiempo en segundos que durará la oferta (e.g., si fuera 10 minutos deberíamos pasar = 10 min * 60 seg = 600 seg).

	- Variable addressBeneficiario de tipo address payable, que representará la persona a la que se transferirán los fondos una vez que la subasta finalice.

Descripción:

	- Igualamos la variable beneficiario a la variable local / entrada de función addressBeneficiario.

	- Igualamos la variable finSubasta al momento actual a nivel de fecha y tiempo (block.timestamp) + la cantidad de segundos que nos han enviado bajo la variable tiempoOferta.
	- block.timestamp nos indica la fecha y la hora a nivel actual.
```
constructor(uint256 tiempoOferta, address payable addressBeneficiario)  {
        propietario = msg.sender;
        beneficiario = addressBeneficiario;
        finSubasta = block.timestamp + tiempoOferta;
    }
```
## 7. Implementación de funciones.

### 1. Implementar la función “ofertar” 

Implementar la función “ofertar” pública y payable que permitirá establecer una puja en la subasta.

	En esta función vamos a usar los errores definidos en vez de require.
	

	Descripción:

	- Comprobamos (mediante un if) que la subasta no ha terminado. Para ello, cogeremos el momento actual a nivel de fecha y tiempo (block.timestamp) veremos si es superior a la fecha de finSubasta.
		-  En caso de que el periodo de la subasta ya haya terminado, lanzaremos un revert con el error SubastaYaFinalizada().

	- Tras esto, comprobamos (mediante un if) si el valor recibido en ether es inferior o igual a la actual mejorOferta.
	- En caso de que la cantidad de ether enviada sea igual o menor, lanzaremos un revert con el error OfertaNoSuficientementeAlta().

	- Finalmente, comprobamos (mediante un if) si la mejor oferta que nos han enviado es distinta de 0.
	- En caso de así sea, sumamos al mapping de devolucionesPendientes del mejorPostor actual la mejorOferta que realizó, ya que ha sido sobrepujado y habrá que devolverle la puja inicial.

	- Una vez hemos realizado todas las comprobaciones, estableceremos la variable mejorPostor con el valor del nuevo ganador y la variable mejorOferta con el valor en ether que ha enviado el emisor.

	- Finalmente, emitimos el evento OfertaMasAltaIncrementada con el emisor y la cantidad de ether enviado.


```
 // Sin require
    function ofertar() public payable {

        if(block.timestamp > finSubasta) {
            revert SubastaYaFinalizada();
        }

        if(msg.value <= mejorOferta) {
            revert OfertaNoSuficientementeAlta(mejorOferta);
        }

        if(mejorOferta != 0) {
            devolucionesPendientes[mejorPostor] += mejorOferta;
        }

        mejorPostor = msg.sender;
        mejorOferta = msg.value;

        emit OfertaMasAltaIncrementada(mejorPostor, mejorOferta);
    }
```

### 2. Implementar la función “retirar” 
Implementar la función “retirar”pública que permitirá retirar al usuario que previamente ha pujado, pero ya no es el ganador, la cantidad de ether enviada inicialmente.

	Descripción:

- Inicialmente, crearemos una variable local llamada cantidad de tipo entero que sea igual a la cantidad pendiente de retirar por el emisor (recordar el mapping devolucionesPendientes).

- Comprobamos (mediante un if) si la cantidad es superior a 0.
	- En caso afirmativo, dejamos a 0 la cantidad pendiente por devolver al emisor (devolucionesPendientes).
	- Comprobamos (mediante un if) si no conseguimos realizar el <address_payable>.send(cantidad) al emisor de la petición de retirar.
		- En caso de que esto sea false, es decir, que no consigamos enviar la cantidad pertinente mediante al función send, establecemos de nuevo devolucionesPendientes del emisor igual a la cantidad previa.
		- Tras esto, retornamos false.

- Finalmente, retornamos true al completar el proceso.

```
function retirar() public returns(bool) {
        uint256 cantidad = devolucionesPendientes[msg.sender]; // valor que le debemos al emisor
        // te debo pasta
        if (cantidad > 0) {

            // no consigo realizar el envío de fondos
            if(!payable(msg.sender).send(cantidad)) { // !false => true
                return false;
            }

            // envío de fondos realizado
            devolucionesPendientes[msg.sender] = 0;
            return true;
        }
        return false;
    }
```
Otra opcion mucho mas sencilla es usar require:

```
 function retirar2() public {
        require(devolucionesPendientes[msg.sender] > 0, "No hay deudas pendientes para ti");
        require(!payable(msg.sender).send(devolucionesPendientes[msg.sender]), "No se han conseguido enviar los fondos");
        devolucionesPendientes[msg.sender] = 0;
    }
```

### 3. Implementar función finalizarSubasta.
Implementar la función “finalizarSubasta” pública que permitirá poner fin al proceso de subasta y establecer el ganador final.

Modificador: soloPropietario.

Descripción:
	
- Inicialmente, comprobaremos (mediante if) si el tiempo de finSubasta establecido es mayor que la fecha y tiempo actual.

		- En caso de que así sea, significará que la subasta aún no ha llegado a la fecha límite, por lo que lanzamos un revert con el error SubastaNoFinalizadaTodavia().

- Comprobamos (mediante if), si la variable finalizada está a true o false.

		- En caso de estar a true, significaría que la subasta ya ha finalizado y lanzaríamos un revert con el error FinSubastaYaLlamado().

- Tras estas comprobaciones y sabiendo que la subasta ya puede finalizarse, establecemos la variable finalizada a true.

- Transferimos los fondos de la subasta al beneficiario que habíamos establecido previamente (en esta ocasión utilizaremos transfer ya que no queremos controlar los posibles errores por nuestra cuenta).

- Emitimos el evento SubastaFinalizada pasándole el mejorPostor y la mejorOferta.

```
 function finalizarSubasta() public soloPropietario {
        if (finSubasta > block.timestamp) {
            revert SubastaNoFinalizadaTodavia();    
        }
        
        if(finalizada) {
            revert FinSubastaYaLlamado();
        }

        finalizada = true;
        beneficiario.transfer(mejorOferta);

        emit SubastaFinalizada(mejorPostor, mejorOferta);
    }
```












