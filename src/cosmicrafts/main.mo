import Types   "./types";
import TypesICRC1 "../ICRC1/Types";
import TypesICRC7 "../icrc7/types";
import TypesChests "../chests/types";
import TypesRewards "../rewards/types";
import Ledger  "./types/ledger_interface";
import Account "./Account";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Int64 "mo:base/Int64";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

import Token "../ICRC1/Canisters/Token";
import Flux "../Flux/Canisters/Token";
import Collection "../icrc7/main";
import Transfer "../ICRC1/Transfer";
import ChestsToken "../chests/main";
import Rewards "../rewards/main";

shared actor class Cosmicrafts() {
    type Player         = Types.Player;
    type PlayerId       = Types.PlayerId;
    type PlayerName     = Types.PlayerName;
    type TokenID        = Types.TokenId;
    type Account        = TypesICRC7.Account;
    type TransferArgs   = TypesICRC7.TransferArgs;
    type TransferResult = TypesICRC1.TransferResult;

    type Level      = Types.Level;
    type PlayerMP   = Types.Players;
    type PlayerPreferences = Types.PlayerPreferences;

    type OwnerResult = TypesICRC7.OwnerResult;

    private let ledger  : Ledger.Interface = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");
    // let scoreToken : Token.Token = actor("e3q2w-lqaaa-aaaai-aazva-cai"); /// Stoic Score Token
    let shardsToken     : Token.Token = actor("svcoe-6iaaa-aaaam-ab4rq-cai"); /// Cosmicraft's ICRC1 Token
    let fluxToken       : Flux.Flux = actor("plahz-wyaaa-aaaam-accta-cai"); /// Cosmicraft's Flux Token
    let nftsToken       : Collection.Collection = actor("phgme-naaaa-aaaap-abwda-cai"); /// Cosmicraft's ICRC7 Token
    let chestsToken     : ChestsToken.Chests = actor("w4fdk-fiaaa-aaaap-qccgq-cai"); /// Cosmicraft's Chests Tokens
    let rewardsCanister : Rewards.Rewards = actor("bm5s5-qqaaa-aaaap-qcgfq-cai"); /// Cosmicraft's Rewards Canister

    private stable var _cosmicPrincipal    : Principal = Principal.fromText("bcy24-rkxgs-yoxmr-qt7ub-qk2cy-2q6q7-mnztq-i7etk-noexw-ae7gi-wqe"); /// Cosmicraft's Principal
    private stable var _statisticPrincipal : Principal = Principal.fromActor(actor("jybso-3iaaa-aaaan-qeima-cai"));
    private stable var transfer_fee : Nat64 = 10_000;
    private stable var icrc1_fee : Nat64 = 1;
    private stable var upgrade_cost : TypesICRC1.Balance = 10;

    private stable var nftID : TokenID = 10000;
    private stable var chestID : TokenID = 10000;

    private stable var _players : [(PlayerId, Player)] = [];
    var players : HashMap.HashMap<PlayerId, Player> = HashMap.fromIter(_players.vals(), 0, Principal.equal, Principal.hash);
    private stable var _playerPreferences : [(PlayerId, PlayerPreferences)] = [];
    var playerPreferences : HashMap.HashMap<PlayerId, PlayerPreferences> = HashMap.fromIter(_playerPreferences.vals(), 0, Principal.equal, Principal.hash);

    //State functions
    system func preupgrade() {
        _players           := Iter.toArray(players.entries());
        _playerPreferences := Iter.toArray(playerPreferences.entries());
    };
    system func postupgrade() {
        _players           := [];
        _playerPreferences := [];
    };



    /// Player's rewards
    public shared(msg) func getUserRewards() : async [TypesRewards.RewardsUser] {
        return await rewardsCanister.getUserRewards(msg.caller);
    };


    /// PLAYERS LOGIC
    public shared(msg) func getPlayer() : async ?Player {
        return players.get(msg.caller);
    };

    public composite query func getPlayerData(player : Principal) : async ?Player {
        return players.get(player);
    };

    public shared query(msg) func getMyPlayerData() : async ?Player {
        return players.get(msg.caller);
    };

    public shared(msg) func createPlayer(name: Text) : async (Bool, Text) {
        switch(players.get(msg.caller)){
            case(null){
                let _level = 0;
                let player : Player = {
                    id    = msg.caller;
                    name  = name;
                    level = _level;
                    elo   = 1200;
                };
                players.put(msg.caller, player);
                let preferences : PlayerPreferences = {
                    language = 0;
                    playerChar = "";
                };
                playerPreferences.put(msg.caller, preferences);
                return (true, "Player created");
            };
            case(?_){
                return (false, "Player already exists");
            };
        };
    };

    public shared(msg) func savePlayerName(name: Text) : async Bool {
        switch(players.get(msg.caller)){
            case(null){
                return false;
            };
            case(?player){
                let _playerNew : Player = {
                    id    = player.id;
                    name  = name;
                    level = player.level;
                    elo   = player.elo;
                };
                players.put(msg.caller, _playerNew);
                return true;
            };
        };
    };

    public shared(msg) func getPlayerPreferences() : async ?PlayerPreferences {
        return playerPreferences.get(msg.caller);
    };

    public shared(msg) func savePlayerChar(_char : Text) : async (Bool, Text){
        switch(playerPreferences.get(msg.caller)){
            case(null){
                return (false, "Player not found");
            };
            case(?_p){
                let _playerNew : PlayerPreferences = {
                    language = _p.language;
                    playerChar = _char;
                };
                playerPreferences.put(msg.caller, _playerNew);
                return (true, "Player's character saved");
            };
        };
    };

    public shared(msg) func savePlayerLanguage(_lang: Nat) : async(Bool, Text){
        switch(playerPreferences.get(msg.caller)){
            case(null){
                return (false, "Player not found");
            };
            case(?_p){
                let _playerNew : PlayerPreferences = {
                    language   = _lang;
                    playerChar = _p.playerChar;
                };
                playerPreferences.put(msg.caller, _playerNew);
                return (true, "Player's language saved");
            };
        };
    };

    func getUserSubaccount(u : Principal) : Account.AccountIdentifier{
        return Account.accountIdentifier(Principal.fromActor(actor("onhpa-giaaa-aaaak-qaafa-cai")), Account.principalToSubaccount(u));
    };

    public shared(msg) func getICPBalance() : async {e8s:Nat64} {
        let {e8s = payment} = await ledger.account_balance({
            account = getUserSubaccount(msg.caller)
        });
    };

    public shared(msg) func mergeSkinNFTs(nftID : Nat, skinID : Nat) : async (Bool, Text){
        /// First we need to verify the user owns the NFT
        let ownerof : OwnerResult = await nftsToken.icrc7_owner_of(nftID);
        let _owner : Account = switch(ownerof){
            case(#Ok(owner)){
                owner;
            };
            case(#Err(_)){
                {owner = Principal.fromText("aaaaa-aa"); subaccount = null};
            };
        };
        if(Principal.notEqual(_owner.owner, msg.caller)){
            return (false, "You do not own this NFT. Caller: " # Principal.toText(msg.caller) # " Owner: " # Principal.toText(_owner.owner));
        };
        assert(_owner.owner == msg.caller);
        /// Then we need to get the NFT Metadata
        let metadata : TypesICRC7.MetadataResult = await nftsToken.icrc7_metadata(nftID);
        let _nftMetadata : [(Text, TypesICRC7.Metadata )] = switch(metadata){
            case(#Ok(metadata)){
                metadata;
            };
            case(#Err(_)){
                return (false, "NFT not found");
            };
        };
        var _newArgs : [(Text, TypesICRC7.Metadata)] = [];
        /// TO-DO: Implement merge logic, append skin to the NFT metadata
        return (true, "Work In Progress");
    };

    public shared(msg) func upgradeNFT(nftID : TokenID) : async (Bool, Text){
        /// First we need to verify the user owns the NFT
        let ownerof : OwnerResult = await nftsToken.icrc7_owner_of(nftID);
        let _owner : Account = switch(ownerof){
            case(#Ok(owner)){
                owner;
            };
            case(#Err(_)){
                {owner = Principal.fromText("aaaaa-aa"); subaccount = null};
            };
        };
        assert(_owner.owner == msg.caller);
        /// Then we need to get the NFT Metadata
        let metadata : TypesICRC7.MetadataResult = await nftsToken.icrc7_metadata(nftID);
        let _nftMetadata : [(Text, TypesICRC7.Metadata )] = switch(metadata){
            case(#Ok(metadata)){
                metadata;
            };
            case(#Err(_)){
                return (false, "NFT not found");
            };
        };
        var _newArgs : [(Text, TypesICRC7.Metadata)] = [];
        let _nftLevel : Nat = getNFTLevel(_nftMetadata);
        for (_md in _nftMetadata.vals()) {
            let _mdKey : Text = _md.0;
            let _mdValue : TypesICRC7.Metadata = _md.1;
            switch(_mdKey){
                case("skin"){
                    /// Skins do not upgrade with the NFT
                    _newArgs := Array.append(_newArgs, [("skin", _mdValue)]);
                };
                case("skills"){
                    let _upgradedAdvanced = upgradeAdvancedAttributes(_nftLevel, _mdValue);
                    _newArgs := Array.append(_newArgs, [("skills", _upgradedAdvanced)]);
                };
                case("souls"){
                    /// Souls do not upgrade with the NFT
                    _newArgs := Array.append(_newArgs, [("souls", _mdValue)]);
                };
                case("basic_stats"){
                    /// Basic stats do not upgrade with the NFT
                    let _basic_stats = updateBasicStats(_mdValue);
                    _newArgs := Array.append(_newArgs, [("basic_stats", _basic_stats)]);
                };
                case("general"){
                    /// General does not upgrade with the NFT
                    _newArgs := Array.append(_newArgs, [("general", _mdValue)]);
                };
                case(_){
                    /// Other attributes do not upgrade with the NFT
                    _newArgs := Array.append(_newArgs, [(_mdKey, _mdValue)]);
                };
            };
        };
        /// Then we need to take the amount of ICRC1 from the user's tokens to pay for this upgrade
        let _transactionsArgs = {
            amount : TypesICRC1.Balance = upgrade_cost;
            created_at_time : ?Nat64 = ?Nat64.fromNat(Int.abs(Time.now()));
            fee : ?TypesICRC1.Balance = ?Nat64.toNat(icrc1_fee);
            from_subaccount : ?TypesICRC1.Subaccount = null;//?getUserSubaccount(msg.caller);
            memo : ?Blob = null;
            // to : TypesICRC1.Account = { owner = _cosmicPrincipal; subaccount = null; };
            to : TypesICRC1.Account = { owner = Principal.fromText("3a6n7-myvuc-huq2n-dgpjx-fxa7y-4pteq-epbjf-sdeis-mqq5z-ak6ff-jqe"); subaccount = null; };
        };
        let transfer : TransferResult = await shardsToken.icrc1_pay_for_transaction(_transactionsArgs, msg.caller);
        /// Finally we need to call the upgrade funciton on the NFT contract
        switch(transfer){
            case(#Ok(_tok)){
                let _upgradeArgs : TypesICRC7.UpgradeArgs = {
                    from     = { owner = msg.caller; subaccount = null; };
                    token_id = nftID;
                    metadata = _newArgs;
                    date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
                };
                let upgrade : TypesICRC7.UpgradeReceipt = await nftsToken.upgradeNFT(_upgradeArgs);
                switch(upgrade){
                    case(#Ok(_)){
                        return (true, "NFT upgraded. Transaction ID: " # Nat.toText(_tok));
                    };
                    case(#Err(_e)){
                        switch(_e){
                            case(#DoesntExistTokenId){
                                return (false, "NFT upgrade failed: NFT not found");
                            };
                            case(#GenericError(_g)){
                                return (false, "NFT upgrade failed: GenericError: " # _g.message);
                            };
                            case(#InvalidRecipient){
                                return (false, "NFT upgrade failed: InvalidRecipient");
                            };
                            case(#Unauthorized){
                                return (false, "NFT upgrade failed: Unauthorized");
                            };
                        };
                    };
                };
            };
            case(#Err(_e)){
                switch(_e){
                    case(#BadBurn(_)){
                        return (false, "BadBurn");
                    };
                    case(#BadFee(_)){
                        return (false, "BadFee");
                    };
                    case(#CreatedInFuture(_)){
                        return (false, "CreatedInFuture");
                    };
                    case(#Duplicate(_)){
                        return (false, "Duplicate");
                    };
                    case(#GenericError(_g)){
                        return (false, "GenericError: " # _g.message);
                    };
                    case(#InsufficientFunds(_b)){
                        return (false, "InsufficientFunds: " # Nat.toText(_b.balance));
                    };
                    case(#TemporarilyUnavailable){
                        return (false, "TemporarilyUnavailable");
                    };
                    case(#TooOld){
                        return (false, "TooOld");
                    };
                };
            };
        };
    };

    public query func getNFTUpgradeCost() : async TypesICRC1.Balance {
        return upgrade_cost;
    };

    func getNFTLevel(metadata : [(Text, TypesICRC7.Metadata)]) : Nat {
        for (_md in metadata.vals()) {
            let _mdKey : Text = _md.0;
            let _mdValue : TypesICRC7.Metadata = _md.1;
            switch(_mdKey){
                /// Search for "basic_stats" and get the level from there
                case("basic_stats"){
                    switch(_mdValue){
                        case(#Nat(_)){
                            /// Not the level attribute
                        };
                        case(#Text(_)){
                            /// Not the level attribute
                        };
                        case(#Blob(_)){
                            /// Not the level attribute
                        };
                        case(#Int(_)){
                            /// Not the level attribute
                        };
                        case(#MetadataArray(_ma)){
                            for (_mad in _ma.vals()) {
                                let _mdValue : TypesICRC7.Metadata = _md.1;
                                switch(_mad.0){
                                    case("level"){
                                        return switch(_mdValue){
                                            case(#Nat(level)){
                                                level;
                                            };
                                            case(#Text(_)){
                                                0;
                                            };
                                            case(#Blob(_)){
                                                0;
                                            };
                                            case(#Int(_)){
                                                0;
                                            };
                                            case(#MetadataArray(_)){
                                                0;
                                            };
                                        };
                                    };
                                    case(_){
                                        /// Not the level attribute
                                    };
                                };
                            };
                        };
                    };
                };
                case(_){
                    /// Not the basic_stats attribute
                };
            };
        };
        return 1;
    };

    func upgradeAdvancedAttributes(nft_level : Nat, currentValue : TypesICRC7.Metadata) : TypesICRC7.Metadata {
        /// Upgrade the Skills value
        let _data : TypesICRC7.Metadata = switch(currentValue){
            case(#Nat(_)){
                currentValue;
            };
            case(#Text(_)){
                currentValue
            };
            case(#Blob(_)){
                currentValue
            };
            case(#Int(_)){
                currentValue
            };
            case(#MetadataArray(_a)){
                // Upgrade the metadata array
                /// Iterate in the array and upgrade the values
                /*
                    Advanced Stats:
                        - Shield Capacity
                        - Impairment Resistance
                        - Slow
                        - Weaken
                        - Stun
                        - Disarm
                        - Silence
                        - Armor
                        - Armor Penetration
                        - Attack Speed
                */
                var _newArray : TypesICRC7.MetadataArray = [];
                for (_md in _a.vals()) {
                    let _mdKey : Text = _md.0;
                    let _mdValue : TypesICRC7.Metadata = _md.1;
                    switch(_mdKey){
                        case("shield_capacity"){
                            switch(_mdValue){
                                case(#Nat(shield_capacity)){
                                    let _newShieldCapacity : Nat = shield_capacity + 1;
                                    let _newShieldCapacityMetadata : TypesICRC7.Metadata = #Nat(_newShieldCapacity);
                                    _newArray := Array.append(_newArray, [("shield_capacity", _newShieldCapacityMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(shield_capacity)){
                                    let _newShieldCapacity : Int = shield_capacity + 1;
                                    let _newShieldCapacityMetadata : TypesICRC7.Metadata = #Int(_newShieldCapacity);
                                    _newArray := Array.append(_newArray, [("shield_capacity", _newShieldCapacityMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("impairment_resistance"){
                            switch(_mdValue){
                                case(#Nat(impairment_resistance)){
                                    let _impairmentResistance : Nat = impairment_resistance + 1;
                                    let _newImpairmentResistance : TypesICRC7.Metadata = #Nat(_impairmentResistance);
                                    _newArray := Array.append(_newArray, [("impairment_resistance", _newImpairmentResistance)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(impairment_resistance)){
                                    let _impairmentResistance : Int = impairment_resistance + 1;
                                    let _newImpairmentResistance : TypesICRC7.Metadata = #Int(_impairmentResistance);
                                    _newArray := Array.append(_newArray, [("impairment_resistance", _newImpairmentResistance)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("slow"){
                            switch(_mdValue){
                                case(#Nat(slow)){
                                    let _newSlow : Nat = slow + 1;
                                    let _newSlowMetadata : TypesICRC7.Metadata = #Nat(_newSlow);
                                    _newArray := Array.append(_newArray, [("slow", _newSlowMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(slow)){
                                    let _newSlow : Int = slow + 1;
                                    let _newSlowMetadata : TypesICRC7.Metadata = #Int(_newSlow);
                                    _newArray := Array.append(_newArray, [("slow", _newSlowMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("weaken"){
                            switch(_mdValue){
                                case(#Nat(weaken)){
                                    let _newWeaken : Nat = weaken + 1;
                                    let _newWeakenMetadata : TypesICRC7.Metadata = #Nat(_newWeaken);
                                    _newArray := Array.append(_newArray, [("weaken", _newWeakenMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(weaken)){
                                    let _newWeaken : Int = weaken + 1;
                                    let _newWeakenMetadata : TypesICRC7.Metadata = #Int(_newWeaken);
                                    _newArray := Array.append(_newArray, [("weaken", _newWeakenMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("stun"){
                            switch(_mdValue){
                                case(#Nat(stun)){
                                    let _newStun : Nat = stun + 1;
                                    let _newStunMetadata : TypesICRC7.Metadata = #Nat(_newStun);
                                    _newArray := Array.append(_newArray, [("stun", _newStunMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(stun)){
                                    let _newStun : Int = stun + 1;
                                    let _newStunMetadata : TypesICRC7.Metadata = #Int(_newStun);
                                    _newArray := Array.append(_newArray, [("stun", _newStunMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("disarm"){
                            switch(_mdValue){
                                case(#Nat(disarm)){
                                    let _newDisarm : Nat = disarm + 1;
                                    let _newDisarmMetadata : TypesICRC7.Metadata = #Nat(_newDisarm);
                                    _newArray := Array.append(_newArray, [("disarm", _newDisarmMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(disarm)){
                                    let _newDisarm : Int = disarm + 1;
                                    let _newDisarmMetadata : TypesICRC7.Metadata = #Int(_newDisarm);
                                    _newArray := Array.append(_newArray, [("disarm", _newDisarmMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("silence"){
                            switch(_mdValue){
                                case(#Nat(silence)){
                                    let _newSilence : Nat = silence + 1;
                                    let _newSilenceMetadata : TypesICRC7.Metadata = #Nat(_newSilence);
                                    _newArray := Array.append(_newArray, [("silence", _newSilenceMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(silence)){
                                    let _newSilence : Int = silence + 1;
                                    let _newSilenceMetadata : TypesICRC7.Metadata = #Int(_newSilence);
                                    _newArray := Array.append(_newArray, [("silence", _newSilenceMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("armor"){
                            switch(_mdValue){
                                case(#Nat(armor)){
                                    let _newArmor : Nat = armor + 1;
                                    let _newArmorMetadata : TypesICRC7.Metadata = #Nat(_newArmor);
                                    _newArray := Array.append(_newArray, [("armor", _newArmorMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(armor)){
                                    let _newArmor : Int = armor + 1;
                                    let _newArmorMetadata : TypesICRC7.Metadata = #Int(_newArmor);
                                    _newArray := Array.append(_newArray, [("armor", _newArmorMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("armor_penetration"){
                            switch(_mdValue){
                                case(#Nat(armor_penetration)){
                                    let _newArmorPenetration : Nat = armor_penetration + 1;
                                    let _newArmorPenetrationMetadata : TypesICRC7.Metadata = #Nat(_newArmorPenetration);
                                    _newArray := Array.append(_newArray, [("armor_penetration", _newArmorPenetrationMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(armor_penetration)){
                                    let _newArmorPenetration : Int = armor_penetration + 1;
                                    let _newArmorPenetrationMetadata : TypesICRC7.Metadata = #Int(_newArmorPenetration);
                                    _newArray := Array.append(_newArray, [("armor_penetration", _newArmorPenetrationMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case("attack_speed"){
                            switch(_mdValue){
                                case(#Nat(attack_speed)){
                                    let _newAttackSpeed : Nat = attack_speed + 1;
                                    let _newAttackSpeedMetadata : TypesICRC7.Metadata = #Nat(_newAttackSpeed);
                                    _newArray := Array.append(_newArray, [("attack_speed", _newAttackSpeedMetadata)]);
                                };
                                case(#Text(_)){
                                    /// If text, do nothing
                                };
                                case(#Blob(_)){
                                    /// If blob, do nothing
                                };
                                case(#Int(attack_speed)){
                                    let _newAttackSpeed : Int = attack_speed + 1;
                                    let _newAttackSpeedMetadata : TypesICRC7.Metadata = #Int(_newAttackSpeed);
                                    _newArray := Array.append(_newArray, [("attack_speed", _newAttackSpeedMetadata)]);
                                };
                                case(#MetadataArray(_)){
                                    /// If metadata array, do nothing
                                };
                            };
                        };
                        case(_){
                            _newArray := Array.append(_newArray, [(_mdKey, _mdValue)]);
                        };
                    };
                };
                return #MetadataArray(_newArray);
            };
        };
    };

    public query func getPlayerElo(player : Principal) : async Float {
        return switch(players.get(player)){
            case(null){
                1200;
            };
            case(?_p){
                _p.elo;
            };
        };
    };

    public shared(msg) func updatePlayerElo(player : Principal, newELO : Float) : async Bool {
        assert(msg.caller == _statisticPrincipal); /// Only Statistics Canister can update ELO, change for statistics principal later
        let _player : Player = switch(players.get(player)){
            case(null){
                return false;
            };
            case(?_p){
                _p;
            };
        };
        /// Update ELO on player's data
        let _playerNew : Player = {
            id    = _player.id;
            name  = _player.name;
            level = _player.level;
            elo   = newELO;
        };
        players.put(player, _playerNew);
        return true;
    };

    public shared(msg) func mintNFT(player : Principal, rarity : Nat, unit_id : Nat) : async (Bool, Text){
        /// Call the NFT contract to mint a new NFT
        let uuid = await generateUUID64();
        let _mintArgs : TypesICRC7.MintArgs = {
            to = {owner = player; subaccount = null};
            token_id = uuid;
            metadata = getBaseMetadata(rarity, unit_id);
            date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
        };
        let mint : TypesICRC7.MintReceipt = await nftsToken.mint(_mintArgs);
        switch(mint){
            case(#Ok(_transactionID)){
                nftID := nftID + 1;
                return (true, "NFT minted. Transaction ID: " # Nat.toText(_transactionID));
            };
            case(#Err(_e)){
                switch(_e){
                    case(#AlreadyExistTokenId){
                        return (false, "NFT mint failed: Token ID already exists");
                    };
                    case(#GenericError(_g)){
                        return (false, "NFT mint failed: GenericError: " # _g.message);
                    };
                    case(#InvalidRecipient){
                        return (false, "NFT mint failed: InvalidRecipient");
                    };
                    case(#Unauthorized){
                        return (false, "NFT mint failed: Unauthorized");
                    };
                    case(#SupplyCapOverflow){
                        return (false, "NFT mint failed: SupplyCapOverflow");
                    };
                };
            };
        };
    };

    /// Mint Chests
    public shared(msg) func mintChest(player : Principal, rarity : Nat) : async (Bool, Text){
        /// Call the NFT contract to mint a new NFT
        let uuid = await generateUUID64();
        let _mintArgs : TypesICRC7.MintArgs = {
            to = {owner = player; subaccount = null};
            token_id = uuid;
            metadata = getChestMetadata(rarity);
            date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
        };
        let mint : TypesICRC7.MintReceipt = await chestsToken.mint(_mintArgs);
        switch(mint){
            case(#Ok(_transactionID)){
                chestID := chestID + 1;
                return (true, "NFT minted. Transaction ID: " # Nat.toText(_transactionID));
            };
            case(#Err(_e)){
                switch(_e){
                    case(#AlreadyExistTokenId){
                        return (false, "NFT mint failed: Token ID already exists");
                    };
                    case(#GenericError(_g)){
                        return (false, "NFT mint failed: GenericError: " # _g.message);
                    };
                    case(#InvalidRecipient){
                        return (false, "NFT mint failed: InvalidRecipient");
                    };
                    case(#Unauthorized){
                        return (false, "NFT mint failed: Unauthorized");
                    };
                    case(#SupplyCapOverflow){
                        return (false, "NFT mint failed: SupplyCapOverflow");
                    };
                };
            };
        };
    };

    func updateBasicStats(basicStats: TypesICRC7.Metadata) : TypesICRC7.Metadata {
    let _data: TypesICRC7.Metadata = switch (basicStats) {
        case (#Nat(_)) basicStats;
        case (#Text(_)) basicStats;
        case (#Blob(_)) basicStats;
        case (#Int(_)) basicStats;
        case (#MetadataArray(_a)) {
            // Upgrade the metadata array
            /// Iterate in the array and upgrade the values
            /*
                Basic Stats:
                    - Level
                    - Health
                    - Damage
            */
            var _newArray = Buffer.Buffer<(Text, TypesICRC7.Metadata)>(_a.size());

            for (_md in _a.vals()) {
                let _mdKey: Text = _md.0;
                let _mdValue: TypesICRC7.Metadata = _md.1;
                switch (_mdKey) {
                    case "level" {
                        let _level: Nat = switch (_mdValue) {
                            case (#Nat(level)) level + 1;
                            case (#Text(_)) 0;
                            case (#Blob(_)) 0;
                            case (#Int(_)) 0;
                            case (#MetadataArray(_)) 0;
                        };
                        let _newLevelMetadata: TypesICRC7.Metadata = #Nat(_level);
                        _newArray.add(("level", _newLevelMetadata));
                    };
                    case "health" {
                        let _health: Float = switch (_mdValue) {
                            case (#Int(health)) Float.fromInt64(Int64.fromInt(health)) / 100;
                            case (#Text(_)) 0;
                            case (#Blob(_)) 0;
                            case (#Nat(_)) 0;
                            case (#MetadataArray(_)) 0;
                        };
                        let _newHealth: Float = _health * 1.1 * 100;
                        let _newHealthMetadata: TypesICRC7.Metadata = #Int(Int64.toInt(Float.toInt64(_newHealth)));
                        _newArray.add(("health", _newHealthMetadata));
                    };
                    case "damage" {
                        let _damage: Float = switch (_mdValue) {
                            case (#Int(damage)) Float.fromInt64(Int64.fromInt(damage)) / 100;
                            case (#Text(_)) 0;
                            case (#Blob(_)) 0;
                            case (#Nat(_)) 0;
                            case (#MetadataArray(_)) 0;
                        };
                        let _newDamage: Float = _damage * 1.1 * 100;
                        let _newDamageMetadata: TypesICRC7.Metadata = #Int(Int64.toInt(Float.toInt64(_newDamage)));
                        _newArray.add(("damage", _newDamageMetadata));
                    };
                    case (_) {
                        _newArray.add((_mdKey, _mdValue));
                    };
                };
            };
            return #MetadataArray(_newArray.toArray());
        };
    };
    return _data;
};


    func getBaseMetadata(rarity : Nat, unit_id : Nat) : [(Text, TypesICRC7.Metadata)] {
        /* Basic Stats */
        let _basicStats : TypesICRC7.MetadataArray = [
            ("level", #Nat(1)),
            ("health", #Int(100)),
            ("damage", #Int(10))
        ];
        /* General */
        let _general : TypesICRC7.MetadataArray = [
            ("unit_id", #Nat(unit_id)),
            ("class", #Text("Warrior")),
            ("rarity", #Nat(rarity)),
            ("faction", #Text("Cosmicrafts")),
            ("name", #Text("Cosmicrafts NFT")),
            ("description", #Text("Cosmicrafts NFT")),
            ("icon", #Nat(1)),
            ("skins", #Text("[{skin_id: 1, skin_name: 'Default', skin_description: 'Default Skin', skin_icon: 'url_to_canister', skin_rarity: 1]"))
        ];
        /* Skills */
        let _skills : TypesICRC7.MetadataArray = [
            ("shield_capacity", #Int(1)),
            ("impairment_resistance", #Int(1)),
            ("slow", #Int(1)),
            ("weaken", #Int(1)),
            ("stun", #Int(1)),
            ("disarm", #Int(1)),
            ("silence", #Int(1)),
            ("armor", #Int(1)),
            ("armor_penetration", #Int(1)),
            ("attack_speed", #Int(1)),
        ];
        let _skins : TypesICRC7.MetadataArray = [
            ("1", #MetadataArray([
                ("skin_id", #Nat(1)),
                ("skin_name", #Text("Default")),
                ("skin_description", #Text("Default Skin")),
                ("skin_icon", #Text("url_to_canister")),
                ("skin_rarity", #Nat(1))
              ]
            ))
        ];
        /* Full Initial Metadata */
        let _baseMetadata : [(Text, TypesICRC7.Metadata)] = [
            ("basic_stats", #MetadataArray(_basicStats)),
            ("general", #MetadataArray(_general)),
            ("skills", #MetadataArray(_skills)),
            ("skins", #MetadataArray(_skins)),
        ];
        return _baseMetadata;
    };

    func getChestMetadata(rarity : Nat) : [(Text, TypesICRC7.Metadata)] {
        /* Full Initial Metadata */
        let _baseMetadata : [(Text, TypesICRC7.Metadata)] = [
            ("rarity", #Nat(rarity))
        ];
        return _baseMetadata;
    };

    public query func getAllPlayers() : async [Player] {
        return Iter.toArray(players.vals());
    };

    /// Open chests
    public shared(msg) func openChests(chestID : Nat) : async (Bool, Text) {
        /// First we need to verify the user owns the chest
        let ownerof : OwnerResult = await chestsToken.icrc7_owner_of(chestID);
        let _owner : Account = switch(ownerof){
            case(#Ok(owner)){
                owner;
            };
            case(#Err(_)){
                return (false, "{\"error\":true, \"message\":\"Chest not found\"}");
            };
        };
        if(Principal.notEqual(_owner.owner, msg.caller)){
            /// Return with JSON format
            return (false, "{\"error\":true, \"message\":\"Not the owner of the chest\"}");
        };
        /// Then we need to get the tokens to be minted and burn the chest
        let _chestArgs : TypesChests.OpenArgs = {
            from     = _owner;
            token_id = chestID;
        };
        let _tokens : TypesChests.OpenReceipt = await chestsToken.openChest(_chestArgs);
        var _tokensResults : Text = "";
        switch(_tokens){
            case(#Ok(_t)){
                for(_token in _t.vals()){
                    switch(_token.0){
                        case("shards"){
                            /// Mint shards to the caller
                            let _shardsArgs : TypesICRC1.Mint = {
                                to = { owner = msg.caller; subaccount = null };
                                amount = _token.1;
                                memo = null;
                                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                            };
                            let _tokenMinted : TypesICRC1.TransferResult = await shardsToken.mint(_shardsArgs);
                            switch(_tokenMinted){
                                case(#Ok(_tid)){
                                    _tokensResults := _tokensResults # "{\"token\":\"Shards\", \"transaction_id\": " # Nat.toText(_tid) # ", \"amount\": " # Nat.toText(_token.1) # "}";
                                };
                                /// Case error with JSON format
                                case(#Err(_e)){
                                    if(_tokensResults != ""){
                                        _tokensResults := _tokensResults # ", ";
                                    };
                                    switch(_e){
                                        case(#Duplicate(_d)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Shards\", \"error\":true, \"message\":\"Chest open failed: Shards mint failed: Duplicate\"}";
                                        };
                                        case(#GenericError(_g)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Shards\", \"error\":true, \"message\":\"Chest open failed: Shards mint failed: GenericError: " # _g.message # "\"}";
                                        };
                                        case(#CreatedInFuture(_cif)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Shards\", \"error\":true, \"message\":\"Chest open failed: Shards mint failed: CreatedInFuture\"}";
                                        };
                                        case(#BadFee(_bf)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Shards\", \"error\":true, \"message\":\"Chest open failed: Shards mint failed: BadFee\"}";
                                        };
                                        case(#BadBurn(_bb)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Shards\", \"error\":true, \"message\":\"Chest open failed: Shards mint failed: BadBurn\"}";
                                        };
                                        case(_){
                                            _tokensResults := _tokensResults # "{\"token\":\"Shards\", \"error\":true, \"message\":\"Chest open failed: Shards mint failed: Other error\"}";
                                        };
                                    };
                                };
                            };
                        };
                        case("flux"){
                            /// Mint flux to the caller
                            let _fluxArgs : TypesICRC1.Mint = {
                                to = { owner = msg.caller; subaccount = null };
                                amount = _token.1;
                                memo = null;
                                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                            };
                            let _tokenMinted : TypesICRC1.TransferResult = await fluxToken.mint(_fluxArgs);
                            switch(_tokenMinted){
                                case(#Ok(_tid)){
                                    /// JSON format
                                    _tokensResults := _tokensResults # "{\"token\":\"Flux\", \"transaction_id\": " # Nat.toText(_tid) # ", \"amount\": " # Nat.toText(_token.1) # "}";
                                    //_tokensResults := _tokensResults # " Flux Transaction ID: " # Nat.toText(_tid);
                                };
                                case(#Err(_e)){
                                    if(_tokensResults != ""){
                                        _tokensResults := _tokensResults # ", ";
                                    };
                                    /// Case error with JSON format and token field in json
                                    switch(_e){
                                        case(#Duplicate(_d)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Flux\", \"error\":true, \"message\":\"Chest open failed: Flux mint failed: Duplicate\"}";
                                        };
                                        case(#GenericError(_g)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Flux\", \"error\":true, \"message\":\"Chest open failed: Flux mint failed: GenericError: " # _g.message # "\"}";
                                        };
                                        case(#CreatedInFuture(_cif)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Flux\", \"error\":true, \"message\":\"Chest open failed: Flux mint failed: CreatedInFuture\"}";
                                        };
                                        case(#BadFee(_bf)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Flux\", \"error\":true, \"message\":\"Chest open failed: Flux mint failed: BadFee\"}";
                                        };
                                        case(#BadBurn(_bb)){
                                            _tokensResults := _tokensResults # "{\"token\":\"Flux\", \"error\":true, \"message\":\"Chest open failed: Flux mint failed: BadBurn\"}";
                                        };
                                        case(_){
                                            _tokensResults := _tokensResults # "{\"token\":\"Flux\", \"error\":true, \"message\":\"Chest open failed: Flux mint failed: Other error\"}";
                                        };
                                    };
                                };
                            };
                        };
                        case(_){
                            /// Unknown token
                        };
                    };
                };
            };
            case(#Err(_e)){
                /// Error with JSON format
                switch(_e){
                    case(#GenericError(_g)){
                        return (false, "{\"error\":true, \"message\":\"Chest open failed: GenericError: " # _g.message # "\"}");
                    };
                    case(#CreatedInFuture(_cif)){
                        return (false, "{\"error\":true, \"message\":\"Chest open failed: CreatedInFuture\"}");
                    };
                    case(#Duplicate(_d)){
                        return (false, "{\"error\":true, \"message\":\"Chest open failed: Duplicate\"}");
                    };
                    case(#TemporarilyUnavailable(_tu)){
                        return (false, "{\"error\":true, \"message\":\"Chest open failed: TemporarilyUnavailable\"}");
                    };
                    case(#TooOld){
                        return (false, "{\"error\":true, \"message\":\"Chest open failed: TooOld\"}");
                    };
                    case(#Unauthorized(_u)){
                        return (false, "{\"error\":true, \"message\":\"Chest open failed: Unauthorized\"}");
                    };
                }
            };
        };
        return (true, _tokensResults);
    };

    /// Mint deck with 8 units and random rarity within a range provided
   public shared(msg) func mintDeck(player: Principal) : async (Bool, Text) {
    let units = [
        ("Blackbird", 30, 120, 3),
        ("Predator", 20, 140, 2),
        ("Warhawk", 30, 180, 4),
        ("Tigershark", 10, 100, 1),
        ("Devastator", 20, 120, 2),
        ("Pulverizer", 10, 180, 3),
        ("Barracuda", 20, 140, 2),
        ("Farragut", 10, 220, 4)
    ];

    var _deck = Buffer.Buffer<TypesICRC7.MintArgs>(8);

    for (i in Iter.range(0, 7)) {
        let (name, damage, hp, rarity) = units[i];
        let uuid = await generateUUID64();
        let _mintArgs: TypesICRC7.MintArgs = {
            to = { owner = player; subaccount = null };
            token_id = uuid;
            metadata = getBaseMetadataWithAttributes(rarity, i + 1, name, damage, hp);
            date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
        };
        _deck.add(_mintArgs);
        nftID := nftID + 1;
    };

    let mint: TypesICRC7.MintReceipt = await nftsToken.mintDeck(_deck.toArray());
    switch (mint) {
        case (#Ok(_transactionID)) {
            return (true, "Deck minted. # NFTs: " # Nat.toText(_transactionID));
        };
        case (#Err(_e)) {
            switch (_e) {
                case (#AlreadyExistTokenId) {
                    return (false, "Deck mint failed: Token ID already exists");
                };
                case (#GenericError(_g)) {
                    return (false, "Deck mint failed: GenericError: " # _g.message);
                };
                case (#InvalidRecipient) {
                    return (false, "Deck mint failed: InvalidRecipient");
                };
                case (#Unauthorized) {
                    return (false, "Deck mint failed: Unauthorized");
                };
                case (#SupplyCapOverflow) {
                    return (false, "Deck mint failed: SupplyCapOverflow");
                };
            };
        };
    };
};


func getBaseMetadataWithAttributes(rarity: Nat, unit_id: Nat, name: Text, damage: Nat, hp: Nat) : [(Text, TypesICRC7.Metadata)] {
    let baseMetadata = getBaseMetadata(rarity, unit_id);

    var updatedMetadata: [(Text, TypesICRC7.Metadata)] = [];

    for ((key, value) in baseMetadata.vals()) {
        switch (key) {
            case ("general") {
                let generalArray = switch (value) {
                    case (#MetadataArray(arr)) arr;
                    case (_) [];
                };
                var newGeneralArray: TypesICRC7.MetadataArray = [];
                for ((gKey, gValue) in generalArray.vals()) {
                    switch (gKey) {
                        case "name" newGeneralArray := Array.append(newGeneralArray, [(gKey, #Text(name))]);
                        case "description" newGeneralArray := Array.append(newGeneralArray, [(gKey, #Text(name # " NFT"))]);
                        case _ newGeneralArray := Array.append(newGeneralArray, [(gKey, gValue)]);
                    };
                };
                updatedMetadata := Array.append(updatedMetadata, [(key, #MetadataArray(newGeneralArray))]);
            };
            case ("basic_stats") {
                let basicStatsArray = switch (value) {
                    case (#MetadataArray(arr)) arr;
                    case (_) [];
                };
                var newBasicStatsArray: TypesICRC7.MetadataArray = [];
                for ((bKey, bValue) in basicStatsArray.vals()) {
                    switch (bKey) {
                        case "health" newBasicStatsArray := Array.append(newBasicStatsArray, [(bKey, #Int(hp))]);
                        case "damage" newBasicStatsArray := Array.append(newBasicStatsArray, [(bKey, #Int(damage))]);
                        case _ newBasicStatsArray := Array.append(newBasicStatsArray, [(bKey, bValue)]);
                    };
                };
                updatedMetadata := Array.append(updatedMetadata, [(key, #MetadataArray(newBasicStatsArray))]);
            };
            case _ updatedMetadata := Array.append(updatedMetadata, [(key, value)]);
        };
    };
    return updatedMetadata;
};


    /// Rewards for users
    public shared(msg) func claimReward(idReward : Nat) : async (Bool, Text){
        let _reward : ?TypesRewards.RewardsUser = await rewardsCanister.getUserReward(msg.caller, idReward);
        switch(_reward){
            case(null){
                return (false, "Reward not found");
            };
            case(?_r){
                /// First lets check if the reward is finished
                if(_r.finished == true){
                    if(_r.finish_date > _r.expiration){
                        return (false, "Reward expired");
                    };
                    switch(_r.prize_type){
                        case(#Chest){
                            let _chestArgs : TypesICRC7.MintArgs = {
                                to = { owner = msg.caller; subaccount = null };
                                token_id = chestID;
                                metadata = getChestMetadata(_r.prize_amount);
                                date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
                            };
                            let mint : TypesICRC7.MintReceipt = await chestsToken.mint(_chestArgs);
                            switch(mint){
                                case(#Ok(_transactionID)){
                                    chestID := chestID + 1;
                                    let _removedReward = await rewardsCanister.claimedReward(msg.caller, idReward);
                                    return (_removedReward.0, _removedReward.1 # " - " # "Chest minted. Transaction ID: " # Nat.toText(_transactionID));
                                };
                                case(#Err(_e)){
                                    switch(_e){
                                        case(#AlreadyExistTokenId){
                                            return (false, "Chest mint failed: Token ID already exists");
                                        };
                                        case(#GenericError(_g)){
                                            return (false, "Chest mint failed: GenericError: " # _g.message);
                                        };
                                        case(#InvalidRecipient){
                                            return (false, "Chest mint failed: InvalidRecipient");
                                        };
                                        case(#Unauthorized){
                                            return (false, "Chest mint failed: Unauthorized");
                                        };
                                        case(#SupplyCapOverflow){
                                            return (false, "Chest mint failed: SupplyCapOverflow");
                                        };
                                    };
                                };
                            };
                        };
                        case(#Flux){
                            let _fluxArgs : TypesICRC1.Mint = {
                                to = { owner = msg.caller; subaccount = null };
                                amount = _r.prize_amount;
                                memo = null;
                                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                            };
                            let _tokenMinted : TypesICRC1.TransferResult = await fluxToken.mint(_fluxArgs);
                            switch(_tokenMinted){
                                case(#Ok(_tid)){
                                    let _removedReward = await rewardsCanister.claimedReward(msg.caller, idReward);
                                    return (_removedReward.0, _removedReward.1 # " - " # "Flux minted. Transaction ID: " # Nat.toText(_tid));
                                };
                                case(#Err(_e)){
                                    switch(_e){
                                        case(#Duplicate(_d)){
                                            return (false, "Flux mint failed: Duplicate");
                                        };
                                        case(#GenericError(_g)){
                                            return (false, "Flux mint failed: GenericError: " # _g.message);
                                        };
                                        case(#CreatedInFuture(_cif)){
                                            return (false, "Flux mint failed: CreatedInFuture");
                                        };
                                        case(#BadFee(_bf)){
                                            return (false, "Flux mint failed: BadFee");
                                        };
                                        case(#BadBurn(_bb)){
                                            return (false, "Flux mint failed: BadBurn");
                                        };
                                        case(_){
                                            return (false, "Flux mint failed: Other error");
                                        };
                                    };
                                };
                            };
                        };
                        case(#Shards){
                            let _shardsArgs : TypesICRC1.Mint = {
                                to = { owner = msg.caller; subaccount = null };
                                amount = _r.prize_amount;
                                memo = null;
                                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                            };
                            let _tokenMinted : TypesICRC1.TransferResult = await shardsToken.mint(_shardsArgs);
                            switch(_tokenMinted){
                                case(#Ok(_tid)){
                                    let _removedReward = await rewardsCanister.claimedReward(msg.caller, idReward);
                                    return (_removedReward.0, _removedReward.1 # " - " # "Shards minted. Transaction ID: " # Nat.toText(_tid));
                                };
                                case(#Err(_e)){
                                    switch(_e){
                                        case(#Duplicate(_d)){
                                            return (false, "Shards mint failed: Duplicate");
                                        };
                                        case(#GenericError(_g)){
                                            return (false, "Shards mint failed: GenericError: " # _g.message);
                                        };
                                        case(#CreatedInFuture(_cif)){
                                            return (false, "Shards mint failed: CreatedInFuture");
                                        };
                                        case(#BadFee(_bf)){
                                            return (false, "Shards mint failed: BadFee");
                                        };
                                        case(#BadBurn(_bb)){
                                            return (false, "Shards mint failed: BadBurn");
                                        };
                                        case(_){
                                            return (false, "Shards mint failed: Other error");
                                        };
                                    };
                                };
                            };
                        };
                    };
                } else {
                    return (false, "Reward not finished");
                };
            };
        };
    };
    
public shared func generateUUID64() : async Nat {
    // Generate a random blob of 8 bytes
    let randomBytes = await Random.blob();
    var uuid : Nat = 0;

    // Convert the blob to an array of bytes
    let byteArray = Blob.toArray(randomBytes);

    // Convert the array of bytes to Nat
    for (i in Iter.range(0, 7)) {
        uuid := Nat.add(Nat.bitshiftLeft(uuid, 8), Nat8.toNat(byteArray[i]));
    };
    
    // Ensure the generated Nat value is within the desired range
    uuid := uuid % 2147483647;

    return uuid;
};

};