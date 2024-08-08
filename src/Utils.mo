// Imports
    import Hash "mo:base/Hash";
    import Iter "mo:base/Iter";
    import Nat8 "mo:base/Nat8";
    import Buffer "mo:base/Buffer";
    import Nat32 "mo:base/Nat32";
    import Random "mo:base/Random";
    import Blob "mo:base/Blob";
    import Nat "mo:base/Nat";
    import Float "mo:base/Float";
    import Debug "mo:base/Debug";
    import Array "mo:base/Array";
    import Bool "mo:base/Bool";
    import Nat64 "mo:base/Nat64";
    import Text "mo:base/Text";
    import Time "mo:base/Time";
    import Principal "mo:base/Principal";
    import Types "Types";
    import TypesICRC7 "/icrc7/types";
    import TypesICRC1 "/icrc1/Types";
    import PseudoRandomX "mo:xtended-random/PseudoRandomX";

module Utils {


    public func getTokensAmount(rarity: Nat): async Nat {
        let randomBytes = await Random.blob(); // Generate random bytes
        let prng = PseudoRandomX.fromBlob(randomBytes, #xorshift32); // Create a pseudo-random generator

        // Define base and initial gap
        let baseMin: Nat = 10;
        let baseMax: Nat = 20;
        let initialGap: Nat = 10;
        let gapMultiplier: Nat = 2;

        // Calculate the range for the given rarity
        let minAmount: Nat = if (rarity == 1) {
            baseMin
        } else {
            let previousMax = Nat.add(baseMax, Nat.mul(Nat.sub(rarity, 2), Nat.add(initialGap, Nat.mul(gapMultiplier, Nat.sub(rarity, 2)))));
            Nat.add(previousMax, 1)
        };

        let maxAmount: Nat = if (rarity == 1) {
            baseMax
        } else {
            Nat.add(minAmount, Nat.add(initialGap, Nat.mul(gapMultiplier, Nat.sub(rarity, 1))))
        };

        // Generate a random amount within the calculated range
        let randomAmount = prng.nextNat(minAmount, maxAmount);

        return randomAmount;
    };

    public func getRandomReward(minReward: Nat, maxReward: Nat): async Nat {
        let randomBytes = await Random.blob(); // Generating random bytes
        let prng = PseudoRandomX.fromBlob(randomBytes, #xorshift32); // Create a pseudo-random generator
        return prng.nextNat(minReward, maxReward);
    };

    public func calculateLevel(xp: Nat) : Nat {
        // Assuming each level requires twice as much XP as the previous one, starting with 100 XP for level 2.
        let baseXP: Nat = 100;
        var level: Nat = 1;
        var requiredXP: Nat = baseXP;

        // Increase level as long as XP meets or exceeds the required XP for the next level.
        while (xp >= requiredXP) {
            level := level + 1;
            requiredXP := requiredXP * 2;
        };

        return level;
    };

    // Function to calculate the upgrade cost based on level
    public func calculateCost(level: Nat): Nat {
        var cost: Nat = 9;
        for (i in Iter.range(2, level)) {
            cost := cost + (Nat.div(cost, 3)); // Increase cost by ~33%
        };
        return cost;
    };

    public type PlayerId = Types.PlayerId;


// Missions Utils
    public func selectRandomRewardPool(rewardPools: [Types.RewardPool], blob: Blob): Types.RewardPool {
        let size: Nat8 = Nat8.fromNat(rewardPools.size() - 1);
        let random = Random.Finite(blob);
        let index = switch (random.range(size)) {
            case (?i) i;
            case null 0; // Default to 0 if range generation fails
        };
        return rewardPools[index];
    };

    public func getRandomMissionOption(options: [Types.MissionOption], blob: Blob): Types.MissionOption {
        let size: Nat8 = Nat8.fromNat(options.size() - 1);
        let index: Nat = Random.rangeFrom(size, blob);
        return options[index];
    };

    public func logMissionResults(results: [(Bool, Text, Nat)], missionType: Text): async () {
        for ((success, message, id) in results.vals()) {
            Debug.print("[logMissionResults] " # missionType # " Mission ID: " # Nat.toText(id) # " - Success: " # Bool.toText(success) # " - Message: " # message);
        }
    };

// Results

    // Function to handle minting errors
    public func handleMintError(token: Text, error: TypesICRC1.TransferError): Text {
        switch (error) {
            case (#Duplicate(_d)) {
                return "{\"token\":\"" # token # "\", \"error\":true, \"message\":\"Chest open failed: " # token # " mint failed: Duplicate\"}";
            };
            case (#GenericError(_g)) {
                return "{\"token\":\"" # token # "\", \"error\":true, \"message\":\"Chest open failed: " # token # " mint failed: GenericError: " # _g.message # "\"}";
            };
            case (#CreatedInFuture(_cif)) {
                return "{\"token\":\"" # token # "\", \"error\":true, \"message\":\"Chest open failed: " # token # " mint failed: CreatedInFuture\"}";
            };
            case (#BadFee(_bf)) {
                return "{\"token\":\"" # token # "\", \"error\":true, \"message\":\"Chest open failed: " # token # " mint failed: BadFee\"}";
            };
            case (#BadBurn(_bb)) {
                return "{\"token\":\"" # token # "\", \"error\":true, \"message\":\"Chest open failed: " # token # " mint failed: BadBurn\"}";
            };
            case (_) {
                return "{\"token\":\"" # token # "\", \"error\":true, \"message\":\"Chest open failed: " # token # " mint failed: Other error\"}";
            };
        }
    };

    // Function to handle chest errors
    public func handleChestError(error: TypesICRC7.TransferError): Text {
        switch (error) {
            case (#GenericError(_g)) {
                return "{\"error\":true, \"message\":\"Chest open failed: GenericError: " # _g.message # "\"}";
            };
            case (#CreatedInFuture(_cif)) {
                return "{\"error\":true, \"message\":\"Chest open failed: CreatedInFuture\"}";
            };
            case (#Duplicate(_d)) {
                return "{\"error\":true, \"message\":\"Chest open failed: Duplicate\"}";
            };
            case (#TemporarilyUnavailable(_tu)) {
                return "{\"error\":true, \"message\":\"Chest open failed: TemporarilyUnavailable\"}";
            };
            case (#TooOld) {
                return "{\"error\":true, \"message\":\"Chest open failed: TooOld\"}";
            };
            case (#Unauthorized(_u)) {
                return "{\"error\":true, \"message\":\"Chest open failed: Unauthorized\"}";
            };
        }
    };

    // Function to convert error to text
    public func errorToText(error: TypesICRC7.MintError): Text {
        switch (error) {
            case (#AlreadyExistTokenId) "Token ID already exists";
            case (#GenericError(_g)) "GenericError: " # _g.message;
            case (#InvalidRecipient) "InvalidRecipient";
            case (#Unauthorized) "Unauthorized";
            case (#SupplyCapOverflow) "SupplyCapOverflow";
        }
    };

    public func transferErrorToText(error: TypesICRC7.TransferError): Text {
        switch (error) {
            case (#CreatedInFuture(details)) "Created in future: Ledger time - " # Nat64.toText(details.ledger_time);
            case (#Duplicate(details)) "Duplicate: Duplicate of - " # Nat.toText(details.duplicate_of);
            case (#GenericError(details)) "Generic error: Code - " # Nat.toText(details.error_code) # ", Message - " # details.message;
            case (#TemporarilyUnavailable {}) "Temporarily unavailable";
            case (#TooOld) "Too old";
            case (#Unauthorized(_)) "Unauthorized";
        }
    };

//--
// General Utils
    // Define a custom equality function for tuples of (PlayerId, PlayerId)
    public func tupleEqual(x: (PlayerId, PlayerId), y: (PlayerId, PlayerId)) : Bool {
        return x == y;
    };

    // Define a custom hash function for tuples of (PlayerId, PlayerId)
    public func tupleHash(tuple: (PlayerId, PlayerId)) : Hash.Hash {
        let hash1 = Principal.hash(tuple.0);
        let hash2 = Principal.hash(tuple.1);
        return Utils._natHash(Nat32.toNat(hash1) + Nat32.toNat(hash2)); // Combine the hashes using a simple addition and then hash the result
    };

    public func nullishCoalescing<T>(value: ?T, defaultValue: T): T {
        switch (value) {
            case (null) defaultValue;
            case (?v) v;
        }
    };

    public func pushIntoArray<T>(item: T, array: [T]): [T] {
        var buffer = Buffer.Buffer<T>(array.size() + 1);
        for (i in Iter.range(0, array.size() - 1)) {
            buffer.add(array[i]);
        };
        buffer.add(item);
        return Buffer.toArray(buffer);
    };

    public func generateUUID64() : async Nat {
        let randomBytes = await Random.blob();
        var uuid : Nat = 0;
        let byteArray = Blob.toArray(randomBytes);
        for (i in Iter.range(0, 7)) {
            uuid := Nat.add(Nat.bitshiftLeft(uuid, 8), Nat8.toNat(byteArray[i]));
        };
        uuid := uuid % 2147483647;
        return uuid;
    };

    public func generateULID(): async Text {
        // Get the current timestamp in UNIX epoch format
        let timestamp: Nat64 = Nat64.fromIntWrap(Time.now());

        // Generate a random component
        let randomComponent: Blob = await Random.blob();
        
        // Convert the Blob to an array and take the first 5 bytes
        let randomArray: [Nat8] = Blob.toArray(randomComponent);
        let randomBlob: [Nat8] = Array.subArray(randomArray, 0, 3);

        // Convert the timestamp and random component to hexadecimal strings
        let timestampHex: Text = Utils.nat64ToHex(timestamp);
        let randomHex: Text = Utils.arrayToHex(randomBlob);

        // Combine the timestamp and random component to form the ULID
        return timestampHex # "-" # randomHex;
    };

    public func get2BytesBlob() : async Blob {
        let fullBlob = await Random.blob();
        // Convert the Blob to an array of bytes
        let byteArray = Iter.toArray<Nat8>(fullBlob.vals());
        // Extract the first 2 bytes
        let twoBytes = Array.tabulate<Nat8>(2, func(i) {
            byteArray[i];
        });
        // Convert the array back to a Blob
        Blob.fromArray(twoBytes)
    };

    public func nat64ToHex(value: Nat64): Text {
        // Convert Nat64 to hexadecimal
        let hexChars: [Char] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];
        var hex = "";
        var tempValue = value;
        for (i in Iter.range(0, 15)) { // Nat64 fits into 16 hex chars
            let nibble = tempValue & 0xF;
            hex := Text.fromChar(hexChars[Nat64.toNat(nibble)]) # hex;
            tempValue := tempValue >> 4;
        };
        return hex;
    };

    public func arrayToHex(array: [Nat8]): Text {
        let hexChars: [Char] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];
        var hex = "";
        for (i in Iter.range(0, array.size() - 1)) {
            let byte = array[i];
            hex #= Text.fromChar(hexChars[Nat8.toNat(byte >> 4)]) # Text.fromChar(hexChars[Nat8.toNat(byte & 0x0F)]);
        };
        return hex;
    };

    public func natToBytes(n: Nat): [Nat8] {
        var bytes = Buffer.Buffer<Nat8>(0);
        var num = n;
        while (num > 0) {
            bytes.add(Nat8.fromNat(num % 256));
            num := num / 256;
        };
        return Buffer.toArray(bytes);
    };

    public func _floatSort(a : Float, b : Float) : Float {
        if (a < b) {
        return -1;
        } else if (a > b) {
        return 1;
        } else {
        return 0;
        };
    };

    public func _natHash(a: Nat): Hash.Hash {
        let byteArray = natToBytes(a);
        var hash: Hash.Hash = 0;
        for (i in Iter.range(0, byteArray.size() - 1)) {
            hash := (hash * 31 + Nat32.fromNat(Nat8.toNat(byteArray[i])));
        };
        return hash;
    };

    public func _natEqual(a : Nat, b : Nat) : Bool {
        return a == b;
    };

    public func shuffleArray(arr: [Nat]): async [Nat] {
        let len = Array.size<Nat>(arr);
        var shuffled = Array.thaw<Nat>(arr);
        
        // Initialize a PseudoRandomGenerator (use your specific seed and kind)
        let seed: Nat32 = 12345; // Example seed
        let kind: PseudoRandomX.PseudoRandomKind = #xorshift32;
        let prng: PseudoRandomX.PseudoRandomGenerator = PseudoRandomX.fromSeed(seed, kind);

        var i = len;
        while (i > 1) {
            i -= 1;
            let j = prng.nextNat(0, i + 1);
            let temp = shuffled[i];
            shuffled[i] := shuffled[j];
            shuffled[j] := temp;
        };
        return Array.freeze<Nat>(shuffled);
    };

    public func arrayContains<T>(array: [T], value: T, eq: (T, T) -> Bool): Bool {
        for (element in array.vals()) {
            if (eq(element, value)) {
                return true;
            };
        };
        return false;
    };
};
