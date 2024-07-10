import subprocess
import random
import string
import logging

# Set up logging
logging.basicConfig(filename='matchmaking.log', level=logging.INFO, format='%(asctime)s - %(message)s')

def execute_dfx_command(command):
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
    execute_dfx_command(f"dfx identity use {identity_name}")

def get_match_searching(identity_name, player_game_data):
    switch_identity(identity_name)
    command = f'dfx canister call cosmicrafts getMatchSearching \'("{player_game_data}")\''
    return execute_dfx_command(command)

def accept_match(identity_name, match_id):
    switch_identity(identity_name)
    command = f'dfx canister call cosmicrafts acceptMatchWS \'({match_id})\''
    return execute_dfx_command(command)

def end_game(identity_name):
    switch_identity(identity_name)
    command = 'dfx canister call cosmicrafts setGameOver'
    return execute_dfx_command(command)

# Example usage
player1_identity = "player1"
player2_identity = "player2"
player_game_data = "game-data"  # Replace with actual game data if needed

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

# Both players accept the match (assuming the result includes the match ID)
# Extract match ID from player1's search result (if the response format is known)
# Adjust according to the actual response format you receive
match_id = None
if "matchID" in player1_search_result:
    match_id = player1_search_result.split('"matchID": ')[1].split(',')[0]

if match_id:
    # Both players accept the match
    print("Player1 accepts the match")
    logging.info("Player1 accepts the match")
    player1_accept_result = accept_match(player1_identity, match_id)
    print(f"Player1 accept result: {player1_accept_result}")
    logging.info(f"Player1 accept result: {player1_accept_result}")

    print("Player2 accepts the match")
    logging.info("Player2 accepts the match")
    player2_accept_result = accept_match(player2_identity, match_id)
    print(f"Player2 accept result: {player2_accept_result}")
    logging.info(f"Player2 accept result: {player2_accept_result}")

    # Simulate the end of the game for player1
    print("Ending the game for Player1")
    logging.info("Ending the game for Player1")
    player1_end_game_result = end_game(player1_identity)
    print(f"Player1 end game result: {player1_end_game_result}")
    logging.info(f"Player1 end game result: {player1_end_game_result}")
else:
    error_message = "Match ID not found, cannot proceed with matchmaking"
    print(error_message)
    logging.error(error_message)
