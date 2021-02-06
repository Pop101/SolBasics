pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import {FixedPoint} from "https://github.com/Uniswap/uniswap-lib/blob/master/contracts/libraries/FixedPoint.sol";
import {IUniswapV2Router02} from "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";

contract UniOracle {
    using FixedPoint for FixedPoint.uq112x112;
    using FixedPoint for FixedPoint.uq144x112;
    
    IUniswapV2Router02 constant private uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    uint32 immutable private period;
    
    mapping(address => OracleData) private oracles;
    struct OracleData {
        uint256 priceCumulative;
        uint32 blockTimestamp;
        FixedPoint.uq112x112 priceAverage;
    }
    
    constructor(uint32 _period) public {
        period = _period;
    }
    
    /**
     * Updates the oracle for the ERC20 at the given address
     * Reverts if not a valid ERC20
     * Does nothing if the coin's last recorded time is less than this oracle's period
    **/
    function updateOracle(address coin) public { 
        OracleData storage od = oracles[coin];
        address pair = IUniswapV2Factory(uniswapRouter.factory()).getPair(uniswapRouter.WETH(), coin);
        require(pair != address(0), "UNIORACLE: WETH-Coin pair does not exist!");
        
        // Get price
        bool coin_is_token0 = IUniswapV2Pair(pair).token0() == coin;
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint256 priceCumulative = coin_is_token0 ? IUniswapV2Pair(pair).price0CumulativeLast() : IUniswapV2Pair(pair).price1CumulativeLast();
        
        // If timestamp different, spoof value
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast < blockTimestamp) { 
            uint32 fullTimeElapsed = blockTimestamp - blockTimestampLast;
            priceCumulative += fullTimeElapsed * uint224(
                coin_is_token0 ?
                    FixedPoint.fraction(reserve1, reserve0)._x : 
                    FixedPoint.fraction(reserve0, reserve1)._x
            );
        }
        
        uint32 timeElapsed = blockTimestamp - od.blockTimestamp;
        if(timeElapsed < period) return;
        
        // Update internal oracle
        if(od.priceCumulative != 0)
            od.priceAverage = FixedPoint.uq112x112(uint224( (priceCumulative - od.priceCumulative) / timeElapsed ));
        od.priceCumulative = priceCumulative;
        od.blockTimestamp = blockTimestamp;
    }
    
    /**
     * The amount of weth that the given amount of coin is worth
    **/
    function consultWorth(address coin, uint256 amount) public view returns (uint144) {
        require(oracles[coin].priceCumulative > 0, "UNIORACLE: Coin not recorded");
        require(oracles[coin].priceAverage._x > 0, "UNIORACLE: Coin has only 1 datapoint");
        return oracles[coin].priceAverage.mul(amount).decode144();
    }
    
    /**
     * The amount of coin that the given amount of weth can buy
     * Somewhat lossy, but that's the price of storing less
    **/
    function consultPrice(address coin, uint256 amount) public view returns (uint144) { 
        require(oracles[coin].priceCumulative > 0, "UNIORACLE: Coin not recorded");
        require(oracles[coin].priceAverage._x > 0, "UNIORACLE: Coin has only 1 datapoint");
        return oracles[coin].priceAverage.reciprocal().mul(amount).decode144();
    }
}