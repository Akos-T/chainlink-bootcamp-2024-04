// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Import 'ERC20', 'AccessControl', '_grantRole()', 'DEFAULT_ADMIN_ROLE', 'onlyRole()', '_mint()'
import "@openzeppelin/contracts@4.6.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";

contract Token is ERC20, AccessControl {
    // Create a role: MINTER_ROLE
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Create ERC20 token: Name + Ticker
    constructor() ERC20("Chainlink Bootcamp 2024 Token", "CLBoot24") {
        // Granting roles to the deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    // Mints token to the `to` address with `amount` amount.
    // Only address with MINTER_ROLE can call this!
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // Overrides ERC20 decimals, our token will have 2 decimals, like fiat currencies
    // ETH has 18 decimals for example.
    // Solidity doesn't handle decimal points, that's why we need this.
    function decimals() public pure override returns (uint8) {
        return 2; // 100.00
    }
}
