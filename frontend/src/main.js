import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import './assets/styles.css';

const app = createApp(App);

// Check if Telegram WebApp is available
if (window.Telegram && window.Telegram.WebApp) {
  // Make telegram WebApp available in all components
  app.config.globalProperties.$telegram = window.Telegram.WebApp;

  // Init telegram WebApp
  window.Telegram.WebApp.ready();
  window.Telegram.WebApp.expand();
} else {
  console.log('Running outside of Telegram WebApp');
  // Create a mock Telegram WebApp for testing
  app.config.globalProperties.$telegram = {
    MainButton: {
      text: '',
      isVisible: false,
      setText: (text) => {
        console.log('MainButton.setText:', text);
        this.text = text;
      },
      show: () => {
        console.log('MainButton.show');
        this.isVisible = true;
      },
      hide: () => {
        console.log('MainButton.hide');
        this.isVisible = false;
      },
      onClick: (callback) => {
        console.log('MainButton.onClick registered');
      }
    },
    close: () => {
      console.log('WebApp.close called');
    },
    ready: () => {
      console.log('WebApp.ready called');
    },
    expand: () => {
      console.log('WebApp.expand called');
    },
    initDataUnsafe: {
      user: {
        id: 123456789,
        first_name: 'Test',
        last_name: 'User',
        username: 'testuser'
      }
    }
  };
}

app.use(router);
app.mount('#app'); 