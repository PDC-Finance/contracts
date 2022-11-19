// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/IpdcFactory.sol";
import "../interfaces/Inft.sol";
import "../interfaces/IcreateMetadata.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AutomationRegistryInterface, State, Config} from "@chainlink/contracts/src/v0.8/interfaces/AutomationRegistryInterface1_2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "../interfaces/IKeeperRegistrarInterface.sol";
import "hardhat/console.sol";

contract PDC is AutomationCompatibleInterface, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address public owner;
    address public pdcSC;
    // string public name;
    // address public pdcFactoryAddress;
    mapping(address => uint256) public taskIdByUser;
    mapping(uint256 => address) public addressdByTaskId;
    //Goreli Link token, registrar & registry addresses
    LinkTokenInterface public immutable i_link =
        LinkTokenInterface(0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06);
    address public immutable registrar =
        0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d;
    AutomationRegistryInterface public immutable i_registry =
        AutomationRegistryInterface(0x02777053d6764996e594c3E88AF1D58D5363a2e6);
    bytes4 registerSig = KeeperRegistrarInterface.register.selector;
    bytes checkData;
    bytes encryptedEmail;
    uint256 gasLimit = 999999;
    uint256 initialLink = 5 ether;

    // State variable
    bytes[] public pdcList;

    event PdcCreated(
        address owner,
        address pdcSC,
        string token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed,
        uint256 tokenId
    );
    event PdcExecuted(
        address owner,
        address pdcSC,
        string token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed,
        uint256 tokenId
    );
    event PdcReturned(string);

    IpdcFactory public pdcFactory;
    Inft public pdcNFT;
    IcreateMetadata public createMetadata;

    // error OnlyKeeperRegistry();

    receive() external payable {}

    fallback() external payable {}

    modifier isOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    modifier onlyKeeperRegistry() {
        require(msg.sender == address(i_registry), "Only Registry");
        // if (msg.sender != address(i_registry)) {
        // revert OnlyKeeperRegistry();
        // }
        _;
    }

    // modifier onlyFactory() {
    //     require(msg.sender == pdcFactoryAddress, "Only Factory");
    //     _;
    // }

    constructor(
        address _owner,
        address _pdcFactoryAddress,
        address _pdcNFT,
        address _createMetadata
    ) // address _link,
    // address _registrar,
    // address _registry
    {
        owner = _owner;
        pdcFactory = IpdcFactory(_pdcFactoryAddress);
        pdcSC = address(this);
        pdcNFT = Inft(_pdcNFT);
        createMetadata = IcreateMetadata(_createMetadata);
        // i_link = LinkTokenInterface(_link);
        // registrar = _registrar;
        // i_registry = AutomationRegistryInterface(_registry);
    }

    function _registerAndPredictID() external {
        (State memory state, Config memory _c, address[] memory _k) = i_registry
            .getState();
        uint256 oldNonce = state.nonce;
        bytes memory payload = abi.encode(
            "PDC",
            encryptedEmail,
            address(this),
            gasLimit,
            owner,
            checkData,
            5000000000000000000,
            0,
            address(this)
        );

        i_link.transferAndCall(
            registrar,
            5000000000000000000,
            bytes.concat(registerSig, payload)
        );
        (state, _c, _k) = i_registry.getState();
        uint256 newNonce = state.nonce;
        if (newNonce == oldNonce + 1) {
            taskIdByUser[msg.sender] = uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        address(i_registry),
                        uint32(oldNonce)
                    )
                )
            );
            // taskIdByUser[msg.sender] = upkeepID;
            // DEV - Use the upkeepID however you see fit
        } else {
            revert("auto-approve disabled");
        }
    }

    function checkUpkeep(bytes calldata checkData)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
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
            upkeepNeeded = block.timestamp >= date && !executed;
            if (upkeepNeeded) {
                performData = abi.encode(_id);
                return (upkeepNeeded, performData);
            }
        }
    }

    function executePDC(uint256 _id) external payable nonReentrant {
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
        pdcList[_id] = abi.encode(token, receiver, amount, date, executed);
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > amount) {
            IERC20(token).safeApprove(address(this), amount);
            address pdcNftOwner = pdcNFT.ownerOf(tokenId);
            receiver = pdcNftOwner;
            IERC20(token).safeTransferFrom(address(this), receiver, amount);
            pdcFactory.updatepdcExecuted(
                owner,
                pdcSC,
                getTokenSymbol(token),
                receiver,
                amount,
                date,
                executed,
                tokenId
            );
            emit PdcExecuted(
                owner,
                pdcSC,
                getTokenSymbol(token),
                receiver,
                amount,
                date,
                executed,
                tokenId
            );
        }
        emit PdcExecuted(
            owner,
            pdcSC,
            getTokenSymbol(token),
            receiver,
            amount,
            date,
            executed,
            tokenId
        );
        emit PdcReturned("Not sufficient balance for payment");
    }

    function performUpkeep(bytes calldata performData) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        uint256 _id = abi.decode(performData, (uint256));
        console.log("id", _id);
        // executePDC(id);
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
        pdcList[_id] = abi.encode(token, receiver, amount, date, executed);
        uint256 balance = IERC20(token).balanceOf(address(this));
        console.log("Balance", balance);
        if (balance > amount) {
            IERC20(token).safeApprove(address(this), amount);
            address pdcNftOwner = pdcNFT.ownerOf(tokenId);
            receiver = pdcNftOwner;
            IERC20(token).safeTransferFrom(address(this), receiver, amount);
            pdcFactory.updatepdcExecuted(
                owner,
                pdcSC,
                getTokenSymbol(token),
                receiver,
                amount,
                date,
                executed,
                tokenId
            );
            emit PdcExecuted(
                owner,
                pdcSC,
                getTokenSymbol(token),
                receiver,
                amount,
                date,
                executed,
                tokenId
            );
        } else {
            emit PdcReturned("Not sufficient balance for payment");
            emit PdcExecuted(
                owner,
                pdcSC,
                getTokenSymbol(token),
                receiver,
                amount,
                date,
                executed,
                tokenId
            );
        } // check this scenario
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
        // uint256 tokenId;
        uint256 _tokenId = pdcNFT.getCurrentToken();
        string memory _uri = createMetadata.buildMetadata(
            _token,
            _receiver,
            _amount,
            _date,
            _tokenId
        );
        // string memory _uri;
        uint256 tokenId = pdcNFT.safeMint(_receiver, _uri);
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
            getTokenSymbol(_token),
            _receiver,
            _amount,
            _date,
            executed,
            tokenId
        );
        if (taskIdByUser[address(this)] == 0) {
            this._registerAndPredictID();
        }
        emit PdcCreated(
            owner,
            pdcSC,
            getTokenSymbol(_token),
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

    function updateGasLimit(uint256 _newGasLimit) public isOwner {
        gasLimit = _newGasLimit;
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

    function getTokenSymbol(address _token)
        public
        view
        returns (string memory _symbol)
    {
        IERC20Metadata tokencontract = IERC20Metadata(_token);
        _symbol = tokencontract.symbol();
        return _symbol;
    }

    function withdraw(address _tokenAddress) external isOwner {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner).transfer(balance);
        }
        uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));
        if (tokenBalance > 0) {
            require(
                IERC20(_tokenAddress).transfer(owner, tokenBalance),
                "transfer not success"
            );
        }
    }
}
