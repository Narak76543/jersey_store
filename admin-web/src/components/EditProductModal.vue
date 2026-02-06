<script setup>
import { ref, watch } from 'vue';
import { X, Upload, ImageIcon, CheckCircle2 } from 'lucide-vue-next';

const props = defineProps({
    product: Object,
    isOpen: Boolean
});

const emit = defineEmits(['close', 'updated']);

// Local state
const editData = ref({});
const imageFile = ref(null);
const previewUrl = ref(null);
const dragOver = ref(false);
const isLoading = ref(false);

// Sync local data when the selected product changes
watch(() => props.product, (newVal) => {
    if (newVal) {
        editData.value = { ...newVal };
        previewUrl.value = newVal.image_url; // Set existing image as preview
    }
}, { immediate: true });

// Handle File Selection
const onFileChange = (e) => {
    const file = e.target.files?.[0];
    if (file) processFile(file);
};

const onFileDrop = (e) => {
    dragOver.value = false;
    const file = e.dataTransfer.files?.[0];
    if (file) processFile(file);
};

const processFile = (file) => {
    imageFile.value = file;
    previewUrl.value = URL.createObjectURL(file);
};

const removeImage = () => {
    imageFile.value = null;
    previewUrl.value = null;
};

// API Call to Update
const handleUpdate = async () => {
    isLoading.value = true;
    const formData = new FormData();
    formData.append("name", editData.value.name);
    formData.append("name_lc", editData.value.name_lc);
    formData.append("price", editData.value.price);
    formData.append("stock_quantity", editData.value.stock_quantity);
    formData.append("descriptions", editData.value.descriptions);
    formData.append("category", editData.value.category);

    if (imageFile.value) {
        formData.append("image", imageFile.value);
    }

    try {
        const response = await fetch(`http://localhost:8000/products/${editData.value.id}`, {
            method: 'PUT',
            body: formData
        });

        if (response.ok) {
            emit('updated');
            emit('close');
        }
    } catch (error) {
        console.error("Update failed:", error);
    } finally {
        isLoading.value = false;
    }
};
</script>

<template>
    <div v-if="isOpen" class="modal-overlay" @click.self="$emit('close')">
        <div class="modal-glass">
            <header class="modal-header">
                <div class="header-title">
                    <div class="icon-box">
                        <ImageIcon :size="18" />
                    </div>
                    <h2>Edit Jersey</h2>
                </div>
                <button @click="$emit('close')" class="close-x">
                    <X :size="20" />
                </button>
            </header>

            <form @submit.prevent="handleUpdate" class="edit-form">
                <div class="field">
                    <label>Product Image</label>
                    <div class="upload-zone" :class="{ 'drag-active': dragOver }" @click="$refs.fileInput.click()"
                        @dragover.prevent="dragOver = true" @dragleave.prevent="dragOver = false"
                        @drop.prevent="onFileDrop">
                        <input ref="fileInput" type="file" hidden @change="onFileChange" accept="image/*" />

                        <div v-if="!previewUrl" class="upload-placeholder">
                            <div class="upload-circle">
                                <Upload :size="24" />
                            </div>
                            <p>Click or drag to upload</p>
                            <span>PNG, JPG, WebP (Max 5MB)</span>
                        </div>

                        <div v-else class="upload-preview">
                            <img :src="previewUrl" alt="Preview" />
                            <button type="button" class="remove-btn" @click.stop="removeImage">
                                <X :size="14" /> Change Image
                            </button>
                        </div>
                    </div>
                </div>

                <div class="field">
                    <label>Product Name</label>
                    <input v-model="editData.name" type="text" placeholder="Jersey Name" required />
                </div>

                <div class="row">
                    <div class="field">
                        <label>Price ($)</label>
                        <input v-model="editData.price" type="number" step="0.01" required />
                    </div>
                    <div class="field">
                        <label>Stock Quantity</label>
                        <input v-model="editData.stock_quantity" type="number" required />
                    </div>
                </div>

                <div class="field">
                    <label>Category</label>
                    <select v-model="editData.category">
                        <option value="Jersey">Jersey</option>
                        <option value="Retro">Retro</option>
                        <option value="Training">Training</option>
                    </select>
                </div>

                <div class="modal-actions">
                    <button type="button" @click="$emit('close')" class="btn-secondary">Cancel</button>
                    <button type="submit" class="btn-primary" :disabled="isLoading">
                        {{ isLoading ? 'Saving...' : 'Save Changes' }}
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>

<style scoped>
.modal-overlay {
    position: fixed;
    inset: 0;
    /* background: rgba(0, 0, 0, 0.85); */
    background: transparent;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
    backdrop-filter: blur(8px);
}

.modal-glass {
    background: rgba(255, 255, 255, 0.04);
    backdrop-filter: blur(25px) saturate(180%);
    border: 1px solid rgba(255, 255, 255, 0.12);
    padding: 35px;
    border-radius: 28px;
    width: 90%;
    max-width: 480px;
    color: white;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
}

/* Header */
.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
}

.header-title {
    display: flex;
    align-items: center;
    gap: 12px;
}

.icon-box {
    background: rgba(223, 37, 49, 0.2);
    padding: 8px;
    border-radius: 10px;
    color: #df2531;
}

.modal-header h2 {
    font-size: 20px;
    margin: 0;
}

.close-x {
    background: transparent;
    border: none;
    color: #aaa;
    cursor: pointer;
    transition: 0.2s;
}

.close-x:hover {
    color: white;
}

/* Modern Upload Zone */
.upload-zone {
    background: rgba(0, 0, 0, 0.3);
    border: 2px dashed rgba(255, 255, 255, 0.1);
    border-radius: 20px;
    min-height: 160px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: 0.3s;
    position: relative;
    overflow: hidden;
}

.upload-zone:hover,
.drag-active {
    border-color: #df2531;
    background: rgba(223, 37, 49, 0.05);
}

.upload-placeholder {
    text-align: center;
    color: rgba(255, 255, 255, 0.5);
}

.upload-circle {
    color: #df2531;
    margin-bottom: 8px;
}

.upload-placeholder p {
    font-size: 14px;
    font-weight: 600;
    margin: 0;
    color: white;
}

.upload-placeholder span {
    font-size: 11px;
}

.upload-preview {
    width: 100%;
    height: 160px;
    padding: 10px;
    position: relative;
}

.upload-preview img {
    width: 100%;
    height: 100%;
    object-fit: contain;
    border-radius: 12px;
}

.remove-btn {
    position: absolute;
    top: 15px;
    right: 15px;
    background: rgba(0, 0, 0, 0.7);
    border: 1px solid rgba(255, 255, 255, 0.2);
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 11px;
    display: flex;
    align-items: center;
    gap: 5px;
    cursor: pointer;
}

/* Form Styles */
.edit-form {
    display: flex;
    flex-direction: column;
    gap: 18px;
}

.field {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.field label {
    font-size: 12px;
    font-weight: 700;
    color: rgba(255, 255, 255, 0.4);
    text-transform: uppercase;
}

.field input,
.field select {
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 255, 255, 0.1);
    padding: 12px;
    border-radius: 12px;
    color: white;
    outline: none;
    transition: 0.2s;
}

.field input:focus {
    border-color: #df2531;
    box-shadow: 0 0 10px rgba(223, 37, 49, 0.2);
}

.row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
}

/* Buttons */
.modal-actions {
    display: flex;
    gap: 12px;
    margin-top: 10px;
}

.btn-primary {
    background: #df2531;
    color: white;
    border: none;
    padding: 14px;
    border-radius: 14px;
    flex: 1;
    font-weight: 700;
    cursor: pointer;
    transition: 0.3s;
    box-shadow: 0 8px 20px rgba(223, 37, 49, 0.3);
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 25px rgba(223, 37, 49, 0.4);
}

.btn-secondary {
    background: rgba(255, 255, 255, 0.05);
    color: white;
    border: none;
    padding: 14px;
    border-radius: 14px;
    flex: 1;
    cursor: pointer;
}
</style>