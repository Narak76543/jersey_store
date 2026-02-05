<script setup>
import { ref, computed } from "vue";
import api from "../api";
import {
  Plus,
  Upload,
  Image as ImageIcon,
  Tag,
  DollarSign,
  Boxes,
  FileText,
  X,
  CheckCircle2,
  AlertTriangle,
} from "lucide-vue-next";

const product = ref({
  name: "",
  name_lc :"",
  descriptions: "",
  price: 0,
  category: "Jersey",
  stock_quantity: 0,
});

const imageFile = ref(null);
const previewUrl = ref(null);
const isLoading = ref(false);

// toast
const toast = ref({ show: false, type: "success", title: "", desc: "" });
let toastTimer = null;

const showToast = (type, title, desc) => {
  toast.value = { show: true, type, title, desc };
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => (toast.value.show = false), 3500);
};

const onFileChange = (e) => {
  const file = e.target.files?.[0];
  if (!file) return;

  if (!file.type.startsWith("image/")) {
    showToast("error", "Invalid file", "Please upload an image (PNG/JPG/WebP).");
    return;
  }

  imageFile.value = file;
  previewUrl.value = URL.createObjectURL(file);
};

const removeImage = () => {
  imageFile.value = null;
  previewUrl.value = null;
};

const isValid = computed(() => {
  return (
    !!imageFile.value &&
    product.value.name.trim().length > 0 &&
    Number(product.value.price) >= 0 &&
    Number(product.value.stock_quantity) >= 0
  );
});

const submitStore = async () => {
  if (!imageFile.value) {
    showToast("error", "Missing image", "Please upload a product image first.");
    return;
  }

  if (!product.value.name.trim()) {
    showToast("error", "Missing name", "Please enter a product name.");
    return;
  }

  isLoading.value = true;

  const formData = new FormData();
  formData.append("name", product.value.name);
  formData.append("name_lc" , product.value.name_lc);
  formData.append("descriptions", product.value.descriptions);
  formData.append("price", product.value.price);
  formData.append("category", product.value.category);
  formData.append("stock_quantity", product.value.stock_quantity);
  formData.append("image", imageFile.value);

  try {
    await api.post("/products", formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });

    showToast("success", "Added!", "Product uploaded successfully.");

    product.value = {
      name: "",
      name_lc: "",
      descriptions: "",
      price: 0,
      category: "Jersey",
      stock_quantity: 0,
    };
    removeImage();
  } catch (err) {
    const detail = err?.response?.data?.detail || "Upload failed";
    showToast("error", "Upload error", detail);
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <div class="page">
    <!-- background blobs -->
    <div class="blob blob--orange" aria-hidden="true"></div>
    <div class="blob blob--white" aria-hidden="true"></div>
    <div class="blob blob--red" aria-hidden="true"></div>

    <!-- toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      <div class="toast__icon">
        <CheckCircle2 v-if="toast.type === 'success'" />
        <AlertTriangle v-else />
      </div>

      <div class="toast__text">
        <p class="toast__title">{{ toast.title }}</p>
        <p class="toast__desc">{{ toast.descriptions }}</p>
      </div>

      <button class="toast__close" @click="toast.show = false" aria-label="Close toast">
        <X />
      </button>
    </div>

    <main class="wrap">
      <!-- FULL SCREEN GLASS -->
      <section class="glass">
        <!-- ✅ TRUE EDGE-TO-EDGE -->
        <div class="glass-inner">
          <!-- ✅ content padding lives here -->
          <div class="content"">
            <!-- topbar -->
            <header class="topbar">
              <div class="brand">
                <div class="brand__badge">
                  <Plus />
                </div>
                <div class="brand__text">
                  <h1>Add New Product</h1>
                  <p>Manchester United store admin</p>
                </div>
              </div>

              <div class="meta">
                <span class="meta__pill">Glass UI</span>
                <span class="meta__pill meta__pill--red">#df2531</span>
              </div>
            </header>

            <!-- content -->
            <div class="grid">
              <!-- LEFT: upload -->
              <aside class="panel">
                <div class="section-title">
                  <ImageIcon class="icon-muted" />
                  <span>PRODUCT IMAGE</span>
                </div>

                <div class="upload" @click="$refs.fileInput.click()">
                  <template v-if="previewUrl">
                    <img :src="previewUrl" alt="Preview" class="upload__img" />
                    <button class="upload__remove" type="button" @click.stop="removeImage">
                      <X /> Remove
                    </button>
                  </template>

                  <template v-else>
                    <div class="upload__center">
                      <div class="upload__ring">
                        <Upload />
                      </div>
                      <p class="upload__headline">Click to upload</p>
                      <p class="upload__sub">PNG / JPG / WebP (max ~5MB)</p>
                    </div>
                  </template>

                  <input
                    ref="fileInput"
                    type="file"
                    hidden
                    accept="image/*"
                    @change="onFileChange"
                  />
                </div>

                <div class="hint">
                  <span class="hint__dot"></span>
                  <p>Tip: use a clean product photo (square works best).</p>
                </div>

                <div class="previewCard">
                  <p class="previewCard__label">Live summary</p>

                  <div class="previewCard__row">
                    <span>Name</span>
                    <b>{{ product.name || "—" }}</b>
                  </div>

                  <div class="previewCard__row">
                    <span>Category</span>
                    <b>{{ product.category }}</b>
                  </div>

                  <div class="previewCard__row">
                    <span>Price</span>
                    <b>\${{ Number(product.price || 0).toFixed(2) }}</b>
                  </div>
                </div>
              </aside>

              <!-- RIGHT: form -->
              <section class="form">
                <form class="form__inner" @submit.prevent="submitStore">
                  <div class="section-title">
                    <FileText class="icon-muted" />
                    <span>PRODUCT DETAILS</span>
                  </div>

                  <div class="field">
                    <label>Product Name</label>
                    <div class="control">
                      <!-- <Tag class="control__icon" /> -->
                      <input
                        v-model="product.name"
                        class="input"
                        placeholder="e.g., Manchester United Home Kit 2024"
                        required
                      />
                    </div>
                  </div>
                  <div class="field">
                    <label>Product Name Local</label>
                    <div class="control">
                      <!-- <Tag class="control__icon" /> -->
                      <input
                        v-model="product.name_lc"
                        class="input"
                        placeholder="e.g., បិសាចក្រហមអាវក្នុងដី 2024"
                        required
                      />
                    </div>
                  </div>
                  

                  <div class="field">
                    <label>Description</label>
                    <div class="control control--textarea">
                      <!-- <FileText class="control__icon" /> -->
                      <textarea
                        v-model="product.descriptions"
                        class="input textarea"
                        rows="6"
                        placeholder="Enter product description..."
                      />
                    </div>
                  </div>

                  <div class="row">
                    <div class="field">
                      <label>Category</label>
                      <div class="control">
                        <Boxes class="control__icon" />
                        <select v-model="product.category" class="input select">
                          <option value="Jersey">Jersey</option>
                          <option value="Retro">Retro</option>
                          <option value="Training">Training</option>
                          <option value="Accessories">Accessories</option>
                        </select>
                      </div>
                    </div>

                    <div class="field">
                      <label>Price ($)</label>
                      <div class="control">
                        <DollarSign class="control__icon" />
                        <input
                          v-model.number="product.price"
                          class="input"
                          type="number"
                          min="0"
                          step="0.01"
                          placeholder="0.00"
                        />
                      </div>
                    </div>

                    <div class="field">
                      <label>Stock</label>
                      <div class="control">
                        <Boxes class="control__icon" />
                        <input
                          v-model.number="product.stock_quantity"
                          class="input"
                          type="number"
                          min="0"
                          placeholder="0"
                        />
                      </div>
                    </div>
                  </div>

                  <button class="btn" type="submit" :disabled="!isValid || isLoading">
                    <span class="btn__shine" aria-hidden="true"></span>
                    <span class="btn__content">
                      <Plus />
                      <span>{{ isLoading ? "Uploading..." : "Add to Store" }}</span>
                    </span>
                  </button>

                  <p class="footnote">
                    By uploading, you confirm you have the right to use this image.
                  </p>
                </form>
              </section>
            </div>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<style scoped>
/* ✅ STOP OVERFLOW */
*,
*::before,
*::after {
  box-sizing: border-box;
}
.page {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  background: transparent;
}

.blob {
  position: absolute;
  width: 500px;
  height: 500px;
  filter: blur(80px);
  opacity: 0.015;
  z-index: 1;
}

.glass {
  min-height: 90vh;
  margin: 20px;
  background: rgba(255, 255, 255, 0.04);
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 24px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
}

.topbar {
  display: flex;
  padding: 18px;
  background: rgba(255, 255, 255, 0.04);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 18px 18px 0 0;
}

.nav-btn {
  padding: 12px 24px;
  margin-right: 12px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: rgba(255, 255, 255, 0.7);
  border-radius: 12px;
  cursor: pointer;
  transition: 0.3s;
}

.nav-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

/* Active State matches your AddProduct button style */
.nav-btn.active {
  background: radial-gradient(circle at 30% 30%, rgba(223, 37, 49, 0.95), rgba(223, 37, 49, 0.55));
  border-color: rgba(223, 37, 49, 0.3);
  color: white;
  box-shadow: 0 10px 20px rgba(223, 37, 49, 0.3);
  font-weight: 600;
}

.wrap {
  min-height: 100vh;
  width: 100%;
  padding: 0;
  position: relative;
  z-index: 2;
}

/* ===== FULL SCREEN GLASS ===== */
.glass {
  min-height: 100vh;
  width: 100%;
  border-radius: 0;
  margin: 0;

  overflow-y: auto; /* ✅ scroll inside */
  overflow-x: hidden;
    background-color: rgba(255, 255, 255, 0.15); 
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
}

/* ✅ TRUE EDGE TO EDGE */
.glass-inner {
  width: 100%;
  max-width: none;
  margin: 0;
  padding: 0; /* ✅ no side gap */
}

/* ✅ padding here */
.content {
  width: 100%;
  min-height: 100vh;
  padding: 24px;
}

/* ===== TOPBAR ===== */
.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 14px;
  padding: 18px 18px 16px;
  border: 1px solid rgba(255, 255, 255, 0.10);
  background: rgba(255, 255, 255, 0.04);
  border-radius: 18px;
  margin-bottom: 18px;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
}
.brand__badge {
  width: 44px;
  height: 44px;
  border-radius: 14px;
  display: grid;
  place-items: center;
  background: radial-gradient(circle at 30% 30%, rgba(223, 37, 49, 0.95), rgba(223, 37, 49, 0.35));
  box-shadow: 0 10px 24px rgba(223, 37, 49, 0.28);
}
.brand__badge :deep(svg) {
  width: 20px;
  height: 20px;
}
.brand__text h1 {
  font-size: 18px;
  margin: 0;
}
.brand__text p {
  margin: 2px 0 0;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.62);
}

.meta {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  justify-content: flex-end;
}
.meta__pill {
  font-size: 12px;
  padding: 8px 10px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.10);
  color: rgba(255, 255, 255, 0.75);
}
.meta__pill--red {
  background: rgba(223, 37, 49, 0.14);
  border-color: rgba(223, 37, 49, 0.28);
  color: rgba(255, 255, 255, 0.88);
}

/* ===== GRID ===== */
.grid {
  display: grid;
  grid-template-columns: 1fr 1.2fr;
  gap: 18px;
  align-items: start;
}

/* ✅ prevent child overflow */
.panel,
.form {
  min-width: 0;
}

/* ===== SECTIONS ===== */
.panel,
.form {
  border-radius: 18px;
  background: rgba(0, 0, 0, 0.14);
  border: 1px solid rgba(255, 255, 255, 0.10);
  padding: 18px;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 12px;
  letter-spacing: 1px;
  color: rgba(255, 255, 255, 0.75);
  margin-bottom: 12px;
  text-transform: uppercase;
}

.icon-muted {
  opacity: 0.75;
}
.icon-muted :deep(svg) {
  width: 16px;
  height: 16px;
}

/* ===== UPLOAD ===== */
.upload {
  border-radius: 18px;
  min-height: 280px;
  border: 1px dashed rgba(255, 255, 255, 0.20);
  background: rgba(0, 0, 0, 0.14);
  position: relative;
  overflow: hidden;
  cursor: pointer;
  transition: 0.25s ease;
   max-height: 240px; 
   max-width: 240px;
}
.upload:hover {
  border-color: rgba(223, 37, 49, 0.55);
  box-shadow: 0 0 0 4px rgba(223, 37, 49, 0.10) inset;
}
.upload__center {
  height: 100%;
  display: grid;
  place-items: center;
  text-align: center;
  padding: 26px;
  gap: 10px;
}
.upload__ring {
  width: 68px;
  height: 68px;
  border-radius: 999px;
  display: grid;
  place-items: center;
  background: rgba(223, 37, 49, 0.14);
  border: 1px solid rgba(223, 37, 49, 0.25);
  box-shadow: 0 10px 26px rgba(0, 0, 0, 0.25);
}
.upload__ring :deep(svg) {
  width: 26px;
  height: 26px;
}
.upload__headline {
  margin: 0;
  font-weight: 600;
  color: whitesmoke;
}
.upload__sub {
  margin: 0;
  color: rgba(255, 255, 255, 0.62);
  font-size: 13px;
}
.upload__img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  padding: 14px;
}
.upload__remove {
  position: absolute;
  right: 12px;
  top: 12px;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 10px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.14);
  background: rgba(0, 0, 0, 0.35);
  color: rgba(255, 255, 255, 0.90);
  cursor: pointer;
}
.upload__remove :deep(svg) {
  width: 16px;
  height: 16px;
}

/* hint + summary */
.hint {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-top: 14px;
  color: rgba(255, 255, 255, 0.62);
  font-size: 13px;
}
.hint__dot {
  width: 8px;
  height: 8px;
  border-radius: 999px;
  background: rgba(255, 176, 32, 0.95);
  box-shadow: 0 0 0 4px rgba(255, 176, 32, 0.12);
}

.previewCard {
  margin-top: 16px;
  border-radius: 16px;
  padding: 14px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.10);
}
.previewCard__label {
  margin: 0 0 10px;
  color: white;
  font-size: 12px;
  letter-spacing: 0.6px;
  text-transform: uppercase;
}
.previewCard__row {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 8px 0;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  color: white;
}
.previewCard__row:first-of-type {
  border-top: none;
}
.previewCard__row span {
  color: rgba(255, 255, 255, 0.62);
  font-size: 13px;
}
.previewCard__row b {
  font-size: 13px;
}

/* ===== FORM ===== */
.form__inner {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.field label {
  display: block;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.82);
  margin-bottom: 6px;
}

/* ✅ THE OVERFLOW FIX */
.control {
  position: relative;
  width: 100%;
  min-width: 0;
}
.control__icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  opacity: 0.75;
  color: rgb(243, 67, 67);
}
.control__icon :deep(svg) {
  width: 16px;
  height: 16px;
}
.control--textarea .control__icon {
  top: 16px;
  transform: none;
}

/* ✅ inputs never overflow */
.input {
  width: 100%;
  max-width: 100%;
  border-radius: 14px;
  border: 1px solid rgba(255, 255, 255, 0.14);
  background: rgba(0, 0, 0, 0.20);
  color: rgba(255, 255, 255, 0.92);
  padding: 12px 12px 12px 38px;
  outline: none;
  transition: 0.2s ease;
}
.input:focus {
  border-color: rgba(223, 37, 49, 0.55);
  box-shadow: 0 0 0 4px rgba(223, 37, 49, 0.12);
}
.input::placeholder {
  color: rgba(255, 255, 255, 0.40);
}

.textarea {
  padding-top: 12px;
  resize: vertical;
  min-height: 120px;
}

.select {
  appearance: none;
  padding-right: 38px;
  background-image: linear-gradient(45deg, transparent 50%, rgba(255, 255, 255, 0.6) 50%),
    linear-gradient(135deg, rgba(255, 255, 255, 0.6) 50%, transparent 50%);
  background-position: calc(100% - 18px) 50%, calc(100% - 12px) 50%;
  background-size: 6px 6px, 6px 6px;
  background-repeat: no-repeat;
}

.row {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1fr;
  gap: 12px;
}

/* ===== BUTTON ===== */
.btn {
  width: 100%;
  margin-top: 6px;
  border: none;
  border-radius: 16px;
  padding: 14px;
  cursor: pointer;

  /* background: radial-gradient(circle at 20% 20%, rgba(255, 255, 255, 0.18), transparent 38%),
    linear-gradient(135deg, rgba(223, 37, 49, 0.95), rgba(223, 37, 49, 0.60));
  color: white;
  font-weight: 700; */
  background: rgba(199, 1, 1, 0.6); /* Man Utd Red */
  border-color: #c70101;
  box-shadow: 0 0 15px rgba(199, 1, 1, 0.4);
  color: aliceblue;

  position: relative;
  overflow: hidden;
  box-shadow: 0 14px 30px rgba(223, 37, 49, 0.22);
  transition: 0.25s ease;
}
.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 18px 40px rgba(223, 37, 49, 0.28);
}
.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  transform: none;
}
.btn__content {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 10px;


}
.btn__content :deep(svg) {
  width: 18px;
  height: 18px;
}
.btn__shine {
  position: absolute;
  inset: -50%;
  background: linear-gradient(120deg, transparent 40%, rgba(249, 72, 72, 0.22), transparent 60%);
  transform: translateX(-40%);
  animation: shine 2.6s linear infinite;
}
@keyframes shine {
  0% { transform: translateX(-45%); }
  100% { transform: translateX(45%); }
}

.footnote {
  margin: 0;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.55);
  text-align: center;
  margin-top: 10px;
  padding-bottom: 14px;
}

/* ===== TOAST ===== */
.toast {
  position: fixed;
  right: 18px;
  top: 18px;
  z-index: 50;
  width: min(380px, calc(100% - 36px));
  border-radius: 16px;
  padding: 12px;
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 10px;
  align-items: center;
  border: 1px solid rgba(255, 255, 255, 0.14);
  background: rgba(0, 0, 0, 0.55);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  box-shadow: 0 18px 50px rgba(0, 0, 0, 0.45);
}
.toast__icon {
  width: 38px;
  height: 38px;
  border-radius: 12px;
  display: grid;
  place-items: center;
  background: rgba(255, 255, 255, 0.08);
}
.toast.success .toast__icon {
  background: rgba(16, 185, 129, 0.15);
  border: 1px solid rgba(16, 185, 129, 0.25);
}
.toast.error .toast__icon {
  background: rgba(239, 68, 68, 0.15);
  border: 1px solid rgba(239, 68, 68, 0.25);
}
.toast__icon :deep(svg) {
  width: 18px;
  height: 18px;
}
.toast__title {
  margin: 0;
  font-weight: 700;
  font-size: 13px;
}
.toast__desc {
  margin: 2px 0 0;
  color: rgba(255, 255, 255, 0.70);
  font-size: 12px;
}
.toast__close {
  border: none;
  cursor: pointer;
  background: transparent;
  color: rgba(255, 255, 255, 0.85);
  padding: 6px;
  border-radius: 10px;
}
.toast__close :deep(svg) {
  width: 18px;
  height: 18px;
}

/* ===== RESPONSIVE ===== */
@media (max-width: 980px) {
  .grid {
    grid-template-columns: 1fr;
  }
  .row {
    grid-template-columns: 1fr;
  }
  .topbar {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
