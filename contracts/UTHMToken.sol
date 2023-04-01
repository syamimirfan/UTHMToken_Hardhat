pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract UTHMToken is ERC20Capped, ERC20Burnable{
    address payable public owner;
    uint public blockReward;

    constructor(uint256 cap, uint256 reward) ERC20("UTHMToken", "UTHM") ERC20Capped(cap * (10 ** decimals())){
        owner = payable(msg.sender);
        //decimals as 18 zeros in blockchain
        //send 10,000,000 initial supply to owner
        _mint(owner,70000000 * (10 ** decimals()));
        blockReward = reward * (10 ** decimals());
    }
        function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

        //make it internal keyword so we cannot called it from outside
        //_beforeTokenTransfer() will call this function to send  the token to student account
    function _mintMinerReward() internal {
            _mint(block.coinbase, blockReward);
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override{
        //checking the valid address
        if(from != address(0) && to != block.coinbase && block.coinbase != address(0)){
               _mintMinerReward();
        }

        super._beforeTokenTransfer(from,to,value);
    }

    function setBlockReward(uint256 reward) public{
        blockReward = reward * (10 ** decimals());
    }

    //to delete this contract
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    //make the compiler read this modifier first
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}