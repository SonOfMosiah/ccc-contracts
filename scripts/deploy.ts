import hre, { ethers } from 'hardhat';

async function main() {
  let wethAddress;
  if (hre.network.name === 'mumbai') {
    wethAddress = '0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa';
  } else {
    wethAddress = '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619';
  }
  const CCC = await ethers.getContractFactory('CuteConeClub');
  const cuteConeClub = await CCC.deploy(wethAddress);
  await cuteConeClub.deployed();

  console.log(`deployed to ${cuteConeClub.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
