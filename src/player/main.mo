import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Int64 "mo:base/Int64";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Result "mo:base/Result";

import Types "types";
import CosmicraftsTypes "../cosmicrafts/types";
import MatchmakingTypes "MatchmakingTypes";
import StatisticsTypes "StatisticsTypes";
import RewardTypes "RewardsTypes";

actor class Player() {

  //Player
  type Player = Types.Player;
  type PlayerId = Types.PlayerId;
  type PlayerName = Types.PlayerName;
  type Level = Types.Level;
  type PlayerMP = Types.Players;
  type PlayerPreferences = Types.PlayerPreferences;
  private stable var _userRecords : [(UserID, UserRecord)] = [];
  var userRecords : HashMap.HashMap<UserID, UserRecord> = HashMap.fromIter(_userRecords.vals(), 0, Principal.equal, Principal.hash);

  //Migrated Player from cosmicrafts
  type UserID = Types.UserID;
  type Username = Types.Username;
  type AvatarID = Types.AvatarID;
  type Description = Types.Description;
  type RegistrationDate = Types.RegistrationDate;
  type UserRecord = Types.UserRecord;
  type FriendDetails = Types.FriendDetails;
  type UserDetails = Types.UserDetails;
  private stable var _players : [(PlayerId, Player)] = [];
  var players : HashMap.HashMap<PlayerId, Player> = HashMap.fromIter(_players.vals(), 0, Principal.equal, Principal.hash);
  private stable var _playerPreferences : [(PlayerId, PlayerPreferences)] = [];
  var playerPreferences : HashMap.HashMap<PlayerId, PlayerPreferences> = HashMap.fromIter(_playerPreferences.vals(), 0, Principal.equal, Principal.hash);

  //Migrated Statistics
  type GameID = StatisticsTypes.GameID;
  type BasicStats = StatisticsTypes.BasicStats;
  type PlayerID = StatisticsTypes.PlayerID;
  type PlayerGamesStats = StatisticsTypes.PlayerGamesStats;
  type OverallStats = StatisticsTypes.OverallStats;
  type GamesWithFaction = StatisticsTypes.GamesWithFaction;
  type GamesWithGameMode = StatisticsTypes.GamesWithGameMode;
  type GamesWithCharacter = StatisticsTypes.GamesWithCharacter;
  type AverageStats = StatisticsTypes.AverageStats;

  private stable var _cosmicraftsPrincipal : Principal = Principal.fromText("woimf-oyaaa-aaaan-qegia-cai");

  private stable var k : Int = 30;

  private stable var overallStats : OverallStats = {
    totalGamesPlayed : Nat = 0;
    totalGamesSP : Nat = 0;
    totalGamesMP : Nat = 0;
    totalDamageDealt : Float = 0;
    totalTimePlayed : Float = 0;
    totalKills : Float = 0;
    totalEnergyGenerated : Float = 0;
    totalEnergyUsed : Float = 0;
    totalEnergyWasted : Float = 0;
    totalXpEarned : Float = 0;
    totalGamesWithFaction : [GamesWithFaction] = [];
    totalGamesGameMode : [GamesWithGameMode] = [];
    totalGamesWithCharacter : [GamesWithCharacter] = [];
  };

  // Function to register a new user with username and avatar
  public shared ({ caller : UserID }) func registerUser(username : Username, avatar : AvatarID) : async (Bool, UserID) {
    let userId = caller;
    switch (userRecords.get(userId)) {
      case (null) {
        let registrationDate = Time.now();
        let newUserRecord : UserRecord = {
          userId = userId;
          username = username;
          avatar = avatar;
          friends = [];
          description = "";
          registrationDate = registrationDate;
        };
        userRecords.put(userId, newUserRecord);
        return (true, userId);
      };
      case (?_) {
        return (false, userId); // User already exists
      };
    };
  };

  // Function to update the username, only the user themselves can update their username
  public shared ({ caller : UserID }) func updateUsername(username : Username) : async (Bool, UserID) {
    let userId = caller;
    switch (userRecords.get(userId)) {
      case (null) {
        return (false, userId); // User record does not exist
      };
      case (?userRecord) {
        let updatedRecord : UserRecord = {
          userId = userRecord.userId;
          username = username;
          avatar = userRecord.avatar;
          friends = userRecord.friends;
          description = userRecord.description;
          registrationDate = userRecord.registrationDate;
        };
        userRecords.put(userId, updatedRecord);
        return (true, userId);
      };
    };
  };

  // Function to update the avatar, only the user themselves can update their avatar
  public shared ({ caller : UserID }) func updateAvatar(avatar : AvatarID) : async (Bool, UserID) {
    let userId = caller;
    switch (userRecords.get(userId)) {
      case (null) {
        return (false, userId); // User record does not exist
      };
      case (?userRecord) {
        let updatedRecord : UserRecord = {
          userId = userRecord.userId;
          username = userRecord.username;
          avatar = avatar;
          friends = userRecord.friends;
          description = userRecord.description;
          registrationDate = userRecord.registrationDate;
        };
        userRecords.put(userId, updatedRecord);
        return (true, userId);
      };
    };
  };

  // Function to update the description, only the user themselves can update their description
  public shared ({ caller : UserID }) func updateDescription(description : Description) : async (Bool, UserID) {
    let userId = caller;
    switch (userRecords.get(userId)) {
      case (null) {
        return (false, userId); // User record does not exist
      };
      case (?userRecord) {
        let updatedRecord : UserRecord = {
          userId = userRecord.userId;
          username = userRecord.username;
          avatar = userRecord.avatar;
          friends = userRecord.friends;
          description = description;
          registrationDate = userRecord.registrationDate;
        };
        userRecords.put(userId, updatedRecord);
        return (true, userId);
      };
    };
  };

  // Function to get user details along with friends' details
  public query func getUserDetails(user : UserID) : async ?UserDetails {
    switch (userRecords.get(user)) {
      case (?userRecord) {
        let friendsBuffer = Buffer.Buffer<FriendDetails>(userRecord.friends.size());
        for (friendId in userRecord.friends.vals()) {
          switch (userRecords.get(friendId)) {
            case (?friendRecord) {
              let friendDetails : FriendDetails = {
                userId = friendRecord.userId;
                username = friendRecord.username;
                avatar = friendRecord.avatar;
              };
              friendsBuffer.add(friendDetails);
            };
            case null {};
          };
        };
        let friendsList = Buffer.toArray(friendsBuffer);
        return ?{ user = userRecord; friends = friendsList };
      };
      case null {
        return null;
      };
    };
  };

  // Function to search for user details by username
  public query func searchUserByUsername(username : Username) : async [UserRecord] {
    let result : Buffer.Buffer<UserRecord> = Buffer.Buffer<UserRecord>(0);
    for ((_, userRecord) in userRecords.entries()) {
      if (userRecord.username == username) {
        result.add(userRecord);
      };
    };
    return Buffer.toArray(result);
  };

  // Function to search for user details by principal ID
  public query func searchUserByPrincipal(userId : UserID) : async ?UserRecord {
    return userRecords.get(userId);
  };

  // Function to add a friend by principal ID
  public shared ({ caller : UserID }) func addFriend(friendId : UserID) : async (Bool, Text) {
    let userId = caller;
    switch (userRecords.get(userId)) {
      case (null) {
        return (false, "User record does not exist"); // User record does not exist
      };
      case (?userRecord) {
        switch (userRecords.get(friendId)) {
          case (null) {
            return (false, "Friend principal not registered"); // Friend principal not registered
          };
          case (?_) {
            let updatedFriends = Buffer.Buffer<UserID>(userRecord.friends.size() + 1);
            for (friend in userRecord.friends.vals()) {
              updatedFriends.add(friend);
            };
            updatedFriends.add(friendId);
            let updatedRecord : UserRecord = {
              userId = userRecord.userId;
              username = userRecord.username;
              avatar = userRecord.avatar;
              friends = Buffer.toArray(updatedFriends);
              description = userRecord.description;
              registrationDate = userRecord.registrationDate;
            };
            userRecords.put(userId, updatedRecord);
            return (true, "Friend added successfully");
          };
        };
      };
    };
  };

  // Function to get the friends list of the user
  public query ({ caller : UserID }) func getFriendsList() : async ?[UserID] {
    let userId = caller;
    switch (userRecords.get(userId)) {
      case (null) {
        return null; // User record does not exist
      };
      case (?userRecord) {
        return ?userRecord.friends;
      };
    };
  };

  //////////////////////////////////
  //analize if its necesary all these three functions...
  /// PLAYERS LOGIC
  public shared (msg) func getPlayer() : async ?Player {
    return players.get(msg.caller);
  };

  public composite query func getPlayerData(player : Principal) : async ?Player {
    return players.get(player);
  };

  public shared query (msg) func getMyPlayerData() : async ?Player {
    return players.get(msg.caller);
  };
  //////////////////////////////////
  public shared (msg) func createPlayer(name : Text) : async (Bool, Text) {
    switch (players.get(msg.caller)) {
      case (null) {
        let _level = 0;
        let player : Player = {
          id = msg.caller;
          name = name;
          level = _level;
          elo = 1200;
        };
        players.put(msg.caller, player);
        let preferences : PlayerPreferences = {
          language = 0;
          playerChar = "";
        };
        playerPreferences.put(msg.caller, preferences);
        return (true, "Player created");
      };
      case (?_) {
        return (false, "Player already exists");
      };
    };
  };

  public shared (msg) func savePlayerName(name : Text) : async Bool {
    switch (players.get(msg.caller)) {
      case (null) {
        return false;
      };
      case (?player) {
        let _playerNew : Player = {
          id = player.id;
          name = name;
          level = player.level;
          elo = player.elo;
        };
        players.put(msg.caller, _playerNew);
        return true;
      };
    };
  };

  public shared (msg) func getPlayerPreferences() : async ?PlayerPreferences {
    return playerPreferences.get(msg.caller);
  };

  public shared (msg) func savePlayerChar(_char : Text) : async (Bool, Text) {
    switch (playerPreferences.get(msg.caller)) {
      case (null) {
        return (false, "Player not found");
      };
      case (?_p) {
        let _playerNew : PlayerPreferences = {
          language = _p.language;
          playerChar = _char;
        };
        playerPreferences.put(msg.caller, _playerNew);
        return (true, "Player's character saved");
      };
    };
  };

  public shared (msg) func savePlayerLanguage(_lang : Nat) : async (Bool, Text) {
    switch (playerPreferences.get(msg.caller)) {
      case (null) {
        return (false, "Player not found");
      };
      case (?_p) {
        let _playerNew : PlayerPreferences = {
          language = _lang;
          playerChar = _p.playerChar;
        };
        playerPreferences.put(msg.caller, _playerNew);
        return (true, "Player's language saved");
      };
    };
  };

  public query func getAllPlayers() : async [Player] {
    return Iter.toArray(players.vals());
  };

  public query func getPlayerElo(player : Principal) : async Float {
    return switch (players.get(player)) {
      case (null) {
        1200;
      };
      case (?_p) {
        _p.elo;
      };
    };
  };

  public shared (msg) func updatePlayerElo(player : Principal, newELO : Float) : async Bool {
    // assert (msg.caller == _statisticPrincipal); /// Only Statistics Canister can update ELO, change for statistics principal later
    let _player : Player = switch (players.get(player)) {
      case (null) {
        return false;
      };
      case (?_p) {
        _p;
      };
    };
    /// Update ELO on player's data
    let _playerNew : Player = {
      id = _player.id;
      name = _player.name;
      level = _player.level;
      elo = newELO;
    };
    players.put(player, _playerNew);
    return true;
  };

  //Statistics
  /// Functions for finding Ships IDs
  func _natEqual(a : Nat, b : Nat) : Bool {
    return a == b;
  };
  func _natHash(a : Nat) : Hash.Hash {
    return Hash.hash(a);
  };

  /// Initialize variables
  private stable var _basicStats : [(GameID, BasicStats)] = [];
  var basicStats : HashMap.HashMap<GameID, BasicStats> = HashMap.fromIter(_basicStats.vals(), 0, _natEqual, _natHash);

  private stable var _playerGamesStats : [(PlayerID, PlayerGamesStats)] = [];
  var playerGamesStats : HashMap.HashMap<PlayerID, PlayerGamesStats> = HashMap.fromIter(_playerGamesStats.vals(), 0, Principal.equal, Principal.hash);

  private stable var _onValidation : [(GameID, BasicStats)] = [];
  var onValidation : HashMap.HashMap<GameID, BasicStats> = HashMap.fromIter(_onValidation.vals(), 0, _natEqual, _natHash);

  /* TO-DO ELO */
  /*
    ** DONE - Give each player their base ELO
    ** DONE - Increase / decrease the amount of ELO after each game
    ** Create list for players looking for games
    ** Search player matching / close ELO on matchmaking
    ** If no player is near, match with the closest ELO
    ** If no player is available then add it to the waiting list
    */

  private func initializeNewPlayerStats(_player : Principal) : async (Bool, Text) {
    let _playerStats : PlayerGamesStats = {
      gamesPlayed = 0;
      gamesWon = 0;
      gamesLost = 0;
      energyGenerated = 0;
      energyUsed = 0;
      energyWasted = 0;
      totalDamageDealt = 0;
      totalDamageTaken = 0;
      totalDamageCrit = 0;
      totalDamageEvaded = 0;
      totalXpEarned = 0;
      totalGamesWithFaction = [];
      totalGamesGameMode = [];
      totalGamesWithCharacter = [];
    };
    playerGamesStats.put(_player, _playerStats);
    return (true, "Player stats initialized");
  };

  private func updatePlayerELO(playerID : PlayerID, won : Nat, otherPlayerID : ?PlayerID) : async Bool {
    switch (otherPlayerID) {
      case (null) {
        return false;
      };
      case (?_p) {
        /// Get both player's ELO
        var _p1Elo : Float = await getPlayerElo(playerID);
        let _p2Elo : Float = await getPlayerElo(_p);
        /// Calculate expected results
        let _p1Expected : Float = 1 / (1 + Float.pow(10, (_p2Elo - _p1Elo) / 400));
        let _p2Expected : Float = 1 / (1 + Float.pow(10, (_p1Elo - _p2Elo) / 400));
        /// Update ELO
        let _elo : Float = _p1Elo + Float.fromInt(k) * (Float.fromInt64(Int64.fromInt(won)) - _p1Expected);
        let _updated = await updatePlayerElo(playerID, _elo);
        return true;
      };
    };
  };

  /// Move game from "In Progress" to "Finished"
  public shared (msg) func setGameOver(caller : Principal) : async (Bool, Bool, ?Principal) {
    assert (msg.caller == Principal.fromText("jybso-3iaaa-aaaan-qeima-cai"));
    switch (playerStatus.get(caller)) {
      case (null) {
        return (false, false, null);
      };
      case (?_s) {
        switch (inProgress.get(_s.matchID)) {
          case (null) {
            switch (searching.get(_s.matchID)) {
              case (null) {
                switch (finishedGames.get(_s.matchID)) {
                  case (null) {
                    return (false, false, null);
                  };
                  case (?_m) {
                    /// Game is not on the searching on inProgress, so we just remove the status from the player
                    playerStatus.delete(caller);
                    return (true, caller == _m.player1.id, getOtherPlayer(_m, caller));
                  };
                };
              };
              case (?_m) {
                /// Game is on Searching list, so we remove it, add it to the finished list and remove the status from the player
                finishedGames.put(_s.matchID, _m);
                searching.delete(_s.matchID);
                playerStatus.delete(caller);
                return (true, caller == _m.player1.id, getOtherPlayer(_m, caller));
              };
            };
          };
          case (?_m) {
            /// Game is on inProgress list, so we remove it, add it to the finished list and remove the status from the player
            finishedGames.put(_s.matchID, _m);
            inProgress.delete(_s.matchID);
            playerStatus.delete(caller);
            return (true, caller == _m.player1.id, getOtherPlayer(_m, caller));
          };
        };
      };
    };
  };

  public shared (msg) func saveFinishedGame(gameID : GameID, _basicStats : BasicStats) : async (Bool, Text) {
    /// End game on the matchmaking canister
    var _txt : Text = "";
    switch (basicStats.get(gameID)) {
      case (null) {
        let endingGame : (Bool, Bool, ?Principal) = await setGameOver(msg.caller);
        basicStats.put(gameID, _basicStats);
        let _gameValid : (Bool, Text) = await validateGame(300 - _basicStats.secRemaining, _basicStats.energyUsed, _basicStats.xpEarned, 0.5);
        if (_gameValid.0 == false) {
          onValidation.put(gameID, _basicStats);
          return (false, _gameValid.1);
        };
        /// Player stats
        let _winner = if (_basicStats.wonGame == true) 1 else 0;
        let _looser = if (_basicStats.wonGame == false) 1 else 0;
        let _elo : Bool = await updatePlayerELO(msg.caller, _winner, endingGame.2);
        var _progressRewards : [RewardTypes.RewardProgress] = [{
          rewardType = #GamesCompleted;
          progress = 1;
        }];
        if (_basicStats.wonGame == true) {
          let _wonProgress : RewardTypes.RewardProgress = {
            rewardType = #GamesWon;
            progress = 1;
          };
          _progressRewards := Array.append(_progressRewards, [_wonProgress]);
        };
        let _progressAdded = await addProgressToRewards(msg.caller, _progressRewards);
        _txt := _progressAdded.1;
        switch (playerGamesStats.get(msg.caller)) {
          case (null) {
            let _gs : PlayerGamesStats = {
              gamesPlayed = 1;
              gamesWon = _winner;
              gamesLost = _looser;
              energyGenerated = _basicStats.energyGenerated;
              energyUsed = _basicStats.energyUsed;
              energyWasted = _basicStats.energyWasted;
              totalDamageDealt = _basicStats.damageDealt;
              totalDamageTaken = _basicStats.damageTaken;
              totalDamageCrit = _basicStats.damageCritic;
              totalDamageEvaded = _basicStats.damageEvaded;
              totalXpEarned = _basicStats.xpEarned;
              totalGamesWithFaction = [{
                factionID = _basicStats.faction;
                gamesPlayed = 1;
                gamesWon = _winner;
              }];
              totalGamesGameMode = [{
                gameModeID = _basicStats.gameMode;
                gamesPlayed = 1;
                gamesWon = _winner;
              }];
              totalGamesWithCharacter = [{
                characterID = _basicStats.characterID;
                gamesPlayed = 1;
                gamesWon = _winner;
              }];
            };
            playerGamesStats.put(msg.caller, _gs);
          };
          case (?_bs) {
            var _gamesWithFaction : [GamesWithFaction] = [];
            var _gamesWithGameMode : [GamesWithGameMode] = [];
            var _totalGamesWithCharacter : [GamesWithCharacter] = [];
            for (gf in _bs.totalGamesWithFaction.vals()) {
              if (gf.factionID == _basicStats.faction) {
                _gamesWithFaction := Array.append(_gamesWithFaction, [{ gamesPlayed = gf.gamesPlayed + 1; factionID = gf.factionID; gamesWon = gf.gamesWon + _winner }]);
              } else {
                _gamesWithFaction := Array.append(_gamesWithFaction, [gf]);
              };
            };
            for (gm in _bs.totalGamesGameMode.vals()) {
              if (gm.gameModeID == _basicStats.gameMode) {
                _gamesWithGameMode := Array.append(_gamesWithGameMode, [{ gamesPlayed = gm.gamesPlayed + 1; gameModeID = gm.gameModeID; gamesWon = gm.gamesWon + _winner }]);
              } else {
                _gamesWithGameMode := Array.append(_gamesWithGameMode, [gm]);
              };
            };
            for (gc in _bs.totalGamesWithCharacter.vals()) {
              if (gc.characterID == _basicStats.characterID) {
                _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [{ gamesPlayed = gc.gamesPlayed + 1; characterID = gc.characterID; gamesWon = gc.gamesWon + _winner }]);
              } else {
                _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [gc]);
              };
            };
            var _thisGameXP = _basicStats.xpEarned;
            if (_basicStats.wonGame == true) {
              _thisGameXP := _thisGameXP * 2;
            } else {
              _thisGameXP := _thisGameXP * 0.5;
            };
            if (_basicStats.gameMode == 1) {
              _thisGameXP := _thisGameXP * 2;
            } else {
              _thisGameXP := _thisGameXP * 0.25;
            };
            let _gs : PlayerGamesStats = {
              gamesPlayed = _bs.gamesPlayed + 1;
              gamesWon = _bs.gamesWon + _winner;
              gamesLost = _bs.gamesLost + _looser;
              energyGenerated = _bs.energyGenerated + _basicStats.energyGenerated;
              energyUsed = _bs.energyUsed + _basicStats.energyUsed;
              energyWasted = _bs.energyWasted + _basicStats.energyWasted;
              totalDamageDealt = _bs.totalDamageDealt + _basicStats.damageDealt;
              totalDamageTaken = _bs.totalDamageTaken + _basicStats.damageTaken;
              totalDamageCrit = _bs.totalDamageCrit + _basicStats.damageCritic;
              totalDamageEvaded = _bs.totalDamageEvaded + _basicStats.damageEvaded;
              totalXpEarned = _bs.totalXpEarned + _thisGameXP;
              totalGamesWithFaction = _gamesWithFaction;
              totalGamesGameMode = _gamesWithGameMode;
              totalGamesWithCharacter = _totalGamesWithCharacter;
            };
            playerGamesStats.put(msg.caller, _gs);
          };
        };
        /// Overall stats
        var _totalGamesWithFaction : [GamesWithFaction] = [];
        var _totalGamesWithGameMode : [GamesWithGameMode] = [];
        var _totalGamesWithCharacter : [GamesWithCharacter] = [];
        for (gf in overallStats.totalGamesWithFaction.vals()) {
          if (gf.factionID == _basicStats.faction) {
            _totalGamesWithFaction := Array.append(_totalGamesWithFaction, [{ gamesPlayed = gf.gamesPlayed + 1; factionID = gf.factionID; gamesWon = gf.gamesWon + _winner }]);
          } else {
            _totalGamesWithFaction := Array.append(_totalGamesWithFaction, [gf]);
          };
        };
        for (gm in overallStats.totalGamesGameMode.vals()) {
          if (gm.gameModeID == _basicStats.gameMode) {
            _totalGamesWithGameMode := Array.append(_totalGamesWithGameMode, [{ gamesPlayed = gm.gamesPlayed + 1; gameModeID = gm.gameModeID; gamesWon = gm.gamesWon + _winner }]);
          } else {
            _totalGamesWithGameMode := Array.append(_totalGamesWithGameMode, [gm]);
          };
        };
        for (gc in overallStats.totalGamesWithCharacter.vals()) {
          if (gc.characterID == _basicStats.characterID) {
            _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [{ gamesPlayed = gc.gamesPlayed + 1; characterID = gc.characterID; gamesWon = gc.gamesWon + _winner }]);
          } else {
            _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [gc]);
          };
        };
        let _os : OverallStats = {
          totalGamesPlayed = overallStats.totalGamesPlayed + 1;
          totalGamesSP = if (_basicStats.gameMode == 2) overallStats.totalGamesSP + 1 else overallStats.totalGamesSP;
          totalGamesMP = if (_basicStats.gameMode == 1) overallStats.totalGamesMP + 1 else overallStats.totalGamesMP;
          totalDamageDealt = overallStats.totalDamageDealt + _basicStats.damageDealt;
          totalTimePlayed = overallStats.totalTimePlayed;
          totalKills = overallStats.totalKills + _basicStats.kills;
          totalEnergyUsed = overallStats.totalEnergyUsed + _basicStats.energyUsed;
          totalEnergyGenerated = overallStats.totalEnergyGenerated + _basicStats.energyGenerated;
          totalEnergyWasted = overallStats.totalEnergyWasted + _basicStats.energyWasted;
          totalGamesWithFaction = _totalGamesWithFaction;
          totalGamesGameMode = _totalGamesWithGameMode;
          totalGamesWithCharacter = _totalGamesWithCharacter;
          totalXpEarned = overallStats.totalXpEarned + _basicStats.xpEarned;
        };
        overallStats := _os;
        return (true, "Game saved");
      };
      case (?_bs) {
        /// Was saved before, only save the respective variables
        /// Also validate info vs other save
        let endingGame = await setGameOver(msg.caller);
        let _winner = if (_basicStats.wonGame == true) 1 else 0;
        let _looser = if (_basicStats.wonGame == false) 1 else 0;
        let _elo : Bool = await updatePlayerELO(msg.caller, _winner, endingGame.2);
        var _progressRewards : [RewardTypes.RewardProgress] = [{
          rewardType = #GamesCompleted;
          progress = 1;
        }];
        if (_basicStats.wonGame == true) {
          let _wonProgress : RewardTypes.RewardProgress = {
            rewardType = #GamesWon;
            progress = 1;
          };
          _progressRewards := Array.append(_progressRewards, [_wonProgress]);
        };
        let _progressAdded = await addProgressToRewards(msg.caller, _progressRewards);
        _txt := _progressAdded.1;
        switch (playerGamesStats.get(msg.caller)) {
          case (null) {
            let _gs : PlayerGamesStats = {
              gamesPlayed = 1;
              gamesWon = _winner;
              gamesLost = _looser;
              energyGenerated = _basicStats.energyGenerated;
              energyUsed = _basicStats.energyUsed;
              energyWasted = _basicStats.energyWasted;
              totalDamageDealt = _basicStats.damageDealt;
              totalDamageTaken = _basicStats.damageTaken;
              totalDamageCrit = _basicStats.damageCritic;
              totalDamageEvaded = _basicStats.damageEvaded;
              totalXpEarned = _basicStats.xpEarned;
              totalGamesWithFaction = [{
                factionID = _basicStats.faction;
                gamesPlayed = 1;
                gamesWon = _winner;
              }];
              totalGamesGameMode = [{
                gameModeID = _basicStats.gameMode;
                gamesPlayed = 1;
                gamesWon = _winner;
              }];
              totalGamesWithCharacter = [{
                characterID = _basicStats.characterID;
                gamesPlayed = 1;
                gamesWon = _winner;
              }];
            };
            playerGamesStats.put(msg.caller, _gs);
          };
          case (?_bs) {
            var _gamesWithFaction : [GamesWithFaction] = [];
            var _gamesWithGameMode : [GamesWithGameMode] = [];
            var _totalGamesWithCharacter : [GamesWithCharacter] = [];
            for (gf in _bs.totalGamesWithFaction.vals()) {
              if (gf.factionID == _basicStats.faction) {
                _gamesWithFaction := Array.append(_gamesWithFaction, [{ gamesPlayed = gf.gamesPlayed + 1; factionID = gf.factionID; gamesWon = gf.gamesWon + _winner }]);
              } else {
                _gamesWithFaction := Array.append(_gamesWithFaction, [gf]);
              };
            };
            for (gm in _bs.totalGamesGameMode.vals()) {
              if (gm.gameModeID == _basicStats.gameMode) {
                _gamesWithGameMode := Array.append(_gamesWithGameMode, [{ gamesPlayed = gm.gamesPlayed + 1; gameModeID = gm.gameModeID; gamesWon = gm.gamesWon + _winner }]);
              } else {
                _gamesWithGameMode := Array.append(_gamesWithGameMode, [gm]);
              };
            };
            for (gc in _bs.totalGamesWithCharacter.vals()) {
              if (gc.characterID == _basicStats.characterID) {
                _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [{ gamesPlayed = gc.gamesPlayed + 1; characterID = gc.characterID; gamesWon = gc.gamesWon + _winner }]);
              } else {
                _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [gc]);
              };
            };
            var _thisGameXP = _basicStats.xpEarned;
            if (_basicStats.wonGame == true) {
              _thisGameXP := _thisGameXP * 2;
            } else {
              _thisGameXP := _thisGameXP * 0.5;
            };
            if (_basicStats.gameMode == 1) {
              _thisGameXP := _thisGameXP * 2;
            } else {
              _thisGameXP := _thisGameXP * 0.25;
            };
            let _gs : PlayerGamesStats = {
              gamesPlayed = _bs.gamesPlayed + 1;
              gamesWon = _bs.gamesWon + _winner;
              gamesLost = _bs.gamesLost + _looser;
              energyGenerated = _bs.energyGenerated + _basicStats.energyGenerated;
              energyUsed = _bs.energyUsed + _basicStats.energyUsed;
              energyWasted = _bs.energyWasted + _basicStats.energyWasted;
              totalDamageDealt = _bs.totalDamageDealt + _basicStats.damageDealt;
              totalDamageTaken = _bs.totalDamageTaken + _basicStats.damageTaken;
              totalDamageCrit = _bs.totalDamageCrit + _basicStats.damageCritic;
              totalDamageEvaded = _bs.totalDamageEvaded + _basicStats.damageEvaded;
              totalXpEarned = _bs.totalXpEarned + _thisGameXP;
              totalGamesWithFaction = _gamesWithFaction;
              totalGamesGameMode = _gamesWithGameMode;
              totalGamesWithCharacter = _totalGamesWithCharacter;
            };
            playerGamesStats.put(msg.caller, _gs);
          };
        };
        /// Overall stats
        var _totalGamesWithFaction : [GamesWithFaction] = [];
        var _totalGamesWithCharacter : [GamesWithCharacter] = [];
        for (gf in overallStats.totalGamesWithFaction.vals()) {
          if (gf.factionID == _basicStats.faction) {
            _totalGamesWithFaction := Array.append(_totalGamesWithFaction, [{ gamesPlayed = gf.gamesPlayed + 1; factionID = gf.factionID; gamesWon = gf.gamesWon + _winner }]);
          } else {
            _totalGamesWithFaction := Array.append(_totalGamesWithFaction, [gf]);
          };
        };
        for (gc in overallStats.totalGamesWithCharacter.vals()) {
          if (gc.characterID == _basicStats.characterID) {
            _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [{ gamesPlayed = gc.gamesPlayed + 1; characterID = gc.characterID; gamesWon = gc.gamesWon + _winner }]);
          } else {
            _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [gc]);
          };
        };
        let _os : OverallStats = {
          totalGamesPlayed = overallStats.totalGamesPlayed + 1;
          totalGamesSP = if (_basicStats.gameMode == 2) overallStats.totalGamesSP + 1 else overallStats.totalGamesSP;
          totalGamesMP = if (_basicStats.gameMode == 1) overallStats.totalGamesMP + 1 else overallStats.totalGamesMP;
          totalDamageDealt = overallStats.totalDamageDealt + _basicStats.damageDealt;
          totalTimePlayed = overallStats.totalTimePlayed;
          totalKills = overallStats.totalKills + _basicStats.kills;
          totalEnergyUsed = overallStats.totalEnergyUsed + _basicStats.energyUsed;
          totalEnergyGenerated = overallStats.totalEnergyGenerated + _basicStats.energyGenerated;
          totalEnergyWasted = overallStats.totalEnergyWasted + _basicStats.energyWasted;
          totalGamesWithFaction = _totalGamesWithFaction;
          totalGamesGameMode = overallStats.totalGamesGameMode;
          totalGamesWithCharacter = _totalGamesWithCharacter;
          totalXpEarned = overallStats.totalXpEarned + _basicStats.xpEarned;
        };
        overallStats := _os;
        return (true, _txt # " - Game saved");
      };
    };
  };

  public query func getOverallStats() : async OverallStats {
    return overallStats;
  };

  public query func getAverageStats() : async AverageStats {
    let _averageStats : AverageStats = {
      averageEnergyGenerated = overallStats.totalEnergyGenerated / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
      averageEnergyUsed = overallStats.totalEnergyUsed / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
      averageEnergyWasted = overallStats.totalEnergyWasted / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
      averageDamageDealt = overallStats.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
      averageKills = overallStats.totalKills / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
      averageXpEarned = overallStats.totalXpEarned / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
    };
    return _averageStats;
  };

  public shared query (msg) func getMyStats() : async ?PlayerGamesStats {
    switch (playerGamesStats.get(msg.caller)) {
      case (null) {
        let _playerStats : PlayerGamesStats = {
          gamesPlayed = 0;
          gamesWon = 0;
          gamesLost = 0;
          energyGenerated = 0;
          energyUsed = 0;
          energyWasted = 0;
          totalDamageDealt = 0;
          totalDamageTaken = 0;
          totalDamageCrit = 0;
          totalDamageEvaded = 0;
          totalXpEarned = 0;
          totalGamesWithFaction = [];
          totalGamesGameMode = [];
          totalGamesWithCharacter = [];
        };
        return ?_playerStats;
      };
      case (?_p) {
        return playerGamesStats.get(msg.caller);
      };
    };
  };

  public shared query (msg) func getMyAverageStats() : async ?AverageStats {
    switch (playerGamesStats.get(msg.caller)) {
      case (null) {
        let _newAverageStats : AverageStats = {
          averageEnergyGenerated = 0;
          averageEnergyUsed = 0;
          averageEnergyWasted = 0;
          averageDamageDealt = 0;
          averageKills = 0;
          averageXpEarned = 0;
        };
        return ?_newAverageStats;
      };
      case (?_p) {
        let _averageStats : AverageStats = {
          averageEnergyGenerated = _p.energyGenerated / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageEnergyUsed = _p.energyUsed / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageEnergyWasted = _p.energyWasted / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageDamageDealt = _p.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageKills = _p.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageXpEarned = _p.totalXpEarned / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
        };
        return ?_averageStats;
      };
    };
  };

  public shared query (msg) func getBasicStats(gameID : GameID) : async ?BasicStats {
    return basicStats.get(gameID);
  };

  public query func getPlayerStats(_player : Principal) : async ?PlayerGamesStats {
    switch (playerGamesStats.get(_player)) {
      case (null) {
        let _playerStats : PlayerGamesStats = {
          gamesPlayed = 0;
          gamesWon = 0;
          gamesLost = 0;
          energyGenerated = 0;
          energyUsed = 0;
          energyWasted = 0;
          totalDamageDealt = 0;
          totalDamageTaken = 0;
          totalDamageCrit = 0;
          totalDamageEvaded = 0;
          totalXpEarned = 0;
          totalGamesWithFaction = [];
          totalGamesGameMode = [];
          totalGamesWithCharacter = [];
        };
        return ?_playerStats;
      };
      case (?_p) {
        return playerGamesStats.get(_player);
      };
    };
    return playerGamesStats.get(_player);
  };

  public query func getPlayerAverageStats(_player : Principal) : async ?AverageStats {
    switch (playerGamesStats.get(_player)) {
      case (null) {
        let _newAverageStats : AverageStats = {
          averageEnergyGenerated = 0;
          averageEnergyUsed = 0;
          averageEnergyWasted = 0;
          averageDamageDealt = 0;
          averageKills = 0;
          averageXpEarned = 0;
        };
        return ?_newAverageStats;
      };
      case (?_p) {
        let _averageStats : AverageStats = {
          averageEnergyGenerated = _p.energyGenerated / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageEnergyUsed = _p.energyUsed / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageEnergyWasted = _p.energyWasted / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageDamageDealt = _p.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageKills = _p.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
          averageXpEarned = _p.totalXpEarned / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
        };
        return ?_averageStats;
      };
    };
  };

  // Validation Data
  public query func getAllOnValidation() : async [(GameID, BasicStats)] {
    return _onValidation;
  };

  public shared (msg) func setGameValid(gameID : GameID) : async Bool {
    switch (onValidation.get(gameID)) {
      case (null) {
        return false;
      };
      case (?_bs) {
        onValidation.delete(gameID);
        basicStats.put(gameID, _bs);
        return true;
      };
    };
  };

  /// Game validator
  // Function to calculate the maximum plausible score
  func maxPlausibleScore(timeInSeconds : Float) : Float {
    let maxScoreRate : Float = 550000.0 / (5.0 * 60.0);
    let maxPlausibleScore : Float = maxScoreRate * timeInSeconds;
    return maxPlausibleScore;
  };

  // Function to validate energy balance
  func validateEnergyBalance(timeInSeconds : Float, energySpent : Float) : Bool {
    let energyGenerated : Float = 30.0 + (0.5 * timeInSeconds);
    return energyGenerated == energySpent;
  };

  // Function to validate efficiency
  func validateEfficiency(score : Float, energySpent : Float, efficiencyThreshold : Float) : Bool {
    let efficiency : Float = score / energySpent;
    return efficiency <= efficiencyThreshold;
  };

  // Main validation function
  public shared query (msg) func validateGame(timeInSeconds : Float, energySpent : Float, score : Float, efficiencyThreshold : Float) : async (Bool, Text) {
    let maxScore : Float = maxPlausibleScore(timeInSeconds);
    let isScoreValid : Bool = score <= maxScore;
    //let isEnergyBalanceValid : Bool  = validateEnergyBalance(timeInSeconds, energySpent);
    //let isEfficiencyValid    : Bool  = validateEfficiency(score, energySpent, efficiencyThreshold);
    if (isScoreValid /* and isEnergyBalanceValid and isEfficiencyValid*/) {
      return (true, "Game is valid");
    } else {
      // onValidation.put(gameID, _basicStats);
      if (isScoreValid == false) {
        return (false, "Score is not valid");
        // } else if(isEnergyBalanceValid == false){
        //     return (false, "Energy balance is not valid");
        // } else if(isEfficiencyValid == false){
        //     return (false, "Efficiency is not valid");
      } else {
        return (false, "Game is not valid");
      };
    };
  };

  //Rewards
  private stable var rewardID : Nat = 1;
  private var ONE_HOUR : Nat64 = 60 * 60 * 1_000_000_000; // 24 hours in nanoseconds
  private var NULL_PRINCIPAL : Principal = Principal.fromText("aaaaa-aa");
  private var ANON_PRINCIPAL : Principal = Principal.fromText("2vxsx-fae");

  /// Initialize variables
  private stable var _activeRewards : [(Nat, RewardTypes.Reward)] = [];
  var activeRewards : HashMap.HashMap<Nat, RewardTypes.Reward> = HashMap.fromIter(_activeRewards.vals(), 0, _natEqual, _natHash);

  private stable var _rewardsUsers : [(PlayerID, [RewardTypes.RewardsUser])] = [];
  var rewardsUsers : HashMap.HashMap<PlayerID, [RewardTypes.RewardsUser]> = HashMap.fromIter(_rewardsUsers.vals(), 0, Principal.equal, Principal.hash);

  private stable var _unclaimedRewardsUsers : [(PlayerID, [RewardTypes.RewardsUser])] = [];
  var unclaimedRewardsUsers : HashMap.HashMap<PlayerID, [RewardTypes.RewardsUser]> = HashMap.fromIter(_unclaimedRewardsUsers.vals(), 0, Principal.equal, Principal.hash);

  private stable var _finishedRewardsUsers : [(PlayerID, [RewardTypes.RewardsUser])] = [];
  var finishedRewardsUsers : HashMap.HashMap<PlayerID, [RewardTypes.RewardsUser]> = HashMap.fromIter(_finishedRewardsUsers.vals(), 0, Principal.equal, Principal.hash);

  private stable var _expiredRewardsUsers : [(PlayerID, [RewardTypes.RewardsUser])] = [];
  var expiredRewardsUsers : HashMap.HashMap<PlayerID, [RewardTypes.RewardsUser]> = HashMap.fromIter(_expiredRewardsUsers.vals(), 0, Principal.equal, Principal.hash);

  private stable var _userLastReward : [(PlayerID, Nat)] = [];
  var userLastReward : HashMap.HashMap<PlayerID, Nat> = HashMap.fromIter(_userLastReward.vals(), 0, Principal.equal, Principal.hash);

  private stable var _expiredRewards : [(Nat, RewardTypes.Reward)] = [];
  var expiredRewards : HashMap.HashMap<Nat, RewardTypes.Reward> = HashMap.fromIter(_expiredRewards.vals(), 0, _natEqual, _natHash);

  /// Functions for rewards
  public shared (msg) func addReward(reward : RewardTypes.Reward) : async (Bool, Text, Nat) {
    if (Principal.notEqual(msg.caller, _cosmicraftsPrincipal)) {
      return (false, "Unauthorized", 0);
    };
    let _newID = rewardID;
    activeRewards.put(_newID, reward);
    rewardID := rewardID + 1;
    return (true, "Reward added successfully", _newID);
  };

  public query func getReward(rewardID : Nat) : async ?RewardTypes.Reward {
    return (activeRewards.get(rewardID));
  };

  public shared query (msg) func getUserReward(_user : PlayerID, _idReward : Nat) : async ?RewardTypes.RewardsUser {
    if (Principal.notEqual(msg.caller, _cosmicraftsPrincipal)) {
      return null;
    };
    switch (rewardsUsers.get(_user)) {
      case (null) {
        return null;
      };
      case (?rewardsu) {
        for (r in rewardsu.vals()) {
          if (r.id_reward == _idReward) {
            return ?r;
          };
        };
        return null;
      };
    };
  };

  public shared (msg) func claimedReward(_player : Principal, rewardID : Nat) : async (Bool, Text) {
    if (Principal.notEqual(msg.caller, _cosmicraftsPrincipal)) {
      return (false, "Unauthorized");
    };
    switch (rewardsUsers.get(_player)) {
      case (null) {
        return (false, "User not found");
      };
      case (?rewardsu) {
        var _removed : Bool = false;
        var _message : Text = "Reward not found";
        var _userRewardsActive : [RewardTypes.RewardsUser] = [];
        for (r in rewardsu.vals()) {
          if (r.id_reward == rewardID) {
            if (r.finished == true) {
              var newUserRewardsFinished = switch (finishedRewardsUsers.get(_player)) {
                case (null) {
                  [];
                };
                case (?rewardsf) {
                  rewardsf;
                };
              };
              _removed := true;
              _message := "Reward claimed successfully";
              newUserRewardsFinished := Array.append(newUserRewardsFinished, [r]);
              finishedRewardsUsers.put(_player, newUserRewardsFinished);
            } else {
              _message := "Reward not finished yet";
            };
          } else {
            _userRewardsActive := Array.append(_userRewardsActive, [r]);
          };
        };
        rewardsUsers.put(_player, _userRewardsActive);
        return (_removed, _message);
      };
    };
  };

  public shared (msg) func addProgressToRewards(_player : Principal, rewardsProgress : [RewardTypes.RewardProgress]) : async (Bool, Text) {

    if (Principal.equal(_player, NULL_PRINCIPAL)) {
      return (false, "USER IS NULL. CANNOT ADD PROGRESS TO NULL USER");
    };
    if (Principal.equal(_player, ANON_PRINCIPAL)) {
      return (false, "USER IS ANONYMOUS. CANNOT ADD PROGRESS TO ANONYMOUS USER");
    };
    let _rewards_user : [RewardTypes.RewardsUser] = switch (rewardsUsers.get(_player)) {
      case (null) {
        addNewRewardsToUser(_player);
        // return (false, "User not found");
      };
      case (?rewardsu) {
        rewardsu;
      };
    };
    if (_rewards_user.size() == 0) {
      return (false, "NO REWARDS FOUND FOR THIS USER");
    };
    if (rewardsProgress.size() == 0) {
      return (false, "NO PROGRESS FOUND FOR THIS USER");
    };
    var _newUserRewards : [RewardTypes.RewardsUser] = [];
    let _now : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
    for (r in _rewards_user.vals()) {
      var _finished = r.finished;
      if (_finished == false and r.start_date <= _now) {
        if (r.expiration < _now) {
          var newUserRewardsExpired = switch (expiredRewardsUsers.get(_player)) {
            case (null) {
              [];
            };
            case (?rewardse) {
              rewardse;
            };
          };
          newUserRewardsExpired := Array.append(newUserRewardsExpired, [r]);
          expiredRewardsUsers.put(_player, newUserRewardsExpired);
        } else {
          for (rp in rewardsProgress.vals()) {
            if (r.rewardType == rp.rewardType) {
              let _progress = r.progress + rp.progress;
              var _finishedDate = r.finish_date;
              if (_progress >= r.total) {
                _finished := true;
                _finishedDate := _now;
              };
              let _r_u : RewardTypes.RewardsUser = {
                expiration = r.expiration;
                start_date = r.start_date;
                finish_date = _finishedDate;
                finished = _finished;
                id_reward = r.id_reward;
                prize_amount = r.prize_amount;
                prize_type = r.prize_type;
                progress = _progress;
                rewardType = r.rewardType;
                total = r.total;
              };
              _newUserRewards := Array.append(_newUserRewards, [_r_u]);
            };
          };
        };
      } else {
        /// Haven't started yet or already finished by the player
        _newUserRewards := Array.append(_newUserRewards, [r]);
      };
    };
    rewardsUsers.put(_player, _newUserRewards);
    return (true, "Progress added successfully for " # Nat.toText(_newUserRewards.size()) # " rewards");
  };

  func getAllUnexpiredActiveRewards(_from : ?Nat) : [RewardTypes.Reward] {
    let _now : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
    var _activeRewards : [RewardTypes.Reward] = [];
    let _fromNat : Nat = switch (_from) {
      case (null) {
        0;
      };
      case (?f) {
        f;
      };
    };
    for (r in activeRewards.vals()) {
      if (r.id > _fromNat) {
        if (r.start_date <= _now) {
          if (r.end_date < _now) {
            /// Already expired, move it to expired list
            let _expR = activeRewards.remove(r.id);
            switch (_expR) {
              case (null) {
                /// Do nothing
              };
              case (?er) {
                expiredRewards.put(er.id, er);
              };
            };
          } else {
            _activeRewards := Array.append(_activeRewards, [r]);
          };
        };
      };
    };
    return _activeRewards;
  };

  public query func getAllUsersRewards() : async ([(Principal, [RewardTypes.RewardsUser])]) {
    return Iter.toArray(rewardsUsers.entries());
  };

  public query func getAllActiveRewards() : async (Nat, [(RewardTypes.Reward)]) {
    var _activeRewards : [RewardTypes.Reward] = [];
    var _expired : Nat = 0;
    let _now : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
    for (r in activeRewards.vals()) {
      if (r.start_date <= _now) {
        if (r.end_date < _now) {
          _expired := _expired + 1;
        } else {
          _activeRewards := Array.append(_activeRewards, [r]);
        };
      };
    };
    return (_expired, _activeRewards);
  };

  func addNewRewardsToUser(_player : Principal) : [RewardTypes.RewardsUser] {
    /// Get last reward for this user
    var _newUserRewards = switch (userLastReward.get(_player)) {
      case (null) {
        /// The user has no rewards yet
        /// Get all active rewards
        let _unexpiredRewards = getAllUnexpiredActiveRewards(null);
        var _newUserRewards : [RewardTypes.RewardsUser] = [];
        for (r in _unexpiredRewards.vals()) {
          let _r_u : RewardTypes.RewardsUser = {
            expiration = r.end_date;
            start_date = r.start_date;
            finish_date = r.end_date;
            finished = false;
            id_reward = r.id;
            prize_amount = r.prize_amount;
            prize_type = r.prize_type;
            progress = 0;
            rewardType = r.rewardType;
            total = r.total;
          };
          /// Add the new reward to the user temp list
          _newUserRewards := Array.append(_newUserRewards, [_r_u]);
        };
        _newUserRewards;
      };
      case (lastReward) {
        let _unexpiredRewards = getAllUnexpiredActiveRewards(lastReward);
        var _newUserRewards : [RewardTypes.RewardsUser] = [];
        for (r in _unexpiredRewards.vals()) {
          let _r_u : RewardTypes.RewardsUser = {
            expiration = r.end_date;
            start_date = r.start_date;
            finish_date = r.end_date;
            finished = false;
            id_reward = r.id;
            prize_amount = r.prize_amount;
            prize_type = r.prize_type;
            progress = 0;
            rewardType = r.rewardType;
            total = r.total;
          };
          _newUserRewards := Array.append(_newUserRewards, [_r_u]);
        };
        _newUserRewards;
      };
    };
    switch (rewardsUsers.get(_player)) {
      case (null) {
        userLastReward.put(_player, rewardID);
        rewardsUsers.put(_player, _newUserRewards);
        return _newUserRewards;
      };
      case (?rewardsu) {
        /// Append the new rewards with the previous ones for this user
        var _newRewards : [RewardTypes.RewardsUser] = [];
        for (r in rewardsu.vals()) {
          _newRewards := Array.append(_newRewards, [r]);
        };
        for (r in _newUserRewards.vals()) {
          _newRewards := Array.append(_newRewards, [r]);
        };
        userLastReward.put(_player, rewardID);
        rewardsUsers.put(_player, _newRewards);
        return _newRewards;
      };
    };
  };

  /// Function to create new rewards
  public shared (msg) func createReward(name : Text, rewardType : RewardTypes.RewardType, prizeType : RewardTypes.PrizeType, prizeAmount : Nat, total : Float, hours_active : Nat64) : async (Bool, Text) {
    let _now : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
    let _hoursActive = ONE_HOUR * hours_active;
    let endDate = _now + _hoursActive;
    // if(Principal.notEqual(msg.caller, _cosmicraftsPrincipal)){
    //     return (false, "Unauthorized");
    // };
    let _newReward : RewardTypes.Reward = {
      end_date = endDate;
      id = rewardID;
      name = name;
      prize_amount = prizeAmount;
      prize_type = prizeType;
      rewardType = rewardType;
      start_date = _now;
      total = total;
    };
    activeRewards.put(rewardID, _newReward);
    rewardID := rewardID + 1;
    return (true, "Reward created successfully");
  };

  //MatchMaking
  type UserId = Types.PlayerId;
  type MatchmakingStatus = MatchmakingTypes.MatchmakingStatus;
  type MatchData = MatchmakingTypes.MatchData;
  type PlayerInfo = MatchmakingTypes.PlayerInfo;
  type PlayerStatus = MatchmakingTypes.PlayerStatus;
  type SearchStatus = MatchmakingTypes.SearchStatus;
  type FullPlayerInfo = MatchmakingTypes.FullPlayerInfo;
  type FullMatchData = MatchmakingTypes.FullMatchData;
  private var ONE_SECOND : Nat64 = 1_000_000_000; // 1 second in nanoseconds

  private stable var _matchID : Nat = 1;

  private var inactiveSeconds : Nat64 = 30 * ONE_SECOND;

  /// Initialize variables
  private stable var _searching : [(Nat, MatchData)] = [];
  var searching : HashMap.HashMap<Nat, MatchData> = HashMap.fromIter(_searching.vals(), 0, _natEqual, _natHash);

  private stable var _playerStatus : [(UserId, PlayerStatus)] = [];
  var playerStatus : HashMap.HashMap<UserId, PlayerStatus> = HashMap.fromIter(_playerStatus.vals(), 0, Principal.equal, Principal.hash);

  private stable var _inProgress : [(Nat, MatchData)] = [];
  var inProgress : HashMap.HashMap<Nat, MatchData> = HashMap.fromIter(_inProgress.vals(), 0, _natEqual, _natHash);

  private stable var _finishedGames : [(Nat, MatchData)] = [];
  var finishedGames : HashMap.HashMap<Nat, MatchData> = HashMap.fromIter(_finishedGames.vals(), 0, _natEqual, _natHash);

  // /* WEB SOCKETS */

  //     // let gateway_principal : Text = "g56br-jfsxj-ppxug-r46ks-h2yaq-ihgk7-25sfv-ajxl5-zsie2-jakwc-oqe";
  //     let gateway_principal : Text = "3656s-3kqlj-dkm5d-oputg-ymybu-4gnuq-7aojd-w2fzw-5lfp2-4zhx3-4ae";
  //     var ws_state = IcWebSocketCdk.IcWebSocketState(gateway_principal);
  //     type AppMessage = {
  //         message : Text;
  //         data : Nat;
  //     };
  //     /// A custom function to send the message to the client
  //     func send_app_message(client_principal : IcWebSocketCdk.ClientPrincipal, msg : AppMessage): async () {
  //         Debug.print("Sending message: " # debug_show (msg));

  //         // here we call the ws_send from the CDK!!
  //         switch (await IcWebSocketCdk.ws_send(ws_state, client_principal, to_candid(msg))) {
  //         case (#Err(err)) {
  //             Debug.print("Could not send message:" # debug_show (#Err(err)));
  //         };
  //         case (_) {};
  //         };
  //     };

  //     func on_open(args : IcWebSocketCdk.OnOpenCallbackArgs) : async () {
  //         let message : AppMessage = {
  //             message = "Open";
  //             data = 0;
  //         };
  //         await send_app_message(args.client_principal, message);
  //     };

  //     func on_message(args : IcWebSocketCdk.OnMessageCallbackArgs) : async () {
  //         let app_msg : ?AppMessage = from_candid(args.message);
  //         switch (app_msg) {
  //             case (?msg) {
  //                 switch(msg.message) {
  //                     case("addPlayerSearching") {
  //                         let _added : (Bool, Nat) = await addPlayerSearchingWS(args.client_principal);
  //                     };
  //                     case("assignPlayer2") {
  //                         let _matchID : Nat = msg.data;
  //                         let _added : (Bool, Text) = await assignPlayer2WS(args.client_principal, _matchID);
  //                     };
  //                     case("acceptMatch") {
  //                         let _accepted : (Bool, Text) = await acceptMatchWS(args.client_principal, msg.data);
  //                     };
  //                     case("rejectMatch") {
  //                         let _rejected : (Bool, Text) = await rejectMatchWS(args.client_principal);
  //                     };
  //                     case(_){
  //                         Debug.print("Message not recognized");
  //                     };
  //                 };
  //             };
  //             case (null) {
  //                 Debug.print("Could not deserialize message");
  //                 return;
  //             };
  //         };
  //     };

  //     func on_close(args : IcWebSocketCdk.OnCloseCallbackArgs) : async () {
  //         Debug.print("Client " # debug_show (args.client_principal) # " disconnected");
  //     };

  //     // method called by the WS Gateway after receiving FirstMessage from the client
  //     public shared ({ caller }) func ws_open(args : IcWebSocketCdk.CanisterWsOpenArguments) : async IcWebSocketCdk.CanisterWsOpenResult {
  //         await ws.ws_open(caller, args);
  //     };

  //     // method called by the Ws Gateway when closing the IcWebSocket connection
  //     public shared ({ caller }) func ws_close(args : IcWebSocketCdk.CanisterWsCloseArguments) : async IcWebSocketCdk.CanisterWsCloseResult {
  //         await ws.ws_close(caller, args);
  //     };

  //     // method called by the frontend SDK to send a message to the canister
  //     public shared ({ caller }) func ws_message(args : IcWebSocketCdk.CanisterWsMessageArguments, msg_type : ?Any) : async IcWebSocketCdk.CanisterWsMessageResult {
  //         await ws.ws_message(caller, args, msg_type);
  //     };

  //     // method called by the WS Gateway to get messages for all the clients it serves
  //     public shared query ({ caller }) func ws_get_messages(args : IcWebSocketCdk.CanisterWsGetMessagesArguments) : async IcWebSocketCdk.CanisterWsGetMessagesResult {
  //         ws.ws_get_messages(caller, args);
  //     };
  // /* END WEB SOCKETS */

  // /* INNER CALLS FOR WEBSOCKETS */
  //     /// Create a new registry ("lobby") for the player searching for a match
  //     func addPlayerSearchingWS(caller : Principal) : async (Bool, Nat){
  //         _matchID := _matchID + 1;
  //         let _player : PlayerInfo = {
  //             id                = caller;
  //             elo               = 0; /// TO-DO: ELO System; Also TO-DO: Ping system
  //             matchAccepted     = false;
  //             playerGameData    = "";
  //             lastPlayerActive  = Nat64.fromIntWrap(Time.now());
  //             // characterSelected = 0;
  //             // deckSavedKeyIds   = [];
  //         };
  //         let _match : MatchData = {
  //             gameId  = _matchID;
  //             player1 = _player;
  //             player2 = null;
  //             status  = #Searching;
  //         };
  //         searching.put(_matchID, _match);
  //         let _ps : PlayerStatus = {
  //             status  = #Searching;
  //             matchID = _matchID;
  //         };
  //         playerStatus.put(caller, _ps);
  //         return(true, _matchID);
  //     };

  //     /// User accepted match found
  //     func acceptMatchWS(caller : Principal, characterP : Nat) : async (Bool, Text){
  //         switch(playerStatus.get(caller)){
  //             case(null){
  //                 return(false, "Game not found for this player");
  //             };
  //             case(?_s){
  //                 if(_s.status == #Reserved){
  //                     switch(searching.get(_s.matchID)){
  //                         case(null){
  //                             return(false, "Game not found for this player");
  //                         };
  //                         case(?_m){
  //                             /// Check if caller is player 1 or 2
  //                             if(_m.player1.id == caller){
  //                                 /// Check if other player already accepted the game
  //                                 let _status : MatchmakingStatus = switch(_m.player2){
  //                                     case(null){
  //                                         /// If is not set the other player, set as searching /// DEBUG THIS
  //                                         #Searching;
  //                                     };
  //                                     case(?_st){
  //                                         /// If player is set check if it already accepted, in that case set as Accepted, if not as Accepting
  //                                         if(_st.matchAccepted == true){
  //                                             #Accepted;
  //                                         } else {
  //                                             #Accepting;
  //                                         }
  //                                     };
  //                                 };
  //                                 let _player1 : PlayerInfo = {
  //                                     id             = _m.player1.id;
  //                                     matchAccepted  = true;
  //                                     elo            = _m.player1.elo;
  //                                     playerGameData = "";
  //                                     lastPlayerActive  = Nat64.fromIntWrap(Time.now());
  //                                     // characterSelected = characterP;
  //                                     // deckSavedKeyIds = _m.player1.deckSavedKeyIds;
  //                                 };
  //                                 let m : MatchData = {
  //                                     gameId  = _s.matchID;
  //                                     player1 = _player1;
  //                                     player2 = _m.player2;
  //                                     status  = _status;
  //                                 };
  //                                 if(_status == #Accepted){
  //                                     /// Move the match from searching to "in progress"
  //                                     searching.delete(_s.matchID);
  //                                     inProgress.put(_s.matchID, m);
  //                                     /// Set both players as "In Game"
  //                                     let _p_s : PlayerStatus = {
  //                                         status  = #InGame;
  //                                         matchID = _s.matchID;
  //                                     };
  //                                     playerStatus.put(caller, _p_s);
  //                                     switch(_m.player2){
  //                                         case(null){};
  //                                         case(?_p2){
  //                                             //// TO-TEST: USE WEB HOOKS TO NOTIFY THE OTHER PLAYER THAT THE MATCH WAS ACCEPTED
  //                                             playerStatus.put(_p2.id, _p_s);
  //                                             await send_app_message(_player1.id, { message = "Game accepted"; data = _s.matchID });
  //                                             await send_app_message(_p2.id, { message = "Game accepted"; data = _s.matchID });
  //                                         };
  //                                     };
  //                                     return(true, "Accepted and In Progress");
  //                                 } else {
  //                                     /// Set searching status
  //                                     searching.put(_s.matchID, m);
  //                                     /// Set Player as status
  //                                     let _p_s : PlayerStatus = {
  //                                         status  = _status;
  //                                         matchID = _s.matchID;
  //                                     };
  //                                     playerStatus.put(caller, _p_s);
  //                                     return(true, "Accepted");
  //                                 };
  //                             };
  //                             /// It wasn't p1, check if it is p2
  //                             let _p2 = switch(_m.player2){
  //                                 case(null){
  //                                     return(false, "Game not found for this player");
  //                                 };
  //                                 case(?_p2){
  //                                     _p2;
  //                                 };
  //                             };
  //                             if(_p2.id == caller){
  //                                 /// Check if other player already accepted the game
  //                                 let _status : MatchmakingStatus = switch(_m.player1.matchAccepted){
  //                                     case(false){
  //                                         #Accepting;
  //                                     };
  //                                     case(true){
  //                                         #Accepted;
  //                                     };
  //                                 };
  //                                 let _player2 : PlayerInfo = {
  //                                     id                = _p2.id;
  //                                     matchAccepted     = true;
  //                                     elo               = _p2.elo;
  //                                     playerGameData    = "";
  //                                     lastPlayerActive  = Nat64.fromIntWrap(Time.now());
  //                                     // characterSelected = characterP;
  //                                     // deckSavedKeyIds   = _p2.deckSavedKeyIds;
  //                                 };
  //                                 let m : MatchData = {
  //                                     gameId  = _s.matchID;
  //                                     player1 = _m.player1;
  //                                     player2 = ?_p2;
  //                                     status  = _status;
  //                                 };
  //                                 if(_status == #Accepted){
  //                                     //// TO-TEST: USE WEB HOOKS TO NOTIFY BOTH PLAYERS THAT THE MATCH WAS ACCEPTED
  //                                     await send_app_message(_m.player1.id, { message = "Game accepted"; data = _s.matchID });
  //                                     await send_app_message(_p2.id, { message = "Game accepted"; data = _s.matchID });
  //                                     /// Move the match from searching to "in progress"
  //                                     searching.delete(_s.matchID);
  //                                     inProgress.put(_s.matchID, m);
  //                                     /// Set both players as "In Game"
  //                                     let _p_s : PlayerStatus = {
  //                                         status  = #InGame;
  //                                         matchID = _s.matchID;
  //                                     };
  //                                     playerStatus.put(caller, _p_s);
  //                                     playerStatus.put(_m.player1.id, _p_s);
  //                                     return(true, "Accepted and In Progress");
  //                                 } else {
  //                                     /// Set searching status
  //                                     searching.put(_s.matchID, m);
  //                                     /// Set Player as status
  //                                     let _p_s : PlayerStatus = {
  //                                         status  = _status;
  //                                         matchID = _s.matchID;
  //                                     };
  //                                     playerStatus.put(caller, _p_s);
  //                                     return(true, "Accepted");
  //                                 };
  //                             };
  //                         };
  //                     };
  //                 }
  //             };
  //         };
  //         return(false, "Not Accepted");
  //     };

  //     /// User didn't accept the match found
  //     func rejectMatchWS(caller : Principal) : async (Bool, Text){
  //         switch(playerStatus.get(caller)){
  //             case(null){
  //                 return(false, "Game not found for this player");
  //             };
  //             case(?_s){
  //                 if(_s.status != #Searching){
  //                     switch(searching.get(_s.matchID)){
  //                         case(null){
  //                             return(false, "Game not found for this player");
  //                         };
  //                         case(?_m){
  //                             /// Check if caller is player 1 or 2
  //                             if(_m.player1.id == caller){
  //                                 /// Remove player from searching status
  //                                 playerStatus.delete(caller);
  //                                 /// Check if other player already accepted the game
  //                                 switch(_m.player2){
  //                                     case(null){
  //                                         /// If is not set the other player, remove this player from list as the other didn't accept and was already removed
  //                                         searching.delete(_s.matchID);
  //                                         return(true, "Player removed from matchmaking");
  //                                     };
  //                                     case(?_st){
  //                                         // Set the player 2 as player 1, remove this player from searching and set the match as searching again
  //                                         let m : MatchData = {
  //                                             gameId  = _s.matchID;
  //                                             player1 = _st;
  //                                             player2 = null;
  //                                             status  = #Searching;
  //                                         };
  //                                         searching.put(_s.matchID, m);
  //                                         //// WEB HOOKS TO NOTIFY THE OTHER PLAYER THAT THEY WERE RETURNED TO SEARCHING
  //                                         await send_app_message(_st.id, { message = "Returning to search"; data = 0; });
  //                                         return(true, "Player removed from matchmaking");
  //                                     };
  //                                 };
  //                             };
  //                             /// It wasn't p1, check if it is p2
  //                             switch(_m.player2){
  //                                 case(null){
  //                                     return(false, "Game not found for this player");
  //                                 };
  //                                 case(?_p2){
  //                                     if(_p2.id == caller){
  //                                         /// Remove player from searching status
  //                                         playerStatus.delete(caller);
  //                                         /// Check if other player already accepted the game
  //                                         let m : MatchData = {
  //                                             gameId  = _s.matchID;
  //                                             player1 = _m.player1;
  //                                             player2 = null;
  //                                             status  = #Searching;
  //                                         };
  //                                         searching.put(_s.matchID, m);
  //                                         //// WEB HOOKS TO NOTIFY THE OTHER PLAYER THAT THEY WERE RETURNED TO SEARCHING
  //                                         await send_app_message(_m.player1.id, { message = "Returning to search"; data = 0; });
  //                                         return(true, "Player removed from matchmaking");
  //                                     };
  //                                 };
  //                             };
  //                         };
  //                     };
  //                 }
  //             };
  //         };
  //         return(false, "Game not found for this player");
  //     };

  //     /// Match found, set player as rival for the matchID received
  //     func assignPlayer2WS(caller : Principal, matchID : Nat) : async (Bool, Text){
  //         switch(searching.get(matchID)){
  //             case (null){
  //                 return (false, "Game Not Available");
  //             };
  //             case (?_m){
  //                 if(_m.player2 == null){
  //                     let _p2 : PlayerInfo = {
  //                         id                = caller;
  //                         elo               = 0; /// TO-DO
  //                         matchAccepted     = false;
  //                         playerGameData    = "";
  //                         lastPlayerActive  = Nat64.fromIntWrap(Time.now());
  //                         // characterSelected = 0;
  //                         // deckSavedKeyIds   = [];
  //                     };
  //                     let _gameData : MatchData = {
  //                         gameId  = matchID;
  //                         player1 = _m.player1;
  //                         player2 = ?_p2;
  //                         status  = #Reserved;
  //                     };
  //                     let _p_s : PlayerStatus = {
  //                         status  = #Reserved;
  //                         matchID = matchID;
  //                     };
  //                     searching.put(matchID, _gameData);
  //                     playerStatus.put(caller, _p_s);
  //                     playerStatus.put(_m.player1.id, _p_s);
  //                     //// TO-TEST: With Web Sockets Notify the other user that a match was found and both need to accept it
  //                     await send_app_message(_m.player1.id, { message = "Game found"; data = matchID });
  //                     await send_app_message(caller, { message = "Game found"; data = matchID });
  //                     return(true, "Assigned");
  //                 };
  //                 return(false, "Game Is Not Available");
  //             };
  //         }
  //     };

  // /* END INNER CALLS FOR WEBSOCKETS */

  public shared (msg) func setPlayerActive() : async Bool {
    assert (Principal.notEqual(msg.caller, NULL_PRINCIPAL));
    assert (Principal.notEqual(msg.caller, ANON_PRINCIPAL));
    switch (playerStatus.get(msg.caller)) {
      case (null) { return false };
      case (?_ps) {
        switch (searching.get(_ps.matchID)) {
          case (null) { return false };
          case (?_m) {
            let _now = Nat64.fromIntWrap(Time.now());
            if (_m.player1.id == msg.caller) {
              /// Check if the time of expiration have passed already and return false
              if ((_m.player1.lastPlayerActive + inactiveSeconds) < _now) {
                return false;
              };
              let _p : PlayerInfo = _m.player1;
              let _p1 : PlayerInfo = structPlayerActiveNow(_p);
              let _gameData : MatchData = structMatchData(_p1, _m.player2, _m);
              searching.put(_m.gameId, _gameData);
              return true;
            } else {
              let _p : PlayerInfo = switch (_m.player2) {
                case (null) { return false };
                case (?_p) { _p };
              };
              if ((_p.lastPlayerActive + inactiveSeconds) < _now) {
                return false;
              };
              let _p2 : PlayerInfo = structPlayerActiveNow(_p);
              let _gameData : MatchData = structMatchData(_m.player1, ?_p2, _m);
              searching.put(_m.gameId, _gameData);
              return true;
            };
          };
        };
        return false;
      };
    };
  };

  private func structPlayerActiveNow(_p1 : PlayerInfo) : PlayerInfo {
    let _p : PlayerInfo = {
      id = _p1.id;
      elo = _p1.elo;
      matchAccepted = _p1.matchAccepted;
      playerGameData = _p1.playerGameData;
      lastPlayerActive = Nat64.fromIntWrap(Time.now());
      // characterSelected = _p1.characterSelected;
      // deckSavedKeyIds   = _p1.deckSavedKeyIds;
    };
    return _p;
  };

  private func structMatchData(_p1 : PlayerInfo, _p2 : ?PlayerInfo, _m : MatchData) : MatchData {
    let _md : MatchData = {
      gameId = _m.gameId;
      player1 = _p1;
      player2 = _p2;
      status = _m.status;
    };
    return _md;
  };

  private func activatePlayerSearching(player : Principal, matchID : Nat) : Bool {
    switch (searching.get(matchID)) {
      case (null) { return false };
      case (?_m) {
        if (_m.status != #Searching) {
          return false;
        };
        let _now = Nat64.fromIntWrap(Time.now());
        if (_m.player1.id == player) {
          /// Check if the time of expiration have passed already and return false
          if ((_m.player1.lastPlayerActive + inactiveSeconds) < _now) {
            return false;
          };
          let _p : PlayerInfo = _m.player1;
          let _p1 : PlayerInfo = structPlayerActiveNow(_p);
          let _gameData : MatchData = structMatchData(_p1, _m.player2, _m);
          searching.put(_m.gameId, _gameData);
          return true;
        } else {
          let _p : PlayerInfo = switch (_m.player2) {
            case (null) { return false };
            case (?_p) { _p };
          };
          if (player != _p.id) {
            return false;
          };
          if ((_p.lastPlayerActive + inactiveSeconds) < _now) {
            return false;
          };
          let _p2 : PlayerInfo = structPlayerActiveNow(_p);
          let _gameData : MatchData = structMatchData(_m.player1, ?_p2, _m);
          searching.put(_m.gameId, _gameData);
          return true;
        };
      };
    };
  };

  func _floatSort(a : Float, b : Float) : Float {
    if (a < b) {
      return -1;
    } else if (a > b) {
      return 1;
    } else {
      return 0;
    };
  };

  func getGamesByELOsorted(targetELO : Float, maxELO : Float) : [MatchData] {
    var _gamesByELO : [MatchData] = [];
    var _now : Nat64 = Nat64.fromIntWrap(Time.now());
    for (m in searching.vals()) {
      /// Validate game is active
      if ((m.player1.lastPlayerActive + inactiveSeconds) >= _now) {
        /// Validate game is within the ELO range
        if (m.player1.elo >= (targetELO - maxELO) and m.player1.elo <= (targetELO + maxELO)) {
          /// To-Do: Add other loop to sort asc by ELO where all registries are passed and the new one is added in the right place
          if (Array.size(_gamesByELO) == 0) {
            _gamesByELO := [m];
          } else {
            var _orderedGamesByELO : [MatchData] = [];
            var _added : Bool = false;
            for (n in _gamesByELO.vals()) {
              if (n.player1.elo > m.player1.elo) {
                /// Add the new match in the right place
                _orderedGamesByELO := Array.append(_gamesByELO, [m]);
                _added := true;
                /// Also add the current registry
                _orderedGamesByELO := Array.append(_gamesByELO, [n]);
              } else {
                /// Only add the current registry
                _orderedGamesByELO := Array.append(_gamesByELO, [n]);
              };
            };
            if (_added == false) {
              _orderedGamesByELO := Array.append(_gamesByELO, [m]);
            };
            _gamesByELO := _orderedGamesByELO;
          };
        };
      };
    };
    _gamesByELO;
  };

  public shared (msg) func getMatchSearching(pgd : Text) : async (SearchStatus, Nat, Text) {
    assert (Principal.notEqual(msg.caller, NULL_PRINCIPAL));
    assert (Principal.notEqual(msg.caller, ANON_PRINCIPAL));
    /// Get Now Time
    let _now : Nat64 = Nat64.fromIntWrap(Time.now());
    let _pELO : Float = await getPlayerElo(msg.caller);
    /// If the player wasn't on a game aleady, check if there's a match available
    //// var _gamesByELO : [MatchData] = getGamesByELOsorted(_pELO, 1000.0); // To-Do: Sort by ELO
    var _gamesByELO : [MatchData] = Iter.toArray(searching.vals());
    for (m in _gamesByELO.vals()) {
      if (m.player2 == null and Principal.notEqual(m.player1.id, msg.caller) and (m.player1.lastPlayerActive + inactiveSeconds) > _now) {
        /// There's a match available, add the player to this match
        let _p2 : PlayerInfo = {
          id = msg.caller;
          elo = _pELO;
          matchAccepted = true; /// Force true for now
          playerGameData = pgd;
          lastPlayerActive = Nat64.fromIntWrap(Time.now());
        };
        let _p1 : PlayerInfo = {
          id = m.player1.id;
          elo = m.player1.elo;
          matchAccepted = true;
          playerGameData = m.player1.playerGameData;
          lastPlayerActive = m.player1.lastPlayerActive;
        };
        let _gameData : MatchData = {
          gameId = m.gameId;
          player1 = _p1;
          player2 = ?_p2;
          status = #Accepted;
        };
        let _p_s : PlayerStatus = {
          status = #Accepted;
          matchID = m.gameId;
        };
        inProgress.put(m.gameId, _gameData);
        let _removedSearching = searching.remove(m.gameId);
        removePlayersFromSearching(m.player1.id, msg.caller, m.gameId);
        playerStatus.put(msg.caller, _p_s);
        playerStatus.put(m.player1.id, _p_s);
        return (#Assigned, _matchID, "Game found");
      };
    };
    /// First we check if the player is already in a match
    switch (playerStatus.get(msg.caller)) {
      case (null) {}; /// Continue with search as this player is not currently in any status
      case (?_p) {
        ///  The player has a status, check which one
        switch (_p.status) {
          case (#Searching) {
            /// The player was already searching, return the status
            let _active : Bool = activatePlayerSearching(msg.caller, _p.matchID);
            if (_active == true) {
              return (#Assigned, _p.matchID, "Searching for game");
            };
          };
          case (#Reserved) {};
          case (#Accepting) {};
          case (#Accepted) {};
          case (#InGame) {};
          case (#Ended) {};
        };
      };
    };
    /// Continue with search as this player is not currently in any status
    _matchID := _matchID + 1;
    let _player : PlayerInfo = {
      id = msg.caller;
      elo = _pELO;
      matchAccepted = false;
      playerGameData = pgd;
      lastPlayerActive = Nat64.fromIntWrap(Time.now());
    };
    let _match : MatchData = {
      gameId = _matchID;
      player1 = _player;
      player2 = null;
      status = #Searching;
    };
    searching.put(_matchID, _match);
    let _ps : PlayerStatus = {
      status = #Searching;
      matchID = _matchID;
    };
    playerStatus.put(msg.caller, _ps);
    return (#Assigned, _matchID, "Lobby created");
  };

  func removePlayersFromSearching(p1 : Principal, p2 : Principal, matchID : Nat) {
    /// Check if player1 or player2 MatchID are different and remove them from the searching list
    switch (playerStatus.get(p1)) {
      case (null) {};
      case (?_p1) {
        if (_p1.matchID != matchID) {
          searching.delete(_p1.matchID);
        };
      };
    };
    switch (playerStatus.get(p2)) {
      case (null) {};
      case (?_p2) {
        if (_p2.matchID != matchID) {
          searching.delete(_p2.matchID);
        };
      };
    };
  };

  /// Cancel search on user's request
  public shared (msg) func cancelMatchmaking() : async (Bool, Text) {
    assert (msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
    switch (playerStatus.get(msg.caller)) {
      case (null) {
        return (true, "Game not found for this player");
      };
      case (?_s) {
        if (_s.status == #Searching) {
          searching.delete(_s.matchID);
          playerStatus.delete(msg.caller);
          return (true, "Matchmaking canceled successfully");
        } else {
          return (false, "Match found, cannot cancel at this time");
        };
      };
    };
  };

  func getOtherPlayer(_m : MatchData, caller : Principal) : ?Principal {
    switch (_m.player1.id == caller) {
      case (true) {
        switch (_m.player2) {
          case (null) {
            return (null);
          };
          case (?_p2) {
            return (?_p2.id);
          };
        };
      };
      case (false) {
        return (?_m.player1.id);
      };
    };
  };

  public shared query (msg) func isGameMatched() : async (Bool, Text) {
    switch (playerStatus.get(msg.caller)) {
      case (null) {
        return (false, "Game not found for this player");
      };
      case (?_s) {
        switch (searching.get(_s.matchID)) {
          case (null) {
            switch (inProgress.get(_s.matchID)) {
              case (null) {
                return (false, "Game not found for this player");
              };
              case (?_m) {
                return (true, "Game matched");
              };
            };
          };
          case (?_m) {
            switch (_m.player2) {
              case (null) {
                return (false, "Not matched yet");
              };
              case (?_p2) {
                return (true, "Game matched");
              };
            };
          };
        };
      };
    };
  };

  public query func getMatchData(matchID : Nat) : async ?MatchData {

    switch (searching.get(matchID)) {
      case (null) {
        switch (inProgress.get(matchID)) {
          case (null) {
            switch (finishedGames.get(matchID)) {
              case (null) {
                return (null);
              };
              case (?_m) {
                return (?_m);
              };
            };
          };
          case (?_m) {
            return (?_m);
          };
        };
      };
      case (?_m) {
        return (?_m);
      };
    };
  };

  public shared composite query (msg) func getMyMatchData() : async (?FullMatchData, Nat) {
    assert (msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
    // public shared(msg) func getMyMatchData() : async (?FullMatchData, Nat){
    switch (playerStatus.get(msg.caller)) {
      case (null) {
        return (null, 0);
      };
      case (?_s) {
        var _m : MatchData = switch (searching.get(_s.matchID)) {
          case (null) {
            switch (inProgress.get(_s.matchID)) {
              case (null) {
                switch (finishedGames.get(_s.matchID)) {
                  case (null) {
                    return (null, 0);
                  };
                  case (?_m) {
                    _m;
                  };
                };
              };
              case (?_m) {
                _m;
              };
            };
          };
          case (?_m) {
            _m;
          };
        };
        let _p : Nat = switch (_m.player1.id == msg.caller) {
          case (true) {
            1;
          };
          case (false) {
            switch (_m.player2) {
              case (null) {
                return (null, 0);
              };
              case (?_p2) {
                2;
              };
            };
          };
        };
        let _p1Name : Text = switch (await getPlayerData(_m.player1.id)) {
          case null {
            "";
          };
          case (?p1) {
            p1.name;
          };
        };
        let _fullPlayer2 : FullPlayerInfo = switch (_m.player2) {
          case null {
            {
              id = Principal.fromText("");
              matchAccepted = false;
              elo = 0;
              playerGameData = "";
              playerName = "";
            };
          };
          case (?p2) {
            let _p2D : ?Player = await getPlayerData(p2.id);
            switch (_p2D) {
              case null {
                {
                  id = p2.id;
                  matchAccepted = p2.matchAccepted;
                  elo = p2.elo;
                  playerGameData = p2.playerGameData;
                  playerName = "";
                };
              };
              case (?_p2D) {
                {
                  id = p2.id;
                  matchAccepted = p2.matchAccepted;
                  elo = p2.elo;
                  playerGameData = p2.playerGameData;
                  playerName = _p2D.name;
                };
              };
            };
          };
        };
        let _fullPlayer1 : FullPlayerInfo = {
          id = _m.player1.id;
          matchAccepted = _m.player1.matchAccepted;
          elo = _m.player1.elo;
          playerGameData = _m.player1.playerGameData;
          playerName = _p1Name;
        };
        let fm : FullMatchData = {
          gameId = _m.gameId;
          player1 = _fullPlayer1;
          player2 = ?_fullPlayer2;
          status = _m.status;
        };
        return (?fm, _p);

        // switch(searching.get(_s.matchID)){
        //     case(null){
        //         switch(inProgress.get(_s.matchID)){
        //             case(null){
        //                 switch(finishedGames.get(_s.matchID)){
        //                     case(null){
        //                         return(null, 0);
        //                     };
        //                     case(?_m){

        //                     };
        //                 };
        //             };
        //             case(?_m){
        //                 let _p : Nat = switch(_m.player1.id == msg.caller){
        //                     case(true){
        //                         1;
        //                     };
        //                     case(false){
        //                         switch(_m.player2){
        //                             case(null){
        //                                 return(null, 0);
        //                             };
        //                             case(?_p2){
        //                                 2;
        //                             };
        //                         };
        //                     };
        //                 };
        //                 return(?_m, _p);
        //             };
        //         };
        //     };
        //     case(?_m){
        //         let _p : Nat = switch(_m.player1.id == msg.caller){
        //             case(true){
        //                 1;
        //             };
        //             case(false){
        //                 switch(_m.player2){
        //                     case(null){
        //                         return(null, 0);
        //                     };
        //                     case(?_p2){
        //                         2;
        //                     };
        //                 };
        //             };
        //         };
        //         return(?_m, _p);
        //     };
        // };
      };
    };
  };

  public query func getAllSearching() : async [MatchData] {
    var _searchingList : [MatchData] = [];
    for (m in searching.vals()) {
      _searchingList := Array.append(_searchingList, [m]);
    };
    return _searchingList;
  };

  // let handlers = IcWebSocketCdk.WsHandlers(
  //     ?on_open,
  //     ?on_message,
  //     ?on_close,
  // );

  // let params = IcWebSocketCdk.WsInitParams(
  //     handlers,
  //     null,
  //     null,
  //     null,
  // );
  // var ws = IcWebSocketCdk.IcWebSocket(ws_state, params);

  //State functions
  system func preupgrade() {

    _userRecords := Iter.toArray(userRecords.entries());
    _players := Iter.toArray(players.entries());
    _playerPreferences := Iter.toArray(playerPreferences.entries());

    _activeRewards := Iter.toArray(activeRewards.entries());
    _rewardsUsers := Iter.toArray(rewardsUsers.entries());
    _unclaimedRewardsUsers := Iter.toArray(unclaimedRewardsUsers.entries());
    _finishedRewardsUsers := Iter.toArray(finishedRewardsUsers.entries());
    _expiredRewardsUsers := Iter.toArray(expiredRewardsUsers.entries());
    _userLastReward := Iter.toArray(userLastReward.entries());
    _expiredRewards := Iter.toArray(expiredRewards.entries());

    _basicStats := Iter.toArray(basicStats.entries());
    _playerGamesStats := Iter.toArray(playerGamesStats.entries());
    _onValidation := Iter.toArray(onValidation.entries());

    _searching := Iter.toArray(searching.entries());
    _inProgress := Iter.toArray(inProgress.entries());
    _finishedGames := Iter.toArray(finishedGames.entries());
  };
  system func postupgrade() {

    userRecords := HashMap.fromIter(_userRecords.vals(), 0, Principal.equal, Principal.hash);
    _players := [];
    _playerPreferences := [];

    _activeRewards := [];
    _rewardsUsers := [];
    _unclaimedRewardsUsers := [];
    _finishedRewardsUsers := [];
    _expiredRewardsUsers := [];
    _userLastReward := [];
    _expiredRewards := [];

    _basicStats := [];
    _playerGamesStats := [];
    _onValidation := [];

    _searching := [];
    _inProgress := [];
    _finishedGames := [];
  };

};
