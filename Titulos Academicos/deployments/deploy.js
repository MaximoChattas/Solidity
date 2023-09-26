async function main() {
    const TitulosAcademicos = await ethers.getContractFactory("TitulosAcademicos");
    const titulos_academicos = await TitulosAcademicos.deploy("Titulos Academicos");
    console.log("Contract Deployed to Address:", titulos_academicos.address);
  }
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });