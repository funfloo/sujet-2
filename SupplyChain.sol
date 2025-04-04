// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Traceabilite is Ownable {
    // Structure pour un lot de produits
    struct Produit {
        address fabricant;
        uint256 nombreDeLots;
        string nomProduit;
        string identifiantLot;
        uint256 quantite;
        string dernierProprietaire;
        uint256 dateAchat;
    }

    // Mapping des identifiants de lots aux produits
    mapping(string => Produit) public produits;

    // Mapping pour la whitelist des participants autorisés
    mapping(address => bool) public whitelist;

    // Événements
    event ProduitEnregistre(string identifiantLot, string nomProduit, address fabricant);
    event ProprieteTransferee(string identifiantLot, string nouveauProprietaire, uint256 dateAchat);
    event ParticipantAjoute(address participant);
    event ParticipantSupprime(address participant);

    // Modificateur pour vérifier l'autorisation via la whitelist
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Acces non autorise");
        _;
    }

    // Gestion de la whitelist
    function ajouterParticipant(address _participant) public onlyOwner {
        whitelist[_participant] = true;
        emit ParticipantAjoute(_participant);
    }

    function supprimerParticipant(address _participant) public onlyOwner {
        whitelist[_participant] = false;
        emit ParticipantSupprime(_participant);
    }

    // Enregistrement d'un nouveau produit
    function enregistrerProduit(
        string memory _identifiantLot,
        string memory _nomProduit,
        uint256 _nombreDeLots,
        uint256 _quantite,
        string memory _dernierProprietaire,
        uint256 _dateAchat
    ) public onlyWhitelisted {
        produits[_identifiantLot] = Produit({
            fabricant: msg.sender,
            nombreDeLots: _nombreDeLots,
            nomProduit: _nomProduit,
            identifiantLot: _identifiantLot,
            quantite: _quantite,
            dernierProprietaire: _dernierProprietaire,
            dateAchat: _dateAchat
        });
        emit ProduitEnregistre(_identifiantLot, _nomProduit, msg.sender);
    }

    // Mise à jour du dernier propriétaire du produit
    function transfererProduit(
        string memory _identifiantLot,
        string memory _nouveauProprietaire,
        uint256 _dateAchat
    ) public onlyWhitelisted {
        Produit storage produit = produits[_identifiantLot];
        produit.dernierProprietaire = _nouveauProprietaire;
        produit.dateAchat = _dateAchat;
        emit ProprieteTransferee(_identifiantLot, _nouveauProprietaire, _dateAchat);
    }
}