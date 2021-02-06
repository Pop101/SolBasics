pragma solidity >=0.6.0 <0.7.0;
library MaxMath { //if overflow, set to max value
    function cadd(uint256 a, uint256 b) internal pure returns (uint256) {
           uint256 c = a + b;
           if(c < a) c = uint256(-1);
           return c;
    }
    
    function csub(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a == uint256(-1)) return a;
        if(b > a) return 0;
        return a - b;
    }
    
    function cmul(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a == 0) return 0;
        uint256 c = a * b;
        
        if(c / a != b) return uint256(-1);
        return c;
    }
    
    function cdiv(uint256 a, uint256 b) internal view returns (uint256) {
        if(a == uint256(-1)) return a;
        uint256 c = a / b;
        c += seedRand(a) % b < (a % b) ? 1 : 0;
        return c;
    }
    
    function cdiv_setseed(uint256 a, uint256 b, uint256 rand) internal pure returns (uint256) {
        if(a == uint256(-1)) return a;
        uint256 c = a / b;
        c += rand % b < (a % b) ? 1 : 0;
        return c;
    }
    
    function seedRand(uint256 seed) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, seed)));
    }
}