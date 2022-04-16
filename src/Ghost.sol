// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.12;

/// @title Ghost
/// @author 0xKitsune (https://github.com/0xKitsune)
/// @notice A minimalistic contract that can execute a payload while appearing as a msg.sender with a codesize of 0
/// @dev This contract demonstrates why it is insecure to rely on checking the codesize of the msg.sender to determine if the sender is an EOA 
contract Ghost {
    /// @notice This function takes a bytecode payload that will execute during the use of the CREATE opcode
    /// @dev Since the payload executes during deployment, if the payload calls an external contract, the msg.sender is rendered as the zero address.
    function sendGhostTransaction(bytes calldata payload) public returns (bool) {

        assembly {
            /// @notice Copy the payload into memory so that it can be passed in as deployment bytecode
            calldatacopy(0x80, payload.offset, payload.length)

            /// @notice Deploy a new account executing the payload on deployment
            let deployedAddress := create(0, 0x80, payload.length)            

            /// @notice If the deployment failed, return false
            if iszero(deployedAddress){
                mstore(0x00, false)
                return(0x00, 0x20)
            }

            /// @notice return a bool to indicate the ghost transaction was a success
            mstore(0x00, true)
            return(0x00, 0x20)
        }
    }
}
