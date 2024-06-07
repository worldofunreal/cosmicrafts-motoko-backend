import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

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
export type GameID = bigint;
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
export interface Statistics {
  'getAllOnValidation' : ActorMethod<[], Array<[GameID, BasicStats]>>,
  'getAverageStats' : ActorMethod<[], AverageStats>,
  'getBasicStats' : ActorMethod<[GameID], [] | [BasicStats]>,
  'getMyAverageStats' : ActorMethod<[], [] | [AverageStats]>,
  'getMyStats' : ActorMethod<[], [] | [PlayerGamesStats]>,
  'getOverallStats' : ActorMethod<[], OverallStats>,
  'getPlayerAverageStats' : ActorMethod<[Principal], [] | [AverageStats]>,
  'getPlayerStats' : ActorMethod<[Principal], [] | [PlayerGamesStats]>,
  'saveFinishedGame' : ActorMethod<[GameID, BasicStats], [boolean, string]>,
  'setGameValid' : ActorMethod<[GameID], boolean>,
}
export interface _SERVICE extends Statistics {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: ({ IDL }: { IDL: IDL }) => IDL.Type[];
