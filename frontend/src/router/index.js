import { createRouter, createWebHistory } from 'vue-router';

// Import views
import MenuView from '../views/MenuView.vue';
import CartView from '../views/CartView.vue';
import CheckoutView from '../views/CheckoutView.vue';
import OrderSuccessView from '../views/OrderSuccessView.vue';

const routes = [
  {
    path: '/',
    redirect: '/menu'
  },
  {
    path: '/menu',
    name: 'Menu',
    component: MenuView,
    meta: { title: 'Menu' }
  },
  {
    path: '/cart',
    name: 'Cart',
    component: CartView,
    meta: { title: 'Cart' }
  },
  {
    path: '/checkout',
    name: 'Checkout',
    component: CheckoutView,
    meta: { title: 'Checkout' }
  },
  {
    path: '/success',
    name: 'OrderSuccess',
    component: OrderSuccessView,
    meta: { title: 'Order Successful' }
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Update document title
router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title} - Oh My Sushi`;
  next();
});

export default router; 