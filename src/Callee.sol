// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

///@notice Simple contract to test ghost contract
contract Callee {
    address public sender;
    address payable public recepient;

    constructor() {
        sender = msg.sender;
        recepient = payable(msg.sender);
    }

    ///@notice Simple fallback function that sets the "sender" to msg.sender and transfers ETH
    fallback() external {
        sender = msg.sender;
        recepient.transfer(10000);
    }
}
