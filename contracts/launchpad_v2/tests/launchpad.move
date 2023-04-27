#[test_only]
module launchpad_v2::test_listing {
    use std::option::some;
    use std::type_name;
    // use std::string;
    // use std::debug;
    // debug::print(&string::utf8(b"a"));

    use sui::test_scenario::{Self, ctx};
    use sui::sui::SUI;
    use sui::transfer;

    use launchpad_v2::launchpad::{Self};
    use launchpad_v2::venue::{Self};
    use launchpad_v2::fixed_bid::{Self, Witness as FixedBidWit};
    use launchpad_v2::dutch_auction::{Self, Witness as DutchAuctionWit};
    use launchpad_v2::warehouse::{Witness as WarehouseWit};
    use launchpad_v2::pseudorand_redeem::{Witness as PseudoRandomWit};
    use launchpad_v2::schedule;

    use nft_protocol::test_utils::marketplace;
    use nft_protocol::utils_supply::Self as supply;

    #[test]
    public fun create_fixed_bid_launchpad() {
        let scenario = test_scenario::begin(marketplace());

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            some(supply::new(1_000)),
            // Market type
            type_name::get<FixedBidWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<PseudoRandomWit>(),
            // NFT Retrieval Method
            type_name::get<PseudoRandomWit>(),
            ctx(&mut scenario),
        );

        // 3. Add market module
        fixed_bid::init_market<SUI>(&launch_cap, &mut venue, 100, 10, ctx(&mut scenario));

        // 4. Add launchpad schedule
        schedule::add_schedule(
            &launch_cap,
            &mut venue,
            // Start Time: Monday, 20 April 2020 00:00:00
            some(1587340800),
            // Stop Time: Saturday, 25 April 2020 00:00:00
            some(1587772800),
        );

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);
        transfer::public_transfer(launch_cap, marketplace());

        test_scenario::end(scenario);
    }

    #[test]
    public fun create_dutch_auction_launchpad() {
        let scenario = test_scenario::begin(marketplace());

        // 1. Create a Launchpad Listing
        let (listing, launch_cap) = launchpad::new(ctx(&mut scenario));

        // 2. Create Sales Venue
        let venue = venue::new(
            &mut listing,
            &launch_cap,
            some(supply::new(1_000)),
            // Market type
            type_name::get<DutchAuctionWit>(),
            // Inventory Type
            type_name::get<WarehouseWit>(),
            // Inventory Retrieval Method
            type_name::get<PseudoRandomWit>(),
            // NFT Retrieval Method
            type_name::get<PseudoRandomWit>(),
            ctx(&mut scenario),
        );

        // 3. Add market module
        dutch_auction::init_market<SUI>(&launch_cap, &mut venue, 100);

        // 4. Add launchpad schedule
        schedule::add_schedule(
            &launch_cap,
            &mut venue,
            // Start Time: Monday, 20 April 2020 00:00:00
            some(1587340800),
            // Stop Time: Saturday, 25 April 2020 00:00:00
            some(1587772800),
        );

        transfer::public_share_object(listing);
        transfer::public_share_object(venue);
        transfer::public_transfer(launch_cap, marketplace());

        test_scenario::end(scenario);
    }
}