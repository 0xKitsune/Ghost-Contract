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

The Ghost Contract implements a minimalistic way to execute a payload while making the codesize of the `msg.sender` appear to be zero in the context of the targeted contract.

I had originally come across this idea when searching for a way to trustlessly verify if the `msg.sender` was a smart contract or an EOA. One approach that has been previously attempted was to check the code size of the sender. If the code size is greater than 0, it is a contract, however if the code size is 0, this does not necessarily mean that the `msg.sender` is an EOA. Contracts that rely on this logic for security are vulnerable to exploits.

As demonstrated in this repo, a contract can use the `CREATE` opcode and execute an arbitrary payload, which can call another contract, transfer funds or anything else that a normal contract can do. When using this approach to call another contract, because the execution of this logic is within the constructor, the codesize of the `msg.sender` is 0.

Below is a quick look at the Ghost contract.

```js

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
```
