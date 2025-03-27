# Oh My Sushi - Telegram WebApp

A Telegram WebApp for the "Oh My Sushi" restaurant that allows customers to browse the menu, add items to cart, and place orders directly from within Telegram.

## Features

- Browse menu categories and items
- Add items to cart
- Adjust quantities in cart
- Checkout process with delivery information
- Order confirmation sent to admin chat

## Project Structure

The project consists of two main parts:

### Backend (Ruby/Sinatra)

- API endpoints for menu and orders
- Database for storing orders
- Telegram bot integration
- Admin notifications

### Frontend (Vue.js)

- Telegram WebApp UI
- Menu browsing
- Cart management
- Checkout process

## Setup and Installation

### Prerequisites

- Ruby 2.7+
- Node.js 14+
- Telegram Bot (create one via BotFather)

### Backend Setup

1. Navigate to the backend directory:
   ```
   cd backend
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Setup the database:
   ```
   bundle exec ruby -r ./lib/db_setup.rb -e "DBSetup.init"
   ```

4. Configure environment variables by editing the `.env` file:
   ```
   TELEGRAM_BOT_TOKEN=your_bot_token
   ADMIN_CHAT_ID=your_admin_chat_id
   DATABASE_URL=sqlite://./db/sushi_bot.db
   BOT_WEBHOOK_URL=https://your-domain.com/bot/webhook
   ```

5. Start the server:
   ```
   bundle exec rackup -p 4567
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```
   cd frontend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Start the development server:
   ```
   npm run dev
   ```

4. Build for production:
   ```
   npm run build
   ```

## Deployment

### Local Development

For local development, you can use a service like ngrok to expose your local server to the internet:

```
ngrok http 4567
```

Update your webhook URL in the `.env` file with the ngrok URL.

### Production Deployment

Deploy the application to a hosting service like Heroku, DigitalOcean, or any other platform that supports Ruby and Node.js applications.

## Integration with Telegram

1. Create a bot using BotFather
2. Set up a webhook: `https://api.telegram.org/bot<token>/setWebhook?url=<your_domain>/bot/webhook`
3. Configure your bot to use the WebApp URL in its menu button
4. Set up your admin chat ID for receiving order notifications

## License

[MIT License](LICENSE) 