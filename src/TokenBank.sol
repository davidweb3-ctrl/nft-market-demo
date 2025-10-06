// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MyERC20} from "./MyERC20.sol";

contract TokenBank {
    MyERC20 public immutable token;

    mapping(address account => uint256) private _balances;

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    constructor(MyERC20 _token) {
        token = _token;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "TokenBank: amount is zero");

        _balances[msg.sender] += amount;
        emit Deposited(msg.sender, amount);

        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "TokenBank: transfer failed");
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "TokenBank: amount is zero");

        uint256 balance = _balances[msg.sender];
        require(balance >= amount, "TokenBank: insufficient balance");

        _balances[msg.sender] = balance - amount;
        emit Withdrawn(msg.sender, amount);

        bool success = token.transfer(msg.sender, amount);
        require(success, "TokenBank: transfer failed");
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
}
