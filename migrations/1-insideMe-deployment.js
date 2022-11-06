const Athlete = artifacts.require("Athlete");

module.exports = function(deployer,accounts){
    deployer.deploy(Athlete,'Athlete','ATHL','https://behindmaskssociety.com',{from:'0x9D9d831Dc8E2734018F211992C35779Ef615eA1F'});
}