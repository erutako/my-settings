# `related` リンクの選定ルール

`related` は**一緒に読むと理解が深まり、記憶の定着に役立つ**既存ノートへの wikilink。漫然と張らない。

## 基本ルール

| ルール | 内容 |
|--------|------|
| **上限** | **最大 5 件**（`prerequisites` は別枠） |
| **下限** | 関連度の高いものが 0 件なら空でよい。5 件に満たす必要はない |
| **検索必須** | 付与前に vault を検索し、既存ノートから選ぶ |
| **双方向** | 新規ノートの `related` に入れる。既存ノートへの逆リンク追記は任意（関連度が高い場合のみ） |

---

## 選定ワークフロー

### 1. vault を検索

保存するノートの `topic`、`tags`、`domains`、キーワードで vault 全体を検索する:

```bash
eval "$( "$SKILL_DIR/scripts/resolve-config.sh" )"

# topic・概念キーワード
rg -l "binary search|lower bound" "$VAULT/Tech/" --glob "*.md"

# 同一 domain
rg -l "DSA: Search" "$VAULT/Tech/" --glob "*.md"

# 同一 LeetCode 問題群
rg -l "search insert|35_" "$VAULT/Tech/LeetCode/" --glob "*.md"

# 同プロジェクト
rg -l "grind75" "$VAULT/" --glob "*.md"
```

Glob や SemanticSearch も併用してよい。候補は 10 件程度まで広げ、関連度で絞る。

### 2. 関連度でスコアリング

候補を次の優先度で評価し、**上位 5 件まで**選ぶ:

| 優先度 | 基準 | 例 |
|--------|------|-----|
| 1 | **前提知識** — 読む前に理解しておくとよい | 二分探索の基礎 → lower bound 解法 |
| 2 | **同一パターン** — 同じ技法・データ構造の別問題 | 単調スタック ↔ 次に大きい要素 |
| 3 | **対比・発展** — 比較することで理解が深まる | linear search vs binary search |
| 4 | **同一 domain** — 同分野で知識を束ねる | `DSA: Search` 内の他ノート |
| 5 | **同一プロジェクト文脈** — 同じ学習系列 | grind75 の近い問題 |
| 6 | **実践・応用** — 本番・面接でセットで使う知識 | 計算量分析 + 二分探索 |

### 3. 除外するもの

- キーワードが一致するだけで内容が無関係なノート
- `Daily/`、`Articles/`（クリップ）、`Books/` — **強い関連がある場合のみ**（通常は外す）
- 自分自身（保存中のノート）
- `_index.md` — MOC は `parent` / `children` でリンク（`related` に入れない）
- 関連度が低いノートを 5 件にするための埋め草

### 4. 記憶定着の観点

選ぶリンクは次の問いに答えるものを優先する:

- 「この概念の**前提**は何か？」→ `prerequisites` または `related`
- 「この技法は**他どこ**で使えるか？」
- 「**似ているが違う**概念は何か？」（混同防止）
- 「この問題と**セット**で覚えるべきことは？」

**知識の枝を 1 本伸ばす**イメージで選ぶ。無関係なノートへのリンクはグラフをノイズ化するだけ。

---

## frontmatter への書き方

```yaml
related:
  - "[[Binary Search Basics]]"
  - "[[35_searchInsertPosition/step2]]"
  - "[[121_Best Time To Buy And Sell Stock]]"
prerequisites:
  - "[[Binary Search Basics]]"   # 前提は prerequisites に分離可
```

- `related` と `prerequisites` で同一ノートを重複させない（前提は `prerequisites` 優先）
- wikilink は Obsidian で解決できるファイル名・パスを使う
- 5 件超の候補がある場合は関連度上位 5 件のみ残す

---

## 本文の「関連」セクション

frontmatter の `related` と対応させ、本文末尾にも簡潔な一覧を置く:

```markdown
## 関連

- [[Binary Search Basics]] — 前提概念
- [[35_searchInsertPosition/step2]] — 同一問題の次ステップ
```

各リンクに**1 行でなぜ関連するか**を添える（定着のため）。

---

## 更新時

既存ノートを更新する場合:

- 新たな関連が見つかれば `related` を見直す
- 5 件を超えたら関連度の低いものから外す
- 古くなったリンク（内容が obsolete）は削除する
