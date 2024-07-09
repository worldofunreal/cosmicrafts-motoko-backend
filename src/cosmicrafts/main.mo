import Types "./types";
import TypesICRC1 "../ICRC1/Types";
import TypesICRC7 "../icrc7/types";
import TypesChests "../chests/types";
import TypesRewards "../player/RewardsTypes";
import Ledger "./types/ledger_interface";
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

import Player "../player/main";

shared actor class Cosmicrafts() {
  type Player = Types.Player;
  type PlayerId = Types.PlayerId;
  type PlayerName = Types.PlayerName;
  type TokenID = Types.TokenId;
  type Account = TypesICRC7.Account;
  type TransferArgs = TypesICRC7.TransferArgs;
  type TransferResult = TypesICRC1.TransferResult;

  type OwnerResult = TypesICRC7.OwnerResult;

  private let ledger : Ledger.Interface = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");
  let shardsToken : Token.Token = actor ("svcoe-6iaaa-aaaam-ab4rq-cai");
  let fluxToken : Flux.Flux = actor ("plahz-wyaaa-aaaam-accta-cai");
  let nftsToken : Collection.Collection = actor ("phgme-naaaa-aaaap-abwda-cai");
  let chestsToken : ChestsToken.Chests = actor ("w4fdk-fiaaa-aaaap-qccgq-cai");

  let rewardsCanister : Player.Player = actor ("bm5s5-qqaaa-aaaap-qcgfq-cai");

  private stable var _cosmicPrincipal : Principal = Principal.fromText("bcy24-rkxgs-yoxmr-qt7ub-qk2cy-2q6q7-mnztq-i7etk-noexw-ae7gi-wqe");
  private stable var _statisticPrincipal : Principal = Principal.fromActor(actor ("jybso-3iaaa-aaaan-qeima-cai"));
  //private stable var transfer_fee : Nat64 = 10_000;
  private stable var icrc1_fee : Nat64 = 1;
  //private stable var upgrade_cost : TypesICRC1.Balance = 10;

  private stable var nftID : TokenID = 10000;
  private stable var chestID : TokenID = 10000;

  func getUserSubaccount(u : Principal) : Account.AccountIdentifier {
    return Account.accountIdentifier(Principal.fromActor(actor ("onhpa-giaaa-aaaak-qaafa-cai")), Account.principalToSubaccount(u));
  };

  public shared (msg) func getICPBalance() : async { e8s : Nat64 } {
    let { e8s = payment } = await ledger.account_balance({
      account = getUserSubaccount(msg.caller);
    });
  };

  public shared (msg) func mergeSkinNFTs(nftID : Nat, skinID : Nat) : async (Bool, Text) {
    /// First we need to verify the user owns the NFT
    let ownerof : OwnerResult = await nftsToken.icrc7_owner_of(nftID);
    let _owner : Account = switch (ownerof) {
      case (#Ok(owner)) {
        owner;
      };
      case (#Err(_)) {
        { owner = Principal.fromText("aaaaa-aa"); subaccount = null };
      };
    };
    if (Principal.notEqual(_owner.owner, msg.caller)) {
      return (false, "You do not own this NFT. Caller: " # Principal.toText(msg.caller) # " Owner: " # Principal.toText(_owner.owner));
    };
    assert (_owner.owner == msg.caller);
    /// Then we need to get the NFT Metadata
    let metadata : TypesICRC7.MetadataResult = await nftsToken.icrc7_metadata(nftID);
    let _nftMetadata : [(Text, TypesICRC7.Metadata)] = switch (metadata) {
      case (#Ok(metadata)) {
        metadata;
      };
      case (#Err(_)) {
        return (false, "NFT not found");
      };
    };
    var _newArgs : [(Text, TypesICRC7.Metadata)] = [];
    /// TO-DO: Implement merge logic, append skin to the NFT metadata
    return (true, "Work In Progress");
  };

  public shared (msg) func upgradeNFT(nftID : TokenID) : async (Bool, Text) {
    // Initiate metadata retrieval in the background
    let metadataFuture = async { await nftsToken.icrc7_metadata(nftID) };

    // Perform ownership check
    let ownerof : OwnerResult = await nftsToken.icrc7_owner_of(nftID);
    let _owner : Account = switch (ownerof) {
      case (#Ok(owner)) owner;
      case (#Err(_)) return (false, "{\"success\":false, \"message\":\"NFT not found\"}");
    };
    if (Principal.notEqual(_owner.owner, msg.caller)) {
      return (false, "{\"success\":false, \"message\":\"You do not own this NFT.\"}");
    };

    // Wait for metadata retrieval
    let metadataResult = await metadataFuture;
    let _nftMetadata : [(Text, TypesICRC7.Metadata)] = switch (metadataResult) {
      case (#Ok(metadata)) metadata;
      case (#Err(_)) return (false, "NFT not found");
    };

    // Send the process to the background
    ignore _processUpgrade(nftID, msg.caller, _nftMetadata);

    // Immediate placeholder response to Unity
    let placeholderResponse = "{\"success\":true, \"message\":\"Upgrade initiated\"}";
    return (true, placeholderResponse);
  };

  // Function to handle the upgrade process in the background
  private func _processUpgrade(nftID : TokenID, caller : Principal, _nftMetadata : [(Text, TypesICRC7.Metadata)]) : async () {
    // Calculate upgrade cost
    let nftLevel : Nat = getNFTLevel(_nftMetadata);
    let upgradeCost = calculateCost(nftLevel);

    // Create transaction arguments for the upgrade cost
    let _transactionsArgs = {
      amount : TypesICRC1.Balance = upgradeCost;
      created_at_time : ?Nat64 = ?Nat64.fromNat(Int.abs(Time.now()));
      fee : ?TypesICRC1.Balance = ?Nat64.toNat(icrc1_fee);
      from_subaccount : ?TypesICRC1.Subaccount = null;
      memo : ?Blob = null;
      to : TypesICRC1.Account = {
        owner = Principal.fromText("3a6n7-myvuc-huq2n-dgpjx-fxa7y-4pteq-epbjf-sdeis-mqq5z-ak6ff-jqe");
        subaccount = null;
      };
    };

    // Transfer the upgrade cost
    let transfer : TransferResult = await shardsToken.icrc1_pay_for_transaction(_transactionsArgs, caller);

    switch (transfer) {
      case (#Ok(_tok)) {
        // Execute the metadata update
        await _executeUpgrade(nftID, caller, _nftMetadata);
      };
      case (#Err(_e)) {
        Debug.print("Upgrade cost transfer failed: ");
      };
    };
  };

  // Function to execute NFT upgrade
  private func _executeUpgrade(nftID : TokenID, caller : Principal, _nftMetadata : [(Text, TypesICRC7.Metadata)]) : async () {
    // Prepare for upgrade
    let _newArgsBuffer = Buffer.Buffer<(Text, TypesICRC7.Metadata)>(_nftMetadata.size());
    let nftLevel : Nat = getNFTLevel(_nftMetadata);

    // Update metadata
    for (_md in _nftMetadata.vals()) {
      let _mdKey : Text = _md.0;
      let _mdValue : TypesICRC7.Metadata = _md.1;
      switch (_mdKey) {
        case ("skin") _newArgsBuffer.add(("skin", _mdValue));
        case ("skills") {
          let _upgradedAdvanced = upgradeAdvancedAttributes(nftLevel, _mdValue);
          _newArgsBuffer.add(("skills", _upgradedAdvanced));
        };
        case ("souls") _newArgsBuffer.add(("souls", _mdValue));
        case ("basic_stats") {
          let _basic_stats = updateBasicStats(_mdValue);
          _newArgsBuffer.add(("basic_stats", _basic_stats));
        };
        case ("general") _newArgsBuffer.add(("general", _mdValue));
        case (_) _newArgsBuffer.add((_mdKey, _mdValue));
      };
    };

    let _upgradeArgs : TypesICRC7.UpgradeArgs = {
      from = { owner = caller; subaccount = null };
      token_id = nftID;
      metadata = _newArgsBuffer.toArray();
      date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
    };
    let upgrade : TypesICRC7.UpgradeReceipt = await nftsToken.upgradeNFT(_upgradeArgs);
    switch (upgrade) {
      case (#Ok(_)) Debug.print("NFT upgraded successfully.");
      case (#Err(_e)) Debug.print("NFT upgrade failed:");
    };
  };

  // Function to get NFT level from metadata
  private func getNFTLevel(metadata : [(Text, TypesICRC7.Metadata)]) : Nat {
    for ((key, value) in metadata.vals()) {
      if (key == "basic_stats") {
        let basicStatsArray = switch (value) {
          case (#MetadataArray(arr)) arr;
          case (_) [];
        };
        for ((bKey, bValue) in basicStatsArray.vals()) {
          if (bKey == "level") {
            let level = switch (bValue) {
              case (#Nat(level)) level;
              case (_) 0;
            };
            Debug.print("Level found: " # Nat.toText(level));
            return level;
          };
        };
      };
    };
    Debug.print("No level found, defaulting to 0");
    return 0;
  };

  // Function to calculate the upgrade cost based on level
  private func calculateCost(level : Nat) : Nat {
    var cost : Nat = 9;
    for (i in Iter.range(2, level)) {
      cost := cost + (Nat.div(cost, 3)); // Increase cost by ~33%
    };
    return cost;
  };

  // Function to update basic stats
  private func updateBasicStats(basicStats : TypesICRC7.Metadata) : TypesICRC7.Metadata {
    let _data : TypesICRC7.Metadata = switch (basicStats) {
      case (#Nat(_)) basicStats;
      case (#Text(_)) basicStats;
      case (#Blob(_)) basicStats;
      case (#Int(_)) basicStats;
      case (#MetadataArray(_a)) {
        var _newArray = Buffer.Buffer<(Text, TypesICRC7.Metadata)>(_a.size());
        for (_md in _a.vals()) {
          let _mdKey : Text = _md.0;
          let _mdValue : TypesICRC7.Metadata = _md.1;
          switch (_mdKey) {
            case "level" {
              let _level : Nat = switch (_mdValue) {
                case (#Nat(level)) level + 1;
                case (_) 0;
              };
              let _newLevelMetadata : TypesICRC7.Metadata = #Nat(_level);
              _newArray.add(("level", _newLevelMetadata));
            };
            case "health" {
              let _health : Float = switch (_mdValue) {
                case (#Int(health)) Float.fromInt64(Int64.fromInt(health)) / 100;
                case (_) 0;
              };
              let _newHealth : Float = _health * 1.1 * 100;
              let _newHealthMetadata : TypesICRC7.Metadata = #Int(Int64.toInt(Float.toInt64(_newHealth)));
              _newArray.add(("health", _newHealthMetadata));
            };
            case "damage" {
              let _damage : Float = switch (_mdValue) {
                case (#Int(damage)) Float.fromInt64(Int64.fromInt(damage)) / 100;
                case (_) 0;
              };
              let _newDamage : Float = _damage * 1.1 * 100;
              let _newDamageMetadata : TypesICRC7.Metadata = #Int(Int64.toInt(Float.toInt64(_newDamage)));
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

  // Function to upgrade advanced attributes
  func upgradeAdvancedAttributes(nft_level : Nat, currentValue : TypesICRC7.Metadata) : TypesICRC7.Metadata {
    let _data : TypesICRC7.Metadata = switch (currentValue) {
      case (#Nat(_)) {
        currentValue;
      };
      case (#Text(_)) {
        currentValue;
      };
      case (#Blob(_)) {
        currentValue;
      };
      case (#Int(_)) {
        currentValue;
      };
      case (#MetadataArray(_a)) {
        var _newArray = Buffer.Buffer<(Text, TypesICRC7.Metadata)>(_a.size());
        for (_md in _a.vals()) {
          let _mdKey : Text = _md.0;
          let _mdValue : TypesICRC7.Metadata = _md.1;
          switch (_mdKey) {
            case ("shield_capacity") {
              switch (_mdValue) {
                case (#Nat(shield_capacity)) {
                  let _newShieldCapacity : Nat = shield_capacity + 1;
                  let _newShieldCapacityMetadata : TypesICRC7.Metadata = #Nat(_newShieldCapacity);
                  _newArray.add(("shield_capacity", _newShieldCapacityMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(shield_capacity)) {
                  let _newShieldCapacity : Int = shield_capacity + 1;
                  let _newShieldCapacityMetadata : TypesICRC7.Metadata = #Int(_newShieldCapacity);
                  _newArray.add(("shield_capacity", _newShieldCapacityMetadata));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("impairment_resistance") {
              switch (_mdValue) {
                case (#Nat(impairment_resistance)) {
                  let _impairmentResistance : Nat = impairment_resistance + 1;
                  let _newImpairmentResistance : TypesICRC7.Metadata = #Nat(_impairmentResistance);
                  _newArray.add(("impairment_resistance", _newImpairmentResistance));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(impairment_resistance)) {
                  let _impairmentResistance : Int = impairment_resistance + 1;
                  let _newImpairmentResistance : TypesICRC7.Metadata = #Int(_impairmentResistance);
                  _newArray.add(("impairment_resistance", _newImpairmentResistance));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("slow") {
              switch (_mdValue) {
                case (#Nat(slow)) {
                  let _newSlow : Nat = slow + 1;
                  let _newSlowMetadata : TypesICRC7.Metadata = #Nat(_newSlow);
                  _newArray.add(("slow", _newSlowMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(slow)) {
                  let _newSlow : Int = slow + 1;
                  let _newSlowMetadata : TypesICRC7.Metadata = #Int(_newSlow);
                  _newArray.add(("slow", _newSlowMetadata));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("weaken") {
              switch (_mdValue) {
                case (#Nat(weaken)) {
                  let _newWeaken : Nat = weaken + 1;
                  let _newWeakenMetadata : TypesICRC7.Metadata = #Nat(_newWeaken);
                  _newArray.add(("weaken", _newWeakenMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(weaken)) {
                  let _newWeaken : Int = weaken + 1;
                  let _newWeakenMetadata : TypesICRC7.Metadata = #Int(_newWeaken);
                  _newArray.add(("weaken", _newWeakenMetadata));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("stun") {
              switch (_mdValue) {
                case (#Nat(stun)) {
                  let _newStun : Nat = stun + 1;
                  let _newStunMetadata : TypesICRC7.Metadata = #Nat(_newStun);
                  _newArray.add(("stun", _newStunMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(stun)) {
                  let _newStun : Int = stun + 1;
                  let _newStunMetadata : TypesICRC7.Metadata = #Int(_newStun);
                  _newArray.add(("stun", _newStunMetadata));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("disarm") {
              switch (_mdValue) {
                case (#Nat(disarm)) {
                  let _newDisarm : Nat = disarm + 1;
                  let _newDisarmMetadata : TypesICRC7.Metadata = #Nat(_newDisarm);
                  _newArray.add(("disarm", _newDisarmMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(disarm)) {
                  let _newDisarm : Int = disarm + 1;
                  let _newDisarmMetadata : TypesICRC7.Metadata = #Int(_newDisarm);
                  _newArray.add(("disarm", _newDisarmMetadata));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("silence") {
              switch (_mdValue) {
                case (#Nat(silence)) {
                  let _newSilence : Nat = silence + 1;
                  let _newSilenceMetadata : TypesICRC7.Metadata = #Nat(_newSilence);
                  _newArray.add(("silence", _newSilenceMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(silence)) {
                  let _newSilence : Int = silence + 1;
                  let _newSilenceMetadata : TypesICRC7.Metadata = #Int(_newSilence);
                  _newArray.add(("silence", _newSilenceMetadata));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("armor") {
              switch (_mdValue) {
                case (#Nat(armor)) {
                  let _newArmor : Nat = armor + 1;
                  let _newArmorMetadata : TypesICRC7.Metadata = #Nat(_newArmor);
                  _newArray.add(("armor", _newArmorMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(armor)) {
                  let _newArmor : Int = armor + 1;
                  let _newArmorMetadata : TypesICRC7.Metadata = #Int(_newArmor);
                  _newArray.add(("armor", _newArmorMetadata));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("armor_penetration") {
              switch (_mdValue) {
                case (#Nat(armor_penetration)) {
                  let _newArmorPenetration : Nat = armor_penetration + 1;
                  let _newArmorPenetrationMetadata : TypesICRC7.Metadata = #Nat(_newArmorPenetration);
                  _newArray.add(("armor_penetration", _newArmorPenetrationMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(armor_penetration)) {
                  let _newArmorPenetration : Int = armor_penetration + 1;
                  let _newArmorPenetrationMetadata : TypesICRC7.Metadata = #Int(_newArmorPenetration);
                  _newArray.add(("armor_penetration", _newArmorPenetrationMetadata));
                };
                case (#MetadataArray(_)) {};
              };
            };
            case ("attack_speed") {
              switch (_mdValue) {
                case (#Nat(attack_speed)) {
                  let _newAttackSpeed : Nat = attack_speed + 1;
                  let _newAttackSpeedMetadata : TypesICRC7.Metadata = #Nat(_newAttackSpeed);
                  _newArray.add(("attack_speed", _newAttackSpeedMetadata));
                };
                case (#Text(_)) {};
                case (#Blob(_)) {};
                case (#Int(attack_speed)) {
                  let _newAttackSpeed : Int = attack_speed + 1;
                  let _newAttackSpeedMetadata : TypesICRC7.Metadata = #Int(_newAttackSpeed);
                  _newArray.add(("attack_speed", _newAttackSpeedMetadata));
                };
                case (#MetadataArray(_)) {};
              };
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

  public shared (msg) func mintNFT(player : Principal, rarity : Nat, unit_id : Nat) : async (Bool, Text) {
    /// Call the NFT contract to mint a new NFT
    let uuid = await generateUUID64();
    let _mintArgs : TypesICRC7.MintArgs = {
      to = { owner = player; subaccount = null };
      token_id = uuid;
      metadata = getBaseMetadata(rarity, unit_id);
      date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
    };
    let mint : TypesICRC7.MintReceipt = await nftsToken.mint(_mintArgs);
    switch (mint) {
      case (#Ok(_transactionID)) {
        nftID := nftID + 1;
        return (true, "NFT minted. Transaction ID: " # Nat.toText(_transactionID));
      };
      case (#Err(_e)) {
        switch (_e) {
          case (#AlreadyExistTokenId) {
            return (false, "NFT mint failed: Token ID already exists");
          };
          case (#GenericError(_g)) {
            return (false, "NFT mint failed: GenericError: " # _g.message);
          };
          case (#InvalidRecipient) {
            return (false, "NFT mint failed: InvalidRecipient");
          };
          case (#Unauthorized) {
            return (false, "NFT mint failed: Unauthorized");
          };
          case (#SupplyCapOverflow) {
            return (false, "NFT mint failed: SupplyCapOverflow");
          };
        };
      };
    };
  };

  /// Mint Chests
  public shared (msg) func mintChest(player : Principal, rarity : Nat) : async (Bool, Text) {
    /// Call the NFT contract to mint a new NFT
    let uuid = await generateUUID64();
    let _mintArgs : TypesICRC7.MintArgs = {
      to = { owner = player; subaccount = null };
      token_id = uuid;
      metadata = getChestMetadata(rarity);
      date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
    };
    let mint : TypesICRC7.MintReceipt = await chestsToken.mint(_mintArgs);
    switch (mint) {
      case (#Ok(_transactionID)) {
        chestID := chestID + 1;
        return (true, "NFT minted. Transaction ID: " # Nat.toText(_transactionID));
      };
      case (#Err(_e)) {
        switch (_e) {
          case (#AlreadyExistTokenId) {
            return (false, "NFT mint failed: Token ID already exists");
          };
          case (#GenericError(_g)) {
            return (false, "NFT mint failed: GenericError: " # _g.message);
          };
          case (#InvalidRecipient) {
            return (false, "NFT mint failed: InvalidRecipient");
          };
          case (#Unauthorized) {
            return (false, "NFT mint failed: Unauthorized");
          };
          case (#SupplyCapOverflow) {
            return (false, "NFT mint failed: SupplyCapOverflow");
          };
        };
      };
    };
  };

  func getBaseMetadata(rarity : Nat, unit_id : Nat) : [(Text, TypesICRC7.Metadata)] {
    let _basicStats : TypesICRC7.MetadataArray = [
      ("level", #Nat(1)),
      ("health", #Int(100)),
      ("damage", #Int(10)),
    ];
    let _general : TypesICRC7.MetadataArray = [
      ("unit_id", #Nat(unit_id)),
      ("class", #Text("Warrior")),
      ("rarity", #Nat(rarity)),
      ("faction", #Text("Cosmicrafts")),
      ("name", #Text("Cosmicrafts NFT")),
      ("description", #Text("Cosmicrafts NFT")),
      ("icon", #Nat(1)),
      ("skins", #Text("[{skin_id: 1, skin_name: 'Default', skin_description: 'Default Skin', skin_icon: 'url_to_canister', skin_rarity: 1]")),
    ];
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
    let _skins : TypesICRC7.MetadataArray = [("1", #MetadataArray([("skin_id", #Nat(1)), ("skin_name", #Text("Default")), ("skin_description", #Text("Default Skin")), ("skin_icon", #Text("url_to_canister")), ("skin_rarity", #Nat(1))]))];
    let _baseMetadata : [(Text, TypesICRC7.Metadata)] = [
      ("basic_stats", #MetadataArray(_basicStats)),
      ("general", #MetadataArray(_general)),
      ("skills", #MetadataArray(_skills)),
      ("skins", #MetadataArray(_skins)),
    ];
    return _baseMetadata;
  };

  func getChestMetadata(rarity : Nat) : [(Text, TypesICRC7.Metadata)] {
    let _baseMetadata : [(Text, TypesICRC7.Metadata)] = [("rarity", #Nat(rarity))];
    return _baseMetadata;
  };

  public shared (msg) func openChests(chestID : Nat) : async (Bool, Text) {
    // Perform ownership check
    let ownerof : TypesChests.OwnerResult = await chestsToken.icrc7_owner_of(chestID);
    let _owner : TypesChests.Account = switch (ownerof) {
      case (#Ok(owner)) owner;
      case (#Err(_)) return (false, "{\"success\":false, \"message\":\"Chest not found\"}");
    };

    if (Principal.notEqual(_owner.owner, msg.caller)) {
      return (false, "{\"success\":false, \"message\":\"Not the owner of the chest\"}");
    };

    // Immediate placeholder response to Unity
    let placeholderResponse = "{\"success\":true, \"message\":\"Chest opened successfully\", \"tokens\":[{\"token\":\"Shards\", \"amount\": 0}, {\"token\":\"Flux\", \"amount\": 0}]}";

    // Schedule background processing without waiting
    ignore _processChestContents(chestID, msg.caller);

    // Burn the chest token asynchronously without waiting for the result
    ignore async {
      let _chestArgs : TypesChests.OpenArgs = {
        from = _owner;
        token_id = chestID;
      };
      await chestsToken.openChest(_chestArgs);
    };

    return (true, placeholderResponse);
  };

  // Function to process chest contents in the background
  private func _processChestContents(chestID : Nat, caller : Principal) : async () {
    // Determine chest rarity based on metadata
    let metadataResult = await chestsToken.icrc7_metadata(chestID);
    let rarity = switch (metadataResult) {
      case (#Ok(metadata)) getRarityFromMetadata(metadata);
      case (#Err(_)) 1;
    };

    let (shardsAmount, fluxAmount) = getTokensAmount(rarity);

    // Mint tokens in parallel
    let shardsMinting = async {
      // Mint shards tokens
      let _shardsArgs : TypesICRC1.Mint = {
        to = { owner = caller; subaccount = null };
        amount = shardsAmount;
        memo = null;
        created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
      };
      let _shardsMinted : TypesICRC1.TransferResult = await shardsToken.mint(_shardsArgs);

      switch (_shardsMinted) {
        case (#Ok(_tid)) {
          Debug.print("Shards minted successfully: " # Nat.toText(_tid));
        };
        case (#Err(_e)) {
          Debug.print("Error minting shards: ");
        };
      };
    };

    let fluxMinting = async {
      // Mint flux tokens
      let _fluxArgs : TypesICRC1.Mint = {
        to = { owner = caller; subaccount = null };
        amount = fluxAmount;
        memo = null;
        created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
      };
      let _fluxMinted : TypesICRC1.TransferResult = await fluxToken.mint(_fluxArgs);

      switch (_fluxMinted) {
        case (#Ok(_tid)) {
          Debug.print("Flux minted successfully: " # Nat.toText(_tid));
        };
        case (#Err(_e)) {
          Debug.print("Error minting flux:");
        };
      };
    };

    await shardsMinting;
    await fluxMinting;
  };

  // Function to get rarity from metadata
  private func getRarityFromMetadata(metadata : [(Text, TypesChests.Metadata)]) : Nat {
    for ((key, value) in metadata.vals()) {
      if (key == "rarity") {
        return switch (value) {
          case (#Nat(rarity)) rarity;
          case (_) 1;
        };
      };
    };
    return 1;
  };

  // Function to get token amounts based on rarity
  private func getTokensAmount(rarity : Nat) : (Nat, Nat) {
    var factor : Nat = 1;
    if (rarity <= 5) {
      factor := Nat.pow(2, rarity - 1);
    } else if (rarity <= 10) {
      factor := Nat.mul(Nat.pow(2, 5), Nat.div(Nat.pow(3, rarity - 6), Nat.pow(2, rarity - 6)));
    } else if (rarity <= 15) {
      factor := Nat.mul(Nat.mul(Nat.pow(2, 5), Nat.div(Nat.pow(3, 5), Nat.pow(2, 5))), Nat.div(Nat.pow(5, rarity - 11), Nat.pow(4, rarity - 11)));
    } else if (rarity <= 20) {
      factor := Nat.mul(Nat.mul(Nat.mul(Nat.pow(2, 5), Nat.div(Nat.pow(3, 5), Nat.pow(2, 5))), Nat.div(Nat.pow(5, 5), Nat.pow(4, 5))), Nat.div(Nat.pow(11, rarity - 16), Nat.pow(10, rarity - 16)));
    } else {
      factor := Nat.mul(Nat.mul(Nat.mul(Nat.mul(Nat.pow(2, 5), Nat.div(Nat.pow(3, 5), Nat.pow(2, 5))), Nat.div(Nat.pow(5, 5), Nat.pow(4, 5))), Nat.div(Nat.pow(11, 5), Nat.pow(10, 5))), Nat.div(Nat.pow(21, rarity - 21), Nat.pow(20, rarity - 21)));
    };
    let shardsAmount = Nat.mul(12, factor);
    let fluxAmount = Nat.mul(4, factor);
    return (shardsAmount, fluxAmount);
  };

  /// Mint deck with 8 units and random rarity within a range provided
  public shared (msg) func mintDeck(player : Principal) : async (Bool, Text) {
    let units = [
      ("Blackbird", 30, 120, 3),
      ("Predator", 20, 140, 2),
      ("Warhawk", 30, 180, 4),
      ("Tigershark", 10, 100, 1),
      ("Devastator", 20, 120, 2),
      ("Pulverizer", 10, 180, 3),
      ("Barracuda", 20, 140, 2),
      ("Farragut", 10, 220, 4),
    ];

    var _deck = Buffer.Buffer<TypesICRC7.MintArgs>(8);

    for (i in Iter.range(0, 7)) {
      let (name, damage, hp, rarity) = units[i];
      let uuid = await generateUUID64();
      let _mintArgs : TypesICRC7.MintArgs = {
        to = { owner = player; subaccount = null };
        token_id = uuid;
        metadata = getBaseMetadataWithAttributes(rarity, i + 1, name, damage, hp);
        date_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
      };
      _deck.add(_mintArgs);
      nftID := nftID + 1;
    };

    let mint : TypesICRC7.MintReceipt = await nftsToken.mintDeck(_deck.toArray());
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

  func getBaseMetadataWithAttributes(rarity : Nat, unit_id : Nat, name : Text, damage : Nat, hp : Nat) : [(Text, TypesICRC7.Metadata)] {
    let baseMetadata = getBaseMetadata(rarity, unit_id);

    var updatedMetadata : [(Text, TypesICRC7.Metadata)] = [];

    for ((key, value) in baseMetadata.vals()) {
      switch (key) {
        case ("general") {
          let generalArray = switch (value) {
            case (#MetadataArray(arr)) arr;
            case (_) [];
          };
          var newGeneralArray = Buffer.Buffer<(Text, TypesICRC7.Metadata)>(generalArray.size());
          for ((gKey, gValue) in generalArray.vals()) {
            switch (gKey) {
              case "name" newGeneralArray.add((gKey, #Text(name)));
              case "description" newGeneralArray.add((gKey, #Text(name # " NFT")));
              case _ newGeneralArray.add((gKey, gValue));
            };
          };
          updatedMetadata := Array.append(updatedMetadata, [(key, #MetadataArray(newGeneralArray.toArray()))]);
        };
        case ("basic_stats") {
          let basicStatsArray = switch (value) {
            case (#MetadataArray(arr)) arr;
            case (_) [];
          };
          var newBasicStatsArray = Buffer.Buffer<(Text, TypesICRC7.Metadata)>(basicStatsArray.size());
          for ((bKey, bValue) in basicStatsArray.vals()) {
            switch (bKey) {
              case "health" newBasicStatsArray.add((bKey, #Int(hp)));
              case "damage" newBasicStatsArray.add((bKey, #Int(damage)));
              case _ newBasicStatsArray.add((bKey, bValue));
            };
          };
          updatedMetadata := Array.append(updatedMetadata, [(key, #MetadataArray(newBasicStatsArray.toArray()))]);
        };
        case _ updatedMetadata := Array.append(updatedMetadata, [(key, value)]);
      };
    };
    return updatedMetadata;
  };

  public shared (msg) func claimReward(idReward : Nat) : async (Bool, Text) {
    let _reward : ?TypesRewards.RewardsUser = await rewardsCanister.getUserReward(msg.caller, idReward);
    switch (_reward) {
      case (null) {
        return (false, "Reward not found");
      };
      case (?_r) {
        if (_r.finished == true) {
          if (_r.finish_date > _r.expiration) {
            return (false, "Reward expired");
          };
          switch (_r.prize_type) {
            case (#Chest) {
              let _chestArgs : TypesICRC7.MintArgs = {
                to = { owner = msg.caller; subaccount = null };
                token_id = chestID;
                metadata = getChestMetadata(_r.prize_amount);
                date_time = ?{
                  timestamp_nanos = Nat64.fromNat(Int.abs(Time.now()));
                };
              };
              let mint : TypesICRC7.MintReceipt = await chestsToken.mint(_chestArgs);
              switch (mint) {
                case (#Ok(_transactionID)) {
                  chestID := chestID + 1;
                  let _removedReward = await rewardsCanister.claimedReward(msg.caller, idReward);
                  return (_removedReward.0, _removedReward.1 # " - " # "Chest minted. Transaction ID: " # Nat.toText(_transactionID));
                };
                case (#Err(_e)) {
                  switch (_e) {
                    case (#AlreadyExistTokenId) {
                      return (false, "Chest mint failed: Token ID already exists");
                    };
                    case (#GenericError(_g)) {
                      return (false, "Chest mint failed: GenericError: " # _g.message);
                    };
                    case (#InvalidRecipient) {
                      return (false, "Chest mint failed: InvalidRecipient");
                    };
                    case (#Unauthorized) {
                      return (false, "Chest mint failed: Unauthorized");
                    };
                    case (#SupplyCapOverflow) {
                      return (false, "Chest mint failed: SupplyCapOverflow");
                    };
                  };
                };
              };
            };
            case (#Flux) {
              let _fluxArgs : TypesICRC1.Mint = {
                to = { owner = msg.caller; subaccount = null };
                amount = _r.prize_amount;
                memo = null;
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
              };
              let _tokenMinted : TypesICRC1.TransferResult = await fluxToken.mint(_fluxArgs);
              switch (_tokenMinted) {
                case (#Ok(_tid)) {
                  let _removedReward = await rewardsCanister.claimedReward(msg.caller, idReward);
                  return (_removedReward.0, _removedReward.1 # " - " # "Flux minted. Transaction ID: " # Nat.toText(_tid));
                };
                case (#Err(_e)) {
                  switch (_e) {
                    case (#Duplicate(_d)) {
                      return (false, "Flux mint failed: Duplicate");
                    };
                    case (#GenericError(_g)) {
                      return (false, "Flux mint failed: GenericError: " # _g.message);
                    };
                    case (#CreatedInFuture(_cif)) {
                      return (false, "Flux mint failed: CreatedInFuture");
                    };
                    case (#BadFee(_bf)) {
                      return (false, "Flux mint failed: BadFee");
                    };
                    case (#BadBurn(_bb)) {
                      return (false, "Flux mint failed: BadBurn");
                    };
                    case (_) {
                      return (false, "Flux mint failed: Other error");
                    };
                  };
                };
              };
            };
            case (#Shards) {
              let _shardsArgs : TypesICRC1.Mint = {
                to = { owner = msg.caller; subaccount = null };
                amount = _r.prize_amount;
                memo = null;
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
              };
              let _tokenMinted : TypesICRC1.TransferResult = await shardsToken.mint(_shardsArgs);
              switch (_tokenMinted) {
                case (#Ok(_tid)) {
                  let _removedReward = await rewardsCanister.claimedReward(msg.caller, idReward);
                  return (_removedReward.0, _removedReward.1 # " - " # "Shards minted. Transaction ID: " # Nat.toText(_tid));
                };
                case (#Err(_e)) {
                  switch (_e) {
                    case (#Duplicate(_d)) {
                      return (false, "Shards mint failed: Duplicate");
                    };
                    case (#GenericError(_g)) {
                      return (false, "Shards mint failed: GenericError: " # _g.message);
                    };
                    case (#CreatedInFuture(_cif)) {
                      return (false, "Shards mint failed: CreatedInFuture");
                    };
                    case (#BadFee(_bf)) {
                      return (false, "Shards mint failed: BadFee");
                    };
                    case (#BadBurn(_bb)) {
                      return (false, "Shards mint failed: BadBurn");
                    };
                    case (_) {
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
    let randomBytes = await Random.blob();
    var uuid : Nat = 0;
    let byteArray = Blob.toArray(randomBytes);
    for (i in Iter.range(0, 7)) {
      uuid := Nat.add(Nat.bitshiftLeft(uuid, 8), Nat8.toNat(byteArray[i]));
    };
    uuid := uuid % 2147483647;
    return uuid;
  };
};
