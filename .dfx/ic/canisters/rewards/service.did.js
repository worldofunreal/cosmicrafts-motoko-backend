export const idlFactory = ({ IDL }) => {
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
  const PlayerID = IDL.Principal;
  const Rewards = IDL.Service({
    'addProgressToRewards' : IDL.Func(
        [IDL.Principal, IDL.Vec(RewardProgress)],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'addReward' : IDL.Func([Reward], [IDL.Bool, IDL.Text, IDL.Nat], []),
    'claimedReward' : IDL.Func(
        [IDL.Principal, IDL.Nat],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'createReward' : IDL.Func(
        [IDL.Text, RewardType, PrizeType, IDL.Nat, IDL.Float64, IDL.Nat64],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'getAllActiveRewards' : IDL.Func([], [IDL.Nat, IDL.Vec(Reward)], ['query']),
    'getAllUsersRewards' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Vec(RewardsUser)))],
        ['query'],
      ),
    'getReward' : IDL.Func([IDL.Nat], [IDL.Opt(Reward)], ['query']),
    'getUserReward' : IDL.Func(
        [PlayerID, IDL.Nat],
        [IDL.Opt(RewardsUser)],
        ['query'],
      ),
    'getUserRewards' : IDL.Func([IDL.Principal], [IDL.Vec(RewardsUser)], []),
  });
  return Rewards;
};
export const init = ({ IDL }) => { return []; };
