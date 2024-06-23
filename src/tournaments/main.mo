import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Order "mo:base/Order";

actor Backend {
    stable var users: [{ principal: Principal; username: Text; elo: Nat; avatarId: Nat }] = [];
    stable var tournaments: [Tournament] = [];
    stable var matches: [Match] = [];
    stable var feedback: [{ principal: Principal; tournamentId: Nat; feedback: Text }] = [];
    stable var disputes: [{ principal: Principal; matchId: Nat; reason: Text; status: Text }] = [];

    type Tournament = {
        id: Nat;
        name: Text;
        startDate: Time.Time;
        prizePool: Text;
        expirationDate: Time.Time;
        participants: [Principal];
        isActive: Bool;
    };

    type Match = {
        id: Nat;
        participants: [Principal];
        result: ?{winner: Principal; score: Text};
        status: Text;
    };

    public shared ({caller}) func createTournament(name: Text, startDate: Time.Time, prizePool: Text, expirationDate: Time.Time) : async Nat {
        if (caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae")) {
            return 0;
        };

        let id = tournaments.size();
        let buffer = Buffer.Buffer<Tournament>(tournaments.size() + 1);
        for (tournament in tournaments.vals()) {
            buffer.add(tournament);
        };
        buffer.add({
            id = id;
            name = name;
            startDate = startDate;
            prizePool = prizePool;
            expirationDate = expirationDate;
            participants = [];
            isActive = true
        });
        tournaments := Buffer.toArray(buffer);
        return id;
    };

    public shared ({caller}) func joinTournament(tournamentId: Nat) : async Bool {
        // Check if the tournament exists
        if (tournamentId >= tournaments.size()) {
            return false;
        };
        
        let tournament = tournaments[tournamentId];
        
        // Check if the user is already a participant
        if (Array.indexOf<Principal>(caller, tournament.participants, func (a: Principal, b: Principal) : Bool { a == b }) != null) {
            return false;
        };
        
        // Add the user to the tournament participants
        var updatedParticipants = Buffer.Buffer<Principal>(tournament.participants.size() + 1);
        for (participant in tournament.participants.vals()) {
            updatedParticipants.add(participant);
        };
        updatedParticipants.add(caller);

        let updatedTournament = {
            id = tournament.id;
            name = tournament.name;
            startDate = tournament.startDate;
            prizePool = tournament.prizePool;
            expirationDate = tournament.expirationDate;
            participants = Buffer.toArray(updatedParticipants);
            isActive = tournament.isActive;
        };

        tournaments := Array.tabulate(tournaments.size(), func(i: Nat): Tournament {
            if (i == tournamentId) {
                updatedTournament
            } else {
                tournaments[i]
            }
        });

        return true;
    };

    public shared ({caller}) func submitFeedback(_tournamentId: Nat, feedbackText: Text) : async Bool {
        let newFeedback = Buffer.Buffer<{principal: Principal; tournamentId: Nat; feedback: Text}>(feedback.size() + 1);
        for (entry in feedback.vals()) {
            newFeedback.add(entry);
        };
        newFeedback.add({principal = caller; tournamentId = _tournamentId; feedback = feedbackText});
        feedback := Buffer.toArray(newFeedback);
        return true;
    };

    public shared ({caller}) func submitMatchResult(matchId: Nat, winner: Principal, score: Text) : async Bool {
        // Ensure the caller is authorized to submit match results
        let authorized = switch (Array.find(matches, func (m: Match) : Bool {
            m.id == matchId and Array.find(m.participants, func (p: Principal) : Bool { p == caller }) != null
        })) {
            case (?_) { true };
            case null { false };
        };
        if (not authorized) {
            return false;
        };

        let matchIndex = Array.indexOf<Match>(
            { id = matchId; participants = []; result = null; status = "" }, 
            matches, 
            func (a: Match, b: Match) : Bool { a.id == b.id }
        );
        switch (matchIndex) {
            case (?idx) {
                var updatedMatches = Buffer.Buffer<Match>(matches.size());
                for (m in matches.vals()) {
                    if (m.id == matchId) {
                        updatedMatches.add({ id = m.id; participants = m.participants; result = ?{winner = winner; score = score}; status = "pending verification" });
                    } else {
                        updatedMatches.add(m);
                    }
                };
                matches := Buffer.toArray(updatedMatches);
                return true;
            };
            case null {
                return false;
            };
        }
    };

    public shared ({caller}) func disputeMatch(matchId: Nat, reason: Text) : async Bool {
        // Check if the match exists
        let matchExists = Array.find(matches, func (m: Match) : Bool { m.id == matchId }) != null;
        if (not matchExists) {
            return false;
        };

        // Add the dispute to the disputes array
        let newDispute = { principal = caller; matchId = matchId; reason = reason; status = "pending" };
        let updatedDisputes = Buffer.Buffer<{ principal: Principal; matchId: Nat; reason: Text; status: Text }>(disputes.size() + 1);
        for (dispute in disputes.vals()) {
            updatedDisputes.add(dispute);
        };
        updatedDisputes.add(newDispute);
        disputes := Buffer.toArray(updatedDisputes);

        return true;
    };

    public shared ({caller}) func resolveDispute(matchId: Nat, resolution: Text) : async Bool {
        if (caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae")) {
            return false;
        };

        let updatedDisputes = Buffer.Buffer<{ principal: Principal; matchId: Nat; reason: Text; status: Text }>(disputes.size());
        for (dispute in disputes.vals()) {
            if (dispute.matchId == matchId) {
                updatedDisputes.add({ principal = dispute.principal; matchId = dispute.matchId; reason = dispute.reason; status = resolution });
            } else {
                updatedDisputes.add(dispute);
            }
        };
        disputes := Buffer.toArray(updatedDisputes);

        return true;
    };

    public query func getRegisteredUsers(tournamentId: Nat) : async [{ principal: Principal; username: Text; elo: Nat; avatarId: Nat }] {
        return Array.filter<{ principal: Principal; username: Text; elo: Nat; avatarId: Nat }>(users, func (user: { principal: Principal; username: Text; elo: Nat; avatarId: Nat }) : Bool {
            Array.indexOf<Principal>(user.principal, tournaments[tournamentId].participants, func (a: Principal, b: Principal) : Bool { a == b }) != null
        });
    };

    public shared func updateBracket(tournamentId: Nat) : async Bool {
        if (tournamentId < tournaments.size()) {
            var tournament = tournaments[tournamentId];
            let participants = tournament.participants;

            // Sort participants by their ELO in descending order
            let sortedParticipants = Array.sort<Principal>(participants, func (a: Principal, b: Principal) : Order.Order {
                let eloA = switch (Array.find(users, func (user: { principal: Principal; username: Text; elo: Nat; avatarId: Nat }) : Bool { user.principal == a })) {
                    case (?user) { user.elo };
                    case null { 0 };
                };
                let eloB = switch (Array.find(users, func (user: { principal: Principal; username: Text; elo: Nat; avatarId: Nat }) : Bool { user.principal == b })) {
                    case (?user) { user.elo };
                    case null { 0 };
                };
                if (eloA > eloB) {
                    #greater
                } else if (eloA < eloB) {
                    #less
                } else {
                    #equal
                }
            });

            // Create matches based on sorted participants
            var newMatches = Buffer.Buffer<Match>(sortedParticipants.size() / 2);
            var i = 0;
            while (i < (sortedParticipants.size() / 2)) {
                newMatches.add({
                    id = matches.size() + i;
                    participants = [sortedParticipants[2 * i], sortedParticipants[2 * i + 1]];
                    result = null;
                    status = "scheduled";
                });
                i += 1;
            };

            // Update the stable variable matches and the tournament
            var updatedMatches = Buffer.Buffer<Match>(matches.size() + newMatches.size());
            for (match in matches.vals()) {
                updatedMatches.add(match);
            };
            for (newMatch in newMatches.vals()) {
                updatedMatches.add(newMatch);
            };
            matches := Buffer.toArray(updatedMatches);

            let updatedTournament = {
                id = tournament.id;
                name = tournament.name;
                startDate = tournament.startDate;
                prizePool = tournament.prizePool;
                expirationDate = tournament.expirationDate;
                participants = tournament.participants;
                isActive = true;
            };

            tournaments := Array.tabulate(tournaments.size(), func (i: Nat) : Tournament {
                if (i == tournamentId) {
                    updatedTournament
                } else {
                    tournaments[i]
                }
            });

            return true;
        };
        return false;
    };

    public shared func closeRegistration(tournamentId: Nat) : async Bool {
        if (tournamentId < tournaments.size()) {
            let updatedTournament = {
                id = tournaments[tournamentId].id;
                name = tournaments[tournamentId].name;
                startDate = tournaments[tournamentId].startDate;
                prizePool = tournaments[tournamentId].prizePool;
                expirationDate = tournaments[tournamentId].expirationDate;
                participants = tournaments[tournamentId].participants;
                isActive = false;
            };

            tournaments := Array.tabulate(tournaments.size(), func(i: Nat): Tournament {
                if (i == tournamentId) {
                    updatedTournament
                } else {
                    tournaments[i]
                }
            });

            return true;
        };
        return false;
    };

    public shared ({caller}) func adminUpdateMatchResult(matchId: Nat, winner: Principal, score: Text) : async Bool {
        if (caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae")) {
            return false;
        };

        let matchIndex = Array.indexOf<Match>(
            {id = matchId; participants = []; result = null; status = ""},
            matches,
            func (m1: Match, m2: Match): Bool { m1.id == m2.id }
        );

        switch (matchIndex) {
            case (?idx) {
                let buffer = Buffer.Buffer<Match>(matches.size());
                for (match in matches.vals()) {
                    if (match.id == matchId) {
                        buffer.add({id = match.id; participants = match.participants; result = ?{winner = winner; score = score}; status = "verified"});
                    } else {
                        buffer.add(match);
                    }
                };
                matches := Buffer.toArray(buffer);
                return true;
            };
            case null {
                return false;
            };
        }
    };

    public shared ({caller}) func manageDispute(matchId: Nat, resolution: Text) : async Bool {
        if (caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae")) {
            return false;
        };

        let matchIndex = Array.find<Match>(matches, func (m: Match) : Bool { m.id == matchId });
        switch (matchIndex) {
            case (?match) {
                var updatedMatches = Buffer.Buffer<Match>(matches.size());
                for (m in matches.vals()) {
                    if (m.id == matchId) {
                        updatedMatches.add({
                            id = m.id;
                            participants = m.participants;
                            result = m.result;
                            status = resolution;
                        });
                    } else {
                        updatedMatches.add(m);
                    }
                };
                matches := Buffer.toArray(updatedMatches);
                return true;
            };
            case null {
                return false;
            };
        }
    };

    public shared ({caller}) func forfeitMatch(matchId: Nat, _player: Principal) : async Bool {
        if (caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae")) {
            return false;
        };

        let matchIndex = Array.find<Match>(matches, func (m: Match) : Bool { m.id == matchId });
        switch (matchIndex) {
            case (?match) {
                var updatedMatches = Buffer.Buffer<Match>(matches.size());
                for (m in matches.vals()) {
                    if (m.id == matchId) {
                        var newStatus = if (Array.indexOf<Principal>(_player, m.participants, func (a: Principal, b: Principal) : Bool { a == b }) != null) {
                            "forfeited by " # Principal.toText(_player)
                        } else {
                            m.status
                        };
                        updatedMatches.add({
                            id = m.id;
                            participants = m.participants;
                            result = m.result;
                            status = newStatus;
                        });
                    } else {
                        updatedMatches.add(m);
                    }
                };
                matches := Buffer.toArray(updatedMatches);
                return true;
            };
            case null {
                return false;
            };
        }
    };

    public query func getActiveTournaments() : async [Tournament] {
        return Array.filter<Tournament>(tournaments, func (t: Tournament) : Bool { t.isActive });
    };

    public query func getInactiveTournaments() : async [Tournament] {
        return Array.filter<Tournament>(tournaments, func (t: Tournament) : Bool { not t.isActive });
    };

    public query func getAllTournaments() : async [Tournament] {
        return tournaments;
    };

    public query func getTournamentBracket(tournamentId: Nat) : async {matches: [Match]} {
        return {
            matches = Array.filter<Match>(matches, func (m: Match) : Bool { m.id == tournamentId })
        };
    };

    public shared func deleteAllTournaments() : async Bool {
        tournaments := [];
        matches := [];
        return true;
    };
}