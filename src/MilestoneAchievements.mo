import Types "Types";

module MilestoneAchievements {

    // Achievement Category: Milestones
    public let milestoneCategory: Types.AchievementCategory = {
        id = 1;  // Unique ID for the Milestones category
        name = "Milestones";
        achievements = [];  // To be filled with achievement IDs
        requiredProgress = 1;  // Placeholder for required progress to complete the category
        tier = #Bronze;  // Initial tier
        progress = 0;  // Initial progress
        completed = false;
        reward = [];  // Placeholder for rewards
    };

    // Achievement Line: First Steps in the Cosmos
    public let firstStepsAchievementLine: Types.Achievement = {
        id = 1;  // Unique ID for the First Steps in the Cosmos achievement line
        name = "First Steps in the Cosmos";
        individualAchievements = [];  // To be filled with individual achievement IDs
        requiredProgress = 5;  // Placeholder for required progress
        tier = #Bronze;  // Initial tier
        progress = 0;  // Initial progress
        completed = false;
        reward = [];  // Placeholder for rewards
        categoryId = milestoneCategory.id;  // Link to the Milestones category
    };

    // Individual Achievements in the First Steps in the Cosmos line
    public let completeTutorialAchievement: Types.IndividualAchievement = {
        id = 1;  // Unique ID for this individual achievement
        name = "Complete the Tutorial";
        achievementType = #GamesCompleted;  // Type of achievement
        requiredProgress = 1;  // Only need to complete the tutorial once
        progress = 0;  // Initial progress
        completed = false;
        reward = [];  // Placeholder for rewards
        achievementId = firstStepsAchievementLine.id;  // Link to the achievement line
    };

    public let play5AIGamesAchievement: Types.IndividualAchievement = {
        id = 2;  // Unique ID for this individual achievement
        name = "Defeat AI 5 Times";
        achievementType = #GamesCompleted;  // Type of achievement
        requiredProgress = 5;  // Defeat AI 5 times
        progress = 0;  // Initial progress
        completed = false;
        reward = [];  // Placeholder for rewards
        achievementId = firstStepsAchievementLine.id;  // Link to the achievement line
    };

    public let changeAvatarAchievement: Types.IndividualAchievement = {
        id = 3;  // Unique ID for this individual achievement
        name = "Change Your Avatar";
        achievementType = #Customization;  // Type of achievement
        requiredProgress = 1;  // Only need to change the avatar once
        progress = 0;  // Initial progress
        completed = false;
        reward = [];  // Placeholder for rewards
        achievementId = firstStepsAchievementLine.id;  // Link to the achievement line
    };

    public let addFriendAchievement: Types.IndividualAchievement = {
        id = 4;  // Unique ID for this individual achievement
        name = "Have 1 Accepted Friend";
        achievementType = #Social;  // Type of achievement
        requiredProgress = 1;  // Need to have 1 accepted friend
        progress = 0;  // Initial progress
        completed = false;
        reward = [];  // Placeholder for rewards
        achievementId = firstStepsAchievementLine.id;  // Link to the achievement line
    };

    public let upgradeNFTAchievement: Types.IndividualAchievement = {
        id = 5;  // Unique ID for this individual achievement
        name = "Upgrade Any NFT to Level 3";
        achievementType = #UpgradeNFT;  // Type of achievement
        requiredProgress = 1;  // Only need to upgrade one NFT to level 3
        progress = 0;  // Initial progress
        completed = false;
        reward = [];  // Placeholder for rewards
        achievementId = firstStepsAchievementLine.id;  // Link to the achievement line
    };
}
