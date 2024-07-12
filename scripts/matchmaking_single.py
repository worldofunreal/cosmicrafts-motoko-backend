import subprocess
import json
import logging
import re

# Set up logging
logging.basicConfig(filename='logs/matchmaking.log', level=logging.INFO, format='%(asctime)s - %(message)s')

def execute_dfx_command(command):
    """Executes a shell command and logs the output."""
    print(f"Executing command: {command}")
    logging.info(f"Executing command: {command}")
    result = subprocess.run(command, capture_output=True, text=True, shell=True)
    if result.returncode != 0:
        error_message = f"Command failed: {command}\n{result.stderr}"
        print(error_message)
        logging.error(error_message)
    else:
        success_message = f"Command succeeded: {command}\n{result.stdout}"
        print(success_message)
        logging.info(success_message)
    return result.stdout.strip()

def switch_identity(identity_name):
    """Switches the DFX identity."""
    execute_dfx_command(f"dfx identity use {identity_name}")

def get_principal(identity_name):
    """Gets the principal of the current identity."""
    switch_identity(identity_name)
    principal = execute_dfx_command("dfx identity get-principal")
    return principal

def get_match_searching(identity_name, player_game_data):
    """Starts searching for a match."""
    switch_identity(identity_name)
    player_game_data_str = json.dumps(player_game_data)
    command = f'dfx canister call cosmicrafts getMatchSearching "{player_game_data_str}"'
    return execute_dfx_command(command)

def set_player_active(identity_name):
    """Sets the player as active."""
    switch_identity(identity_name)
    command = 'dfx canister call cosmicrafts setPlayerActive'
    return execute_dfx_command(command)

def is_game_matched(identity_name):
    """Checks if the game is matched."""
    switch_identity(identity_name)
    command = 'dfx canister call cosmicrafts isGameMatched'
    return execute_dfx_command(command)

def cancel_matchmaking(identity_name):
    """Cancels the matchmaking process."""
    switch_identity(identity_name)
    command = 'dfx canister call cosmicrafts cancelMatchmaking'
    return execute_dfx_command(command)

def save_finished_game(identity_name, game_id, stats):
    """Saves the finished game statistics."""
    switch_identity(identity_name)
    
    stats_str = (
        'record {'
        f'energyUsed = {stats["energyUsed"]}; '
        f'energyGenerated = {stats["energyGenerated"]}; '
        f'energyWasted = {stats["energyWasted"]}; '
        f'energyChargeRate = {stats["energyChargeRate"]}; '
        f'xpEarned = {stats["xpEarned"]}; '
        f'damageDealt = {stats["damageDealt"]}; '
        f'damageTaken = {stats["damageTaken"]}; '
        f'damageCritic = {stats["damageCritic"]}; '
        f'damageEvaded = {stats["damageEvaded"]}; '
        f'kills = {stats["kills"]}; '
        f'deploys = {stats["deploys"]}; '
        f'secRemaining = {stats["secRemaining"]}; '
        f'wonGame = {str(stats["wonGame"]).lower()}; '
        f'faction = {stats["faction"]}; '
        f'characterID = "{stats["characterID"]}"; '
        f'gameMode = {stats["gameMode"]}; '
        f'botMode = {stats["botMode"]}; '
        f'botDifficulty = {stats["botDifficulty"]};'
        '}'
    )

    command = (
        f'dfx canister call cosmicrafts saveFinishedGame \'({game_id}, {stats_str})\''
    )
    print(f"Constructed command: {command}")
    logging.info(f"Constructed command: {command}")
    return execute_dfx_command(command)

def parse_match_id(search_result):
    """Extracts the match ID from the search result."""
    match = re.search(r'\(variant \{ Assigned \}, (\d+) : nat,', search_result)
    if match:
        return int(match.group(1))
    else:
        raise ValueError("Match ID not found in the search result")

def main():
    """Main function to simulate the matchmaking process."""
    player1_identity = "player1"
    player2_identity = "player2"

    # Get principals for both players
    player1_principal = get_principal(player1_identity)
    player2_principal = get_principal(player2_identity)

    player_game_data = {
        "userAvatar": 1,  # Replace with actual avatar ID
        "listSavedKeys": []  # Replace with actual saved keys if needed
    }

    # Player1 starts searching for a match
    print("Player1 starts searching for a match")
    logging.info("Player1 starts searching for a match")
    player1_search_result = get_match_searching(player1_identity, player_game_data)
    print(f"Player1 search result: {player1_search_result}")
    logging.info(f"Player1 search result: {player1_search_result}")

    # Extract the match ID from Player1's search result
    match_id = parse_match_id(player1_search_result)

    # Player2 joins the match
    print("Player2 joins the match")
    logging.info("Player2 joins the match")
    player2_search_result = get_match_searching(player2_identity, player_game_data)
    print(f"Player2 search result: {player2_search_result}")
    logging.info(f"Player2 search result: {player2_search_result}")

    # Simulate the active status of Player1 and Player2
    send_player_active = True
    while send_player_active:
        player1_active_result = set_player_active(player1_identity)
        print(f"Player1 active result: {player1_active_result}")
        logging.info(f"Player1 active result: {player1_active_result}")

        player2_active_result = set_player_active(player2_identity)
        print(f"Player2 active result: {player2_active_result}")
        logging.info(f"Player2 active result: {player2_active_result}")

        is_matched_result_player1 = is_game_matched(player1_identity)
        print(f"Is game matched result for Player1: {is_matched_result_player1}")
        logging.info(f"Is game matched result for Player1: {is_matched_result_player1}")

        is_matched_result_player2 = is_game_matched(player2_identity)
        print(f"Is game matched result for Player2: {is_matched_result_player2}")
        logging.info(f"Is game matched result for Player2: {is_matched_result_player2}")

        if "true" in is_matched_result_player1 or "true" in is_matched_result_player2:
            send_player_active = False
            print("Match found! Ending search.")
            logging.info("Match found! Ending search.")
            break

    # Send game statistics for both players
    game_stats = {
        "energyUsed": 100.0,  # Example values
        "energyGenerated": 120.0,
        "energyWasted": 20.0,
        "energyChargeRate": 1.5,
        "xpEarned": 50.0,
        "damageDealt": 200.0,
        "damageTaken": 150.0,
        "damageCritic": 30.0,
        "damageEvaded": 10.0,
        "kills": 5.0,
        "deploys": 3.0,
        "secRemaining": 60.0,
        "wonGame": True,
        "faction": 1,
        "characterID": "character1",
        "gameMode": 1,
        "botMode": 0,
        "botDifficulty": 1
    }
    print(f"Sending statistics for match ID: {match_id}")
    logging.info(f"Sending statistics for match ID: {match_id}")
    save_finished_game(player1_identity, match_id, game_stats)
    save_finished_game(player2_identity, match_id, game_stats)

if __name__ == "__main__":
    main()
