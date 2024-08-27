import os
import subprocess
import random
import string
import asyncio
import time

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

    # Manually parse the output (expected format: (vec { "SATOSHI8584"; "PUMP9400" }))
    parsed_codes = output.strip().replace('(vec {', '').replace('})', '').replace('"', '').replace(';', '').split()

    return parsed_codes

async def get_referral_code(player_principal):
    """Fetches the referral code of a given player."""
    command = f'dfx canister call cosmicrafts getReferralCode \'(principal "{player_principal}")\''
    success, output = await execute_dfx_command(command)
    if not success:
        raise Exception(f"Failed to get referral code for {player_principal}: {output}")

    # Extract the referral code from the output, removing the `opt` wrapper
    referral_code = output.strip().replace('(opt "', '').replace('")', '')
    return referral_code

async def register_user(semaphore, user, username, avatar_id, referral_code):
    """Switches identity and registers a user using the registerPlayer canister method."""
    async with semaphore:
        retries = 3
        for attempt in range(retries):
            try:
                print(f"Switching to identity {user}")
                player_principal = await switch_identity(user)
                
                print(f"Identity switched to {user} (Principal: {player_principal}), now making canister call")
                command = f'dfx canister call cosmicrafts registerPlayer \'("{username}", {avatar_id}, "{referral_code}")\''
                
                success, output = await execute_dfx_command(command)
                if not success:
                    raise Exception(f"Canister call failed: {output}")
                
                print(f"Finished registration for {user}")
                return player_principal  # Return the principal ID for further use
            except Exception as e:
                error_message = f"Error registering {user} on attempt {attempt + 1}: {e}"
                print(error_message)
                if attempt == retries - 1:
                    raise e
                await asyncio.sleep(1)  # Wait before retrying

async def register_players_batch(semaphore, user_data, start_index, referral_code, batch_size):
    """Register a batch of players with the same referral code."""
    new_referral_codes = []

    for i in range(batch_size):
        if start_index >= len(user_data):
            break
        # Register the player with the given referral code
        player_principal = await register_user(semaphore, user_data[start_index][0], user_data[start_index][1], user_data[start_index][2], referral_code)
        # Get the new referral code for this player
        new_referral_code = await get_referral_code(player_principal)
        new_referral_codes.append(new_referral_code)
        start_index += 1

    return new_referral_codes, start_index

async def register_players_cascade(semaphore, user_data, start_index, referral_code, batch_size):
    """Recursively register players with cascading referrals."""
    if start_index >= len(user_data):
        return

    # Register a batch of players using the same referral code
    new_referral_codes, new_start_index = await register_players_batch(semaphore, user_data, start_index, referral_code, batch_size)

    # Recursively register next batches using new referral codes
    for new_referral_code in new_referral_codes:
        await register_players_cascade(semaphore, user_data, new_start_index, new_referral_code, batch_size)
        new_start_index += batch_size

async def main():
    """Main function to run the initial commands and then register users."""

    # Prompt for the number of users to register
    num_users = int(input("Enter the number of users to register: "))

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

    users = [f"player{i}" for i in range(1, num_users + 1)]  # Create player identities
    user_data = [(user, generate_random_username(), random.randint(1, 33)) for user in users]  # Pre-generate usernames and avatar IDs

    semaphore = asyncio.Semaphore(1)  # Allow only one identity switch and canister call at a time

    # Step 1: Create a batch of unassigned referral codes
    unassigned_codes = await create_batch_of_unassigned_codes()
    print(f"Created unassigned referral codes: {unassigned_codes}")

    # Step 2: Register the first player with the first unassigned code
    first_player_data = user_data[0]
    first_player_principal = await register_user(semaphore, first_player_data[0], first_player_data[1], first_player_data[2], unassigned_codes[0])

    # Step 3: Get the referral code for the first player
    first_player_referral_code = await get_referral_code(first_player_principal)

    # Step 4: Register subsequent players in batches with a max of 11 players per batch
    batch_size = 11
    await register_players_cascade(semaphore, user_data, 1, first_player_referral_code, batch_size)

    # Switch back to the bizkit identity at the end
    print("Switching back to bizkit identity")
    await switch_identity("bizkit")

    # Step 5: Check referrals for the first player
    principal_id = await switch_identity(user_data[0][0])
    command = f'dfx canister call cosmicrafts getTotalReferralNetwork \'(principal "{principal_id}")\''
    success, output = await execute_dfx_command(command)
    if success:
        print(f"Total referral network for the first player ({principal_id}): {output}")

if __name__ == "__main__":
    asyncio.run(main())
