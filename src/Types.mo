import Time "mo:base/Time";

module Types {
// General Types
  public type PlayerId = Principal;
  public type Username = Text;
  public type AvatarID = Nat;
  public type Description = Text;
  public type RegistrationDate = Time.Time;
  public type Level = Nat;
  public type MatchID = Nat;
  public type TokenID = Nat;
  public type Title = Text;

  public type MatchResult = Text;
  public type MatchMap = Text;
  public type PlayerFaction = Text;

// Player and Friend Details
  public type Player = {
    id: PlayerId;
    username: Username;
    avatar: AvatarID;
    title: Title;
    description: Description;
    registrationDate: RegistrationDate;
    level: Level;
    elo: Float;
    friends: [FriendDetails];
  };

  public type FriendDetails = {
    playerId: PlayerId;
    username: Username;
    avatar: AvatarID;
  };

  public type FriendRequest = {
      from: PlayerId;
      to: PlayerId;
      timestamp: Int;
  };
  public type MutualFriendship = {
      friend1: PlayerId;
      friend2: PlayerId;
      friendsSince: Int;
  };

  public type PrivacySetting = {
    #acceptAll;
    #blockAll;
    #friendsOfFriends
  };

  public type Notification = {
    from: PlayerId;
    message: Text;
    timestamp: Time.Time;
  };

  public type UpdateTimestamps = {
      avatar: Nat64;
      description: Nat64;
      username: Nat64;
  };



// Statistics
  public type PlayerStats = {
    playerId: PlayerId;
    energyUsed: Nat;
    energyGenerated: Nat;
    energyWasted: Nat;
    energyChargeRate: Nat;
    xpEarned: Nat;
    damageDealt: Nat;
    damageTaken: Nat;
    damageCritic: Nat;
    damageEvaded: Nat;
    kills: Nat;
    deploys: Nat;
    secRemaining: Nat;
    wonGame: Bool;
    faction: Nat;
    characterID: Nat;
    gameMode: Nat;
    botMode: Nat;
    botDifficulty: Nat;
  };

  public type BasicStats = {
    playerStats: [PlayerStats];
  };

  public type PlayerGamesStats = {
    gamesPlayed: Nat;
    gamesWon: Nat;
    gamesLost: Nat;
    energyGenerated: Nat;
    energyUsed: Nat;
    energyWasted: Nat;
    totalKills: Nat;
    totalDamageDealt: Nat;
    totalDamageTaken: Nat;
    totalDamageCrit: Nat;
    totalDamageEvaded: Nat;
    totalXpEarned: Nat;
    totalGamesWithFaction: [GamesWithFaction];
    totalGamesGameMode: [GamesWithGameMode];
    totalGamesWithCharacter: [GamesWithCharacter];
  };

  public type GamesWithFaction = {
    factionID: Nat;
    gamesPlayed: Nat;
    gamesWon: Nat;
  };

  public type GamesWithGameMode = {
    gameModeID: Nat;
    gamesPlayed: Nat;
    gamesWon: Nat;
  };

  public type GamesWithCharacter = {
    characterID: Nat;
    gamesPlayed: Nat;
    gamesWon: Nat;
  };

  public type AverageStats = {
    averageEnergyGenerated: Nat;
    averageEnergyUsed: Nat;
    averageEnergyWasted: Nat;
    averageDamageDealt: Nat;
    averageKills: Nat;
    averageXpEarned: Nat;
  };

  public type OverallStats = {
    totalGamesPlayed: Nat;
    totalGamesSP: Nat;
    totalGamesMP: Nat;
    totalDamageDealt: Nat;
    totalTimePlayed: Nat;
    totalKills: Nat;
    totalEnergyGenerated: Nat;
    totalEnergyUsed: Nat;
    totalEnergyWasted: Nat;
    totalXpEarned: Nat;
    totalGamesWithFaction: [OverallGamesWithFaction];
    totalGamesGameMode: [OverallGamesWithGameMode];
    totalGamesWithCharacter: [OverallGamesWithCharacter];
  };

    public type OverallGamesWithFaction = {
    factionID: Nat;
    gamesPlayed: Nat;
  };

  public type OverallGamesWithGameMode = {
    gameModeID: Nat;
    gamesPlayed: Nat;
  };

  public type OverallGamesWithCharacter = {
    characterID: Nat;
    gamesPlayed: Nat;
  };
//--
// Matchmaking
  public type MMInfo = {
    id: PlayerId;
    matchAccepted: Bool;
    elo: Float;
    playerGameData: PlayerGameData;
    lastPlayerActive: Nat64;
    username: Username;
  };

  public type MMStatus = {
    #Searching;
    #Reserved;
    #Accepting;
    #Accepted;
    #InGame;
    #Ended;
  };

  public type MMSearchStatus = {
    #Assigned;
    #Available;
    #NotAvailable;
  };

  public type MMPlayerStatus = {
    status: MMStatus;
    matchID: MatchID;
  };

  public type MatchData = {
    matchID: MatchID;
    player1: MMInfo;
    player2: ?MMInfo;
    status: MMStatus;
  };

  public type FullMatchData = {
    matchID: MatchID;
    player1: {
      id: PlayerId;
      username: Username;
      avatar: AvatarID;
      level: Level;
      matchAccepted: Bool;
      elo: Float;
      playerGameData: PlayerGameData;
    };
    player2: ?{
      id: PlayerId;
      username: Username;
      avatar: AvatarID;
      level: Level;
      matchAccepted: Bool;
      elo: Float;
      playerGameData: PlayerGameData;
    };
    status: MMStatus;
  };
//--
// Match History
  public type MatchOpt = {
    #Ranked;
    #Normal;
    #Tournament;
  };

  public type PlayerRecord = {
    playerId: Principal;
    faction: PlayerFaction;
  };

  public type MatchRecord = {
    matchID: MatchID;
    map: MatchMap;
    team1: [PlayerRecord];
    team2: [PlayerRecord];
    faction1: [PlayerFaction];
    faction2: [PlayerFaction];
    result: MatchResult;
    timestamp: Time.Time;
    mode: MatchOpt;
  };

  public type PlayerGameData = {
      deck: [Nat]; // Array of token IDs
      // Add other relevant fields here if necessary
  };
//--
// Missions
  public type MissionType = {
    #GamesCompleted;
    #GamesWon;
    #DamageDealt;
    #DamageTaken;
    #EnergyUsed;
    #UnitsDeployed;
    #FactionPlayed;
    #GameModePlayed;
    #XPEarned;
    #Kills;
  };

  public type MissionRewardType = {
    #Chest;
    #Stardust;
   // #NFTXP;
  };

  public type MissionOption = {
    MissionType: MissionType;
    minAmount: Nat;
    maxAmount: Nat;
    rarity: Nat;
  };

  public type Mission = {
    id: Nat;
    missionCategory: MissionCategory;
    missionType: MissionType;
    name: Text;
    reward_type: MissionRewardType;
    reward_amount: Nat;
    start_date: Nat64;
    end_date: Nat64;
    total: Nat;
  };

  public type MissionCategory = {
    #Weekly;
    #Daily;
    #Hourly;
    #Free;
    #Achievement;
  };

  public type MissionsUser = {
    id_mission: Nat;
    missionCategory: MissionCategory;
    total: Nat;
    progress: Nat;
    finished: Bool;
    finish_date: Nat64;
    start_date: Nat64;
    expiration: Nat64;
    missionType: MissionType;
    reward_type: MissionRewardType;
    reward_amount: Nat;
  };

  public type MissionProgress = {
    missionType: MissionType;
    progress: Nat;
  };

  public type MissionTemplate = {
      name: Text;
      missionCategory: MissionCategory;
      missionType: MissionType;
      rewardType: MissionRewardType;
      minReward: Nat;
      maxReward: Nat;
      total: Nat;
      hoursActive: Nat64;
  };

  public type RewardPool = {
    chestRarity: (Nat, Nat);
    stardust: (Nat, Nat);
  };
  
//--
//Achievements
 
    // Individual Achievement relates to a single mission, e.g., "Play 3 games."
    public type IndividualAchievement = {
        id: Nat;
        name: Text;
        achievementType: AchievementType;
        requiredProgress: Nat;
        progress: Nat;
        completed: Bool;
        reward: [AchievementReward]; // Allowing multiple rewards
        achievementId: Nat; // Link to the general achievement
    };

    // Achievement represents a type of achievement, e.g., "Games Played."
    public type Achievement = {
        id: Nat;
        name: Text;
        individualAchievements: [Nat]; // List of related individual achievements
        tier: AchievementTier;
        progress: Nat;
        requiredProgress: Nat; // Total progress required to complete this achievement
        categoryId: Nat; // Link to the category
        reward: [AchievementReward]; // Allowing multiple rewards
        completed: Bool; // Field added to track completion status
    };

    // Achievement Category represents a grouping of achievements, e.g., "Progression."
    public type AchievementCategory = {
        id: Nat;
        name: Text;
        achievements: [Nat]; // List of related achievements
        tier: AchievementTier;
        progress: Nat;
        requiredProgress: Nat; // Total progress required to complete this category
        reward: [AchievementReward]; // Allowing multiple rewards
        completed: Bool; // Field added to track completion status
    };

    // Achievement Type
    public type AchievementType = {
        #Combat : CombatAchievementType;
        #Social : SocialAchievementType;
        #Resource : ResourceAchievementType;
        #Misc : MiscAchievementType;
    };

      public type CombatAchievementType = {
      #DamageDealt;
      #DamageTaken;
      #EnergyUsed;
      #FactionPlayed;
      #GameModePlayed;
      #GamesCompleted;
      #GamesWon;
      #Kills;
      #UnitsDeployed;
      #XPEarned;
      #GamesWithCharacter;
      #GamesWithFaction;
      #GamesPlayed;
  };

  public type SocialAchievementType = {
      #AchievementsUnlocked;
      #Friends;
      #SomeBullshit;
  };

  public type ResourceAchievementType = {
      #ChestsMinted;
      #ChestsOpened;
      #FluxMinted;
      #NFTsMinted;
      #ShardsMinted;
      #RewardsClaimed;
      #UpgradeNFT;
  };

  public type MiscAchievementType = {
      #Customization;
      #LevelReached;
      #TimePlayed;
      #UserMissionsCompleted;
      #DailyMissionsCompleted;
      #WeeklyMissionsCompleted;
      #ChangeAvatar
  };

    // Achievement Reward Types
    public type AchievementRewardsType = {
        #Stardust;
        #Chest;
    };

    // Achievement Reward
    public type AchievementReward = {
        rewardType: AchievementRewardsType;
        amount: Nat;
    };

    // Achievement Tier
    public type AchievementTier = {
        #Bronze;
        #Silver;
        #Gold;
        #Platinum;
        #Diamond;
        #Master;
        #Legend;
    };

  public type AchievementProgress = {
        achievementId: Nat;
        playerId: PlayerId;
        progress: Nat;
        completed: Bool;
    };

}
