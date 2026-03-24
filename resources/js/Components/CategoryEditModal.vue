<script setup lang="ts">
import AppModal from '@/Components/AppModal.vue';
import { router, useForm } from '@inertiajs/vue3';
import { ref, watch } from 'vue';

type CategoryType = 'expense' | 'income' | 'saving' | 'loan';

export type CategoryForEdit = {
    id: number;
    name: string;
    type: CategoryType;
    color: string;
    icon: string;
    budget_amount: string | number;
    loan_amount: string | number | null;
    emi_amount: string | number | null;
    monthly_amount: string | number | null;
    target_amount: string | number | null;
};

const props = defineProps<{ category: CategoryForEdit | null }>();
const emit = defineEmits<{ close: [] }>();

const presetColors = [
    '#F43F5E', '#EC4899', '#D946EF', '#A855F7', '#7C3AED', '#6366F1', '#06B6D4', '#0D9488',
    '#BE185D', '#9333EA', '#4F46E5', '#0891B2', '#0E7490', '#0F766E', '#F97316', '#64748B',
];

const confirmingDelete = ref(false);

const form = useForm({
    name: '', color: '#7C3AED', icon: 'circle',
    budget_amount: '' as string | number,
    loan_amount: '' as string | number,
    emi_amount: '' as string | number,
    monthly_amount: '' as string | number,
    target_amount: '' as string | number,
});

watch(() => props.category, (cat) => {
    if (cat) {
        form.name = cat.name;
        form.color = cat.color;
        form.icon = cat.icon;
        form.budget_amount = cat.budget_amount;
        form.loan_amount = cat.loan_amount ?? '';
        form.emi_amount = cat.emi_amount ?? '';
        form.monthly_amount = cat.monthly_amount ?? '';
        form.target_amount = cat.target_amount ?? '';
        confirmingDelete.value = false;
    }
});

const submit = () => {
    form.patch(`/categories/${props.category!.id}`, {
        preserveScroll: true,
        onSuccess: () => emit('close'),
    });
};

const confirmDelete = () => {
    router.delete(`/categories/${props.category!.id}`, {
        preserveScroll: true,
        onSuccess: () => { confirmingDelete.value = false; emit('close'); },
    });
};
</script>

<template>
    <AppModal v-if="category" :title="`Edit ${category.name}`" @close="emit('close')">
        <form class="space-y-5" @submit.prevent="submit">
            <div class="flex items-center gap-4 p-4 rounded-xl bg-gray-50 dark:bg-white/5">
                <div
                    class="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg flex-shrink-0"
                    :style="{ backgroundColor: form.color, boxShadow: `0 4px 14px ${form.color}40` }"
                >
                    {{ form.name ? form.name[0].toUpperCase() : '?' }}
                </div>
                <div>
                    <div class="font-semibold text-gray-900 dark:text-white">{{ form.name || '—' }}</div>
                    <div class="text-xs text-gray-400 capitalize">{{ category.type }}</div>
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
                <input v-model="form.name" type="text" required class="input" />
                <p v-if="form.errors.name" class="mt-1 text-xs text-red-500">{{ form.errors.name }}</p>
            </div>

            <div v-if="category.type === 'expense'">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Monthly Budget</label>
                <div class="relative">
                    <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-violet-400 select-none pointer-events-none">৳</span>
                    <input v-model="form.budget_amount" type="number" step="0.01" min="0" required placeholder="0.00" class="input pl-7" />
                </div>
                <p v-if="form.errors.budget_amount" class="mt-1 text-xs text-red-500">{{ form.errors.budget_amount }}</p>
            </div>

            <div v-if="category.type === 'income'">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Expected Monthly Amount</label>
                <div class="relative">
                    <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-violet-400 select-none pointer-events-none">৳</span>
                    <input v-model="form.monthly_amount" type="number" step="0.01" min="0" required placeholder="0.00" class="input pl-7" />
                </div>
                <p v-if="form.errors.monthly_amount" class="mt-1 text-xs text-red-500">{{ form.errors.monthly_amount }}</p>
            </div>

            <template v-if="category.type === 'loan'">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Total Loan Amount</label>
                    <div class="relative">
                        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-violet-400 select-none pointer-events-none">৳</span>
                        <input v-model="form.loan_amount" type="number" step="0.01" min="0" required placeholder="0.00" class="input pl-7" />
                    </div>
                    <p v-if="form.errors.loan_amount" class="mt-1 text-xs text-red-500">{{ form.errors.loan_amount }}</p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Monthly EMI</label>
                    <div class="relative">
                        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-violet-400 select-none pointer-events-none">৳</span>
                        <input v-model="form.emi_amount" type="number" step="0.01" min="0" required placeholder="0.00" class="input pl-7" />
                    </div>
                    <p v-if="form.errors.emi_amount" class="mt-1 text-xs text-red-500">{{ form.errors.emi_amount }}</p>
                </div>
            </template>

            <template v-if="category.type === 'saving'">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Monthly Contribution</label>
                    <div class="relative">
                        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-violet-400 select-none pointer-events-none">৳</span>
                        <input v-model="form.monthly_amount" type="number" step="0.01" min="0" required placeholder="0.00" class="input pl-7" />
                    </div>
                    <p v-if="form.errors.monthly_amount" class="mt-1 text-xs text-red-500">{{ form.errors.monthly_amount }}</p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Target Amount <span class="text-gray-400">(optional)</span></label>
                    <div class="relative">
                        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-violet-400 select-none pointer-events-none">৳</span>
                        <input v-model="form.target_amount" type="number" step="0.01" min="0" placeholder="0.00" class="input pl-7" />
                    </div>
                    <p v-if="form.errors.target_amount" class="mt-1 text-xs text-red-500">{{ form.errors.target_amount }}</p>
                </div>
            </template>

            <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Color</label>
                <div class="grid grid-cols-8 gap-2">
                    <button
                        v-for="c in presetColors"
                        :key="c"
                        type="button"
                        class="w-8 h-8 rounded-lg transition-all"
                        :style="{ backgroundColor: c }"
                        :class="form.color === c ? 'ring-2 ring-offset-2 ring-offset-white dark:ring-offset-coin-dark-card ring-gray-500 scale-110' : 'hover:scale-110 opacity-80 hover:opacity-100'"
                        @click="form.color = c"
                    />
                </div>
            </div>

            <button type="submit" class="btn-primary w-full py-2.5" :disabled="form.processing">
                {{ form.processing ? 'Saving…' : 'Save Changes' }}
            </button>

            <div class="border-t border-gray-100 dark:border-white/5 pt-4">
                <div v-if="!confirmingDelete">
                    <button
                        type="button"
                        class="w-full py-2.5 rounded-xl text-sm font-medium text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 transition-all"
                        @click="confirmingDelete = true"
                    >
                        Delete Category
                    </button>
                </div>
                <div v-else class="space-y-3">
                    <p class="text-sm text-gray-600 dark:text-gray-400 text-center">
                        Permanently delete <span class="font-semibold text-gray-900 dark:text-white">{{ category.name }}</span> and all its transactions?
                    </p>
                    <div class="flex gap-3">
                        <button
                            type="button"
                            class="flex-1 py-2.5 rounded-xl text-sm font-medium border border-gray-200 dark:border-white/10 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-white/5 transition-all"
                            @click="confirmingDelete = false"
                        >
                            Cancel
                        </button>
                        <button
                            type="button"
                            class="flex-1 py-2.5 rounded-xl text-sm font-medium bg-red-500 hover:bg-red-600 text-white shadow-md shadow-red-500/30 transition-all active:scale-[0.98]"
                            @click="confirmDelete"
                        >
                            Delete
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </AppModal>
</template>
