/*
The MIT License (MIT)

Copyright (c) 2016 Dũng Trần <chiro@fkguru.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

// Derived from: https://github.com/chiro-hiro/thedivine/blob/master/contracts/TheDivine.sol
pragma solidity >=0.6.0 <0.7.0;
abstract contract PseudoRandomSource {
    bytes32 internal immotal;
    mapping (address => uint256) internal nonce;
    
    constructor() internal {
        immotal = keccak256(abi.encode(this));
    }
    
    function random() internal returns (bytes32 result) {
        uint256 complex = (nonce[msg.sender] % 11) + 10;
        result = keccak256(abi.encode(immotal, nonce[msg.sender]++));
        for(uint256 c = 0; c < complex; c++){
            result = keccak256(abi.encode(result));
        }
        immotal = result;
    }
}