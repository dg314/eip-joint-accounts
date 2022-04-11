# EIP Joint Accounts
Ethereum Improvement Proposal for an ERC-20 token with joint accounts

## Motivation
Cryptocurrency has the potential to replace traditional payment methods, but ERC-20 tokens are still lacking a key feature offered by banks: **joint accounts**.

A joint bank account allows two or more people to deposit, withdraw, and transfer money from the same balance. Business partners and married couples alike rely on joint bank accounts to simultaneously access the same pool of money. An individual may even have access to multiple joint bank accounts at once.

Currently, a user must distribute their private key to share access to their ERC-20 balance without transferring it. Additionally, a single address cannot control distinct balances shared with different groups. ERC-xxxx extends the ERC-20 standard to implement a system of joint accounts that solves both of these problems.

## Overview
- ERC-xxxx is backward compatible with ERC-20.
- A user can share access to their address's balance with any number of other addresses.
- A user can revoke another address's access to the user's balance at any time.
- A user can have access to any positive number of balances.
- A user always has access to their own balance.
- A user can set their active balance holder to their own address or any address that they have balance access to.
  - A user's active balance holder is their own address by default.
- The balance and allowance of a user is displayed from the perspective of their active balance holder.
  - This allows users to easily view balances and allowances of joint accounts in ERC-20 compatible platforms like MetaMask.
- A group of users can create another address to serve as their joint account.
