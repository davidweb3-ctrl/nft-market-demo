// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 1e18;

    constructor() ERC20("BaseERC20", "BERC20") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        address owner = _msgSender();
        require(balanceOf(owner) >= value, "ERC20: transfer amount exceeds balance");
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        address spender = _msgSender();
        require(balanceOf(from) >= value, "ERC20: transfer amount exceeds balance");
        require(allowance(from, spender) >= value, "ERC20: transfer amount exceeds allowance");
        return super.transferFrom(from, to, value);
    }
}
