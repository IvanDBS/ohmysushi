require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'dotenv/load'
require 'telegram/bot'
require 'rack/cors'
require 'net/http'

class SushiApp < Sinatra::Base
  configure do
    enable :sessions
    set :json_encoder, :to_json
    set :public_folder, 'public'
    set :views, 'views'
    set :bind, '0.0.0.0'
  end

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: [:get, :post, :options]
    end
  end
  
  # API routes for the Telegram WebApp
  
  # Menu endpoint - returns menu categories and items
  get '/api/menu' do
    content_type :json
    if File.exist?('./lib/data/menu.json')
      menu = JSON.parse(File.read('./lib/data/menu.json'))
      json menu
    else
      status 404
      json({ error: "Menu file not found" })
    end
  end

  # Create order endpoint
  post '/api/orders' do
    content_type :json
    request_payload = JSON.parse(request.body.read)
    
    # Since we're not using models yet, just log the order
    puts "Order received: #{request_payload.inspect}"
    
    # Send notification to admin chat
    send_order_to_admin(request_payload)
    
    json({ success: true, order_id: Time.now.to_i })
  end
  
  # Helper method to send order to admin chat
  def send_order_to_admin(order)
    token = ENV['TELEGRAM_BOT_TOKEN']
    chat_id = ENV['ADMIN_CHAT_ID']
    
    # Skip if not configured
    return unless token && chat_id
    
    message = "🆕 New Order!\n\n"
    message += "Customer: #{order['delivery_info']['name']}\n"
    message += "Phone: #{order['delivery_info']['phone']}\n"
    message += "Address: #{order['delivery_info']['address']}\n\n"
    message += "Items:\n"
    
    order['items'].each do |item|
      message += "- #{item['name']} x #{item['quantity']}: #{item['price'] * item['quantity']} MDL\n"
    end
    
    message += "\nTotal: #{order['total']} MDL"
    
    begin
      Telegram::Bot::Client.new(token).api.send_message(
        chat_id: chat_id,
        text: message,
        parse_mode: 'HTML'
      )
    rescue => e
      puts "Error sending message to Telegram: #{e.message}"
    end
  end

  # Set webhook for the bot
  get '/set_webhook' do
    token = ENV['TELEGRAM_BOT_TOKEN']
    webhook_url = params[:url] || "#{request.base_url}/bot/webhook"
    
    begin
      response = Telegram::Bot::Client.new(token).api.set_webhook(url: webhook_url)
      json({ success: response['ok'], description: response['description'], webhook_url: webhook_url })
    rescue => e
      json({ success: false, error: e.message })
    end
  end

  # Set menu button for the bot
  get '/set_menu_button' do
    token = ENV['TELEGRAM_BOT_TOKEN']
    web_app_url = params[:url] || "https://ivandbs.github.io/ohmysushi/"
    
    # Ensure URL has trailing slash
    web_app_url += '/' unless web_app_url.end_with?('/')
    
    begin
      menu_button = {
        type: "web_app",
        text: "Меню",
        web_app: { url: web_app_url }
      }
      
      uri = URI.parse("https://api.telegram.org/bot#{token}/setChatMenuButton")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = { menu_button: menu_button }.to_json
      
      response = http.request(request)
      result = JSON.parse(response.body)
      
      json({ success: result['ok'], description: result['description'], menu_button: menu_button })
    rescue => e
      json({ success: false, error: e.message })
    end
  end
  
  # Method to create main menu keyboard with WebApp button
  def main_menu_keyboard(web_app_url)
    kb = {
      keyboard: [
        [
          {
            text: "🍣 Order Sushi",
            web_app: { url: web_app_url }
          }
        ],
        [
          { text: "📱 Contact Us" },
          { text: "ℹ️ About Us" }
        ]
      ],
      resize_keyboard: true
    }
    kb.to_json
  end
  
  # Telegram Bot webhook endpoint
  post '/bot/webhook' do
    request_body = request.body.read
    
    if request_body.empty?
      status 400
      return json({ error: 'Empty request body' })
    end
    
    update = JSON.parse(request_body)
    puts "Received update: #{update.inspect}"
    
    # Process the update
    if update['message']
      message = update['message']
      chat_id = message['chat']['id']
      text = message['text']
      token = ENV['TELEGRAM_BOT_TOKEN']
      web_app_url = "https://ivandbs.github.io/ohmysushi/" # Replace with your hosted WebApp URL
      
      case text
      when '/start'
        # Set the menu button for this user
        set_menu_button_for_user(chat_id)
        
        Telegram::Bot::Client.new(token).api.send_message(
          chat_id: chat_id,
          text: "Welcome to Oh My Sushi! 🍣\nUse the menu below or the Menu button to order delicious sushi delivered to your door.",
          reply_markup: main_menu_keyboard(web_app_url)
        )
      when '/menu'
        Telegram::Bot::Client.new(token).api.send_message(
          chat_id: chat_id,
          text: "Tap the button below to browse our menu:",
          reply_markup: {
            inline_keyboard: [
              [
                {
                  text: "🍣 View Menu",
                  web_app: { url: web_app_url }
                }
              ]
            ]
          }.to_json
        )
      when '📱 Contact Us'
        Telegram::Bot::Client.new(token).api.send_message(
          chat_id: chat_id,
          text: "📞 Phone: +373 123 456 789\n📧 Email: info@ohmysushi.md\n⏰ Working hours: 10:00 - 22:00"
        )
      when 'ℹ️ About Us'
        Telegram::Bot::Client.new(token).api.send_message(
          chat_id: chat_id,
          text: "Oh My Sushi is a premier sushi restaurant offering the freshest and most delicious Japanese cuisine in Moldova. We source only the finest ingredients to create authentic and innovative sushi dishes."
        )
      else
        Telegram::Bot::Client.new(token).api.send_message(
          chat_id: chat_id,
          text: "I'm sorry, I didn't understand that command. Please use the menu below:",
          reply_markup: main_menu_keyboard(web_app_url)
        )
      end
    end
    
    status 200
    json({ ok: true })
  end
  
  # Set menu button for a specific user
  def set_menu_button_for_user(chat_id)
    # Make sure we have a valid token
    return { success: false, error: 'Bot token not configured' } unless ENV['TELEGRAM_BOT_TOKEN']

    # Use the real website instead of GitHub Pages
    web_app_url = "https://ohmysushi.md/"
    
    # Ensure URL has trailing slash
    web_app_url += '/' unless web_app_url.end_with?('/')
    
    menu_button = {
      type: "web_app",
      text: "Меню",
      web_app: { url: web_app_url }
    }
    
    # Set up the HTTP request to the Telegram API
    uri = URI.parse("https://api.telegram.org/bot#{ENV['TELEGRAM_BOT_TOKEN']}/setChatMenuButton")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = { chat_id: chat_id, menu_button: menu_button }.to_json
    
    # Make the request and parse the response
    begin
      response = http.request(request)
      result = JSON.parse(response.body)
      
      if result['ok']
        { success: true, message: "Menu button set with URL: #{web_app_url}" }
      else
        { success: false, error: result['description'] }
      end
    rescue => e
      { success: false, error: e.message }
    end
  end
  
  # Health check endpoint
  get '/health' do
    json({ status: 'ok', timestamp: Time.now.to_i })
  end
  
  # Get current menu button configuration
  get '/menu_button_status' do
    token = ENV['TELEGRAM_BOT_TOKEN']
    
    begin
      uri = URI.parse("https://api.telegram.org/bot#{token}/getMyCommands")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      commands_result = JSON.parse(response.body)
      
      # Get menu button info
      uri = URI.parse("https://api.telegram.org/bot#{token}/getChatMenuButton")
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      button_result = JSON.parse(response.body)
      
      # Get webhook info
      uri = URI.parse("https://api.telegram.org/bot#{token}/getWebhookInfo")
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      webhook_result = JSON.parse(response.body)
      
      json({ 
        commands: commands_result,
        menu_button: button_result,
        webhook: webhook_result
      })
    rescue => e
      json({ success: false, error: e.message })
    end
  end
  
  # Bot command setup endpoint
  get '/setup_commands' do
    token = ENV['TELEGRAM_BOT_TOKEN']
    
    commands = [
      { command: 'start', description: 'Start the bot' },
      { command: 'menu', description: 'Show sushi menu' },
      { command: 'help', description: 'Get help' }
    ]
    
    begin
      response = Telegram::Bot::Client.new(token).api.set_my_commands(commands: commands)
      json({ success: response['ok'], description: response['description'] })
    rescue => e
      json({ success: false, error: e.message })
    end
  end
  
  # Serve frontend for development purposes
  get '/' do
    if File.exist?('public/index.html')
      File.read(File.join('public', 'index.html'))
    else
      'Welcome to Oh My Sushi API. Frontend not built yet.'
    end
  end
end
