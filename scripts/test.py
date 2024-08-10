import subprocess
import re

def run_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(result.stdout)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command}")
        print(e.stderr)
        return None

def use_identity(identity_name):
    command = f"dfx identity use {identity_name}"
    print(f"Switching to identity: {identity_name}")
    run_command(command)

def get_principal():
    command = "dfx identity get-principal"
    print("Retrieving principal...")
    return run_command(command)

def mint_deck():
    command = "dfx canister call cosmicrafts mintDeck"
    print("Minting deck...")
    output = run_command(command)
    
    if output and "Deck minted" in output:
        nats = re.findall(r'\d+', output)
        nats = [int(nat) for nat in nats]
        print(f"Extracted nats: {nats}")
        return nats
    return []

def get_units(principal):
    command = f'dfx canister call cosmicrafts getUnits "(principal \\"{principal}\\")"'
    print(f"Retrieving units for principal {principal}...")
    output = run_command(command)
    
    if output:
        token_ids = re.findall(r'tokenId = (\d+) : nat;', output)
        token_ids = [int(token_id) for token_id in token_ids]
        print(f"Extracted Token IDs: {token_ids}")
        return token_ids
    return []

def get_match_searching(deck):
    deck_str = "; ".join([str(token_id) for token_id in deck])
    command = f'dfx canister call cosmicrafts getMatchSearching "(record {{ deck = vec {{ {deck_str} }} }})"'
    print(f"Searching for match with deck: {deck}...")
    run_command(command)

def save_finished_game(match_id, game_data):
    command = (
        f'dfx canister call cosmicrafts saveFinishedGame '
        f'(nat {match_id}, record {{ secRemaining = {game_data["secRemaining"]}; '
        f'energyGenerated = {game_data["energyGenerated"]}; '
        f'damageDealt = {game_data["damageDealt"]}; '
        f'wonGame = {game_data["wonGame"]}; '
        f'botMode = {game_data["botMode"]}; '
        f'deploys = {game_data["deploys"]}; '
        f'damageTaken = {game_data["damageTaken"]}; '
        f'damageCritic = {game_data["damageCritic"]}; '
        f'damageEvaded = {game_data["damageEvaded"]}; '
        f'energyChargeRate = {game_data["energyChargeRate"]}; '
        f'faction = {game_data["faction"]}; '
        f'energyUsed = {game_data["energyUsed"]}; '
        f'gameMode = {game_data["gameMode"]}; '
        f'energyWasted = {game_data["energyWasted"]}; '
        f'xpEarned = {game_data["xpEarned"]}; '
        f'characterID = {game_data["characterID"]}; '
        f'botDifficulty = {game_data["botDifficulty"]}; '
        f'kills = {game_data["kills"]}; }})'
    )
    print("Saving finished game...")
    run_command(command)

def main():
    players = ["player1", "player2"]
    
    game_data = {
        "secRemaining": 12,
        "energyGenerated": 32,
        "damageDealt": 23,
        "wonGame": "true",
        "botMode": 23,
        "deploys": 23,
        "damageTaken": 2,
        "damageCritic": 33,
        "damageEvaded": 53,
        "energyChargeRate": 3,
        "faction": 4,
        "energyUsed": 1,
        "gameMode": 1,
        "energyWasted": 1,
        "xpEarned": 100000,
        "characterID": 1,
        "botDifficulty": 1,
        "kills": 1
    }
    
    match_id = 2
    
    # Process for player1
    use_identity(players[0])
    principal1 = get_principal()
    if principal1:
        deck1 = mint_deck()
        if not deck1:
            deck1 = get_units(principal1)
        if deck1:
            get_match_searching(deck1)
    
    # Process for player2
    use_identity(players[1])
    principal2 = get_principal()
    if principal2:
        deck2 = mint_deck()
        if not deck2:
            deck2 = get_units(principal2)
        if deck2:
            get_match_searching(deck2)
    
    # Save finished game for both players
    for player in players:
        use_identity(player)
        save_finished_game(match_id, game_data)

if __name__ == "__main__":
    main()
