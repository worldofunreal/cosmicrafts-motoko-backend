import subprocess

def create_identities(num_identities):
    for i in range(num_identities):
        identity_name = f"player{i + 1}"
        print(f"Creating identity: {identity_name}")
        try:
            # Run the `dfx identity new` command
            subprocess.run(["dfx", "identity", "new", identity_name], check=True)
            print(f"Identity {identity_name} created successfully.")
        except subprocess.CalledProcessError as e:
            print(f"Error creating identity {identity_name}: {e}")

def main():
    while True:
        try:
            num_identities = int(input("How many players want to register? "))
            if num_identities <= 0:
                print("Please enter a positive integer.")
            else:
                break
        except ValueError:
            print("Invalid input. Please enter a valid number.")
    
    create_identities(num_identities)

if __name__ == "__main__":
    main()
