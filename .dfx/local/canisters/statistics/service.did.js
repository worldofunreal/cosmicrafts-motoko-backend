export const idlFactory = ({ IDL }) => {
  const GameID = IDL.Nat;
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
  const AverageStats = IDL.Record({
    'averageDamageDealt' : IDL.Float64,
    'averageEnergyGenerated' : IDL.Float64,
    'averageEnergyUsed' : IDL.Float64,
    'averageKills' : IDL.Float64,
    'averageEnergyWasted' : IDL.Float64,
    'averageXpEarned' : IDL.Float64,
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
  const Statistics = IDL.Service({
    'getAllOnValidation' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(GameID, BasicStats))],
        ['query'],
      ),
    'getAverageStats' : IDL.Func([], [AverageStats], ['query']),
    'getBasicStats' : IDL.Func([GameID], [IDL.Opt(BasicStats)], ['query']),
    'getMyAverageStats' : IDL.Func([], [IDL.Opt(AverageStats)], ['query']),
    'getMyStats' : IDL.Func([], [IDL.Opt(PlayerGamesStats)], ['query']),
    'getOverallStats' : IDL.Func([], [OverallStats], ['query']),
    'getPlayerAverageStats' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(AverageStats)],
        ['query'],
      ),
    'getPlayerStats' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(PlayerGamesStats)],
        ['query'],
      ),
    'saveFinishedGame' : IDL.Func(
        [GameID, BasicStats],
        [IDL.Bool, IDL.Text],
        [],
      ),
    'setGameValid' : IDL.Func([GameID], [IDL.Bool], []),
  });
  return Statistics;
};
export const init = ({ IDL }) => { return []; };
