// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD or Mainnet ETH/USD or ... have diffrent addresses

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil chain, we deploy mock contracts for us to interact with
    // Otherwise, grab the existing address from the live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        // this constructor is for the DeployFundMe to be redirected to the active chain network (anvil/sepolia)
        // block.chainid is solidities global variable -> it refers to the chain's current id
        if (block.chainid == 11155111) {
            // 11155111 is sepolia chain id
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    // we have to use memory keyword as it is a special object
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // get this pricefeed address from https://docs.chain.link/data-feeds/price-feeds/addresses
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // get this pricefeed address from https://docs.chain.link/data-feeds/price-feeds/addresses
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // price feed address
        // this if block is here to check if we have already created a pricefeed then we do not have to make another one
        if (activeNetworkConfig.priceFeed != address(0)){   // address(0) is to get the 0 address or default value
            return activeNetworkConfig;
        }

        // 1. Deploy the mocks(dummy contracts)
        // 2. Return the mock address

        vm.startBroadcast(); // to deploy mock contracts to the anvil chain we are working on
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); // decimals of eth is 8 and 2000 is reandom and e8 is because it has 8 digits
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
