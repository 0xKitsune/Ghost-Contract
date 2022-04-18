// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.12;

///@notice Simple contract to test ghost contract
contract Callee {
    address payable public recepient;

    constructor() {
        recepient = payable(msg.sender);
    }

    ///@notice Simple fallback function that transfers ETH if the msg.sender's codesize is 0
    fallback() external {
        assembly {
            if iszero(iszero(extcodesize(caller()))) {
                revert(0x00, 0x00)
            }
        }

        recepient.transfer(10000);
    }
}
