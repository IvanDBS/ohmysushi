class Order < Sequel::Model
  one_to_many :order_items
  one_to_one :delivery_info
  
  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil? || user_id.empty?
    errors.add(:total, 'must be greater than 0') if total.nil? || total <= 0
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
      user_id: user_id,
      total: total,
      status: status,
      created_at: created_at,
      items: order_items.map(&:to_hash),
      delivery_info: delivery_info&.to_hash
    }
  end
end 