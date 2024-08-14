import subprocess
import time

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

def main():

    run_command("dfx identity use bizkit")
    # Register players
    print("Registering players...")
    run_command("python scripts/registerPlayer.py", "2\n")

    # Mint decks for players
    print("Minting decks for players...")
    run_command("python scripts/mintdeck.py", "2\n")

    # Retrieve Cosmicrafts stats
    print("Getting Cosmicrafts stats...")
    run_command("dfx canister call cosmicrafts getCosmicraftsStats")

if __name__ == "__main__":
    main()
