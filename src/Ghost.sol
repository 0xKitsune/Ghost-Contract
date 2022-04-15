// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.12;


/// @title Ghost
/// @author 0xKitsune (https://github.com/0xKitsune)
/// @notice A minimalistic contract that can execute a payload while rendering the msg.sender as 0x0000000000000000000000000000000000000000
contract Ghost {

    struct Payload{
        bytes data;
        bytes memoryOffset;
        bytes sizeOffset;
    }
    
    /// @notice This function takes a bytecode payload that will execute during the use of the CREATE opcode
    /// @dev Since the payload executes during deployment, if the payload calls an external contract, the msg.sender is rendered as the zero address.
    function sendGhostTransaction(bytes calldata payloadData) public returns (bool) {
        assembly {

            /// @notice Deploy a new account executing the payload on deployment
            let deployedAddress := create(0, payloadData.offset, payloadData.length)

            /// @notice return a bool to indicate the ghost transaction was a success
            mstore(0x00, true)
            return(0x00,0x20)
        }
    }

    function newPayload() public pure returns (Payload memory){

        bytes memory data;
        bytes memory memoryOffset;
        bytes memory sizeOffset;


        assembly{
            memoryOffset := 0x80
        }

        return Payload(data, sizeOffset, memoryOffset);
    }


    function addDataToPayload(Payload memory payload, bytes calldata newData)public pure returns (Payload memory){
       payload.data = bytes.concat(payload.data, newData);
       

       //Update the offset
       bytes memory sizeOffset = payload.sizeOffset;

       assembly{
           sizeOffset := add(newData.length, sizeOffset)
       }

        payload.sizeOffset = sizeOffset;

       return payload;
    }

    function addCallToPayload(Payload memory payload, address to, bytes calldata data) public pure returns (Payload memory){

        bytes memory newData;
        //add opcodes to store data into memory

        //push value push offset



       // this assumes that there are no return values, this gets appended to the newData
       //PUSH1 00 DUP1
        //^^ this sets the return offset and return size as 00
       newData = bytes.concat(newData, hexStrToBytes("0x600080"));


    }



    function toBytes(address a) public pure returns (bytes memory b){
        assembly {
            let m := mload(0x40)
            a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    function hexStrToBytes(string memory hex_str)
        public
        pure
        returns (bytes memory)
    {
        //Check hex string is valid
        if (
            bytes(hex_str)[0] != "0" ||
            bytes(hex_str)[1] != "x" ||
            bytes(hex_str).length % 2 != 0 ||
            bytes(hex_str).length < 4
        ) {
            revert("Hex string not valid");
        }

        bytes memory bytes_array = new bytes((bytes(hex_str).length - 2) / 2);

        for (uint256 i = 2; i < bytes(hex_str).length; i += 2) {
            uint256 tetrad1 = 16;
            uint256 tetrad2 = 16;

            //left digit
            if (
                uint256(uint8(bytes(hex_str)[i])) >= 48 &&
                uint256(uint8(bytes(hex_str)[i])) <= 57
            ) tetrad1 = uint256(uint8(bytes(hex_str)[i])) - 48;

            //right digit
            if (
                uint256(uint8(bytes(hex_str)[i + 1])) >= 48 &&
                uint256(uint8(bytes(hex_str)[i + 1])) <= 57
            ) tetrad2 = uint256(uint8(bytes(hex_str)[i + 1])) - 48;

            //left A->F
            if (
                uint256(uint8(bytes(hex_str)[i])) >= 65 &&
                uint256(uint8(bytes(hex_str)[i])) <= 70
            ) tetrad1 = uint256(uint8(bytes(hex_str)[i])) - 65 + 10;

            //right A->F
            if (
                uint256(uint8(bytes(hex_str)[i + 1])) >= 65 &&
                uint256(uint8(bytes(hex_str)[i + 1])) <= 70
            ) tetrad2 = uint256(uint8(bytes(hex_str)[i + 1])) - 65 + 10;

            //left a->f
            if (
                uint256(uint8(bytes(hex_str)[i])) >= 97 &&
                uint256(uint8(bytes(hex_str)[i])) <= 102
            ) tetrad1 = uint256(uint8(bytes(hex_str)[i])) - 97 + 10;

            //right a->f
            if (
                uint256(uint8(bytes(hex_str)[i + 1])) >= 97 &&
                uint256(uint8(bytes(hex_str)[i + 1])) <= 102
            ) tetrad2 = uint256(uint8(bytes(hex_str)[i + 1])) - 97 + 10;

            //Check all symbols are allowed
            if (tetrad1 == 16 || tetrad2 == 16) revert();

            bytes_array[i / 2 - 1] = bytes1(uint8(16 * tetrad1 + tetrad2));
        }

        return bytes_array;
    }
}
