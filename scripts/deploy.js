const hre = require("hardhat");

async function main() {
  const Voting = await hre.ethers.getContractFactory("Voting");

  // les candidats initiaux
  const initialCandidates = ["Alice", "Bob", "Charlie"];

  const vote = await Voting.deploy(initialCandidates);

  // nouvelle syntaxe dans Ethers v6 :
  await vote.waitForDeployment();

  console.log("Contract deployed at:", await vote.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
