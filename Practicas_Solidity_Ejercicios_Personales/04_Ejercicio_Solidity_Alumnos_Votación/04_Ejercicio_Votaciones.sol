// Introducir cabecera contracto

// SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

// Declarar “contract” Votación

    contract Votacion {
    
// Define una variable de estado llamada "presidente" de tipo address y haz que sea
// pública (public). Esta variable almacenará la dirección del propietario del contrato.

    address public  presidente;

// Define una variable de estado llamada "Votante" de tipo struct. Esta variable contendrá las siguientes propiedades:
//  ● peso (entero): peso acumulado por el votante mediante delegación
//  ● votado (boolean): si es true, la persona ya habrá votado
//  ● delegado (address): persona delegada
//  ● voto (entero): índice votado del futuro array de propuestas de la votación

    struct votante {
        uint256 peso;
        bool votado;
        address delegado;
        uint256 voto;
    }
// Define una variable de estado llamada "Propuesta" de tipo struct. Esta variable contendrá las siguientes propiedades:
//  ● nombre (string): nombre corto de la propuesta de votación
//  ● cantidadVotos (entero): número de votos acumulado

    struct Propuesta {
        string nombre;
        uint256 cantidadVotos;

    }

// Crea un mapeo llamado "votantes" que mapea el address del votante (address) con su struct Votante (struct) correspondiente. 
// Este mapeo debe ser público (público).
// De esta menera, almacenamos la relación entre el propio votante y sus decisiones a nivel de voto.

    mapping (address => votante) public votantes;

// Crea un array de Propuestas (Propuestas[]) llamado "propuestas" con visibilidad pública que almacenará todas las propuestas existentes de manera inicial 
// (e.g., pongamos de ejemplo que son los candidatos a la presidencia)..

    Propuesta[] public propuestas ; // almacena en un array el struc Propuesta --> [nombre,cantidadVotos] --> [("Pedro",2),("Juan",3),("Ana",4)]

// Crea un evento (event) llamado "DerechoVotoOtorgado" con los siguientes datos:
//  ● votante indexed (address)
// Evento para registrar cuando se otorga el derecho de voto.

    event DerechoVotoOtorgado ( address indexed _votante );

// Crea un evento (event) llamado "VotoDelegado" con los siguientes datos:
//  ● remitente indexed (address)
//  ● delegado indexed (address)
// Evento para registrar cuando se delega un voto.


    event VotoDelegado (

        address indexed _remitente,
        address indexed _delegado
    );

// Crea un evento (event) llamado "VotoEmitido" con los siguientes datos:
//  ● votante indexed (address)
//  ● propuestas indexed (entero)
// Evento para registrar cuando se emite un voto.

    event VotoEmitido (

        address indexed _votante,
        uint256 indexed _propuestas
    );

// Crea un modificador (modifier) llamado "soloPresidente" el cual no requiere ningún tipo de variable de entrada y 
// comprobará que el emisor de la petición (msg.sender) es el presidente, en caso contrario, fallará.

    modifier soloPresidente () {
        require (msg.sender == presidente, "No eres el propietario");
        _;
    }

// Crea una función constructora (constructor) que contenga:
// Parámetros de entrada:
//  ● Variable nombresPropuestas de tipo string[]. A través de la misma le pasaremos
//    los nombre de todas las propuestas candidatas (en nuestro caso todos los candidatos a la presidencia).

    constructor(string[] memory _nombresPropuestas) {
    
//  ● Igualamos la variable presidente al propio emisor del despliegue.

        presidente = msg.sender;

//  ● Ahora, deberemos introducir todos los nombres de propuestas que nos han llegado en el array de string (string[]) llamado propuestas.
//      ○ Realizamos un bucle for() que comience por 0 y finalice cuando el valor de la variable que declaremos “i” 
//          sea < nombresPropuestas.length (longitud máxima del array).

        for (uint256 i=0; i < _nombresPropuestas.length; i++) 
        {

//      ○ Dentro del propio bucle, lo que haremos será introducir dentro del array propuestas un objeto por nombre que nos ha llegado en nombrePropuestas. 
//          Para ello utilizaremos la función push() de los arrays, para introducirle las Propuestas (propuestas.push(<INTRODUCIR_STRUCT_PROPUESTA*).

            propuestas.push(Propuesta(_nombresPropuestas[i],0));

// otra forma forma de hacerlo seria de forma explícita:
//          propuestas.push( Propuesta({
//              nombre: _nombresPropuestas [i],
//              cantidadVotos: 0
//          });
        }

    }

// Implementar la función “darDerechoAVotar” pública que permitirá al presidente dar derecho a votar a addresses específicas.
// Parámetros de entrada:
//  ● Variable votante de tipo address.
// Modificador de función: 
//  ● soloPresidente.

    function darDerechoAVotar (address _votante) public soloPresidente {

// Comprobamos que el votante no haya votado, es decir, miramos dentro del mapping votantes, si el votante tiene la variable votado a “true”.

    require(votantes[_votante].votado == false, "El votante ya ha votado");

// También podemos definir el require  de la siguiente forma require(!votantes[Votante].votado, "El votante ya ha votado"); negando directamente el true con !

// Comprobamos que al votante no se le haya asignado el derecho a votar previamente, es decir, miramos dentro del mapping votantes, 
// si el votante tiene la variable peso a 0.

    require(votantes[_votante].peso == 0, "El votate ya tiene el derecho a votar");

// Ahora añadiros al array de votantes al propio votante accediendo a su variable peso y asignándole valor 1 (votantes[votante].peso).

votantes[_votante].peso = 1;

// Por último, emitimos el evento DerechoDeVotoOtorgado.

    emit DerechoVotoOtorgado(_votante);

    }

// Implementar la función “delegar” pública que permitirá delegar el voto a otra persona.
// Parámetros de entrada:
//  ● Variable receptor de tipo address.

    function delegar (address _receptor) public  {
    
// Comprobamos que el emisor de la petición tenga un peso != 0 porque sino no podría votar ni delegar el voto (para ello accedemos al mapping de votantes).

        require (votantes[msg.sender].peso != 0, "No puede delegar voto");

// Comprobamos que el emisor de la petición tenga un tenga la variable votado sea = false porque sino ya habría votado (para ello accedemos al mapping de votantes).

        require (votantes[msg.sender].votado == false, "El emisor ya ha votado");

// Comprobamos que el address del emisor no coincida con el address enviado como parámetro de entrada receptor.

        require(msg.sender != _receptor, "No puedes autodelegar");

// Realizamos un bucle while que compruebe si el receptor ha establecido ya un delegado de voto, mapping de votantes[receptor], es decir, 
// si ese valor es distinto de 0.

        // Compruebo que el receptor no tenga niguna dirección delegada (voto delegado)

        while (votantes[_receptor].delegado != address(0)){

        // Dentro del bucle estableceremos la variable receptor = al delegado que tenga establecido el votantes[receptor], 
        // es decir, que si el receptor ya tiene un delegado elegido, ese será el nuevo receptor.    
        
            // asigno a receptor una dirección que le delega el voto

            _receptor = votantes[_receptor].delegado;

// Finalmente, se realiza un comprobación para ver si el receptor es distinto del emisor de la recepción, ya que sino habría un bucle en la delegación.

        require(msg.sender != _receptor, "El emisor y el receptor no pueden ser los mismos");

        }

// Al salir del bucle, vamos a comprobar que el peso de votantes[receptor] sea >= 1, ya que esto nos dejará claro si tiene derecho a voto o no.

        require(votantes[_receptor].peso >= 1, "El receptor no tiene derecho a voto");

// vamos a establecer las variables votado=true y delegado=receptor de votantes[msg.sender] (del emisor que quiere delegar), 
// ya que de este modo ya se habrá delegado el voto y aparece como voto completado.

        votantes [_receptor].votado = true;
        votantes [msg.sender].delegado = _receptor;

// Finalmente, comprobamos en base a if/else:
//  ○ If votantes[receptor] ya ha votado
//    ■ Si el delegado ya votó, añade directamente al número de votos el peso del que delegó el voto (usar propuestas[votantes[receptor].voto] para acceder a la cantidadVotos 
//      e incrementarla en base al peso del receptor)

        if (votantes[_receptor].votado == true) { 
            propuestas[votantes[_receptor].voto].cantidadVotos += votantes[msg.sender].peso;
        }

//  ○ Sino, se incrementa el peso del delegado añadiéndole el peso del remitente.
//    A votantes[receptor].peso le añadimos el peso de votantes[msg.sender].peso.

        else {
            votantes[_receptor].peso = votantes[msg.sender].peso;
        }
// Para finalizar, emitimos el evento de VotoDelegado con los parámetros correspondientes.

        emit VotoDelegado(msg.sender, _receptor);

    }

// Implementar la función “votar” pública que permitirá votar a aquellos que puedan votantes a los que se les haya otorgado previamente el voto.

    function votar (uint256 _proposicion) public  {

// Comprobamos que al votante se le haya asignado el derecho a votar previamente, es decir, miramos dentro del mapping votantes, 
// si el votante tiene la variable peso != 0 o >0.

        require(votantes[msg.sender].peso >0, "No tienes derecho a voto");

// Comprobamos que el votante no haya votado (del msg.sender), es decir, miramos dentro del mapping votantes si el votante tiene la variable votado a “true” .

        require(votantes[msg.sender].votado == false, "Ya ha votado o ha delegado el voto");

// Tras estas comprobaciones, ponemos al votante con la variable votado a true.

        votantes[msg.sender].votado = true;

// Ponemos al votante con la variable voto = a la proposición realizada.

        votantes[msg.sender].voto = _proposicion ;

// Actualizamos la cantidadVotos dentro del array de propuestas el correspondiente al índice de la proposición (propuestas[proposicion]) 
// que nos han pasado con el peso total que tenía el votante (votantes[msg.sender]).

        propuestas[_proposicion].cantidadVotos += votantes[msg.sender].peso ;

// Por último, emitimos el evento VotoEmitido.

        emit VotoEmitido(msg.sender, _proposicion);
    }

// Implementar la función “propuestaGanadora” private que permitirá obtener el índice de la propuesta ganadora.
//  Parámetros de salida:
//      ● Variable de tipo entero correspondiente al índice de la propuesta ganadora.

    function propuestaGanadora () private view returns (uint256) {

// Declaramos e inicializamos dos variables a 0 que serán la cantidadVotosGanadores e indicePropuestaGanadora

        uint256 cantidadVotosGanadores = 0;

        uint256 indicePropuestaGanadora = 0;

// Recorremos con un bucle for el tamaño de las propuesta (propuestas.length).

        for(uint256 i=0; i< propuestas.length; i++) {

// comprobaremos con un if si la cantidadVotos de la propuesta que estamos recorriendo (e.g., propuestas[p]) > cantidadVotosGanadores.

            if (propuestas[i].cantidadVotos > cantidadVotosGanadores) {

// actualizamos cantidadVotosGanadores con cantidadVotos de la propuesta que va ganando 
// y el indicePropuestaGanadora con el índice de de la propuesta que estamos recorriendo (e.g., “p”).

                cantidadVotosGanadores = propuestas[i].cantidadVotos;
                indicePropuestaGanadora = i ;
            }
        }
        return (indicePropuestaGanadora) ;

    }

// Implementar la función “propuestaGanadora” public que devolverá el nombre de la propuesta ganadora.
// Parámetros de salida:
//  ● Variable nombre de la propuesta ganadora de tipo string.

    function propuestaGanadora (uint256 indicePropuestaGanadora) public view returns (string memory) {

        return (propuestas[propuestaGanadora()].nombre); // la función propuestaGanadora devuelve el indice y con el indice busco el nombre e propuestas.
    }
// devolver un struct votante

//    function devolverStruct () public pure returns (votante memory){
// dos posibilidades de return
//        return (votante(0, false, address(0), 1 ));
//        return (votantes(msg.sender));
//    }

}