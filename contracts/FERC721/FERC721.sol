// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IFERC721.sol";

contract FERC721 is IFERC721 {
    string private _name;
    string private _symbol;

    mapping(address => mapping(uint256 => uint256)) private _balances;
    mapping(uint256 => address[]) private _owners;

    mapping(address => mapping(address => mapping(uint256 => uint256)))
        private _allowances;

    mapping(uint256 => uint256) private _fractions;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(IFERC721)
        returns (bool)
    {
        return interfaceId == type(IFERC721).interfaceId;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner, uint256 tokenId)
        public
        view
        override
        returns (uint256 balance)
    {
        return _balances[owner][tokenId];
    }

    function fractionOf(uint256 tokenId)
        public
        view
        override
        returns (uint256 fraction)
    {
        return _fractions[tokenId];
    }

    function ownersOf(uint256 tokenId)
        public
        view
        override
        returns (address[] memory owner)
    {
        return _owners[tokenId];
    }

    function transfer(
        address recipient,
        uint256 tokenId,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, tokenId, amount);
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId].length > 0;
    }

    function _addOwner(uint256 tokenId, address owner) internal {
        address[] storage values = _owners[tokenId];
        for (uint256 i = 0; i < values.length; i++) {
            if (values[i] == owner) {
                return;
            }
        }
        _owners[tokenId].push(owner);
    }

    function _removeOwner(uint256 tokenId, address owner) internal {
        address[] storage values = _owners[tokenId];
        for (uint256 i = 0; i < values.length; i++) {
            if (values[i] == owner) {
                values[i] = values[values.length - 1];
                values.pop();
                break;
            }
        }
    }

    function _mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        require(to != address(0), "FERC721: mint to the zero address");
        require(!_exists(tokenId), "FERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);
        _fractions[tokenId] = amount;
        _balances[to][tokenId] += amount;
        _addOwner(tokenId, to);

        emit Transfer(address(0), to, tokenId, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        require(
            sender != address(0),
            "FERC721: transfer from the zero address"
        );
        require(
            recipient != address(0),
            "FERC721: transfer to the zero address"
        );

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender][tokenId];
        require(
            senderBalance >= amount,
            "FERC721: transfer amount exceeds balance"
        );
        _balances[sender][tokenId] = senderBalance - amount;
        _balances[recipient][tokenId] += amount;
        if (_balances[sender][tokenId] == 0) {
            _removeOwner(tokenId, sender);
        }
        _addOwner(tokenId, recipient);

        emit Transfer(sender, recipient, tokenId, amount);
    }

    function allowance(
        address owner,
        address spender,
        uint256 tokenId
    ) public view override returns (uint256) {
        return _allowances[owner][spender][tokenId];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 tokenId,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, tokenId, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender][tokenId];
        require(
            currentAllowance >= amount,
            "FERC721: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, tokenId, currentAllowance - amount);

        return true;
    }

    function approve(
        address to,
        uint256 tokenId,
        uint256 amount
    ) public override {
        _approve(msg.sender, to, tokenId, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "FERC721: approve from the zero address");
        require(spender != address(0), "FERC721: approve to the zero address");
        _allowances[owner][spender][tokenId] = amount;
        emit Approval(owner, spender, tokenId, amount);
    }
}
