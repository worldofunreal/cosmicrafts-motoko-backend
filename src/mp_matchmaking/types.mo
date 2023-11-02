module {
    public type UserId = Principal;

    public type MatchmakingStatus = {
        #Searching;
        #Reserved;
        #Accepting;
        #Accepted;
        #InGame;
        #Ended;
    };

    public type SearchStatus = {
        #Assigned;
        #Available;
        #NotAvailable;
    };

    public type PlayerInfo = {
        id                : UserId;
        matchAccepted     : Bool;
        elo               : Nat;
        characterSelected : Nat;
    };

    public type PlayerStatus = {
        status  : MatchmakingStatus;
        matchID : Nat;
    };

    public type MatchData = {
        gameId  : Nat;
        player1 : PlayerInfo;
        player2 : ?PlayerInfo;
        status  : MatchmakingStatus;
    };  
};