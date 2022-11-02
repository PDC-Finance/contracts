import time
import brownie
from brownie import (
    pdcFactory,
    PDC,
    interface,
    accounts
)

from helpers.time import days

import pytest

@pytest.fixture
def deployer():
    return accounts[0]

@pytest.fixture
def user():
    return accounts[9]

@pytest.fixture
def dai(deployer):
    """
        TODO: Customize this so you have the token you need for the strat
    """
    TOKEN_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
    WHALE_ADDRESS = "0x7842186cdd11270c4af8c0a99a5e0589c7f249ce"
    token = interface.IERC20Detailed(TOKEN_ADDRESS)
    WHALE = accounts.at(WHALE_ADDRESS, force=True) ## Address with tons of token

    token.transfer(deployer, token.balanceOf(WHALE), {"from": WHALE})
    return token

@pytest.fixture
def deployed(deployer):
    pdcFactoryDeployed = pdcFactory.deploy("0xB3f5503f93d5Ef84b06993a1975B9D21B962892F", "0x2807B4aE232b624023f87d0e237A3B1bf200Fd99",{'from': deployer})
    return pdcFactoryDeployed

## Forces reset before each test
@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass
