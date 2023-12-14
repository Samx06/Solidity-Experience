// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.21;

contract MyContract {
    
    uint public finalfare;

    struct Distance {
        string station;
        uint BetweenStations;
    }

    mapping (uint => Distance) Calculate;

    constructor() {
        Calculate[0].station = "A";
        Calculate[1].station = "B";
        Calculate[2].station = "C";
        Calculate[3].station = "D";
        Calculate[4].station = "E";

        Calculate[0].BetweenStations = 0;
        Calculate[1].BetweenStations = 2;
        Calculate[2].BetweenStations = 5;
        Calculate[3].BetweenStations = 11;
        Calculate[4].BetweenStations = 23;
    }

    function calculatefare(uint a, uint b) public {
        uint CalculatedFare = 0;
        if(a < b) {
            for(uint i = a+1; i <= b; i++) {
                CalculatedFare += Calculate[i].BetweenStations;
            }
        }
        else {
            for(uint i = a; i > b; i--) {
                CalculatedFare += Calculate[i].BetweenStations;
            }
        }

        finalfare = CalculatedFare;
    }
}