module ticketpick::marketplace {

    use sui::balance::{Self, Balance};
    use sui::event::{Self};


    const EAuctionAlreadyEnded: u64 = 0;      
    const EAuctionNotYetEnded: u64 = 1;       
    const EInsufficientBalance: u64 = 2;      
    const EInvalidPriceUpdate: u64 = 3;       
    const EInvalidAuctionID: u64 = 4;         


    public struct AuctionCreated has copy, drop {
        auction_id: ID,
        initial_price: u64,
        event_name: vector<u8>,
        tickets_count: u64,
    }

    public struct PriceUpdated has copy, drop {
        auction_id: ID,
        new_price: u64,
    }

    public struct TicketPurchased has copy, drop {
        auction_id: ID,
        buyer: address,
        final_price: u64,
    }

    public struct AuctionStopped has copy, drop {
        auction_id: ID,
    }

    public struct Auction<T0: store, phantom T1> has key {
        id: UID,
        tickets: vector<T0>,  
        current_price: u64,      
        ended: bool,              
        proceeds: Balance<T1>,    
    }

    public struct AuctioneerCap has key, store {
        id: UID,
        auction_id: ID,
    }

    public fun get_current_price<T0: store, T1>(auction: &Auction<T0, T1>): u64 {
        auction.current_price
    }

    public fun create_auction<T0: store, T1>(
        tickets: vector<T0>,
        initial_price: u64,
        event_name: vector<u8>,
        ctx: &mut TxContext,
    ): AuctioneerCap {
        let auction = Auction<T0, T1> {
            id: object::new(ctx),
            tickets,
            current_price: initial_price,
            ended: false,
            proceeds: balance::zero(),
        };

        let auction_cap = AuctioneerCap {
            id: object::new(ctx),
            auction_id: object::uid_to_inner(&auction.id),
        };

        event::emit(AuctionCreated {
            auction_id: object::uid_to_inner(&auction.id),
            initial_price,
            event_name,
            tickets_count: vector::length(&auction.tickets),
        });

        transfer::share_object(auction);
        auction_cap
    }

    public fun update_price<T0: store, T1>(
        auction: &mut Auction<T0, T1>,
        auction_cap: &AuctioneerCap,
        new_price: u64,
    ) {
        assert!(object::uid_to_inner(&auction.id) == auction_cap.auction_id, EInvalidAuctionID);
        assert!(!auction.ended, EAuctionAlreadyEnded);
        assert!(new_price < auction.current_price, EInvalidPriceUpdate);

        auction.current_price = new_price;

        event::emit(PriceUpdated {
            auction_id: object::uid_to_inner(&auction.id),
            new_price,
        });
    }

    public fun purchase_ticket<T0: store, T1>(
        auction: &mut Auction<T0, T1>,
        mut buyer_balance: Balance<T1>,
        ctx: &mut TxContext,
    ): (T0, Balance<T1>) {
        assert!(!auction.ended, EAuctionAlreadyEnded);
        assert!(buyer_balance.value() >= auction.current_price, EInsufficientBalance);

        let payment = balance::split(&mut buyer_balance, auction.current_price);
        balance::join(&mut auction.proceeds, payment);

        let ticket = vector::pop_back(&mut auction.tickets);

        if (vector::is_empty(&auction.tickets)) {
            auction.ended = true;
        };

        event::emit(TicketPurchased {
            auction_id: object::uid_to_inner(&auction.id),
            buyer: ctx.sender(),
            final_price: auction.current_price,
        });

        (ticket, buyer_balance)
    }

    
    public fun stop_auction<T0: store, T1>(
        auction: Auction<T0, T1>,
        auction_cap: AuctioneerCap,
    ): vector<T0> {
        assert!(object::uid_to_inner(&auction.id) == auction_cap.auction_id, EInvalidAuctionID);
        assert!(!auction.ended, EAuctionAlreadyEnded);

        let Auction { id, tickets, current_price: _, ended: _, proceeds } = auction;

        event::emit(AuctionStopped {
            auction_id: object::uid_to_inner(&id),
        });

        object::delete(id);
        balance::destroy_zero(proceeds);

        let AuctioneerCap { id, auction_id: _ } = auction_cap;
        object::delete(id);

        tickets
    }

    
    public fun claim_proceeds<T0: store, T1>(
        auction: Auction<T0, T1>,
        auction_cap: AuctioneerCap,
    ): Balance<T1> {
        assert!(object::uid_to_inner(&auction.id) == auction_cap.auction_id, EInvalidAuctionID);
        assert!(auction.ended, EAuctionNotYetEnded);

        let Auction { id, tickets, current_price: _, ended: _, proceeds } = auction;

        object::delete(id);
        vector::destroy_empty(tickets);

        let AuctioneerCap { id, auction_id: _ } = auction_cap;
        object::delete(id);

        proceeds
    }
}
