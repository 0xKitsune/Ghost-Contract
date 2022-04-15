# Ghost Contract

                                                   ██████
                                               ████▒▒▒▒▒▒████
                                             ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
                                           ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
                                         ██▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒
                                         ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▓▓▓▓
                                         ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▒▒▓▓
                                       ██▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒    ██
                                       ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
                                       ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
                                       ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
                                       ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
                                       ██▒▒██▒▒▒▒▒▒██▒▒▒▒▒▒▒▒██▒▒▒▒██
                                       ████  ██▒▒██  ██▒▒▒▒██  ██▒▒██
                                       ██      ██      ████      ████

**This contract is under development and does not work yet.**

```js
contract Ghost {

    /// @notice This function takes a bytecode payload that will execute during the use of the CREATE opcode
    /// @dev Since the payload executes during deployment, if the payload calls an external contract, the msg.sender is rendered as the zero address.
    function sendGhostTransaction(bytes calldata payload) public returns (bool) {
        assembly {

            /// @notice Deploy a new account executing the payload on deployment
            let deployedAddress := create(0, payload.offset, payload.length)

            /// @notice return a bool to indicate the ghost transaction was a success
            mstore(0x00, true)
            return(0x00,0x20)
        }
    }
}


```
