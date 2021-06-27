// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FERC721/FERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PRIVIFERC721TestToken is FERC721, Ownable {
    constructor() FERC721("PRIVIERC20TestToken", "PRIVIERC20Test") {}

    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) public onlyOwner {
        _mint(_to, _tokenId, _amount);
    }
}
