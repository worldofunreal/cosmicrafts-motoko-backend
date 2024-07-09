import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Random "mo:base/Random";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Text "mo:base/Text";

actor Backend {
  stable var tournaments : [Tournament] = [];
  stable var matches : [Match] = [];
  stable var feedback : [{
    principal : Principal;
    tournamentId : Nat;
    feedback : Text;
  }] = [];
  stable var disputes : [{
    principal : Principal;
    matchId : Nat;
    reason : Text;
    status : Text;
  }] = [];

  type Tournament = {
    id : Nat;
    name : Text;
    startDate : Time.Time;
    prizePool : Text;
    expirationDate : Time.Time;
    participants : [Principal];
    registeredParticipants : [Principal];
    isActive : Bool;
    bracketCreated : Bool;
    matchCounter : Nat; // Add matchCounter to each tournament
  };

  type Match = {
    id : Nat;
    tournamentId : Nat;
    participants : [Principal];
    result : ?{ winner : Principal; score : Text };
    status : Text;
    nextMatchId : ?Nat; // Track the next match
  };

  public shared ({ caller }) func createTournament(name : Text, startDate : Time.Time, prizePool : Text, expirationDate : Time.Time) : async Nat {
    if (
      caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae") and
      caller != Principal.fromText("bdycp-b54e6-fvsng-ouies-a6zfm-khbnh-wcq3j-pv7qt-gywe2-em245-3ae")
    ) {
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
      registeredParticipants = [];
      isActive = true;
      bracketCreated = false;
      matchCounter = 0 // Initialize matchCounter
    });
    tournaments := Buffer.toArray(buffer);
    return id;
  };

  public shared ({ caller }) func joinTournament(tournamentId : Nat) : async Bool {
    if (tournamentId >= tournaments.size()) {
      return false;
    };

    let tournament = tournaments[tournamentId];

    if (Array.indexOf<Principal>(caller, tournament.participants, func(a : Principal, b : Principal) : Bool { a == b }) != null) {
      return false;
    };

    var updatedParticipants = Buffer.Buffer<Principal>(tournament.participants.size() + 1);
    for (participant in tournament.participants.vals()) {
      updatedParticipants.add(participant);
    };
    updatedParticipants.add(caller);

    var updatedRegisteredParticipants = Buffer.Buffer<Principal>(tournament.registeredParticipants.size() + 1);
    for (participant in tournament.registeredParticipants.vals()) {
      updatedRegisteredParticipants.add(participant);
    };
    updatedRegisteredParticipants.add(caller);

    let updatedTournament = {
      id = tournament.id;
      name = tournament.name;
      startDate = tournament.startDate;
      prizePool = tournament.prizePool;
      expirationDate = tournament.expirationDate;
      participants = Buffer.toArray(updatedParticipants);
      registeredParticipants = Buffer.toArray(updatedRegisteredParticipants);
      isActive = tournament.isActive;
      bracketCreated = tournament.bracketCreated;
      matchCounter = tournament.matchCounter;
    };

    tournaments := Array.tabulate(
      tournaments.size(),
      func(i : Nat) : Tournament {
        if (i == tournamentId) {
          updatedTournament;
        } else {
          tournaments[i];
        };
      },
    );

    return true;
  };

  public query func getRegisteredUsers(tournamentId : Nat) : async [Principal] {
    if (tournamentId >= tournaments.size()) {
      return [];
    };

    let tournament : Tournament = tournaments[tournamentId];
    return tournament.registeredParticipants;
  };

  public shared ({ caller }) func submitFeedback(_tournamentId : Nat, feedbackText : Text) : async Bool {
    let newFeedback = Buffer.Buffer<{ principal : Principal; tournamentId : Nat; feedback : Text }>(feedback.size() + 1);
    for (entry in feedback.vals()) {
      newFeedback.add(entry);
    };
    newFeedback.add({
      principal = caller;
      tournamentId = _tournamentId;
      feedback = feedbackText;
    });
    feedback := Buffer.toArray(newFeedback);
    return true;
  };

  public shared ({ caller }) func submitMatchResult(tournamentId : Nat, matchId : Nat, score : Text) : async Bool {
    let matchOpt = Array.find<Match>(matches, func(m : Match) : Bool { m.id == matchId and m.tournamentId == tournamentId });
    switch (matchOpt) {
      case (?match) {
        let isParticipant = Array.find<Principal>(match.participants, func(p : Principal) : Bool { p == caller }) != null;
        if (not isParticipant) {
          return false;
        };

        var updatedMatches = Buffer.Buffer<Match>(matches.size());
        for (m in matches.vals()) {
          if (m.id == matchId and m.tournamentId == tournamentId) {
            updatedMatches.add({
              id = m.id;
              tournamentId = m.tournamentId;
              participants = m.participants;
              result = ?{ winner = caller; score = score };
              status = "pending verification";
              nextMatchId = m.nextMatchId;
            });
          } else {
            updatedMatches.add(m);
          };
        };
        matches := Buffer.toArray(updatedMatches);
        return true;
      };
      case null {
        return false;
      };
    };
  };

  public shared ({ caller }) func disputeMatch(tournamentId : Nat, matchId : Nat, reason : Text) : async Bool {
    let matchExists = Array.find(matches, func(m : Match) : Bool { m.id == matchId and m.tournamentId == tournamentId }) != null;
    if (not matchExists) {
      return false;
    };

    let newDispute = {
      principal = caller;
      matchId = matchId;
      reason = reason;
      status = "pending";
    };
    let updatedDisputes = Buffer.Buffer<{ principal : Principal; matchId : Nat; reason : Text; status : Text }>(disputes.size() + 1);
    for (dispute in disputes.vals()) {
      updatedDisputes.add(dispute);
    };
    updatedDisputes.add(newDispute);
    disputes := Buffer.toArray(updatedDisputes);

    return true;
  };

  public shared ({ caller }) func adminUpdateMatch(tournamentId : Nat, matchId : Nat, winnerIndex : Nat, score : Text) : async Bool {
    if (
      caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae") and
      caller != Principal.fromText("bdycp-b54e6-fvsng-ouies-a6zfm-khbnh-wcq3j-pv7qt-gywe2-em245-3ae")
    ) {
      return false;
    };

    let matchOpt = Array.find<Match>(matches, func(m : Match) : Bool { m.id == matchId and m.tournamentId == tournamentId });
    switch (matchOpt) {
      case (?match) {
        if (winnerIndex >= Array.size<Principal>(match.participants)) {
          return false; // Invalid winner index
        };

        let winnerPrincipal = match.participants[winnerIndex];

        var updatedMatches = Buffer.Buffer<Match>(matches.size());
        for (m in matches.vals()) {
          if (m.id == matchId and m.tournamentId == tournamentId) {
            updatedMatches.add({
              id = m.id;
              tournamentId = m.tournamentId;
              participants = m.participants;
              result = ?{ winner = winnerPrincipal; score = score };
              status = "verified";
              nextMatchId = m.nextMatchId;
            });
          } else {
            updatedMatches.add(m);
          };
        };
        matches := Buffer.toArray(updatedMatches);

        // Update the bracket directly by advancing the winner
        Debug.print("Admin verified match: " # Nat.toText(matchId) # " with winner: " # Principal.toText(winnerPrincipal));
        ignore updateBracketAfterMatchUpdate(match.tournamentId, match.id, winnerPrincipal);

        return true;
      };
      case null {
        return false;
      };
    };
  };

  // Calculate the base-2 logarithm of a number
  func log2(x : Nat) : Nat {
    var result = 0;
    var value = x;
    while (value > 1) {
      value /= 2;
      result += 1;
    };
    return result;
  };

  // Helper function to update the bracket after a match result is verified
  public shared func updateBracketAfterMatchUpdate(tournamentId : Nat, matchId : Nat, winner : Principal) : async () {
    Debug.print("Starting updateBracketAfterMatchUpdate");
    Debug.print("Updated Match ID: " # Nat.toText(matchId));
    Debug.print("Winner: " # Principal.toText(winner));

    // Log the current state of the matches
    for (i in Iter.range(0, matches.size() - 1)) {
      let match = matches[i];
      Debug.print("Current Match: " # matchToString(match));
    };

    let updatedMatchOpt = Array.find<Match>(matches, func(m : Match) : Bool { m.id == matchId and m.tournamentId == tournamentId });
    switch (updatedMatchOpt) {
      case (?updatedMatch) {
        switch (updatedMatch.nextMatchId) {
          case (?nextMatchId) {
            Debug.print("Next match ID is not null: " # Nat.toText(nextMatchId));

            let nextMatchOpt = Array.find<Match>(matches, func(m : Match) : Bool { m.id == nextMatchId and m.tournamentId == tournamentId });
            switch (nextMatchOpt) {
              case (?nextMatch) {
                Debug.print("Next match found with ID: " # Nat.toText(nextMatchId));

                var updatedParticipants = Buffer.Buffer<Principal>(2);
                var replaced = false;

                for (p in nextMatch.participants.vals()) {
                  if (p == Principal.fromText("2vxsx-fae") and not replaced) {
                    updatedParticipants.add(winner);
                    replaced := true;
                  } else {
                    updatedParticipants.add(p);
                  };
                };

                Debug.print("Before update: " # participantsToString(nextMatch.participants));
                Debug.print("After update: " # participantsToString(Buffer.toArray(updatedParticipants)));

                let updatedNextMatch = {
                  id = nextMatch.id;
                  tournamentId = nextMatch.tournamentId;
                  participants = Buffer.toArray(updatedParticipants);
                  result = nextMatch.result;
                  status = nextMatch.status;
                  nextMatchId = nextMatch.nextMatchId;
                };

                // Update the next match in the matches array using Array.map
                matches := Array.map<Match, Match>(
                  matches,
                  func(m : Match) : Match {
                    if (m.id == nextMatchId and m.tournamentId == tournamentId) {
                      updatedNextMatch;
                    } else {
                      m;
                    };
                  },
                );
                Debug.print("Updated match in the matches map with ID: " # Nat.toText(nextMatchId));
              };
              case null {
                Debug.print("Error: Next match not found with ID: " # Nat.toText(nextMatchId));
              };
            };
          };
          case null {
            Debug.print("Next match ID is null for match ID: " # Nat.toText(matchId));
          };
        };
      };
      case null {
        Debug.print("Match not found for ID: " # Nat.toText(matchId));
      };
    };

    // Log the updated state of the matches
    for (i in Iter.range(0, matches.size() - 1)) {
      let match = matches[i];
      Debug.print("Updated Match: " # matchToString(match));
    };
  };

  private func matchToString(match : Match) : Text {
    return "Match ID: " # Nat.toText(match.id) # ", Participants: " # participantsToString(match.participants) # ", Result: " # (switch (match.result) { case (?res) { "Winner: " # Principal.toText(res.winner) # ", Score: " # res.score }; case null { "pending" } }) # ", Next Match ID: " # (switch (match.nextMatchId) { case (?nextId) { Nat.toText(nextId) }; case null { "none" } });
  };

  private func participantsToString(participants : [Principal]) : Text {
    var text = "";
    var first = true;
    for (participant in participants.vals()) {
      if (not first) {
        text #= ", ";
      };
      first := false;
      text #= Principal.toText(participant);
    };
    return text;
  };

  public shared func updateBracket(tournamentId : Nat) : async Bool {
    if (tournamentId >= tournaments.size()) {
      // Debug.print("Tournament does not exist.");
      return false;
    };

    var tournament = tournaments[tournamentId];
    let participants = tournament.participants;

    // Close registration if not already closed
    if (not tournament.bracketCreated) {
      let updatedTournament = {
        id = tournament.id;
        name = tournament.name;
        startDate = tournament.startDate;
        prizePool = tournament.prizePool;
        expirationDate = tournament.expirationDate;
        participants = tournament.participants;
        registeredParticipants = tournament.registeredParticipants;
        isActive = false;
        bracketCreated = true;
        matchCounter = tournament.matchCounter;
      };

      tournaments := Array.tabulate(
        tournaments.size(),
        func(i : Nat) : Tournament {
          if (i == tournamentId) {
            updatedTournament;
          } else {
            tournaments[i];
          };
        },
      );
    };

    // Obtain a fresh blob of entropy
    let entropy = await Random.blob();
    let random = Random.Finite(entropy);

    // Calculate total participants including byes
    var totalParticipants = 1;
    while (totalParticipants < participants.size()) {
      totalParticipants *= 2;
    };

    let byesCount = Nat.sub(totalParticipants, participants.size());
    var allParticipants = Buffer.Buffer<Principal>(totalParticipants);
    for (p in participants.vals()) {
      allParticipants.add(p);
    };
    for (i in Iter.range(0, byesCount - 1)) {
      allParticipants.add(Principal.fromText("2vxsx-fae"));
    };

    // Shuffle all participants and byes together
    var shuffledParticipants = Array.thaw<Principal>(Buffer.toArray(allParticipants));
    var i = shuffledParticipants.size();
    while (i > 1) {
      i -= 1;
      let j = switch (random.range(32)) {
        case (?value) { value % (i + 1) };
        case null { i };
      };
      let temp = shuffledParticipants[i];
      shuffledParticipants[i] := shuffledParticipants[j];
      shuffledParticipants[j] := temp;
    };

    Debug.print("Total participants after adjustment: " # Nat.toText(totalParticipants));

    // Store the total participants count for round 1
    let totalParticipantsRound1 = totalParticipants;

    // Create initial round matches with nextMatchId
    let roundMatches = Buffer.Buffer<Match>(0);
    var matchId = tournament.matchCounter;
    var nextMatchIdBase = totalParticipants / 2;
    for (i in Iter.range(0, totalParticipants / 2 - 1)) {
      let p1 = shuffledParticipants[i * 2];
      let p2 = shuffledParticipants[i * 2 + 1];
      let currentNextMatchId = ?(nextMatchIdBase + (i / 2));
      roundMatches.add({
        id = matchId;
        tournamentId = tournamentId;
        participants = [p1, p2];
        result = null;
        status = "scheduled";
        nextMatchId = currentNextMatchId;
      });
      Debug.print("Created match: " # Nat.toText(matchId) # " with participants: " # Principal.toText(p1) # " vs " # Principal.toText(p2) # " nextMatchId: " # (switch (currentNextMatchId) { case (?id) { Nat.toText(id) }; case null { "none" } }));
      matchId += 1;
    };
    nextMatchIdBase /= 2;

    // Update matchCounter in the tournament
    let updatedTournament = {
      id = tournament.id;
      name = tournament.name;
      startDate = tournament.startDate;
      prizePool = tournament.prizePool;
      expirationDate = tournament.expirationDate;
      participants = tournament.participants;
      registeredParticipants = tournament.registeredParticipants;
      isActive = tournament.isActive;
      bracketCreated = tournament.bracketCreated;
      matchCounter = matchId // Update matchCounter
    };

    tournaments := Array.tabulate(
      tournaments.size(),
      func(i : Nat) : Tournament {
        if (i == tournamentId) {
          updatedTournament;
        } else {
          tournaments[i];
        };
      },
    );

    // Function to recursively create matches for all rounds
    func createAllRounds(totalRounds : Nat, currentRound : Nat, matchId : Nat) : Buffer.Buffer<Match> {
      let newMatches = Buffer.Buffer<Match>(0);
      if (currentRound >= totalRounds) {
        return newMatches;
      };

      let numMatches = (totalParticipantsRound1 / (2 ** (currentRound + 1)));
      for (i in Iter.range(0, numMatches - 1)) {
        // Calculate next match ID correctly
        let nextMatchIdOpt = if (currentRound + 1 == totalRounds) {
          null;
        } else {
          ?(matchId + (i / 2) + numMatches);
        };

        newMatches.add({
          id = matchId + i;
          tournamentId = tournamentId;
          participants = [Principal.fromText("2vxsx-fae"), Principal.fromText("2vxsx-fae")];
          result = null;
          status = "scheduled";
          nextMatchId = nextMatchIdOpt;
        });
        Debug.print("Created next round match: " # Nat.toText(matchId + i) # " with nextMatchId: " # (switch (nextMatchIdOpt) { case (?id) { Nat.toText(id) }; case null { "none" } }));
      };

      // Recursively create next round matches
      let nextRoundMatches = createAllRounds(totalRounds, currentRound + 1, matchId + numMatches);
      for (match in nextRoundMatches.vals()) {
        newMatches.add(match);
      };

      return newMatches;
    };

    let totalRounds = log2(totalParticipantsRound1);
    Debug.print("Total rounds: " # Nat.toText(totalRounds));
    let subsequentRounds = createAllRounds(totalRounds, 1, matchId);

    // Update the stable variable matches
    var updatedMatches = Buffer.Buffer<Match>(matches.size() + roundMatches.size() + subsequentRounds.size());
    for (match in matches.vals()) {
      updatedMatches.add(match);
    };
    for (newMatch in roundMatches.vals()) {
      updatedMatches.add(newMatch);
    };
    for (subsequentMatch in subsequentRounds.vals()) {
      updatedMatches.add(subsequentMatch);
    };
    matches := Buffer.toArray(updatedMatches);

    // Manually create text representation for matches
    var matchesText = "";
    var firstMatch = true;
    for (match in matches.vals()) {
      if (not firstMatch) {
        matchesText #= ", ";
      };
      firstMatch := false;
      let nextMatchIdText = switch (match.nextMatchId) {
        case (?id) { Nat.toText(id) };
        case null { "none" };
      };
      matchesText #= "Match ID: " # Nat.toText(match.id) # " nextMatchId: " # nextMatchIdText;
    };

    Debug.print("Bracket created with matches: " # matchesText);

    return true;
  };

  public query func getActiveTournaments() : async [Tournament] {
    return Array.filter<Tournament>(tournaments, func(t : Tournament) : Bool { t.isActive });
  };

  public query func getInactiveTournaments() : async [Tournament] {
    return Array.filter<Tournament>(tournaments, func(t : Tournament) : Bool { not t.isActive });
  };

  public query func getAllTournaments() : async [Tournament] {
    return tournaments;
  };

  public query func getTournamentBracket(tournamentId : Nat) : async {
    matches : [Match];
  } {
    return {
      matches = Array.filter<Match>(matches, func(m : Match) : Bool { m.tournamentId == tournamentId });
    };
  };

  public shared func deleteAllTournaments() : async Bool {
    tournaments := [];
    matches := [];
    return true;
  };
};
