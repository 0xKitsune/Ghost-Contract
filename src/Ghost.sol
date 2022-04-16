// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.12;


/// @title Ghost
/// @author 0xKitsune (https://github.com/0xKitsune)
/// @notice A minimalistic contract that can execute a payload while rendering the msg.sender as 0x0000000000000000000000000000000000000000
contract Ghost {
    
    /// @notice This function takes a bytecode payload that will execute during the use of the CREATE opcode
    /// @dev Since the payload executes during deployment, if the payload calls an external contract, the msg.sender is rendered as the zero address.
    function sendGhostTransaction(bytes memory payload) public returns (bool) {
        bytes memory payloadLength = abi.encodePacked(payload.length);

        
        assembly {

            /// @notice Deploy a new account executing the payload on deployment
            let deployedAddress := create(0, payload, payloadLength)

            /// @notice return a bool to indicate the ghost transaction was a success
            mstore(0x00, true)
            return(0x00,0x20)
        }
    }
}
