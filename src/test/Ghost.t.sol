// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.12;

import "./utils/test.sol";
import "../Ghost.sol";
import "../Callee.sol";
import "./utils/Console.sol";
import "./utils/Utils.sol";

interface CheatCodes {
    function deal(address who, uint256 amount) external;
}

contract GhostTest is DSTest {
    CheatCodes cheatCodes = CheatCodes(HEVM_ADDRESS);

    Ghost ghost;
    Callee callee;

    ///@notice Create contract instances and give the callee contract ETH
    function setUp() public {
        ghost = new Ghost();
        callee = new Callee();

        cheatCodes.deal(
            address(callee),
            99999999999999999999999999999999999999
        );
    }

    function testGhostTransaction() public {
        ///@notice First get the balance before the transfer so the balance after the transfer can be verified
        uint256 preBalance = address(this).balance;

        ///@notice Create the bytecode payload.
        ///@notice This bytecode sequence simply calls the callee contract, which triggers it's fallback function and sends ETH to the test contract.
        // PUSH1	00
        // DUP1
        // DUP1
        // DUP1
        // DUP1
        // PUSH20	185a4dc360ce69bdccee33b3784b0282f7961aea //This is the callee address
        // GAS
        // CALL
        bytes memory payload = (
            hex"60008080808073185a4dc360ce69bdccee33b3784b0282f7961aea5af1"
        );

        ///@notice Send the ghost transaction, this will execute the payload while making it seem like the msg.sender has a code size of 0
        ///@dev The callee's fallback function checks if the extcodesize(caller()) is zero, otherwise it reverts
        bool success = ghost.sendGhostTransaction(payload);
        require(success, "Ghost tx failed");

        ///@notice Ensure that the balance has increased, meaning that the ghostTransaction executed the payload successfully
        require(address(this).balance > preBalance, "transfer failed");
    }

    function testFailGhostTransaction() public {
        ///@notice First get the balance before the transfer so the balance after the transfer can be verified
        uint256 preBalance = address(this).balance;

        ///@notice Calling the contract will trigger the Callee fallback
        ///@notice The transfer within the fallback will fail because the msg.sender has a codesize > 0
        (bool success, ) = address(callee).call("");
        require(success, "low-level call failed");

        ///@notice Ensure that the balance has increased, meaning that the ghostTransaction executed the payload successfully
        require(address(this).balance > preBalance, "transfer failed");
    }

    receive() external payable {}
}
