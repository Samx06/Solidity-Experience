// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the Owner");
        _;
    }

    modifier validAddress(address merchantAddress) {
        require(merchantAddress != address(0), "Invalid Address");
        _;
    }

    modifier checkStudent(address studentAddress) {
        bool Sregister;
        for (uint256 i = 0; i < students.length; i++) {
            if (msg.sender == students[i]) {
                Sregister = true;
            }
        }
        require(Sregister == true, "You are not a student with scholarship");
        _;
    }

    struct merchantDetails {
        uint256 credits;
        string _category;
    }


    uint256 total_credits = 1000000;
    mapping(address => mapping(uint8 => uint)) Students;
    mapping(address => merchantDetails) Merchants;
    address[] merchants;
    address[] students;
    string[] categories = ["Meal", "Academics", "Sports", "All"];

    //This function assigns credits to student getting the scholarship
    function grantScholarship(
        address studentAddress,
        uint256 credits,
        string memory category
    ) public onlyOwner {
        for (uint256 i = 0; i < merchants.length; i++) {
            require(
                studentAddress != merchants[i],
                "This is a Merchant Address"
            );
        }
        require(studentAddress != owner, "Owner can't be granted scholarship");
        require(
            credits > 0 && credits <= total_credits,
            "Amount can't be zero or out of balance"
        );
        bool exists;
        for (uint256 i = 0; i < students.length; i++) {
            if (studentAddress == students[i]) {
                exists = true;
            }
        }
        if(exists == false) {
            students.push(studentAddress);
        }
        for(uint8 z = 0; z < 4; z++) {
            if(keccak256(abi.encodePacked(toLowerCase(category))) == keccak256(abi.encodePacked(toLowerCase(categories[z])))){
                Students[studentAddress][z] += credits;
            }
        }
        total_credits -= credits;
    }

    //This function is used to register a new merchant who can receive credits from students
    function registerMerchantAddress(
        address merchantAddress,
        string memory category
    ) public onlyOwner validAddress(merchantAddress) {
        for (uint256 j = 0; j < students.length; j++) {
            require(
                merchantAddress != students[j],
                "This is a Student address"
            );
        }
        require(merchantAddress != owner, "Owner can't be merchant");
        bool registered;
        for (uint8 i = 0; i < merchants.length; i++) {
            if (merchantAddress == merchants[i]) {
                registered = true;
            }
        }
        if (registered == false) {
            merchants.push(merchantAddress);
        }
        for (uint256 i = 0; i < 3; i++) {
            if (
                keccak256(abi.encodePacked(toLowerCase(category))) ==
                keccak256(abi.encodePacked(toLowerCase(categories[i])))
            ) {
                Merchants[merchantAddress]._category = categories[i];
            }
        }
    }

    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address merchantAddress)
        public
        onlyOwner
        validAddress(merchantAddress)
    {
        bool registered;
        for (uint8 i = 0; i < merchants.length; i++) {
            if (merchantAddress == merchants[i]) {
                registered = true;
                merchants[i] = merchants[merchants.length - 1];
                merchants.pop();
            }
        }
        require(registered == true, "You never registered this Merchant bro");

        total_credits += Merchants[merchantAddress].credits;
        Merchants[merchantAddress].credits = 0;
    }

    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address studentAddress) public onlyOwner {
        bool registered;
        for (uint256 i = 0; i < students.length; i++) {
            if (studentAddress == students[i]) {
                students[i] = students[students.length - 1];
                students.pop();
                registered = true;
            }
        }
        require(registered == true, "Incorrect Address");
        uint256 total;
        for(uint8 i = 0; i < 4; i++) {
            total += Students[studentAddress][i];
            Students[studentAddress][i] = 0;
        }
        total_credits += total;
    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address merchantAddress, uint256 amount) public {
        bool Sregister;
        for (uint256 i = 0; i < students.length; i++) {
            if (msg.sender == students[i]) {
                Sregister = true;
            }
        }
        require(Sregister == true, "You are not a student with scholarship");
        bool Mregister;
        for (uint256 j = 0; j < merchants.length; j++) {
            if (merchantAddress == merchants[j]) {
                Mregister = true;
            }
        }
        require(Mregister == true, "Incorrect merchant Address");
        for(uint8 i = 0; i < 4; i++) {
            if(keccak256(abi.encodePacked(toLowerCase(Merchants[merchantAddress]._category))) == keccak256(abi.encodePacked(toLowerCase(categories[i])))){
                if(Students[msg.sender][i] > amount) {
                    Students[msg.sender][i] -= amount;
                    Merchants[merchantAddress].credits += amount;
                } else {
                    uint256 remaining = amount - Students[msg.sender][i];
                    require(remaining >= Students[msg.sender][3],"Insufficient Balance");
                    Students[msg.sender][i] = 0;
                    Students[msg.sender][3] -= remaining;
                }
            }
        }
    }

    //This function is used to see the available credits assigned.
    function checkBalance(string memory category) public view returns (uint256) {
        uint256 result;
        bool check;
        for (uint8 i = 0; i < students.length; i++) {
            if (msg.sender == students[i]) {
                for(uint8 j = 0; j < categories.length; j++) {
                    if (keccak256(abi.encodePacked(toLowerCase(category))) == keccak256(abi.encodePacked(toLowerCase(categories[j])))) {
                        result = Students[msg.sender][j];
                        check = true;
                        break;
                    }
                }
            }
        }
        for (uint256 j = 0; j < merchants.length; j++) {
            if (msg.sender == merchants[j] && keccak256(abi.encodePacked(toLowerCase(Merchants[msg.sender]._category))) == keccak256(abi.encodePacked(toLowerCase(category)))) {
                result = Merchants[msg.sender].credits;
                check = true;
                break;
            }
        }
        if (msg.sender == owner && keccak256(abi.encodePacked(toLowerCase(category))) == keccak256(abi.encodePacked(toLowerCase(categories[3])))) {
            result = total_credits;
            check = true;
        }
        require(check == true, "Invalid category or Address");

        return result;
    }

    function showCategory() public view returns (string memory) {
        bool check;
        string memory result;
        for(uint i = 0; i < merchants.length; i++) {
            if(msg.sender == merchants[i] && keccak256(abi.encodePacked(toLowerCase(Merchants[msg.sender]._category))) == keccak256(abi.encodePacked(toLowerCase(categories[i])))){
                check = true;
                result = categories[i];
            }
        }
        require(check == true, "You are not merchant");
        return result;
    }

    function toLowerCase(string memory str) internal pure returns (string memory) {
        bytes memory newStr = bytes(str);
        for (uint256 i = 0; i < newStr.length; i++) {
            if (uint8(newStr[i]) >= 65 && uint8(newStr[i]) <= 90) {
                newStr[i] = bytes1(uint8(newStr[i]) + 32);
            }
        }
        return string(newStr);
    }
}
