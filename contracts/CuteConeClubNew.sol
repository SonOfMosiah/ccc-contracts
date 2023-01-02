// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @notice The contract is already initailized
error AlreadyInitialized();
/// @notice The ERC20 transfer failed
error TransferFailed();
/// @notice The mint limit for the address has been exceeded
error MintLimitExceeded();
/// @notice The NFTs are sold out
error SoldOut();
/// @notice Invalid inputs
error InvalidInputs();

/// @title Cute Cone Club
/// @author sonofmosiah.eth
contract CuteConeClubNew is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, ReentrancyGuard {
    using Strings for uint256;
    constructor(string memory _uri) ERC721("CuteConeClub", "CCC") {
        baseURI_ = _uri;
    }

    /// @notice Emitted when the base URI is set
    /// @param uri The base URI
    event BaseURISet(string uri);

    /// @notice Total supply of NFTs
    uint256 constant public TOTAL_SUPPLY = 420;

    /// @notice Whether the base URI has been set
    bool public initialized;
    uint256 private nextId;
    string private baseURI_;

    /// @notice Mapping of the minted amount per address
    mapping (address => uint256) public mintedAmount;

    /// @notice Mapping of the mintable amount per address
    mapping (address => uint256) public mintableAmount;

    /// @notice Mint an NFT
    function mint() external nonReentrant {
        if (nextId > TOTAL_SUPPLY) {
            revert SoldOut();
        }
        if (++mintedAmount[msg.sender] > mintableAmount[msg.sender]) {
            revert MintLimitExceeded();
        }

        _safeMint(msg.sender, nextId);
        ++nextId;
    }

    /// @notice Return the URI for the token
    /// @param tokenId The token ID
    /// @return The URI for the token
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /// @notice Return whether the interface is supported
    /// @param interfaceId The interface ID
    /// @return Whether the interface is supported
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Set the mintable amount for the allowlist addresses
    /// @param _addresses The addresses on the allowlist
    /// @param _amounts The amounts allowed to mint
    function setMintableAmount(address[] calldata _addresses, uint256[] calldata _amounts)
        external
        onlyOwner
    {
        if (_addresses.length != _amounts.length) {
            revert InvalidInputs();
        }

        for (uint256 i = 0; i < _addresses.length; i++) {
            mintableAmount[_addresses[i]] = _amounts[i];
        }
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function safeMintBatch(address to, uint256[] memory tokenIds) public onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _safeMint(to, tokenIds[i]);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}