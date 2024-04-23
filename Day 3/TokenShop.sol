// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Sepolia

// This will allow us to see price and other information
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface TokenInterface {
    function mint(address account, uint256 amount) external;
}

contract TokenShop {
    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;
    uint256 public tokenPrice = 200; //1 token = 2.00 USD, with 2 decimal places
    address public owner;

    // In this case this address is going to be the previously created token contract's address
    // We need to defin this when deploying this contract
    constructor(address tokenAddress) {
        minter = TokenInterface(tokenAddress);

        /**
         * Network: Sepolia
         * Aggregator: ETH/USD
         * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
         */
        priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        owner = msg.sender;
    }

    /**
     * Returns the latest answer
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // We're only interested in the price now
        (
            ,
            /* uint80 roundID */ int price /* uint startedAt */ /* uint timeStamp */ /* uint80 answeredInRound */,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }

    // In: amount of ETH
    // Out: amount of my token
    // X ETH = Y MyToken
    function tokenAmount(uint256 amountETH) public view returns (uint256) {
        //Sent amountETH, how many usd I have
        uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer()); //with 8 decimal places
        uint256 amountUSD = (amountETH * ethUsd) / 10 ** 18; //ETH = 18 decimal places
        uint256 amountToken = amountUSD / tokenPrice / 10 ** (8 / 2); //8 decimal places from ETHUSD / 2 decimal places from token
        return amountToken;
    }

    // payable = it can receive tokens, in this case ETH
    receive() external payable {
        uint256 amountToken = tokenAmount(msg.value); // In: amount of ETH, Out: amount of my token
        minter.mint(msg.sender, amountToken); // Mint MyToken in the amount of `amountToken` to `msg.sender`
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Owner can withdraw the ETH that was sent to the contract in exchange of `MyToken` using the receive function
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
        // address(this) = address of this contract
    }
}
