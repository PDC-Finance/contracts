import brownie
from brownie import *
from helpers.time import days
from helpers.constants import AddressZero

def test_createPDCAccount(deployed, user):
    with brownie.reverts():
        deployed.pdcAccountList(0)
    createAccount = deployed.createPDCAccount({'from': user})
    fromList = deployed.pdcAccountList(0)
    print(f'From List: {fromList}')
    print(f'User add : {user}')
    # mapping = deployed.pdcAccountListMapping(createAccount.address)
    # print(f'From Mapping : {createAccount}')
    # createPDCAccount reverts when the user tried to create second account
    with brownie.reverts('PDC Account already exists for the user!'):
        createAccount2 = deployed.createPDCAccount({'from': user})
    # createAccount3 = deployed.createPDCAccount({'from': '0x0000000000000000000000000000000000000000'})
    # print(f'create3 : {createAccount3}')
    return fromList

# def test_access_PDCAccount(deployed, user):
