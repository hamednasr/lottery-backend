// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;


import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

error lottery__NotEnoughETH();

contract lottery is VRFConsumerBaseV2{

    // state variables
    uint private immutable i_minFee;
    address payable[] private s_players;

    // Events
    event LotteryEnter(address indexed player);

    constructor (address vrfCoordinatorV2, uint minFee) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_minFee = minFee
    }

    function enterLottery()  returns () {
        if (msg.value < i_minFee) revert lottery__NotEnoughETH();
        s_players.push(payable(msg.sender));

        emit LotteryEnter(msg.sender);

    }

    function requestRandomWinner() external{
              
    }

    function fulfillRandomWords(uint requestId, uint[] memory randomWords) internal override {
        
    }

    function getEntranceFee() public view returns (uint) {
        return i_minFee;
    }

    function getPlayers(uint index) public view returns (address) {
        return s_players[index]
    }

}
