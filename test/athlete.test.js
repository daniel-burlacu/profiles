const Athlete = artifacts.require("Athlete");
const truffleAssert = require("truffle-assertions");

const { ErrorType } = truffleAssert;

contract("Athlete",(accounts) => {

    it("Should mint an amount of NFT's to a specific account when whitelist on with ownerAccount", async()=>{
        const athleteInstance = await Athlete.deployed('Athlete','ATHL','https://pinata.com/#3213mci23jdf023j4sdfa234dcd',{from:accounts[0]});
        
        await athleteInstance.unpause({from:accounts[0]});
        await athleteInstance.whiteListOn({from:accounts[0]});
        //for ETHERS
        // const mintQuantity = 5;
        // const mintCost =web3.utils.toBN(1000000000000000000);
        // const transactionCost = web3.utils.toBN(10000000);
        // const totalCost = web3.utils.fromWei(web3.utils.toBN(mintQuantity).mul(web3.utils.toBN(mintCost)).add(web3.utils.toBN(transactionCost)));
       
        //for WEI
        const mintQuantity = '5';
        const mintCost = '1000000000000000000';
        const transactionCost = '10000000';

        const totalCost = web3.utils.toBN(mintQuantity).mul(web3.utils.toBN(mintCost)).add(web3.utils.toBN(transactionCost)).toString();
        console.log('total cost is:',totalCost);
        const txResult = await athleteInstance.mint(mintQuantity,{from:accounts[0], value:totalCost});
        console.log('txResult: ',txResult);
        truffleAssert.eventEmitted(txResult,"Transfer",{from:'0x0000000000000000000000000000000000000000',
                                   to:accounts[0],tokenId:web3.utils.toBN("5")});
        assert.equal(await athleteInstance.ownerOf(5),accounts[0],"Owner of Token 5 is not equal account 0 !");
    })

    it("Should not mint in NFT's if address is not whiteListed account[2]", async()=>{
       const athleteInstance = await Athlete.deployed('Athlete','ATHL','https://pinata.com/#3213mci23jdf023j4sdfa234dcd',{from:accounts[0]});
   //     await athleteInstance.unpause();
   //     await athleteInstance.whiteListOn();

        //for WEI
        const mintQuantity = '5';
        const mintCost = '1000000000000000000';
        const transactionCost = '10000000';

        const totalCost = web3.utils.toBN(mintQuantity).mul(web3.utils.toBN(mintCost)).add(web3.utils.toBN(transactionCost)).toString();
        await truffleAssert.reverts(
            athleteInstance.mint(mintQuantity,{from:accounts[2], value:totalCost}),'You are not in the whitelist !!'
        );
    });

    it("Should mint an NFT when account[2] added to whitelist", async()=>{
        const athleteInstance = await Athlete.deployed('Athlete','ATHL','https://pinata.com/#3213mci23jdf023j4sdfa234dcd',{from:accounts[0]});
        await athleteInstance.addToWhiteList(accounts[2],{from:accounts[0]});

        // await athleteInstance.unpause({from:accounts[1]});
         await athleteInstance.whiteListOn({from:accounts[0]});
        assert.equal(await athleteInstance.checkAddressIsWhiteListed(accounts[2]),true,'accounts[2] is inside the whitelist');
 
         //for WEI
         const mintQuantity = '5';
         const mintCost = '1000000000000000000';
         const transactionCost = '10000000';
 
         const totalCost = web3.utils.toBN(mintQuantity).mul(web3.utils.toBN(mintCost)).add(web3.utils.toBN(transactionCost)).toString();
 
         const txResult = await athleteInstance.mint(mintQuantity,{from:accounts[2], value:totalCost});
         console.log('txResult: ',txResult);
         truffleAssert.eventEmitted(txResult,"Transfer",{from:'0x0000000000000000000000000000000000000000',
                                    to:accounts[2],tokenId:web3.utils.toBN("10")});
         assert.equal(await athleteInstance.ownerOf(10),accounts[2],"Owner of Token 10 is not equal account 0 !");
     });

    it("should not be able to set white-list on , if it is not the owner", async()=>{
            const athleteInstance = await Athlete.deployed('Athlete','ATHL','https://pinata.com/#3213mci23jdf023j4sdfa234dcd',{from:accounts[0]});
            await truffleAssert.fails(
                athleteInstance.whiteListOn({from:accounts[3]}),ErrorType.REVERT
            );
    });
     it("should not be able to set white-list off , if it is not the owner", async()=>{
        const athleteInstance = await Athlete.deployed('Athlete','ATHL','https://pinata.com/#3213mci23jdf023j4sdfa234dcd',{from:accounts[0]});
        await truffleAssert.fails(
            athleteInstance.whiteListOff({from:accounts[3]}),ErrorType.REVERT
        );
     });

     it("should not be able to Pause the contract , if it is not the owner", async()=>{
        const athleteInstance = await Athlete.deployed('Athlete','ATHL','https://pinata.com/#3213mci23jdf023j4sdfa234dcd',{from:accounts[0]});
        await truffleAssert.fails(
            athleteInstance.pause({from:accounts[3]}),ErrorType.REVERT
        );
     });

     it("should not be able to unPause the contract , if it is not the owner", async()=>{
        const athleteInstance = await Athlete.deployed('Athlete','ATHL','https://pinata.com/#3213mci23jdf023j4sdfa234dcd',{from:accounts[0]});
        await truffleAssert.fails(
            athleteInstance.unpause({from:accounts[3]}),ErrorType.REVERT
        );
     });

     it("should be in the white list, accounts[2]", async()=>{
        const athleteInstance = await Athlete.deployed('Athlete','ATHL','https://pinata.com/#3213mci23jdf023j4sdfa234dcd',{from:accounts[0]});
        //await athleteInstance.unpause({from:accounts[0]});
        //await athleteInstance.whiteListOn({from:accounts[0]});
        await athleteInstance.addToWhiteList(accounts[2],{from:accounts[0]});
        
        await truffleAssert.passes(
            athleteInstance.checkAddressIsWhiteListed(accounts[2],{from:accounts[0]}),'Should pass',/Should pass/)
       });
})