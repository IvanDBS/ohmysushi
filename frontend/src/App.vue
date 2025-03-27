<template>
  <div class="app-container">
    <header v-if="showHeader" class="app-header">
      <button v-if="canGoBack" @click="goBack" class="back-button">
        ← Back
      </button>
      <h1 class="app-title">Oh My Sushi</h1>
    </header>
    
    <main class="app-content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      showHeader: true
    }
  },
  computed: {
    canGoBack() {
      return this.$route.path !== '/' && this.$route.path !== '/menu';
    }
  },
  methods: {
    goBack() {
      this.$router.back();
    }
  }
}
</script>

<style>
.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.app-header {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  background-color: var(--tg-theme-bg-color, #fff);
  color: var(--tg-theme-text-color, #000);
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.app-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.back-button {
  background: none;
  border: none;
  font-size: 16px;
  color: var(--tg-theme-button-color, #007bff);
  padding: 8px;
  cursor: pointer;
  margin-right: 10px;
}

.app-content {
  flex: 1;
  padding: 16px;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style> 