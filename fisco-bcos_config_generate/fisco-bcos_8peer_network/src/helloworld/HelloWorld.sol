pragma solidity ^0.4.2;

contract HelloWorld {
    string name;
    mapping(string => uint256)  balances;
    mapping(string => string)  assetOwners;
    constructor() public {
        name = "Hello, World!";
        balances["lefthand"] = 100; // 初始化账号1的金币数为100
        balances["righthand"] = 100; // 初始化账号2的金币数为100
        assetOwners["body"] = "lefthand"; // 初始化资产"body"的属于为账号1
    }

    function get() public view returns(string) {
        return name;
    }

    function  set(string n) public {
    	name = n;
    }



    function transferAsset(string memory sender, string memory receiver) public {

        balances[sender] -= 1; // 转移资产时从发送者扣除一个金币
        balances[receiver] += 1; // 接收者增加一个金币
        assetOwners["body"] = receiver; // 更新资产的所有者为接收者
    }
}
