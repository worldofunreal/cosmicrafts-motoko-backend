import subprocess

def run_command(command, input_text=None):
    try:
        if input_text:
            result = subprocess.run(command, input=input_text, text=True, shell=True, capture_output=True)
        else:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)

        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
    except Exception as e:
        print(f"Error: {e}")

# Get the principal
def get_principal():
    try:
        result = subprocess.run("dfx identity get-principal", shell=True, capture_output=True, text=True)
        if result.stdout:
            principal = result.stdout.strip()
            print(f"Principal: {principal}")
            return principal
        if result.stderr:
            print(result.stderr)
    except Exception as e:
        print(f"Error: {e}")
        return None

# Define the commands
commands = [
    #"dfx canister uninstall-code cosmicrafts",
    #"dfx deploy",
    "dfx identity use player46",
    "dfx canister call cosmicrafts loadAchievements",
    'dfx canister call cosmicrafts registerPlayer \'("BiZKiT", 1)\'',
    "dfx canister call cosmicrafts getAchievements",
]

# Execute each command for the setup process
for command in commands:
    run_command(command)

# Get the principal
principal = get_principal()

if principal:
    # Define individual achievement IDs
    individual_achievement_ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
    referral_achievement_ids = [26, 27, 28, 29, 30]

    # Update and claim progress for regular individual achievements
    for ind_ach_id in individual_achievement_ids:
        # Update progress to meet the required progress for regular achievements
        run_command(f"dfx canister call cosmicrafts addProgressToIndividualAchievement '(principal \"{principal}\", {ind_ach_id}, 1)'")
        
        # Claim the individual achievement reward
        run_command(f"dfx canister call cosmicrafts claimIndividualAchievementReward '({ind_ach_id})'")

    # Handle referral achievements with specific progress requirements
    referral_progress_requirements = [1, 3, 5, 10, 25]

    for ind_ach_id, required_progress in zip(referral_achievement_ids, referral_progress_requirements):
        # Update progress to meet the required progress for referral achievements
        run_command(f"dfx canister call cosmicrafts addProgressToIndividualAchievement '(principal \"{principal}\", {ind_ach_id}, {required_progress})'")
        
        # Claim the individual achievement reward
        run_command(f"dfx canister call cosmicrafts claimIndividualAchievementReward '({ind_ach_id})'")

    # Claim all achievement lines after all individual achievements are completed
    achievement_line_ids = [1, 2, 3, 4, 5, 6, 7, 8]  # Replace with actual achievement line IDs

    for ach_line_id in achievement_line_ids:
        # Claim the achievement line reward
        run_command(f"dfx canister call cosmicrafts claimAchievementLineReward '({ach_line_id})'")

    # Finally, claim the category reward
    category_id = 1  # Replace with the actual category ID
    run_command(f"dfx canister call cosmicrafts claimCategoryAchievementReward '({category_id})'")

    # Check the final state of all achievements
    run_command("dfx canister call cosmicrafts getAchievements")
else:
    print("Failed to retrieve principal.")
