# 02 Ejercicio ERC271
	Vamos a implementar un contrato estandar ERC271 para NFT.

	Estan diseñados para tokens no fungibles como pueden ser los NFT.

## 1. Cabecera e import de libreias e interfaces para ERC721 

```.sol

// SPDX-License-Identifier: MIT
// Los contratos con el estandar ERC271 son contratos para tokens no fungibles, o sea NFT por ejemplo.

pragma solidity ^0.8.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721//IERC721Receiver.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721//extensions/IERC721Metadata.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165, ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

```
## 2. Creación del contrato.

### 1. abstract contract MyNFT: 

	Aquí se define un contrato abstracto llamado MyNFT. Un contrato abstracto no puede ser instanciado directamente en la cadena de bloques; en su lugar, debe ser heredado por otros contratos que implementarán las funciones y variables abstractas.

### 2. 	Is Context, ERC165, IERC721, IERC721Metadata, IERC721Errors: 

	MyNFT hereda las funcionalidades de varios otros contratos. A continuación, desglosamos lo que cada uno de estos contratos generalmente proporciona:

	- Context: Proporciona funciones de contexto, como obtener el remitente de la transacción.

	- ERC165: Es una interfaz estándar para anunciar la compatibilidad con interfaces específicas.

	- IERC721: Especifica la interfaz estándar para los tokens no fungibles (NFTs) en Ethereum.

	- IERC721Metadata: Define funciones para obtener información sobre los metadatos de los NFTs, como el nombre y el símbolo.

	- IERC721Errors: Define códigos de error estándar para los NFTs.
```.sol
abstract contract MyNFT is Context, ERC165, IERC721, IERC721Metadata, IERC721Errors  { 
// aqui va el código de todo el contrato
}
```

## 3. Definición de variables.

#### 1. using Strings for uint256: 

	Aquí se utiliza la librería Strings para permitir la manipulación de cadenas de texto con valores uint256. Esta librería estándar en Solidity facilita la conversión de números a cadenas de texto.

```.sol
using Strings for uint256;
```


#### 2. string private _name: 

	Declara una variable privada llamada _name que almacena el nombre del token NFT.

```.sol
// Token name
    string private _name;
```

#### 3. string private _symbol: 

	Declara una variable privada llamada _symbol que almacena el símbolo del token NFT.

```.sol
 // Token symbol
    string private _symbol;
```

#### 4. mapping(uint256 tokenId => address) private _owners: 

	Declara un mapeo privado que asocia el ID de un token NFT con la dirección de su propietario.

```.sol
 mapping(uint256 tokenId => address) private _owners;
```


#### 5. mapping(uint256 tokenId => address) private _tokenApprovals: 

	Declara un mapeo privado que asocia el ID de un token NFT con la dirección autorizada para transferir ese token.

```.sol
mapping(uint256 tokenId => address) private _tokenApprovals;
```

#### 6. mapping(address owner => mapping(address operator => bool)) private _operatorApprovals: 

	Declara un mapeo privado que indica si una dirección específica (operador) está autorizada por un propietario para gestionar sus tokens.

```.sol
mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;
```

## 4. Iniciación del cotrato.

	Este constructor se utiliza para inicializar dos variables privadas, _name y _symbol, con los valores proporcionados como parámetros al desplegar el contrato. Estas variables podrían ser parte de un contrato más grande que representa algún tipo de activo digital o token en una cadena de bloques.

```.sol
constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
```

## 5. Definición de funciones.

### 1. function supportsInterface(bytes4 interfaceId) (función de IERC165):

	Esta función se utiliza para determinar si el contrato cumple con ciertas interfaces, en particular, las interfaces ERC-721 y ERC-721 Metadata, siguiendo el estándar de interfaces en Ethereum. Esto es importante para la interoperabilidad y para que otros contratos o aplicaciones puedan verificar qué funcionalidades específicas son compatibles con el contrato en cuestión.

```.sol
 	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
```
	- function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool): 

	Esto define una función llamada supportsInterface que toma un parámetro interfaceId de tipo bytes4. La función es pública (public), de solo lectura (view), virtual (virtual), y está anulando (override) las implementaciones de las funciones con el mismo nombre en los contratos ERC165 y IERC165. Devuelve un valor booleano (returns (bool)).

	- return interfaceId == type(IERC721).interfaceId ||: 

	Compara el interfaceId pasado como argumento con el interfaceId del estándar ERC-721. Si son iguales, esta parte de la expresión devuelve true.

	- interfaceId == type(IERC721Metadata).interfaceId ||: 

	Similar al paso anterior, compara el interfaceId con el interfaceId del estándar adicional ERC-721 Metadata. Si son iguales, esta parte de la expresión devuelve true.

	- super.supportsInterface(interfaceId);: 

	Llama a la implementación de la función supportsInterface en el contrato base (super) que está anulando. Esto es importante porque el contrato actual hereda de ERC165, y al llamar a super.supportsInterface, se asegura de que las implementaciones en los contratos base también se tengan en cuenta.

	- En general, la función devuelve true si el interfaceId coincide con el del estándar ERC-721 o ERC-721 Metadata, o si la llamada a super.supportsInterface(interfaceId) devuelve true. De lo contrario, devuelve false.

### 2. function balanceOf(address owner) public view virtual returns (uint256) (función de IERC271)

 La función balanceOf devuelve el número de tokens ERC-721 que el propietario dado (especificado por la dirección owner) tiene en su posesión. Antes de realizar esta consulta, se verifica que la dirección del propietario no sea la dirección cero para evitar comportamientos inesperados.

```.sol
 /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return _balances[owner];
    }
```

	- function balanceOf(address owner) public view virtual returns (uint256) {: 

	Esta línea declara la función balanceOf, que toma un parámetro owner de tipo address y devuelve un valor de tipo uint256. La función está marcada como public para que pueda ser llamada desde fuera del contrato, y view indica que no modifica el estado del contrato.

	- if (owner == address(0)) { revert ERC721InvalidOwner(address(0)); }: 

	Esta línea verifica si el parámetro owner es la dirección cero (address(0)), que generalmente se utiliza para representar la ausencia de una dirección válida. Si owner es la dirección cero, se revierte la transacción y se lanza una excepción ERC721InvalidOwner. Esta línea se añade para evitar que se consulte el balance de la dirección cero.

	- return _balances[owner];: 

	Esta línea devuelve el balance del propietario (owner). Parece que el balance se mantiene en una variable interna _balances, que es probable que sea un mapeo (mapping) que asigna direcciones de propietarios a sus saldos de tokens ERC-721.

### 3. function ownerOf(uint256 tokenId) public view virtual returns (address) (función de IERC271)
.

	Esta función ownerOf devuelve la dirección del propietario de un token NFT específico identificado por su tokenId. La lógica real de determinar el propietario parece estar encapsulada en la función _requireOwned, que probablemente realiza algunas verificaciones y devuelve la dirección del propietario.

```.sol
/**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }
```

	- ownerOf(uint256 tokenId): El nombre de la función es ownerOf y toma un parámetro tokenId de tipo uint256.

	- public: La función es accesible desde fuera del contrato.

	- view: Indica que la función no modifica el estado del contrato; es de solo lectura.

	- virtual: Indica que esta función puede ser anulada por funciones en contratos heredados.

	- _requireOwned(tokenId): Parece que esta función está delegando la responsabilidad de determinar el propietario del token a otra función llamada _requireOwned y devuelve el resultado.

### 4 Funciones de (IERC271 Metadatos).

```.sol
 function name() public view virtual returns (string memory) {
        return _name;
    }
```
	La función name() proporciona el nombre de un contrato que cumple con el estándar ERC-721 (tokens no fungibles en Ethereum). Está diseñada para ser llamada de manera externa y devuelve una cadena de texto que representa el nombre del contrato. La información del nombre se almacena en la variable _name.
```.sol
  function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
```
	función symbol se utiliza para obtener el símbolo asociado con el contrato. Por ejemplo, en el contexto de un token ERC-20 (un estándar para tokens en Ethereum), esta función podría devolver el símbolo de ese token, como "ETH" para Ether 

```.sol
function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }
```
	Esta función tokenURI se utiliza para obtener la URI de un token no fungible, y parece asegurarse de que solo el propietario del token pueda obtener esta información. La URI resultante generalmente se utilizará para acceder a información adicional asociada con el token, como metadatos, imágenes, u otros recursos relacionados con ese token específico.

	- Parámetro de Entrada:

	uint256 tokenId: Este parámetro representa el identificador único del token para el cual se desea obtener la URI (Identificador de Recursos Uniforme).

	- Modificador _requireOwned:

	Parece haber una función o un modificador llamado _requireOwned que no se proporciona aquí, pero se asume que verifica si el titular de la llamada de la función es el propietario del token especificado. Es probable que esta función se utilice para asegurar que solo el propietario del token pueda obtener su URI.

	- Base URI:

	Se declara una variable baseURI que parece contener la parte base de la URI para los tokens. Puede ser una URL base común para todos los tokens de este contrato.

	- Obtención de la URI completa:

	Se obtiene la longitud en bytes de baseURI. Si la longitud es mayor que cero, significa que la baseURI existe.

	Si la baseURI existe, se concatena con el tokenId convertido a cadena (tokenId.toString()).
	Esto se hace para formar la URI completa del token.
	Si la longitud de baseURI es cero, se devuelve una cadena vacía.

	- Retorno:

	La función devuelve la URI completa del token si existe, de lo contrario, devuelve una cadena vacía.

### 5.   function _baseURI().

	Esta función _baseURI proporciona una manera de definir la URI base para los tokens no fungibles en un contrato inteligente, permitiendo así la construcción de URIs únicas para cada token dentro de un estándar como ERC-721 o ERC-1155.

```.sol
  function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
```
	- baseURI: Se refiere a la parte fija de la URI base que se utilizará para construir las URIs de los tokens.

	- tokenId: Se refiere al identificador único de cada token. La URI de cada token se formará concatenando la baseURI con este tokenId.

	- La función retorna una cadena de texto (string memory) que representa la URI base. En el código proporcionado, la función simplemente devuelve una cadena vacía "". Sin embargo, la documentación indica que esta cadena puede ser sobrescrita en contratos hijos para establecer una URI base específica.


### 6.  function approve(address to, uint256 tokenId).
	Esta función approve proporciona una interfaz pública para aprobar la transferencia de un token específico a otra dirección. La lógica real de aprobación está delegada a la función privada _approve, que probablemente contiene la implementación específica de la lógica de aprobación y gestión de permisos. Este código es típicamente parte de un contrato ERC-721, que es un estándar para tokens no fungibles (NFT) en la red Ethereum.
```.sol
 function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, _msgSender());
    }
```
	- function approve(address to, uint256 tokenId) public virtual: 
	  Esto declara una función llamada approve que toma dos parámetros: to de tipo address y tokenId de tipo uint256. La función es pública, lo que significa que puede ser llamada desde fuera del contrato. La palabra clave virtual indica que esta función puede ser sobrescrita por funciones en contratos heredados.

	- _approve(to, tokenId, _msgSender()): 
	   Llama a otra función llamada _approve con tres argumentos: to (la dirección a la que se aprueba el token), tokenId (el identificador del token que se aprueba) y _msgSender() (la dirección que llamó a la función approve). El uso de _msgSender() es una práctica común para asegurarse de que la dirección que aprueba el token sea la misma que llamó a la función approve.

### 7. function getApproved(uint256 tokenId).
	La función getApproved está diseñada para proporcionar la dirección que tiene permisos aprobados para un token específico, pero antes de hacerlo, verifica si el token está en posesión del llamador utilizando la función _requireOwned. Es posible que esta función se utilice en el contexto de un estándar de token como ERC-721, que es un estándar para tokens no fungibles (NFTs) en la cadena de bloques Ethereum.

```.sol
function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }
```
	- getApproved(uint256 tokenId): Esta es la declaración de la función. Toma un argumento tokenId, que es un identificador único para un token en el sistema.

	- public view virtual returns (address): Indica que la función es pública, se puede ver (no modifica el estado del contrato) y es virtual, lo que significa que puede ser sobrescrita por funciones en contratos herederos. Devuelve una dirección, que probablemente representará la dirección del usuario que tiene permisos aprobados para el token.

	- _requireOwned(tokenId): Parece que hay una función llamada _requireOwned que se llama antes de continuar con el resto de la función. No has proporcionado el código para esta función, pero el nombre sugiere que se utiliza para verificar si el token con el ID proporcionado está en posesión del llamador (la dirección que invoca esta función). Si el token no está en posesión, es probable que se lance una excepción o se tome alguna acción específica según la implementación de _requireOwned.

	- _getApproved(tokenId): Parece que hay otra función llamada _getApproved que se llama para obtener la dirección que tiene permisos aprobados para el token. No has proporcionado el código para esta función, pero el nombre sugiere que se utiliza para recuperar la dirección que tiene permisos aprobados para el token especificado.


### 8. function setApprovalForAll(address operator, bool approved) public virtual.

	La función getApproved está diseñada para proporcionar la dirección que tiene permisos aprobados para un token específico, pero antes de hacerlo, verifica si el token está en posesión del llamador utilizando la función _requireOwned. 

```.sol
function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }
```

	- getApproved(uint256 tokenId): Esta es la declaración de la función. Toma un argumento tokenId, que es un identificador único para un token en el sistema.
	
	- public view virtual returns (address): Indica que la función es pública, se puede ver (no modifica el estado del contrato) y es virtual, lo que significa que puede ser sobrescrita por funciones en contratos herederos. Devuelve una dirección, que probablemente representará la dirección del usuario que tiene permisos aprobados para el token.

	- _requireOwned(tokenId): Parece que hay una función llamada _requireOwned que se llama antes de continuar con el resto de la función. No has proporcionado el código para esta función, pero el nombre sugiere que se utiliza para verificar si el token con el ID proporcionado está en posesión del llamador (la dirección que invoca esta función). Si el token no está en posesión, es probable que se lance una excepción o se tome alguna acción específica según la implementación de _requireOwned.

	- _getApproved(tokenId): Parece que hay otra función llamada _getApproved que se llama para obtener la dirección que tiene permisos aprobados para el token. No has proporcionado el código para esta función, pero el nombre sugiere que se utiliza para recuperar la dirección que tiene permisos aprobados para el token especificado.

### 9.    function isApprovedForAll(address owner, address operator).

	Se utiliza para gestionar las aprobaciones de operadores que pueden realizar ciertas operaciones en nombre del propietario del contrato, como transferir tokens no fungibles.

```.sol
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }
```
	- function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {: Aquí se define una función llamada isApprovedForAll. La función toma dos parámetros de tipo address llamados owner y operator. Además, la función es declarada como pública (public), de solo lectura (view), virtual (virtual) y devuelve un valor booleano (returns (bool)).

		- public: Indica que esta función puede ser llamada desde fuera del contrato.
		- view: Indica que la función no modifica el estado del contrato. Es solo de lectura y no realiza cambios permanentes en la cadena de bloques.
		- virtual: Indica que esta función puede ser anulada (override) por funciones en contratos herederos.

	- return _operatorApprovals[owner][operator];: Aquí se devuelve el valor almacenado en la variable _operatorApprovals, que parece ser una matriz bidimensional de booleanos. Esta matriz se utiliza para almacenar aprobaciones de operadores para realizar ciertas acciones en nombre del propietario del contrato.

		- owner: Representa la dirección del propietario del contrato.
		- operator: Representa la dirección del operador cuya aprobación se está verificando.

	- Entonces, la función isApprovedForAll devuelve true si el operador (la dirección operator) está aprobado para realizar acciones en nombre del propietario (la dirección owner), y false en caso contrario.

### 10.  function transferFrom(address from, address to, uint256 tokenId).

	Esta función se encarga de transferir un token no fungible de un propietario a otro, verificando que la dirección de destino no sea la dirección cero y que el propietario actual del token sea el que se espera antes de la transferencia.

```.sol
 function transferFrom(address from, address to, uint256 tokenId) public virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }
```
	- Parámetros de entrada:

		- address from: La dirección del propietario actual del token que se va a transferir.

		- address to: La dirección a la que se va a transferir el token.

		- uint256 tokenId: El identificador único del token que se va a transferir.

	- Verificación de destinatario válido:

```.sol
if (to == address(0)) {
    revert ERC721InvalidReceiver(address(0));
}
```

		- Verifica que la dirección de destino (to) no sea la dirección cero. Si es cero, revierte la transacción con un error personalizado (ERC721InvalidReceiver), indicando que la dirección de destino no es válida.

	- Actualización y verificación de propietario anterior:

```.sol

address previousOwner = _update(to, tokenId, _msgSender());
if (previousOwner != from) {
    revert ERC721IncorrectOwner(from, tokenId, previousOwner);
}
```

		- Llama a la función _update para actualizar el estado del contrato y obtener la dirección del propietario anterior después de la actualización.
		- Compara la dirección del propietario anterior con la dirección proporcionada (from). Si no coinciden, revierte la transacción con un error personalizado (ERC721IncorrectOwner), indicando que el propietario anterior no es el esperado.


### 11. function safeTransferFrom(address from, address to, uint256 tokenId).

	Esta función actúa como un atajo o una interfaz para llamar a otra función safeTransferFrom con un parámetro adicional, proporcionando una forma simplificada de realizar transferencias seguras de tokens en el contrato inteligente.

```.sol
 function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }
```
	- from: La dirección que actualmente posee el token y desea transferirlo.
	- to: La dirección a la que se transferirá el token, es decir, la nueva propietaria.
	- tokenId: El identificador único del token que se está transfiriendo.

	- Dentro de la función, se llama a otra función llamada safeTransferFrom con los mismos parámetros más un cuarto parámetro, que es una cadena vacía "". Esto es común en los estándares de tokens como ERC-721 o ERC-1155 en Ethereum.

	- La función safeTransferFrom generalmente se utiliza para realizar transferencias seguras de tokens, donde se ejecutan ciertas verificaciones para garantizar que la operación sea segura y no provoque problemas inesperados.

### 12. function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data).

	Esta función realiza la transferencia segura de un token no fungible de una dirección a otra, y luego verifica si el receptor puede manejar la recepción del token. La seguridad de la transferencia se refiere a asegurarse de que el receptor sea capaz de manejar la recepción del token de acuerdo con el estándar ERC-721, evitando posibles problemas y asegurando que la operación sea exitosa.

```.sol
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }
```

	Esta función se encarga de transferir la propiedad de un token no fungible (NFT) de una dirección from a otra dirección to. Además de la transferencia del token, esta función realiza una llamada a otra función llamada _checkOnERC721Received, la cual se encarga de verificar si el receptor (to) puede manejar la recepción del token según el estándar ERC-721.

	- address from: Es la dirección del propietario actual del token que se va a transferir.
	- address to: Es la dirección del nuevo propietario al que se va a transferir el token.
	- uint256 tokenId: Es el identificador único del token no fungible que se va a transferir.
	- bytes memory data: Es una serie de datos adicionales que se pueden incluir como parte de la transferencia. Estos datos son procesados por la función _checkOnERC721Received.

### 13. function _ownerOf(uint256 tokenId).

	Esta función proporciona una manera de obtener la dirección del propietario de un token específico en un contrato que maneja tokens no fungibles.

```.sol
function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }
```
	La lógica de la función es bastante simple. Toma el tokenId como entrada y devuelve la dirección (address) que posee ese token en particular. Esto sugiere que el contrato mantiene un mapeo interno (_owners) que asocia cada tokenId con la dirección de su propietario.

### 14. function _getApproved(uint256 tokenId).

	Esta función proporciona una manera de obtener la dirección que tiene los permisos aprobados para un token específico, según la información almacenada en el mapeo _tokenApprovals.
```.sol
function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }
```

	- function _getApproved(uint256 tokenId) internal view virtual returns (address): Esta línea declara una función interna llamada _getApproved. La función toma un parámetro tokenId de tipo uint256 (entero sin signo de 256 bits). La palabra clave internal indica que la función solo puede ser llamada desde dentro del contrato actual, mientras que view significa que la función no modifica el estado del contrato y solo lee datos.

	- returns (address): Indica que la función devuelve un valor de tipo address (dirección Ethereum).

	- { return _tokenApprovals[tokenId]; }: El cuerpo de la función simplemente devuelve el valor almacenado en el mapeo _tokenApprovals para la clave tokenId. En otras palabras, devuelve la dirección que tiene los permisos aprobados para el token con el ID especificado.

### 15. function _isAuthorized(address owner, address spender, uint256 tokenId).

	Esta función se utiliza para verificar si un usuario específico tiene la autorización necesaria para realizar una acción sobre un token en un contrato inteligente.

```.sol
function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }
```
	- function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {: 
	
	Esta línea define la función _isAuthorized con tres parámetros de entrada: owner (dueño del token), spender (quien desea realizar la acción) y tokenId (identificador único del token). La función devuelve un valor booleano y es de tipo view, lo que significa que no modifica el estado del contrato.

	- return spender != address(0) &&: Verifica si la dirección del "spender" no es cero. En Ethereum, la dirección cero (address(0)) se utiliza a menudo para representar la ausencia de una dirección válida.

	- (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);: 
	Esta es la condición principal de la función. Comprueba si una de las siguientes condiciones es verdadera:

	- owner == spender: El "spender" es el propietario del token.

	- isApprovedForAll(owner, spender): El propietario del token ha aprobado al "spender" para realizar acciones en todos sus tokens.

	- _getApproved(tokenId) == spender: El "spender" está explícitamente aprobado para realizar acciones en el token específico identificado por tokenId.

	- La función retorna true si alguna de las condiciones anteriores es verdadera, lo que indica que el "spender" está autorizado para realizar la acción sobre el token. De lo contrario, devuelve false.

### 16. function _checkAuthorized(address owner, address spender, uint256 tokenId).

	Esta función se encarga de verificar la autorización para la transferencia de un token y lanza excepciones personalizadas en caso de que la autorización sea insuficiente o el token no exista.

```.sol
 function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }
```

	- Este código es una función interna (_checkAuthorized) que se encarga de verificar si un usuario (owner) tiene la autorización para transferir un token específico (tokenId) a otro usuario (spender). La función utiliza dos parámetros de dirección (address) para representar al propietario (owner) y al usuario autorizado (spender), así como un parámetro uint256 para el identificador único del token (tokenId).

	- La función utiliza otra función interna llamada _isAuthorized para realizar la verificación real. Si la verificación muestra que el propietario no está autorizado para transferir el token al usuario especificado, se ejecutan ciertos bloques de código dentro de la condición.

	- Primero, verifica si el propietario es una dirección nula (address(0)). Si es así, significa que el token no existe, y la función lanza una excepción (revert) con un error personalizado ERC721NonexistentToken, indicando que el token no existe.

	- Si el propietario no es una dirección nula, entonces la función asume que el propietario existe, pero no tiene la aprobación suficiente para transferir el token al usuario autorizado. En este caso, la función lanza otra excepción (revert) con un error personalizado ERC721InsufficientApproval, indicando que la aprobación para la transferencia es insuficiente y especificando al usuario autorizado y el tokenId involucrados.

### 17. function _increaseBalance(address account, uint128 value).

	Esta función se encarga de aumentar el saldo de una cuenta específica en una cantidad determinada. Es importante destacar que esta implementación asume que no ocurrirá un desbordamiento durante la adición, lo cual puede tener consecuencias si no se maneja adecuadamente.

```.sol
function _increaseBalance(address account, uint128 value) internal virtual {
        unchecked {
            _balances[account] += value;
        }
    }
```
	- function _increaseBalance(address account, uint128 value) internal virtual: Esta línea define una función llamada _increaseBalance que toma dos parámetros: account (una dirección de cuenta) y value (un número entero de 128 bits sin signo). La palabra clave internal significa que la función solo puede ser llamada desde dentro del contrato y virtual indica que esta función puede ser sobrescrita por funciones en contratos herederos.

	- unchecked: Esta palabra clave se refiere a que las verificaciones de desbordamiento (overflow) no se realizan. En otras palabras, el código no verificará si la adición de _balances[account] + value supera el valor máximo que puede contener un número de 128 bits.

	- { _balances[account] += value; }: Este bloque de código realiza una operación de incremento en la variable _balances almacenada en la dirección de la cuenta account. Suma el valor de value al saldo actual de esa cuenta. La operación se realiza sin verificar el desbordamiento.

### 18.  function _update(address to, uint256 tokenId, address auth).

	Es una función interna y virtual que realiza la actualización de la propiedad de un token en un contrato inteligente.

```.sol
function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }
```

	- Parámetros de entrada:

		- to: La dirección a la que se va a transferir la propiedad del token.
		- tokenId: El identificador único del token cuya propiedad se va a transferir.
		- auth: La dirección autorizada para realizar la operación (puede ser address(0) si no se requiere autorización).

	- Obtención de la dirección actual del propietario:

		- Se obtiene la dirección actual del propietario del token a través de la función _ownerOf(tokenId) y se almacena en la variable from.

	- Verificación del operador autorizado (opcional):

		- Si la dirección de autorización (auth) no es igual a address(0), se realiza una verificación para asegurarse de que la dirección actual del propietario (from) esté autorizada para realizar la operación en el token específico (tokenId). Esto se hace llamando a la función _checkAuthorized.

	- Ejecución de la actualización:

		- Si la dirección actual del propietario (from) no es igual a address(0), se procede a realizar la actualización.
		- Se borra cualquier aprobación existente para el token llamando a _approve con los parámetros necesarios, indicando que no es necesario volver a autorizar y que no se debe emitir el evento de aprobación.
		- Se disminuye el saldo del propietario actual (from) en 1.

	- Transferencia de la propiedad del token:

		- Si la dirección a la que se va a transferir la propiedad (to) no es igual a address(0), se incrementa el saldo de esa dirección en 1.

	- Actualización del registro de propietarios:

		- Se actualiza el registro interno _owners para reflejar que el token ahora pertenece a la dirección especificada (to).

	- Emisión del evento de transferencia:

		- Se emite el evento Transfer para indicar que la propiedad del token ha sido transferida de la dirección anterior (from) a la nueva dirección (to).

	- Retorno de la dirección anterior del propietario:

		- La función devuelve la dirección anterior del propietario (from).

### 19.  function _mint(address to, uint256 tokenId).

	Esta función _mint es utilizada para crear un nuevo NFT y asignarlo a una dirección específica (to). Antes de hacerlo, verifica si la dirección de destino es válida y luego actualiza la información del token, asegurándose de que el token no tenga un propietario anterior. Si todo es válido, el nuevo propietario es registrado y el token es creado exitosamente. En caso de que haya algún problema, la transacción se revierte con un mensaje de error específico.


```.sol
 function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }
```

### 20.  function _safeMint(address to, uint256 tokenId).

	Esta función _safeMint interna proporciona una interfaz más simple para realizar la creación segura de NFTs en el contrato, permitiendo asignar un nuevo token a una dirección sin tener que especificar metadatos adicionales en este caso.

```.sol
function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }
```

### 21. function _safeMint(address to, uint256 tokenId, bytes memory data).

	Esta función _safeMint se encarga de asignar un nuevo token a un destinatario específico y realiza una verificación adicional para asegurarse de que el destinatario pueda manejar la recepción del token de manera segura.

```.sol
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }
```
	- _mint(to, tokenId): Llama a otra función interna llamada _mint, que se encarga de crear y asignar un nuevo token al destinatario especificado.

	- _checkOnERC721Received(address(0), to, tokenId, data): Llama a otra función interna llamada _checkOnERC721Received para verificar si el destinatario (to) puede recibir tokens ERC721 y manejar la recepción mediante la ejecución de código adicional. La dirección address(0) se utiliza para indicar que no hay dirección de remitente previa en este contexto.

### 22. function _burn(uint256 tokenId).

	Esta función _burn se encarga de quemar (eliminar) un token no fungible con el tokenId proporcionado. Antes de realizar la eliminación, se llama a la función _update para obtener al propietario anterior del token. Si el propietario anterior es la dirección cero, se revierte la operación, indicando que el token no existe.

```.sol
function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }
```
	- function _burn(uint256 tokenId) internal {: Esta línea declara una función interna llamada _burn que toma un parámetro tokenId de tipo uint256. La palabra clave internal significa que esta función solo puede ser llamada desde dentro del contrato o contratos herederos.

	- address previousOwner = _update(address(0), tokenId, address(0));: Llama a la función _update con tres argumentos: address(0) (que podría representar la dirección cero), el tokenId y otra vez address(0). La dirección que devuelve _update se asigna a la variable previousOwner.

	- if (previousOwner == address(0)) {: Verifica si el valor de previousOwner es igual a la dirección cero.

	- revert ERC721NonexistentToken(tokenId);: Si previousOwner es igual a la dirección cero, la ejecución del contrato se revierte y se lanza una excepción de tipo ERC721NonexistentToken con el tokenId como argumento. Esto podría indicar que se intentó quemar (eliminar) un token que no existe.

### 23.  function _transfer(address from, address to, uint256 tokenId).

	Esta función se encarga de manejar la lógica de transferencia de tokens no fungibles (NFTs) en el estándar ERC-721, verificando la validez de la dirección receptora, asegurándose de que el token exista y que el propietario actual sea el correcto antes de realizar la transferencia.

```.sol
function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }
```
	- function _transfer(address from, address to, uint256 tokenId) internal {: Esta línea define la función _transfer, que toma tres parámetros: from (la dirección del propietario actual del token), to (la dirección a la que se está transfiriendo el token) y tokenId (el identificador único del token que se está transfiriendo). La palabra clave internal significa que la función solo puede ser llamada desde dentro del contrato o contratos que heredan de este.

	- if (to == address(0)) { revert ERC721InvalidReceiver(address(0)); }: Esta línea verifica si la dirección a la que se está intentando transferir el token (to) es la dirección cero (0x0), que generalmente se utiliza para representar la quema (destruction) del token. Si es así, se revierte la transacción y se lanza una excepción con el mensaje de error ERC721InvalidReceiver indicando que la dirección del receptor es inválida.

	- address previousOwner = _update(to, tokenId, address(0));: Llama a la función _update con los parámetros to (la dirección a la que se está transfiriendo), tokenId (el identificador del token) y address(0) (indicando que no hay propietario anterior, ya que se está transfiriendo a una nueva dirección). La función _update probablemente actualiza la información del token y devuelve la dirección del propietario anterior.

	- if (previousOwner == address(0)) { revert ERC721NonexistentToken(tokenId); }: Verifica si la dirección del propietario anterior es cero (0x0), lo cual significa que el token no existía antes (no tenía propietario anterior). En ese caso, se revierte la transacción y se lanza una excepción con el mensaje de error ERC721NonexistentToken indicando que el token no existe.

	- else if (previousOwner != from) { revert ERC721IncorrectOwner(from, tokenId, previousOwner); }: Si la dirección del propietario anterior no es cero y no es igual a la dirección desde la cual se intenta transferir (from), se revierte la transacción y se lanza una excepción con el mensaje de error ERC721IncorrectOwner, indicando que el propietario actual no es el correcto.

### 24. function _safeTransfer

	La función _safeTransfer principal es simplemente una interfaz conveniente que permite realizar una transferencia segura de un token al llamar a otra función con los mismos parámetros más un cuarto parámetro opcional, que en este caso está configurado como una cadena vacía. La lógica real de la transferencia segura se encuentra en la función _safeTransfer secundaria, que probablemente esté implementada en otro lugar del contrato.

```.sol
function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }
```

	Esta función _safeTransfer realiza una transferencia segura de un token no fungible (NFT) de la dirección from a la dirección to. Primero, realiza la transferencia del token llamando a la función _transfer, y luego verifica si el contrato receptor es compatible con el estándar ERC-721 llamando a la función _checkOnERC721Received. La utilización de esta función puede ayudar a prevenir posibles problemas en la transferencia de tokens no fungibles.

	
```.sol

function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }
```

### 25. function _approve.

	Esta función _approve proporciona una interfaz más sencilla para aprobar la transferencia de un token NFT, al llamar a otra función interna _approve con la información necesaria. La lógica específica de la aprobación y cualquier otra acción relacionada estarían implementadas dentro de la función _approve completa.

```.sol
function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }
```



```.sol
function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        // Avoid reading the owner unless necessary
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }
```

	- Se verifica si es necesario leer el propietario del token. Esto se hace si se solicita emitir un evento o si la dirección de autorización (auth) no es la dirección cero.

	- Se obtiene la dirección del propietario del token llamando a la función _requireOwned(tokenId).

	- Se verifica la autorización para transferir el token. Si la dirección de autorización no es la dirección cero y no es el propietario ni está autorizado para todos los tokens, se produce una reversión con un error específico (ERC721InvalidApprover).

	- Si se solicita emitir un evento, se emite el evento de aprobación (Approval) con la información del propietario actual, la dirección aprobada (to), y el ID del token.

	- Se establece la aprobación del token para la dirección proporcionada (to) en el mapa _tokenApprovals.

### 26.  function _setApprovalForAll(address owner, address operator, bool approved).

	Esta función se encarga de establecer o revocar los permisos de un operador para manejar todos los tokens de un propietario en un contrato ERC-721, y luego notifica este cambio mediante la emisión de un evento.

``.sol
 function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
```
	- Parámetros de entrada:

		- owner: La dirección del propietario del token (posiblemente un NFT).
		- operator: La dirección del operador al que se le otorgan o revocan permisos.
		- approved: Un booleano que indica si se aprueba o revoca el permiso.

	- Validación del operador:

		- La función comienza verificando si la dirección del operador (operator) no es nula (address(0)). Si es nula, se revierte la transacción con un mensaje de error indicando que el operador no es válido. La función revert se utiliza para cancelar la transacción y revertir todos los cambios realizados hasta ese momento.

	- Establecimiento de permisos:

		- Si la dirección del operador es válida, se procede a establecer o revocar los permisos del operador para manejar todos los tokens del propietario. Esta información se almacena en una estructura de datos llamada _operatorApprovals, que probablemente es un mapeo bidimensional (diccionario) que asocia propietarios con operadores y sus respectivos estados de aprobación.

	- La línea _operatorApprovals[owner][operator] = approved; asigna el estado de aprobación (approved) para el operador específico (operator) en relación con el propietario del token (owner).

	- Emisión de evento:

		- Finalmente, la función emite un evento llamado ApprovalForAll con los parámetros owner (propietario del token), operator (operador) y approved (estado de aprobación). Los eventos en Ethereum son registros que se pueden observar desde fuera del contrato y son comúnmente utilizados para notificar a otras partes interesadas sobre cambios importantes en el contrato.

### 27.  function _requireOwned(uint256 tokenId).

	Esta función asegura que el token con el ID proporcionado existe y tiene un propietario. Si el token no existe, se revierte la transacción con una excepción personalizada. Si el token existe, la función devuelve la dirección del propietario.

```.sol
 function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }
```
	- address owner = _ownerOf(tokenId);: Esta línea llama a una función interna llamada _ownerOf con el parámetro tokenId y asigna el resultado a la variable owner. La función _ownerOf probablemente está definida en otro lugar del contrato y se encarga de devolver la dirección del propietario del token con el ID especificado.

	- if (owner == address(0)) { revert ERC721NonexistentToken(tokenId); }: Aquí se verifica si la dirección del propietario es igual a la dirección cero (address(0)), lo que generalmente indica que el token no tiene propietario (es inexistente). Si esta condición es verdadera, se revierte la transacción y se lanza una excepción de tipo ERC721NonexistentToken con el ID del token como argumento. La excepción indica que el token no existe.

	- return owner;: Si el propietario existe, la función devuelve la dirección del propietario.

### 27. function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data).

	Esta función verifica si un contrato receptor es compatible con el estándar ERC-721 al intentar llamar a su función onERC721Received y maneja posibles excepciones en caso de fallos. Si el contrato receptor no es compatible, se revierte la transacción.

```.sol
 function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
```
	- if (to.code.length > 0): Esta línea verifica si el contrato de destino (to) tiene código. La propiedad code de una dirección en Ethereum devuelve el bytecode del contrato. Si la longitud es mayor que cero, significa que el contrato tiene código y, por lo tanto, es un contrato válido.

	- try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) { ... }: Aquí se intenta llamar a la función onERC721Received del contrato receptor (to). Se espera que esta función esté definida en el estándar ERC-721 y devuelve un valor de 4 bytes llamado retval.

	- if (retval != IERC721Receiver.onERC721Received.selector) { revert ERC721InvalidReceiver(to); }: Después de llamar a la función, se verifica si el valor devuelto (retval) es igual al selector de la función onERC721Received del estándar ERC-721. Si no es así, se revierte la transacción indicando que el receptor es inválido.

	- } catch (bytes memory reason) { ... }: En caso de que ocurra una excepción durante la ejecución del bloque try, se captura el motivo de la excepción en la variable reason.

	- if (reason.length == 0) { revert ERC721InvalidReceiver(to); }: Si la longitud del motivo de la excepción es cero, se revierte la transacción indicando que el receptor es inválido.

	- else { assembly { revert(add(32, reason), mload(reason)) } }: Si hay un motivo de excepción, se utiliza una instrucción de ensamblador de Solidity para revertir la transacción con el motivo específico contenido en reason.
	











