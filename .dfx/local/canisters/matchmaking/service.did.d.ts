import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface FullMatchData {
  'status' : MatchmakingStatus,
  'gameId' : bigint,
  'player1' : FullPlayerInfo,
  'player2' : [] | [FullPlayerInfo],
}
export interface FullPlayerInfo {
  'id' : UserId,
  'elo' : number,
  'playerName' : string,
  'matchAccepted' : boolean,
  'playerGameData' : string,
}
export interface MatchData {
  'status' : MatchmakingStatus,
  'gameId' : bigint,
  'player1' : PlayerInfo,
  'player2' : [] | [PlayerInfo],
}
export type MatchmakingStatus = { 'Ended' : null } |
  { 'Reserved' : null } |
  { 'Searching' : null } |
  { 'Accepted' : null } |
  { 'InGame' : null } |
  { 'Accepting' : null };
export interface PlayerInfo {
  'id' : UserId,
  'elo' : number,
  'lastPlayerActive' : bigint,
  'matchAccepted' : boolean,
  'playerGameData' : string,
}
export interface PlayersCanister {
  'cancelMatchmaking' : ActorMethod<[], [boolean, string]>,
  'getAllSearching' : ActorMethod<[], Array<MatchData>>,
  'getMatchData' : ActorMethod<[bigint], [] | [MatchData]>,
  'getMatchSearching' : ActorMethod<[string], [SearchStatus, bigint, string]>,
  'getMyMatchData' : ActorMethod<[], [[] | [FullMatchData], bigint]>,
  'isGameMatched' : ActorMethod<[], [boolean, string]>,
  'setGameOver' : ActorMethod<
    [Principal],
    [boolean, boolean, [] | [Principal]]
  >,
  'setPlayerActive' : ActorMethod<[], boolean>,
}
export type SearchStatus = { 'Available' : null } |
  { 'NotAvailable' : null } |
  { 'Assigned' : null };
export type UserId = Principal;
export interface _SERVICE extends PlayersCanister {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
