// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721 is ERC721URIStorage, Ownable {
    uint256 private _tokenIdTracker;

    constructor() ERC721("MyERC721", "M721") Ownable(msg.sender) {}

    function mint(address to, string calldata tokenURI_) external onlyOwner returns (uint256 tokenId) {
        _tokenIdTracker += 1;
        tokenId = _tokenIdTracker;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI_);
    }
}
