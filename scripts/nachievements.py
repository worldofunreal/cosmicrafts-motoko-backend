import subprocess

def run_command(command, input_text=None):
    try:
        if input_text:
            # Pass the input to the process using the `input` parameter of `communicate`
            result = subprocess.run(command, input=input_text, text=True, shell=True, capture_output=True)
        else:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)

        # Output the result
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
    except Exception as e:
        print(f"Error: {e}")

# Define the username and avatar_id
username = "BiZKiT"
avatar_id = 1
new_avatar_id = 2

# List of commands to execute with arguments
commands = [
    "dfx canister uninstall-code cosmicrafts",
    "dfx deploy",
    "dfx canister call cosmicrafts initializeMilestones",
    f'dfx canister call cosmicrafts registerPlayer \'("{username}", {avatar_id})\'',
    "dfx canister call cosmicrafts getAchievements",
    f'dfx canister call cosmicrafts updateAvatar \'({new_avatar_id})\'',
    "dfx canister call cosmicrafts getAchievements",
    f'dfx canister call cosmicrafts claimIndividualAchievementReward \'(3)\''
]

# Execute each command
for command in commands:
    run_command(command)
