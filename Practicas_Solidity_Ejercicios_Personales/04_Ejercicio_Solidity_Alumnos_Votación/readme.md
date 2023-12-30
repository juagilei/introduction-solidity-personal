# Ejercicio 4 Votaciones

## Contrato Votación

	El siguiente contrato muestra muchas de las características de Solidity. Implementa un contrato de votación. Por supuesto, los principales problemas de la votación electrónica son cómo asignar los derechos de voto a las personas correctas y cómo evitar la manipulación. No resolveremos todos los problemas aquí, pero al menos mostraremos cómo se puede delegar el voto para que el recuento de votos sea automático y completamente transparente al mismo tiempo.

- La idea es crear un contrato inteligente por papeleta, proporcionando un nombre corto para cada opción. A continuación, el creador del contrato, que actúa como presidente, otorgará el derecho de voto a cada dirección individualmente.

- La idea es crear un contrato inteligente por papeleta, proporcionando un nombre corto para cada opción. A continuación, el creador del contrato, que actúa como presidente, otorgará el derecho de voto a cada dirección individualmente.

- Las personas detrás de las addresses pueden elegir votar ellas mismas o delegar su voto en una persona de su confianza.

- Al final del tiempo de votación, propuestaGanadora() devolverá la propuesta con el mayor número de votos.

Seguiremos paso a paso el contrato.

## 1. Introcucir cabecera del contrato.

	Simplemente introduci,os la cabecera que tienen todos los contratos en solidity.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
```

## 2. Declaramos el contrato Votacion.

```
contract Votacion {
 // (entre las llaves va el código) 
}
```

## 3. Declaración de variables.

	Una vez declarado el contrato y siempre entre las llaves lo primero que hacemos es declarar todas las variables, mappings, arrays, eventos y modificadores en este orden. 

**Las declariones quedan de la siguiente forma:**


1. Crear variable presidente:

	Define una variable de estado llamada "presidente" de tipo address y haz que sea
pública (public). Esta variable almacenará la dirección del propietario del contrato.

	Una variable la definimos en el siguiente orden:
	- Tipo (int, bool, address, etc...).
	- Visualización (public, private).
	- Condición (payable, non payable(si no se pone nada se interpreta como non payable).

```
address public  presidente;
```
2. Crear variable Votante:

	Define una variable de estado llamada "Votante" de tipo struct. Esta variable contendrá las siguientes propiedades:
-  peso (entero): peso acumulado por el votante mediante delegación
-  votado (boolean): si es true, la persona ya habrá votado
-  delegado (address): persona delegada
-  voto (entero): índice votado del futuro array de propuestas de la votación

	Los struct son arrays con multiples variables, y se localizan por su posición en el array teniendo en cuenta que las posiciones en los array siempre empiezan por [0].

```
struct votante {
        uint256 peso;
        bool votado;
        address delegado;
        uint256 voto;
    }
```
3. Crear variable Propuesta:

	Define una variable de estado llamada "Propuesta" de tipo struct. Esta variable contendrá las siguientes propiedades:
- nombre (string): nombre corto de la propuesta de votación
- cantidadVotos (entero): número de votos acumulado

```
struct Propuesta {
        string nombre;
        uint256 cantidadVotos;

    }
```
4. Crear mapping votantes:

	Crea un mapeo llamado "votantes" que mapea el address del votante (address) con su struct Votante (struct) correspondiente. Este mapeo debe ser público (público).
De esta menera, almacenamos la relación entre el propio votante y sus decisiones a nivel de voto.

	La función del mapping es recorrer un struct para ir viendo los datos de las posiciones del struct (array)o para ir añadiendo datos al struct.

	Este mapping asigna direcciones (address) a cada votante, de esta forma ya tenemos una referencia con cada votante.

```
 mapping (address => votante) public votantes;
```
5. Crear array de Propuestas:

	Crea un array de Propuestas (Propuestas[]) llamado "propuestas" con visibilidad pública que almacenará todas las propuestas existentes de manera inicial (e.g., pongamos de ejemplo que son los candidatos a la presidencia).

	Vamos a crear un array que almacena los datos del struct propuesta.
```
Propuesta[] public propuestas ;
```
6. Crear evento DerechoVotoOtorgado:

	Crea un evento (event) llamado "DerechoVotoOtorgado" con los siguientes datos:
	- votante indexed (address)

	Evento para registrar cuando se otorga el derecho de voto.

	Los eventos tienen la característica de enviar datos con la pala ra reservada emit.
```
 event DerechoVotoOtorgado ( address indexed _votante );
```
7. Crear evento VotoDelegado
	Crea un evento (event) llamado "VotoDelegado" con los siguientes datos:
	- remitente indexed (address)
	- delegado indexed (address)

	Evento para registrar cuando se delega un voto.
```
event VotoDelegado (

        address indexed _remitente,
        address indexed _delegado
    );
```
8. Crear evento VotoEmitido:
	Crea un evento (event) llamado "VotoEmitido" con los siguientes datos:
	- votante indexed (address)
	- ropuestas indexed (entero)

	Evento para registrar cuando se emite un voto.
```
event VotoEmitido (

        address indexed _votante,
        uint256 indexed _propuestas
    );
```
9. Crear modificador soloPresidente:

	Crea un modificador (modifier) llamado "soloPresidente" el cual no requiere ningún tipo de variable de entrada y comprobará que el emisor de la petición (msg.sender) es el presidente, en caso contrario, fallará.

	Los modificadores se usan para crear execpciones require globales de esta forma con una palabra aplicamos la excepcion en vez de escribirla en todas las funciones que la necesitemos.

	El modifier siempre ha de terminar con _;, estomindica que continue ejecutandose al función.

```
modifier soloPresidente () {
        require (msg.sender == presidente, "No eres el propietario");
        _;
    }
```

## 4. Creamos un constructor.

	Una vez definidas las variables, pasamos a la crear el constructor.
	El constructor realmente es quien despliega el contrato, o sea lo construye puede tener variales de untrada o no, pero es una dirección que despliega el comtrato.

	En este caso creamos una función constructora (constructor) que contenga:

	Parámetros de entrada:

- Variable nombresPropuestas de tipo string[]. A través de la misma le pasaremos los nombre de todas las propuestas candidatas (en nuestro caso todos los candidatos a la presidencia).

	Descripción:

- Igualamos la variable presidente al propio emisor del despliegue.
- Ahora, deberemos introducir todos los nombres de propuestas que nos han llegado en el array de string (string[]) llamado propuestas.
	- Realizamos un bucle for() que comience por 0 y finalice cuando el valor de la variable que declaremos “i” sea >= nombresPropuestas.length (longitud máxima del array).

		- 	Dentro del propio bucle, lo que haremos será introducir dentro del array propuestas un objeto/struct por nombre que nos ha llegado en nombrePropuestas. Para ello utilizaremos la función push() de los arrays, con el fin de introducirle las Propuestas (propuestas.push(<INTRODUCIR_STRUCT_PROPUESTA*).
			
```
 constructor(string[] memory _nombresPropuestas) {
 presidente = msg.sender;

 for (uint256 i=0; i < _nombresPropuestas.length; i++) 
        {
 propuestas.push(Propuesta(_nombresPropuestas[i],0));
   }

    }
```
## 5. Implementar función darDerechoAVotar.

	Implementar la función “darDerechoAVotar” pública que permitirá al presidente dar derecho a votar a addresses específicas.
	Parámetros de entrada:
		- Variable votante de tipo address.
		- Modificador de función: soloPresidente.

	Descripción:

		- Comprobamos que el votante no haya votado, es decir, miramos dentro del mapping
		votantes, si el votante tiene la variable votado a “true”.

		- Comprobamos que al votante no se le haya asignado el derecho a votar previamente, es
		decir, miramos dentro del mapping votantes, si el votante tiene la variable peso a 0.

		- Ahora añadiros al array de votantes al propio votante accediendo a su variable
		peso y asignándole valor 1 (votantes[votante].peso).

		- Por último, emitimos el evento DerechoDeVotoOtorgado.
```
  function darDerechoAVotar (address _votante) public soloPresidente {

	require(votantes[_votante].votado == false, "El votante ya ha votado");
	require(votantes[_votante].peso == 0, "Al usuario ya se le ha otorgado derecho a votar");
	votantes[_votante].peso = 1;

 	emit DerechoVotoOtorgado(_votante);

    }
```
## 6. Implementar función delegar.
	Implementar la función “delegar” pública que permitirá delegar el voto a otra persona.
		Parámetros de entrada:
			-  Variable receptor de tipo address.

Descripción:
- Comprobamos que el emisor de la petición tenga un peso != 0 porque sino no podría votar ni delegar el voto (para ello accedemos al mapping de votantes).
- Comprobamos que el emisor de la petición tenga un tenga la variable votado sea = false porque sino ya habría votado (para ello accedemos al mapping de votantes).
- Comprobamos que el address del emisor no coincida con el address enviado como parámetro de entrada receptor.
- Realizamos un bucle while que compruebe si el receptor ha establecido ya un delegado de voto, mapping de votantes[receptor], es decir, si ese valor es distinto de 0.
	- Dentro del bucle estableceremos la variable receptor = al delegado que tenga establecido el votantes[receptor], es decir, que si el receptor ya tiene un delegado elegido, ese será el nuevo receptor.
	-  Finalmente, se realiza un comprobación para ver si el receptor es distinto del emisor de la recepción, ya que sino habría un bucle en la delegación.
- Al salir del bucle, vamos a comprobar que el peso de votantes[receptor] sea >= 1, ya que esto nos dejará claro si tiene derecho a voto o no.
- Tras esto, vamos a establecer las variables votado=true y delegado=receptor de votantes[msg.sender] (del emisor que quiere delegar), ya que de este modo ya se habrá delegado el voto y aparece como voto completado.
- Finalmente, comprobamos en base a if/else:
	- If votantes[receptor] ya ha votado
		-  Si el delegado ya votó, añade directamente al número de votos el peso del que delegó el voto (usar propuestas[votantes[receptor].voto] para acceder a la cantidadVotos e incrementarla en base al peso del receptor)
		- Sino, se incrementa el peso del delegado añadiéndole el peso del remitente. A votantes[receptor].peso le añadimos el peso de votantes[msg.sender].peso.
- Para finalizar, emitimos el evento de VotoDelegado con los parámetros correspondientes.



```
 function delegar(address _receptor) public {
        require(votantes[msg.sender].peso != 0, "No tiene derecho a votar ni delegar");
        require(!votantes[msg.sender].votado, "Ya has votado");
        require(msg.sender != _receptor, "Estas delegando en ti mismo");
```

	Iván delega en Laura => Laura delega en Pedro => Pedro no delega (nuevo _receptor)
	Dentro del bucle estableceremos la variable receptor = al delegado que tenga establecido el votantes[receptor], es decir, que si el receptor ya tiene un delegado elegido, ese será el nuevo receptor.    
        
    Asigno a receptor una dirección que le delega el voto

```

	while(votantes[_receptor].delegado != address(0)) {
 
        	_receptor = votantes[_receptor].delegado;
        	require(_receptor != msg.sender, "No se admiten bucles hacia el emisor");
        }
```


	Finalmente, se realiza un comprobación para ver si el receptor es distinto del emisor de la recepción, ya que sino habría un bucle en la delegación.
```
require(votantes[_receptor].peso >= 1, "No tiene derecho a votar");
```


       
	Vamos a establecer las variables votado=true y delegado=receptor de votantes[msg.sender] (del emisor que quiere delegar), ya que de este modo ya se habrá delegado el voto y aparece como voto completado.

```
    	votantes[msg.sender].votado = true;
    	votantes[msg.sender].delegado = _receptor;
```
- Finalmente, comprobamos en base a if/else:
	- If votantes[receptor] ya ha votado
		-  Si el delegado ya votó, añade directamente al número de votos el peso del que delegó el voto (usar propuestas[votantes[receptor].voto] para acceder a la cantidadVotos e incrementarla en base al peso del receptor)
		- Sino, se incrementa el peso del delegado añadiéndole el peso del remitente. A votantes[receptor].peso le añadimos el peso de votantes[msg.sender].peso.
- Para finalizar, emitimos el evento de VotoDelegado con los parámetros correspondientes.

```
 if(votantes[_receptor].votado) { // Pedro ha votado a Feijó | Feijó tiene 5 votos | Laura delega en Pedro 1 voto => Feijó tiene 6 votos
            propuestas[votantes[_receptor].voto].cantidadVotos += votantes[msg.sender].peso;
        }
        else {
            votantes[_receptor].peso += votantes[msg.sender].peso;
        }

        emit VotoDelegado(msg.sender, _receptor);
    }
```
## 7. Implementar la función “votar”.
Implementar la función “votar” pública que permitirá votar a aquellos que puedan votantes a los que se les haya otorgado previamente el voto.
```
function votar (uint256 _proposicion) public  {
```
Comprobamos que al votante se le haya asignado el derecho a votar previamente, es decir, miramos dentro del mapping votantes, si el votante tiene la variable peso != 0 o >0.
```
 require(votantes[msg.sender].peso >0, "No tienes derecho a voto");
```
Comprobamos que el votante no haya votado (del msg.sender), es decir, miramos dentro del mapping votantes si el votante tiene la variable votado a “true”.
```
  require(!votantes[msg.sender].votado, "Ya has votado");
```
Ponemos al votante con la variable a true y voto = a la proposición realizada.
```
	votantes[msg.sender].votado = true;
        votantes[msg.sender].voto = _proposicion;
```
Actualizamos la cantidadVotos dentro del array de propuestas el correspondiente al índice de la proposición (propuestas[proposicion]) que nos han pasado con el peso total que tenía el votante (votantes[msg.sender]).
```
 	propuestas[_proposicion].cantidadVotos += votantes[msg.sender].peso;

        emit VotoEmitido(msg.sender, _proposicion);
```
## 8. Implementar función propuestaGanadora.
Implementar la función “propuestaGanadora” private que permitirá obtener el índice de la propuesta ganadora.

	Parámetros de salida:

		- Variable de tipo entero correspondiente al índice de la propuesta ganadora.
Descripción:

Declaramos e inicializamos dos variables a 0 que serán la
cantidadVotosGanadores e indicePropuestaGanadora.
-  Recorremos con un bucle for el tamaño de las propuesta (propuestas.length).

	- Dentro de este, comprobaremos con un if si la cantidadVotos de la propuesta que estamos recorriendo (e.g., propuestas[p]) > cantidadVotosGanadores.
	- Si entra en dicho if, actualizamos cantidadVotosGanadores con cantidadVotos de la propuesta que va ganando y el indicePropuestaGanadora con el índice de de la propuesta que estamos recorriendo (e.g., “p”).

- Fuera del bucle for, devolveremos el indicePropuestaGanadora. 
```
 function propuestaGanadora() private view returns(uint256) {
        uint256 cantidadVotosGanadores = 0;
        uint256 indicePropuestaGanadora = 0;
        for(uint256 i = 0; i < propuestas.length; i++) {
            if(propuestas[i].cantidadVotos > cantidadVotosGanadores) {
                cantidadVotosGanadores = propuestas[i].cantidadVotos;
                indicePropuestaGanadora = i;
            }
        }
        // Propuesta("Pedro", 5) | Propuesta("Feijó", 6)
        return indicePropuestaGanadora;
    }
```
## 9. Implementar función nombreGanador.
Implementar la función “propuestaGanadora” public que devolverá el nombre de la propuesta ganadora.

Parámetros de salida:
- Variable nombre de la propuesta ganadora de tipo string.

Descripción:
- Esta función será tan sencilla como devolver el nombre de la propuesta ganadora
invocando a la función propuestaGanadora() para obtener el índice de la misma (pista: propuestas[propuestaGanadora()]).
```
  function nombreGanador() public view returns(string memory) {
        return propuestas[propuestaGanadora()].nombre;
    }
```
## 10. Ejemplo de función devolver un struct.

```
 function devolverStruct() public view returns(Votante memory, Votante memory) {
        // return(Votante(0, false, address(0), 1));
        return(
            votantes[msg.sender],
            Votante(0, false, address(0), 1)
        );
    }
```





















