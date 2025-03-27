<template>
  <div class="order-success">
    <div class="success-icon">✓</div>
    <h1>Order Successful!</h1>
    <p>Your order has been successfully placed. We'll prepare it as soon as possible!</p>
    <p>You'll receive a confirmation in the chat.</p>
    
    <button @click="closeWebApp" class="btn">Close</button>
  </div>
</template>

<script>
export default {
  name: 'OrderSuccessView',
  mounted() {
    const tg = window.Telegram.WebApp;
    tg.MainButton.hide();
    
    // Automatically close after a few seconds
    setTimeout(() => {
      this.closeWebApp();
    }, 3000);
  },
  methods: {
    closeWebApp() {
      const tg = window.Telegram.WebApp;
      tg.close();
    }
  }
};
</script>

<style scoped>
.order-success {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 32px 16px;
  height: 70vh;
}

.success-icon {
  font-size: 64px;
  color: #4CAF50;
  background-color: rgba(76, 175, 80, 0.1);
  border-radius: 50%;
  width: 100px;
  height: 100px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

h1 {
  margin-bottom: 16px;
}

p {
  margin-bottom: 8px;
  color: var(--tg-theme-hint-color, #888);
}

.btn {
  margin-top: 24px;
}
</style> 