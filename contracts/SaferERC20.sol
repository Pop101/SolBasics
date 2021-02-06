// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

abstract contract IERC20D is IERC20 {
    uint8 public decimals;
}

library SaferERC20 {
    //TODO: use CancerMath
    using SafeMath for uint256;
    using Address for address;
    
    function safeTotalSupply(IERC20 token) internal view returns (uint256) {
        bytes memory returndata = _callStaticDefaultReturn(token, abi.encodeWithSelector(token.totalSupply.selector), toBytes32(0));
        return abi.decode(returndata, (uint256));
    }
    
    function safeBalanceOf(IERC20 token, address account) internal view returns (uint256) {
        bytes memory returndata = _callStaticDefaultReturn(token, abi.encodeWithSelector(token.balanceOf.selector, account), toBytes32(0));
        return abi.decode(returndata, (uint256));
    }
    
    function safeAllowance(IERC20 token, address owner, address spender) internal view returns (uint256) {
        bytes memory returndata = _callStaticDefaultReturn(token, abi.encodeWithSelector(token.balanceOf.selector, owner, spender), toBytes32(0));
        return abi.decode(returndata, (uint256));
    }
    
    function safeDecimals(IERC20 token) internal view returns (uint8) {
        try IERC20D(address(token)).decimals() returns (uint8 _decimals) {
            return _decimals;
        }
        catch {
            return 0;
        }
    }
    
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SAFERERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SAFERERC20: ERC20 operation did not succeed");
        }
    }
    
    function _callDefaultReturn(IERC20 token, bytes memory data, bytes memory defaultReturn) private returns(bytes memory returndata) {
        if(!address(token).isContract()) return defaultReturn;
        
        returndata = defaultReturn;
        (bool success, bytes memory _returndata) = address(token).call(data);
        if(success) returndata = _returndata;
    }
    
    function _callStaticDefaultReturn(IERC20 token, bytes memory data, bytes memory defaultReturn) private view returns(bytes memory returndata) {
        if(!address(token).isContract()) return defaultReturn;
        
        returndata = defaultReturn;
        (bool success, bytes memory _returndata) = address(token).staticcall(data);
        if(success) returndata = _returndata;
    }
    
    function toBytes32(uint256 x) private pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }
}