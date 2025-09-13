module MyModule::SimpleDAO {
    use aptos_framework::signer;
    use std::vector;

    /// Struct representing a DAO proposal with voting mechanism
    struct Proposal has store, key {
        description: vector<u8>,    // Proposal description
        yes_votes: u64,            // Number of yes votes
        no_votes: u64,             // Number of no votes
        voters: vector<address>,   // Track who has voted to prevent double voting
        is_active: bool,           // Whether proposal is still accepting votes
    }

    /// Function to create a new proposal in the DAO
    public fun create_proposal(creator: &signer, description: vector<u8>) {
        let proposal = Proposal {
            description,
            yes_votes: 0,
            no_votes: 0,
            voters: vector::empty<address>(),
            is_active: true,
        };
        move_to(creator, proposal);
    }

    /// Function for DAO members to vote on a proposal
    public fun vote_on_proposal(
        voter: &signer, 
        proposal_owner: address, 
        vote_yes: bool
    ) acquires Proposal {
        let proposal = borrow_global_mut<Proposal>(proposal_owner);
        let voter_addr = signer::address_of(voter);
        
        // Check if proposal is still active
        assert!(proposal.is_active, 1);
        
        // Check if voter has already voted
        assert!(!vector::contains(&proposal.voters, &voter_addr), 2);
        
        // Record the vote
        if (vote_yes) {
            proposal.yes_votes = proposal.yes_votes + 1;
        } else {
            proposal.no_votes = proposal.no_votes + 1;
        };
        
        // Add voter to the list to prevent double voting
        vector::push_back(&mut proposal.voters, voter_addr);
        
        // Auto-close proposal if it reaches 10 total votes
        if (proposal.yes_votes + proposal.no_votes >= 10) {
            proposal.is_active = false;
        };
    }
}