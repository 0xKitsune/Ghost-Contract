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
                        

This contract implements a minimalistic way to execute a payload and render the msg.sender as the zero address. I had originally come across this idea when searching for a way to trustlessly verify if the `msg.sender` was a smart contract or an EOA. One way you can determine if the `msg.sender` is a contract is to check the code size of the sender. If the code size is greater than 0, it is a contract. However, this does not cover all cases and if a contract is relying on this logic for security, it is still vulnerable.

As demonstrated in this repo, a contract can use the `CREATE` opcode and execute an arbitrary payload, which can call another contract, transfer funds or anything else that a normal contract can do. When using this approach to call another contract, the `msg.sender` is rendered as the `0x0000000000000000000000000000000000000000`.

When verifying if the `msg.sender` is a contract or an EOA, it is important to check **both** the code size of the `msg.sender` and if the `msg.sender` is `address(0)`. 

Below is a quick look at the Ghost contract. 

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


                                                                                        
                                                                                                                                                      
