// Para el test creamos un archivo con extensión .test.js y almacenamos el contrato a testear en una constante.
// la palabra artifacts hace que truufle busque el contrato en la carpeta contracts de truffle y 
// hay que poner el mismo nombre que el contrato que queremos testear.

const AlmacenamientoSimple = artifacts.require("AlmacenamientoSimple");

// Imporamos Chai, al poner { expect } indicamos que solo vamos a usar el funcionalidad expect de chai.
// chai tiene varias funcionalidas las mas usadas son expect y should

const { expect } = requiere ("chai");

// empezamos el test.
// ponemos nombre al test:
// contract es para indicar que hacemos un test a un contrato.
// cuentas son las cuentas que nos da truffle igual que haca remix para hacer pruebas de esta forma
// podemos acceder a las cuentas que nos da trucffle por defecto.
// declaramos una variable let donde desplegamos el contrato.
contract('AlmacenamientoSimple', (cuentas)=>{

    // declaramos una variable let donde desplegaremos el contrato.
     let almacenamientoSimple;

    // Funcionalidades básicas de truffle antes de hacer el test y despues de hacer el test:
    // Before()
    // BeforeEach()
    // After()
    // AfterEach()
    // Antes que nada compilamos y desplegamos el contrato.
    // la diferencia entre before y beforeEach es que before es para todas las pruebas y
    // beforeEach es para cada prueba.

    beforeEach(async () => {
        almacenamientoSimple = await AlmacenamientoSimple.new();
    });
    // definimos la pruebas con la palabra it. it = individual test.

    it('[1] Debería de establecer el valor de los datos', async ()=> {
        // en el contrato la función tiene un uint256 por lo que como parametro de entrada debe de ser un número
        await almacenamientoSimple.establecerDatos(45);

        // obtenemos el dato en una constante
        const datoObtenido = await almacenamientoSimple.obtenerDatos();

        // usamos ahora chai
        // para comparar el numero usamos toNumber y luego podemos ver si es igual .to.equal()
        // o si es mayor .to.greaterTan

        expect(datoObtenido.toNumber()).to.equal (45);
    });
});


