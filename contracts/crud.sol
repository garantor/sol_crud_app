// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

/*
Solidty smart contract account that accept username and password

- login - user password is hash onchain and stored onchain set mapping value to connected
- logout - user mapping value is set to false
- protected URL - use modifier to gate user from accessing the endpoint
- modifer for protected url
- Some of the function and implementation below are costly, they are not meant for production
- code is only available on remix ide 
*/

import "hardhat/console.sol";

contract CRUDWITHLOGIN {
    struct User {
        address owner;
        bool isConnected;
        bytes32 password;
        string username;
        bool isUser; // used to check if this is a valid user we set, it will always be true for valid user
    }
    mapping(address => User) private  userMapping;

    //create a modifer that checks the if the msg.sender is connected

    modifier isUserConnected() {
        bool userStatus = userMapping[msg.sender].isConnected;
        require(userStatus == true, "This user is not connected");
        _;
    }

    // only owner should be able to query their own details using modifer
    modifier onlyOwner() {
        console.log(userMapping[msg.sender].owner);
        address owner = userMapping[msg.sender].owner;
        require(msg.sender == owner, "Not authorized to view data");
        _;
    }

    //check if a user exist withing our mapping.

    modifier userExist() {
        require(userMapping[msg.sender].isUser == true, "user does not exist");
        _;
    }
    // add a login event
    event LoginSuccessfully(string description, bool loginstatus);

    //logout event
    event LogoutSuccessfully(string description, bool logoutStatus);

    //signup event
    event SignupSuccessfully(string description, string username, bool status);

    //incorrect password
    event IncorrectPassword(string message, string status, string statusCode);

    //custom error

    error unAuthorized(string message);

    // query user details
    function getMydetails()
        public
        view
        isUserConnected
        onlyOwner
        returns (User memory)
    {
        User memory data = userMapping[msg.sender];
        return data;
    }

    //login users
    function login(string memory _password)
        public
        userExist
        returns (bool status)
    {
        User memory user = userMapping[msg.sender];
        if (
            user.password ==
            keccak256(abi.encodePacked(_password))
        ) {
            userMapping[msg.sender].isConnected = true;
            emit LoginSuccessfully("user successfully logged in", true);
            return true;
        } else {
            revert unAuthorized("the password you entered is incorrect");
        }
    }

    //signup function
    function signup(string memory username, string memory password)
        public
        returns (bool)
    {
        User memory user = User({
            owner: msg.sender,
            isConnected: true,
            password: keccak256(abi.encodePacked(password)),
            username: username,
            isUser: true
        }); //password should be hashed using keccak256
        userMapping[msg.sender] = user;
        emit SignupSuccessfully("successfully signup", username, true);
        return true;
    }

    //protected route
    function protectedFunction()
        public
        view
        isUserConnected
        returns (string memory)
    {
        string memory resp = string.concat("user is ", " fully authenticated");
        return resp;
    }

    //logout function
    function logout() public isUserConnected returns (string memory) {
        userMapping[msg.sender].isConnected = false;
        string
            memory loggedOut = "You have successfully logout from the protocol";
        emit LogoutSuccessfully("successfully Loggedout", true);
        return loggedOut;
    }

    //update user details
    // user exist
    function update(string memory username, string memory password)
        public
        isUserConnected
        onlyOwner
        userExist
        returns (bool)
    {
        userMapping[msg.sender].username = username;
        userMapping[msg.sender].password = keccak256(abi.encodePacked(password));
        userMapping[msg.sender].isConnected = false; //logout if connected

        return true;
    }

    function remove() public isUserConnected userExist returns (bool){
        delete userMapping[msg.sender];
        return true;
    }
}
