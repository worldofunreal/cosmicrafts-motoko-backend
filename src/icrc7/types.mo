import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {
    public type Subaccount = Blob;

    public type Account = {
        owner: Principal; 
        subaccount: ?Blob;
    };

    public type CollectionInitArgs = {
        name: Text;
        symbol: Text;
        royalties: ?Nat16;
        royaltyRecipient: ?Account;
        description: ?Text;
        image: ?Blob;
        supplyCap: ?Nat;
    };

    public type CollectionMetadata = {
        name: Text;
        symbol: Text;
        royalties: ?Nat16;
        royaltyRecipient: ?Account;
        description: ?Text;
        image: ?Blob;
        totalSupply: Nat;
        supplyCap: ?Nat;
    };

    public type SupportedStandard = {
        name: Text;
        url: Text;
    };

    public type TokenId = Nat;

    public type MetadataArray = [(Text, Metadata)];

    public type TokenMetadata = {
        tokenId: TokenId;
        owner: Account;
        metadata: Metadata;
    };

    public type Result<S, E> = {
        #Ok: S;
        #Err: E;
    };

    public type CallError = {
        #Unauthorized;
        #InvalidTokenId;
        #AlreadyExistTokenId;
        #SupplyCapOverflow;
        #InvalidRecipient;
        #GenericError;
    };

    public type MintArgs = {
        to: Account;
        token_id: TokenId;
        metadata: Metadata;
    };

    public type UpgradeArgs = {
        from: Account;
        token_id: TokenId;
        metadata: Metadata;
    };

    public type TransferId = Nat;

    public type TransferArgs = {
        spender_subaccount: ?Subaccount;
        from: ?Account;
        to: Account;
        token_ids: [TokenId];
        memo: ?Blob;
        created_at_time: ?Nat64;
        is_atomic: ?Bool;
    };

    public type TransferError = {
        #Unauthorized: { token_ids: [TokenId] };
        #TooOld;
        #CreatedInFuture: { ledger_time: Nat64 };
        #Duplicate: { duplicate_of: TransferId };
        #TemporarilyUnavailable: {};
        #GenericError: { error_code: Nat; message: Text };
    };

    public type ApprovalId = Nat;

    public type ApprovalArgs = {
        from_subaccount: ?Subaccount;
        spender: Account;
        token_ids: ?[TokenId];
        expires_at: ?Nat64;
        memo: ?Blob;
        created_at_time: ?Nat64;
    };

    public type ApprovalError = {
        #Unauthorized: { token_ids: [TokenId] };
        #TooOld;
        #TemporarilyUnavailable: {};
        #GenericError: { error_code: Nat; message: Text };
    };

    public type MintError = {
        #Unauthorized;
        #SupplyCapOverflow;
        #InvalidRecipient;
        #AlreadyExistTokenId;
        #GenericError: { error_code: Nat; message: Text };
    };

    public type UpgradeError = {
        #Unauthorized;
        #InvalidRecipient;
        #DoesntExistTokenId;
        #GenericError: { error_code: Nat; message: Text };
    };

    public type MetadataResult = Result<Metadata, CallError>;

    public type OwnerResult = Result<Account, CallError>;

    public type BalanceResult = Result<Nat, CallError>;

    public type TokensOfResult = Result<[TokenId], CallError>;

    public type MintReceipt = Result<TokenId, MintError>;

    public type UpgradeReceipt = Result<TokenId, UpgradeError>;

    public type TransferReceipt = Result<TransferId, TransferError>;

    public type ApprovalReceipt = Result<ApprovalId, ApprovalError>;

    public type TransferErrorCode = {
        #EmptyTokenIds;
        #DuplicateInTokenIds;
    };

    public type ApproveErrorCode = {
        #SelfApproval;
    };

    public type OperatorApproval = {
        spender: Account;
        memo: ?Blob;
        expires_at: ?Nat64;
    };

    public type TokenApproval = {
        spender: Account;
        memo: ?Blob;
        expires_at: ?Nat64;
    };

    public type TransactionId = Nat;

    public type Transaction = {
        kind: Text;
        timestamp: Nat64;
        mint: ?{
            to: Account;
            token_ids: [TokenId];
        };
        icrc7_transfer: ?{
            from: Account;
            to: Account;
            spender: ?Account;
            token_ids: [TokenId];
            memo: ?Blob;
            created_at_time: ?Nat64;
        };
        icrc7_approve: ?{
            from: Account;
            spender: Account;
            token_ids: ?[TokenId];
            expires_at: ?Nat64;
            memo: ?Blob;
            created_at_time: ?Nat64;
        };
        upgrade: ?{
            prev_metadata: [(Text, Metadata)];
            new_metadata: [(Text, Metadata)];
            token_id: ?TokenId;
            memo: ?Blob;
            upgraded_at: ?Nat64;
        };
    };

    public type GetTransactionsArgs = {
        limit: Nat;
        offset: Nat;
        account: ?Account;
    };

    public type GetTransactionsResult = {
        total: Nat;
        transactions: [Transaction];
    };

    public type UpdateArgs = {
        from: Account;
        token_id: TokenId;
        metadata: [(Text, Metadata)];
    };

    public type UpdateError = {
        #Unauthorized;
        #InvalidRecipient;
        #DoesntExistTokenId;
        #GenericError: { error_code: Nat; message: Text };
    };

    public type UpdateReceipt = Result<Nat, UpdateError>;

    public type OpenArgs = {
        from: Account;
        token_id: TokenId;
    };

    public type OpenError = {
        #Unauthorized;
        #InvalidRecipient;
        #DoesntExistTokenId;
        #GenericError: { error_code: Nat; message: Text };
    };

    public type OpenReceipt = Result<[(Text, Nat)], TransferError>;


// New Types of Metadata

// Root Type for NFT Metadata
public type Metadata = {
    general: GeneralMetadata;
    basic: ?BasicMetadata;
    skills: ?SkillMetadata;
    skins: ?SkinMetadata;
    soul: ?SoulMetadata;
};

// General Metadata
public type GeneralMetadata = {
    category: ?Category;
    rarity: ?Nat;
    faction: ?Faction;
    id: Nat;
    name: Text;
    description: Text;
    image: Text;
};

public type Faction = {
    #Cosmicon;
    #Spirat;
    #Webe;
    #Spade;
    #Arch;
    #Celestial;
    #Neutral;
};

// Basic Metadata
public type BasicMetadata = {
    level: Nat;
    health: Nat;
    damage: Nat;
};

// Category Type
public type Category = {
    #character: CharacterMetadata;
    #unit: Unit;
    #avatar: AvatarMetadata;
    #chest: ChestMetadata;
    #trophy: TrophyMetadata;
};

// Character Metadata
public type CharacterMetadata = {
    general: GeneralMetadata;
    basic: ?BasicMetadata;
    skills: ?SkillMetadata;
    skins: ?SkinMetadata;
    soul: ?SoulMetadata;
};

// Unit Type
public type Unit = {
    #spaceship: ?SpaceshipMetadata;
    #station: ?StationMetadata;
    #weapon: ?WeaponMetadata;
};

// Spaceship Metadata
public type SpaceshipMetadata = {
    general: GeneralMetadata;
    basic: ?BasicMetadata;
    skills: ?SkillMetadata;
    skins: ?SkinMetadata;
    soul: ?SoulMetadata;
};

// Station Metadata
public type StationMetadata = {
    general: GeneralMetadata;
    basic: ?BasicMetadata;
    skills: ?SkillMetadata;
    skins: ?SkinMetadata;
    soul: ?SoulMetadata;
};

// Weapon Metadata
public type WeaponMetadata = {
    general: GeneralMetadata;
    basic: ?BasicMetadata;
    skills: ?SkillMetadata;
    skins: ?SkinMetadata;
    soul: ?SoulMetadata;
};

// Avatar Metadata
public type AvatarMetadata = {
    general: GeneralMetadata;
    soul: ?SoulMetadata;
};

// Chest Metadata
public type ChestMetadata = {
    general: GeneralMetadata;
    soul: ?SoulMetadata;
};

// Trophy Metadata
public type TrophyMetadata = {
    general: GeneralMetadata;
    soul: ?SoulMetadata;
};

// Skin Metadata
public type SkinMetadata = {
    general: GeneralMetadata;
    soul: ?SoulMetadata;
};

// Soul Metadata
public type SoulMetadata = {
    birth: Time.Time;
    gamesPlayed: ?Nat;
    totalKills: ?Nat;
    totalDamageDealt: ?Nat;
};

// Skill Metadata
public type SkillMetadata = {
    #shield: ?ShieldMetadata;
    #evasion: ?EvasionMetadata;
    #criticalStrike: ?CriticalStrikeMetadata;
};

// Shield Skill Metadata
public type ShieldMetadata = {
    // Define fields specific to the shield skill
    // Placeholder fields for future expansion
};

// Evasion Skill Metadata
public type EvasionMetadata = {
    // Define fields specific to the evasion skill
    // Placeholder fields for future expansion
};

// Critical Strike Skill Metadata
public type CriticalStrikeMetadata = {
    // Define fields specific to the critical strike skill
    // Placeholder fields for future expansion
};


};
