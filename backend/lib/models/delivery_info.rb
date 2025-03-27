class DeliveryInfo < Sequel::Model
  many_to_one :order
  
  def validate
    super
    errors.add(:order_id, 'cannot be empty') if order_id.nil?
    errors.add(:name, 'cannot be empty') if name.nil? || name.empty?
    errors.add(:phone, 'cannot be empty') if phone.nil? || phone.empty?
    errors.add(:address, 'cannot be empty') if address.nil? || address.empty?
  end
  
  def before_create
    self.created_at = Time.now
    super
  end
  
  def to_hash
    {
      id: id,
      order_id: order_id,
      name: name,
      phone: phone,
      address: address,
      notes: notes
    }
  end
end 