// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin-contracts/security/ReentrancyGuard.sol";
import "./interfaces/IResolver.sol";
import "./interfaces/IpdcFactory.sol";
import {OpsReady} from "./interfaces/OpsReady.sol";
import {IOps} from "./interfaces/IOps.sol";
import {ITaskTreasury} from "./interfaces/ITaskTreasury.sol";
import "./interfaces/Inft.sol";
import "./interfaces/ICreateMetadata.sol";

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

    event PdcCreated(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed,
        uint256 tokenId
    );
    event PdcExecuted(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed,
        uint256 tokenId
    );
    event PdcReturned(string);
    // address public PDCFACTORY = 0x417Bf7C9dc415FEEb693B6FE313d1186C692600F;

    IpdcFactory public pdcFactory;
    Inft public IpdcNFT;
    ICreateMetadata public createMetadata;

    receive() external payable {}

    fallback() external payable {}

    modifier isOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    // string public uri = "test";

    // modifier onlyFactory() {
    //     require(msg.sender == pdcFactoryAddress, "Only Factory");
    //     _;
    // } 0x0642E3426981cA8FCFeF74b493D5f7f90cA35035

    constructor(
        address _owner,
        address _pdcFactoryAddress,
        address payable _ops,
        address _treasury,
        address _createMetadata
    ) OpsReady(_ops, payable(_treasury)) {
        owner = _owner;
        pdcFactory = IpdcFactory(_pdcFactoryAddress);
        pdcSC = address(this);
        createMetadata = ICreateMetadata(_createMetadata);
    }

    function topUp() external payable {}

    function createPDC(
        address _token,
        address _receiver,
        uint256 _amount,
        uint256 _date
    )
        external
        // string memory _uri
        isOwner
    {
        bool executed = false;
        string memory _uri = createMetadata.buildMetadata(
            _token,
            _receiver,
            _amount,
            _date,
            executed
        );
        uint256 tokenId = pdcFactory.mintPdcNFT(_receiver, _uri);
        // address pdcNftOwner = pdcFactory.getNftOwner(tokenId);
        // _receiver = pdcNftOwner;
        bytes memory pdc = abi.encode(
            _token,
            _receiver,
            _amount,
            _date,
            executed,
            tokenId
        );
        pdcList.push(pdc);
        pdcFactory.updatepdcCreated(
            owner,
            pdcSC,
            _token,
            _receiver,
            _amount,
            _date,
            executed,
            tokenId
        );
        createTaskNoPrepayment();
        emit PdcCreated(
            owner,
            pdcSC,
            _token,
            _receiver,
            _amount,
            _date,
            executed,
            tokenId
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

    function createTaskNoPrepayment() public isOwner {
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
        taskIdByUser[msg.sender] = bytes32(0);
        IOps(ops).cancelTask(taskId);
    }

    // solhint-disable not-rely-on-time
    function executePDC(uint256 _id)
        external
        payable
        onlyOps
        nonReentrant
        returns (bool)
    {
        (
            address token,
            address receiver,
            uint256 amount,
            uint256 date,
            bool executed,
            uint256 tokenId
        ) = abi.decode(
                pdcList[_id],
                (address, address, uint256, uint256, bool, uint256)
            );
        require(
            block.timestamp >= date && !executed,
            "Not yet time for payment"
        );
        executed = true;
        pdcList[_id] = abi.encode(
            token,
            receiver,
            amount,
            date,
            executed,
            tokenId
        );
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > amount) {
            IERC20(token).safeApprove(address(this), amount);
            address pdcNftOwner = pdcFactory.getNftOwner(tokenId);
            receiver = pdcNftOwner;
            IERC20(token).safeTransferFrom(address(this), receiver, amount);
            pdcFactory.updatepdcExecuted(
                owner,
                pdcSC,
                token,
                receiver,
                amount,
                date,
                executed,
                tokenId
            );
            emit PdcExecuted(
                owner,
                pdcSC,
                token,
                receiver,
                amount,
                date,
                executed,
                tokenId
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
        emit PdcExecuted(
            owner,
            pdcSC,
            token,
            receiver,
            amount,
            date,
            executed,
            tokenId
        );
        emit PdcReturned("Not sufficient balance for payment");
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
        external
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(_holder);
    }

    function withdraw(address _tokenAddress) external isOwner {
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
