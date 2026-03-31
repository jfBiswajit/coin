<script setup lang="ts">
import AppModal from '@/Components/AppModal.vue';
import ColorPickerInput from '@/Components/ColorPickerInput.vue';
import { defaultColor } from '@/constants/colors';
import { useForm } from '@inertiajs/vue3';
import { watch } from 'vue';

type CategoryType = 'expense' | 'income' | 'saving' | 'loan';

const props = defineProps<{ show: boolean; defaultType: CategoryType }>();
const emit = defineEmits<{ close: [] }>();


const form = useForm({
    name: '', type: 'expense' as CategoryType, color: defaultColor, icon: 'circle',
    budget_amount: '',
    loan_amount: '', emi_amount: '',
    monthly_amount: '', target_amount: '',
});

watch(() => props.show, (val) => {
    if (val) {
        form.reset();
        form.type = props.defaultType;
        form.color = defaultColor;
    }
});

const submit = () => {
    form.post('/categories', {
        preserveScroll: true,
        onSuccess: () => emit('close'),
    });
};
</script>

<template>
    <AppModal v-if="show" title="New Category" @close="emit('close')">
        <form class="space-y-5" @submit.prevent="submit">

            <div class="flex items-center gap-4 p-4 rounded-xl bg-gray-50 dark:bg-white/5">
                <div
                    class="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg flex-shrink-0"
                    :style="{ backgroundColor: form.color, boxShadow: `0 4px 14px ${form.color}40` }"
                >
                    {{ form.name ? form.name[0].toUpperCase() : '?' }}
                </div>
                <div>
                    <div class="font-semibold text-gray-900 dark:text-white">{{ form.name || 'Category name' }}</div>
                    <div class="text-xs text-gray-400 capitalize">{{ form.type }}</div>
                </div>
            </div>

            <div class="grid grid-cols-4 rounded-xl overflow-hidden border border-gray-200 dark:border-white/10">
                <button type="button"
                    class="py-2 text-xs font-medium transition-all"
                    :class="form.type === 'expense' ? 'bg-red-500 text-white' : 'bg-white dark:bg-white/5 text-gray-600 dark:text-gray-400'"
                    @click="form.type = 'expense'"
                >Expense</button>
                <button type="button"
                    class="py-2 text-xs font-medium transition-all"
                    :class="form.type === 'income' ? 'bg-emerald-500 text-white' : 'bg-white dark:bg-white/5 text-gray-600 dark:text-gray-400'"
                    @click="form.type = 'income'"
                >Income</button>
                <button type="button"
                    class="py-2 text-xs font-medium transition-all"
                    :class="form.type === 'saving' ? 'bg-blue-500 text-white' : 'bg-white dark:bg-white/5 text-gray-600 dark:text-gray-400'"
                    @click="form.type = 'saving'"
                >Saving</button>
                <button type="button"
                    class="py-2 text-xs font-medium transition-all"
                    :class="form.type === 'loan' ? 'bg-orange-500 text-white' : 'bg-white dark:bg-white/5 text-gray-600 dark:text-gray-400'"
                    @click="form.type = 'loan'"
                >Loan</button>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
                <input v-model="form.name" type="text" required class="input" placeholder="e.g. Groceries" />
                <p v-if="form.errors.name" class="mt-1 text-xs text-red-500">{{ form.errors.name }}</p>
            </div>

            <div v-if="form.type === 'expense'">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Monthly Budget</label>
                <div class="relative">
                    <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-violet-400 select-none pointer-events-none">৳</span>
                    <input v-model="form.budget_amount" type="number" step="0.01" min="0" required placeholder="0.00" class="input pl-7" />
                </div>
                <p v-if="form.errors.budget_amount" class="mt-1 text-xs text-red-500">{{ form.errors.budget_amount }}</p>
            </div>

            <div v-if="form.type === 'income'">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Expected Monthly Amount</label>
                <div class="relative">
                    <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-violet-400 select-none pointer-events-none">৳</span>
                    <input v-model="form.monthly_amount" type="number" step="0.01" min="0" required placeholder="0.00" class="input pl-7" />
                </div>
                <p v-if="form.errors.monthly_amount" class="mt-1 text-xs text-red-500">{{ form.errors.monthly_amount }}</p>
            </div>

            <template v-if="form.type === 'loan'">
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

            <template v-if="form.type === 'saving'">
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
                <ColorPickerInput v-model="form.color" />
            </div>

            <button type="submit" class="btn-primary w-full py-2.5" :disabled="form.processing">
                {{ form.processing ? 'Adding…' : 'Add Category' }}
            </button>
        </form>
    </AppModal>
</template>
