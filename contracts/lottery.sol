// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

lottery__fewETH();

contract lottery{

    uint private immutable i_minFee;

    constructor (uint minFee) {
        i_minFee = minFee
    }

    function enterLottery()  returns () {
        if (msg.value < i_minFee) revert lottery__fewETH();
    }

    function pichWinner() {

    }

    function getEntranceFee() public view returns (uint) {
        return i_minFee;
    }
}
