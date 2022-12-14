// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin-contracts/token/ERC721/ERC721.sol";
import "@openzeppelin-contracts/access/Ownable.sol";
import "@openzeppelin-contracts/utils/Counters.sol";
import "./interfaces/IpdcFactory.sol";
import "@openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin-contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract PostDatedCryptoPayment is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    address public pdcFactoryAddress;

    IpdcFactory public pdcFactory;

    modifier onlyChild() {
        require(
            getPdcAccountListMapping() != address(0),
            "Not a child calling the mint!"
        );
        _;
    }

    modifier onlyFactory() {
        require(
            msg.sender == pdcFactoryAddress,
            "Not a factory calling the mint!"
        );
        _;
    }

    constructor() ERC721("Post_Dated Crypto Payment", "PDC") {}

    function safeMint(address to, string memory uri)
        public
        onlyFactory
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    function getCurrentToken() public view returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        return tokenId;
    }

    function setPdcfactoryAddress(address _pdcFactoryAddress) public onlyOwner {
        pdcFactoryAddress = _pdcFactoryAddress;
        pdcFactory = IpdcFactory(pdcFactoryAddress);
    }

    function getPdcAccountListMapping() public view returns (address) {
        address childAddress = pdcFactory.pdcUserMapping(msg.sender);
        return childAddress;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
