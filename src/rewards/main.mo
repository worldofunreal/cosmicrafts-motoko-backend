import Types "./types";

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
import Bool "mo:base/Bool";
import Time "mo:base/Time";


actor class Rewards() {
    type PlayerID = Types.PlayerID;

    private stable var rewardID : Nat = 1;

    private stable var _cosmicraftsPrincipal : Principal = Principal.fromText("woimf-oyaaa-aaaan-qegia-cai");
    private stable var _statisticsPrincipal  : Principal = Principal.fromText("jybso-3iaaa-aaaan-qeima-cai");

    private var ONE_HOUR : Nat64 = 60 * 60 * 1_000_000_000; // 24 hours in nanoseconds
    private var NULL_PRINCIPAL: Principal = Principal.fromText("aaaaa-aa");
    private var ANON_PRINCIPAL: Principal = Principal.fromText("2vxsx-fae");
    

    /// Functions for finding Ships IDs
    func _natEqual (a : Nat, b : Nat) : Bool {
        return a == b;
    };
    func _natHash (a : Nat) : Hash.Hash {
        return Hash.hash(a);
    };

    /// Initialize variables
    private stable var _activeRewards : [(Nat, Types.Reward)] = [];
    var activeRewards : HashMap.HashMap<Nat, Types.Reward> = HashMap.fromIter(_activeRewards.vals(), 0, _natEqual, _natHash);

    private stable var _rewardsUsers : [(PlayerID, [Types.RewardsUser])] = [];
    var rewardsUsers : HashMap.HashMap<PlayerID, [Types.RewardsUser]> = HashMap.fromIter(_rewardsUsers.vals(), 0, Principal.equal, Principal.hash);

    private stable var _unclaimedRewardsUsers : [(PlayerID, [Types.RewardsUser])] = [];
    var unclaimedRewardsUsers : HashMap.HashMap<PlayerID, [Types.RewardsUser]> = HashMap.fromIter(_unclaimedRewardsUsers.vals(), 0, Principal.equal, Principal.hash);

    private stable var _finishedRewardsUsers : [(PlayerID, [Types.RewardsUser])] = [];
    var finishedRewardsUsers : HashMap.HashMap<PlayerID, [Types.RewardsUser]> = HashMap.fromIter(_finishedRewardsUsers.vals(), 0, Principal.equal, Principal.hash);

    private stable var _expiredRewardsUsers : [(PlayerID, [Types.RewardsUser])] = [];
    var expiredRewardsUsers : HashMap.HashMap<PlayerID, [Types.RewardsUser]> = HashMap.fromIter(_expiredRewardsUsers.vals(), 0, Principal.equal, Principal.hash);

    private stable var _userLastReward : [(PlayerID, Nat)] = [];
    var userLastReward : HashMap.HashMap<PlayerID, Nat> = HashMap.fromIter(_userLastReward.vals(), 0, Principal.equal, Principal.hash);

    private stable var _expiredRewards : [(Nat, Types.Reward)] = [];
    var expiredRewards : HashMap.HashMap<Nat, Types.Reward> = HashMap.fromIter(_expiredRewards.vals(), 0, _natEqual, _natHash);

    

    //State functions
    system func preupgrade() {
        _activeRewards         := Iter.toArray(activeRewards.entries());
        _rewardsUsers          := Iter.toArray(rewardsUsers.entries());
        _unclaimedRewardsUsers := Iter.toArray(unclaimedRewardsUsers.entries());
        _finishedRewardsUsers  := Iter.toArray(finishedRewardsUsers.entries());
        _expiredRewardsUsers   := Iter.toArray(expiredRewardsUsers.entries());
        _userLastReward        := Iter.toArray(userLastReward.entries());
        _expiredRewards        := Iter.toArray(expiredRewards.entries());
    };
    system func postupgrade() {
        _activeRewards         := [];
        _rewardsUsers          := [];
        _unclaimedRewardsUsers := [];
        _finishedRewardsUsers  := [];
        _expiredRewardsUsers   := [];
        _userLastReward        := [];
        _expiredRewards        := [];
    };



    /// Functions for rewards
    public shared(msg) func addReward (reward : Types.Reward) : async (Bool, Text, Nat) {
        if(Principal.notEqual(msg.caller, _cosmicraftsPrincipal)){
            return (false, "Unauthorized", 0);
        };
        let _newID = rewardID;
        activeRewards.put(_newID, reward);
        rewardID := rewardID + 1;
        return (true, "Reward added successfully", _newID);
    };

    public query func getReward (rewardID : Nat) : async ?Types.Reward {
        return(activeRewards.get(rewardID));
    };

    public shared query(msg) func getUserReward(_user : PlayerID, _idReward : Nat) : async ?Types.RewardsUser {
        if(Principal.notEqual(msg.caller, _cosmicraftsPrincipal)){
            return null;
        };
        switch(rewardsUsers.get(_user)){
            case (null) {
                return null;
            };
            case (?rewardsu) {
                for(r in rewardsu.vals()){
                    if(r.id_reward == _idReward){
                        return ?r;
                    };
                };
                return null;
            };
        };
    };

    public shared(msg) func claimedReward (_player : Principal, rewardID : Nat) : async (Bool, Text) {
        if(Principal.notEqual(msg.caller, _cosmicraftsPrincipal)){
            return (false, "Unauthorized");
        };
        switch(rewardsUsers.get(_player)) {
            case (null) {
                return (false, "User not found");
            };
            case (?rewardsu) {
                var _removed : Bool = false;
                var _message : Text = "Reward not found";
                var _userRewardsActive : [Types.RewardsUser] = [];
                for(r in rewardsu.vals()){
                    if(r.id_reward == rewardID){
                        if(r.finished == true){
                            var newUserRewardsFinished = switch(finishedRewardsUsers.get(_player)){
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
                return(_removed, _message);
            };
        };
    };

    public shared(msg) func addProgressToRewards(_player : Principal, rewardsProgress : [Types.RewardProgress]) : async (Bool, Text){
        if(Principal.notEqual(msg.caller, _statisticsPrincipal)){
            return (false, "Unauthorized");
        };
        if(Principal.equal(_player, NULL_PRINCIPAL)){
            return (false, "USER IS NULL. CANNOT ADD PROGRESS TO NULL USER");
        };
        if(Principal.equal(_player, ANON_PRINCIPAL)){
            return (false, "USER IS ANONYMOUS. CANNOT ADD PROGRESS TO ANONYMOUS USER");
        };
        let _rewards_user : [Types.RewardsUser] = switch(rewardsUsers.get(_player)){
            case (null) {
                addNewRewardsToUser(_player);
                // return (false, "User not found");
            };
            case (?rewardsu) {
                rewardsu;
            };
        };
        if(_rewards_user.size() == 0){
            return (false, "NO REWARDS FOUND FOR THIS USER");
        };
        if(rewardsProgress.size() == 0){
            return (false, "NO PROGRESS FOUND FOR THIS USER");
        };
        var _newUserRewards : [Types.RewardsUser] = [];
        let _now : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
        for(r in _rewards_user.vals()){
            var _finished = r.finished;
            if(_finished == false and r.start_date <= _now){
                if(r.expiration < _now){
                    var newUserRewardsExpired = switch(expiredRewardsUsers.get(_player)){
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
                    for(rp in rewardsProgress.vals()){
                        if(r.rewardType == rp.rewardType){
                            let _progress = r.progress;
                            var _finishedDate = r.finish_date;
                            let _r_u : Types.RewardsUser = {
                                expiration   = r.expiration;
                                start_date   = r.start_date;
                                finish_date  = _finishedDate;
                                finished     = _finished;
                                id_reward    = r.id_reward;
                                prize_amount = r.prize_amount;
                                prize_type   = r.prize_type;
                                progress     = _progress;
                                rewardType   = r.rewardType;
                                total        = r.total;
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

    func getAllUnexpiredActiveRewards (_from : ?Nat) : [Types.Reward] {
        let _now : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
        var _activeRewards : [Types.Reward] = [];
        let _fromNat : Nat = switch(_from){
            case (null) {
                0;
            };
            case (?f) {
                f;
            };
        };
        for(r in activeRewards.vals()){
            if(r.id > _fromNat){
                if(r.start_date <= _now){
                    if(r.end_date < _now){
                        /// Already expired, move it to expired list
                        let _expR = activeRewards.remove(r.id);
                        switch(_expR){
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

    public shared(msg) func getUserRewards(_player : Principal) : async [Types.RewardsUser] {
        if(Principal.notEqual(msg.caller, _cosmicraftsPrincipal)){
            return [];
        };
        return addNewRewardsToUser(_player);
    };

    // public shared(msg) func adminGetUserRewards(_player : Principal) : async [Types.RewardsUser] {
    //     return addNewRewardsToUser(_player);
    // };

    // public query func adminGetUserLastUpdate() : async ([(Principal, Nat)]) {
    //     return Iter.toArray(userLastReward.entries());
    // };

    public query func getAllUsersRewards() : async ([(Principal, [Types.RewardsUser])]) {
        return Iter.toArray(rewardsUsers.entries());
    };

    public query func getAllActiveRewards() : async (Nat, [(Types.Reward)]) {
        var _activeRewards : [Types.Reward] = [];
        var _expired : Nat = 0;
        let _now : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
        for(r in activeRewards.vals()){
            if(r.start_date <= _now){
                if(r.end_date < _now){
                    _expired := _expired + 1;
                } else {
                    _activeRewards := Array.append(_activeRewards, [r]);
                };
            };
        };
        return (_expired, _activeRewards);
    };

    func addNewRewardsToUser(_player : Principal) : [Types.RewardsUser]{
        /// Get last reward for this user
        var _newUserRewards = switch(userLastReward.get(_player)){
            case (null) {
                /// The user has no rewards yet
                /// Get all active rewards
                let _unexpiredRewards = getAllUnexpiredActiveRewards(null);
                var _newUserRewards : [Types.RewardsUser] = [];
                for(r in _unexpiredRewards.vals()){
                    let _r_u : Types.RewardsUser = {
                        expiration   = r.end_date;
                        start_date   = r.start_date;
                        finish_date  = r.end_date;
                        finished     = false;
                        id_reward    = r.id;
                        prize_amount = r.prize_amount;
                        prize_type   = r.prize_type;
                        progress     = 0;
                        rewardType   = r.rewardType;
                        total        = r.total;
                    };
                    /// Add the new reward to the user temp list
                    _newUserRewards := Array.append(_newUserRewards, [_r_u]);
                };
                _newUserRewards;
            };
            case (lastReward) {
                let _unexpiredRewards = getAllUnexpiredActiveRewards(lastReward);
                var _newUserRewards : [Types.RewardsUser] = [];
                for(r in _unexpiredRewards.vals()){
                    let _r_u : Types.RewardsUser = {
                        expiration   = r.end_date;
                        start_date   = r.start_date;
                        finish_date  = r.end_date;
                        finished     = false;
                        id_reward    = r.id;
                        prize_amount = r.prize_amount;
                        prize_type   = r.prize_type;
                        progress     = 0;
                        rewardType   = r.rewardType;
                        total        = r.total;
                    };
                    _newUserRewards := Array.append(_newUserRewards, [_r_u]);
                };
                _newUserRewards;
            };
        };
        switch(rewardsUsers.get(_player)){
            case (null) {
                userLastReward.put(_player, rewardID);
                rewardsUsers.put(_player, _newUserRewards);
                return _newUserRewards;
            };
            case (?rewardsu) {
                /// Append the new rewards with the previous ones for this user
                var _newRewards : [Types.RewardsUser] = [];
                for(r in rewardsu.vals()){
                    _newRewards := Array.append(_newRewards, [r]);
                };
                for(r in _newUserRewards.vals()){
                    _newRewards := Array.append(_newRewards, [r]);
                };
                userLastReward.put(_player, rewardID);
                rewardsUsers.put(_player, _newRewards);
                return _newRewards;
            };
        };
    };


    /// Function to create new rewards
    public shared(msg) func createReward (name : Text, rewardType : Types.RewardType, prizeType : Types.PrizeType, prizeAmount : Nat, total : Float, hours_active : Nat64) : async (Bool, Text) {
        let _now : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
        let _hoursActive = ONE_HOUR * hours_active;
        let endDate = _now + _hoursActive;
        // if(Principal.notEqual(msg.caller, _cosmicraftsPrincipal)){
        //     return (false, "Unauthorized");
        // };
        let _newReward : Types.Reward = {
            end_date     = endDate;
            id           = rewardID;
            name         = name;
            prize_amount = prizeAmount;
            prize_type   = prizeType;
            rewardType   = rewardType;
            start_date   = _now;
            total        = total;
        };
        activeRewards.put(rewardID, _newReward);
        rewardID := rewardID + 1;
        return (true, "Reward created successfully");
    };

};