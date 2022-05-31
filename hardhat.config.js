require('dotenv').config();
require("@nomiclabs/hardhat-waffle");

const { API_KEY, SECRET_KEY } = process.env;

module.exports = {
   solidity: "0.8.0",
   networks: {
      hardhat: {
         chainId: 1337
      },
      goerli: {
         url: `https://eth-goerli.alchemyapi.io/v2/${API_KEY}`,
         accounts: [SECRET_KEY]
      }
   },
}
