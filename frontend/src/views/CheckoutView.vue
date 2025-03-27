<template>
  <div class="checkout">
    <h1>Checkout</h1>
    
    <div v-if="cartItems.length === 0" class="empty-cart">
      <p>Your cart is empty</p>
      <button @click="$router.push('/menu')" class="btn">Go to Menu</button>
    </div>
    
    <div v-else>
      <div class="order-summary card">
        <h2>Order Summary</h2>
        <div class="order-items">
          <div v-for="(item, index) in cartItems" :key="index" class="order-item">
            <div class="order-item-details">
              <span>{{ item.name }} × {{ item.quantity }}</span>
            </div>
            <div class="order-item-price">
              <span>{{ (item.price * item.quantity).toFixed(2) }} MDL</span>
            </div>
          </div>
        </div>
        
        <div class="order-total">
          <strong>Total:</strong>
          <span class="price">{{ totalAmount.toFixed(2) }} MDL</span>
        </div>
      </div>
      
      <div class="delivery-info card">
        <h2>Delivery Information</h2>
        <form @submit.prevent="submitOrder">
          <div class="form-group">
            <label for="name" class="form-label">Full Name</label>
            <input 
              type="text" 
              id="name" 
              v-model="deliveryInfo.name" 
              class="form-input" 
              required 
              :class="{ 'is-invalid': errors.name }"
            >
            <div v-if="errors.name" class="error-message">{{ errors.name }}</div>
          </div>
          
          <div class="form-group">
            <label for="phone" class="form-label">Phone Number</label>
            <input 
              type="tel" 
              id="phone" 
              v-model="deliveryInfo.phone" 
              class="form-input" 
              required 
              placeholder="+373 XXXXXXX"
              :class="{ 'is-invalid': errors.phone }"
            >
            <div v-if="errors.phone" class="error-message">{{ errors.phone }}</div>
          </div>
          
          <div class="form-group">
            <label for="address" class="form-label">Delivery Address</label>
            <input 
              type="text" 
              id="address" 
              v-model="deliveryInfo.address" 
              class="form-input" 
              required 
              :class="{ 'is-invalid': errors.address }"
            >
            <div v-if="errors.address" class="error-message">{{ errors.address }}</div>
          </div>
          
          <div class="form-group">
            <label for="notes" class="form-label">Notes (Optional)</label>
            <textarea 
              id="notes" 
              v-model="deliveryInfo.notes" 
              class="form-input" 
              rows="3"
            ></textarea>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';

export default {
  name: 'CheckoutView',
  setup() {
    const router = useRouter();
    const cartItems = ref([]);
    const deliveryInfo = ref({
      name: '',
      phone: '',
      address: '',
      notes: ''
    });
    const errors = ref({});
    const isSubmitting = ref(false);
    
    // Calculate total amount
    const totalAmount = computed(() => {
      return cartItems.value.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    });
    
    // Load cart from localStorage
    const loadCart = () => {
      const savedCart = localStorage.getItem('cart');
      if (savedCart) {
        cartItems.value = JSON.parse(savedCart);
      }
    };
    
    // Validate form
    const validateForm = () => {
      const newErrors = {};
      
      if (!deliveryInfo.value.name.trim()) {
        newErrors.name = 'Name is required';
      }
      
      if (!deliveryInfo.value.phone.trim()) {
        newErrors.phone = 'Phone number is required';
      } else if (!validatePhone(deliveryInfo.value.phone)) {
        newErrors.phone = 'Please enter a valid phone number';
      }
      
      if (!deliveryInfo.value.address.trim()) {
        newErrors.address = 'Address is required';
      }
      
      errors.value = newErrors;
      return Object.keys(newErrors).length === 0;
    };
    
    // Validate phone number
    const validatePhone = (phone) => {
      // Basic phone validation, can be enhanced
      return /^\+?[0-9]{8,15}$/.test(phone.replace(/\s/g, ''));
    };
    
    // Submit order
    const submitOrder = async () => {
      if (!validateForm() || isSubmitting.value) return;
      
      try {
        isSubmitting.value = true;
        
        const tg = window.Telegram.WebApp;
        const user = tg.initDataUnsafe?.user || { id: 'web_user' };
        
        const orderData = {
          user_id: user.id.toString(),
          items: cartItems.value,
          total: totalAmount.value,
          delivery_info: deliveryInfo.value
        };
        
        const response = await axios.post('/api/orders', orderData);
        
        if (response.data.success) {
          // Clear cart
          localStorage.removeItem('cart');
          
          // Send data back to Telegram
          tg.MainButton.hide();
          tg.close();
          
          // Navigate to success page (if not closed)
          router.push('/success');
        }
      } catch (error) {
        console.error('Error submitting order:', error);
        alert('There was an error processing your order. Please try again.');
      } finally {
        isSubmitting.value = false;
      }
    };
    
    // Update Telegram MainButton
    const updateMainButton = () => {
      const tg = window.Telegram.WebApp;
      
      if (cartItems.value.length > 0) {
        tg.MainButton.setText('Place Order');
        tg.MainButton.show();
        tg.MainButton.onClick(submitOrder);
      } else {
        tg.MainButton.hide();
      }
    };
    
    onMounted(() => {
      loadCart();
      updateMainButton();
      
      // Try to prefill user data from Telegram if available
      const tg = window.Telegram.WebApp;
      const user = tg.initDataUnsafe?.user;
      
      if (user) {
        deliveryInfo.value.name = [user.first_name, user.last_name].filter(Boolean).join(' ');
      }
    });
    
    return {
      cartItems,
      deliveryInfo,
      totalAmount,
      errors,
      submitOrder
    };
  }
};
</script>

<style scoped>
.checkout {
  padding: 8px 0;
}

.empty-cart {
  text-align: center;
  padding: 32px 0;
}

.card {
  margin-bottom: 24px;
}

.order-summary h2,
.delivery-info h2 {
  margin-top: 0;
  margin-bottom: 16px;
  font-size: 18px;
}

.order-items {
  margin-bottom: 16px;
}

.order-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.order-item:last-child {
  border-bottom: none;
}

.order-total {
  display: flex;
  justify-content: space-between;
  font-size: 18px;
  padding-top: 16px;
  border-top: 2px solid rgba(0, 0, 0, 0.1);
}

.form-group {
  margin-bottom: 16px;
}

.is-invalid {
  border-color: #f44336 !important;
}

.error-message {
  color: #f44336;
  font-size: 14px;
  margin-top: 4px;
}
</style> 