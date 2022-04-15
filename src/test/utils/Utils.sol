// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library utils {
    /// @notice Function to calculate the gas cost of call data
    function callDataCost(bytes memory _callData)
        public
        pure
        returns (uint256)
    {
        uint256 i = 0;
        uint256 gasCost;
        uint256 callDataLength = _callData.length;

        //For each byte in call data, if it is a 0 byte, add 4 gas. Else, add 68 gas.
        for (i; i < callDataLength; i++) {
            if (_callData[i] == 0) {
                gasCost += 4;
            } else {
                gasCost += 16;
            }
        }

        return gasCost;
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
