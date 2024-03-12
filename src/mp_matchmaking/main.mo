import Types "./types";
import CosmicraftsTypes "../cosmicrafts/types";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";

// import IcWebSocketCdk "mo:ic-websocket-cdk";

import Cosmicrafts "../cosmicrafts/main";

actor class PlayersCanister() {
    type UserId            = Types.UserId;
    type MatchmakingStatus = Types.MatchmakingStatus;
    type MatchData         = Types.MatchData;
    type PlayerInfo        = Types.PlayerInfo;
    type PlayerStatus      = Types.PlayerStatus;
    type SearchStatus      = Types.SearchStatus;
    type FullPlayerInfo    = Types.FullPlayerInfo;
    type FullMatchData     = Types.FullMatchData;
    type Player            = CosmicraftsTypes.Player;

    let cosmicraftsCanister : Cosmicrafts.Cosmicrafts = actor("woimf-oyaaa-aaaan-qegia-cai"); /// cosmicrafts canister data

    /// Functions for finding Ships IDs
    func _natEqual (a : Nat, b : Nat) : Bool {
        return a == b;
    };
    func _natHash (a : Nat) : Hash.Hash {
        return Hash.hash(a);
    };

    private stable var _matchID : Nat = 1;

    private var inactiveSeconds : Nat64 = 25 * 1_000_000_000;
    private var NULL_PRINCIPAL: Principal = Principal.fromText("aaaaa-aa");
    private var ANON_PRINCIPAL: Principal = Principal.fromText("2vxsx-fae");

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

    //State functions
    system func preupgrade() {
        _searching     := Iter.toArray(searching.entries());
        _inProgress    := Iter.toArray(inProgress.entries());
        _finishedGames := Iter.toArray(finishedGames.entries());
    };
    system func postupgrade() {
        _searching     := [];
        _inProgress    := [];
        _finishedGames := [];
        /// Websockets
        // ws_state := IcWebSocketCdk.IcWebSocketState(gateway_principal);
        // ws := IcWebSocketCdk.IcWebSocket(ws_state, params);
    };

    /// Search if player has already a search in progress or wheter there's a match available or not
    // public shared query(msg) func getMatchSearching() : async (SearchStatus, Nat, Text){
        //     switch(playerStatus.get(msg.caller)){
        //         case (null) { }; /// Continue with search as this player is not currently in any status
        //         case (?_p) {
        //             switch(_p.status){
        //                 case(#Searching){
        //                     return(#Assigned, _p.matchID, "Searching for game");
        //                 };
        //                 case(#Reserved){
        //                     return(#Assigned, _p.matchID, "Game found");
        //                 };
        //                 case(#Accepting){
        //                     return(#Assigned, _p.matchID, "Accepting game");
        //                 };
        //                 case(#Accepted){
        //                     return(#Assigned, _p.matchID, "Game accepted");
        //                 };
        //                 case(#InGame){
        //                     return(#Assigned, _p.matchID, "In game");
        //                 };
        //                 case(#Ended){
        //                     /// Game ended, should remove from list or add the next match
        //                 };
        //             };
        //         };
        //     };
        //     for(m in searching.vals()){
        //         if(m.player2 == null){
        //             return(#Available, m.gameId, "ID Available");
        //         };
        //     };
        //     return (#NotAvailable, 0, "Not found game to match");
    // };

    
    /*
    ** When the player sends the setActive message and if the match is already made, continue to the next step
    */

    public shared(msg) func setPlayerActive() : async Bool {
        assert(msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
        switch(playerStatus.get(msg.caller)){
            case (null) { return false; };
            case (?_ps) {
                switch(searching.get(_ps.matchID)){
                    case (null) { return false; };
                    case (?_m) {
                        if(_m.player1.id == msg.caller){
                            let _p : PlayerInfo = _m.player1;
                            let _p1 : PlayerInfo = structPlayerActiveNow(_p);
                            let _gameData : MatchData = structMatchData(_p1, _m.player2, _m);
                            searching.put(_m.gameId, _gameData);
                            return true;
                        } else {
                            let _p : PlayerInfo = switch(_m.player2){
                                case (null) { return false; };
                                case (?_p) { _p; };
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
            id                = _p1.id;
            elo               = _p1.elo;
            matchAccepted     = _p1.matchAccepted;
            playerGameData    = _p1.playerGameData;
            lastPlayerActive  = Nat64.fromIntWrap(Time.now());
            // characterSelected = _p1.characterSelected;
            // deckSavedKeyIds   = _p1.deckSavedKeyIds;
        };
        return _p;
    };

    private func structMatchData(_p1 : PlayerInfo, _p2 : ?PlayerInfo, _m : MatchData) : MatchData{
        let _md : MatchData = {
            gameId  = _m.gameId;
            player1 = _p1;
            player2 = _p2;
            status  = _m.status;
        };
        return _md;
    };

    private func activatePlayerSearching(player : Principal, matchID : Nat) : Bool {
        switch(searching.get(matchID)){
            case (null) { return false; };
            case (?_m) {
                if(_m.player1.id == player){
                    let _p : PlayerInfo = _m.player1;
                    let _p1 : PlayerInfo = structPlayerActiveNow(_p);
                    let _gameData : MatchData = structMatchData(_p1, _m.player2, _m);
                    searching.put(_m.gameId, _gameData);
                    return true;
                } else {
                    let _p : PlayerInfo = switch(_m.player2){
                        case (null) { return false; };
                        case (?_p) { _p; };
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

    func _floatSort (a : Float, b : Float) : Float {
        if(a < b){
            return -1;
        } else if(a > b){
            return 1;
        } else {
            return 0;
        };
    };

    func getGamesByELOsorted(targetELO : Float, maxELO : Float) : [MatchData]{
        var _gamesByELO : [MatchData] = [];
        for(m in searching.vals()){
            if(m.player1.elo >= (targetELO - maxELO) and m.player1.elo <= (targetELO + maxELO)){
                /// To-Do: Add other loop to sort asc by ELO where all registries are passed and the new one is added in the right place
                if(Array.size(_gamesByELO) == 0){
                    _gamesByELO := [m];
                } else {
                    var _orderedGamesByELO : [MatchData] = [];
                    var _added : Bool = false;
                    for(n in _gamesByELO.vals()){
                        if(n.player1.elo > m.player1.elo){
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
                    if(_added == false){
                        _orderedGamesByELO := Array.append(_gamesByELO, [m]);
                    };
                    _gamesByELO := _orderedGamesByELO;
                };
            };
        };
        _gamesByELO;
    };

    public shared(msg) func getMatchSearching(pgd : Text) : async (SearchStatus, Nat, Text){
        assert(msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
        /// First we check if the player is already in a match
        switch(playerStatus.get(msg.caller)){
            case (null) { }; /// Continue with search as this player is not currently in any status
            case (?_p) {
                ///  The player has a status, check which one
                switch(_p.status){
                    case(#Searching){
                        /// The player was already searching, return the status
                        let _active : Bool = activatePlayerSearching(msg.caller, _p.matchID);
                        return(#Assigned, _p.matchID, "Searching for game");
                    };
                    case(#Reserved){
                        /// The player has found a match but hasn't accepted it yet
                        //return(#Assigned, _p.matchID, "Game found");
                    };
                    case(#Accepting){
                        /// The game is being accepted, ask the player for this
                        //return(#Assigned, _p.matchID, "Accepting game");
                    };
                    case(#Accepted){
                        /// The game was accepted, return the status
                        //return(#Assigned, _p.matchID, "Game accepted");
                    };
                    case(#InGame){
                        /// The game is in progress, return the status
                        /// return(#Assigned, _p.matchID, "In game");
                        /// Will comment this until we have a end game function and a way to check if a game is still active
                    };
                    case(#Ended){
                        /// Game ended, should remove from list or add the next match
                    };
                };
            };
        };
        /// Get Now Time
        let _now : Nat64 = Nat64.fromIntWrap(Time.now());
        let _pELO : Float = await cosmicraftsCanister.getPlayerElo(msg.caller);
        /// If the player wasn't on a game aleady, check if there's a match available
        var _gamesByELO : [MatchData] = getGamesByELOsorted(_pELO, 100.0); // To-Do: Sort by ELO
        for(m in _gamesByELO.vals()){
            if(m.player2 == null and m.player1.id != msg.caller /*and (m.player1.lastPlayerActive + inactiveSeconds) < _now*/){
                /// There's a match available, add the player to this match
                let _p2 : PlayerInfo = {
                    id                = msg.caller;
                    elo               = _pELO;
                    matchAccepted     = true; /// Force true for now
                    playerGameData    = pgd;
                    lastPlayerActive  = Nat64.fromIntWrap(Time.now());
                    // characterSelected = 0;
                    // deckSavedKeyIds   = [];
                };
                let _p1 : PlayerInfo = {
                    id               = m.player1.id;
                    elo              = m.player1.elo;
                    matchAccepted    = true;
                    playerGameData   = m.player1.playerGameData;
                    lastPlayerActive = m.player1.lastPlayerActive;
                };
                let _gameData : MatchData = {
                    gameId  = m.gameId;
                    player1 = _p1;
                    player2 = ?_p2;
                    status  = #Accepted;
                };
                let _p_s : PlayerStatus = {
                    status  = #Accepted;
                    matchID = m.gameId;
                };
                searching.put(m.gameId, _gameData);
                playerStatus.put(msg.caller, _p_s);
                playerStatus.put(m.player1.id, _p_s);
                return(#Assigned, _matchID, "Game found");
                //return(#Available, m.gameId, "ID Available");
            };
        };
        /// Continue with search as this player is not currently in any status
        _matchID := _matchID + 1;
        let _player : PlayerInfo = {
            id                = msg.caller;
            elo               = _pELO;
            matchAccepted     = false;
            playerGameData    = pgd;
            lastPlayerActive  = Nat64.fromIntWrap(Time.now());
            // characterSelected = 0;
            // deckSavedKeyIds   = [];
        };
        let _match : MatchData = {
            gameId  = _matchID;
            player1 = _player;
            player2 = null;
            status  = #Searching;
        };
        searching.put(_matchID, _match);
        let _ps : PlayerStatus = {
            status  = #Searching;
            matchID = _matchID;
        };
        playerStatus.put(msg.caller, _ps);
        return(#Assigned, _matchID, "Game found");
        //return (#NotAvailable, 0, "Not found game to match");
    };

    // public shared query func getAllSearchingMatches() : async [(Nat, MatchData)] {
    //     return Iter.toArray(searching.entries());
    // };

    // /// Create a new registry ("lobby") for the player searching for a match
    // public shared(msg) func addPlayerSearching() : async (Bool, Nat){
        //     assert(msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
        //     switch(playerStatus.get(msg.caller)){
        //         case (null) { 
        //             /// Continue with search as this player is not currently in any status
        //             _matchID := _matchID + 1;
        //             let _player : PlayerInfo = {
        //                 id                = msg.caller;
        //                 elo               = 0; /// TO-DO: ELO System; Also TO-DO: Ping system
        //                 matchAccepted     = false;
        //                 playerGameData    = "";
        //                 lastPlayerActive  = Nat64.fromIntWrap(Time.now());
        //                 // characterSelected = 0;
        //                 // deckSavedKeyIds   = [];
        //             };
        //             let _match : MatchData = {
        //                 gameId  = _matchID;
        //                 player1 = _player;
        //                 player2 = null;
        //                 status  = #Searching;
        //             };
        //             searching.put(_matchID, _match);
        //             let _ps : PlayerStatus = {
        //                 status  = #Searching;
        //                 matchID = _matchID;
        //             };
        //             playerStatus.put(msg.caller, _ps);
        //             return(true, _matchID);
        //         };
        //         case (?_p) {
        //             return(true, _p.matchID);
        //         };
        //     };
    // };

    // /// Match found, set player as rival for the matchID received
    // public shared(msg) func assignPlayer2(matchID : Nat) : async (Bool, Text){
        //     switch(searching.get(matchID)){
        //         case (null){
        //             return (false, "Game Not Available");
        //         };
        //         case (?_m){
        //             if(_m.player2 == null){
        //                 let _p2 : PlayerInfo = {
        //                     id                = msg.caller;
        //                     elo               = 0; /// TO-DO
        //                     matchAccepted     = false;
        //                     playerGameData    = "";
        //                     lastPlayerActive  = Nat64.fromIntWrap(Time.now());
        //                     // characterSelected = 0;
        //                     // deckSavedKeyIds   = [];
        //                 };
        //                 let _gameData : MatchData = {
        //                     gameId  = matchID;
        //                     player1 = _m.player1;
        //                     player2 = ?_p2;
        //                     status  = #Reserved;
        //                 };
        //                 let _p_s : PlayerStatus = {
        //                     status  = #Reserved;
        //                     matchID = matchID;
        //                 };
        //                 searching.put(matchID, _gameData);
        //                 playerStatus.put(msg.caller, _p_s);
        //                 playerStatus.put(_m.player1.id, _p_s);
        //                 //// TO-TEST: With Web Sockets Notify the other user that a match was found and both need to accept it
        //                 // await send_app_message(_m.player1.id, { message = "Game found"; data = matchID });
        //                 // await send_app_message(msg.caller, { message = "Game found"; data = matchID });
        //                 return(true, "Assigned");
        //             };
        //             return(false, "Game Is Not Available");
        //         };
        //     }
    // };

    // /// User accepted match found
    // public shared(msg) func acceptMatch(/*c : Nat, deckSaved : [Text]*/ pgd : Text) : async (Bool, Text){
        //     switch(playerStatus.get(msg.caller)){
        //         case(null){
        //             return(false, "Game not found for this player");
        //         };
        //         case(?_s){
        //             if(_s.status == #Reserved or _s.status == #Accepting){
        //                 switch(searching.get(_s.matchID)){
        //                     case(null){
        //                         return(false, "Game not found for this player");
        //                     };
        //                     case(?_m){
        //                         /// Check if caller is player 1 or 2
        //                         if(_m.player1.id == msg.caller){
        //                             /// Check if other player already accepted the game
        //                             let _status : MatchmakingStatus = switch(_m.player2){
        //                                 case(null){
        //                                     /// If is not set the other player, set as searching /// DEBUG THIS
        //                                     #Searching;
        //                                 };
        //                                 case(?_st){
        //                                     /// If player is set check if it already accepted, in that case set as Accepted, if not as Accepting
        //                                     if(_st.matchAccepted == true){
        //                                         #Accepted;
        //                                     } else {
        //                                         #Accepting;
        //                                     }
        //                                 };
        //                             };
        //                             let _player1 : PlayerInfo = {
        //                                 id                = _m.player1.id;
        //                                 matchAccepted     = true;
        //                                 elo               = _m.player1.elo;
        //                                 playerGameData    = pgd;
        //                                 lastPlayerActive  = Nat64.fromIntWrap(Time.now());
        //                                 // characterSelected = c;
        //                                 // deckSavedKeyIds   = deckSaved;
        //                             };
        //                             let m : MatchData = {
        //                                 gameId  = _s.matchID;
        //                                 player1 = _player1;
        //                                 player2 = _m.player2;
        //                                 status  = _status;
        //                             };
        //                             if(_status == #Accepted){
        //                                 /// Move the match from searching to "in progress"
        //                                     // searching.delete(_s.matchID);
        //                                     // inProgress.put(_s.matchID, m);
        //                                 /// Set both players as "In Game"
        //                                 let _p_s : PlayerStatus = {
        //                                     status  = #InGame;
        //                                     matchID = _s.matchID;
        //                                 };
        //                                 playerStatus.put(msg.caller, _p_s);
        //                                 switch(_m.player2){
        //                                     case(null){};
        //                                     case(?_p2){
        //                                         //// TO-TEST: USE WEB HOOKS TO NOTIFY THE OTHER PLAYER THAT THE MATCH WAS ACCEPTED
        //                                         playerStatus.put(_p2.id, _p_s);
        //                                         // await send_app_message(_player1.id, { message = "Game accepted"; data = _s.matchID });
        //                                         // await send_app_message(_p2.id, { message = "Game accepted"; data = _s.matchID });
        //                                     };
        //                                 };
        //                                 return(true, "Accepted and In Progress");
        //                             } else {
        //                                 /// Set searching status
        //                                 searching.put(_s.matchID, m);
        //                                 /// Set Player as status
        //                                 let _p_s : PlayerStatus = {
        //                                     status  = _status;
        //                                     matchID = _s.matchID;
        //                                 };
        //                                 playerStatus.put(msg.caller, _p_s);
        //                                 return(true, "Accepted");
        //                             };
        //                         };
        //                         /// It wasn't p1, check if it is p2
        //                         let _p2 = switch(_m.player2){
        //                             case(null){
        //                                 return(false, "Game not found for this player");
        //                             };
        //                             case(?_p2){
        //                                 _p2;
        //                             };
        //                         };
        //                         if(_p2.id == msg.caller){
        //                             /// Check if other player already accepted the game
        //                             let _status : MatchmakingStatus = switch(_m.player1.matchAccepted){
        //                                 case(false){
        //                                     #Accepting;
        //                                 };
        //                                 case(true){
        //                                     #Accepted;
        //                                 };
        //                             };
        //                             let _player2 : PlayerInfo = {
        //                                 id                = _p2.id;
        //                                 matchAccepted     = true;
        //                                 elo               = _p2.elo;
        //                                 playerGameData    = pgd;
        //                                 lastPlayerActive  = Nat64.fromIntWrap(Time.now());
        //                                 // characterSelected = c;
        //                                 // deckSavedKeyIds   = deckSaved;
        //                             };
        //                             let m : MatchData = {
        //                                 gameId  = _s.matchID;
        //                                 player1 = _m.player1;
        //                                 player2 = ?_p2;
        //                                 status  = _status;
        //                             };
        //                             if(_status == #Accepted){
        //                                 //// TO-TEST: USE WEB HOOKS TO NOTIFY BOTH PLAYERS THAT THE MATCH WAS ACCEPTED
        //                                 // await send_app_message(_m.player1.id, { message = "Game accepted"; data = _s.matchID });
        //                                 // await send_app_message(_p2.id, { message = "Game accepted"; data = _s.matchID });
        //                                 /// Move the match from searching to "in progress"
        //                                     // searching.delete(_s.matchID);
        //                                     // inProgress.put(_s.matchID, m);
        //                                 /// Set both players as "In Game"
        //                                 let _p_s : PlayerStatus = {
        //                                     status  = #InGame;
        //                                     matchID = _s.matchID;
        //                                 };
        //                                 playerStatus.put(msg.caller, _p_s);
        //                                 playerStatus.put(_m.player1.id, _p_s);
        //                                 return(true, "Accepted and In Progress");
        //                             } else {
        //                                 /// Set searching status
        //                                 searching.put(_s.matchID, m);
        //                                 /// Set Player as status
        //                                 let _p_s : PlayerStatus = {
        //                                     status  = _status;
        //                                     matchID = _s.matchID;
        //                                 };
        //                                 playerStatus.put(msg.caller, _p_s);
        //                                 return(true, "Accepted");
        //                             };
        //                         } else {
        //                             return (false, "Invalid Game");
        //                         }
        //                     };
        //                 };
        //             }
        //         };
        //     };
        //     return(false, "Not Accepted");
    // };

    // /// User didn't accept the match found
    // public shared(msg) func rejectMatch() : async (Bool, Text){
        //     switch(playerStatus.get(msg.caller)){
        //         case(null){
        //             return(false, "Game not found for this player");
        //         };
        //         case(?_s){
        //             if(_s.status != #Searching){
        //                 switch(searching.get(_s.matchID)){
        //                     case(null){
        //                         return(false, "Game not found for this player");
        //                     };
        //                     case(?_m){
        //                         /// Check if caller is player 1 or 2
        //                         if(_m.player1.id == msg.caller){
        //                             /// Remove player from searching status
        //                             playerStatus.delete(msg.caller);
        //                             /// Check if other player already accepted the game
        //                             switch(_m.player2){
        //                                 case(null){
        //                                     /// If is not set the other player, remove this player from list as the other didn't accept and was already removed
        //                                     searching.delete(_s.matchID);
        //                                     return(true, "Player removed from matchmaking");
        //                                 };
        //                                 case(?_st){
        //                                     // Set the player 2 as player 1, remove this player from searching and set the match as searching again
        //                                     let m : MatchData = {
        //                                         gameId  = _s.matchID;
        //                                         player1 = _st;
        //                                         player2 = null;
        //                                         status  = #Searching;
        //                                     };
        //                                     searching.put(_s.matchID, m);
        //                                     //// TO-TEST: USE WEB HOOKS TO NOTIFY THE OTHER PLAYER THAT THEY WERE RETURNED TO SEARCHING
        //                                     // await send_app_message(_st.id, { message = "Returning to search"; data = 0; });
        //                                     return(true, "Player removed from matchmaking");
        //                                 };
        //                             };
        //                         };
        //                         /// It wasn't p1, check if it is p2
        //                         switch(_m.player2){
        //                             case(null){
        //                                 return(false, "Game not found for this player");
        //                             };
        //                             case(?_p2){
        //                                 if(_p2.id == msg.caller){
        //                                     /// Remove player from searching status
        //                                     playerStatus.delete(msg.caller);
        //                                     /// Check if other player already accepted the game
        //                                     let m : MatchData = {
        //                                         gameId  = _s.matchID;
        //                                         player1 = _m.player1;
        //                                         player2 = null;
        //                                         status  = #Searching;
        //                                     };
        //                                     searching.put(_s.matchID, m);
        //                                     //// TO-TEST: USE WEB HOOKS TO NOTIFY THE OTHER PLAYER THAT THEY WERE RETURNED TO SEARCHING
        //                                     // await send_app_message(_m.player1.id, { message = "Returning to search"; data = 0; });
        //                                     return(true, "Player removed from matchmaking");
        //                                 };
        //                             };
        //                         };
        //                     };
        //                 };
        //             }
        //         };
        //     };
        //     return(false, "Game not found for this player");
    // };

    /// Cancel search on user's request
    public shared(msg) func cancelMatchmaking() : async (Bool, Text){
        assert(msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
        switch(playerStatus.get(msg.caller)){
            case(null){
                return(true, "Game not found for this player");
            };
            case(?_s){
                if(_s.status == #Searching){
                    searching.delete(_s.matchID);
                    playerStatus.delete(msg.caller);
                    return(true, "Matchmaking canceled successfully");
                } else {
                    return(false, "Match found, cannot cancel at this time");
                }
            };
        };
    };

    func getOtherPlayer(_m : MatchData, caller : Principal) : ?Principal {
        switch(_m.player1.id == caller){
            case(true){
                switch(_m.player2){
                    case(null){
                        return(null);
                    };
                    case(?_p2){
                        return(?_p2.id);
                    };
                };
            };
            case(false){
                return(?_m.player1.id);
            };
        };
    };

    /// Move game from "In Progress" to "Finished"
    public shared(msg) func setGameOver(caller : Principal) : async (Bool, Bool, ?Principal){
        assert(msg.caller == Principal.fromText("jybso-3iaaa-aaaan-qeima-cai"));
        switch(playerStatus.get(caller)){
            case(null){
                return(false, false, null);
            };
            case(?_s){
                switch(inProgress.get(_s.matchID)){
                    case(null){
                        switch(searching.get(_s.matchID)){
                            case(null){
                                /// Game is not on the searching on inProgress, so we just remove the status from the player
                                playerStatus.delete(caller);
                                return(false, false, null);
                            };
                            case(?_m){
                                /// Game is on Searching list, so we remove it, add it to the finished list and remove the status from the player
                                finishedGames.put(_s.matchID, _m);
                                searching.delete(_s.matchID);
                                playerStatus.delete(caller);
                                return(true, caller == _m.player1.id, getOtherPlayer(_m, caller));
                            };
                        };
                        
                    };
                    case(?_m){
                        /// Game is on inProgress list, so we remove it, add it to the finished list and remove the status from the player
                        finishedGames.put(_s.matchID,_m);
                        inProgress.delete(_s.matchID);
                        playerStatus.delete(caller);
                        return(true, caller == _m.player1.id, getOtherPlayer(_m, caller));
                    };
                };
            };
        };
    };

    public shared query(msg) func isGameMatched() : async (Bool, Text){
        switch(playerStatus.get(msg.caller)){
            case(null){
                return(false, "Game not found for this player");
            };
            case(?_s){
                switch(searching.get(_s.matchID)){
                    case(null){
                        return(false, "Game not found for this player");
                    };
                    case(?_m){
                        switch(_m.player2){
                            case(null){
                                return(false, "Not matched yet");
                            };
                            case(?_p2){
                                return(true, "Game matched");
                            };
                        };
                    };
                };
            };
        };
    };

    // public shared query(msg) func isGameAccepted() : async (Nat, Text){
        //     switch(playerStatus.get(msg.caller)){
        //         case(null){
        //             return(3, "Game not found for this player");
        //         };
        //         case(?_s){
        //             switch(searching.get(_s.matchID)){
        //                 case(null){
        //                     return(3, "Game not found for this player");
        //                 };
        //                 case(?_m){
        //                     switch(_m.player2){
        //                         case(null){
        //                             return(2, "Other player rejected the game");
        //                         };
        //                         case(?_p2){
        //                             if(_p2.matchAccepted == true and _m.player1.matchAccepted == true){
        //                                 return(1, "Game accepted");
        //                             } else {
        //                                 return(0, "Game not accepted yet");
        //                             };
        //                         };
        //                     };
        //                 };
        //             };
        //         };
        //     };
    // };

    public query func getMatchData(matchID : Nat) : async ?MatchData{

        switch(searching.get(matchID)){
            case(null){
                switch(inProgress.get(matchID)){
                    case(null){
                        switch(finishedGames.get(matchID)){
                            case(null){
                                return(null);
                            };
                            case(?_m){
                                return(?_m);
                            };
                        };
                    };
                    case(?_m){
                        return(?_m);
                    };
                };
            };
            case(?_m){
                return(?_m);
            };
        };
    };

    public shared composite query(msg) func getMyMatchData() : async (?FullMatchData, Nat){
        assert(msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
        // public shared(msg) func getMyMatchData() : async (?FullMatchData, Nat){
        switch(playerStatus.get(msg.caller)){
            case(null){
                return(null, 0);
            };
            case(?_s){
                var _m : MatchData = switch(searching.get(_s.matchID)){
                    case(null){
                        switch(inProgress.get(_s.matchID)){
                            case(null){
                                switch(finishedGames.get(_s.matchID)){
                                    case(null){
                                        return(null, 0);
                                    };
                                    case(?_m){
                                        _m;
                                    };
                                };
                            };
                            case(?_m){
                                _m;
                            };
                        };
                    };
                    case(?_m){
                        _m;
                    };
                };
                let _p : Nat = switch(_m.player1.id == msg.caller){
                    case(true){
                        1;
                    };
                    case(false){
                        switch(_m.player2){
                            case(null){
                                return(null, 0);
                            };
                            case(?_p2){
                                2;
                            };
                        };
                    };
                };
                let _p1Name : Text = switch(await cosmicraftsCanister.getPlayerData(_m.player1.id)){
                    case null {
                        "";
                    };
                    case(?p1){
                        p1.name;
                    };
                };
                let _fullPlayer2 : FullPlayerInfo = switch(_m.player2){
                    case null {
                        {
                            id             = Principal.fromText("");
                            matchAccepted  = false;
                            elo            = 0;
                            playerGameData = "";
                            playerName     = "";
                        };
                    };
                    case(?p2){
                        let _p2D : ?Player = await cosmicraftsCanister.getPlayerData(p2.id);
                        switch(_p2D){
                            case null {
                                {
                                    id             = p2.id;
                                    matchAccepted  = p2.matchAccepted;
                                    elo            = p2.elo;
                                    playerGameData = p2.playerGameData;
                                    playerName     = "";
                                };
                            };
                            case(?_p2D){
                                {
                                    id             = p2.id;
                                    matchAccepted  = p2.matchAccepted;
                                    elo            = p2.elo;
                                    playerGameData = p2.playerGameData;
                                    playerName     = _p2D.name;
                                };
                            };
                        };
                    };
                };
                let _fullPlayer1 : FullPlayerInfo = {
                    id             = _m.player1.id;
                    matchAccepted  = _m.player1.matchAccepted;
                    elo            = _m.player1.elo;
                    playerGameData = _m.player1.playerGameData;
                    playerName     = _p1Name;
                };
                let fm : FullMatchData = {
                    gameId  = _m.gameId;
                    player1 = _fullPlayer1;
                    player2 = ?_fullPlayer2;
                    status  = _m.status;
                };
                return(?fm, _p);


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

    // public shared(msg) func addMatchPlayerData(pgd : Text) : async Bool{
        //     switch(playerStatus.get(msg.caller)){
        //         case(null){
        //             return false;
        //         };
        //         case(?_p){
        //             switch(searching.get(_p.matchID)){
        //                 case(null){
        //                     return false;
        //                 };
        //                 case(?_m){
        //                     if(_m.player1.id == msg.caller){
        //                         let _p1 : PlayerInfo = {
        //                             id                = _m.player1.id;
        //                             elo               = _m.player1.elo;
        //                             matchAccepted     = true;
        //                             playerGameData    = pgd;
        //                             lastPlayerActive  = Nat64.fromIntWrap(Time.now());
        //                         };
        //                         let _md : MatchData = {
        //                             gameId  = _m.gameId;
        //                             player1 = _p1;
        //                             player2 = _m.player2;
        //                             status  = #InGame;
        //                         };
        //                         let _p_s : PlayerStatus = {
        //                             status  = #InGame;
        //                             matchID = _p.matchID;
        //                         };
        //                         playerStatus.put(msg.caller, _p_s);
        //                         searching.put(_p.matchID, _md);
        //                         return true;
        //                     };
        //                     switch(_m.player2){
        //                         case(null){
        //                             return false;
        //                         };
        //                         case(?_p2){
        //                             if(_p2.id == msg.caller){
        //                                 let _p2d : PlayerInfo = {
        //                                     id                = _p2.id;
        //                                     elo               = _p2.elo;
        //                                     matchAccepted     = true;
        //                                     playerGameData    = pgd;
        //                                     lastPlayerActive  = Nat64.fromIntWrap(Time.now());
        //                                 };
        //                                 let _md : MatchData = {
        //                                     gameId  = _m.gameId;
        //                                     player1 = _m.player1;
        //                                     player2 = ?_p2d;
        //                                     status  = #InGame;
        //                                 };
        //                                 let _p_s : PlayerStatus = {
        //                                     status  = #InGame;
        //                                     matchID = _p.matchID;
        //                                 };
        //                                 playerStatus.put(msg.caller, _p_s);
        //                                 searching.put(_p.matchID, _md);
        //                                 return true;
        //                             };
        //                             return false;
        //                         };
        //                     };
        //                 };
        //             };
        //         };
        //     };
    // };




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

};