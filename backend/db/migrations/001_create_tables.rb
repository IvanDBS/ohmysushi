Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :telegram_id, null: false, unique: true
      String :first_name
      String :last_name
      String :username
      String :phone_number
      DateTime :created_at
      DateTime :updated_at
      
      index :telegram_id
    end
    
    create_table :orders do
      primary_key :id
      String :user_id, null: false
      Float :total, null: false
      String :status, null: false, default: 'pending'
      DateTime :created_at
      DateTime :updated_at
      
      index :user_id
      index :status
    end
    
    create_table :order_items do
      primary_key :id
      Integer :order_id, null: false
      String :item_name, null: false
      Integer :quantity, null: false
      Float :price, null: false
      DateTime :created_at
      
      index :order_id
    end
    
    create_table :delivery_info do
      primary_key :id
      Integer :order_id, null: false, unique: true
      String :name, null: false
      String :phone, null: false
      String :address, null: false
      String :notes
      DateTime :created_at
      
      index :order_id
    end
  end
end 