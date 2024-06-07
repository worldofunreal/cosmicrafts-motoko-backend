import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type PlayerID = Principal;
export type PrizeType = { 'Flux' : null } |
  { 'Shards' : null } |
  { 'Chest' : null };
export interface Reward {
  'id' : bigint,
  'total' : number,
  'name' : string,
  'end_date' : bigint,
  'prize_amount' : bigint,
  'start_date' : bigint,
  'rewardType' : RewardType,
  'prize_type' : PrizeType,
}
export interface RewardProgress {
  'progress' : number,
  'rewardType' : RewardType,
}
export type RewardType = { 'LevelReached' : null } |
  { 'GamesCompleted' : null } |
  { 'GamesWon' : null };
export interface Rewards {
  'addProgressToRewards' : ActorMethod<
    [Principal, Array<RewardProgress>],
    [boolean, string]
  >,
  'addReward' : ActorMethod<[Reward], [boolean, string, bigint]>,
  'claimedReward' : ActorMethod<[Principal, bigint], [boolean, string]>,
  'createReward' : ActorMethod<
    [string, RewardType, PrizeType, bigint, number, bigint],
    [boolean, string]
  >,
  'getAllActiveRewards' : ActorMethod<[], [bigint, Array<Reward>]>,
  'getAllUsersRewards' : ActorMethod<
    [],
    Array<[Principal, Array<RewardsUser>]>
  >,
  'getReward' : ActorMethod<[bigint], [] | [Reward]>,
  'getUserReward' : ActorMethod<[PlayerID, bigint], [] | [RewardsUser]>,
  'getUserRewards' : ActorMethod<[Principal], Array<RewardsUser>>,
}
export interface RewardsUser {
  'total' : number,
  'id_reward' : bigint,
  'prize_amount' : bigint,
  'start_date' : bigint,
  'progress' : number,
  'finish_date' : bigint,
  'expiration' : bigint,
  'rewardType' : RewardType,
  'finished' : boolean,
  'prize_type' : PrizeType,
}
export interface _SERVICE extends Rewards {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: ({ IDL }: { IDL: IDL }) => IDL.Type[];
