
<script setup>
import { ref } from 'vue';
import GetProduct from './components/GetProduct.vue';
import AddProduct from './components/AddProduct.vue';

// Use this to track which screen is active
const currentScreen = ref('monitor'); 
</script>

<template>
  <div class="admin-container">
    <nav class="nav-menu">
      <button 
        @click="currentScreen = 'monitor'" 
        :class="{ active: currentScreen === 'monitor' }"
        class="nav-btn"
      >
        Monitor Inventory
      </button>
      
      <button 
        @click="currentScreen = 'add'" 
        :class="{ active: currentScreen === 'add' }"
        class="nav-btn"
      >
        Add New Jersey
      </button>
    </nav>

    <main class="content-area">
      <GetProduct v-if="currentScreen === 'monitor'" />
      <AddProduct v-if="currentScreen === 'add'" />
    </main>
  </div>
</template>

<style scoped>
.admin-container {
  padding: 20px;
}

.nav-menu {
  display: flex;
  gap: 15px;
  justify-content: center;
  margin-bottom: 30px;
}

/* Glassmorphism Navigation Buttons */
.nav-btn {
  padding: 12px 24px;
  font-size: 1rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  cursor: pointer;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.nav-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

/* Red Glow for Active Button */
.nav-btn.active {
  background: rgba(199, 1, 1, 0.6); /* Man Utd Red */
  border-color: #c70101;
  box-shadow: 0 0 15px rgba(199, 1, 1, 0.4);
}

.content-area {
  animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
</style>