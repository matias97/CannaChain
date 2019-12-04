
pragma solidity ^0.4.24;



contract CannaChain {
    address public owner;
    mapping(address=>productor) productoresId;
    mapping(address=>socio) sociosId;
    mapping(address=>uint256) cantidadDisponible;
    mapping(string=>cepa) cepasIds;
    
    constructor() public {
        owner = msg.sender;
    }
    
    struct productor {
        string nombre;
        address productorDir;
        mapping(string=>uint256) producido;
    }
    
    struct socio {
        string nombre;
        address socioDir;
        uint256 cantMensualDisponible;
        uint256 cantMensualComprado;
        mapping(uint256=>cepa) historial;
    }
    
    struct cepa {
        string nombre;
        string descripcion;
        uint256 disponible;
        address productorDir;
        uint256 precio;
    }
    
    
    
    function getProductor(address _productorDir) public view returns (string) {
        return productoresId[_productorDir].nombre;
    }
    
    
    function agregarProductor(string _nombre, address _productorDir) public returns (string) {
        require(msg.sender==owner);
        productor memory nuevoProductor;
        nuevoProductor.nombre = _nombre;
        nuevoProductor.productorDir = _productorDir;
        productoresId[nuevoProductor.productorDir] = nuevoProductor;
        return nuevoProductor.nombre;
    }
    
    function getSocio(address _socioDir) public view returns (string) {
        return sociosId[_socioDir].nombre;
    }
    
    function agregarSocio(string _nombre, address _socioDir, uint256 _cantMensualDisponible) public returns (string) {
        require(msg.sender==owner);
        socio memory nuevoSocio;
        nuevoSocio.nombre = _nombre;
        nuevoSocio.socioDir = _socioDir;
        nuevoSocio.cantMensualDisponible = _cantMensualDisponible;
        sociosId[nuevoSocio.socioDir] = nuevoSocio;
        cantidadDisponible[nuevoSocio.socioDir] = nuevoSocio.cantMensualDisponible;
        return nuevoSocio.nombre;
    }
    
    function getCepa(string _nombre) public view returns (string) {
        return cepasIds[_nombre].descripcion;
    }
    
    //El productor agrega una cepa nueva, indicando su informacion y la cantidad que produjo.
    function agegarCepa(string _nombre, string _descripcion, uint256 _disponible, address _productorDir, uint256 _precio) public returns (string) {
        require(productoresId[_productorDir].productorDir==_productorDir);
        require(msg.sender==_productorDir);
        cepa memory nuevaCepa;
        nuevaCepa.nombre = _nombre;
        nuevaCepa.descripcion = _descripcion;
        nuevaCepa.disponible = _disponible;
        nuevaCepa.productorDir = _productorDir;
        nuevaCepa.precio = _precio;
        cepasIds[nuevaCepa.nombre] = nuevaCepa;
        productoresId[_productorDir].producido[_nombre] = 0;
        return nuevaCepa.nombre;
    }
    
    //El owner asegura que el productor produjo lo que dijo y se lo asigna a su perfil.
    function producir(uint256 _cantidad, address _productorDir, string _nombre) public {
        require(msg.sender==owner);
        productoresId[_productorDir].producido[_nombre] += _cantidad;
    }
    
    
    //Al pasar el mes, se renuevan las cantidades disponibles para comprar.
    function renovarCantidades(address _socioDir) public {
        require(msg.sender==owner);
        cantidadDisponible[_socioDir] = sociosId[_socioDir].cantMensualDisponible;
    }
    
    //Los socios pueden comprar cepas: Se verifica que el socio este asociado y que no haya alcanzado el limite.
    function comprarCepa(address _socioDir, uint256 _cantidad, string _nombreCepa) public payable returns (uint256) {
        require(sociosId[_socioDir].socioDir==_socioDir);
        require(sociosId[_socioDir].cantMensualComprado<sociosId[_socioDir].cantMensualDisponible);
        require(cantidadDisponible[_socioDir]>_cantidad);
        require(cepasIds[_nombreCepa].disponible>_cantidad);
        require(cepasIds[_nombreCepa].precio<=msg.value);
        sociosId[_socioDir].cantMensualComprado +=_cantidad;
        cantidadDisponible[_socioDir] -= _cantidad;
        cepasIds[_nombreCepa].disponible -= _cantidad;
        cepasIds[_nombreCepa].productorDir.transfer(msg.value);
        return cantidadDisponible[_socioDir]; //Devuelve la cantidad que le queda disponible.
    }
    
    
}
