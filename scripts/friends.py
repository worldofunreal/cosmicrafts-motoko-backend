import subprocess
import logging

# Set up logging
#logging.basicConfig(filename='logs/add_friends.log', level=logging.INFO, format='%(asctime)s - %(message)s')

def execute_dfx_command(command, log_output=True):
    """Executes a shell command and logs the output."""
    result = subprocess.run(command, capture_output=True, text=True, shell=True)
    if result.returncode != 0:
        error_message = f"Command failed: {command}\n{result.stderr.strip()}"
        print(error_message)
        logging.error(error_message)
        raise Exception(error_message)
    else:
        output = result.stdout.strip()
        print(f"Command: {command}")
        logging.info(f"Command: {command}")
        if log_output:
            print(f"Output: {output}\n")
            logging.info(f"Output: {output}")
    return output

def switch_identity(identity_name):
    """Switches the DFX identity."""
    execute_dfx_command(f"dfx identity use {identity_name}", log_output=False)

def get_principal(identity_name):
    """Gets the principal of the current identity."""
    switch_identity(identity_name)
    principal = execute_dfx_command("dfx identity get-principal")
    return principal

def send_friend_request(identity_name, friend_principal):
    """Sends a friend request using the sendFriendRequest canister method."""
    command = f'dfx canister call cosmicrafts sendFriendRequest "(principal \\"{friend_principal}\\")"'
    return execute_dfx_command(command)

def accept_friend_request(identity_name, friend_principal):
    """Accepts a friend request using the acceptFriendRequest canister method."""
    command = f'dfx canister call cosmicrafts acceptFriendRequest "(principal \\"{friend_principal}\\")"'
    return execute_dfx_command(command)

def main():
    """Main function to send and accept friend requests."""
    num_friends = int(input("Enter the number of friends to add: "))

    friends = [f"player{i}" for i in range(1, num_friends + 1)]  # Create player identities

    # Get principals for all friends
    principals = {friend: get_principal(friend) for friend in friends}

    # Send and accept friend requests
    for i, friend in enumerate(friends):
        try:
            print(f"Switching to identity {friend}\n")
            logging.info(f"Switching to identity {friend}")
            switch_identity(friend)
            
            for other_friend, principal in principals.items():
                if friend != other_friend:
                    try:
                        # Send friend request
                        send_friend_request(friend, principal)

                        # Switch to the other friend and accept the request
                        switch_identity(other_friend)
                        accept_friend_request(other_friend, principals[friend])

                    except Exception as e:
                        error_message = f"Error processing friend request between {friend} and {other_friend}: {e}"
                        print(error_message)
                        logging.error(error_message)
                        continue
        except Exception as e:
            error_message = f"Error switching identity or getting principal for {friend}: {e}"
            print(error_message)
            logging.error(error_message)

if __name__ == "__main__":
    main()
