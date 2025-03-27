require 'telegram/bot'
require 'dotenv'
require 'net/http'
require 'uri'
require 'json'

puts "Setting up Telegram Bot..."

# Load environment variables
Dotenv.load

token = ENV['TELEGRAM_BOT_TOKEN']
unless token
  puts "Error: TELEGRAM_BOT_TOKEN not found in .env file"
  exit 1
end

def set_commands(token)
  puts "Setting up bot commands..."
  commands = [
    { command: 'start', description: 'Start the bot' },
    { command: 'menu', description: 'Show sushi menu' },
    { command: 'help', description: 'Get help' }
  ]
  
  uri = URI.parse("https://api.telegram.org/bot#{token}/setMyCommands")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
  request.body = { commands: commands }.to_json
  
  response = http.request(request)
  result = JSON.parse(response.body)
  
  if result['ok']
    puts "✅ Commands set successfully"
  else
    puts "❌ Failed to set commands: #{result['description']}"
  end
end

def set_webhook(token)
  puts "\nSetting up webhook..."
  print "Enter your public webhook URL (e.g., https://your-domain.com/bot/webhook): "
  webhook_url = gets.chomp
  
  if webhook_url.empty?
    puts "No webhook URL provided, skipping webhook setup"
    return
  end
  
  uri = URI.parse("https://api.telegram.org/bot#{token}/setWebhook")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
  request.body = { url: webhook_url }.to_json
  
  response = http.request(request)
  result = JSON.parse(response.body)
  
  if result['ok']
    puts "✅ Webhook set successfully to: #{webhook_url}"
  else
    puts "❌ Failed to set webhook: #{result['description']}"
  end
end

def set_menu_button(token)
  puts "\nSetting up menu button..."
  
  # Use the real website instead of asking for input
  web_app_url = "https://ohmysushi.md/"
  puts "Using existing website URL: #{web_app_url}"
  
  # Ensure URL has trailing slash
  web_app_url += '/' unless web_app_url.end_with?('/')
  
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
  
  if result['ok']
    puts "✅ Menu button set successfully with text \"#{menu_button[:text]}\" and URL \"#{web_app_url}\""
  else
    puts "❌ Failed to set menu button: #{result['description']}"
  end
end

def get_bot_info(token)
  uri = URI.parse("https://api.telegram.org/bot#{token}/getMe")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  result = JSON.parse(response.body)
  
  if result['ok']
    puts "Bot username: @#{result['result']['username']}"
    puts "Bot ID: #{result['result']['id']}"
  else
    puts "Failed to get bot info: #{result['description']}"
  end
end

# Main execution
get_bot_info(token)
set_commands(token)
set_webhook(token)
set_menu_button(token)

puts "\nBot setup complete! Your bot is ready to use."
puts "To delete the webhook at any time, run: curl --request POST https://api.telegram.org/bot#{token}/deleteWebhook"
puts "To get webhook info, run: curl https://api.telegram.org/bot#{token}/getWebhookInfo"