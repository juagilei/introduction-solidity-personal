// Introducir cabecera contracto

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Declarar “contract” Mercado

contract Mercado {

// Como buena práctica se suelen declarar antes del constructor 
// las variables globales, mapping, modifiers, events, etc...

// Define una variable de estado llamada "propietario" de tipo address y haz que sea
// pública (public). Esta variable almacenará la dirección del propietario del contrato.

address public propietario;    

// Define una variable de estado llamada "Producto" de tipo struct.

struct Producto {
    uint256 id;
    string nombre;
    uint256 precio;
    uint256 cantidad;
    address vendedor;
}

// Crea un mapeo llamado "productos" que mapea el identificador del producto (de tipo entero) 
// con su Producto (de tipo struct) correspondiente. Este mapeo debe ser privado (private).

mapping (uint256 => Producto) private Productos;

// rea un entero llamado "contadorProductos" con visibilidad pública que almacenará 
// el número de productos que están presentes en la aplicación.

uint256 public contadorProductos;

// Crea un evento (event) llamado "ProductoAgregado" con los siguientes datos:

// Los eventos son una característica fundamental en Solidity que permite 
// la comunicación efectiva entre contratos y aplicaciones externas. 
// Su capacidad para proporcionar información inalterable y ser capturados 
// por aplicaciones externas los convierte en una herramienta esencial 
// para el desarrollo de contratos inteligentes robustos y 
// la construcción de interfaces de usuario interactivas.

event ProductoAgregado(
    uint _idProducto,
    uint _precio,
    uint _cantidad,
    address indexed _vendedor 
    // -> indexed se usa para indexar (para filtrar por ejemplo todos los eventos de una address específica)
);

// Crea un evento (event) llamado "ProductoComprado" con los siguientes datos:

event ProductoComprado(
    uint _idProducto,
    uint _precio,
    uint _cantidad,
    address indexed _comprador
);

// Crea un modificador (modifier) llamado "soloPropietario" el cual no requiere ningún 
// tipo de variable de entrada y comprobará que el emisor de la petición (msg.sender) 
// es el propietario, en caso contrario, fallará.

// modifier se usa para usar una condición varias veces en vez de poner el mismo texto cada vez 

modifier soloPropietario () {
    require (msg.sender == propietario, "No eres el propietario");
    // la sintaxis de _; par cerrar el modifier indica que puede continuar con la función
    _;
}

// Crea un modificador (modifier) llamado "productoExistente" el cual require como dato de entrada:
//  ● idProducto (entero).
// Este modificador comprobará:
//  1. Que el idProducto es distinto de 0.
//  2. Que el idProducto es menor o igual que el contadorProductos (ya que el
//     contador productos nos dirá cuál es el identificador más alto del último producto que se ha agregado al mercado).

modifier productoExistente (uint256 _idProducto) {
    require (_idProducto != 0, "Id del producto no valida");
    require ( _idProducto <= contadorProductos, "El producto es inexistente");
    // la barra baja y el punto y coma _; lo que indica que es que se continue ejecutando el contrato
    // ya que no ha saltado ningún require 
    // indica que puede continuar con la función
    _;
}

// Crea una función constructora (constructor) que establezca el valor de "propietario"
// como la dirección que despliega el contrato y que inicialice contradorProductos a 0.

constructor() {
    
    propietario = msg.sender;
    contadorProductos = 0;
}
// Implementar la función “agregarProducto” pública que agregará un nuevo producto al mercado.
//  Parámetros de entrada:
//      ● Variable nombre de tipo cadena.
//      ● Variable precio de tipo entero.
//      ● Variable cantidad de tipo entero.
//  Modificador de función: 
//      ● soloPropietario.
// El ejercicio pide poner el modificador solo propietario ero no tiene mucho sentido
// que solo el propietario sea el que introduzca los produstos, por lo que lo quitamos.

    function agregarProducto (
        string memory _nombre,
        uint256 _precio,
        uint256 _cantidad
        ) 
        public {
        
        contadorProductos ++ ; //=> contadorProductos = contadorProductos + 1

        Productos [contadorProductos] = Producto ({
            id: contadorProductos,
            nombre:  _nombre, 
            precio: _precio, 
            cantidad: _cantidad, 
            vendedor: msg.sender});

        emit ProductoAgregado(contadorProductos, _precio, _cantidad, msg.sender);
    }

// Implementar la función ”comprarProducto” pública de tipo payable que permitirá comprar un del mercado con ether.
// Parámetros de entrada:
// ● Variable idProducto de tipo entero.
// Modificador de función:
// ● productoExistente(idProducto).

    function compraProducto(uint256 _idProducto)public payable productoExistente(_idProducto) {

        require (Productos[_idProducto].cantidad !=0, "No hay stock");
        require (msg.value >= Productos[_idProducto].precio, "El precio es mayor al ether enviado");

        Productos[_idProducto].cantidad -= 1;

        payable (Productos[_idProducto].vendedor).transfer(Productos[_idProducto].precio);

        emit ProductoComprado(Productos[_idProducto].id, Productos[_idProducto].precio, Productos[_idProducto].cantidad, msg.sender);
    }

    function obenerProducto (uint256 _idProducto) public view productoExistente (_idProducto) returns (string memory, uint256, uint256, address) {

        return (
            Productos[_idProducto].nombre, 
            Productos[_idProducto].precio, 
            Productos[_idProducto].cantidad, 
            Productos[_idProducto].vendedor
            ) ;
    }

// Declarar función “receive”
// Declaramos la función receive() de tipo external y payable sin cuerpo de función 
// para que actúe de respaldo en caso de que alguien envíe ether desde fuera del contrato 
// sin llamar a ninguna función.

    receive() external payable {
        // Función de respaldo para aceptar ether
    }

}