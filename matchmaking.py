import subprocess
import json
import logging

# Set up logging
logging.basicConfig(filename='matchmaking.log', level=logging.INFO, format='%(asctime)s - %(message)s')

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

def main():
    """Main function to simulate the matchmaking process."""
    player1_identity = "player1"
    player2_identity = "player2"
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

if __name__ == "__main__":
    main()
