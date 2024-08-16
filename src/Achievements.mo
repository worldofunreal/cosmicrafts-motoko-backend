import Types "Types";

module Achievements {

    // Create the Milestone Category and associated achievements
    public func createMilestoneCategory(
        categoryID: Nat, 
        achievementID: Nat, 
        individualAchievementID: Nat
    ): (Types.AchievementCategory, Types.Achievement, [Types.IndividualAchievement]) {
        
        let milestoneCategory: Types.AchievementCategory = {
            id = categoryID;
            name = "Milestones";
            achievements = [];
            requiredProgress = 5;
            tier = #Bronze;
            progress = 0;
            completed = false;
            reward = [];
        };

        let firstStepsAchievementLine: Types.Achievement = {
            id = achievementID;
            name = "First Steps in the Cosmos";
            individualAchievements = [];
            requiredProgress = 5;
            tier = #Bronze;
            progress = 0;
            completed = false;
            reward = [];
            categoryId = milestoneCategory.id;
        };

        // Individual achievements associated with "First Steps in the Cosmos"
        let completeTutorialAchievement: Types.IndividualAchievement = {
            id = individualAchievementID;
            name = "Complete the Tutorial";
            achievementType = #GamesCompleted;
            requiredProgress = 1;
            progress = 0;
            completed = false;
            reward = [{ rewardType = #Stardust; amount = 10 }];
            achievementId = firstStepsAchievementLine.id;
        };

        let play5AIGamesAchievement: Types.IndividualAchievement = {
            id = individualAchievementID + 1;
            name = "Defeat AI 5 Times";
            achievementType = #GamesCompleted;
            requiredProgress = 5;
            progress = 0;
            completed = false;
            reward = [{ rewardType = #Chest; amount = 1 }];
            achievementId = firstStepsAchievementLine.id;
        };

        let changeAvatarAchievement: Types.IndividualAchievement = {
            id = individualAchievementID + 2;
            name = "Change Your Avatar";
            achievementType = #Customization;
            requiredProgress = 1;
            progress = 0;
            completed = false;
            reward = [{ rewardType = #Stardust; amount = 10 }];
            achievementId = firstStepsAchievementLine.id;
        };

        let addFriendAchievement: Types.IndividualAchievement = {
            id = individualAchievementID + 3;
            name = "Have 1 Accepted Friend";
            achievementType = #Social;
            requiredProgress = 1;
            progress = 0;
            completed = false;
            reward = [{ rewardType = #Chest; amount = 1 }];
            achievementId = firstStepsAchievementLine.id;
        };

        let upgradeNFTAchievement: Types.IndividualAchievement = {
            id = individualAchievementID + 4;
            name = "Upgrade Any NFT to Level 3";
            achievementType = #UpgradeNFT;
            requiredProgress = 1;
            progress = 0;
            completed = false;
            reward = [{ rewardType = #Stardust; amount = 15 }];
            achievementId = firstStepsAchievementLine.id;
        };

        // Return the category, the achievement line, and the individual achievements
        return (milestoneCategory, firstStepsAchievementLine, [
            completeTutorialAchievement, 
            play5AIGamesAchievement, 
            changeAvatarAchievement, 
            addFriendAchievement, 
            upgradeNFTAchievement
        ]);
    };

    // Additional template functions for other categories and achievements can be added here
}
