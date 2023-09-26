// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TitulosAcademicos is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private cantidadTitulosEmitidos;

    string public institucion;

    struct Estudiante {
        string nombre;
        string apellido;
        bool registrado;
    }

    struct Titulo {
        string titulo;
        address owner;
        uint256 fecha;
        bool emitido;
    }

    mapping (address => Estudiante) public estudiantes;
    mapping (address => Titulo) public titulos;

    event EstudianteRegistrado(address indexed estudiante, string nombre, string apellido);
    event TituloEmitido(address indexed estudiante, string titulo, uint256 fecha);

    constructor(string memory _institucion) {
        institucion = _institucion;
    }

    function registrarEstudiante(string memory _nombre, string memory _apellido) external {
        require(owner() != msg.sender, "El administrador del contrato no se puede registrar como estudiante");
        require(!estudiantes[msg.sender].registrado, "El estudiante ya se encuentra registrado");

        estudiantes[msg.sender] = Estudiante(_nombre, _apellido, true);
        emit EstudianteRegistrado(msg.sender, _nombre, _apellido);
    }

    function emitirTitulo(address _estudiante, string memory _titulo) external onlyOwner nonReentrant {
        require(estudiantes[_estudiante].registrado, "El estudiante no se encuentra registrado");
        require(!titulos[_estudiante].emitido, "El estudiante ya tiene un titulo emitido");

        titulos[_estudiante] = Titulo(_titulo, _estudiante, block.timestamp, true);
        cantidadTitulosEmitidos.increment();
        emit TituloEmitido(_estudiante, _titulo, block.timestamp);
    }
}
