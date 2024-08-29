import os
import subprocess
import random
import string
import asyncio

async def execute_dfx_command(command, log_output=True):
    """Executes a shell command asynchronously and logs the output."""
    print(f"Executing command: {command}")
    process = await asyncio.create_subprocess_shell(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = await process.communicate()
    
    if process.returncode != 0:
        error_message = f"Command failed: {command}\n{stderr.decode().strip()}"
        if log_output:
            print(error_message)
        return False, stderr.decode().strip()
    else:
        output = stdout.decode().strip()
        if log_output:
            print(f"Command output: {output}")
        return True, output

async def switch_identity(identity_name):
    """Switches the DFX identity asynchronously."""
    command = f"dfx identity use {identity_name}"
    success, _ = await execute_dfx_command(command)
    if not success:
        raise Exception(f"Failed to switch identity: {identity_name}")
    
    # Get the principal ID of the current identity
    command = "dfx identity get-principal"
    success, principal_id = await execute_dfx_command(command)
    if not success:
        raise Exception(f"Failed to get principal ID for identity: {identity_name}")
    
    return principal_id.strip()

def generate_random_username(length=12):
    """Generates a random username with a specified length."""
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

async def create_batch_of_unassigned_codes():
    """Creates a batch of unassigned referral codes."""
    command = f"dfx canister call cosmicrafts createBatchOfUnassignedCodes"
    success, output = await execute_dfx_command(command)
    if not success:
        raise Exception(f"Failed to create unassigned referral codes: {output}")

    parsed_codes = output.strip().replace('(vec {', '').replace('})', '').replace('"', '').replace(';', '').split()

    return parsed_codes

async def get_referral_code(player_principal):
    """Fetches the referral code of a given player."""
    command = f'dfx canister call cosmicrafts getReferralCode \'(principal "{player_principal}")\''
    success, output = await execute_dfx_command(command)
    if not success:
        raise Exception(f"Failed to get referral code for {player_principal}: {output}")

    referral_code = output.strip().replace('(opt "', '').replace('")', '')
    return referral_code

async def register_user(semaphore, user, username, avatar_id, referral_code, registered_players):
    """Switches identity and registers a user using the registerPlayer canister method."""
    async with semaphore:
        retries = 3
        for attempt in range(retries):
            try:
                if user in registered_players:
                    print(f"User {user} already registered, skipping.")
                    return None

                print(f"Switching to identity {user}")
                player_principal = await switch_identity(user)
                
                print(f"Identity switched to {user} (Principal: {player_principal}), now making canister call")
                command = f'dfx canister call cosmicrafts registerPlayer \'("{username}", {avatar_id}, "{referral_code}")\''
                
                success, output = await execute_dfx_command(command)
                if not success:
                    raise Exception(f"Canister call failed: {output}")
                
                print(f"Finished registration for {user}")
                registered_players.add(user)
                return player_principal  # Return the principal ID for further use
            except Exception as e:
                error_message = f"Error registering {user} on attempt {attempt + 1}: {e}"
                print(error_message)
                if attempt == retries - 1:
                    raise e
                await asyncio.sleep(1)  # Wait before retrying

def build_hardcoded_tree():
    """Builds the hardcoded referral tree structure."""
    tree = {
        0: [1, 2, 3, 4, 5],  # First player invites second level players
        1: [6, 7, 8, 9],  # Second level invites third level players
        2: [10, 11, 12, 13],
        3: [14, 15, 16],
        4: [17, 18],
        5: [19, 20, 21],
        6: [22, 23],  # Third level invites fourth level players
        7: [24],
        8: [25, 26],
        9: [27],
        10: [28, 29],
        11: [30],
        12: [31, 32],
        13: [33, 34],
        14: [35],
        15: [36],
        16: [37, 38],
        17: [39],
        18: [40, 41],
        19: [42],
        20: [43],
        21: [44, 45],
    }
    return tree

async def register_and_cascade(semaphore, user_data, tree, parent_index, referral_code, registered_players):
    """Register a player and make them invite others based on the prebuilt tree structure."""
    player_principal = await register_user(semaphore, user_data[parent_index][0], user_data[parent_index][1], user_data[parent_index][2], referral_code, registered_players)
    if not player_principal:
        return
    
    # Get the new referral code for this player
    new_referral_code = await get_referral_code(player_principal)

    # Register children in sequence
    if parent_index in tree:
        for child_index in tree[parent_index]:
            await register_and_cascade(semaphore, user_data, tree, child_index, new_referral_code, registered_players)

async def main():
    """Main function to run the initial commands and then register users."""
    # Initial commands
    initial_commands = [
        "dfx identity use bizkit",
        "dfx canister uninstall-code cosmicrafts",
        "dfx deploy"
    ]
    
    for command in initial_commands:
        await execute_dfx_command(command)

    # Switch to bizkit identity
    await switch_identity("bizkit")

    num_users = 46  # Number of players matching the hardcoded tree

    users = [f"player{i}" for i in range(1, num_users + 1)]  # Create player identities
    user_data = [(user, generate_random_username(), random.randint(1, 33)) for user in users]  # Pre-generate usernames and avatar IDs

    semaphore = asyncio.Semaphore(1)  # Allow only one identity switch and canister call at a time
    registered_players = set()

    # Step 1: Create a batch of unassigned referral codes
    unassigned_codes = await create_batch_of_unassigned_codes()
    print(f"Created unassigned referral codes: {unassigned_codes}")

    # Step 2: Build the hardcoded referral tree
    tree = build_hardcoded_tree()

    # Step 3: Register the first player with the first unassigned code
    print(f"Starting cascade registration from player 0")
    await register_and_cascade(semaphore, user_data, tree, 0, unassigned_codes[0], registered_players)

    # Switch back to the bizkit identity at the end
    print("Switching back to bizkit identity")
    await switch_identity("bizkit")

    # Step 4: Check referrals for the first player
    principal_id = await switch_identity(user_data[0][0])
    command = f'dfx canister call cosmicrafts getTotalReferralNetwork \'(principal "{principal_id}")\''
    success, output = await execute_dfx_command(command)
    if success:
        print(f"Total referral network for the first player ({principal_id}): {output}")

if __name__ == "__main__":
    asyncio.run(main())
