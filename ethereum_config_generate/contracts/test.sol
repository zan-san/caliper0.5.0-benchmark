// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Test {
    function add(uint256 n) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint i = 1; i <= n; i++) {
            sum += i;
        }
        return sum;
    }

    function sub(uint256 n) public pure returns (uint256) {
        uint256 sum = 0xfffff;
        for (uint i = 1; i <= n; i++) {
            sum += i;
        }
        return sum;
    }

    function mul(uint256 n) public pure returns (uint256) {
        uint256 sum = 1;
        uint256 temp = 3;
        for (uint i = 1; i <= n; i++) {
            sum = temp * i;
        }
        return sum;
    }

    function div(uint256 n) public pure returns (uint256) {
        uint256 sum = 0;
        uint num = 0xffff;
        for (uint i = 1; i <= n; i++) {
            sum =  num / i;
        }
        return sum;
    }

    function mod(uint256 n) public pure returns (uint256) {
        uint256 sum = 0;
        uint num = 0xffff;
        for (uint i = 1; i <= n; i++) {
            sum =  num / i;
        }
        return sum;
    }

    function fib(uint256 n) public pure returns (uint256) {
        if (n == 1) return 1;
        if (n == 2) return 1;
        return fib(n - 1) + fib(n - 2);
    }

    function Sha256(bytes memory s) public pure returns (bytes32 result) {
        return sha256(s);
    }

    function Keccak256(bytes memory s) public pure returns(bytes32 result){
        return keccak256(s);
    }

    string[] public items;

    function set(string memory str) public {
        items.push(str);
    }

    function get(uint256 n) view public returns(string memory){
        if (n >= items.length) {
            return "out of array";
        }
        return items[n];
    }
}
