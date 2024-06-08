export const idlFactory = ({ IDL }) => {
  const PlayerId = IDL.Principal;
  const PlayerName = IDL.Text;
  const Level = IDL.Nat;
  const Player = IDL.Record({
    'id' : PlayerId,
    'elo' : IDL.Float64,
    'name' : PlayerName,
    'level' : Level,
  });
  const Balance = IDL.Nat;
  const PlayerPreferences = IDL.Record({
    'language' : IDL.Nat,
    'playerChar' : IDL.Text,
  });
  const RewardType = IDL.Variant({
    'LevelReached' : IDL.Null,
    'GamesCompleted' : IDL.Null,
    'GamesWon' : IDL.Null,
  });
  const PrizeType = IDL.Variant({
    'Flux' : IDL.Null,
    'Shards' : IDL.Null,
    'Chest' : IDL.Null,
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
  const TokenID = IDL.Nat;
  const Cosmicrafts = IDL.Service({
    'claimReward' : IDL.Func([IDL.Nat], [IDL.Bool, IDL.Text], []),
    'createPlayer' : IDL.Func([IDL.Text], [IDL.Bool, IDL.Text], []),
    'getAllPlayers' : IDL.Func([], [IDL.Vec(Player)], ['query']),
    'getICPBalance' : IDL.Func([], [IDL.Record({ 'e8s' : IDL.Nat64 })], []),
    'getMyPlayerData' : IDL.Func([], [IDL.Opt(Player)], ['query']),
    'getNFTUpgradeCost' : IDL.Func([], [Balance], ['query']),
    'getPlayer' : IDL.Func([], [IDL.Opt(Player)], []),
    'getPlayerData' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(Player)],
        ['composite_query'],
      ),
    'getPlayerElo' : IDL.Func([IDL.Principal], [IDL.Float64], ['query']),
    'getPlayerPreferences' : IDL.Func([], [IDL.Opt(PlayerPreferences)], []),
    'getUserRewards' : IDL.Func([], [IDL.Vec(RewardsUser)], []),
    'mergeSkinNFTs' : IDL.Func([IDL.Nat, IDL.Nat], [IDL.Bool, IDL.Text], []),
    'mintChest' : IDL.Func([IDL.Principal, IDL.Nat], [IDL.Bool, IDL.Text], []),
    'mintDeck' : IDL.Func([IDL.Principal], [IDL.Bool, IDL.Text], []),
    'mintNFT' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'openChests' : IDL.Func([IDL.Nat], [IDL.Bool, IDL.Text], []),
    'savePlayerChar' : IDL.Func([IDL.Text], [IDL.Bool, IDL.Text], []),
    'savePlayerLanguage' : IDL.Func([IDL.Nat], [IDL.Bool, IDL.Text], []),
    'savePlayerName' : IDL.Func([IDL.Text], [IDL.Bool], []),
    'updatePlayerElo' : IDL.Func([IDL.Principal, IDL.Float64], [IDL.Bool], []),
    'upgradeNFT' : IDL.Func([TokenID], [IDL.Bool, IDL.Text], []),
  });
  return Cosmicrafts;
};
export const init = ({ IDL }) => { return []; };
