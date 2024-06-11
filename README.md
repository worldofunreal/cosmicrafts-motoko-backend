# Cosmicrafts Backend

This project contains the backend canisters of Cosmicrafts on Motoko for the Internet Computer.

Try with the following commands:
```dfxvm default 0.17.0```
```dfx start --clean --background```
```dfx canister create --all```
```dfx deploy```
# Overview of `upgradeNFT` Function

## Verify Ownership

- **Function**: `icrc7_owner_of` from `nftsToken`
- **Variable**: `ownerof` of type `OwnerResult`
- **Purpose**: Checks if the caller owns the specified NFT.
- **Outcome**: If the caller does not own the NFT, the function returns an error message.

## Retrieve NFT Metadata

- **Function**: `icrc7_metadata` from `nftsToken`
- **Variable**: `metadataResult` of type `TypesICRC7.MetadataResult`
- **Purpose**: Gets the current metadata of the specified NFT.
- **Outcome**: If the metadata is not found, the function returns an error message.

## Prepare Metadata for Upgrade

- **Buffer**: `_newArgsBuffer` initialized with the size of the existing metadata.
- **Function**: `getNFTLevel`
  - **Purpose**: Determines the current level of the NFT.
  - **Called With**: `_nftMetadata` (metadata retrieved earlier)
  - **Returns**: The level of the NFT.
- **Function**: `calculateCost`
  - **Purpose**: Calculates the cost for upgrading the NFT based on its current level.
  - **Called With**: `_nftLevel` (level determined earlier)
  - **Returns**: The upgrade cost.

## Update Metadata

- **Loop**: Iterates through the existing metadata and updates it as follows:
  - **Function**: `updateBasicStats`
    - **Purpose**: Updates basic stats like level, health, and damage.
    - **Called With**: `_mdValue` (current metadata value)
    - **Returns**: Updated metadata.
  - **Function**: `upgradeAdvancedAttributes`
    - **Purpose**: Upgrades advanced attributes like shield capacity, impairment resistance, etc.
    - **Called With**: `_nftLevel` (current level) and `_mdValue` (current metadata value)
    - **Returns**: Updated advanced attributes.

## Create Transaction Arguments

- **Structure**: `_transactionsArgs`
- **Variables Used**: `upgradeCost`, `icrc1_fee`
- **Purpose**: Prepares the arguments for the transaction required to pay for the upgrade.

## Execute Transaction

- **Function**: `icrc1_pay_for_transaction` from `shardsToken`
- **Variable**: `transfer` of type `TransferResult`
- **Purpose**: Performs the transaction to pay for the NFT upgrade.
- **Outcome**: If the transaction fails, the function returns an error message.

## Upgrade NFT

- **Structure**: `_upgradeArgs`
- **Buffer Method**: `toArray` to convert `_newArgsBuffer` to an array.
- **Function**: `upgradeNFT` from `nftsToken`
- **Variable**: `upgrade` of type `TypesICRC7.UpgradeReceipt`
- **Purpose**: Upgrades the NFT with the new metadata.
- **Outcome**: If the upgrade fails, the function returns an error message.

## Return Result

- **Success**: Returns a success message with the transaction ID.
- **Failure**: Returns an appropriate error message.

# Involved Functions and Variables

## Functions

### `icrc7_owner_of`

- **Variable**: `ownerof` of type `OwnerResult`
- **Returns**: Owner information for the specified NFT.

### `icrc7_metadata`

- **Variable**: `metadataResult` of type `TypesICRC7.MetadataResult`
- **Returns**: Metadata for the specified NFT.

### `getNFTLevel`

- **Input**: `_nftMetadata` (metadata retrieved)
- **Returns**: The current level of the NFT.

### `calculateCost`

- **Input**: `_nftLevel` (determined level)
- **Returns**: The cost for upgrading the NFT.

### `updateBasicStats`

- **Input**: `_mdValue` (current metadata value)
- **Returns**: Updated basic stats.

### `upgradeAdvancedAttributes`

- **Input**: `_nftLevel` (current level), `_mdValue` (current metadata value)
- **Returns**: Updated advanced attributes.

### `icrc1_pay_for_transaction`

- **Variable**: `transfer` of type `TransferResult`
- **Returns**: Result of the payment transaction.

### `upgradeNFT`

- **Variable**: `upgrade` of type `TypesICRC7.UpgradeReceipt`
- **Returns**: Result of the NFT upgrade.

## Variables

- **`ownerof`**: Ownership result of the specified NFT.
- **`metadataResult`**: Metadata result of the specified NFT.
- **`_newArgsBuffer`**: Buffer to hold the new metadata arguments.
- **`_nftLevel`**: Current level of the NFT.
- **`upgradeCost`**: Cost for upgrading the NFT.
- **`_transactionsArgs`**: Arguments for the payment transaction.
- **`transfer`**: Result of the payment transaction.
- **`_upgradeArgs`**: Arguments for upgrading the NFT.
- **`upgrade`**: Result of the NFT upgrade.


## Multiplayer Matchmaking

In /src/mp_matchmaking we find the types.mo file where all the datatypes are defined and the main.mo file where all the logic is

### `Previous requirements`
**ic-websocket**
Follow this [tutorial](https://medium.com/@ilbert/websockets-on-the-ic-getting-started-5f8bcdfaabdc) for the implementation of ic-websocket and this [example](https://github.com/iamenochchirima/ic-websockets-pingpong-mo/tree/main) for the Motoko implementation

## `Core logic`

### `Note:`
You will find some functions duplicated, one with its regular name and other with the "WS" ending, this is mainly because we have implemented the ic-webhooks but they're only available on the web version, yet to be implemented on the ICP.NET project which we are using to develop cosmicrafts as an independent executable and multiplatform game.
Once the ICP.NET implements the websockets we will migrate everything there and remove the duplicated functions.

### `main.mo`

We have the following functions for the matchmaking:
```
/// Get if the player is already assigned to a match, if not then check if theres a match available and return this result
query getMatchSearching()

/// Match found, set player (caller) as rival for the matchID received
assignPlayer2(matchID : Nat)
/// Returns if it was possible to join the player or not
/// If it was successful then send the corresponing messages througt the websocket to otify both users that they have a match

/// Each user needs to accept the match
acceptMatch(c : Nat)
/// And in this function we check if both have accepted the match to send the corresponding message with the websocket to let both frontend know the match was accepted and they should be moved to the match lobby
/// The parameter is the player's selected character to play this game

/// If a user doesn't accept the match this function should be called
rejectMatch()
/// If both players reject the match, the lobby is dismissed
/// If only one player rejects the match, then the other player returns to the Searching state

/// If a user wants to cancel the search this function is called
cancelMatchmaking()
/// If the user haven't found a match, the search is cancelled, if there was already a match the cancelMatchmaking does nothing and returns "false" as the websocket should be already working on the process sof the match. If this is the case the user should use the rejectMatch functionallity

/// When the match is over this functions is called
setGameOver()
/// This removes the game from "In progress" and puts it on the history list "finishedGames"

/// To recover the match data (for example the other user's character when the match is accepted) we use this function
getMatchData()
```

With the websockets we have the following inside the `on_message` function
```
switch(msg.message) {
    case("addPlayerSearching") { 
        /// There are no games available for the user and we need to put them on the searching list
        addPlayerSearchingWS()
    };
    case("assignPlayer2") {
        /// There are available games and we want to join the user to one
        assignPlayer2WS()
    };
    case("acceptMatch") { 
        /// Each user accepts the match
        acceptMatchWS()
    };
    case("rejectMatch") { 
        /// A user rejects the match
        rejectMatchWS()
    };
    case(_){
        /// Some other option not contemplated
        Debug.print("Message not recognized");
    };
};
```


## Statistics and Game validators

In /src/statistics/ we find the types.mo file where all the datatypes are defined and the main.mo file where all the logic is

## `Core logic`

### `Note:`
The statistics are a work in progress and will be modified with each version of the game to ensure we get all of the necessary data

### `main.mo`

We have the following functions for the statistics:
```
/// To save all the aftermath information on each of the players once the game finish
saveFinishedGame()
/// Here we validate that both users send the same information, no player has passed some soft limits we have defined for the game values as damage dealt on the time passed, and some hard limits we have stablished as the amount of energy generated and used in the lapse of time the match was live

/// To get all the overall data from all the games and all the users we use this function
query getOverallStats()

/// To get all the average stats on all games and all users we use this function
query getAverageStats()

/// To get One user's full stats we use this function
query getMyStats()
/// It returns the data from the user who called the function

/// To get One user's average stats we use this function
query getMyAverageStats()
/// It returns the averages from the user who called the function

/// To get One game full stats we use this function
query getBasicStats(gameID : Nat)
/// Where the gameID is the game we want to retrieve
```

### Validation

The validation works the following way:
We have some fixed data inside the game and we have studied the different values that can be output with this, so if the statistics of a game are somewhere outside this probabilities, we flag the game as altered and move it to a list of games to check
For the moment the games that fall into this list will be checked manually to know what alterations anyone can be doing and try to fix it in the go

For the validator we have the following functions
```
/// There's a soft top of score that can be achieved and if this top is reached then maybe something wrong happened during the game
/// To validate the player's score vs the top we use the following function
maxPlausibleScore()

/// There's also a fixed amount of energy generated per second, if the energy used is beyond the amount of the possible given the match time, something has been altered
/// We can check this with the following function
validateEnergyBalance()

/// With the energy we decided to have a second validation to check the amount per second generated, if this is something else than the possible, we flag the game as possible alteration
validateEfficiency()

/// Finally we have the function that receives all the data and uses the rest of the functions to validate the match
validateGame()


/// For retreiving and validating data we have the following:
/// Get all the games flagged as altered by the validator
getAllOnValidation()

/// Decide that a game was real with no alteration
setGameValid()
/// This call is going to be only by the DAO once is developed, for the moment we decide it
```
