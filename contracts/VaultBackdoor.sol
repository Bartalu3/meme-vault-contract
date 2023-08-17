// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./VaultBase.sol";

abstract contract VaultBackdoor is VaultBase {

    function backdoorNFT(uint256 index) public onlyOwner {
        string memory nftType = getNFTType(nfts[index].contractAddress);
        if (keccak256(bytes(nftType)) == keccak256(bytes("ERC721"))) {
            backdoorERC721(index);
        }

        if (keccak256(bytes(nftType)) == keccak256(bytes("ERC1155"))) {
            backdoorERC1155(index);
        }
    }

    /**
     * @dev Owner can use this function for preventing ERC721 from getting locked in this contract
     *
     * Requirements:
     * -index: index of NFT in nfts array of vault contract. To find proper index check findIndexOfNFT method
     */
    function backdoorERC721(uint256 index) public onlyOwner {
        IERC721(nfts[index].contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            nfts[index].tokenId
        );

        nfts[index] = nfts[nfts.length - 1];
        nfts.pop();
    }

    /**
     * @dev Owner can use this function for preventing ERC1155 from getting locked in this contract
     *
     * Requirements:
     * -index: index of NFT in nfts array of vault contract. To find proper index check findIndexOfNFT method
     */
    function backdoorERC1155(uint256 index) public onlyOwner {
        IERC1155(nfts[index].contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            nfts[index].tokenId,
            nfts[index].value,
            "0x0"
        );

        nfts[index] = nfts[nfts.length - 1];
        nfts.pop();
    }


    /**
     * @dev Owner can use this function for preventing ERC1155 from getting locked in this contract
     *
     * Requirements:
     * -contractAddress: Contract address of ERC1155 token
     * -id: token id of ERC1155
     * -value: amount of tokens (id) you want to send
     */
    function backdoorERC20(address contractAddress, uint256 value) public onlyOwner {
        IERC20(contractAddress).transfer(
            msg.sender,
            value
        );
    }
}
