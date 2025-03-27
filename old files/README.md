# Oh My Sushi Telegram Bot

A Telegram bot for ordering sushi from Oh My Sushi restaurant. Built with Ruby and Telegram Bot API.

## Features

- Browse menu categories and items
- Add items to cart
- Manage cart (update quantities, remove items)
- Place orders with delivery information
- Process payments through Telegram Payments API
- Admin notifications for new orders

## Requirements

- Ruby 3.0+
- SQLite3
- Bundler

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/sushi-bot.git
cd sushi-bot
```

2. Install dependencies:
```bash
bundle install
```

3. Create a `.env` file in the project root and add your configuration:
```
TELEGRAM_BOT_TOKEN=your_bot_token_here
PAYMENT_PROVIDER_TOKEN=your_payment_token_here
ADMIN_CHAT_ID=your_admin_chat_id_here
DATABASE_URL=sqlite://db/sushi_bot.db
WEBHOOK_URL=your_webhook_url_here
```

4. Initialize the database and import menu data:
```bash
ruby lib/models/init.rb
ruby scripts/import_menu.rb
```

## Running the Bot

Start the bot:
```bash
ruby lib/bot.rb
```

## Project Structure

- `lib/` - Main application code
  - `bot.rb` - Main bot file
  - `models/` - Database models
  - `handlers/` - Message and callback handlers
  - `services/` - Business logic services
- `data/` - Data files (menu, etc.)
- `db/` - Database files
- `scripts/` - Utility scripts

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 