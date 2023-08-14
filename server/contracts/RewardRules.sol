// RewardRules.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FlipGem.sol";  // Import the FlipGem contract

contract RewardRules is Ownable {
    FlipGem public flipGemToken;  // Reference to the FlipGem contract

    mapping(string => uint256) public actionRewards;
    mapping(string => uint256) public coupenAmount;
    struct Transaction {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
    }
    Transaction[] public transactionHistory;

    constructor(address _flipGemAddress) {
        flipGemToken = FlipGem(_flipGemAddress);  // Initialize the FlipGem contract
    }

    // Set reward for a specific action
    function setRewardForAction(string memory product_id, uint256 reward) external onlyOwner {
        actionRewards[product_id] = reward;
    }

    function setCoupenAmount(string memory coupen_id, uint256 reward) external onlyOwner {
        actionRewards[coupen_id] = reward;
    }

    // Get reward for a specific action
    function getRewardForAction(string memory product_id) external view returns (uint256) {
        return actionRewards[product_id];
    }

    function getCoupenAmountForAction(string memory coupen_id) external view returns (uint256) {
        return actionRewards[coupen_id];
    }

    // Deduct amount from owner and add it to given user's balance
    function transferReward(address user, string memory product_id) external onlyOwner {
        uint256 rewardAmount = actionRewards[product_id];

        require(rewardAmount > 0, "Reward not set for this action");
        require(user != address(0), "Invalid user address");

        // Transfer the reward from owner to the user using FlipGem token
        flipGemToken.transferFrom(owner(), user, rewardAmount);
        transactionHistory.push(Transaction({
            from: address(this),
            to: user,
            amount:  rewardAmount,
            timestamp: block.timestamp
        }));
    }

    function deductCoupon(address user, string memory coupon_id) external onlyOwner {
        uint256 couponAmount = coupenAmount[coupon_id];
        require(couponAmount > 0, "Coupon amount not set");
        require(user != address(0), "Invalid user address");

        // Deduct the coupon amount from the user's balance using FlipGem token
        flipGemToken.transferFrom(user, address(this), couponAmount);
        transactionHistory.push(Transaction({
            from: user,
            to: address(this),
            amount:  couponAmount,
            timestamp: block.timestamp
        }));
    }

    function decayReward(address user) external onlyOwner {
        require(user != address(0), "Invalid user address");
        for (uint256 i = 0; i < transactionHistory.length; i++) {
            if (transactionHistory[i].from == user &&
                block.timestamp > transactionHistory[i].timestamp + 30 days) {
                
                uint256 decayedAmount = transactionHistory[i].amount;

                flipGemToken.transferFrom(user, address(this), decayedAmount);

                transactionHistory.push(Transaction({
                    from: user,
                    to: address(this),
                    amount: decayedAmount,
                    timestamp: block.timestamp
                }));
            }
        }
    }


    function getTransactionHistoryLength() external view returns (uint256) {
        return transactionHistory.length;
    }

    function getTransaction(uint256 index) external view returns (address from, address to, uint256 amount, uint256 timestamp) {
        require(index < transactionHistory.length, "Index out of bounds");
        
        Transaction memory transaction = transactionHistory[index];
        return (transaction.from, transaction.to, transaction.amount, transaction.timestamp);
    }
    function getUserTransactions(address user) external view returns (Transaction[] memory) {
        uint256 userTransactionCount = 0;
        for(uint256 i = 0; i < transactionHistory.length; i++) {
            if (transactionHistory[i].from == user || transactionHistory[i].to == user) {
                userTransactionCount++;
            }
        }
        Transaction[] memory userTransactions = new Transaction[](userTransactionCount);
        uint256 userTransactionIndex = 0;

        for (uint256 i = 0; i < transactionHistory.length; i++) {
            if (transactionHistory[i].from == user || transactionHistory[i].to == user) {
                userTransactions[userTransactionIndex] = transactionHistory[i];
                userTransactionIndex++;
            }
        }
        return userTransactions;
    }
}
