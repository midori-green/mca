pragma solidity >=0.4.20;
pragma experimental ABIEncoderV2;

contract ERC20CoinInterface{
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256);
}

contract PaymentAcceptance{
    address ThanksTokenAddress = 0x692a70D2e424a56D2C6C27aA97D1a86395877b3A; //for test
    address SorryTokenAddress = 0x0FdF4894a3b7C5a101686829063BE52Ad45bcfb7; //for test
    ERC20CoinInterface ThanksTokenInterface = ERC20CoinInterface(ThanksTokenAddress);
    ERC20CoinInterface SorryTokenInterface = ERC20CoinInterface(SorryTokenAddress);
    
    function acceptPayment(uint _finalPrice,address _sender,uint _token) external payable returns(bool){
    uint PaymentAmount0 = _finalPrice;
    if(_token == 0){
      uint allowanceAmount = ThanksTokenInterface.allowance(_sender,address(this));
      require(allowanceAmount>=PaymentAmount0);
      bool Check0 = ThanksTokenInterface.transferFrom(_sender,address(this),allowanceAmount);
      return Check0;
    }
   else if(_token == 1){
       uint allowanceAmount1 = SorryTokenInterface.allowance(_sender,address(this));
       require(allowanceAmount1>=PaymentAmount0);
       bool Check1 = SorryTokenInterface.transferFrom(_sender,address(this),allowanceAmount1);
       return Check1;
   }
  }
}