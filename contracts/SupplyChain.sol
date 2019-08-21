pragma solidity ^0.5.0;

contract SupplyChain {


uint itemIdCount;

enum State { ForSale, Sold, Shipped, Received }

struct Item {
    string name;
    uint price;
    State state;
    address payable seller;
    address payable buyer;

}

mapping( uint => Item ) items;

event Event3 (
    uint itemId,
    string name,
    uint price,
    State state,
    address seller,
    address buyer
    );


address owner;
constructor() public{
    owner = msg.sender;
}

modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}

modifier checkState(uint _itemId, State _state) {
    require(items[_itemId].state == _state );
    _;
}

modifier checkCaller(address _caller) {
    require(msg.sender == _caller);
    _;
}
modifier checkValue(uint _value) {
    require(msg.value >= _value);
    _;
}

function addItem(string calldata _name, uint _price) checkValue(1 finney) external payable{

     uint itemId = itemIdCount;
     items[itemIdCount] = Item( _name, _price, State.ForSale, msg.sender, address(0));

     uint overpayment = msg.value - 1 finney;
     msg.sender.transfer(overpayment);

     emit Event3 (
         itemId,
         items[itemId].name,
         items[itemId].price,
         items[itemId].state,
         items[itemId].seller,
         items[itemId].buyer
    );

     itemIdCount++;
 }

function buyItem (uint _itemId) checkState( _itemId, State.ForSale) checkValue(items[_itemId].price) external payable {

    items[_itemId].buyer = msg.sender;
    uint change = msg.value - items[_itemId].price;
    items[_itemId].seller.transfer(items[_itemId].price);
    items[_itemId].buyer.transfer(change);
    items[_itemId].state = State.Sold;

    emit Event3 (
         _itemId,
         items[_itemId].name,
         items[_itemId].price,
         items[_itemId].state,
         items[_itemId].seller,
         items[_itemId].buyer
    );

}

function shipItem(uint _itemId) checkState( _itemId, State.Sold) checkCaller(items[_itemId].seller) public {
    items[_itemId].state = State.Shipped;

    emit Event3 (
         _itemId,
         items[_itemId].name,
         items[_itemId].price,
         items[_itemId].state,
         items[_itemId].seller,
         items[_itemId].buyer
    );


  }

function receiveItem(uint _itemId) checkState( _itemId, State.Shipped) checkCaller(items[_itemId].buyer) public {
    items[_itemId].state = State.Received;

    emit Event3 (
         _itemId,
         items[_itemId].name,
         items[_itemId].price,
         items[_itemId].state,
         items[_itemId].seller,
         items[_itemId].buyer
    );

  }

function getItem(uint _itemId) public view returns(string memory name, uint price, State state, address seeler, address buyer ){

    return(items[_itemId].name, items[_itemId].price, items[_itemId].state, items[_itemId].seller, items[_itemId].buyer);


}

function withdrawFunds() onlyOwner() external {
    msg.sender.transfer(address(this).balance);
}


  }
