// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./PDC.sol";
import "./interfaces/Inft.sol";

contract pdcFactory {
    PDC[] public pdcAccountList;
    address public factoryOwner;
    mapping(address => address) public pdcAccountListMapping;
    mapping(address => address) public pdcUserMapping;
    event PDCAccount(address pdcSCowner, address pdcSC);

    // bytes[] public pdcList;
    event PdcCreated(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed
    );
    event PdcExecuted(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed
    );
    event PdcReturned(string);

    address public pdcFactoryAddress = address(this);
    address internal ops;
    address internal treasury;
    address public createMetadata;
    // address public pdcNFT;

    Inft public IpdcNFT;

    constructor(
        address _ops,
        address _treasury,
        address _pdcNFT,
        address _createMetadata
    ) {
        factoryOwner = msg.sender;
        ops = _ops;
        treasury = _treasury;
        IpdcNFT = Inft(_pdcNFT);
        createMetadata = _createMetadata;
    }

    modifier onlyChild() {
        require(pdcAccountListMapping[msg.sender] != address(0));
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factoryOwner);
        _;
    }

    function createPDCAccount() external {
        require(
            pdcUserMapping[msg.sender] == address(0),
            "PDC Account already exists for the user!"
        );
        PDC pdcAccountInstance = new PDC(
            msg.sender,
            address(this),
            payable(ops),
            treasury,
            createMetadata
        );
        pdcAccountList.push(pdcAccountInstance);
        // pdcAccountListMapping[address(pdcAccountInstance)] = true;
        pdcAccountListMapping[address(pdcAccountInstance)] = msg.sender;
        pdcUserMapping[msg.sender] = address(pdcAccountInstance);
        emit PDCAccount(msg.sender, address(pdcAccountInstance));
    }

    function updatepdcCreated(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed,
        uint256 tokenId
    ) external onlyChild {
        emit PdcCreated(owner, pdcSC, token, receiver, amount, date, executed);
    }

    function updatepdcExecuted(
        address owner,
        address pdcSC,
        address token,
        address receiver,
        uint256 amount,
        uint256 date,
        bool executed,
        uint256 tokenId
    ) external onlyChild {
        emit PdcExecuted(owner, pdcSC, token, receiver, amount, date, executed);
    }

    function mintPdcNFT(address to, string memory _uri)
        external
        onlyChild
        returns (uint256)
    {
        uint256 tokenId = IpdcNFT.safeMint(to, _uri);
        return tokenId;
    }

    function getNftOwner(uint256 _tokenId)
        external
        view
        onlyChild
        returns (address)
    {
        address pdcNftOwner = IpdcNFT.ownerOf(_tokenId);
        return pdcNftOwner;
    }
}
