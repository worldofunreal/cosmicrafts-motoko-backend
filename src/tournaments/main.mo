import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Random "mo:base/Random";

actor Backend {
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
        bracketCreated: Bool;
    };

    type Match = {
        id: Nat;
        tournamentId: Nat;
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
            isActive = true;
            bracketCreated = false
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
            bracketCreated = tournament.bracketCreated
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

    public query func getRegisteredUsers(tournamentId: Nat) : async [Principal] {
        if (tournamentId >= tournaments.size()) {
            return [];
        };

        let tournament: Tournament = tournaments[tournamentId];
        return tournament.participants;
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

    public shared ({caller}) func submitMatchResult(matchId: Nat, score: Text) : async Bool {
        // Find the match with the given ID
        let matchOpt = Array.find<Match>(matches, func (m: Match) : Bool { m.id == matchId });
        switch (matchOpt) {
            case (?match) {
                // Ensure the caller is a participant in the match
                let isParticipant = Array.find<Principal>(match.participants, func (p: Principal) : Bool { p == caller }) != null;
                if (not isParticipant) {
                    return false;
                };

                // Update the match with the result
                var updatedMatches = Buffer.Buffer<Match>(matches.size());
                for (m in matches.vals()) {
                    if (m.id == matchId) {
                        updatedMatches.add({
                            id = m.id;
                            tournamentId = m.tournamentId;
                            participants = m.participants;
                            result = ?{winner = caller; score = score};
                            status = "pending verification";
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

    public shared ({caller}) func adminUpdateMatch(matchId: Nat, score: Text) : async Bool {
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
                            tournamentId = m.tournamentId;
                            participants = m.participants;
                            result = ?{winner = m.participants[0]; score = score};
                            status = "verified";
                        });
                    } else {
                        updatedMatches.add(m);
                    }
                };
                matches := Buffer.toArray(updatedMatches);

                // Handle progress to next round or declare winner
                var foundTournament: ?Tournament = null;
                for (t in tournaments.vals()) {
                    if (Array.find(t.participants, func (p: Principal) : Bool { p == match.participants[0] or p == match.participants[1] }) != null) {
                        foundTournament := ?t;
                    }
                };

                switch (foundTournament) {
                    case (?t) {
                        var allMatchesVerified = true;
                        var winners = Buffer.Buffer<Principal>(0);
                        for (m in matches.vals()) {
                            if (m.tournamentId == t.id and Array.find(t.participants, func (p: Principal) : Bool { p == m.participants[0] or p == m.participants[1] }) != null) {
                                if (m.status != "verified") {
                                    allMatchesVerified := false;
                                } else {
                                    switch (m.result) {
                                        case (?res) {
                                            winners.add(res.winner);
                                        };
                                        case null {};
                                    }
                                }
                            }
                        };

                        if (allMatchesVerified) {
                            if (winners.size() == 1) {
                                let updatedTournaments = Buffer.Buffer<Tournament>(tournaments.size());
                                for (tournament in tournaments.vals()) {
                                    if (tournament.id == t.id) {
                                        updatedTournaments.add({
                                            id = tournament.id;
                                            name = tournament.name;
                                            startDate = tournament.startDate;
                                            prizePool = tournament.prizePool;
                                            expirationDate = tournament.expirationDate;
                                            participants = tournament.participants;
                                            isActive = false; // We have a champion
                                            bracketCreated = tournament.bracketCreated
                                        });
                                    } else {
                                        updatedTournaments.add(tournament);
                                    }
                                };
                                tournaments := Buffer.toArray(updatedTournaments);
                            } else {
                                // Create next round
                                let nextParticipants = Buffer.toArray(winners);
                                let updatedTournaments = Buffer.Buffer<Tournament>(tournaments.size());
                                for (tournament in tournaments.vals()) {
                                    if (tournament.id == t.id) {
                                        updatedTournaments.add({
                                            id = tournament.id;
                                            name = tournament.name;
                                            startDate = tournament.startDate;
                                            prizePool = tournament.prizePool;
                                            expirationDate = tournament.expirationDate;
                                            participants = nextParticipants;
                                            isActive = true;
                                            bracketCreated = true
                                        });
                                    } else {
                                        updatedTournaments.add(tournament);
                                    }
                                };
                                tournaments := Buffer.toArray(updatedTournaments);
                                ignore await updateBracket(t.id);
                            }
                        }
                    };
                    case null {};
                };

                return true;
            };
            case null {
                return false;
            };
        }
    };

    public shared func updateBracket(tournamentId: Nat) : async Bool {
        if (tournamentId >= tournaments.size()) {
            return false;
        };

        var tournament = tournaments[tournamentId];
        if (tournament.bracketCreated) {
            return false;
        };

        let participants = tournament.participants;

        // Close registration
        let updatedTournament = {
            id = tournament.id;
            name = tournament.name;
            startDate = tournament.startDate;
            prizePool = tournament.prizePool;
            expirationDate = tournament.expirationDate;
            participants = tournament.participants;
            isActive = false;
            bracketCreated = true;
        };

        tournaments := Array.tabulate(tournaments.size(), func(i: Nat): Tournament {
            if (i == tournamentId) {
                updatedTournament
            } else {
                tournaments[i]
            }
        });

        // Obtain a fresh blob of entropy
        let entropy = await Random.blob();
        let random = Random.Finite(entropy);

        // Shuffle participants randomly using Fisher-Yates shuffle algorithm
        let shuffledParticipants = Array.thaw<Principal>(participants);
        let n = shuffledParticipants.size();
        var i = n;
        while (i > 1) {
            i -= 1;
            let j = switch (random.range(32)) {
                case (?value) { value % (i + 1) };
                case null { i }
            };
            let temp = shuffledParticipants[i];
            shuffledParticipants[i] := shuffledParticipants[j];
            shuffledParticipants[j] := temp;
        };

        // Recursive function to create matches for all rounds
        func createMatches(participants: [Principal], matchId: Nat, round: Nat) : (Buffer.Buffer<Match>, Nat) {
            var newMatches = Buffer.Buffer<Match>(0);
            var currentMatchId = matchId;
            let numMatches = participants.size() / 2;

            // Create matches for the current round
            var i = 0;
            while (i < numMatches) {
                newMatches.add({
                    id = currentMatchId;
                    tournamentId = tournamentId;
                    participants = [participants[2 * i], participants[2 * i + 1]];
                    result = null;
                    status = "scheduled";
                });
                currentMatchId += 1;
                i += 1;
            };

            // Handle byes for non-power of two participants
            if (participants.size() % 2 == 1) {
                newMatches.add({
                    id = currentMatchId;
                    tournamentId = tournamentId;
                    participants = [participants[participants.size() - 1], Principal.fromText("2vxsx-fae")]; // Using anonymous principal as a bye
                    result = ?{winner = participants[participants.size() - 1]; score = "bye"};
                    status = "verified";
                });
                currentMatchId += 1;
            };

            // Create matches for the next round if more than one match
            if (numMatches > 1 or (participants.size() % 2 == 1 and participants.size() > 1)) {
                var nextRoundParticipants = Buffer.Buffer<Principal>(0);
                for (match in newMatches.vals()) {
                    if (match.status == "verified") {
                        switch (match.result) {
                            case (?res) {
                                nextRoundParticipants.add(res.winner);
                            };
                            case null {};
                        }
                    }
                };
                let nextRoundResult = createMatches(Buffer.toArray(nextRoundParticipants), currentMatchId, round + 1);
                let nextRoundMatches = nextRoundResult.0;
                let finalMatchId = nextRoundResult.1;
                for (nextMatch in nextRoundMatches.vals()) {
                    newMatches.add(nextMatch);
                };
                currentMatchId := finalMatchId;
            };

            return (newMatches, currentMatchId);
        };

        // Start creating matches from round 0
        let roundMatchesResult = createMatches(Array.freeze(shuffledParticipants), 0, 0);
        let roundMatches = roundMatchesResult.0;

        // Update the stable variable matches and the tournament
        var updatedMatches = Buffer.Buffer<Match>(matches.size() + roundMatches.size());
        for (match in matches.vals()) {
            updatedMatches.add(match);
        };
        for (newMatch in roundMatches.vals()) {
            updatedMatches.add(newMatch);
        };
        matches := Buffer.toArray(updatedMatches);

        return true;
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
            matches = Array.filter<Match>(matches, func (m: Match) : Bool { m.tournamentId == tournamentId })
        };
    };

    public shared func deleteAllTournaments() : async Bool {
        tournaments := [];
        matches := [];
        return true;
    };
}
