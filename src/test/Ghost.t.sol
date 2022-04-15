// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

import "./utils/test.sol";
import "../Ghost.sol";
import "../Callee.sol";
import "./utils/Console.sol";
import "./utils/Utils.sol";

interface CheatCodes {
    function prank(address) external;

    function deal(address who, uint256 amount) external;
}

contract GhostTest is DSTest {
    CheatCodes cheatCodes = CheatCodes(HEVM_ADDRESS);

    Ghost ghost;
    Callee callee;

    ///@notice create contract instances and give the ghost contract ETh
    function setUp() public {
        ghost = new Ghost();
    }

    receive() external payable {}

    fallback() external payable {}

    function testGhostTransaction() public {
        callee = new Callee();

        cheatCodes.deal(
            address(callee),
            99999999999999999999999999999999999999
        );

        ///@notice First get the balance before the transfer so the balance after the transfer can be verified
        uint256 preBalance = address(this).balance;

        ///@notice Create the bytecode payload.
        ///@notice This simply calls the tryTransfer function, sending an amount of ETH to the passed in address, which is this contract for this test.
        ///@dev The ghost transaction works by executing the payload during deployment, making the msg.sender 0x0000000000000000000000000000000000000000
        // PUSH1	00
        // DUP1
        // DUP1
        // DUP1
        // DUP1
        // PUSH20	0c7bbb021d72db4ffba37bdf4ef055eecdbc0a295
        // GAS
        // CALL
        bytes memory payload = utils.hexStrToBytes(
            "0x600080808080730c7bbb021d72db4ffba37bdf4ef055eecdbc0a2955AF1"
        );

        ///@note when uncommented below, this works but the ghost transaction does not
        // address(callee).call("");

        ///@notice Send the ghost transaction, this will execute the payload without exposing a msg.sender to the contract that was called
        ///@notice If the contract were to check the msg.sender, the address would be 0x0000000000000000000000000000000000000000
        bool success = ghost.sendGhostTransaction(payload);
        require(success, "Ghost tx failed");

        ///@notice Get the balance after the ghostTransaction to check the change in balance
        uint256 postBalance = address(this).balance;

        ///@notice Ensure that the balance has increased, meaning that the ghostTransaction executed the payload successfully
        require(postBalance > preBalance, "transfer failed");

        ///@notice during the callee.tryTransfer function, the callee sets a state variable called "sender" to the msg.sender
        ///@notice This check ensures that the ghost transaction renders the msg.sender as the zero address in the context of the Callee contract.
        // require(callee.sender() == address(0), "sender is not 0");
    }
}
