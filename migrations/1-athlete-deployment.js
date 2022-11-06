const Athlete = artifacts.require("Athlete");

module.exports = function(deployer,accounts){
    deployer.deploy(Athlete,'Athlete','ATHL','https://behindmaskssociety.com',{from:'0x760DE429EF0FE3C25C03Da388401d246CE668505'});
}