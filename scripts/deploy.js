async function main() {
  const MarketPlace = await hre.ethers.getContractFactory("MarketPlace");
  const marketPlace = await MarketPlace.deploy();

  await marketPlace.deployed();

  console.log("MarketPlace deployed to:", marketPlace.address);
}

const run = async() => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

run();
