pragma solidity >=0.4.20;
pragma experimental ABIEncoderV2;
import "./Ownable.sol";

contract ERC20CoinInterface{
  function transfer(address _to, uint256 _value) public returns (bool);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256);
}

contract PaymentAcceptance{
    address ThanksTokenAddress = 0xD10AD9dB327300bBe5D71440c883A634DaD8f2C1;   //For Test 実際はALIS
    address SorryTokenAddress = 0x6d93819eD7500fF40A92F2Ef4631ca4f189f52a4;    //For Test 実際はARUK
    ERC20CoinInterface ThanksTokenInterface = ERC20CoinInterface(ThanksTokenAddress);
    ERC20CoinInterface SorryTokenInterface = ERC20CoinInterface(SorryTokenAddress);
    
    function acceptPayment(uint _finalPrice,address _sender,uint _token) external payable returns(bool){
    uint PaymentAmount = _finalPrice;
    if(_token == 0){
      ThanksTokenInterface.approve(address(this),PaymentAmount);
      require(PaymentAmount<=ThanksTokenInterface.allowance(_sender,address(this)));
    }
   else if(_token == 1){
    SorryTokenInterface.approve(address(this),PaymentAmount);
    require(PaymentAmount<=SorryTokenInterface.allowance(_sender,address(this)));
   }
    if(_token == 0){
      ThanksTokenInterface.transferFrom(_sender,address(this),PaymentAmount);
    }
    else if(_token == 1){
      SorryTokenInterface.transferFrom(_sender,address(this),PaymentAmount);
    }
    return true;
  }
}