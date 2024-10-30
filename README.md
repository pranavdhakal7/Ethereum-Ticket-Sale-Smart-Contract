
#  Ticket Sale Smart Contract

This smart contract facilitates a secure ticket sale system on the Ethereum blockchain, allowing users to purchase, swap, and resell tickets while handling service fees automatically.

## Overview

The contract offers a robust ticket management solution with the following features:
- Direct ticket sales
- Verification of ticket ownership
- Peer-to-peer ticket exchanges
- Resale of tickets on a secondary market with automatic fee distribution
- Enforcement of a one-ticket-per-address rule

## Smart Contract Specifications

**Network:** Sepolia Testnet  
**Contract Address:** `0x4d594a3A020580Fb74ec2e07eB576a13b5C9eAce`  
**Solidity Version:** 0.8.28

### Main Functions

| Function         | Description                                 | Parameters           |
|------------------|---------------------------------------------|----------------------|
| `buyTicket`      | Purchase a ticket from the primary sale     | `uint ticketId`     |
| `getTicketOf`    | Check who owns a specific ticket            | `address person`     |
| `offerSwap`      | Propose a ticket swap                       | `uint ticketId`     |
| `acceptSwap`     | Finalize a ticket swap                      | `uint ticketId`     |
| `resaleTicket`    | List a ticket for resale                    | `uint price`        |
| `acceptResale`   | Buy a ticket listed for resale              | `uint index`        |
| `checkResale`    | Display available tickets for resale        | -                    |

## Test Results

```shell
  TicketSale Contract
Deploying contract with account: 0xdFf48411e404772cd137AAdC0Fd43139b3e42Db3
Account balance: 1000000000000000000000
Contract deployed to: 0x48Cd9110d9BbaBA4217B876120aFAc5F9437b3fd
    ✔ Contract deployment successful
Deploying contract with account: 0xdFf48411e404772cd137AAdC0Fd43139b3e42Db3
Account balance: 999998199776000000000
Contract deployed to: 0x928071f8fF7F868aC99581d8CDc904EeC0cDCEfc
Buyer initial balance: 1000000000000000000000
    ✔ Allows a user to purchase a ticket (54ms)
Deploying contract with account: 0xdFf48411e404772cd137AAdC0Fd43139b3e42Db3
Account balance: 999996399552000000000
Contract deployed to: 0x0482bD807158626549fe0f1F3dBB7D7843f2AC3F
    ✔ Prevents double purchasing of the same ticket (63ms)
Deploying contract with account: 0xdFf48411e404772cd137AAdC0Fd43139b3e42Db3
Account balance: 999994599328000000000
Contract deployed to: 0xdFf48411e404772cd137AAdC0Fd43139b3e42Db3
    ✔ Supports ticket swapping between users (95ms)
Deploying contract with account: 0xdFf48411e404772cd137AAdC0Fd43139b3e42Db3
Account balance: 999992799104000000000
Contract deployed to: 0xdFf48411e404772cd137AAdC0Fd43139b3e42Db3
    ✔ Enables ticket resale functionality (76ms)

  5 tests passed (467ms)
```

## Deployment Information

```shell
Contract compiled successfully!
MNEMONIC available: true
INFURA_URL available: true
Attempting to deploy from account 0xFa12724063D16a22a13621272409085731D4acA4
Contract successfully deployed at: 0xdFf48411e404772cd137AAdC0Fd43139b3e42Db3

```

## Setup Instructions

1. Navigate to the project directory:
```bash
cd Ticket-Sale-Contract
```

2. Install required dependencies:
```bash
npm install
```

3. Set up your environment:
Create a `.env` file with the following content:
```
MNEMONIC=your_mnemonic_phrase
INFURA_URL=your_infura_url
```

4. Generate ABI and Bytecode:
```bash
npm run generate
```

5. Execute tests:
```bash
npm test
```

6. Deploy the contract:
```bash
npm run deploy
```

## Security Measures

- Verification of ownership for all actions
- Prevention of duplicate ticket purchases
- Secure mechanisms for ticket swapping
- Automated collection of service fees
- Access control for critical functions

## Technical Implementation Details

- Developed using Solidity 0.8.28
- Tested with Mocha
- Deployed with Web3.js and Truffle HDWallet Provider
- Gas-optimized for efficient execution

## Development Tools Utilized

- Solidity
- Web3.js
- Ganache CLI
- Mocha
- Truffle HDWallet Provider

## Author

Pranav Dhakal

## License Information

This project is licensed under the MIT License - see the LICENSE file for further details.

---

**Note:** This smart contract is deployed on the Sepolia testnet. For use in production, further security audits and optimizations are advisable.

---

Feel free to adjust any sections further if needed!