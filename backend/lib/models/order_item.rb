class OrderItem < Sequel::Model
  many_to_one :order
  
  def validate
    super
    errors.add(:order_id, 'cannot be empty') if order_id.nil?
    errors.add(:item_name, 'cannot be empty') if item_name.nil? || item_name.empty?
    errors.add(:quantity, 'must be greater than 0') if quantity.nil? || quantity <= 0
    errors.add(:price, 'must be greater than 0') if price.nil? || price <= 0
  end
  
  def before_create
    self.created_at = Time.now
    super
  end
  
  def to_hash
    {
      id: id,
      order_id: order_id,
      item_name: item_name,
      quantity: quantity,
      price: price,
      subtotal: price * quantity
    }
  end
end 