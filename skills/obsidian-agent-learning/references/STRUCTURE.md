# ドキュメント分割とディレクトリ階層化

**目的**: 人間が「どこに何があるか」の知識マップを頭の中に持ちやすくする。検索に頼らず、フォルダ名を辿って目的のノートに到達できる構造を作る。

## 基本原則

1. **フォルダ = 知識の棚** — 1 フォルダは 1 つの意味的カテゴリ（分野・プロジェクト・問題群）
2. **ファイル = 1 トピック** — 1 ノートは 1 つの学び。混在したら分割
3. **深さは浅く** — ルートから葉ノートまで **最大 4 階層**（それ以上は分割しすぎ or 統合を検討）
4. **MOC は必要な集合だけ** — 共通フォーマットで管理する範囲に限定して `_index.md` を置く（詳細は下記）
5. **Agent フォルダは作らない** — エージェント由来は `source: agent` / `tags: agent-learning` で識別
6. **既存構造を尊重** — vault に既にあるフォルダ・命名規則を優先。無理に作り直さない

---

## ディレクトリ階層モデル

```
Tech/                                   # 技術学習のルート
└── {category}/                         # L0: 分野カテゴリ（人間が読める名前）
    └── {subtopic}/                     # L1: サブトピック（任意）
        ├── {note}.md                   # 葉ノート
        └── {collection}/               # 共通フォーマットの集合（任意）
            ├── _index.md               # MOC（条件を満たす場合のみ）
            └── step1.md
```

**`Tech/Agent/` は作らない。** 学習内容は `Tech/{category}/` に配置し、エージェント由来は metadata で区別する。

---

## Tech/ カテゴリマップ

`domains` プレフィックスまたは内容から L0 カテゴリを決定する:

| `domains` | L0 カテゴリフォルダ | 例 |
|-----------|-------------------|-----|
| `DSA:*` | `Algorithm & Data Structure/` | `Tech/Algorithm & Data Structure/Search/Lower Bound.md` |
| LeetCode 問題 | `LeetCode/` | `Tech/LeetCode/35_searchInsertPosition/step1.md` |
| `SYS:*` | `Systems/` | `Tech/Systems/Memory-Management/G1GC Tuning.md` |
| `FPL:*` | `Programming Languages/` | `Tech/Programming Languages/Ruby/Method Lookup.md` |
| `NET:*` | `Networking/` | `Tech/Networking/TCP/Handshakes.md` |
| `ARCH:*` | `Software Architecture/` | `Tech/Software Architecture/SRP.md` |
| `PERF:*` | `Performance/` | `Tech/Performance/Latency/INP.md` |
| `TOOL:*` | `Tools/` | `Tech/Tools/Cursor/Agent Skills.md` |
| session-summary | `Sessions/YYYY-MM/` | `Tech/Sessions/2026-05/2026-05-29 grind75.md` |

### L1 サブトピック（任意）

`domains` の `"DSA: Search"` → `Algorithm & Data Structure/Search/`

- vault に既存ノートがフラット配置（カテゴリ直下）ならそれに合わせる（例: `Algorithm & Data Structure/B-tree.md`）
- サブトピックが増えてきたら `Search/` 等の L1 を追加

### 種別ルート（`type` × 配置）

| `type` | 配置 | 例 |
|--------|------|-----|
| `concept`, `debugging`, `decision`, `snippet` | `Tech/{カテゴリ}/` | `Tech/Algorithm & Data Structure/...` |
| `algorithm` (LeetCode) | `Tech/LeetCode/` | `Tech/LeetCode/35_searchInsertPosition/` |
| `session-summary` | `Tech/Sessions/YYYY-MM/` | `Tech/Sessions/2026-05/` |
| `blog-draft` | `Tech/Zenn/` | `Tech/Zenn/...` |
| `workflow` | `Memo/` | `Memo/cursor/...` |

LeetCode 固有 frontmatter: `Tech/LeetCode/_default-metadata.md` を参照。

### L3 プロジェクト文脈（任意）

会話が特定プロジェクトに紐づく場合のみ追加:

```
Tech/LeetCode/35_searchInsertPosition/step1.md
Tech/Algorithm & Data Structure/Search/Lower Bound.md
Memo/cursor/agent-skills/Obsidian Learning Skill.md
```

命名: kebab-case または既存 vault の慣習に合わせる（leetcode は `{番号}_{camelCase}` 可）。

---

## 分割の判断基準

### 分割する（複数ファイル + 必要ならサブディレクトリ）

| 条件 | 例 | アクション |
|------|-----|-----------|
| 独立したトピックが **2 つ以上** | 二分探索 + 単調スタック | トピックごとにファイル分割 |
| 1 ノートが **150 行超**（コード除く） | 長いセッション要約 | セクション単位で分割 |
| **`type` が混在** | 概念説明 + デバッグ手順 | type ごとにファイル・フォルダを分ける |
| **`domains` が異なる** | DSA + SYS | ドメインフォルダを分ける |
| **時系列ステップ** | step1, step2, step3 | サブディレクトリ + 各 step をファイル化 + `_index.md` |
| **共通フォーマットの系列** | 同一テンプレートの複数ノート | 集合フォルダ + `_index.md` + 子ノート |

### 分割しない（1 ファイル維持）

| 条件 | 理由 |
|------|------|
| 1 トピックで 150 行未満 | 細分化すると逆に探しにくい |
| 密接に結合（片方が無意味） | 例: 問題文 + その解法 |
| 追記のみ（既存ノートの更新） | 履歴は同一ファイル内 `## YYYY-MM-DD 追記` |

### 分割後のリンク構造

**MOC あり（共通フォーマットの集合）:**

```
Tech/LeetCode/35_searchInsertPosition/
├── _index.md
├── step1.md
└── step2.md
```

**MOC なし（独立ノートが同じカテゴリに並ぶ）:**

```
Tech/Algorithm & Data Structure/Search/
├── Lower Bound.md
└── Binary Search Loop Invariant.md
```

- MOC がある場合 → `_index.md` の `children` に子ノートを列挙
- MOC がない場合 → 兄弟ノート同士を `related` でリンク（`_index` は作らない）
- 上位フォルダ（カテゴリ直下等）に MOC を**自動作成しない**

---

## `_index.md`（MOC: Map of Content）

**デフォルトでは作らない。** ある程度の範囲で**共通フォーマットのドキュメント群**を管理するときだけ作成する。

### MOC を作る条件（すべてまたは強い理由で満たす）

| 条件 | 例 |
|------|-----|
| **同一フォーマット** | step1/step2/step3、同一テンプレートの session-summary 群 |
| **明確な集合単位** | 1 LeetCode 問題の学習ステップ、1 プロジェクトの調査系列 |
| **件数** | 3 件以上、または 2 件でも時系列・ステップ系列など格式が統一されている |
| **人間のマップとして意味がある** | フォルダを開いたとき「何から読むか」が一目で分かる |

### MOC を作らない

| 条件 | 理由 |
|------|------|
| 独立トピックが同じ分野フォルダに並ぶだけ | フォルダ名 + `related` で十分 |
| 子ノート 2 件だがフォーマットが異なる | 集合として管理する意味が薄い |
| 組織用の中間ディレクトリ（`Search/` 等） | 階層の整理目的であり MOC 不要 |
| 子ノート 1 件のみ | 地図になる中身がない |
| ユーザーが MOC を求めていない単発保存 | 過剰なメタファイル |

### 代表例

| パス | MOC | 理由 |
|------|-----|------|
| `Tech/LeetCode/35_searchInsertPosition/` | **作る** | step 系列、同一フォーマット |
| `Tech/Sessions/2026-05/` | **作る**（3件以上） | 月次 session-summary 群 |
| `Tech/Algorithm & Data Structure/Search/` | **作らない** | 独立概念ノートの置き場 |
| `Tech/Algorithm & Data Structure/` | **作らない** | カテゴリ直下の独立ノート |
| `Memo/cursor/agent-skills/` | **作らない** | 単発 or 少数の workflow ノート |

### 既存 MOC がある場合

- 同じ集合に子ノートを追加 → **既存 `_index.md` を更新**
- 新規 `_index.md` は作らない（既存がなければ上記条件を再判定）

```yaml
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: index
topic: "Algorithm & Data Structure — Search"
tags:
  - agent-learning
  - moc
domains:
  - "DSA: Search"
source: agent
agent: cursor
index: true
category: "Algorithm & Data Structure/Search"
children:
  - "[[Lower Bound]]"
  - "[[Search Insert Position]]"
---
```

本文テンプレート: [TEMPLATES.md の index（MOC）](TEMPLATES.md)

### MOC 更新ルール

- 既存 `_index.md` への子ノート追加時 → `children` と本文一覧を更新
- 集合の子ノートが 0 件になった → `_index.md` を削除してよい
- フォルダ名変更時 → `category` と wikilink を一括更新
- **上位階層の `_index.md` を連鎖的に作ったり更新したりしない**

---

## ディレクトリ作成手順

保存時、パスが存在しなければ **再帰的に作成** する:

```bash
eval "$( "$SKILL_DIR/scripts/resolve-config.sh" )"
mkdir -p "$VAULT/Tech/Algorithm & Data Structure/Search"
```

### 作成フロー

1. 内容から `Tech/{カテゴリ}/` を決定（カテゴリマップ参照）
2. 必要なら L1 サブトピック、`project` 文脈の L2 を追加
3. `mkdir -p` でパス作成
4. MOC 作成条件を満たす場合のみ `_index.md` を作成（既存があれば更新）
5. 葉ノートを書き込み（`source: agent`, `tags: [agent-learning]` を付与）
6. MOC がない場合は兄弟ノート間を `related` でリンク

### パス決定の例

| 会話内容 | 生成パス |
|---------|---------|
| LeetCode 35 step1〜3 | `Tech/LeetCode/35_searchInsertPosition/step{N}.md` + `_index.md` |
| 二分探索 lower bound 一般 | `Tech/Algorithm & Data Structure/Search/Lower Bound.md`（MOC なし） |
| Cursor スキル作成 | `Memo/cursor/agent-skills/Obsidian Agent Learning Skill.md` |
| JVM G1GC チューニング調査 | `Tech/Systems/Memory-Management/G1GC Tuning.md` |
| 2026-05 セッション要約 | `Tech/Sessions/2026-05/2026-05-29 grind75.md` |

---

## Tech/Zenn/ — 技術ブログ用ネタ置き場

`Tech/Zenn/` は公開記事（Zenn 等）の**ネタ・構成・下書き素材**専用。エージェント学習記録のデフォルト保存先ではない。

### 使い分け

| 観点 | `Tech/{カテゴリ}/` | `Tech/Zenn/` |
|------|--------------|--------------|
| 目的 | 学習・定着・復習 | ブログ執筆・公開 |
| 読者 | 未来の自分 | 不特定の読者 |
| 文体 | メモ・自分の言葉 | 記事構成・説得・例示 |
| 復習 | `next_review` あり | 不要（`writing_status` で管理） |

### 保存条件

`Tech/Zenn/` に保存してよいのは次の場合のみ:

- ユーザーが「ブログネタに」「Zenn 用に」等と**明示**した
- `type: blog-draft` として保存することが合意された

それ以外は `Tech/{カテゴリ}/` に保存する。

### 学習 → Zenn の昇格

1. `Tech/{カテゴリ}/` に学習記録を残す（デフォルト）
2. ユーザーがブログ化を希望 → `Tech/Zenn/` に `blog-draft` を新規作成
3. 双方向リンク: 学習側 `related: "[[Zenn/Monotonic Stack]]"`、Zenn 側 `related: "[[Algorithm & Data Structure/...]]"`

`Tech/Zenn/` 既存ファイル（フラット配置）はそのまま維持。新規もフラットでよい（ブログネタは件数が少ない想定）。

---

## Daily/ — デイリーノート

`Daily/` は日次の個人メモ・振り返り用。**エージェント学習記録の保存先ではない。**

### ルール

- 学習ノートの本体は `Tech/{カテゴリ}/` に保存する
- `Daily/` への書き込みはユーザーが「デイリーノートにリンクして」等と**明示した場合のみ**
- 明示がない限り `Daily/` には触らない（リンク追記もしない）
- ファイルが存在しない場合は作成せず、ユーザーに確認する

---

## 既存 vault との統合

| 既存パス | 方針 |
|---------|------|
| `Tech/Algorithm & Data Structure/` | DSA 学習のデフォルト配置。既存フラット配置を尊重 |
| `Tech/LeetCode/` | LeetCode 専用。`_default-metadata.md` に従う |
| `Tech/Agent/`（レガシー） | **新規作成しない**。既存ファイルは `related` でリンク可。移動はユーザー確認 |
| `Daily/*.md` | 日次の個人メモ。**学習記録は置かない**。ユーザー明示時のみ wikilink 追記 |
| `Tech/Zenn/*.md` | 技術ブログ用ネタ置き場。**学習記録は置かない**。ユーザー明示時のみ `blog-draft` として追加 |
| `Tech/daily−quiz/*.md` | 形式が異なるため触らない。リンクのみ張る |
| `Articles/`, `Books/` | 外部クリップ用。学習ノートから `related` でリンク |

既存フラットファイルを無理に移動しない。移動する場合はユーザーに確認する。

---

## 命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| ディレクトリ（L0） | 人間が読めるカテゴリ名 | `Algorithm & Data Structure`, `Systems` |
| ディレクトリ（L1） | サブトピック | `Search`, `Memory-Management` |
| LeetCode | `Tech/LeetCode/{番号}_{camelCase}/` | `35_searchInsertPosition/` |
| 葉ノート | 具体的名詞句。`Untitled` 禁止 | `Lower Bound.md` |
| MOC | 固定 `_index.md` | `_index.md` |
| 時系列 | `step{N}.md` または `YYYY-MM-DD {topic}.md` | `step1.md` |

---

## 品質チェック（構造）

- [ ] 葉ノートまでの深さが 4 階層以内
- [ ] 1 ノート 1 トピック（150 行超なら分割検討済み）
- [ ] 不要な `_index.md` を作っていない（条件を満たす集合にのみ MOC あり）
- [ ] 既存 `_index.md` の `children` が実ファイルと一致
- [ ] `category` が frontmatter と実パスで一致
- [ ] `related` が最大 5 件で、vault 検索に基づく高関連ノートのみ（[RELATED.md](RELATED.md)）
- [ ] 兄弟ノート間の `related` も同基準で選定済み
- [ ] `Tech/Agent/` に新規ファイルを作っていない
- [ ] エージェント由来ノートに `source: agent` と `tags: agent-learning` がある
