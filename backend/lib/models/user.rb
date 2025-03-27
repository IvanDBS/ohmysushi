class User < Sequel::Model
  one_to_many :orders
  
  def validate
    super
    errors.add(:telegram_id, 'cannot be empty') if telegram_id.nil? || telegram_id.empty?
  end
  
  def before_create
    self.created_at = Time.now
    self.updated_at = Time.now
    super
  end
  
  def before_update
    self.updated_at = Time.now
    super
  end
  
  def to_hash
    {
      id: id,
      telegram_id: telegram_id,
      first_name: first_name,
      last_name: last_name,
      username: username,
      phone_number: phone_number
    }
  end
end 