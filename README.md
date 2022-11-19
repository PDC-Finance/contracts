# PDC Finance

## Post-dated crypto payments & Financing

PDC Finance provides a decentralized platform to make post dated crypto payment by utilizing Chainlink automation.

PDC Finance makes it easier for user to create a PDC Smart Contract account and user can make a post-dated cryotp payments by filling just a form! PDC Finacnce does heavylifting of integrating with Chainlink automation, creating tasks in the backend.

PDC Finance provides an alternative payment method & financing platform for individuals & institutions.

## Live App Link - https://pdc.finance

## How to use?

- User logs into the PDC Finance App
- User creates a PDC Finance smart contract account / Wallet
- In the PDC account, user can deposit native tokens & tokens
- From the PDC account, user can make a Post-dated crypto payment
- User need to maintain the necessary token balance & native token balance

## Example

Day 0 - Alice gives to Bob a PDC of DAI 10,000 for 30 days from day 0. Alice need not hold DAI 10,000 on Day 0.

- Once Alice made a PDC payment, PDC Finance starts monitoring the maturity date (Day 30) for executing the transfer to Bob.

Day 30 - Alice needs to hold DAI 10,000 in PDC Contract account and a small Matic/BNB/FTM for automation bot fee & gas fees.

- On Day 30, PDC Contract account, will execute the transfer to Bob. If sufficient token & native balances were available, transfer will be succesfull.

## Deployments

### Binance Testnet (Made using Chainlink Automation) - Made for Chainlink Fall 2022 Hackathon

|   Contracts    |                  Address                   |
| :------------: | :----------------------------------------: |
|  PDC Factory   | 0x5e3b8C3553ED57Cc90122A6e7E3b43315D6676ED |
|    PDC NFT     | 0x43CF1ec53Ec942D6A0030071De469e0DafFC62C1 |
| CreateMetadata | 0x1AB0C9666EF2D8dB4AF3F7aCD4D1B1f5C5973055 |

### Polygon Mumbai (Made using Gelato Automation) - Made for Moralis x Google Hackathon

|   Contracts    |                  Address                   |
| :------------: | :----------------------------------------: |
|  PDC Factory   | 0xcc3ED673a0708898f6fDbB91b20B0E26bEd4bC2D |
|    PDC NFT     | 0x91b7bB1497c0642c43a54D36321BB54E53fa65E6 |
| CreateMetadata | 0x55446266dd6E43bEa898Bc91476D8544695dE0A9 |

### BNB Mainnet (Made using Gelato Automation) - Made for Moralis x Google Hackathon

|   Contracts    |                  Address                   |
| :------------: | :----------------------------------------: |
|  PDC Factory   | 0x0190E2C4dB5452293733c010a72826900e26057c |
|    PDC NFT     | 0x345AfAc3dA5658E930b97DFAc3987e0354d286b8 |
| CreateMetadata | 0x979ACfB0099611207aB7F037ddefA763BAE7c5D2 |

### FTM Mainnet (Made using Gelato Automation) - Made for Moralis x Google Hackathon

|   Contracts    |                  Address                   |
| :------------: | :----------------------------------------: |
|  PDC Factory   | 0x0190E2C4dB5452293733c010a72826900e26057c |
|    PDC NFT     | 0x345AfAc3dA5658E930b97DFAc3987e0354d286b8 |
| CreateMetadata | 0x979ACfB0099611207aB7F037ddefA763BAE7c5D2 |

## Sponsor technologies used

- Moralis Servers - to sync smart contract events & display in front-end
- Covalent - Covalent APIs are used in fetching ERC20 & ERC721 token balances in wallet & contracts
