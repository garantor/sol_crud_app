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


contract CRUDWITHLOGIN {
    struct User {
        address owner;
        bool isConnected;
        string password;
        string username;
        bool isUser; // used to check if this is a valid user we set, it will always be true for valid user
    }
    mapping (address => User) public userMapping;


    //create a modifer that checks the if the msg.sender is connected 

    modifier isUserConnected (){
        bool userStatus = userMapping[msg.sender].isConnected;
        require(userStatus == true, "This user is not connected");
        _;
    }

    // only owner should be able to query their own details using modifer
    modifier onlyOwner (address caller){
        require(msg.sender == caller, "Not authorized to view data");
        _;
    }

    //check if a user exist withing our mapping.

    modifier userExist(){
        require(userMapping[msg.sender].isUser == true, "user does not exist");
        _;
    }
    // add a login event
    event LoginSuccessfully (string description, bool loginstatus);

    //logout event
    event LogoutSuccessfully (string description, bool logoutStatus);

    //signup event 
    event SignupSuccessfully ( string description, string username, bool status);


    //custom error

    error unAuthorized();



    // query user details
    function getMydetails(address userAddress) public view isUserConnected onlyOwner(userAddress) returns (User memory) {
      User memory data = userMapping[userAddress];
      return data;
    }

    //login users 
    function login(string memory _username, string memory password) public userExist returns(bool status){
        User memory user = userMapping[msg.sender];
        if (keccak256(abi.encodePacked(user.username)) == keccak256(abi.encodePacked(user.password))) {
             User({ owner:msg.sender, isConnected:true, password:password, username:_username, isUser:true});
             emit LoginSuccessfully("user successfully logged in", true);
            return true;
        } else if (keccak256(abi.encodePacked(user.username)) == keccak256(abi.encodePacked(user.password))) {
            revert unAuthorized();
        }
    }


    //signup function
    function signup(string memory username, string memory password) public returns (bool) {
       User memory user = User({ owner:msg.sender, isConnected:true, password:password, username:username, isUser:true}); //password should be hashed using keccak256
       userMapping[msg.sender] = user; 
        emit SignupSuccessfully("successfully signup", username, true);
       return true;
    }


    //protected route
    function protectedFunction() public view isUserConnected  returns (string memory){
        string memory resp = string.concat("user is ", " fully authenticated");
        return resp;
    }

    //logout function
    function logout() public isUserConnected returns (string memory){
        userMapping[msg.sender].isConnected = false;
        string memory loggedOut = "You have successfully logout from the protocol";
        emit LogoutSuccessfully("successfully Loggedout", true);
        return loggedOut;
    }
}