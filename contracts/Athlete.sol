// contracts/PFPinatas.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Athlete is ERC721, Ownable, ReentrancyGuard,Pausable  {

//used to increment how many NFT's have been minted
  using Counters for Counters.Counter;
  Counters.Counter private supply;

/*
* NFT IPFS configuration 
*/
  //ipfs://CDI/
  string public uriPrefix = "";
  //files extension from baseExtension location
  string public uriSuffix = ".json";
  //ipfs://CDI/hidden.json
  string public hiddenMetadataUri="";

/*
*END IPFS Configuration
*/

/*
* NFT Costs and minting limits Configuration  
*/
//Cost per mint!
  uint256 public cost = 1000000000000000000;
//How many NFT's you can mint in total
  uint256 public maxSupply = 10000;
//Set NFT minting amount per transaction
  uint256 public maxMintAmountPerTx = 50;
//Set limit per address to mint  
  uint256 public nftPerAddressLimit = 100;
//Limit for maximum NFT's you can mint
  uint256 public limitSupply=0;
/*
* END NFT Costs and minting limits Configuration  
*/

//List of events
event contractIsPaused(string _paused);
event contractIsUnPaused(string _unPaused);
event itHasMinted(address _adr, uint _value);
event invalidMindAmount(address _adr, string _message);
event mintLimitExceeded(address _adr, string _message);
event notInTheWhiteList(address _adr, string _message);
event maxMintAmountReached(address _adr, string _message);
event insufficientFunds(address _adr, string _event);

//Setting up the mintig properties  
  bool public onlyWhitelisted = false;
  
/*
* Presale/WhiteList/AirDrop Configuration
*/
  mapping(address => bool) public whitelisted;
  mapping(address => uint256) public addressMintedBalance;

/*
* EDND Presale/WhiteList/AirDrop Configuration
*/
//Setting up the contract state when deployed
  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    addressMintedBalance[ msg.sender]=0;
    setBaseURI(_initBaseURI);
    pause();
  }

/*
* Rules of the contract
*/
    modifier mintCompliance(uint256 _mintAmount) {
       require(!paused(), "The contract is paused");

       require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx , "Invalid mint amount!");
      if(!(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx)){
        emit invalidMindAmount(msg.sender, "Invalid mint amount!");
      }

      require(supply.current() + _mintAmount <= maxSupply - limitSupply, "Max NFT limit exceeded!");
      if(!(supply.current() + _mintAmount <= maxSupply - limitSupply)){
        emit mintLimitExceeded(msg.sender, "Max NFT limit exceeded!");
      }  
    _;
  }
/*
* EMD Rules of the contract
*/

/*
* This is the minting function
*/
function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {

    if (msg.sender != owner()) {
        if(onlyWhitelisted == true) {
            require(isInWhiteList(msg.sender)==true,"You are not in the whitelist !!");
            if(!isInWhiteList(msg.sender)==true){
              emit notInTheWhiteList(msg.sender, "You are not in the whitelist !!");
            }
            uint256 ownerMintedCount = addressMintedBalance[msg.sender];
            require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "Max NFT per address exceeded");
            if(!(ownerMintedCount + _mintAmount <= nftPerAddressLimit)){
              emit maxMintAmountReached(msg.sender, "Max NFT per address exceeded");
            }
        }
        require(msg.value >= cost * _mintAmount, "insufficient funds");
        if(!(msg.value >= cost * _mintAmount)){
          emit insufficientFunds(msg.sender, "Insufficient funds");
        }
    }

    _mintLoop(msg.sender, _mintAmount);
  }

function _mintLoop(address _receiver, uint256 _mintAmount) internal {
  for (uint256 i = 0; i < _mintAmount; i++) {
    supply.increment();
    _safeMint(_receiver, supply.current());
  }
  emit itHasMinted(_receiver, _mintAmount);
}
 
  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }

 /*
    @_mintAmount -> amount you want to mint 
    @_receiver   -> wallet addres you want to send it to
    This function is used for bonuses, airdrops or prizes 
 */
 function mintForOneAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    _mintLoop(_receiver, _mintAmount);
  }

/*
    @_mintAmount -> amount you want to mint
    @_receivers[] -> wallet address you want to send the minted NFT's: for each address/amount
*/
 function mintForMultipleAddresses(uint256 _mintAmount, address[] memory _receivers) public mintCompliance(_mintAmount) onlyOwner {
      for (uint256 i=0;i< _receivers.length;i++)
        _mintLoop(_receivers[i], _mintAmount);
  }
 
  function _mintSingleNFT() private {
       supply.increment();
      _safeMint(msg.sender, supply.current());
  } 

/*
  @_addr -> adding 1 address to the whiteList
*/
  function addToWhiteList(address _addr) public onlyOwner {
      whitelisted[_addr] = true;
  }
/*
  @_addrsp[] -> adding multiple addresses to the whiteList
*/
   function addAMultipleAddressesToWhiteList(address[] memory _addrs) public onlyOwner {
      
      for (uint256 i=0;i< _addrs.length;i++){
            whitelisted[_addrs[i]] = true;
          }  
  }

/*
  Setting whiteList to true
*/
  function whiteListOn() public onlyOwner{
    onlyWhitelisted=true;
  }
  /*
  Setting whiteList to false
*/
  function whiteListOff() public onlyOwner{
    onlyWhitelisted=false;
  }
/*
  check if the contract is paused
*/
    function isItpaused() public view virtual returns (bool) {
        return paused();
    }

/*
  @_addr -> check if address exists in the WhiteList private
*/
  function isInWhiteList(address _addr) private view returns (bool) {
            return whitelisted[_addr]  || _addr == owner();
  }

/*
  @_addr -> calles the private function which can access the mapping array and checks if address exists
*/
  function checkAddressIsWhiteListed(address _addr) public view returns(bool){
      return isInWhiteList(_addr);
  }

  function getNFTBalance() public view returns (uint256) {
      return supply.current();
  }

      function getBalance() public view onlyOwner returns(uint256) {
      return address(this).balance; 
    }

    function getMyNFTBalance() public view returns(uint256){
      return addressMintedBalance[msg.sender];
    }

    function getNFTBalanceByAddress(address _addr) public view returns(uint256){
      return addressMintedBalance[_addr];
    }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, Strings.toString(_tokenId), uriSuffix))
        : "";
  }

    function pause() public onlyOwner {
        _pause();
        emit contractIsPaused("Contract is set to Pause !");
    }

    function unpause() public onlyOwner {
        _unpause();
        emit contractIsUnPaused("Contract is unPause !");
    }

  /*
   @_limit Set's the minting limit per address
  */
  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
    nftPerAddressLimit = _limit;
  }

  function setMaxMintAmountPerTx(uint256 _limit) public onlyOwner {
      maxMintAmountPerTx = _limit;
  }

  /*
    @_newCost Set's the cost's per 1 NFT
  */
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }
  /*
    @_newMaxMintAmount Set's the minting limit from 1000 NFT's only newMaxMintAmount are mintable
  */
  function setmaxMintAmount(uint256 _newMaxMintAmount) public onlyOwner {
    limitSupply = _newMaxMintAmount;
  }
/*
  @_newBaseURI Set's the address for uriPrefix -> //ipfs://CDI/
*/
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    uriPrefix = _newBaseURI;
  }
/*
  @_newBaaseExtension Set's the base extension which should be .json
*/
  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    uriSuffix = _newBaseExtension;
  }
 
 //withdraw everything to the owners wallet
  function withdrawAll() public payable onlyOwner {

    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }

    fallback() external payable {}
    receive() external payable {}
}