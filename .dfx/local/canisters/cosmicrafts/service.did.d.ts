import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type Balance = bigint;
export interface Cosmicrafts {
  'claimReward' : ActorMethod<[bigint], [boolean, string]>,
  'createPlayer' : ActorMethod<[string], [boolean, string]>,
  'getAllPlayers' : ActorMethod<[], Array<Player>>,
  'getICPBalance' : ActorMethod<[], { 'e8s' : bigint }>,
  'getMyPlayerData' : ActorMethod<[], [] | [Player]>,
  'getNFTUpgradeCost' : ActorMethod<[], Balance>,
  'getPlayer' : ActorMethod<[], [] | [Player]>,
  'getPlayerData' : ActorMethod<[Principal], [] | [Player]>,
  'getPlayerElo' : ActorMethod<[Principal], number>,
  'getPlayerPreferences' : ActorMethod<[], [] | [PlayerPreferences]>,
  'getUserRewards' : ActorMethod<[], Array<RewardsUser>>,
  'mergeSkinNFTs' : ActorMethod<[bigint, bigint], [boolean, string]>,
  'mintChest' : ActorMethod<[Principal, bigint], [boolean, string]>,
  'mintDeck' : ActorMethod<[Principal, [bigint, bigint]], [boolean, string]>,
  'mintNFT' : ActorMethod<[Principal, bigint, bigint], [boolean, string]>,
  'openChests' : ActorMethod<[bigint], [boolean, string]>,
  'savePlayerChar' : ActorMethod<[string], [boolean, string]>,
  'savePlayerLanguage' : ActorMethod<[bigint], [boolean, string]>,
  'savePlayerName' : ActorMethod<[string], boolean>,
  'updatePlayerElo' : ActorMethod<[Principal, number], boolean>,
  'upgradeNFT' : ActorMethod<[TokenID], [boolean, string]>,
}
export type Level = bigint;
export interface Player {
  'id' : PlayerId,
  'elo' : number,
  'name' : PlayerName,
  'level' : Level,
}
export type PlayerId = Principal;
export type PlayerName = string;
export interface PlayerPreferences {
  'language' : bigint,
  'playerChar' : string,
}
export type PrizeType = { 'Flux' : null } |
  { 'Shards' : null } |
  { 'Chest' : null };
export type RewardType = { 'LevelReached' : null } |
  { 'GamesCompleted' : null } |
  { 'GamesWon' : null };
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
export type TokenID = bigint;
export interface _SERVICE extends Cosmicrafts {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: ({ IDL }: { IDL: IDL }) => IDL.Type[];
