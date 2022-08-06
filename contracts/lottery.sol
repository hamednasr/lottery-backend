// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error lottery__NotEnoughETH();
error lottery__transferFailed();

contract lottery is VRFConsumerBaseV2 {
    // state variables
    uint256 private immutable i_minFee;
    address payable[] private s_players;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant NUM_WORDS = 1;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    // Lottery variables
    address private s_Winner;

    // Events
    event LotteryEnter(address indexed player);
    event RequestedLotteryWinner(uint256 indexed requestId);
    event WinnerSelected(address indexed winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 minFee,
        bytes32 keyHash,
        uint32 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_minFee = minFee;
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterLottery() public payable {
        if (msg.value < i_minFee) revert lottery__NotEnoughETH();
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }

    function requestRandomWinner() external {
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedLotteryWinner(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 WinnerIndex = randomWords[0] % s_players.length;
        address payable WinnerAddress = s_players[WinnerIndex];
        s_Winner = WinnerAddress;
        s_players = new address payable[](0);

        (bool success, ) = WinnerAddress.call{value: address(this).balance}("");
        if (!success) revert lottery__transferFailed();

        emit WinnerSelected(WinnerAddress);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_minFee;
    }

    function getPlayers(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getWinner() public view returns (address) {
        return s_Winner;
    }
}
