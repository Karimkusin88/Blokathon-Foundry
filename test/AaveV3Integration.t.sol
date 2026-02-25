// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/facets/utilityFacets/aaveV3/AaveV3Base.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DataTypes} from "@aave/aave-v3-core/contracts/protocol/libraries/types/DataTypes.sol";

contract TestableAave is AaveV3Base {
    function getReserveData(address tokenIn) external view override returns (DataTypes.ReserveData memory) {
        return _getReserveData(tokenIn);
    }
    function lend(address tokenIn, uint256 amountIn) external override {
        _lend(tokenIn, amountIn);
    }
    function withdraw(address tokenIn, uint256 amountToWithdraw) external override {
        _withdraw(tokenIn, amountToWithdraw);
    }
}

contract AaveV3IntegrationTest is Test {
    TestableAave public aave;
    address constant ARB_WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    function setUp() public {
        aave = new TestableAave();
    }

    function testFullFlow() public {
        uint256 amountToLend = 1 ether;
        deal(ARB_WETH, address(aave), amountToLend);

        // 1. Lend
        aave.lend(ARB_WETH, amountToLend);
        
        // 2. Withdraw All (Input 0)
        aave.withdraw(ARB_WETH, 0); 
        
        // 3. Verifikasi dengan toleransi 10 wei (Precision Loss Fix)
        uint256 balanceFinally = IERC20(ARB_WETH).balanceOf(address(aave));
        assertApproxEqAbs(balanceFinally, amountToLend, 10, "Duit balik dengan toleransi pembulatan");
        
        console.log("-----------------------------------------");
        console.log("STATUS: DOUBLE HIJAU JAYA!");
        console.log("Saldo Akhir:", balanceFinally);
        console.log("-----------------------------------------");
    }
}
