// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin-contracts/security/ReentrancyGuard.sol";
import "./IResolver.sol";
import "./IpdcFactory.sol";
import {OpsReady} from "./OpsReady.sol";
import {IOps} from "./IOps.sol";
import {ITaskTreasury} from "./ITaskTreasury.sol";

contract PDC is IResolver, OpsReady, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address public owner;
    address public pdcSC;
    // string public name;
    // address public pdcFactoryAddress;
    mapping(address => bytes32) public taskIdByUser;
    mapping(bytes32 => address) public addressdByTaskId;

    // State variable
    bytes[] public pdcList;

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
    // address public PDCFACTORY = 0x417Bf7C9dc415FEEb693B6FE313d1186C692600F;

    IpdcFactory public pdcFactory;

    receive() external payable {}

    fallback() external payable {}

    modifier isOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    // modifier onlyFactory() {
    //     require(msg.sender == pdcFactoryAddress, "Only Factory");
    //     _;
    // }

    constructor(
        address _owner,
        address _pdcFactoryAddress,
        address payable _ops,
        address _treasury
    ) OpsReady(_ops, payable(_treasury)) {
        owner = _owner;
        pdcFactory = IpdcFactory(_pdcFactoryAddress);
        pdcSC = address(this);
    }

    function topUp() external payable {}

    function createPDC(
        address _token,
        address _receiver,
        uint256 _amount,
        uint256 _date
    ) external isOwner nonReentrant {
        bool executed = false;
        bytes memory pdc = abi.encode(
            _token,
            _receiver,
            _amount,
            _date,
            executed
        );
        pdcList.push(pdc);
        pdcFactory.updatepdcCreated(
            owner,
            pdcSC,
            _token,
            _receiver,
            _amount,
            _date,
            executed
        );
        createTaskNoPrepayment();
        emit pdcCreated(
            owner,
            pdcSC,
            _token,
            _receiver,
            _amount,
            _date,
            executed
        );
    }

    function getIssuedCheque(uint256 id)
        public
        view
        returns (
            address token,
            address receiver,
            uint256 amount,
            uint256 date,
            bool executed
        )
    {
        require(id < pdcList.length, "ID not valid");
        (token, receiver, amount, date, executed) = abi.decode(
            pdcList[id],
            (address, address, uint256, uint256, bool)
        );
        return (token, receiver, amount, date, executed);
    }

    function createTaskNoPrepayment() public isOwner nonReentrant {
        if (taskIdByUser[msg.sender] == bytes32(0)) {
            // bytes32 taskId;
            taskIdByUser[msg.sender] = IOps(ops).createTaskNoPrepayment(
                address(this),
                this.executePDC.selector,
                address(this),
                abi.encodeWithSelector(this.checker.selector),
                ETH
            );
            // taskIdByUser[msg.sender] = taskId;
        }
    }

    function cancelTask(bytes32 taskId) external isOwner nonReentrant {
        IOps(ops).cancelTask(taskId);
        taskIdByUser[msg.sender] = bytes32(0);
    }

    // solhint-disable not-rely-on-time
    function executePDC(uint256 _id) public payable onlyOps returns (bool) {
        (
            address token,
            address receiver,
            uint256 amount,
            uint256 date,
            bool executed
        ) = abi.decode(
                pdcList[_id],
                (address, address, uint256, uint256, bool)
            );
        require(
            block.timestamp >= date && !executed,
            "Not yet time for payment"
        );
        executed = true;
        pdcList[_id] = abi.encode(token, receiver, amount, date, executed);
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > amount) {
            IERC20(token).safeApprove(address(this), amount);
            IERC20(token).safeTransferFrom(address(this), receiver, amount);
            pdcFactory.updatepdcExecuted(
                owner,
                pdcSC,
                token,
                receiver,
                amount,
                date,
                executed
            );
            emit pdcExecuted(
                owner,
                pdcSC,
                token,
                receiver,
                amount,
                date,
                executed
            );
            uint256 fee;
            address feeToken;
            (fee, feeToken) = IOps(ops).getFeeDetails();
            _transfer(fee, feeToken);
        } else {
            uint256 fee;
            address feeToken;
            (fee, feeToken) = IOps(ops).getFeeDetails();
            _transfer(fee, feeToken);
            return false;
        } // check this scenario
        emit pdcExecuted(owner, pdcSC, token, receiver, amount, date, executed);
        emit pdcReturned("Not sufficient balance for payment");
    }

    function checker()
        external
        view
        override
        returns (bool canExec, bytes memory execPayload)
    {
        uint256 pdcLength = getNumberOfIssuedCheque();

        for (uint256 i = 0; i < pdcLength; i++) {
            (
                address token,
                address receiver,
                uint256 amount,
                uint256 date,
                bool executed
            ) = getIssuedCheque(i);
            // bytes memory pdcDetails = abi.encode(token, receiver, amount, date, executed);
            uint256 _id = i;
            // solhint-disable not-rely-on-time
            canExec = block.timestamp >= date && !executed;
            if (canExec) {
                execPayload = abi.encodeWithSelector(
                    this.executePDC.selector,
                    _id
                );
                return (canExec, execPayload);
            }
        }
    }

    function getNumberOfIssuedCheque() public view returns (uint256) {
        return pdcList.length;
    }

    function getBalance(address _token, address _holder)
        public
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(_holder);
    }

    function withdraw(address _tokenAddress) public isOwner {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner).transfer(balance);
        }
        uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));
        if (tokenBalance > 0) {
            // do not use safe transfer here to prevents revert by any shitty token
            require(
                IERC20(_tokenAddress).transfer(owner, tokenBalance),
                "transfer not success"
            );
        }
    }
}
