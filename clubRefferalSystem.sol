// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MyContract {

    address[] public Members;

    modifier RequiredAmount() {
        require(msg.value == 1000000000000000000, "1 ether required to join");
        _;
    }

    modifier ExistingMember() {
        for(uint i = 0; i < Members.length; i++) {
            require(Members[i] != msg.sender, "You are already a member");
        }
        _;
    }
    
    function join() public payable RequiredAmount ExistingMember {
        Members.push(msg.sender);
    }

    function join_referrer(address payable refferee) public payable RequiredAmount ExistingMember {
        for(uint i = 0; i < Members.length; i++){
            require(Members[i] == refferee, "The refferee is not a member");
        }
        Members.push(msg.sender);
        uint returnAmount = 100000000000000000;
        refferee.transfer(returnAmount);
    }

    function get_members() public view returns(address[] memory) {
        return Members;
    }
}