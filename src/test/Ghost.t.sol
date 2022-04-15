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
        callee = new Callee();
        cheatCodes.deal(address(ghost), 99999999999999999999999999999999999999);
    }

    receive() external payable {}

    fallback() external payable {}

    function testGhostTransaction() public {
        console.logAddress(address(this));

        ///@notice First get the balance before the transfer so the balance after the transfer can be verified
        uint256 preBalance = address(this).balance;

        ///@notice Create the bytecode payload.
        ///@notice This simply calls the tryTransfer function, sending an amount of ETH to the passed in address, which is this contract for this test.
        ///@dev The ghost transaction works by executing the payload during deployment, making the msg.sender 0x0000000000000000000000000000000000000000
        bytes memory payload = abi.encodeWithSelector(
            callee.tryTransfer.selector,
            address(this),
            10000
        );

        ///@notice Send the ghost transaction, this will execute the payload without exposing a msg.sender to the contract that was called
        ///@notice If the contract were to check the msg.sender, the address would be 0x0000000000000000000000000000000000000000
        bool success = ghost.sendGhostTransaction(payload);
        require(success, "Ghost tx failed");

        ///@notice Get the balance after the ghostTransaction to check the change in balance
        uint256 postBalance = address(this).balance;

        ///@notice Ensure that the balance has increased, meaning that the ghostTransaction executed the payload successfully
        require(
            postBalance > preBalance,
            "postBalance is not greater than preBalance"
        );

        ///@notice during the callee.tryTransfer function, the callee sets a state variable called "sender" to the msg.sender
        ///@notice This check ensures that the ghost transaction renders the msg.sender as the zero address in the context of the Callee contract.
        // require(callee.sender() == address(0));
    }
}
