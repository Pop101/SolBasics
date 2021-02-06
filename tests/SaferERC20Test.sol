// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "../contracts/SaferERC20.sol";

contract Dummy is ERC20 {
    constructor() ERC20("Idiot", "DMY") public { _mint(address(this), 400000); }
}

contract Dumber {
    constructor() public {}
}

contract Readr {
    using SaferERC20 for IERC20;
    
    IERC20 public dummy = IERC20(address(0));
    constructor() public {
        dummy = new Dummy();
    }
    
    function t1(address tok) public view returns(uint8) {
        return IERC20(tok).safeDecimals();
    }
    
    function t2(address tok) public view returns(uint256) {
        return IERC20(tok).safeTotalSupply();
    }
    function t3(address tok) public view returns(uint256) {
        return IERC20(tok).safeBalanceOf(tok);
    }
}