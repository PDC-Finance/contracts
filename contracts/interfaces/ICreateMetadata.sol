// SPDX-License-Identifier: UNLICENSED
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v0.6.6. SEE SOURCE BELOW. !!
pragma solidity >=0.7.0 <0.9.0;

interface ICreateMetadata {
    function buildImage(
        address _token,
        address _receiver,
        uint256 _amount,
        uint256 _date,
        uint256 tokenId
    ) external pure returns (string memory);

    function buildMetadata(
        address _token,
        address _receiver,
        uint256 _amount,
        uint256 _date,
        uint256 tokenId
    ) external pure returns (string memory);
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"inputs":[{"internalType":"address","name":"_token","type":"address"},{"internalType":"address","name":"_receiver","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"},{"internalType":"uint256","name":"_date","type":"uint256"},{"internalType":"bool","name":"executed","type":"bool"}],"name":"buildImage","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"_token","type":"address"},{"internalType":"address","name":"_receiver","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"},{"internalType":"uint256","name":"_date","type":"uint256"},{"internalType":"bool","name":"executed","type":"bool"}],"name":"buildMetadata","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"}]
*/
