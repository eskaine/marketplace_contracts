/**
* @type import('hardhat/config').HardhatUserConfig
*/
// require('dotenv').config();
// require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");

// const { API_URL, PRIVATE_KEY } = process.env;
module.exports = {
   solidity: "0.8.1",
   networks: {
      hardhat: {
         chainId: 1337
       },
   },
}
