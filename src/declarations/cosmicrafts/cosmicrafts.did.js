export const idlFactory = ({ IDL }) => {
  const UserID = IDL.Principal;
  const RewardType = IDL.Variant({
    'LevelReached' : IDL.Null,
    'GamesCompleted' : IDL.Null,
    'GamesWon' : IDL.Null,
  });
  const RewardProgress = IDL.Record({
    'progress' : IDL.Float64,
    'rewardType' : RewardType,
  });
  const PrizeType = IDL.Variant({
    'Flux' : IDL.Null,
    'Shards' : IDL.Null,
    'Chest' : IDL.Null,
  });
  const Reward = IDL.Record({
    'id' : IDL.Nat,
    'total' : IDL.Float64,
    'name' : IDL.Text,
    'end_date' : IDL.Nat64,
    'prize_amount' : IDL.Nat,
    'start_date' : IDL.Nat64,
    'rewardType' : RewardType,
    'prize_type' : PrizeType,
  });
  const Time = IDL.Int;
  const Tournament = IDL.Record({
    'id' : IDL.Nat,
    'participants' : IDL.Vec(IDL.Principal),
    'name' : IDL.Text,
    'isActive' : IDL.Bool,
    'expirationDate' : Time,
    'matchCounter' : IDL.Nat,
    'registeredParticipants' : IDL.Vec(IDL.Principal),
    'bracketCreated' : IDL.Bool,
    'prizePool' : IDL.Text,
    'startDate' : Time,
  });
  const StastisticsGameID = IDL.Nat;
  const BasicStats = IDL.Record({
    'secRemaining' : IDL.Float64,
    'energyGenerated' : IDL.Float64,
    'damageDealt' : IDL.Float64,
    'wonGame' : IDL.Bool,
    'botMode' : IDL.Nat,
    'deploys' : IDL.Float64,
    'damageTaken' : IDL.Float64,
    'damageCritic' : IDL.Float64,
    'damageEvaded' : IDL.Float64,
    'energyChargeRate' : IDL.Float64,
    'faction' : IDL.Nat,
    'energyUsed' : IDL.Float64,
    'gameMode' : IDL.Nat,
    'energyWasted' : IDL.Float64,
    'xpEarned' : IDL.Float64,
    'characterID' : IDL.Text,
    'botDifficulty' : IDL.Nat,
    'kills' : IDL.Float64,
  });
  const PlayerId = IDL.Principal;
  const PlayerName = IDL.Text;
  const Level = IDL.Nat;
  const Player = IDL.Record({
    'id' : PlayerId,
    'elo' : IDL.Float64,
    'name' : PlayerName,
    'level' : Level,
  });
  const MatchmakingStatus = IDL.Variant({
    'Ended' : IDL.Null,
    'Reserved' : IDL.Null,
    'Searching' : IDL.Null,
    'Accepted' : IDL.Null,
    'InGame' : IDL.Null,
    'Accepting' : IDL.Null,
  });
  const UserId = IDL.Principal;
  const PlayerInfo = IDL.Record({
    'id' : UserId,
    'elo' : IDL.Float64,
    'lastPlayerActive' : IDL.Nat64,
    'matchAccepted' : IDL.Bool,
    'playerGameData' : IDL.Text,
  });
  const MatchData = IDL.Record({
    'status' : MatchmakingStatus,
    'gameId' : IDL.Nat,
    'player1' : PlayerInfo,
    'player2' : IDL.Opt(PlayerInfo),
  });
  const RewardsUser = IDL.Record({
    'total' : IDL.Float64,
    'id_reward' : IDL.Nat,
    'prize_amount' : IDL.Nat,
    'start_date' : IDL.Nat64,
    'progress' : IDL.Float64,
    'finish_date' : IDL.Nat64,
    'expiration' : IDL.Nat64,
    'rewardType' : RewardType,
    'finished' : IDL.Bool,
    'prize_type' : PrizeType,
  });
  const AverageStats = IDL.Record({
    'averageDamageDealt' : IDL.Float64,
    'averageEnergyGenerated' : IDL.Float64,
    'averageEnergyUsed' : IDL.Float64,
    'averageKills' : IDL.Float64,
    'averageEnergyWasted' : IDL.Float64,
    'averageXpEarned' : IDL.Float64,
  });
  const SearchStatus = IDL.Variant({
    'Available' : IDL.Null,
    'NotAvailable' : IDL.Null,
    'Assigned' : IDL.Null,
  });
  const FullPlayerInfo = IDL.Record({
    'id' : UserId,
    'elo' : IDL.Float64,
    'playerName' : IDL.Text,
    'matchAccepted' : IDL.Bool,
    'playerGameData' : IDL.Text,
  });
  const FullMatchData = IDL.Record({
    'status' : MatchmakingStatus,
    'gameId' : IDL.Nat,
    'player1' : FullPlayerInfo,
    'player2' : IDL.Opt(FullPlayerInfo),
  });
  const GamesWithGameMode = IDL.Record({
    'gameModeID' : IDL.Nat,
    'gamesPlayed' : IDL.Nat,
    'gamesWon' : IDL.Nat,
  });
  const GamesWithCharacter = IDL.Record({
    'gamesPlayed' : IDL.Nat,
    'characterID' : IDL.Text,
    'gamesWon' : IDL.Nat,
  });
  const GamesWithFaction = IDL.Record({
    'gamesPlayed' : IDL.Nat,
    'gamesWon' : IDL.Nat,
    'factionID' : IDL.Nat,
  });
  const PlayerGamesStats = IDL.Record({
    'gamesLost' : IDL.Nat,
    'energyGenerated' : IDL.Float64,
    'gamesPlayed' : IDL.Nat,
    'totalGamesGameMode' : IDL.Vec(GamesWithGameMode),
    'totalDamageDealt' : IDL.Float64,
    'totalDamageCrit' : IDL.Float64,
    'totalDamageTaken' : IDL.Float64,
    'energyUsed' : IDL.Float64,
    'totalDamageEvaded' : IDL.Float64,
    'energyWasted' : IDL.Float64,
    'gamesWon' : IDL.Nat,
    'totalXpEarned' : IDL.Float64,
    'totalGamesWithCharacter' : IDL.Vec(GamesWithCharacter),
    'totalGamesWithFaction' : IDL.Vec(GamesWithFaction),
  });
  const OverallStats = IDL.Record({
    'totalEnergyGenerated' : IDL.Float64,
    'totalGamesMP' : IDL.Nat,
    'totalGamesSP' : IDL.Nat,
    'totalGamesGameMode' : IDL.Vec(GamesWithGameMode),
    'totalGamesPlayed' : IDL.Nat,
    'totalDamageDealt' : IDL.Float64,
    'totalEnergyUsed' : IDL.Float64,
    'totalTimePlayed' : IDL.Float64,
    'totalEnergyWasted' : IDL.Float64,
    'totalKills' : IDL.Float64,
    'totalXpEarned' : IDL.Float64,
    'totalGamesWithCharacter' : IDL.Vec(GamesWithCharacter),
    'totalGamesWithFaction' : IDL.Vec(GamesWithFaction),
  });
  const PlayerPreferences = IDL.Record({
    'language' : IDL.Nat,
    'playerChar' : IDL.Text,
  });
  const Match = IDL.Record({
    'id' : IDL.Nat,
    'status' : IDL.Text,
    'result' : IDL.Opt(
      IDL.Record({ 'winner' : IDL.Principal, 'score' : IDL.Text })
    ),
    'participants' : IDL.Vec(IDL.Principal),
    'nextMatchId' : IDL.Opt(IDL.Nat),
    'tournamentId' : IDL.Nat,
  });
  const Username = IDL.Text;
  const Description = IDL.Text;
  const RegistrationDate = IDL.Int;
  const AvatarID = IDL.Nat;
  const UserRecord = IDL.Record({
    'username' : Username,
    'userId' : UserID,
    'description' : Description,
    'registrationDate' : RegistrationDate,
    'friends' : IDL.Vec(UserID),
    'avatar' : AvatarID,
  });
  const FriendDetails = IDL.Record({
    'username' : Username,
    'userId' : UserID,
    'avatar' : AvatarID,
  });
  const UserDetails = IDL.Record({
    'user' : UserRecord,
    'friends' : IDL.Vec(FriendDetails),
  });
  const PlayerID = IDL.Principal;
  const TokenID = IDL.Nat;
  const Cosmicrafts = IDL.Service({
    'addFriend' : IDL.Func([UserID], [IDL.Bool, IDL.Text], []),
    'addProgressToRewards' : IDL.Func(
        [IDL.Principal, IDL.Vec(RewardProgress)],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'addReward' : IDL.Func([Reward], [IDL.Bool, IDL.Text, IDL.Nat], []),
    'adminUpdateMatch' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Nat, IDL.Text],
        [IDL.Bool],
        [],
      ),
    'cancelMatchmaking' : IDL.Func([], [IDL.Bool, IDL.Text], []),
    'claimReward' : IDL.Func([IDL.Nat], [IDL.Bool, IDL.Text], []),
    'claimedReward' : IDL.Func(
        [IDL.Principal, IDL.Nat],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'createPlayer' : IDL.Func([IDL.Text], [IDL.Bool, IDL.Text], []),
    'createReward' : IDL.Func(
        [IDL.Text, RewardType, PrizeType, IDL.Nat, IDL.Float64, IDL.Nat64],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'createTournament' : IDL.Func(
        [IDL.Text, Time, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'deleteAllTournaments' : IDL.Func([], [IDL.Bool], []),
    'disputeMatch' : IDL.Func([IDL.Nat, IDL.Nat, IDL.Text], [IDL.Bool], []),
    'generateUUID64' : IDL.Func([], [IDL.Nat], []),
    'getActiveTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getAllActiveRewards' : IDL.Func([], [IDL.Nat, IDL.Vec(Reward)], ['query']),
    'getAllOnValidation' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(StastisticsGameID, BasicStats))],
        ['query'],
      ),
    'getAllPlayers' : IDL.Func([], [IDL.Vec(Player)], ['query']),
    'getAllSearching' : IDL.Func([], [IDL.Vec(MatchData)], ['query']),
    'getAllTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getAllUsersRewards' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Vec(RewardsUser)))],
        ['query'],
      ),
    'getAverageStats' : IDL.Func([], [AverageStats], ['query']),
    'getBasicStats' : IDL.Func(
        [StastisticsGameID],
        [IDL.Opt(BasicStats)],
        ['query'],
      ),
    'getFriendsList' : IDL.Func([], [IDL.Opt(IDL.Vec(UserID))], ['query']),
    'getICPBalance' : IDL.Func([], [IDL.Record({ 'e8s' : IDL.Nat64 })], []),
    'getInactiveTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getMatchData' : IDL.Func([IDL.Nat], [IDL.Opt(MatchData)], ['query']),
    'getMatchSearching' : IDL.Func(
        [IDL.Text],
        [SearchStatus, IDL.Nat, IDL.Text],
        [],
      ),
    'getMyAverageStats' : IDL.Func([], [IDL.Opt(AverageStats)], ['query']),
    'getMyMatchData' : IDL.Func(
        [],
        [IDL.Opt(FullMatchData), IDL.Nat],
        ['composite_query'],
      ),
    'getMyPlayerData' : IDL.Func([], [IDL.Opt(Player)], ['query']),
    'getMyStats' : IDL.Func([], [IDL.Opt(PlayerGamesStats)], ['query']),
    'getOverallStats' : IDL.Func([], [OverallStats], ['query']),
    'getPlayer' : IDL.Func([], [IDL.Opt(Player)], []),
    'getPlayerAverageStats' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(AverageStats)],
        ['query'],
      ),
    'getPlayerData' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(Player)],
        ['composite_query'],
      ),
    'getPlayerElo' : IDL.Func([IDL.Principal], [IDL.Float64], ['query']),
    'getPlayerPreferences' : IDL.Func([], [IDL.Opt(PlayerPreferences)], []),
    'getPlayerStats' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(PlayerGamesStats)],
        ['query'],
      ),
    'getRegisteredUsers' : IDL.Func(
        [IDL.Nat],
        [IDL.Vec(IDL.Principal)],
        ['query'],
      ),
    'getReward' : IDL.Func([IDL.Nat], [IDL.Opt(Reward)], ['query']),
    'getTournamentBracket' : IDL.Func(
        [IDL.Nat],
        [IDL.Record({ 'matches' : IDL.Vec(Match) })],
        ['query'],
      ),
    'getUserDetails' : IDL.Func([UserID], [IDL.Opt(UserDetails)], ['query']),
    'getUserReward' : IDL.Func(
        [PlayerID, IDL.Nat],
        [IDL.Opt(RewardsUser)],
        ['query'],
      ),
    'isGameMatched' : IDL.Func([], [IDL.Bool, IDL.Text], ['query']),
    'joinTournament' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'mergeSkinNFTs' : IDL.Func([IDL.Nat, IDL.Nat], [IDL.Bool, IDL.Text], []),
    'mintChest' : IDL.Func([IDL.Principal, IDL.Nat], [IDL.Bool, IDL.Text], []),
    'mintDeck' : IDL.Func([IDL.Principal], [IDL.Bool, IDL.Text], []),
    'mintNFT' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'mintTokens' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'openChests' : IDL.Func([IDL.Nat], [IDL.Bool, IDL.Text], []),
    'registerUser' : IDL.Func([Username, AvatarID], [IDL.Bool, UserID], []),
    'saveFinishedGame' : IDL.Func(
        [StastisticsGameID, BasicStats],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'savePlayerChar' : IDL.Func([IDL.Text], [IDL.Bool, IDL.Text], []),
    'savePlayerLanguage' : IDL.Func([IDL.Nat], [IDL.Bool, IDL.Text], []),
    'savePlayerName' : IDL.Func([IDL.Text], [IDL.Bool], []),
    'searchUserByPrincipal' : IDL.Func(
        [UserID],
        [IDL.Opt(UserRecord)],
        ['query'],
      ),
    'searchUserByUsername' : IDL.Func(
        [Username],
        [IDL.Vec(UserRecord)],
        ['query'],
      ),
    'setGameOver' : IDL.Func(
        [IDL.Principal],
        [IDL.Bool, IDL.Bool, IDL.Opt(IDL.Principal)],
        [],
      ),
    'setGameValid' : IDL.Func([StastisticsGameID], [IDL.Bool], []),
    'setPlayerActive' : IDL.Func([], [IDL.Bool], []),
    'submitFeedback' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'submitMatchResult' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Text],
        [IDL.Bool],
        [],
      ),
    'updateAvatar' : IDL.Func([AvatarID], [IDL.Bool, UserID], []),
    'updateBracket' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'updateBracketAfterMatchUpdate' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Principal],
        [],
        [],
      ),
    'updateDescription' : IDL.Func([Description], [IDL.Bool, UserID], []),
    'updatePlayerElo' : IDL.Func([IDL.Principal, IDL.Float64], [IDL.Bool], []),
    'updateUsername' : IDL.Func([Username], [IDL.Bool, UserID], []),
    'upgradeNFT' : IDL.Func([TokenID], [IDL.Bool, IDL.Text], []),
    'validateGame' : IDL.Func(
        [IDL.Float64, IDL.Float64, IDL.Float64, IDL.Float64],
        [IDL.Bool, IDL.Text],
        ['query'],
      ),
  });
  return Cosmicrafts;
};
export const init = ({ IDL }) => { return []; };
