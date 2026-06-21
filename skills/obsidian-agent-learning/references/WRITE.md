# 書き込みプロトコル（ロック必須）

Obsidian vault への外部書き込みで `ファイル (N).md` 競合コピーが量産されるのを防ぐ。**すべての vault 書き込みは本プロトコルに従う。**

## 背景 — なぜ `(N)` コピーが増えるか

`GitHub PR Discussion Insights (1).md` のような `(N)` 付きファイルは、**エージェントが意図的に付けた名前ではない**。macOS が「同名ファイルが既にある」と判断したときに、古い版を退避する際の**汎用命名**（iCloud 専用ではない）。

### 主因: Obsidian 起動中の外部 Write

```
Cursor エージェントが vault へ Write（上書き）
        ↓
Obsidian が同ファイルを監視／バッファ保持中
        ↓
macOS がディスク上の旧版を ファイル (N).md として退避
        ↓
本体は新内容に更新されるが、(1)〜(N) がフォルダに残る
```

- Obsidian を**開いたまま**エージェントが保存すると起きやすい
- 同一パスへの**繰り返し上書き**（既存確認なし）で `(N)` が増殖しやすい
- vault の**一括移動・振り分け中**（Write / Delete 連発）でも同様

### 副因（参考）

| 要因 | 備考 |
|------|------|
| **Obsidian Sync** | 別デバイスとの同時編集。競合ファイル名は通常 `*.sync-conflict-*` だが、同期中のローカル変更と組み合わさると重複の温床になる |
| **過去のクラウド同期** | 以前 iCloud 等で `Documents` を同期していた名残が残ることはある（現在オフでも） |
| **Finder 手動複製** | `Cmd+D` や「両方を保持」でのコピー |

### 本プロトコルで防ぐこと

1. **存在確認** — `UPDATE` なら同一路径を更新（別パスに同名を作らない）
2. **ロック** — 同一 `TARGET` への並行書き込みを直列化
3. **Write ツール禁止** — Cursor Write ではなく `vault-write.sh` 経由の原子 replace
4. **`(N)` パス拒否** — 競合コピーへ書き込まない

**運用推奨**: エージェント保存時は Obsidian を閉じるか、対象ノートを開かない。

---

## 原則

| ルール | 内容 |
|--------|------|
| **Write ツール単体禁止** | Cursor の Write ツールはロックを取れない。**必ず `vault-write.sh` 経由** |
| **1 パス = 1 ファイル** | 同名の別パスを新規作成しない。既存があれば **同一路径を更新** |
| **`(N)` コピー禁止** | `GitHub PR Discussion Insights (3).md` 等へは書き込まない。`(N)` なしの正規パスへ |
| **ロック内で read→write** | ロック取得後に最新内容を読み、マージしてから 1 回で書き込む |

## ヘルパースクリプト

```text
<skill-dir>/scripts/resolve-config.sh   # VAULT / SCRIPT を export（eval 経由推奨）
<skill-dir>/scripts/vault-write.sh      # ロック付き書き込み
```

```bash
eval "$( "<skill-dir>/scripts/resolve-config.sh" )"
TARGET="$VAULT/Tech/LeetCode/35_searchInsertPosition/GitHub PR Discussion Insights.md"
```

---

## Step A: 書き込み前チェック（必須）

決定した `TARGET` 絶対パスに対し、**書き込み前に必ず**実行する。

### A-1. 正規パスの存在確認

```bash
"$SCRIPT" --check "$TARGET"
# → NEW  または UPDATE
```

- **UPDATE** → 新規作成しない。既存ファイルの **更新** モード
- **NEW** → 新規作成（同名ファイルがそのパスにない）

### A-2. 競合コピーの検出（同ディレクトリ）

```bash
DIR="$(dirname "$TARGET")"
STEM="$(basename "$TARGET" .md)"
find "$DIR" -maxdepth 1 -name "${STEM} ([0-9]*).md" 2>/dev/null
```

ヒットした `(N)` ファイルは **削除・更新しない**（ユーザー判断）。これらは Obsidian + 外部 Write の競合退避コピーであることが多い。書き込み先は常に `(N)` なしの `TARGET`。

### A-3. 意味的な重複検索（Step 2 補完）

キーワード検索に加え、LeetCode では次も確認:

```bash
# 問題番号・フォルダ
ls -d "$VAULT/Tech/LeetCode/"*35* 2>/dev/null
rg -l "leetcode_id: 35" "$VAULT/Tech/LeetCode/" --glob "*.md"

# ルート MOC に載っているフラット配置
rg "121_Best Time" "$VAULT/Tech/LeetCode/_index.md"
```

フラット配置（例: `121_Best Time To Buy And Sell Stock.md`）が `_index.md` にある場合、サブフォルダを新設せず **そのパスを TARGET** とする。

### A-4. 参照専用ファイル

次は **Read のみ**。内容コピーの書き込み先にしない:

- `Tech/LeetCode/_default-metadata.md`
- `Tech/LeetCode/grind75-categories.md`
- `Tech/LeetCode/_index.md`（MOC 行の追加・更新は例外としてロック付き更新可）

---

## Step B: ロック取得 → 読み取り → 書き込み

**1 つのシェル invocation** で完結させる（ロックを跨いだ別コマンドに分割しない）。

### 新規（NEW）

```bash
"$SCRIPT" "$TARGET" <<'NOTE_EOF'
---
created: 2026-06-21
...
---

## TL;DR
...
NOTE_EOF
```

### 更新（UPDATE）

1. ロック付きシェル内で **最新内容を読む**
2. `created` を維持、`updated` / `next_review` を更新
3. 末尾に `## YYYY-MM-DD 追記` を追加するか、該当セクションをマージ
4. **マージ後の全文** を heredoc で `vault-write.sh` に渡す

```bash
TARGET="$VAULT/Tech/..."
"$SCRIPT" "$TARGET" <<'NOTE_EOF'
（Read で取得した既存 frontmatter の created を維持したうえでの、マージ済み全文）
NOTE_EOF
```

更新時に **Read ツールだけ使って Write ツールで上書き** してはならない。

### Daily 追記（ユーザー明示時のみ）

```bash
TARGET="$VAULT/Daily/2026-06-21.md"
"$SCRIPT" --check "$TARGET"   # 存在しなければユーザーに確認（作成しない）
# 既存全文を読み、末尾 1 行追記した全文を vault-write.sh へ
```

---

## ロックの実装

macOS では `flock` が使えないため **`mkdir` による排他ロック**:

```text
$VAULT/.agent-locks/<target-path-hash>/
```

- 取得: `mkdir` 成功まで最大 60 秒リトライ（1 秒間隔）
- 解放: 書き込み完了後 `rmdir`（`vault-write.sh` が `trap` で自動実行）
- 同一 `TARGET` への並行書き込みを直列化

---

## 複数ファイルを書く場合

**ファイルごとに** `vault-write.sh` を 1 回ずつ呼ぶ（各 TARGET で独立ロック）。

推奨順:

1. 葉ノート（`NEW` / `UPDATE`）
2. 集合 `_index.md`（MOC 条件を満たす場合のみ）
3. `Daily/` への 1 行追記（明示時のみ）

---

## 品質チェック（書き込み）

- [ ] `--check` を実行し `NEW` / `UPDATE` を記録した
- [ ] `TARGET` に `(N)` サフィックスがない
- [ ] UPDATE 時はロック付きフローで既存 `created` を保持した
- [ ] Write ツールを vault パスに対して使っていない
- [ ] 同名の別パスに新規ファイルを作っていない
