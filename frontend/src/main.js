import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import './assets/styles.css';

const app = createApp(App);

// Make telegram WebApp available in all components
app.config.globalProperties.$telegram = window.Telegram.WebApp;

// Init telegram WebApp
window.Telegram.WebApp.ready();
window.Telegram.WebApp.expand();

app.use(router);
app.mount('#app'); 