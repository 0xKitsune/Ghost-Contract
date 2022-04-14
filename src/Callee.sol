// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

///@notice Simple contract to test ghost contract
contract Callee {
    address public sender;

    ///@notice Simple function that sets the "sender" to msg.sender and transfers ETH
    function tryTransfer(address to, uint256 amount) public {
        sender = msg.sender;
        payable(to).transfer(amount);
    }
}
