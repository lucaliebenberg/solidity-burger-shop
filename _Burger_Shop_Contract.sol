// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract BurgerShop {
    uint256 public normalCost = 0.2 ether;
    uint256 public deluxeCost = 0.4 ether;
    address public owner;
    uint public startDate = block.timestamp + 30 seconds;
    mapping (address => uint256) public userRefunds;

   event BoughtBurger(address indexed _from, uint256 cost);

    // State Machine example - use of 'enum'
   enum Stages {

       readyToOrder,
       makeBurger,
       deliverBurger
   }

    // Initialisation of the Stages burgerShopStage - of type 'enum'  
    Stages public burgerShopStage = Stages.readyToOrder;

    // Initialisation of the constructor - set the owner state to the contract creator / 'msg.sender'
    constructor() {
        owner = msg.sender;
    }

    // Checks if only owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner!");
        _;
    }
  
    // Checks if only owner
    modifier shopOpened() {
        require(block.timestamp > startDate, "Not open yet!");
        _;
    }

    // Checks if only owner
   modifier shouldPay(uint256 _cost) {
        require(msg.value >= _cost, "The burger costs more!");
        _;
   }

    // State Machine modifier: checks the positionality of the state 
   modifier isAtStage(Stages _stage) {
       require(burgerShopStage == _stage, "Not at the correct stage!");
       _;
   }
   
    // Function to buy a burger 
    function buyBurger() payable public shouldPay(normalCost) isAtStage(Stages.readyToOrder) shopOpened {
        updateStage(Stages.makeBurger);
        emit BoughtBurger(msg.sender, normalCost);
    }
  
    // Function to buy a burger 
    function buyDeluxeBurger() payable public shouldPay(deluxeCost) isAtStage(Stages.readyToOrder) shopOpened {
        updateStage(Stages.makeBurger);
        emit BoughtBurger(msg.sender, deluxeCost);
    }

    // Function to buy a burger 
    function refund(address payable _to, uint256 _cost) payable public onlyOwner {
        require(_cost == normalCost || _cost == deluxeCost, "You are trying to refuned the wrong amount!");
        require(address(this).balance >= _cost);

        userRefunds[_to] = _cost;
    }
    // Function to buy a burger 
    function claimRefund() payable public {
        uint256 value = userRefunds[msg.sender];

        userRefunds[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: value}("");
        require(success);
    }

    // Function to get funds
    function getFunds() public view returns(uint256) {
        return address(this).balance;
    }

    // Function to make burger
    function madeBurger() public isAtStage(Stages.makeBurger) shopOpened {
        updateStage(Stages.deliverBurger);
    }

    // Function to pick up burger 
    function pickUpBurger() public isAtStage(Stages.deliverBurger) shopOpened {
         updateStage(Stages.readyToOrder);
    }

    // Function to update burgerShopStage
    function updateStage(Stages _stage) public {
        burgerShopStage = _stage;
    }

    // Function to get a randomNumber
    function getRandomNumber(uint256 _seed) public view returns(uint256) {
        uint256 randNum = uint256(keccak256(abi.encodePacked(block.timestamp, _seed))) % 10 + 1;
        return randNum;
    }
}