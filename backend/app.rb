require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'dotenv/load'
require 'telegram/bot'
require 'rack/cors'

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
  
  # Telegram Bot webhook endpoint
  post '/bot/webhook' do
    request_body = request.body.read
    
    if request_body.empty?
      status 400
      return json({ error: 'Empty request body' })
    end
    
    update = JSON.parse(request_body)
    puts "Received update: #{update.inspect}"
    
    status 200
    json({ ok: true })
  end
  
  # Health check endpoint
  get '/health' do
    json({ status: 'ok', timestamp: Time.now.to_i })
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
