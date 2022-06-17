//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract BillardCueNFT is IERC721Enumerable, ERC721URIStorage, Ownable {
    using Strings for uint256;
    string public baseURI =
        "https://raw.githubusercontent.com/blockdev-vn/nft-demo/master/cards/";

    address payable public _owner;
    mapping(uint256 => bool) public sold;
    mapping(uint256 => uint256) public price;
    event Purchase(address owner, uint256 price, uint256 id, string uri);

    constructor() ERC721("BillardCueNFT", "BillardCue NFT") {}

    function _burn(uint256 tokenId) internal override(ERC721URIStorage) {
        super._burn(tokenId);
    }

    //
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory buri = baseURI;
        return
            bytes(buri).length > 0
                ? string(abi.encodePacked(buri, tokenId.toString(), ".json"))
                : "";
    }

    function mint(string memory _tokenURI, uint256 _price)
        public
        onlyOwner
        returns (bool)
    {
        // uint256 _tokenId = totalSupply() + 1;
        uint256 _tokenId = 1;

        price[_tokenId] = _price;
        _mint(address(this), _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        return true;
    }

    function buy(uint256 _id) external payable {
        _validate(_id);
        _trade(_id);
        emit Purchase(msg.sender, price[_id], _id, tokenURI(_id));
    }

    function _validate(uint256 _id) internal {
        require(_exists(_id), "Error, wrong Token id");
        require(!sold[_id], "Error, Token is sold");
        require(msg.value >= price[_id], "Error, Token costs more");
    }

    function _trade(uint256 _id) internal {
        _transfer(address(this), msg.sender, _id);
        _owner.transfer(msg.value);
        sold[_id] = true;
    }

    function totalSupply() external view override returns (uint256) {}

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        override
        returns (uint256)
    {}

    function tokenByIndex(uint256 index)
        external
        view
        override
        returns (uint256)
    {}
}
