pragma solidity >=0.6.0 <0.7.0;
abstract contract Ownable {
    address payable public owner;
    address payable public nextOwner;
    
    constructor() internal {
        owner = msg.sender;
        nextOwner = msg.sender;
    }
    
    modifier onlyOwner {
        require (msg.sender == owner, "Function may only be called by owner");
        _;
    }
    
    function transferOwner(address payable _nextOwner) external onlyOwner {
        nextOwner = _nextOwner;
    }
    
    function acceptOwner() external {
        require(msg.sender == nextOwner, "Must be pre-approved by owner");
        owner = nextOwner;
    }
}