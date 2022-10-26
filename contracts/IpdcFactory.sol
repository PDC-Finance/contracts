// SPDX-License-Identifier: UNLICENSED
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v0.6.6. SEE SOURCE BELOW. !!
pragma solidity 0.8.1;

interface IpdcFactory {
    event pdcAccount(address pdcSCowner, address pdcSC);
    event pdcCreated(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed
    );
    event pdcExecuted(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed
    );
    event pdcReturned(string);

    function createPDCAccount() external;

    function factoryOwner() external view returns (address);

    function pdcAccountList(uint256) external view returns (address);

    function pdcAccountListMapping(address) external view returns (address);

    function updatepdcCreated(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed
    ) external;

    function updatepdcExecuted(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed
    ) external;
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"pdcSCowner","type":"address"},{"indexed":false,"internalType":"address","name":"pdcSC","type":"address"}],"name":"pdcAccount","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"owner","type":"address"},{"indexed":false,"internalType":"address","name":"pdcSC","type":"address"},{"indexed":false,"internalType":"address","name":"token","type":"address"},{"indexed":false,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"date","type":"uint256"},{"indexed":false,"internalType":"bool","name":"executed","type":"bool"}],"name":"pdcCreated","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"owner","type":"address"},{"indexed":false,"internalType":"address","name":"pdcSC","type":"address"},{"indexed":false,"internalType":"address","name":"token","type":"address"},{"indexed":false,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"date","type":"uint256"},{"indexed":false,"internalType":"bool","name":"executed","type":"bool"}],"name":"pdcExecuted","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"","type":"string"}],"name":"pdcReturned","type":"event"},{"inputs":[],"name":"createPDCAccount","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"factoryOwner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"pdcAccountList","outputs":[{"internalType":"contract PDC","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"pdcAccountListMapping","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"pdcSC","type":"address"},{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"receiver","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"date","type":"uint256"},{"internalType":"bool","name":"executed","type":"bool"}],"name":"updatepdcCreated","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"pdcSC","type":"address"},{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"receiver","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"date","type":"uint256"},{"internalType":"bool","name":"executed","type":"bool"}],"name":"updatepdcExecuted","outputs":[],"stateMutability":"nonpayable","type":"function"}]
*/