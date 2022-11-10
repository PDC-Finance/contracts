from brownie import (pdcFactory, accounts, network, config)

def main():
    dev = accounts.add(config["wallets"]["from_key"])
    pdcNft = '0x91b7bB1497c0642c43a54D36321BB54E53fa65E6' 
    createMetadata = '0x55446266dd6E43bEa898Bc91476D8544695dE0A9' 
    gOps = '0xB3f5503f93d5Ef84b06993a1975B9D21B962892F'
    gTreasury = '0x527a819db1eb0e34426297b03bae11F2f8B3A19E'

    pdcNft = pdcFactory.deploy(gOps, gTreasury, pdcNft, createMetadata,
        {"from": dev}
    )
    print(f'pdcFactory deployed address : {pdcNft}')
    return pdcNft