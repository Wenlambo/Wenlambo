Install NodeJS and NPM.

Deploy contract (using remix or any other method).

Transfer 0.2 LINK to it (buy Binance-peg LINk and convert it to ERC677 first using https://pegswap.chain.link/ !)

Create file `.env` and fill it with this data:

```
CONTRACT=0x89728767e8842E1BaE387ECdbAA926f334028B27
#enter your address of the contract "admin" here
ADMIN=
#enter your private key here
ADMIN_PRIVATE_KEY=
API_KEY=ckey_36ab2e8266b94b629b88a3d0222
```

Run `npm install && npm run scrips/index.js`
