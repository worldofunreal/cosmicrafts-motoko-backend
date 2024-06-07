export const idlFactory = ({ IDL }) => {
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
  const PlayersCanister = IDL.Service({
    'cancelMatchmaking' : IDL.Func([], [IDL.Bool, IDL.Text], []),
    'getAllSearching' : IDL.Func([], [IDL.Vec(MatchData)], ['query']),
    'getMatchData' : IDL.Func([IDL.Nat], [IDL.Opt(MatchData)], ['query']),
    'getMatchSearching' : IDL.Func(
        [IDL.Text],
        [SearchStatus, IDL.Nat, IDL.Text],
        [],
      ),
    'getMyMatchData' : IDL.Func(
        [],
        [IDL.Opt(FullMatchData), IDL.Nat],
        ['composite_query'],
      ),
    'isGameMatched' : IDL.Func([], [IDL.Bool, IDL.Text], ['query']),
    'setGameOver' : IDL.Func(
        [IDL.Principal],
        [IDL.Bool, IDL.Bool, IDL.Opt(IDL.Principal)],
        [],
      ),
    'setPlayerActive' : IDL.Func([], [IDL.Bool], []),
  });
  return PlayersCanister;
};
export const init = ({ IDL }) => { return []; };
