pragma solidity ^0.4.24;

pragma experimental ABIEncoderV2;
import "./Ownable.sol";

contract PaymentAcceptance{
     function acceptPayment(uint _finalPrice,address _sender,uint _token) external payable returns(bool);
     function ConfirmOfReceipt(uint _finalPrice,address _sellersAddress,uint _Token,uint evaluation) public;
}

contract point_system is Ownable {
    address PaymentAcceptanceAddress = 0x8046085fb6806cAa9b19a4Cd7b3cd96374dD9573;
    PaymentAcceptance PaymentAcceptance1 = PaymentAcceptance(PaymentAcceptanceAddress);
struct product{
  string name;
  mapping(uint=>uint) NowPrice;
  mapping(uint=>address) highestBidder;
  uint biddingPeriod;   //Seconds
  uint finalPrice;
  uint Token;
  bool PaymentStatus;
}
struct seller{
  string name;
  address sellerAddress;
  uint good;
  uint bad;
}
mapping(address=>uint) addressToPoint;
mapping(uint=>uint) productToSeller;
address[] public PermissionPersonList;
product[] public products;
seller[] public sellers;

function AddPermissionAddress(address _permissionPerson) public onlyOwner(){
  PermissionPersonList.push(_permissionPerson);
}

function setPaymentAcceptanceAddress(address _new) public onlyOwner(){
    PaymentAcceptanceAddress = _new;
}
function addSeller(string _name) external dupCheck(msg.sender) PermissionCheck(msg.sender){
  sellers.push(seller(_name,msg.sender,0,0));
}
  function addItem(string _productName,uint[] _StartPrice,uint[] TypeOfCurrency,uint period) external exiCheck(msg.sender){
    uint productId = products.push(product(_productName,0,0,0,false)) - 1;
    products[productId].biddingPeriod = now + period;
    ConnectingSellerWithProduct(productId,msg.sender);
    setStartPrice(productId,_StartPrice,TypeOfCurrency);
  }
  function setStartPrice(uint _productId,uint[] _StartPrice,uint[] TypeOfCurrency) private{
      for(uint i=0; i<TypeOfCurrency.length; i++){
      products[_productId].NowPrice[TypeOfCurrency[i]] = _StartPrice[i];   //通貨ごとにオークション開始値段を分けている
    }
  }
  function ConnectingSellerWithProduct(uint _productId,address _sender) private{
    for(uint i=0; i<sellers.length; i++){ //プロダクトとセラーの結びつけをしている
     if(sellers[i].sellerAddress == _sender){
        productToSeller[_productId] = i;
      }
    }
  }
  function bidding(uint _productId,uint _biddingPrice, uint TypeOfCurrency) external{
    require(_biddingPrice>products[_productId].NowPrice[TypeOfCurrency] && products[_productId].biddingPeriod>=block.timestamp);
    products[_productId].NowPrice[TypeOfCurrency] = _biddingPrice;
    products[_productId].highestBidder[TypeOfCurrency] = msg.sender;
  }
  function GetNowPrice(uint _productId,uint TypeOfCurrency) external view returns(uint){
    return products[_productId].NowPrice[TypeOfCurrency];
  }
  function GetHightestBidder(uint _productId,uint _TypeOfCurrency) external view returns(address){
    return products[_productId].highestBidder[_TypeOfCurrency];
  }
  function GetBiddingPeriod(uint _productId) external view returns(uint,uint){
      return(now,products[_productId].biddingPeriod);
  }
  function chooseCurrency(uint _productId,uint TypeOfCurrency) external{        //ここがしっかり実行されたかのパラメーター必要
    require(sellers[productToSeller[_productId]].sellerAddress == msg.sender && now>=products[_productId].biddingPeriod);
    products[_productId].finalPrice = products[_productId].NowPrice[TypeOfCurrency];
    products[_productId].Token = TypeOfCurrency;
  }
  function ConfirmOfReceipit(uint _productId,uint _evaluation) external{
      require(products[_productId].highestBidder[products[_productId].Token] == msg.sender && products[_productId].PaymentStatus == true);
      if(_evaluation == 1){
          sellers[productToSeller[_productId]].good++;
      }else if(_evaluation == 2){
          sellers[productToSeller[_productId]].bad++;
      }
      PaymentAcceptance1.ConfirmOfReceipt(products[_productId].finalPrice,sellers[productToSeller[_productId]].sellerAddress,products[_productId].Token,_evaluation);
  }
  function Payment(uint _productId) external payable{
      uint FinallyToken = products[_productId].Token;
      require(products[_productId].highestBidder[FinallyToken] == msg.sender);
      if(products[_productId].Token !=2 ){
      bool check = PaymentAcceptance1.acceptPayment(products[_productId].finalPrice,msg.sender,FinallyToken);
      products[_productId].PaymentStatus = check;
    }
    else if(products[_productId].Token == 2){
        
    }
  }
  modifier dupCheck(address seller1){
    int check = -5;
    for(int i=0;i<int(sellers.length);i++){
      if(sellers[uint(i)].sellerAddress == seller1){
        check =  -1;
      }
    } 
    require(check!=-1);
    _;
  }

modifier exiCheck(address seller2){
    int check2 = -1;
    for(int i=0; i<int(sellers.length); i++){
      if(sellers[uint(i)].sellerAddress == seller2){
        check2 =  i;
      }
    }
    require(check2!=-1);
    _;
  }
 modifier PermissionCheck(address person){
   bool check = false;
   for(uint i = 0; i<PermissionPersonList.length; i++ ){
     if(PermissionPersonList[i] == person){
       check = true;
       break;
     }
   }
   require(check==true,"You aren't in the permission list ");
   _;
 }
}

//商品に対するいいねを押すことでトークンをゲットできる　出品でトークンをゲットできる　購入ではポイントのようにトークンをゲットできる
//受取相手の評価をすることでトークンをゲットできるなど、トークンエコノミーと結び付けられるかも？