module MyModule::BloodDonation {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    
    /// Error codes
    const E_DONOR_NOT_FOUND: u64 = 1;
    const E_INVALID_BLOOD_TYPE: u64 = 2;
    const E_DONATION_TOO_RECENT: u64 = 3;
    
    /// Blood types (simplified as numbers: 1=O+, 2=O-, 3=A+, 4=A-, 5=B+, 6=B-, 7=AB+, 8=AB-)
    const BLOOD_TYPE_O_POSITIVE: u8 = 1;
    const BLOOD_TYPE_O_NEGATIVE: u8 = 2;
    const BLOOD_TYPE_A_POSITIVE: u8 = 3;
    const BLOOD_TYPE_A_NEGATIVE: u8 = 4;
    const BLOOD_TYPE_B_POSITIVE: u8 = 5;
    const BLOOD_TYPE_B_NEGATIVE: u8 = 6;
    const BLOOD_TYPE_AB_POSITIVE: u8 = 7;
    const BLOOD_TYPE_AB_NEGATIVE: u8 = 8;
    
    /// Minimum time between donations (90 days in seconds)
    const MIN_DONATION_INTERVAL: u64 = 7776000;
    
    /// Struct representing a blood donor profile
    struct DonorProfile has store, key {
        blood_type: u8,           // Blood type of the donor
        total_donations: u64,     // Total number of donations made
        last_donation_time: u64,  // Timestamp of last donation
        is_eligible: bool,        // Current eligibility status
    }
    
    /// Function to register a new donor with their blood type
    public fun register_donor(donor: &signer, blood_type: u8) {
        // Validate blood type
        assert!(blood_type >= 1 && blood_type <= 8, E_INVALID_BLOOD_TYPE);
        
        let donor_profile = DonorProfile {
            blood_type,
            total_donations: 0,
            last_donation_time: 0,
            is_eligible: true,
        };
        
        move_to(donor, donor_profile);
    }
    
    /// Function to record a blood donation
    public fun donate_blood(donor: &signer) acquires DonorProfile {
        let donor_address = signer::address_of(donor);
        assert!(exists<DonorProfile>(donor_address), E_DONOR_NOT_FOUND);
        
        let donor_profile = borrow_global_mut<DonorProfile>(donor_address);
        let current_time = timestamp::now_seconds();
        
        // Check if enough time has passed since last donation
        if (donor_profile.last_donation_time > 0) {
            assert!(
                current_time - donor_profile.last_donation_time >= MIN_DONATION_INTERVAL,
                E_DONATION_TOO_RECENT
            );
        };
        
        // Record the donation
        donor_profile.total_donations = donor_profile.total_donations + 1;
        donor_profile.last_donation_time = current_time;
        donor_profile.is_eligible = false; // Temporarily ineligible after donation
    }
}