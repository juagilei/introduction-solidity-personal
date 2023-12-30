// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importa la interfaz ERC-20 estándar.
import "./IERC721.sol";

// Contrato MyNFT que hereda de ERC721.
contract MyNFT is ERC721 {
    // Función externa para realizar la creación (mint) de un nuevo token.
    function mint(address to, uint id) external {
        _mint(to, id);
    }

    // Función externa para realizar la destrucción (burn) de un token.
    function burn(uint id) external {
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}