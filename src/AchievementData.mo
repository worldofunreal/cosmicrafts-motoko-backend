import Types "Types";

module AchievementData {

    public type AchievementCategory = Types.AchievementCategory;
    public type AchievementLine = Types.AchievementLine;
    public type IndividualAchievement = Types.IndividualAchievement;
    public type AchievementReward = Types.AchievementReward;
    public type AchievementRewardsType = Types.AchievementRewardsType;
    public type NFTDetails = Types.NFTDetails;
    public type AchievementType = Types.AchievementType;

    // Step 1: Define the NFT Details
    let rewardNFT: NFTDetails = {
        unitType = #Spaceship;
        name = "Gemini";
        description = "A glitch on the matrix";
        image = "imageURL";
        faction = #Celestial;
        rarity = 4;
        level = 1;
        health = 420;
        damage = 42;
        combatExperience = 0;
    };

    // Step 2: Define Rewards for the Tiers Category
    let categoryReward: [AchievementReward] = [
        { rewardType = #XP; amount = 100 },
        { rewardType = #Stardust; amount = 1000 },
        { rewardType = #Avatar; amount = 1; avatar = ?99 },  // Avatar ID 99
        { rewardType = #Title; amount = 1; title = ?"Cosmicrafts Beta Founder" },  // Title as Text
        { rewardType = #Chest; amount = 1; chestRarity = ?10 },  // Chest rarity 10
        { rewardType = #NFT; amount = 1; nftDetails = ?rewardNFT }  // NFT details
    ];

    // Step 3: Define Achievement Line Rewards
    let lineRewards: [AchievementReward] = [
        { rewardType = #XP; amount = 50 },
        { rewardType = #Stardust; amount = 100 },
        { rewardType = #Chest; amount = 1; chestRarity = ?7 },  // Chest rarity 7
        // The title for each line will be specified in the individual line definitions
    ];

    // Step 4: Define the rewards for individual achievements
    let indAchRewards: [AchievementReward] = [
        { rewardType = #Stardust; amount = 10 },
        { rewardType = #Chest; amount = 1; chestRarity = ?2 },  // Chest rarity 2
        { rewardType = #XP; amount = 25 }
    ];

    // Define each individual achievement for Twitter
    let indAchievementsTwitter: [IndividualAchievement] = [
        { id = 1; achievementId = 1; name = "Connect with Twitter"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 2; achievementId = 1; name = "Follow us on Twitter"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 3; achievementId = 1; name = "Like/Share/Comment on Twitter"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 4; achievementId = 1; name = "Post and tag us on Twitter"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false }
    ];

    // Repeat similar definitions for other platforms
    // Example: Discord
    let indAchievementsDiscord: [IndividualAchievement] = [
        { id = 5; achievementId = 2; name = "Connect with Discord"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 6; achievementId = 2; name = "Follow us on Discord"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 7; achievementId = 2; name = "Like/Share/Comment on Discord"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 8; achievementId = 2; name = "Join Discord Server"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 9; achievementId = 2; name = "Add Faction Role"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false }
    ];

    // Define each individual achievement for DSCVR
    let indAchievementsDSCVR: [IndividualAchievement] = [
        { id = 10; achievementId = 3; name = "Connect with DSCVR"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 11; achievementId = 3; name = "Follow us on DSCVR"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 12; achievementId = 3; name = "Like/Share/Comment on DSCVR"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 13; achievementId = 3; name = "Post and tag us on DSCVR"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false }
    ];

    // Define each individual achievement for Tiktok
    let indAchievementsTiktok: [IndividualAchievement] = [
        { id = 14; achievementId = 4; name = "Connect with Tiktok"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 15; achievementId = 4; name = "Follow us on Tiktok"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 16; achievementId = 4; name = "Like/Share/Comment on Tiktok"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 17; achievementId = 4; name = "Post and tag us on Tiktok"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false }
    ];

    // Define each individual achievement for Facebook
    let indAchievementsFacebook: [IndividualAchievement] = [
        { id = 18; achievementId = 5; name = "Connect with Facebook"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 19; achievementId = 5; name = "Follow us on Facebook"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 20; achievementId = 5; name = "Like/Share/Comment on Facebook"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 21; achievementId = 5; name = "Post and tag us on Facebook"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false }
    ];

    // Define each individual achievement for Instagram
    let indAchievementsInstagram: [IndividualAchievement] = [
        { id = 22; achievementId = 6; name = "Connect with Instagram"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 23; achievementId = 6; name = "Follow us on Instagram"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 24; achievementId = 6; name = "Like/Share/Comment on Instagram"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false },
        { id = 25; achievementId = 6; name = "Post and tag us on Instagram"; achievementType = #Social; requiredProgress = 1; completed = false; reward = indAchRewards; progress = 0; claimed = false }
    ];

    // Step 5: Define each individual achievement for the Referrals Program
    let indAchievementsReferrals: [IndividualAchievement] = [
        { id = 26; achievementId = 7; name = "1 Referral"; achievementType = #Social; requiredProgress = 1; completed = false; reward = [{ rewardType = #Stardust; amount = 10 }, { rewardType = #Chest; amount = 1; chestRarity = ?1 }, { rewardType = #XP; amount = 25 }]; progress = 0; claimed = false },
        { id = 27; achievementId = 7; name = "3 Referrals"; achievementType = #Social; requiredProgress = 3; completed = false; reward = [{ rewardType = #Stardust; amount = 35 }, { rewardType = #Chest; amount = 1; chestRarity = ?3 }, { rewardType = #XP; amount = 25 }]; progress = 0; claimed = false },
        { id = 28; achievementId = 7; name = "5 Referrals"; achievementType = #Social; requiredProgress = 5; completed = false; reward = [{ rewardType = #Stardust; amount = 75 }, { rewardType = #Chest; amount = 1; chestRarity = ?5 }, { rewardType = #XP; amount = 25 }]; progress = 0; claimed = false },
        { id = 29; achievementId = 7; name = "10 Referrals"; achievementType = #Social; requiredProgress = 10; completed = false; reward = [{ rewardType = #Stardust; amount = 150 }, { rewardType = #Chest; amount = 1; chestRarity = ?6 }, { rewardType = #XP; amount = 25 }]; progress = 0; claimed = false },
        { id = 30; achievementId = 7; name = "25 Referrals"; achievementType = #Social; requiredProgress = 25; completed = false; reward = [{ rewardType = #Stardust; amount = 500 }, { rewardType = #Chest; amount = 1; chestRarity = ?8 }, { rewardType = #XP; amount = 25 }]; progress = 0; claimed = false }
    ];

    // Step 6: Define all achievement lines including the Referrals Program
    let achievementLines: [AchievementLine] = [
        { id = 1; name = "Twitter"; individualAchievements = indAchievementsTwitter; categoryId = 1; reward = [{ rewardType = #Title; amount = 1; title = ?"Twitter Ambassador" }, { rewardType = #Stardust; amount = 100 }, { rewardType = #Chest; amount = 1; chestRarity = ?7 }, { rewardType = #XP; amount = 50 }]; requiredProgress = 4; completed = false; progress = 0; claimed = false },  // Twitter Ambassador title
        { id = 2; name = "Discord"; individualAchievements = indAchievementsDiscord; categoryId = 1; reward = [{ rewardType = #Title; amount = 1; title = ?"Discord Ambassador" }, { rewardType = #Stardust; amount = 100 }, { rewardType = #Chest; amount = 1; chestRarity = ?7 }, { rewardType = #XP; amount = 50 }]; requiredProgress = 5; completed = false; progress = 0; claimed = false },  // Discord Ambassador title
        { id = 3; name = "DSCVR"; individualAchievements = indAchievementsDSCVR; categoryId = 1; reward = [{ rewardType = #Title; amount = 1; title = ?"DSCVR Ambassador" }, { rewardType = #Stardust; amount = 100 }, { rewardType = #Chest; amount = 1; chestRarity = ?7 }, { rewardType = #XP; amount = 50 }]; requiredProgress = 4; completed = false; progress = 0; claimed = false },  // DSCVR Ambassador title
        { id = 4; name = "Tiktok"; individualAchievements = indAchievementsTiktok; categoryId = 1; reward = [{ rewardType = #Title; amount = 1; title = ?"Tiktok Ambassador" }, { rewardType = #Stardust; amount = 100 }, { rewardType = #Chest; amount = 1; chestRarity = ?7 }, { rewardType = #XP; amount = 50 }]; requiredProgress = 4; completed = false; progress = 0; claimed = false },  // Tiktok Ambassador title
        { id = 5; name = "Facebook"; individualAchievements = indAchievementsFacebook; categoryId = 1; reward = [{ rewardType = #Title; amount = 1; title = ?"Facebook Ambassador" }, { rewardType = #Stardust; amount = 100 }, { rewardType = #Chest; amount = 1; chestRarity = ?7 }, { rewardType = #XP; amount = 50 }]; requiredProgress = 4; completed = false; progress = 0; claimed = false },  // Facebook Ambassador title
        { id = 6; name = "Instagram"; individualAchievements = indAchievementsInstagram; categoryId = 1; reward = [{ rewardType = #Title; amount = 1; title = ?"Instagram Ambassador" }, { rewardType = #Stardust; amount = 100 }, { rewardType = #Chest; amount = 1; chestRarity = ?7 }, { rewardType = #XP; amount = 50 }]; requiredProgress = 4; completed = false; progress = 0; claimed = false },  // Instagram Ambassador title
        { id = 7; name = "Referrals Program"; individualAchievements = indAchievementsReferrals; categoryId = 1; reward = [{ rewardType = #Title; amount = 1; title = ?"Cosmicrafts Ambassador" }, { rewardType = #Avatar; amount = 1; avatar = ?98 }, { rewardType = #Stardust; amount = 1000 }, { rewardType = #Chest; amount = 1; chestRarity = ?10 }, { rewardType = #XP; amount = 1000 }]; requiredProgress = 5; completed = false; progress = 0; claimed = false }  // Cosmicrafts Ambassador title
    ];

    // Step 7: Define the category "Tiers"
    let categoryTiers: AchievementCategory = {
        id = 1;
        name = "Tiers";
        achievements = achievementLines;
        reward = categoryReward;
        requiredProgress = 7;  // Since we now have 7 achievement lines
        completed = false;
        progress = 0;
        claimed = false;
    };

    // Export the category
    public func getTiersCategory(): AchievementCategory {
        return categoryTiers;
    };
}
