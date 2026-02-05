<script setup>
import { ref, onMounted } from 'vue';
import EditProductModal from './EditProductModal.vue';

const products = ref([]);
const loading = ref(true);

const selectedProduct = ref(null);
const isEditModalOpen = ref(false);

const fetchProducts = async () => {
  try {
    const response = await fetch('http://localhost:8000/products');
    const data = await response.json();
    products.value = data;
  } catch (error) {
    console.error("error fetching", error);
  } finally {
    loading.value = false;
  }
};

const handleEdit = (item) => {
  selectedProduct.value = item;
  isEditModalOpen.value = true;
};

onMounted(() => {
  fetchProducts();
});
</script>

<template>
  <div class="container">
    <h1 class="title">Man U Store Inventory</h1>
    
    <div v-if="loading" class="loading-text">Loading kits...</div>

    <div v-else class="list-container">
      <div class="header-row">
        <span class="col-photo">Photo</span>
        <span class="col-name">Name</span>
        <span class="col-name-lc">Name (Local)</span>
        <span class="col-price">Price</span>
        <span class="col-desc">Description</span>
        <span class="col-stock">Stock</span>
        <span class="col-actions">Actions</span>
      </div>

      <div v-for="item in products" :key="item.id" class="list-card">
        <div class="col col-photo">
          <img :src="item.image_url" alt="Jersey" class="row-img" />
        </div>
        
        <div class="col col-name">
          <p class="product-text">{{ item.category+" - "+ item.name }}</p>
        </div>

        <div class="col col-name-lc">
          <p class="product-text-kh">{{ item.name_lc }}</p>
        </div>

        <div class="col col-price">
          <p class="product-price">${{ item.price }}</p>
        </div>

        <div class="col col-desc">
          <p class="product-desc">{{ item.descriptions }}</p>
        </div>

        <div class="col col-stock">
          <p class="product-text">{{ item.stock_quantity }}</p>
        </div>

        <div class="col col-actions">
          <div class="btn-group">
            <button class="btn btn-edit" @click="handleEdit(item)">Edit</button>
            <button class="btn btn-view">View</button>
          </div>
        </div>
      </div>
    </div>

    <EditProductModal 
      :isOpen="isEditModalOpen" 
      :product="selectedProduct" 
      @close="isEditModalOpen = false" 
      @updated="fetchProducts" 
    />
  </div>
</template>

<style scoped>
/* --- Layout Structure --- */
.container {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.title {
  color: white;
  margin-bottom: 25px;
  font-size: 24px;
}

.list-container {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

/* --- Column Sizing --- */
.header-row, .list-card {
  display: grid;

  grid-template-columns: 80px 2fr 1fr 80px 2fr 80px 160px;
  align-items: center;
  gap: 15px;
}

.header-row {
  padding: 10px 20px;
  color: rgba(255, 255, 255, 0.5);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.list-card {
  background: rgba(255, 255, 255, 0.06);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 10px 20px;
  transition: all 0.3s ease;
}

.list-card:hover {
  background: rgba(255, 255, 255, 0.12);
  transform: translateX(5px);
}

.row-img {
  width: 50px;
  height: 50px;
  object-fit: contain; /* */
  background: rgba(0, 0, 0, 0.2);
  border-radius: 8px;
}

.product-text { color: #fff; font-size: 14px; margin: 0; }

.product-text-kh { 
  color: #ddd; 
  font-size: 13px; 
  font-family: "Koh Santepheap", serif; 
  margin: 0;
}

.product-price { color: #ff4d4d; font-weight: bold; margin: 0; }

.product-desc {
  color: rgba(255, 255, 255, 0.6);
  font-size: 12px;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin: 0;
}


.btn-group {
  display: flex;
  gap: 8px;
}

.btn {
  border: none;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 11px;
  font-weight: 600;
  flex: 1;
}

.btn-view {
  background-color: #df2531;
  color: white;
}

.btn-edit {
  background-color: rgba(255, 255, 255, 0.1);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.btn:hover {
  opacity: 0.8;
  transform: translateY(-1px);
}
</style>