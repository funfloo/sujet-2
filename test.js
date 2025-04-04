const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Traceabilite", function () {
  let Traceabilite;
  let traceabilite;
  let owner, addr1, addr2;

  beforeEach(async function () {
    // Récupérer le contract factory et les comptes de test
    Traceabilite = await ethers.getContractFactory("Traceabilite");
    [owner, addr1, addr2] = await ethers.getSigners();

    // Déployer le contrat en utilisant le compte owner
    traceabilite = await Traceabilite.deploy();
    await traceabilite.deployed();
  });

  it("doit définir le bon propriétaire", async function () {
    expect(await traceabilite.owner()).to.equal(owner.address);
  });

  it("doit permettre au propriétaire d'ajouter et de supprimer des participants", async function () {
    // Ajout d'un participant (addr1)
    await traceabilite.ajouterParticipant(addr1.address);
    expect(await traceabilite.whitelist(addr1.address)).to.equal(true);

    // Suppression du participant
    await traceabilite.supprimerParticipant(addr1.address);
    expect(await traceabilite.whitelist(addr1.address)).to.equal(false);
  });

  it("doit permettre à un participant whiteliste d'enregistrer un produit", async function () {
    // Ajout de addr1 à la whitelist
    await traceabilite.ajouterParticipant(addr1.address);

    // Définition des paramètres du produit
    const identifiantLot = "lot123";
    const nomProduit = "ProduitTest";
    const nombreDeLots = 1;
    const quantite = 100;
    const dernierProprietaire = "FabricantTest";
    const dateAchat = Math.floor(Date.now() / 1000);

    // Enregistrement du produit via addr1
    await traceabilite.connect(addr1).enregistrerProduit(
      identifiantLot,
      nomProduit,
      nombreDeLots,
      quantite,
      dernierProprietaire,
      dateAchat
    );

    // Vérification des données enregistrées
    const produit = await traceabilite.produits(identifiantLot);
    expect(produit.fabricant).to.equal(addr1.address);
    expect(produit.nomProduit).to.equal(nomProduit);
    expect(produit.nombreDeLots).to.equal(nombreDeLots);
    expect(produit.quantite).to.equal(quantite);
    expect(produit.dernierProprietaire).to.equal(dernierProprietaire);
    expect(produit.dateAchat).to.equal(dateAchat);
  });

  it("doit permettre à un participant whiteliste de transférer un produit", async function () {
    // Ajout de addr1 à la whitelist et enregistrement d'un produit
    await traceabilite.ajouterParticipant(addr1.address);
    const identifiantLot = "lot456";
    const nomProduit = "ProduitTest2";
    const nombreDeLots = 1;
    const quantite = 50;
    const dernierProprietaire = "FabricantTest2";
    const dateAchat = Math.floor(Date.now() / 1000);
    await traceabilite.connect(addr1).enregistrerProduit(
      identifiantLot,
      nomProduit,
      nombreDeLots,
      quantite,
      dernierProprietaire,
      dateAchat
    );

    // Transfert du produit par addr1
    const nouveauProprietaire = "NouveauProprio";
    const newDateAchat = dateAchat + 1000; // exemple de nouvelle date
    await traceabilite.connect(addr1).transfererProduit(
      identifiantLot,
      nouveauProprietaire,
      newDateAchat
    );

    // Vérification des données mises à jour
    const produit = await traceabilite.produits(identifiantLot);
    expect(produit.dernierProprietaire).to.equal(nouveauProprietaire);
    expect(produit.dateAchat).to.equal(newDateAchat);
  });

  it("doit rejeter l'enregistrement d'un produit si l'appelant n'est pas whiteliste", async function () {
    // addr2 n'est pas ajouté à la whitelist
    const identifiantLot = "lot789";
    const nomProduit = "ProduitTest3";
    const nombreDeLots = 1;
    const quantite = 200;
    const dernierProprietaire = "FabricantTest3";
    const dateAchat = Math.floor(Date.now() / 1000);

    await expect(
      traceabilite.connect(addr2).enregistrerProduit(
        identifiantLot,
        nomProduit,
        nombreDeLots,
        quantite,
        dernierProprietaire,
        dateAchat
      )
    ).to.be.revertedWith("Acces non autorise");
  });
});