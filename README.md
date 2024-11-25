TicketPick: Real-Time Event Ticket Marketplace

TicketPick is a real-time ticket marketplace built on the Dutch auction model. The platform enables event organizers to sell tickets for events such as concerts, sports matches, and more. Prices for tickets drop over time, incentivizing early buyers while providing an engaging way for users to purchase tickets at the best possible price.

Features

- Dutch Auction Model: Prices start at a maximum value and decrease over time until a bidder accepts the price.
- Ticket Auctions: Event organizers (auctioneers) can create and manage ticket auctions.
- Real-Time Bidding: Users can place bids at the current auction price to purchase tickets.
- Flexible Seat Selection: Users can select specific seats based on availability.
- Anti-Scalping Measures: Measures to verify users and prevent scalping practices.
- Instant Payments: Integration with digital wallets for fast and secure payments.
  
Requirements

- Move Language: The code is written using the Move programming language, deployed on the Sui blockchain.
- Git: For version control and managing repository updates.
- Sui Wallet: Integration with Sui's digital wallet for transactions.

Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/soss28/ticketpick.git
    cd ticketpick
    ```

2. Install Move toolchain (if you haven't already). Instructions can be found on the official [Move documentation](https://move-language.github.io/).

3. Ensure that you have a Sui wallet setup to interact with the platform.

Usage

Deploying the Smart Contract

1. Compile the Move contract and deploy it to the Sui blockchain:

    ```bash
    sui move compile --path <path-to-your-move-code>
    ```

2. Deploy the contract:

    ```bash
    sui client publish --path <path-to-your-move-code>
    ```

3. Interact with the contract through the Move command line or via the Sui client.

Example Interaction

1. Creating a new auction:

    An event organizer can create a new ticket auction by specifying the ticket price and available seats.

    ```move
    let auction = ticketpick::auction::create(ticket, 1000)
    ```

2. Bidding on tickets:

    Users can place a bid when the auction price meets their expectations:

    ```move
    let result = ticketpick::auction::bid(auction, balance)
    ```

3. Claiming auction proceeds:

    After the auction ends, the auctioneer can claim the proceeds:

    ```move
    let claim = ticketpick::auction::claim(auction, auctioneer_cap)
    ```

Error Codes

- `EAuctionHasEnded`: Auction has already ended.
- `EAuctionHasNotEnded`: Auction is still ongoing.
- `EBalanceNotEnough`: The user's balance is insufficient to place a bid.
- `ENewPriceMustBeLower`: The new price set by the auctioneer must be lower than the current price.
- `EAuctionIDMismatch`: Mismatch between the auction ID and the provided auction capability.

Contributing

We welcome contributions to TicketPick! If you have ideas, features, or bug fixes, please fork the repository and create a pull request.

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add feature'`).
5. Push to the branch (`git push origin feature-name`).
6. Create a new pull request.

License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Acknowledgments

- The Move language and the Sui blockchain for enabling secure and scalable decentralized applications.
- Special thanks to the community contributors for their support.
