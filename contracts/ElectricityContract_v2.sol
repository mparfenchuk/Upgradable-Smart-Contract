pragma solidity ^0.4.18;

import "./ElectricityContract_v1.sol";

contract ElectricityContract_v2 is ElectricityContract_v1 {
    
    function getRate() public view returns (uint256) {
        return uintStorage[keccak256("rate")];
    }

    function setRate(uint _newRate) public {
        uintStorage[keccak256("rate")] = _newRate;
    }
}