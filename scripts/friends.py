import subprocess
import time

def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def switch_identity(identity):
    run_command(f"dfx identity use {identity}")

def get_principal():
    return run_command("dfx identity get-principal")

def send_friend_request(from_identity, to_principal):
    switch_identity(from_identity)
    output = run_command(f'dfx canister call cosmicrafts sendFriendRequest "(principal \\"{to_principal}\\")"')
    return output

def accept_friend_request(from_identity, from_principal):
    switch_identity(from_identity)
    output = run_command(f'dfx canister call cosmicrafts acceptFriendRequest "(principal \\"{from_principal}\\")"')
    return output

# Define the number of players
num_players = 10
identities = [f'player{i}' for i in range(1, num_players + 1)]
principals = {}

# Get principals for all players
for identity in identities:
    switch_identity(identity)
    principals[identity] = get_principal()

# Process friend requests
for i in range(num_players):
    sender_identity = identities[i]
    for j in range(i + 1, num_players):
        receiver_identity = identities[j]

        # Check if the receiver has already sent a friend request
        switch_identity(receiver_identity)
        output = run_command(f'dfx canister call cosmicrafts acceptFriendRequest "(principal \\"{principals[sender_identity]}\\")"')

        if "Friend request not found" in output:
            # Send friend request if not already sent
            output = send_friend_request(sender_identity, principals[receiver_identity])
            if "Friend request sent successfully" in output:
                # Accept the friend request after it's sent
                output = accept_friend_request(receiver_identity, principals[sender_identity])

        print(f'{sender_identity} -> {receiver_identity}: {output}')

print("All friend requests processed successfully!")
