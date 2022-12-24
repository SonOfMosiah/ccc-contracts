// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @notice The contract is already initailized
error AlreadyInitialized();
/// @notice The NFTs have already been revealed
error AlreadyRevealed();
/// @notice The ERC20 transfer failed
error TransferFailed();
/// @notice The mint limit for the address has been exceeded
error MintLimitExceeded();
/// @notice The NFTs are sold out
error SoldOut();

/// @title Cute Cone Club
/// @author sonofmosiah.eth
contract CuteConeClub is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Strings for uint256;
    constructor(address _weth) ERC721("CuteConeClub", "CCC") {
        WETH = _weth;
        _mintToTreasury(TREASURY);
    }

    /// @notice Emitted when the base URI is set
    /// @param uri The base URI
    event BaseURISet(string uri);

    address immutable private WETH;
    address constant private TREASURY = 0x7e7c3543C4426B9E149a837eE843c4aD730738e4;

    /// @notice Mint price in WETH (.01 WETH)
    uint256 constant public MINT_PRICE = 0.01 ether;
    uint256 constant private MAX_MINT_AMOUNT = 10;
    /// @notice Total supply of NFTs
    uint256 constant public TOTAL_SUPPLY = 420;

    /// @notice Whether the base URI has been set
    bool public initialized;
    /// @notice Whether the reveal URI has been set
    bool public revealed;
    uint256 private nextId = 43;
    string private baseURI_;

    /// @notice Mapping of the minted amount per address
    mapping (address => uint256) public mintedAmount;

    /// @notice Set the Base URI for the preveal image
    /// @param _uri The base URI
    function setPrerevealURI(string memory _uri) external onlyOwner {
        if (initialized || revealed) {
            revert AlreadyInitialized();
        }
        baseURI_ = _uri;
        initialized = true;
        emit BaseURISet(_uri);
    }

    /// @notice Set the Base URI for the reveal image
    /// @param _uri The base URI
    function setRevealURI(string memory _uri) external onlyOwner {
        if (revealed) {
            revert AlreadyRevealed();
        }
        baseURI_ = _uri;
        revealed = true;    
        emit BaseURISet(_uri);
    }

    /// @notice Mint `amount` of NFTs
    /// @param amount The amount of tokens to mint
    function mint(uint256 amount) external {
        if (nextId + amount > TOTAL_SUPPLY) {
            revert SoldOut();
        }
        if (mintedAmount[msg.sender] + amount > MAX_MINT_AMOUNT) {
            revert MintLimitExceeded();
        }
        mintedAmount[msg.sender] += amount;

        uint256 price = MINT_PRICE * amount;
        if (!IERC20(WETH).transferFrom(msg.sender, TREASURY, price)) {
            revert TransferFailed();
        }

        string memory baseURI = _baseURI();
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(msg.sender, nextId);
            _setTokenURI(nextId, string(abi.encodePacked(baseURI, nextId.toString())));
            ++nextId;
        }
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
        if (!revealed) {
            return _baseURI();
        }
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

    function _mintToTreasury(address to) internal {
        string memory baseURI = _baseURI();
        // Mint the first 42 NFTs to the treasury starting at token ID 1
        for (uint256 i = 1; i < 43; i++) {
            _safeMint(to, i);
            _setTokenURI(i, string(abi.encodePacked(baseURI, i.toString())));
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