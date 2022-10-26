// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./PDC.sol";

contract pdcFactory {
    PDC[] public pdcAccountList;
    address public factoryOwner;
    mapping(address => address) public pdcAccountListMapping;
    mapping(address => address) public pdcUserMapping;

    event pdcAccount(address pdcSC, address pdcSCowner);

    // bytes[] public pdcList;

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

    address public pdcFactoryAddress = address(this);
    address internal ops = 0xB3f5503f93d5Ef84b06993a1975B9D21B962892F;
    address internal treasury = 0x527a819db1eb0e34426297b03bae11F2f8B3A19E;

    constructor() {
        factoryOwner = msg.sender;
    }

    modifier onlyChild() {
        require(pdcAccountListMapping[msg.sender] != address(0));
        _;
    }

    function createPDCAccount() public {
        require(
            pdcUserMapping[msg.sender] == address(0),
            "PDC Account already exists for the user!"
        );
        PDC pdcAccountInstance = new PDC(
            msg.sender,
            address(this),
            payable(ops),
            treasury
        );
        pdcAccountList.push(pdcAccountInstance);
        // pdcAccountListMapping[address(pdcAccountInstance)] = true;
        pdcAccountListMapping[address(pdcAccountInstance)] = msg.sender;
        pdcUserMapping[msg.sender] = address(pdcAccountInstance);
        emit pdcAccount(msg.sender, address(pdcAccountInstance));
    }

    function updatepdcCreated(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed
    ) external onlyChild {
        emit pdcCreated(owner, pdcSC, token, receiver, amount, date, executed);
    }

    function updatepdcExecuted(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed
    ) public onlyChild {
        emit pdcExecuted(owner, pdcSC, token, receiver, amount, date, executed);
    }
}
