<template>
  <div class="menu">
    <div class="categories">
      <button 
        v-for="(category, index) in menu.categories" 
        :key="index"
        @click="selectCategory(index)"
        :class="['category-btn', { active: selectedCategoryIndex === index }]"
      >
        {{ category.name }}
      </button>
    </div>
    
    <div v-if="currentCategory" class="category-items">
      <h2>{{ currentCategory.name }}</h2>
      <p>{{ currentCategory.description }}</p>
      
      <div class="menu-items">
        <div v-for="(item, index) in currentCategory.items" :key="index" class="menu-item card">
          <div class="menu-item-image">
            <img :src="item.image_url" :alt="item.name">
          </div>
          <div class="menu-item-content">
            <h3>{{ item.name }}</h3>
            <p>{{ item.description }}</p>
            <p class="ingredients">{{ item.ingredients }}</p>
            <div class="menu-item-footer">
              <span class="price">{{ item.price }} MDL</span>
              <button @click="addToCart(item)" class="add-btn">+ Add</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';

export default {
  name: 'MenuView',
  setup() {
    const menu = ref({ categories: [] });
    const selectedCategoryIndex = ref(0);
    const cartItems = ref([]);
    const isLoading = ref(true);
    
    // Get current selected category
    const currentCategory = computed(() => {
      if (menu.value.categories.length === 0) return null;
      return menu.value.categories[selectedCategoryIndex.value];
    });
    
    // Load menu data from API
    const loadMenu = async () => {
      try {
        isLoading.value = true;
        const response = await axios.get('/api/menu');
        menu.value = response.data;
      } catch (error) {
        console.error('Error loading menu:', error);
      } finally {
        isLoading.value = false;
      }
    };
    
    // Select a category
    const selectCategory = (index) => {
      selectedCategoryIndex.value = index;
    };
    
    // Add item to cart
    const addToCart = (item) => {
      const existingItem = cartItems.value.find(i => i.name === item.name);
      
      if (existingItem) {
        existingItem.quantity += 1;
      } else {
        cartItems.value.push({
          ...item,
          quantity: 1
        });
      }
      
      // Store cart in localStorage
      localStorage.setItem('cart', JSON.stringify(cartItems.value));
      
      // Show Telegram MainButton if we have items
      updateMainButton();
    };
    
    // Update Telegram MainButton
    const updateMainButton = () => {
      const tg = window.Telegram.WebApp;
      
      if (cartItems.value.length > 0) {
        const total = cartItems.value.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        tg.MainButton.setText(`View Cart (${total} MDL)`);
        tg.MainButton.show();
        tg.MainButton.onClick(() => {
          window.location.href = '/cart';
        });
      } else {
        tg.MainButton.hide();
      }
    };
    
    // Load cart from localStorage
    const loadCart = () => {
      const savedCart = localStorage.getItem('cart');
      if (savedCart) {
        cartItems.value = JSON.parse(savedCart);
        updateMainButton();
      }
    };
    
    onMounted(() => {
      loadMenu();
      loadCart();
    });
    
    return {
      menu,
      selectedCategoryIndex,
      currentCategory,
      isLoading,
      selectCategory,
      addToCart
    };
  }
};
</script>

<style scoped>
.menu {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.categories {
  display: flex;
  overflow-x: auto;
  padding-bottom: 8px;
  scrollbar-width: none;
  -ms-overflow-style: none;
  gap: 8px;
  padding: 4px;
}

.categories::-webkit-scrollbar {
  display: none;
}

.category-btn {
  padding: 8px 16px;
  border-radius: 20px;
  background-color: var(--tg-theme-secondary-bg-color, #f5f5f5);
  color: var(--tg-theme-text-color, #000);
  border: none;
  white-space: nowrap;
  cursor: pointer;
}

.category-btn.active {
  background-color: var(--tg-theme-button-color, #007bff);
  color: var(--tg-theme-button-text-color, #fff);
}

.menu-items {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

.menu-item {
  display: flex;
  flex-direction: column;
  border-radius: 8px;
  overflow: hidden;
}

.menu-item-image {
  width: 100%;
  height: 180px;
  overflow: hidden;
}

.menu-item-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 8px 8px 0 0;
}

.menu-item-content {
  padding: 12px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.menu-item-content h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
}

.menu-item-content p {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: var(--tg-theme-hint-color, #888);
}

.ingredients {
  font-size: 12px;
  margin-bottom: 8px;
  color: var(--tg-theme-hint-color, #888);
}

.menu-item-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.price {
  font-weight: bold;
  color: var(--primary-color);
}

.add-btn {
  padding: 6px 12px;
  border-radius: 4px;
  background-color: var(--tg-theme-button-color, #007bff);
  color: var(--tg-theme-button-text-color, #fff);
  border: none;
  cursor: pointer;
}

@media (min-width: 600px) {
  .menu-items {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style> 