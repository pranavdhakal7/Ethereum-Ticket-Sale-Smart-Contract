const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');

// Set up ganache with several accounts, each funded adequately
const provider = ganache.provider({
  accounts: [
    { balance: '1000000000000000000000' },  // Deployer account
    { balance: '1000000000000000000000' },  // Buyer account 1
    { balance: '1000000000000000000000' },  // Buyer account 2
    { balance: '1000000000000000000000' }   // Additional account
  ],
  gasLimit: 8000000
});

const web3 = new Web3(provider);
const { interface, bytecode } = require('../scripts/compile');

let accounts;
let ticketSaleContract;
const TICKET_COST = web3.utils.toWei('0.1', 'ether');

beforeEach(async () => {
  // Retrieve accounts from the provider
  accounts = await web3.eth.getAccounts();
  
  console.log('Deploying the contract with:', accounts[0]);
  console.log('Initial balance of deployer:', await web3.eth.getBalance(accounts[0]));
  
  try {
    // Deploy the ticket sale contract
    ticketSaleContract = await new web3.eth.Contract(JSON.parse(interface))
      .deploy({
        data: bytecode,
        arguments: [10, TICKET_COST]
      })
      .send({
        from: accounts[0],
        gas: '6000000'
      });
      
    console.log('Contract successfully deployed at:', ticketSaleContract.options.address);
  } catch (error) {
    console.error('Error during contract deployment:', error);
    throw error;
  }
});

describe('TicketSaleContract Tests', () => {
  it('should deploy the contract', () => {
    assert.ok(ticketSaleContract.options.address);
  });

  it('should allow an account to purchase a ticket', async () => {
    try {
      const buyerInitialBalance = await web3.eth.getBalance(accounts[1]);
      console.log('Initial balance of buyer:', buyerInitialBalance);

      await ticketSaleContract.methods.buyTicket(1).send({
        from: accounts[1],
        value: TICKET_COST,
        gas: '3000000'
      });

      const ticketOwner = await ticketSaleContract.methods.ticketOwners(1).call();
      assert.equal(ticketOwner, accounts[1]);
    } catch (error) {
      console.error('Error purchasing ticket:', error);
      throw error;
    }
  });

  it('should prevent the same ticket from being purchased twice', async () => {
    await ticketSaleContract.methods.buyTicket(1).send({
      from: accounts[1],
      value: TICKET_COST,
      gas: '3000000'
    });

    try {
      await ticketSaleContract.methods.buyTicket(1).send({
        from: accounts[2],
        value: TICKET_COST,
        gas: '3000000'
      });
      assert(false, 'Should not allow purchasing the same ticket again');
    } catch (error) {
      assert(error);
    }
  });

  it('should enable ticket swapping between two users', async () => {
    // First user purchases ticket 1
    await ticketSaleContract.methods.buyTicket(1).send({
      from: accounts[1],
      value: TICKET_COST,
      gas: '3000000'
    });

    // Second user purchases ticket 2
    await ticketSaleContract.methods.buyTicket(2).send({
      from: accounts[2],
      value: TICKET_COST,
      gas: '3000000'
    });

    // First user offers to swap ticket 1
    await ticketSaleContract.methods.offerSwap(1).send({
      from: accounts[1],
      gas: '3000000'
    });

    // Second user accepts the swap offer
    await ticketSaleContract.methods.acceptSwap(1).send({
      from: accounts[2],
      gas: '3000000'
    });

    const ownerOfTicket1 = await ticketSaleContract.methods.ticketOwners(1).call();
    const ownerOfTicket2 = await ticketSaleContract.methods.ticketOwners(2).call();

    assert.equal(ownerOfTicket1, accounts[2]);
    assert.equal(ownerOfTicket2, accounts[1]);
  });

  it('should allow ticket resale', async () => {
    // First user buys a ticket
    await ticketSaleContract.methods.buyTicket(1).send({
      from: accounts[1],
      value: TICKET_COST,
      gas: '3000000'
    });

    // User lists the ticket for resale
    const resalePrice = web3.utils.toWei('0.15', 'ether');
    await ticketSaleContract.methods.resaleTicket(resalePrice).send({
      from: accounts[1],
      gas: '3000000'
    });

    // Another user buys the listed ticket
    await ticketSaleContract.methods.acceptResale(0).send({
      from: accounts[2],
      value: resalePrice,
      gas: '3000000'
    });

    const newTicketOwner = await ticketSaleContract.methods.ticketOwners(1).call();
    assert.equal(newTicketOwner, accounts[2]);
  });
});
