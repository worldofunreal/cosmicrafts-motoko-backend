module {
    public type PlayerId = Principal;
    public type PlayerName = Text;
    public type Level = Nat;
    public type GameID = Principal;
    public type Players = Principal;

    public type PlayerPreferences = {
        language   : Nat;
        playerChar : Text;
    };

    public type Player = {
        id    : PlayerId;
        name  : PlayerName;
        level : Level;
        elo   : Float;
    };

    ///ICRC STANDARDS
    public type TokenId    = Nat;
    public type Subaccount = Blob;
    public type Balance    = Nat;
    public type TxIndex    = Nat;
}