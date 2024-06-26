import Types "./types";
import RewardsTypes "../rewards/types";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Int64 "mo:base/Int64";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";

import PlayersCanister "../mp_matchmaking/main";
import Validator "../validator/main";
import Cosmicrafts "../cosmicrafts/main";
import Rewards "../rewards/main";

actor class Statistics() {
    type GameID             = Types.GameID;
    type BasicStats         = Types.BasicStats;
    type PlayerID           = Types.PlayerID;
    type PlayerGamesStats   = Types.PlayerGamesStats;
    type OverallStats       = Types.OverallStats;
    type GamesWithFaction   = Types.GamesWithFaction;
    type GamesWithGameMode  = Types.GamesWithGameMode;
    type GamesWithCharacter = Types.GamesWithCharacter;
    type AverageStats       = Types.AverageStats;

    let multiplayerCanister : PlayersCanister.PlayersCanister = actor("vqzll-jiaaa-aaaan-qegba-cai"); /// multiplayer canister data
    let validatorCanister   : Validator.Validator = actor("2dzox-tqaaa-aaaan-qlphq-cai"); /// multiplayer canister data
    let cosmicraftsCanister : Cosmicrafts.Cosmicrafts = actor("woimf-oyaaa-aaaan-qegia-cai"); /// multiplayer canister data
    let rewardsCanister     : Rewards.Rewards = actor("bm5s5-qqaaa-aaaap-qcgfq-cai"); /// Cosmicraft's Rewards Canister

    private stable var _cosmicraftsPrincipal : Principal = Principal.fromText("woimf-oyaaa-aaaan-qegia-cai");

    private stable var k : Int = 30;

    private stable var overallStats : OverallStats = {
        totalGamesPlayed        : Nat   = 0;
        totalGamesSP            : Nat   = 0;
        totalGamesMP            : Nat   = 0;
        totalDamageDealt        : Float = 0;
        totalTimePlayed         : Float = 0;
        totalKills              : Float = 0;
        totalEnergyGenerated    : Float = 0;
        totalEnergyUsed         : Float = 0;
        totalEnergyWasted       : Float = 0;
        totalXpEarned           : Float = 0;
        totalGamesWithFaction   : [GamesWithFaction]   = [];
        totalGamesGameMode      : [GamesWithGameMode]  = [];
        totalGamesWithCharacter : [GamesWithCharacter] = [];
    };

    /// Functions for finding Ships IDs
    func _natEqual (a : Nat, b : Nat) : Bool {
        return a == b;
    };
    func _natHash (a : Nat) : Hash.Hash {
        return Hash.hash(a);
    };

    /// Initialize variables
    private stable var _basicStats : [(GameID, BasicStats)] = [];
    var basicStats : HashMap.HashMap<GameID, BasicStats> = HashMap.fromIter(_basicStats.vals(), 0, _natEqual, _natHash);

    private stable var _playerGamesStats : [(PlayerID, PlayerGamesStats)] = [];
    var playerGamesStats : HashMap.HashMap<PlayerID, PlayerGamesStats> = HashMap.fromIter(_playerGamesStats.vals(), 0, Principal.equal, Principal.hash);

    private stable var _onValidation : [(GameID, BasicStats)] = [];
    var onValidation : HashMap.HashMap<GameID, BasicStats> = HashMap.fromIter(_onValidation.vals(), 0, _natEqual, _natHash);

    //State functions
    system func preupgrade() {
        _basicStats       := Iter.toArray(basicStats.entries());
        _playerGamesStats := Iter.toArray(playerGamesStats.entries());
        _onValidation     := Iter.toArray(onValidation.entries());
    };
    system func postupgrade() {
        _basicStats       := [];
        _playerGamesStats := [];
        _onValidation     := [];
    };

    /* TO-DO ELO */
    /*
    ** DONE - Give each player their base ELO
    ** DONE - Increase / decrease the amount of ELO after each game
    ** Create list for players looking for games
    ** Search player matching / close ELO on matchmaking
    ** If no player is near, match with the closest ELO
    ** If no player is available then add it to the waiting list
    */

    private func initializeNewPlayerStats (_player : Principal) : async (Bool, Text) {
        let _playerStats : PlayerGamesStats = {
            gamesPlayed             = 0;
            gamesWon                = 0;
            gamesLost               = 0;
            energyGenerated         = 0;
            energyUsed              = 0;
            energyWasted            = 0;
            totalDamageDealt        = 0;
            totalDamageTaken        = 0;
            totalDamageCrit         = 0;
            totalDamageEvaded       = 0;
            totalXpEarned           = 0;
            totalGamesWithFaction   = [];
            totalGamesGameMode      = [];
            totalGamesWithCharacter = [];
        };
        playerGamesStats.put(_player, _playerStats);
        return (true, "Player stats initialized");
    };

    private func updatePlayerELO(playerID : PlayerID, won : Nat, otherPlayerID : ?PlayerID) : async Bool {
        switch(otherPlayerID){
            case(null){
                return false;
            };
            case(?_p){
                /// Get both player's ELO
                var _p1Elo : Float = await cosmicraftsCanister.getPlayerElo(playerID);
                let _p2Elo : Float = await cosmicraftsCanister.getPlayerElo(_p);
                /// Calculate expected results
                let _p1Expected : Float = 1 / (1 + Float.pow(10, (_p2Elo - _p1Elo) / 400));
                let _p2Expected : Float = 1 / (1 + Float.pow(10, (_p1Elo - _p2Elo) / 400));
                /// Update ELO
                let _elo : Float = _p1Elo + Float.fromInt(k) * (Float.fromInt64(Int64.fromInt(won)) - _p1Expected);
                let _updated = await cosmicraftsCanister.updatePlayerElo(playerID, _elo);
                return true;
            };
        };
    };

    public shared(msg) func saveFinishedGame (gameID : GameID, _basicStats : BasicStats) : async (Bool, Text) {
        /// End game on the matchmaking canister
        var _txt : Text = "";
        switch(basicStats.get(gameID)){
            case(null) {
                let endingGame : (Bool, Bool, ?Principal) = await multiplayerCanister.setGameOver(msg.caller);
                basicStats.put(gameID, _basicStats);
                let _gameValid : (Bool, Text) = await validatorCanister.validateGame(300 - _basicStats.secRemaining, _basicStats.energyUsed, _basicStats.xpEarned, 0.5);
                if(_gameValid.0 == false){
                    onValidation.put(gameID, _basicStats);
                    return (false, _gameValid.1);
                };
                /// Player stats
                let _winner = if(_basicStats.wonGame == true)  1 else 0;
                let _looser = if(_basicStats.wonGame == false) 1 else 0;
                let _elo : Bool = await updatePlayerELO(msg.caller, _winner, endingGame.2);
                var _progressRewards : [RewardsTypes.RewardProgress] = [{
                    rewardType = #GamesCompleted;
                    progress   = 1;
                }];
                if(_basicStats.wonGame == true){
                    let _wonProgress : RewardsTypes.RewardProgress = {
                        rewardType = #GamesWon;
                        progress   = 1;
                    };
                    _progressRewards := Array.append(_progressRewards, [_wonProgress]);
                };
                let _progressAdded = await rewardsCanister.addProgressToRewards(msg.caller, _progressRewards);
                _txt := _progressAdded.1;
                switch(playerGamesStats.get(msg.caller)){
                    case(null) {
                        let _gs : PlayerGamesStats = {
                            gamesPlayed             = 1;
                            gamesWon                = _winner;
                            gamesLost               = _looser;
                            energyGenerated         = _basicStats.energyGenerated;
                            energyUsed              = _basicStats.energyUsed;
                            energyWasted            = _basicStats.energyWasted;
                            totalDamageDealt        = _basicStats.damageDealt;
                            totalDamageTaken        = _basicStats.damageTaken;
                            totalDamageCrit         = _basicStats.damageCritic;
                            totalDamageEvaded       = _basicStats.damageEvaded;
                            totalXpEarned           = _basicStats.xpEarned;
                            totalGamesWithFaction   = [{factionID   = _basicStats.faction;     gamesPlayed = 1; gamesWon = _winner;}];
                            totalGamesGameMode      = [{gameModeID  = _basicStats.gameMode;    gamesPlayed = 1; gamesWon = _winner;}];
                            totalGamesWithCharacter = [{characterID = _basicStats.characterID; gamesPlayed = 1; gamesWon = _winner;}];
                        };
                        playerGamesStats.put(msg.caller, _gs);
                    };
                    case(?_bs){
                        var _gamesWithFaction        : [GamesWithFaction]   = []; 
                        var _gamesWithGameMode       : [GamesWithGameMode]  = [];
                        var _totalGamesWithCharacter : [GamesWithCharacter] = [];
                        for(gf in _bs.totalGamesWithFaction.vals()){
                            if(gf.factionID == _basicStats.faction){
                                _gamesWithFaction := Array.append(_gamesWithFaction, [{gamesPlayed = gf.gamesPlayed + 1; factionID = gf.factionID; gamesWon = gf.gamesWon + _winner;}] );
                            } else {
                                _gamesWithFaction := Array.append(_gamesWithFaction, [gf] );
                            };
                        };
                        for(gm in _bs.totalGamesGameMode.vals()){
                            if(gm.gameModeID == _basicStats.gameMode){
                                _gamesWithGameMode := Array.append(_gamesWithGameMode, [{gamesPlayed = gm.gamesPlayed + 1; gameModeID = gm.gameModeID; gamesWon = gm.gamesWon + _winner;}] );
                            } else {
                                _gamesWithGameMode := Array.append(_gamesWithGameMode, [gm] );
                            };
                        };
                        for(gc in _bs.totalGamesWithCharacter.vals()){
                            if(gc.characterID == _basicStats.characterID){
                                _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [{gamesPlayed = gc.gamesPlayed + 1; characterID = gc.characterID; gamesWon = gc.gamesWon + _winner;}] );
                            } else {
                                _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [gc] );
                            };
                        };
                        var _thisGameXP = _basicStats.xpEarned;
                        if(_basicStats.wonGame == true){
                            _thisGameXP := _thisGameXP * 2;
                        } else {
                            _thisGameXP := _thisGameXP * 0.5;
                        };
                        if(_basicStats.gameMode == 1){
                            _thisGameXP := _thisGameXP * 2;
                        } else {
                            _thisGameXP := _thisGameXP * 0.25;
                        };
                        let _gs : PlayerGamesStats = {
                            gamesPlayed             = _bs.gamesPlayed       + 1;
                            gamesWon                = _bs.gamesWon          + _winner;
                            gamesLost               = _bs.gamesLost         + _looser;
                            energyGenerated         = _bs.energyGenerated   + _basicStats.energyGenerated;
                            energyUsed              = _bs.energyUsed        + _basicStats.energyUsed;
                            energyWasted            = _bs.energyWasted      + _basicStats.energyWasted;
                            totalDamageDealt        = _bs.totalDamageDealt  + _basicStats.damageDealt;
                            totalDamageTaken        = _bs.totalDamageTaken  + _basicStats.damageTaken;
                            totalDamageCrit         = _bs.totalDamageCrit   + _basicStats.damageCritic;
                            totalDamageEvaded       = _bs.totalDamageEvaded + _basicStats.damageEvaded;
                            totalXpEarned           = _bs.totalXpEarned     + _thisGameXP;
                            totalGamesWithFaction   = _gamesWithFaction;
                            totalGamesGameMode      = _gamesWithGameMode;
                            totalGamesWithCharacter = _totalGamesWithCharacter;
                        };
                        playerGamesStats.put(msg.caller, _gs);
                    };
                };
                /// Overall stats
                var _totalGamesWithFaction   : [GamesWithFaction]   = [];
                var _totalGamesWithGameMode  : [GamesWithGameMode]  = [];
                var _totalGamesWithCharacter : [GamesWithCharacter] = [];
                for(gf in overallStats.totalGamesWithFaction.vals()){
                    if(gf.factionID == _basicStats.faction){
                        _totalGamesWithFaction := Array.append(_totalGamesWithFaction, [{gamesPlayed = gf.gamesPlayed + 1; factionID = gf.factionID; gamesWon = gf.gamesWon + _winner;}] );
                    } else {
                        _totalGamesWithFaction := Array.append(_totalGamesWithFaction, [gf] );
                    };
                };
                for(gm in overallStats.totalGamesGameMode.vals()){
                    if(gm.gameModeID == _basicStats.gameMode){
                        _totalGamesWithGameMode := Array.append(_totalGamesWithGameMode, [{gamesPlayed = gm.gamesPlayed + 1; gameModeID = gm.gameModeID; gamesWon = gm.gamesWon + _winner;}] );
                    } else {
                        _totalGamesWithGameMode := Array.append(_totalGamesWithGameMode, [gm] );
                    };
                };
                for(gc in overallStats.totalGamesWithCharacter.vals()){
                    if(gc.characterID == _basicStats.characterID){
                        _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [{gamesPlayed = gc.gamesPlayed + 1; characterID = gc.characterID; gamesWon = gc.gamesWon + _winner;}] );
                    } else {
                        _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [gc] );
                    };
                };
                let _os : OverallStats = {
                    totalGamesPlayed        = overallStats.totalGamesPlayed + 1;
                    totalGamesSP            = if(_basicStats.gameMode == 2) overallStats.totalGamesSP + 1 else overallStats.totalGamesSP;
                    totalGamesMP            = if(_basicStats.gameMode == 1) overallStats.totalGamesMP + 1 else overallStats.totalGamesMP;
                    totalDamageDealt        = overallStats.totalDamageDealt + _basicStats.damageDealt;
                    totalTimePlayed         = overallStats.totalTimePlayed;
                    totalKills              = overallStats.totalKills + _basicStats.kills;
                    totalEnergyUsed         = overallStats.totalEnergyUsed + _basicStats.energyUsed;
                    totalEnergyGenerated    = overallStats.totalEnergyGenerated + _basicStats.energyGenerated;
                    totalEnergyWasted       = overallStats.totalEnergyWasted + _basicStats.energyWasted;
                    totalGamesWithFaction   = _totalGamesWithFaction;
                    totalGamesGameMode      = _totalGamesWithGameMode;
                    totalGamesWithCharacter = _totalGamesWithCharacter;
                    totalXpEarned           = overallStats.totalXpEarned + _basicStats.xpEarned;
                };
                overallStats := _os;
                return (true, "Game saved");
            };
            case(?_bs){
                /// Was saved before, only save the respective variables
                /// Also validate info vs other save
                let endingGame = await multiplayerCanister.setGameOver(msg.caller);
                let _winner = if(_basicStats.wonGame == true)  1 else 0;
                let _looser = if(_basicStats.wonGame == false) 1 else 0;
                let _elo : Bool = await updatePlayerELO(msg.caller, _winner, endingGame.2);
                var _progressRewards : [RewardsTypes.RewardProgress] = [{
                    rewardType = #GamesCompleted;
                    progress   = 1;
                }];
                if(_basicStats.wonGame == true){
                    let _wonProgress : RewardsTypes.RewardProgress = {
                        rewardType = #GamesWon;
                        progress   = 1;
                    };
                    _progressRewards := Array.append(_progressRewards, [_wonProgress]);
                };
                let _progressAdded = await rewardsCanister.addProgressToRewards(msg.caller, _progressRewards);
                _txt := _progressAdded.1;
                switch(playerGamesStats.get(msg.caller)){
                    case(null) {
                        let _gs : PlayerGamesStats = {
                            gamesPlayed             = 1;
                            gamesWon                = _winner;
                            gamesLost               = _looser;
                            energyGenerated         = _basicStats.energyGenerated;
                            energyUsed              = _basicStats.energyUsed;
                            energyWasted            = _basicStats.energyWasted;
                            totalDamageDealt        = _basicStats.damageDealt;
                            totalDamageTaken        = _basicStats.damageTaken;
                            totalDamageCrit         = _basicStats.damageCritic;
                            totalDamageEvaded       = _basicStats.damageEvaded;
                            totalXpEarned           = _basicStats.xpEarned;
                            totalGamesWithFaction   = [{factionID   = _basicStats.faction;     gamesPlayed = 1; gamesWon = _winner;}];
                            totalGamesGameMode      = [{gameModeID  = _basicStats.gameMode;    gamesPlayed = 1; gamesWon = _winner;}];
                            totalGamesWithCharacter = [{characterID = _basicStats.characterID; gamesPlayed = 1; gamesWon = _winner;}];
                        };
                        playerGamesStats.put(msg.caller, _gs);
                    };
                    case(?_bs){
                        var _gamesWithFaction        : [GamesWithFaction]   = []; 
                        var _gamesWithGameMode       : [GamesWithGameMode]  = [];
                        var _totalGamesWithCharacter : [GamesWithCharacter] = [];
                        for(gf in _bs.totalGamesWithFaction.vals()){
                            if(gf.factionID == _basicStats.faction){
                                _gamesWithFaction := Array.append(_gamesWithFaction, [{gamesPlayed = gf.gamesPlayed + 1; factionID = gf.factionID; gamesWon = gf.gamesWon + _winner;}] );
                            } else {
                                _gamesWithFaction := Array.append(_gamesWithFaction, [gf] );
                            };
                        };
                        for(gm in _bs.totalGamesGameMode.vals()){
                            if(gm.gameModeID == _basicStats.gameMode){
                                _gamesWithGameMode := Array.append(_gamesWithGameMode, [{gamesPlayed = gm.gamesPlayed + 1; gameModeID = gm.gameModeID; gamesWon = gm.gamesWon + _winner;}] );
                            } else {
                                _gamesWithGameMode := Array.append(_gamesWithGameMode, [gm] );
                            };
                        };
                        for(gc in _bs.totalGamesWithCharacter.vals()){
                            if(gc.characterID == _basicStats.characterID){
                                _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [{gamesPlayed = gc.gamesPlayed + 1; characterID = gc.characterID; gamesWon = gc.gamesWon + _winner;}] );
                            } else {
                                _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [gc] );
                            };
                        };
                        var _thisGameXP = _basicStats.xpEarned;
                        if(_basicStats.wonGame == true){
                            _thisGameXP := _thisGameXP * 2;
                        } else {
                            _thisGameXP := _thisGameXP * 0.5;
                        };
                        if(_basicStats.gameMode == 1){
                            _thisGameXP := _thisGameXP * 2;
                        } else {
                            _thisGameXP := _thisGameXP * 0.25;
                        };
                        let _gs : PlayerGamesStats = {
                            gamesPlayed             = _bs.gamesPlayed       + 1;
                            gamesWon                = _bs.gamesWon          + _winner;
                            gamesLost               = _bs.gamesLost         + _looser;
                            energyGenerated         = _bs.energyGenerated   + _basicStats.energyGenerated;
                            energyUsed              = _bs.energyUsed        + _basicStats.energyUsed;
                            energyWasted            = _bs.energyWasted      + _basicStats.energyWasted;
                            totalDamageDealt        = _bs.totalDamageDealt  + _basicStats.damageDealt;
                            totalDamageTaken        = _bs.totalDamageTaken  + _basicStats.damageTaken;
                            totalDamageCrit         = _bs.totalDamageCrit   + _basicStats.damageCritic;
                            totalDamageEvaded       = _bs.totalDamageEvaded + _basicStats.damageEvaded;
                            totalXpEarned           = _bs.totalXpEarned     + _thisGameXP;
                            totalGamesWithFaction   = _gamesWithFaction;
                            totalGamesGameMode      = _gamesWithGameMode;
                            totalGamesWithCharacter = _totalGamesWithCharacter;
                        };
                        playerGamesStats.put(msg.caller, _gs);
                    };
                };
                /// Overall stats
                var _totalGamesWithFaction   : [GamesWithFaction]   = [];
                var _totalGamesWithCharacter : [GamesWithCharacter] = [];
                for(gf in overallStats.totalGamesWithFaction.vals()){
                    if(gf.factionID == _basicStats.faction){
                        _totalGamesWithFaction := Array.append(_totalGamesWithFaction, [{gamesPlayed = gf.gamesPlayed + 1; factionID = gf.factionID; gamesWon = gf.gamesWon + _winner;}] );
                    } else {
                        _totalGamesWithFaction := Array.append(_totalGamesWithFaction, [gf] );
                    };
                };
                for(gc in overallStats.totalGamesWithCharacter.vals()){
                    if(gc.characterID == _basicStats.characterID){
                        _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [{gamesPlayed = gc.gamesPlayed + 1; characterID = gc.characterID; gamesWon = gc.gamesWon + _winner;}] );
                    } else {
                        _totalGamesWithCharacter := Array.append(_totalGamesWithCharacter, [gc] );
                    };
                };
                let _os : OverallStats = {
                    totalGamesPlayed        = overallStats.totalGamesPlayed + 1;
                    totalGamesSP            = if(_basicStats.gameMode == 2) overallStats.totalGamesSP + 1 else overallStats.totalGamesSP;
                    totalGamesMP            = if(_basicStats.gameMode == 1) overallStats.totalGamesMP + 1 else overallStats.totalGamesMP;
                    totalDamageDealt        = overallStats.totalDamageDealt + _basicStats.damageDealt;
                    totalTimePlayed         = overallStats.totalTimePlayed;
                    totalKills              = overallStats.totalKills + _basicStats.kills;
                    totalEnergyUsed         = overallStats.totalEnergyUsed + _basicStats.energyUsed;
                    totalEnergyGenerated    = overallStats.totalEnergyGenerated + _basicStats.energyGenerated;
                    totalEnergyWasted       = overallStats.totalEnergyWasted + _basicStats.energyWasted;
                    totalGamesWithFaction   = _totalGamesWithFaction;
                    totalGamesGameMode      = overallStats.totalGamesGameMode;
                    totalGamesWithCharacter = _totalGamesWithCharacter;
                    totalXpEarned           = overallStats.totalXpEarned + _basicStats.xpEarned;
                };
                overallStats := _os;
                return (true, _txt # " - Game saved");
            };
        };
    };

    public query func getOverallStats () : async OverallStats {
        return overallStats;
    };

    public query func getAverageStats () : async AverageStats {
        let _averageStats : AverageStats = {
            averageEnergyGenerated  = overallStats.totalEnergyGenerated / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
            averageEnergyUsed       = overallStats.totalEnergyUsed      / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
            averageEnergyWasted     = overallStats.totalEnergyWasted    / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
            averageDamageDealt      = overallStats.totalDamageDealt     / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
            averageKills            = overallStats.totalKills           / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
            averageXpEarned         = overallStats.totalXpEarned        / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(overallStats.totalGamesPlayed)));
        };
        return _averageStats;
    };

    public shared query(msg) func getMyStats () : async ?PlayerGamesStats {
        switch(playerGamesStats.get(msg.caller)){
            case(null){
                let _playerStats : PlayerGamesStats = {
                    gamesPlayed             = 0;
                    gamesWon                = 0;
                    gamesLost               = 0;
                    energyGenerated         = 0;
                    energyUsed              = 0;
                    energyWasted            = 0;
                    totalDamageDealt        = 0;
                    totalDamageTaken        = 0;
                    totalDamageCrit         = 0;
                    totalDamageEvaded       = 0;
                    totalXpEarned           = 0;
                    totalGamesWithFaction   = [];
                    totalGamesGameMode      = [];
                    totalGamesWithCharacter = [];
                };
                return ?_playerStats;
            };
            case(?_p){
                return playerGamesStats.get(msg.caller);
            };
        };
    };

    public shared query(msg) func getMyAverageStats () : async ?AverageStats {
        switch(playerGamesStats.get(msg.caller)){
            case(null){
                let _newAverageStats : AverageStats = {
                    averageEnergyGenerated  = 0;
                    averageEnergyUsed       = 0;
                    averageEnergyWasted     = 0;
                    averageDamageDealt      = 0;
                    averageKills            = 0;
                    averageXpEarned         = 0;
                };
                return ?_newAverageStats;
            };
            case(?_p){
                let _averageStats : AverageStats = {
                    averageEnergyGenerated  = _p.energyGenerated  / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageEnergyUsed       = _p.energyUsed       / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageEnergyWasted     = _p.energyWasted     / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageDamageDealt      = _p.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageKills            = _p.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageXpEarned         = _p.totalXpEarned    / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                };
                return ?_averageStats;
            };
        }
    };

    public shared query(msg) func getBasicStats (gameID : GameID) : async ?BasicStats {
        return basicStats.get(gameID);
    };

    public query func getPlayerStats (_player : Principal) : async ?PlayerGamesStats {
        switch(playerGamesStats.get(_player)){
            case(null){
                let _playerStats : PlayerGamesStats = {
                    gamesPlayed             = 0;
                    gamesWon                = 0;
                    gamesLost               = 0;
                    energyGenerated         = 0;
                    energyUsed              = 0;
                    energyWasted            = 0;
                    totalDamageDealt        = 0;
                    totalDamageTaken        = 0;
                    totalDamageCrit         = 0;
                    totalDamageEvaded       = 0;
                    totalXpEarned           = 0;
                    totalGamesWithFaction   = [];
                    totalGamesGameMode      = [];
                    totalGamesWithCharacter = [];
                };
                return ?_playerStats;
            };
            case(?_p){
                return playerGamesStats.get(_player);
            };
        };
        return playerGamesStats.get(_player);
    };

    public query func getPlayerAverageStats (_player : Principal) : async ?AverageStats {
        switch(playerGamesStats.get(_player)){
            case(null){
                let _newAverageStats : AverageStats = {
                    averageEnergyGenerated  = 0;
                    averageEnergyUsed       = 0;
                    averageEnergyWasted     = 0;
                    averageDamageDealt      = 0;
                    averageKills            = 0;
                    averageXpEarned         = 0;
                };
                return ?_newAverageStats;
            };
            case(?_p){
                let _averageStats : AverageStats = {
                    averageEnergyGenerated  = _p.energyGenerated  / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageEnergyUsed       = _p.energyUsed       / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageEnergyWasted     = _p.energyWasted     / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageDamageDealt      = _p.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageKills            = _p.totalDamageDealt / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                    averageXpEarned         = _p.totalXpEarned    / Float.fromInt64(Int64.fromNat64(Nat64.fromNat(_p.gamesPlayed)));
                };
                return ?_averageStats;
            };
        }
    };



    // Validation Data
    public query func getAllOnValidation () : async [(GameID, BasicStats)] {
        return _onValidation;
    };

    public shared(msg) func setGameValid(gameID : GameID) : async Bool {
        switch(onValidation.get(gameID)){
            case(null){
                return false;
            };
            case(?_bs){
                onValidation.delete(gameID);
                basicStats.put(gameID, _bs);
                return true;
            };
        };
    };
};