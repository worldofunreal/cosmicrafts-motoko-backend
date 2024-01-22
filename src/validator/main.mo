import Types "../statistics/types";

actor class Validator() {

    //State functions
    system func preupgrade() { };
    system func postupgrade() { };

    /// Game validator
    // Function to calculate the maximum plausible score
    func maxPlausibleScore(timeInSeconds : Float) : Float {
        let maxScoreRate : Float = 550000.0 / (5.0 * 60.0);
        let maxPlausibleScore : Float = maxScoreRate * timeInSeconds;
        return maxPlausibleScore;
    };
    
    // Function to validate energy balance
    func validateEnergyBalance(timeInSeconds : Float, energySpent : Float) : Bool {
        let energyGenerated : Float = 30.0 + (0.5 * timeInSeconds);
        return energyGenerated == energySpent;
    };

    // Function to validate efficiency
    func validateEfficiency(score : Float, energySpent : Float, efficiencyThreshold : Float) : Bool {
        let efficiency : Float = score / energySpent;
        return efficiency <= efficiencyThreshold;
    };

    // Main validation function
    public shared query(msg) func validateGame(timeInSeconds : Float, energySpent : Float, score : Float, efficiencyThreshold : Float) : async Bool {
        let maxScore             : Float = maxPlausibleScore(timeInSeconds);
        let isScoreValid         : Bool  = score <= maxScore;
        let isEnergyBalanceValid : Bool  = validateEnergyBalance(timeInSeconds, energySpent);
        let isEfficiencyValid    : Bool  = validateEfficiency(score, energySpent, efficiencyThreshold);
        if(isScoreValid and isEnergyBalanceValid and isEfficiencyValid){
            return true;
        } else {
            // onValidation.put(gameID, _basicStats);
            return false;
        };
    };

};