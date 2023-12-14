// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract DiamondLedger {

    uint[] _weights;

    //this function imports the diamonds
    function importDiamonds(uint[] memory weights) public {
        for(uint i = 0; i < weights.length; i++) {
            require(weights[i] >= 0 && weights[i] <= 1000, "Invalid weight");
        }
        uint[] memory result = new uint[](_weights.length + weights.length);
        for(uint t = 0; t < _weights.length; t++) {
            result[t] = _weights[t];
        }

        for(uint j = 0; j < weights.length; j++) {
            result[_weights.length + j] = weights[j];
        }
        _weights = result;
    }

    //this function returns the total number of available diamonds as per the weight and offset
    function availableDiamonds(uint weight, uint allowance) public view returns(uint) {
        uint upperdifference = weight + allowance;
        uint lowerdifference = weight - allowance;
        uint count = 0;
        for(uint i = 0; i < _weights.length; i++) {
            if(_weights[i] <= upperdifference && _weights[i] >= lowerdifference) {
                count++;
            }
        }
        return count;
    }

    function array() public view returns(uint[] memory) {
        return _weights;
    }
}