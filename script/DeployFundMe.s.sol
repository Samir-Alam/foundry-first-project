// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployFundMe is Script{
    function run() external returns (FundMe) {
        // anything before startBroadcast is not sended as a real transaction
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig(); //if we return somthing from struct we have to wrap it with parenthesis if the struct contains/returns more than 1 attribute or variable

        vm.startBroadcast();
        // Mock
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}