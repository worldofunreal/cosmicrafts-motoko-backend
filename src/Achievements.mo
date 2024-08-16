import Types "Types";

module Achievements {

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
        id = 1;
        name = "Complete the Tutorial";
        achievementType = #Combat(#GamesCompleted);  // Type of achievement
        requiredProgress = 1;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = firstStepsAchievementLine.id;
    };

    public let play5AIGamesAchievement: Types.IndividualAchievement = {
        id = 2;
        name = "Defeat AI 5 Times";
        achievementType = #Combat(#GamesCompleted);
        requiredProgress = 5;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = firstStepsAchievementLine.id;
    };

    public let changeAvatarAchievement: Types.IndividualAchievement = {
        id = 3;
        name = "Change Your Avatar";
        achievementType = #Misc(#Customization);
        requiredProgress = 1;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = firstStepsAchievementLine.id;
    };

    public let addFriendAchievement: Types.IndividualAchievement = {
        id = 4;
        name = "Have 1 Accepted Friend";
        achievementType = #Social(#Social);
        requiredProgress = 1;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = firstStepsAchievementLine.id;
    };

    public let upgradeNFTAchievement: Types.IndividualAchievement = {
        id = 5;
        name = "Upgrade Any NFT to Level 3";
        achievementType = #Resource(#UpgradeNFT);
        requiredProgress = 1;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = firstStepsAchievementLine.id;
    };

    // Achievement Category: Combat
    public let combatCategory: Types.AchievementCategory = {
        id = 2;
        name = "Combat";
        achievements = [];  // To be filled with achievement IDs
        requiredProgress = 20;  // Placeholder for required progress to complete the category
        tier = #Bronze;
        progress = 0;
        completed = false;
        reward = [];
    };

    // Combat Achievement Line: Games Played
    public let gamesPlayedAchievementLine: Types.Achievement = {
        id = 2;
        name = "Games Played";
        individualAchievements = [];  // To be filled with individual achievement IDs
        requiredProgress = 7;  // Number of individual achievements
        tier = #Bronze;
        progress = 0;
        completed = false;
        reward = [];
        categoryId = combatCategory.id;
    };

    public let play10Games: Types.IndividualAchievement = {
        id = 6;
        name = "Play 10 Games";
        achievementType = #Combat(#GamesCompleted);
        requiredProgress = 10;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = gamesPlayedAchievementLine.id;
    };

    public let play25Games: Types.IndividualAchievement = {
        id = 7;
        name = "Play 25 Games";
        achievementType = #Combat(#GamesCompleted);
        requiredProgress = 25;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = gamesPlayedAchievementLine.id;
    };

    public let play50Games: Types.IndividualAchievement = {
        id = 8;
        name = "Play 50 Games";
        achievementType = #Combat(#GamesCompleted);
        requiredProgress = 50;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = gamesPlayedAchievementLine.id;
    };

    // Combat Achievement Line: Games Won
    public let gamesWonAchievementLine: Types.Achievement = {
        id = 3;
        name = "Games Won";
        individualAchievements = [];  // To be filled with individual achievement IDs
        requiredProgress = 7;
        tier = #Bronze;
        progress = 0;
        completed = false;
        reward = [];
        categoryId = combatCategory.id;
    };

    public let win10Games: Types.IndividualAchievement = {
        id = 9;
        name = "Win 10 Games";
        achievementType = #Combat(#GamesWon);
        requiredProgress = 10;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = gamesWonAchievementLine.id;
    };

    public let win25Games: Types.IndividualAchievement = {
        id = 10;
        name = "Win 25 Games";
        achievementType = #Combat(#GamesWon);
        requiredProgress = 25;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = gamesWonAchievementLine.id;
    };

    public let win50Games: Types.IndividualAchievement = {
        id = 11;
        name = "Win 50 Games";
        achievementType = #Combat(#GamesWon);
        requiredProgress = 50;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = gamesWonAchievementLine.id;
    };

    // Combat Achievement Line: Damage Dealt
    public let damageDealtAchievementLine: Types.Achievement = {
        id = 4;
        name = "Damage Dealt";
        individualAchievements = [];  // To be filled with individual achievement IDs
        requiredProgress = 7;
        tier = #Bronze;
        progress = 0;
        completed = false;
        reward = [];
        categoryId = combatCategory.id;
    };

    public let deal1000Damage: Types.IndividualAchievement = {
        id = 12;
        name = "Deal 1000 Damage";
        achievementType = #Combat(#DamageDealt);
        requiredProgress = 1000;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = damageDealtAchievementLine.id;
    };

    public let deal2500Damage: Types.IndividualAchievement = {
        id = 13;
        name = "Deal 2500 Damage";
        achievementType = #Combat(#DamageDealt);
        requiredProgress = 2500;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = damageDealtAchievementLine.id;
    };

    public let deal5000Damage: Types.IndividualAchievement = {
        id = 14;
        name = "Deal 5000 Damage";
        achievementType = #Combat(#DamageDealt);
        requiredProgress = 5000;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = damageDealtAchievementLine.id;
    };

    // Combat Achievement Line: Energy Used
    public let energyUsedAchievementLine: Types.Achievement = {
        id = 5;
        name = "Energy Used";
        individualAchievements = [];  // To be filled with individual achievement IDs
        requiredProgress = 7;
        tier = #Bronze;
        progress = 0;
        completed = false;
        reward = [];
        categoryId = combatCategory.id;
    };

    public let use100Energy: Types.IndividualAchievement = {
        id = 15;
        name = "Use 100 Energy";
        achievementType = #Combat(#EnergyUsed);
        requiredProgress = 100;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = energyUsedAchievementLine.id;
    };

    public let use250Energy: Types.IndividualAchievement = {
        id = 16;
        name = "Use 250 Energy";
        achievementType = #Combat(#EnergyUsed);
        requiredProgress = 250;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = energyUsedAchievementLine.id;
    };

    public let use500Energy: Types.IndividualAchievement = {
        id = 17;
        name = "Use 500 Energy";
        achievementType = #Combat(#EnergyUsed);
        requiredProgress = 500;
        progress = 0;
        completed = false;
        reward = [{ rewardType = #Stardust; amount = 10 }];
        achievementId = energyUsedAchievementLine.id;
    };
}
