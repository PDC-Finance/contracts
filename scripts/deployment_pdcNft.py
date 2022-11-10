from brownie import (accounts, network, PostDatedCryptoPayment, config)

def main():
    dev = accounts.add(config["wallets"]["from_key"])

    pdcNft = PostDatedCryptoPayment.deploy(
        {"from": dev}
    )
    print(f'pdcNft deployed address : {pdcNft}')
    return pdcNft