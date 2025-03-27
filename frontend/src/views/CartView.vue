<template>
  <div class="cart">
    <h1>Your Order</h1>
    
    <div v-if="cartItems.length === 0" class="empty-cart">
      <p>Your cart is empty</p>
      <button @click="$router.push('/menu')" class="btn">Back to Menu</button>
    </div>
    
    <div v-else class="cart-items">
      <div v-for="(item, index) in cartItems" :key="index" class="cart-item card">
        <div class="cart-item-info">
          <h3>{{ item.name }}</h3>
          <p>{{ item.price }} MDL</p>
        </div>
        
        <div class="cart-item-actions">
          <button @click="decreaseQuantity(index)" class="quantity-btn">-</button>
          <span class="quantity">{{ item.quantity }}</span>
          <button @click="increaseQuantity(index)" class="quantity-btn">+</button>
          <button @click="removeItem(index)" class="remove-btn">✕</button>
        </div>
        
        <div class="cart-item-total">
          <span>{{ (item.price * item.quantity).toFixed(2) }} MDL</span>
        </div>
      </div>
      
      <div class="cart-summary card">
        <div class="cart-total">
          <h3>Total</h3>
          <span class="price">{{ totalAmount.toFixed(2) }} MDL</span>
        </div>
      </div>
      
      <div class="cart-actions">
        <button @click="$router.push('/menu')" class="btn-secondary">Add More Items</button>
        <button @click="$router.push('/checkout')" class="btn">Proceed to Checkout</button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue';

export default {
  name: 'CartView',
  setup() {
    const cartItems = ref([]);
    
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
    
    // Save cart to localStorage
    const saveCart = () => {
      localStorage.setItem('cart', JSON.stringify(cartItems.value));
      updateMainButton();
    };
    
    // Increase item quantity
    const increaseQuantity = (index) => {
      cartItems.value[index].quantity += 1;
      saveCart();
    };
    
    // Decrease item quantity
    const decreaseQuantity = (index) => {
      if (cartItems.value[index].quantity > 1) {
        cartItems.value[index].quantity -= 1;
      } else {
        removeItem(index);
      }
      saveCart();
    };
    
    // Remove item from cart
    const removeItem = (index) => {
      cartItems.value.splice(index, 1);
      saveCart();
    };
    
    // Update Telegram MainButton
    const updateMainButton = () => {
      const tg = window.Telegram.WebApp;
      
      if (cartItems.value.length > 0) {
        tg.MainButton.setText('Proceed to Checkout');
        tg.MainButton.show();
        tg.MainButton.onClick(() => {
          window.location.href = '/checkout';
        });
      } else {
        tg.MainButton.hide();
      }
    };
    
    onMounted(() => {
      loadCart();
      updateMainButton();
    });
    
    return {
      cartItems,
      totalAmount,
      increaseQuantity,
      decreaseQuantity,
      removeItem
    };
  }
};
</script>

<style scoped>
.cart {
  padding: 8px 0;
}

.empty-cart {
  text-align: center;
  padding: 32px 0;
}

.cart-items {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.cart-item {
  display: grid;
  grid-template-columns: 1fr auto;
  grid-template-rows: auto auto;
  gap: 8px;
  padding: 16px;
}

.cart-item-info {
  grid-column: 1;
  grid-row: 1;
}

.cart-item-info h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
}

.cart-item-info p {
  margin: 0;
  color: var(--tg-theme-hint-color, #888);
}

.cart-item-actions {
  grid-column: 2;
  grid-row: 1;
  display: flex;
  align-items: center;
  gap: 8px;
}

.cart-item-total {
  grid-column: 1 / span 2;
  grid-row: 2;
  text-align: right;
  font-weight: bold;
  color: var(--primary-color);
}

.quantity-btn {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: none;
  background-color: var(--tg-theme-button-color, #007bff);
  color: var(--tg-theme-button-text-color, #fff);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.quantity {
  font-weight: bold;
  min-width: 24px;
  text-align: center;
}

.remove-btn {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: none;
  background-color: #f44336;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-left: 8px;
  cursor: pointer;
}

.cart-summary {
  margin-top: 16px;
}

.cart-total {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.cart-total h3 {
  margin: 0;
}

.cart-actions {
  display: flex;
  gap: 16px;
  margin-top: 16px;
}

.btn-secondary {
  background-color: var(--tg-theme-secondary-bg-color, #f5f5f5);
  color: var(--tg-theme-text-color, #000);
  border: none;
  border-radius: 4px;
  padding: 10px 16px;
  flex: 1;
  cursor: pointer;
}

.btn {
  flex: 1;
}
</style> 