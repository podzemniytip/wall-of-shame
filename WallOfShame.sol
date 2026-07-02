// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract WallOfShame is Ownable, ReentrancyGuard {
    uint256 public postFee;
    uint256 public immutable devFeePercent;
    uint256 public rewardDelay;
    address public immutable feeRecipient;

    uint256 public rewardPool;

    address public currentAuthor;
    string public currentMessage;
    uint256 public lastMessageTime;

    event MessagePosted(
        address indexed author,
        string message,
        uint256 timestamp,
        uint256 feePaid
    );
    event RewardClaimed(
        address indexed author,
        uint256 amount,
        uint256 timestamp
    );

    constructor(
        uint256 _postFee,
        uint256 _devFeePercent,
        uint256 _rewardDelay,
        address _feeRecipient
    ) Ownable(msg.sender) {
        require(_devFeePercent <= 10000, "devFeePercent > 100%");
        require(_feeRecipient != address(0), "invalid feeRecipient");
        postFee = _postFee;
        devFeePercent = _devFeePercent;
        rewardDelay = _rewardDelay;
        feeRecipient = _feeRecipient;
    }

    function postMessage(
        string calldata message
    ) external payable nonReentrant {
        require(msg.value == postFee, "incorrect fee");
        bytes memory msgBytes = bytes(message);
        require(msgBytes.length > 0 && msgBytes.length <= 32, "invalid length");

        uint256 devShare = (msg.value * devFeePercent) / 10000;
        uint256 poolShare = msg.value - devShare;

        (bool sent, ) = payable(feeRecipient).call{value: devShare}("");
        require(sent, "dev fee failed");

        rewardPool += poolShare;

        currentAuthor = msg.sender;
        currentMessage = message;
        lastMessageTime = block.timestamp;

        emit MessagePosted(msg.sender, message, block.timestamp, msg.value);
    }

    function claimReward() external nonReentrant {
        require(msg.sender == currentAuthor, "not the author");
        require(
            block.timestamp >= lastMessageTime + rewardDelay,
            "too early"
        );
        require(rewardPool > 0, "pool empty");

        uint256 amount = rewardPool;
        rewardPool = 0;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "reward transfer failed");

        emit RewardClaimed(msg.sender, amount, block.timestamp);
    }

    function getCurrentMessage()
        external
        view
        returns (
            address,
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        return (currentAuthor, currentMessage, lastMessageTime, rewardPool, postFee);
    }

    function setPostFee(uint256 newFee) external onlyOwner {
        require(newFee >= 0.001 ether && newFee <= 0.1 ether, "fee out of bounds");
        postFee = newFee;
    }

    function setRewardDelay(uint256 newDelay) external onlyOwner {
        require(newDelay >= 1 hours && newDelay <= 7 days, "delay out of bounds");
        rewardDelay = newDelay;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > rewardPool, "no extra funds");
        uint256 withdrawable = balance - rewardPool;
        (bool sent, ) = payable(owner()).call{value: withdrawable}("");
        require(sent, "withdraw failed");
    }

    receive() external payable {}
}
