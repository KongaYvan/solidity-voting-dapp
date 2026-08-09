const hre = require("hardhat");

async function main() {
  // Adresse du contrat déployé
  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = Voting.attach(contractAddress);

  console.log("=== Démonstration du système de vote ===\n");

  // Récupération des comptes
  const comptes = await hre.ethers.getSigners();

  console.log("Candidats au départ :");
  let [noms, voix] = await voting.getAllCandidates();
  console.log("Noms :", noms);
  console.log("Votes :", voix.map(v => v.toString()), "\n");

  // On utilise différents comptes pour éviter le revert
  console.log("➡ Vote du compte 2 pour Bob (id 1)");
  await voting.connect(comptes[1]).vote(1);

  console.log("➡ Vote du compte 3 pour Alice (id 0)");
  await voting.connect(comptes[2]).vote(0);

  console.log("➡ Vote du compte 4 pour Charlie (id 2)");
  await voting.connect(comptes[3]).vote(2);

  console.log("\nTentative de double vote par le compte 3...");
  try {
    await voting.connect(comptes[2]).vote(0);
  } catch (err) {
    console.log("❌ Double vote refusé :", err.reason); // err.reason contient 'Adresse a deja vote'
  }

  console.log("\n=== Résultats finaux ===");
  [noms, voix] = await voting.getAllCandidates();
  console.log("Noms :", noms);
  console.log("Votes :", voix.map(v => v.toString()));

  console.log("\n🎉 Démonstration terminée !");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
