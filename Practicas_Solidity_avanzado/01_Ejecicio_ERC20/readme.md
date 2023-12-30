# 1. Ejercicio contrato ERC20

Implementamos un contrato ERC20.

## 1. Introducimos la cabecera e importamos la interfaz IERC20

	Importamos la interfaz de openzeppelin.

```
		// SPDX-License-Identifier: MIT
		// Versión del compilador de Solidity.

			pragma solidity ^0.8.0;
		// Importa la interfaz ERC20 del paquete OpenZeppelin.

			import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
```

## 2. Definimos contrato y variables.

	Indicamos que nuestro contrato se implementa la interfaz IERC20.
```
	// Definición del contrato MyToken que implementa la interfaz ERC20.

		contract MyToken is IERC20 {

	// Variables para almacenar el nombre, símbolo y decimales del token.

    		string private _name;
    		string private _symbol;
    		uint8 private _decimals;

    	// Mappings para almacenar balances y asignaciones permitidas.

		mapping(address => uint256) private _balances;

		mapping(address => mapping(address => uint256)) private _allowances;

    	// Variable para almacenar el suministro total de tokens.

   		 uint256 private _totalSupply;
```
## 3. Definimos el constructor.

	En la definición del constructor hay que tener en cuenta que por seguridad la cuenta que despliega el contrato (msg.sender) no puede realizar las transacciones de los tokens. 

	Se añade una cuenta inicial (nitialAccount) en el constructor donde esten los tokens.

	En la inicialización del contrato deberiamos introducir nombre, simbolo y la cuenta inicial (diferente al msg.sender que el address(0) y constructor)cmo datos para el constructor.

```
 	constructor(string memory name_, string memory symbol_, address initialAccount) {
        _name = name_;
     	_symbol = symbol_;
        _decimals = 18;
        _totalSupply = 1000000 * 10**uint256(_decimals);
        _balances[initialAccount] = _totalSupply;
        emit Transfer(address(0), initialAccount, _totalSupply);
	}
```
## 4. Definimos funciones.

#### 1. Funciones para obtener el nombre, símbolo, decimales y suministro total del token.

		1. Devuelve el nombre de Token.
```
	function name() public view returns (string memory) {

    	return _name; 
	}
```
		2. Devulelve el simbolo del Token.
```

 	function symbol() public view returns (string memory) {


     
     	return _symbol;
	}
```
		3. Devuelve la cantidad de decimales del Token.
```
 	function decimals() public view returns (uint8) {

// Devuelve la cantidad de decimales del Token.

     	return _decimals;
	}
```

		4. Devuelve la cantdad total del Token.
```
 	function totalSupply() public view override returns (uint256) {


     
     	return _totalSupply;
	}
```

#### 2. Funciones para obtener el balance, realizar transferencias, y consultar asignaciones permitidas.

		1. balanceOf( address account):

			- Devuelve el balance de tokens de una dirección específica.
			- Recorro el mapping _balances anteriormente definido.
    


```

	function balanceOf(address account) public view override returns (uint256) {

   		 return _balances[account]; 

	}
```

		2. transfer(address recipient, uint256 amount):

			- Llamar a la función de transferencia interna _transfer.
			- Esta función interna lo que hace es descontar la cantidad (amount) de la cuenta que envia 
			  y sumarla a la cuenta que recibe.
			- Solo se usa con la cuenta inicial que es la única cuenta que tiene tokens al principio 
			  del contrato .

```
	function transfer(address recipient, uint256 amount) public override returns (bool) {


        	_transfer(msg.sender, recipient, amount);   

        	return true;
    }
```

		3. allowance(address owner, address spender):
	
			- Devuelve la asignación  de tokens permititida por el owner para el 'spender' 
			( o gestor de tus tokens).
			- recorre el mapping _allowances donde encontramos un mapping dentro de otro mapping
    
    	

    
       	
```
	function allowance(address owner, address spender) public view override returns (uint256) {

 		return _allowances[owner][spender];
 		
	}
```

#### 3. Funciones para aprobar transferencias y realizar transferencias desde.

	1. approve(address spender, uint256 amount):

		- Llama a una función inerna de aprovación.
		- Permite al 'spender' gastar una cantidad específica de tokens en nombre del 'owner'.
		- _approve es una Función interna para aprobar asignaciones permitidas que vemos mas adelante.

```
	function approve(address spender, uint256 amount) public override returns (bool) {


        _approve(msg.sender, spender, value);

        return true;
    }
```

	2. transferFrom(address sender, address recipient, uint256 amount).
	
		- Función que permite transferir tokens de una cuenta emisora a una receptora.
		- Esta función necesita una aprobación (_approve).
```
	function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);   // Llamar a la función de transferencia interna.

        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);   // Actualizar la asignación permitida (ya que descuenta el amount de la transferencia por lo que disminuye la cantidad permitida).

        return true;
    }
		
```

#### 4. Funciones para aumentar y disminuir asignaciones permitidas.

		1. Función para incrementar la cantidad permitida.
		Modificamos la cantidad con la función _approve.

```
	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);   // TODO: Aumentar la asignación permitida.
        return true;
    }
´´´
	2. Función para decrementar la cantidad permitida.
		Modificamos la cantidad con la función _approve.
```
 	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);   // TODO: Disminuir la asignación permitida.
        return true;
    }

```

#### 5. Funciones internas.

1. _transfer().
		Función interna que tiene como fin realizar transferencias de tokens entre cuentas.
		Por seguridad la cuenta 0 que es la que despliega el contrato no puede transferir ni 
		recibir por lo que usamos unos require para esto.

```
	function _transfer(address sender, address recipient, uint256 amount) internal {
        	require(sender != address(0), "Sender cannot be the zero address");   // Verificar 	que el remitente no sea la dirección cero.
        	require(recipient != address(0), "Recipient cannot be the zero address");   // 	Verificar que el destinatario no sea la dirección cero.

        	_balances[sender] -= amount;   // Restar el monto del remitente.
        	_balances[recipient] += amount;   // Sumar el monto al destinatario.
        	emit Transfer(sender, recipient, amount);   // Emitir el evento de transferencia.
    	}
```

2. _approve().
		Función interna que aprueba las asignaciones permitidas.

```
	function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");   // Verificar que el propietario no sea la dirección cero.
        require(spender != address(0), "ERC20: approve to the zero address");   // Verificar que el spender no sea la dirección cero.

        _allowances[owner][spender] = amount;   // Establecer la asignación permitida.
        emit Approval(owner, spender, amount);   // Emitir el evento de aprobación.
    }
```













