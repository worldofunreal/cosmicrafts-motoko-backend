import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AvatarID = bigint;
export interface AverageStats {
  'averageDamageDealt' : number,
  'averageEnergyGenerated' : number,
  'averageEnergyUsed' : number,
  'averageKills' : number,
  'averageEnergyWasted' : number,
  'averageXpEarned' : number,
}
export interface BasicStats {
  'secRemaining' : number,
  'energyGenerated' : number,
  'damageDealt' : number,
  'wonGame' : boolean,
  'botMode' : bigint,
  'deploys' : number,
  'damageTaken' : number,
  'damageCritic' : number,
  'damageEvaded' : number,
  'energyChargeRate' : number,
  'faction' : bigint,
  'energyUsed' : number,
  'gameMode' : bigint,
  'energyWasted' : number,
  'xpEarned' : number,
  'characterID' : string,
  'botDifficulty' : bigint,
  'kills' : number,
}
export interface Cosmicrafts {
  'addFriend' : ActorMethod<[UserID], [boolean, string]>,
  'addProgressToRewards' : ActorMethod<
    [Principal, Array<RewardProgress>],
    [boolean, string]
  >,
  'addReward' : ActorMethod<[Reward], [boolean, string, bigint]>,
  'adminUpdateMatch' : ActorMethod<[bigint, bigint, bigint, string], boolean>,
  'cancelMatchmaking' : ActorMethod<[], [boolean, string]>,
  'claimReward' : ActorMethod<[bigint], [boolean, string]>,
  'claimedReward' : ActorMethod<[Principal, bigint], [boolean, string]>,
  'createPlayer' : ActorMethod<[string], [boolean, string]>,
  'createReward' : ActorMethod<
    [string, RewardType, PrizeType, bigint, number, bigint],
    [boolean, string]
  >,
  'createTournament' : ActorMethod<[string, Time, string, Time], bigint>,
  'deleteAllTournaments' : ActorMethod<[], boolean>,
  'disputeMatch' : ActorMethod<[bigint, bigint, string], boolean>,
  'generateUUID64' : ActorMethod<[], bigint>,
  'getActiveTournaments' : ActorMethod<[], Array<Tournament>>,
  'getAllActiveRewards' : ActorMethod<[], [bigint, Array<Reward>]>,
  'getAllOnValidation' : ActorMethod<
    [],
    Array<[StastisticsGameID, BasicStats]>
  >,
  'getAllPlayers' : ActorMethod<[], Array<Player>>,
  'getAllSearching' : ActorMethod<[], Array<MatchData>>,
  'getAllTournaments' : ActorMethod<[], Array<Tournament>>,
  'getAllUsersRewards' : ActorMethod<
    [],
    Array<[Principal, Array<RewardsUser>]>
  >,
  'getAverageStats' : ActorMethod<[], AverageStats>,
  'getBasicStats' : ActorMethod<[StastisticsGameID], [] | [BasicStats]>,
  'getFriendsList' : ActorMethod<[], [] | [Array<UserID>]>,
  'getICPBalance' : ActorMethod<[], { 'e8s' : bigint }>,
  'getInactiveTournaments' : ActorMethod<[], Array<Tournament>>,
  'getMatchData' : ActorMethod<[bigint], [] | [MatchData]>,
  'getMatchSearching' : ActorMethod<[string], [SearchStatus, bigint, string]>,
  'getMyAverageStats' : ActorMethod<[], [] | [AverageStats]>,
  'getMyMatchData' : ActorMethod<[], [[] | [FullMatchData], bigint]>,
  'getMyPlayerData' : ActorMethod<[], [] | [Player]>,
  'getMyStats' : ActorMethod<[], [] | [PlayerGamesStats]>,
  'getOverallStats' : ActorMethod<[], OverallStats>,
  'getPlayer' : ActorMethod<[], [] | [Player]>,
  'getPlayerAverageStats' : ActorMethod<[Principal], [] | [AverageStats]>,
  'getPlayerData' : ActorMethod<[Principal], [] | [Player]>,
  'getPlayerElo' : ActorMethod<[Principal], number>,
  'getPlayerPreferences' : ActorMethod<[], [] | [PlayerPreferences]>,
  'getPlayerStats' : ActorMethod<[Principal], [] | [PlayerGamesStats]>,
  'getRegisteredUsers' : ActorMethod<[bigint], Array<Principal>>,
  'getReward' : ActorMethod<[bigint], [] | [Reward]>,
  'getTournamentBracket' : ActorMethod<[bigint], { 'matches' : Array<Match> }>,
  'getUserDetails' : ActorMethod<[UserID], [] | [UserDetails]>,
  'getUserReward' : ActorMethod<[PlayerID, bigint], [] | [RewardsUser]>,
  'isGameMatched' : ActorMethod<[], [boolean, string]>,
  'joinTournament' : ActorMethod<[bigint], boolean>,
  'mergeSkinNFTs' : ActorMethod<[bigint, bigint], [boolean, string]>,
  'mintChest' : ActorMethod<[Principal, bigint], [boolean, string]>,
  'mintDeck' : ActorMethod<[Principal], [boolean, string]>,
  'mintNFT' : ActorMethod<[Principal, bigint, bigint], [boolean, string]>,
  'mintTokens' : ActorMethod<[Principal, bigint, bigint], [boolean, string]>,
  'openChests' : ActorMethod<[bigint], [boolean, string]>,
  'registerUser' : ActorMethod<[Username, AvatarID], [boolean, UserID]>,
  'saveFinishedGame' : ActorMethod<
    [StastisticsGameID, BasicStats],
    [boolean, string]
  >,
  'savePlayerChar' : ActorMethod<[string], [boolean, string]>,
  'savePlayerLanguage' : ActorMethod<[bigint], [boolean, string]>,
  'savePlayerName' : ActorMethod<[string], boolean>,
  'searchUserByPrincipal' : ActorMethod<[UserID], [] | [UserRecord]>,
  'searchUserByUsername' : ActorMethod<[Username], Array<UserRecord>>,
  'setGameOver' : ActorMethod<
    [Principal],
    [boolean, boolean, [] | [Principal]]
  >,
  'setGameValid' : ActorMethod<[StastisticsGameID], boolean>,
  'setPlayerActive' : ActorMethod<[], boolean>,
  'submitFeedback' : ActorMethod<[bigint, string], boolean>,
  'submitMatchResult' : ActorMethod<[bigint, bigint, string], boolean>,
  'updateAvatar' : ActorMethod<[AvatarID], [boolean, UserID]>,
  'updateBracket' : ActorMethod<[bigint], boolean>,
  'updateBracketAfterMatchUpdate' : ActorMethod<
    [bigint, bigint, Principal],
    undefined
  >,
  'updateDescription' : ActorMethod<[Description], [boolean, UserID]>,
  'updatePlayerElo' : ActorMethod<[Principal, number], boolean>,
  'updateUsername' : ActorMethod<[Username], [boolean, UserID]>,
  'upgradeNFT' : ActorMethod<[TokenID], [boolean, string]>,
  'validateGame' : ActorMethod<
    [number, number, number, number],
    [boolean, string]
  >,
}
export type Description = string;
export interface FriendDetails {
  'username' : Username,
  'userId' : UserID,
  'avatar' : AvatarID,
}
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
export interface GamesWithCharacter {
  'gamesPlayed' : bigint,
  'characterID' : string,
  'gamesWon' : bigint,
}
export interface GamesWithFaction {
  'gamesPlayed' : bigint,
  'gamesWon' : bigint,
  'factionID' : bigint,
}
export interface GamesWithGameMode {
  'gameModeID' : bigint,
  'gamesPlayed' : bigint,
  'gamesWon' : bigint,
}
export type Level = bigint;
export interface Match {
  'id' : bigint,
  'status' : string,
  'result' : [] | [{ 'winner' : Principal, 'score' : string }],
  'participants' : Array<Principal>,
  'nextMatchId' : [] | [bigint],
  'tournamentId' : bigint,
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
export interface OverallStats {
  'totalEnergyGenerated' : number,
  'totalGamesMP' : bigint,
  'totalGamesSP' : bigint,
  'totalGamesGameMode' : Array<GamesWithGameMode>,
  'totalGamesPlayed' : bigint,
  'totalDamageDealt' : number,
  'totalEnergyUsed' : number,
  'totalTimePlayed' : number,
  'totalEnergyWasted' : number,
  'totalKills' : number,
  'totalXpEarned' : number,
  'totalGamesWithCharacter' : Array<GamesWithCharacter>,
  'totalGamesWithFaction' : Array<GamesWithFaction>,
}
export interface Player {
  'id' : PlayerId,
  'elo' : number,
  'name' : PlayerName,
  'level' : Level,
}
export interface PlayerGamesStats {
  'gamesLost' : bigint,
  'energyGenerated' : number,
  'gamesPlayed' : bigint,
  'totalGamesGameMode' : Array<GamesWithGameMode>,
  'totalDamageDealt' : number,
  'totalDamageCrit' : number,
  'totalDamageTaken' : number,
  'energyUsed' : number,
  'totalDamageEvaded' : number,
  'energyWasted' : number,
  'gamesWon' : bigint,
  'totalXpEarned' : number,
  'totalGamesWithCharacter' : Array<GamesWithCharacter>,
  'totalGamesWithFaction' : Array<GamesWithFaction>,
}
export type PlayerID = Principal;
export type PlayerId = Principal;
export interface PlayerInfo {
  'id' : UserId,
  'elo' : number,
  'lastPlayerActive' : bigint,
  'matchAccepted' : boolean,
  'playerGameData' : string,
}
export type PlayerName = string;
export interface PlayerPreferences {
  'language' : bigint,
  'playerChar' : string,
}
export type PrizeType = { 'Flux' : null } |
  { 'Shards' : null } |
  { 'Chest' : null };
export type RegistrationDate = bigint;
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
export type SearchStatus = { 'Available' : null } |
  { 'NotAvailable' : null } |
  { 'Assigned' : null };
export type StastisticsGameID = bigint;
export type Time = bigint;
export type TokenID = bigint;
export interface Tournament {
  'id' : bigint,
  'participants' : Array<Principal>,
  'name' : string,
  'isActive' : boolean,
  'expirationDate' : Time,
  'matchCounter' : bigint,
  'registeredParticipants' : Array<Principal>,
  'bracketCreated' : boolean,
  'prizePool' : string,
  'startDate' : Time,
}
export interface UserDetails {
  'user' : UserRecord,
  'friends' : Array<FriendDetails>,
}
export type UserID = Principal;
export type UserId = Principal;
export interface UserRecord {
  'username' : Username,
  'userId' : UserID,
  'description' : Description,
  'registrationDate' : RegistrationDate,
  'friends' : Array<UserID>,
  'avatar' : AvatarID,
}
export type Username = string;
export interface _SERVICE extends Cosmicrafts {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
