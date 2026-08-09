// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Système de vote simple et sécurisé sur Ethereum
/// @notice Permet l'ajout de candidats, le vote unique par adresse, et le calcul du gagnant
contract Voting {

    // ---------- STRUCTURES ----------
    struct Candidate {
        string name;
        uint256 voteCount;
        bool exists;
    }

    // ---------- VARIABLES ----------
    address public owner;
    mapping(uint256 => Candidate) private candidates;
    uint256 public candidateCount;
    mapping(address => bool) public hasVoted; // Anti double-vote

    // ---------- EVENTS ----------
    event CandidateAdded(uint256 id, string name);
    event Voted(address voter, uint256 candidateId);

    // ---------- MODIFIERS ----------
    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut faire cela");
        _;
    }

    // ---------- CONSTRUCTEUR ----------
    constructor(string[] memory initialCandidates) {
        owner = msg.sender;

        // Ajout des candidats initiaux
        for (uint256 i = 0; i < initialCandidates.length; i++) {
            _addCandidate(initialCandidates[i]);
        }
    }

    // ---------- AJOUT DE CANDIDAT ----------
    function _addCandidate(string memory name) internal {
        candidates[candidateCount] = Candidate({
            name: name,
            voteCount: 0,
            exists: true
        });

        emit CandidateAdded(candidateCount, name);
        candidateCount++;
    }

    // Optionnel : le propriétaire peut ajouter d'autres candidats
    function addCandidate(string memory name) external onlyOwner {
        _addCandidate(name);
    }

    // ---------- FONCTION DE VOTE (Point 1) ----------
    function vote(uint256 candidateId) external {
        require(!hasVoted[msg.sender], "Adresse a deja vote");
        require(candidateId < candidateCount, "Candidat invalide");
        require(candidates[candidateId].exists, "Candidat introuvable");

        // Marquer l’adresse comme ayant voté
        hasVoted[msg.sender] = true;

        // Incrémenter les votes
        candidates[candidateId].voteCount++;

        emit Voted(msg.sender, candidateId);
    }

    // ---------- LECTURE D'UN CANDIDAT ----------
    function getCandidate(uint256 candidateId)
        external
        view
        returns (string memory name, uint256 votes)
    {
        require(candidates[candidateId].exists, "Candidat invalide");
        return (candidates[candidateId].name, candidates[candidateId].voteCount);
    }

    // ---------- RESULTATS (Point 2) ----------
    function getWinner() external view returns (string memory winnerName, uint256 winnerVotes) {
        require(candidateCount > 0, "Aucun candidat");

        uint256 highestVotes = 0;
        uint256 winnerId = 0;

        // Parcourt des candidats pour trouver le gagnant
        for (uint256 i = 0; i < candidateCount; i++) {
            if (candidates[i].voteCount > highestVotes) {
                highestVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }

        return (candidates[winnerId].name, candidates[winnerId].voteCount);
    }

    // ---------- LISTE DES CANDIDATS ----------
    function getAllCandidates() external view returns (string[] memory names, uint256[] memory votes) {
        names = new string[](candidateCount);
        votes = new uint256[](candidateCount);

        for (uint256 i = 0; i < candidateCount; i++) {
            names[i] = candidates[i].name;
            votes[i] = candidates[i].voteCount;
        }

        return (names, votes);
    }
}
