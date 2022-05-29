const main = async () => {
        const [owner, superCoder] = await hre.ethers.getSigners();
      const contractFactory = await hre.ethers.getContractFactory('MarketPlace');
      const contract = await contractFactory.deploy();
      await contract.deployed();
    
    //   console.log({contract});



        const result = await contract.addNFT('cat', 100, 'https://ipfs.infura.io/ipfs/Qmf6isejKuRVLxWyY1NpMudrGp97xo5NCtamynbKrssjBi', true);

     console.log({result});
   
    }
    
    const runMain = async () => {
      try {
        await main();
        process.exit(0);
      } catch (error) {
        console.log(error);
        process.exit(1);
      }
    };
    
    runMain();
      