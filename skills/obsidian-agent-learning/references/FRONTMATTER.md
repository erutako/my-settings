# Obsidian Frontmatter スキーマ

エージェント学習ノート用 YAML frontmatter の定義。学習効率と知識定着を最大化するため、**時間軸・分類・学習状態・検索** の 4 軸で設計している。

## 設計思想

| 軸 | 目的 | 主なフィールド |
|----|------|----------------|
| 時間軸 | 鮮度管理・間隔反復 | `created`, `updated`, `next_review` |
| 分類 | 検索・グラフビュー | `type`, `topic`, `tags`, `domains` |
| 学習状態 | 定着度の可視化 | `mastery`, `confidence` |
| 検索・関連 | 知識ネットワーク | `aliases`, `related`, `prerequisites` |
| 階層・地図 | フォルダ構造の把握 | `category`, `index`, `children`, `parent` |

---

## 必須フィールド

```yaml
---
created: 2026-05-29          # 初回作成日 (YYYY-MM-DD)
updated: 2026-05-29          # 最終更新日 (YYYY-MM-DD)
type: concept                # ノート種別（下表参照）
topic: "Binary Search Lower Bound"  # 主題（1 行、検索キー）
tags:
  - agent-learning           # エージェント由来ノートは必須
  - algorithm
mastery: learning            # 理解度（下表参照）
source: agent                # 情報源（下表参照）
---
```

---

## 推奨フィールド

```yaml
---
# 分類の精緻化
domains:
  - "DSA: Search"            # 知識領域（daily-quiz 形式に合わせる）
languages:
  - python
tools:
  - cursor

# 学習状態
confidence: medium           # low | medium | high
next_review: 2026-06-05      # 次回レビュー推奨日（間隔反復）

# 出所・再現性
agent: cursor                # cursor | claude | copilot | other
project: "leetcode/grind75"  # 関連リポジトリ・プロジェクト（任意）
context: "35 Search Insert Position の解法議論"  # 会話の文脈（任意）

# 検索・関連
aliases:
  - "lower bound"
related:
  - "[[121_Best Time To Buy And Sell Stock]]"
prerequisites:
  - "[[Binary Search]]"

# LeetCode 固有（該当時のみ）
leetcode_id: 35
leetcode_url: "https://leetcode.com/problems/search-insert-position/"

# 階層・地図（分割・ディレクトリ化時）
category: "Algorithm & Data Structure/Search"  # Tech/ 以下の相対パス
index: false                    # true = _index.md（MOC）
parent: "[[_index]]"            # 親 MOC への wikilink（葉ノートのみ）
children:                       # 子ノート一覧（_index.md のみ）
  - "[[Lower Bound]]"
---
```

---

## フィールド詳細

### 時間軸

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `created` | date | 初回作成日。新規作成時のみ設定。更新時は変更しない |
| `updated` | date | 最終更新日。追記・修正のたびに当日に更新 |
| `next_review` | date | 復習推奨日。初回: created + 3日、2回目: +7日、3回目: +14日、以降: +30日 |

`next_review` の計算ルール:

| `mastery` 更新回数 | 間隔 |
|-------------------|------|
| 初回 capture | +3 日 |
| 1 回目 review 後 | +7 日 |
| 2 回目 review 後 | +14 日 |
| 3 回目以降 | +30 日 |

レビュー時は `mastery` を見直し、`updated` と `next_review` を更新する。

### 分類

| フィールド | 型 | 値 |
|-----------|-----|-----|
| `type` | enum | `concept`, `algorithm`, `debugging`, `workflow`, `decision`, `snippet`, `session-summary`, `index`, `blog-draft` |
| `topic` | string | 主題。ファイル名と一致させなくてよいが、検索しやすい具体名 |
| `tags` | list | Obsidian タグ。`agent-learning` は必須。技術タグを 1〜4 個追加 |
| `domains` | list | 知識領域。既存 vault の `Tech/daily−quiz/` 形式 `[分野: サブ分野]` を推奨 |
| `languages` | list | 言及したプログラミング言語 |
| `tools` | list | 言及したツール・フレームワーク |

#### `type` 一覧

| 値 | 使う場面 |
|----|---------|
| `concept` | 原理・用語・パターンの理解 |
| `algorithm` | 解法・計算量・データ構造 |
| `debugging` | エラー調査・原因特定・修正 |
| `workflow` | 手順・設定・CI/CD・運用 |
| `decision` | 設計選択とトレードオフ |
| `snippet` | コピペ可能なコード・コマンド |
| `session-summary` | 1 会話全体の要約 |
| `index` | フォルダ MOC（`_index.md`）。共通フォーマット集合の地図。条件を満たす場合のみ |
| `blog-draft` | 技術ブログ（Zenn 等）用ネタ・下書き。`Tech/Zenn/` 専用。`writing_status` で執筆進捗を管理 |

#### `tags` 命名規則

- 小文字、ハイフン区切り: `binary-search`, `time-complexity`
- エージェント由来: 必ず `agent-learning`
- 技術スタック: `python`, `ruby`, `javascript`, `jvm`, `gc`
- 用途: `interview-prep`, `production`, `leetcode`

#### `domains` 例（既存 vault との整合）

```
DSA: Search
DSA: Dynamic Programming
FPL: Programming Languages
SYS: Operating Systems
SYS: Memory Management
NET: Protocols
ARCH: Software Architecture
PERF: Performance
```

### 学習状態

| フィールド | 型 | 値 | 説明 |
|-----------|-----|-----|------|
| `mastery` | enum | `unknown`, `learning`, `familiar`, `mastered` | 理解度 |
| `confidence` | enum | `low`, `medium`, `high` | 説明できる自信 |

#### `mastery` 遷移ガイド

| 状態 | 基準 |
|------|------|
| `unknown` | 初めて触れた、用語だけ知った |
| `learning` | 例題は追えるが、一人で再現は不安 |
| `familiar` | 一人で説明・実装できる |
| `mastered` | 応用・教えられる・本番で使える |

新規 capture 時のデフォルト: `learning`（深い理解が確認できれば `familiar`）

### 出所・再現性

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `source` | enum | `agent`, `article`, `book`, `practice`, `interview` |
| `agent` | enum | `cursor`, `claude`, `copilot`, `other` |
| `project` | string | 関連 git リポジトリやプロジェクト名 |
| `context` | string | 会話の背景（問題番号、PR、エラー内容など） |

### 検索・関連

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `aliases` | list | 別名・略称。Obsidian 検索用 |
| `related` | list | 関連ノートへの wikilink。**最大 5 件**。vault 検索で選定 → [RELATED.md](RELATED.md) |
| `prerequisites` | list | 理解に必要な前提ノート（`related` とは重複させない） |

### LeetCode 固有（該当時のみ）

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `leetcode_id` | number | 問題番号 |
| `leetcode_url` | string | 問題 URL |

### 階層・地図

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `category` | string | `Tech/` 以下の相対パス。フォルダ名と一致（例: `Algorithm & Data Structure/Search`） |
| `index` | boolean | `true` = このファイルは `_index.md`（MOC）。`type: index` とセット |
| `parent` | string | 親 MOC への wikilink。葉ノートに設定 |
| `children` | list | 直下の子ノート wikilink 一覧。`_index.md` のみ |

`type: index` は MOC 専用。`mastery` / `next_review` は不要（MOC は復習対象外）。作成条件: [STRUCTURE.md](STRUCTURE.md)

---

## 完全例

```yaml
---
created: 2026-05-29
updated: 2026-05-29
next_review: 2026-06-01
type: algorithm
topic: "Search Insert Position — Lower Bound Binary Search"
tags:
  - agent-learning
  - binary-search
  - leetcode
domains:
  - "DSA: Search"
languages:
  - python
mastery: familiar
confidence: high
source: agent
agent: cursor
project: "leetcode/grind75"
context: "LeetCode 35 の解法と lower bound の関係"
leetcode_id: 35
leetcode_url: "https://leetcode.com/problems/search-insert-position/"
aliases:
  - "lower bound"
  - "search insert"
related:                        # 最大 5 件。vault 検索で選定
  - "[[121_Best Time To Buy And Sell Stock]]"
prerequisites: []
---
```

---

## 更新時のルール

既存ノートを更新する場合:

1. `updated` を当日に変更
2. `created` は変更しない
3. `next_review` を上記間隔ルールで再計算
4. 追記内容の前に `## YYYY-MM-DD 追記` 見出しを入れる
5. `mastery` / `confidence` が上がった場合のみ更新
