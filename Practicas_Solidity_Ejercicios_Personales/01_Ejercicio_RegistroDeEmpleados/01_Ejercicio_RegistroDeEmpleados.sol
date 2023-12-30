// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReistroDeEmpleados {
    address public propietario;
    constructor() {
       propietario=msg.sender;
    }
       struct Empleado {
        uint256 idEmpleado;
        string nombre;
        uint256 salario;
       }
       // El mapping lo que va hacer es asignar un numero a Empleado (uint256 => Empleado) tal y como pide el ejercicico.
       mapping (uint256=>Empleado) public Empleados;

      // No pongo nada enla mutabilidad del estado (ni pure, ni view) por que por defecto es nonpayable y nonpayable permite modificar los datos.
      // Como la función lo que hace es agregar datos pues es non payable para poder modificar.

       function agregarEmpleado (
         uint256 _idEmpleado, // en los dato de la función se sule poner un barra baja delante de la variable pera identificar que es de una función (_idEmpleado)
         string memory _nombre, 
         uint256 _salario) 
         public {

         // Nos pide que el propietario sea el único que puede agregar emplados y hacemos un require.

            require (msg.sender == propietario, "No eres el propietario");

         // Asegurar que la id del empleado sea única por lo que hay que comprobar que el id no exista.
         // Lo primero es acceder al mapping de Empleados y con el idEmplado obtener los datos de la struct Empleado => (Empleados[idEmplado]).
         // Como ya tengo lo datos de struct miro si el idEmplado existe => Empleados[_idEmpleado].idEmplado.
         // Cuando no hay datos se devuelve 0 por lo que si idEmpleado no existe, el struct nos devuelve 0.

            require(Empleados[_idEmpleado].idEmpleado == 0, "El empleado ya existe");

         // Vamos a introducir los datos del empleado.
         // Primero ecesitamos acceder al struct (Empleados[_idEmpleado]).
         // Introduzco los datos del Empleado

            Empleados[_idEmpleado]= Empleado(_idEmpleado, _nombre, _salario);
       
       }
         // Urilizamos la mutavilidad view por que vamos a acceder a los datos de variables interiores y no va a modificar nada.

       function obtenerEmpleado (uint256 _idEmpleado) public view returns (uint256, string memory, uint256 ){

         // En este caso vamos a comprobar que el empleado exista por lo que vamos hacer un require que debería de ser el contrario al anterior.

            require(Empleados[_idEmpleado].idEmpleado != 0, "El empleado no existe");

            return ( Empleados[_idEmpleado].idEmpleado, Empleados[_idEmpleado].nombre,  Empleados[_idEmpleado].salario);

         // También puedo simplificar el return introduciendo en una variable el struct de Empleado:
         // Empleado memory empleado = Empleados[_idEmpleado] => lo que quiere decir es que del struct Emplado voy a nombrar en memoria una variable empleado que se le asignan los datos del struct
         // La función quedaría de la siguiente forma:
         // require(empleado.idEmpleado != 0, "El empleado no existe");
         // return ( empleado.idEmpleado, empleado.nombre,  empleado.salario);
       }
       function actualizarSalarioEmpleado (uint256 _idEmpleado, uint256 _salario) public {

         // Actualizamos el salario accediando a el mapping de Empleados en le salario y cambiamos el valor

         require (msg.sender == propietario);
         Empleados[_idEmpleado].salario = _salario;

       }
       function eliminarEmpleado (uint256 _idEmpleado) public {

         // Utilizamos la función delete para borrar al empleado.
         require (msg.sender == propietario);
         require(Empleados[_idEmpleado].idEmpleado != 0, "El empleado no existe");
         delete Empleados[_idEmpleado];
       }


}
