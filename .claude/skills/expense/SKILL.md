---
name: expense
description: Parse WhatsApp messages or plain text lines and create expense transactions in the database. Use when the user provides a list of expenses to log.
argument-hint: "[WhatsApp messages or plain text expense lines]"
---

Parse the following WhatsApp messages (or plain text lines) from `$ARGUMENTS` and create expense transactions.

## Step 1 — Parse input

Extract each expense as `{ item, amount, date }` from `$ARGUMENTS`.

Supported formats:
- Plain: `Chicken 400`
- WhatsApp: `[7:18 PM, 3/20/2026] Biswajit Biswas: Chicken 400`

Rules:
- `item` = the descriptive text (e.g. "Chicken", "Fish fillets")
- `amount` = the numeric value (integer or decimal)
- `date` = date from WhatsApp timestamp if present, otherwise today's date (ISO format `YYYY-MM-DD`)
- Skip lines that don't contain a recognisable item + amount pair
- **Refine the title** — fix typos, expand abbreviations, and improve clarity (e.g. "Vegitables" → "Vegetables", "Mango 2 kg" → "Mango (2 kg)", "Recharge lokkhi moni" → "Recharge - Lokkhi Moni"). Keep it concise and human-readable.

## Step 2 — Fetch expense categories

Use the `database-query` MCP tool:

```sql
SELECT id, name FROM categories WHERE user_id = 1 AND type = 'expense' ORDER BY name
```

## Step 3 — Map each item to a category

Use the categories fetched in Step 2 as the **only valid options**. For each item:

1. Read every category name carefully and consider what types of expenses it would cover.
2. Pick the category whose meaning best matches the item's real-world purpose.
3. If no category is a clear, natural fit, assign the fallback category (e.g. "Miscellaneous") — do **not** force an item into an unrelated category just to avoid the fallback.

Every item must be mapped to one of the fetched category IDs.

## Step 4 — Show confirmation table

Display a markdown table with a total footer row:

| # | Item | Amount | Category | Date |
|---|------|--------|----------|------|
| 1 | Chicken | 400 | Groceries | 2026-03-20 |
| 2 | Fish | 200 | Groceries | 2026-03-20 |
| | **Total** | **600** | | |

Then ask: **"Insert these transactions? (y/n)"**

## Step 5 — Insert on confirmation

When the user confirms, run `php artisan tinker --execute "..."` to insert all transactions in a single command using Eloquent.

Use this template (adjust for actual data):

```php
php artisan tinker --execute "
use App\Models\Transaction;
use Illuminate\Support\Str;

\$transactions = [
    ['category_id' => 3, 'amount' => 400, 'title' => 'Chicken', 'transacted_at' => '2026-03-20'],
    ['category_id' => 3, 'amount' => 200, 'title' => 'Fish', 'transacted_at' => '2026-03-20'],
];

foreach (\$transactions as \$t) {
    Transaction::create([
        'uuid'          => Str::uuid(),
        'user_id'       => 1,
        'category_id'   => \$t['category_id'],
        'type'          => 'expense',
        'amount'        => \$t['amount'],
        'title'         => \$t['title'],
        'transacted_at' => \$t['transacted_at'],
    ]);
}

echo 'Inserted ' . count(\$transactions) . ' transactions';
"
```

After inserting, confirm with the count of inserted transactions.
