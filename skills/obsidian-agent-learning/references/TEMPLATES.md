# ノート本文テンプレート

`type` に応じてテンプレートを選ぶ。frontmatter は [FRONTMATTER.md](FRONTMATTER.md) を参照。

---

## concept（概念理解）

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
next_review: YYYY-MM-DD
type: concept
topic: ""
tags:
  - agent-learning
domains: []
mastery: learning
confidence: medium
source: agent
agent: cursor
---

## TL;DR

（1〜3 文で核心）

## 背景・疑問

（なぜこの話題が出たか。会話のきっかけ）

## 核心

（原理・定義・重要ポイント）

## 具体例

（コード、図、比較表）

## 自分の言葉で

（未来の自分向けに、教材なしで説明できる形で書く）

## 誤解していた点

| Before | After |
|--------|-------|
| | |

## 関連

- [[関連ノート]] — なぜ関連するか（1 行）
```

`related` は最大 5 件。vault 検索で選定 → [RELATED.md](RELATED.md)
```

---

## algorithm（アルゴリズム・解法）

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
next_review: YYYY-MM-DD
type: algorithm
topic: ""
tags:
  - agent-learning
  - algorithm
domains:
  - "DSA: "
languages: []
mastery: learning
confidence: medium
source: agent
agent: cursor
---

## TL;DR

（解法の一行要約 + 計算量）

## 問題

（何を解くか。LeetCode なら問題の要点）

## アプローチ

（なぜこの解法か。他の解法との比較）

## 実装

```language
# コード
```

## 計算量

| | 時間 | 空間 |
|---|------|------|
| この解法 | O() | O() |
| 代替案 | O() | O() |

## パターンとして覚える

（他の問題への転用ポイント）

## 自分の言葉で

## 関連

- [[関連ノート]]
```

---

## debugging（デバッグ・調査）

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
next_review: YYYY-MM-DD
type: debugging
topic: ""
tags:
  - agent-learning
domains: []
mastery: learning
confidence: medium
source: agent
agent: cursor
project: ""
context: ""
---

## TL;DR

（症状 → 原因 → 解決 の一行）

## 症状

（エラーメッセージ、再現手順）

## 調査過程

1. 最初の仮説:
2. 確認したこと:
3. 実際の原因:

## 解決

（修正内容・コマンド）

## 再発防止

（チェックリスト、モニタリング）

## 自分の言葉で

## 関連

- [[関連ノート]]
```

---

## workflow（手順・ワークフロー）

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
next_review: YYYY-MM-DD
type: workflow
topic: ""
tags:
  - agent-learning
tools: []
mastery: familiar
confidence: high
source: agent
agent: cursor
---

## TL;DR

## 目的

## 手順

1. 
2. 
3. 

## 注意点

## 自分の言葉で

## 関連
```

---

## decision（設計判断）

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
next_review: YYYY-MM-DD
type: decision
topic: ""
tags:
  - agent-learning
domains: []
mastery: familiar
confidence: medium
source: agent
agent: cursor
context: ""
---

## TL;DR

（選んだ案 + 理由一行）

## 背景

（何を決める必要があったか）

## 選択肢

| 案 | メリット | デメリット |
|----|---------|-----------|
| A | | |
| B | | |

## 決定

（採用案と根拠）

## トレードオフ

## 自分の言葉で

## 関連
```

---

## snippet（コード片・コマンド）

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
next_review: YYYY-MM-DD
type: snippet
topic: ""
tags:
  - agent-learning
languages: []
tools: []
mastery: familiar
confidence: high
source: agent
agent: cursor
---

## 用途

（いつ使うか）

## コード / コマンド

```language

```

## 解説

（各行の意味、注意点）

## 関連
```

---

## session-summary（セッション要約）

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
next_review: YYYY-MM-DD
type: session-summary
topic: ""
tags:
  - agent-learning
mastery: learning
confidence: medium
source: agent
agent: cursor
project: ""
context: ""
---

## TL;DR

（セッション全体の一行要約）

## 扱ったトピック

- [[ノート1]] — 
- [[ノート2]] — 

## 主要な学び

1. 
2. 
3. 

## 未解決・次回

- [ ] 

## 自分の言葉で
```

---

## index（MOC: フォルダ地図）

**共通フォーマットのドキュメント群**を管理する集合フォルダ専用。作成条件は [STRUCTURE.md](STRUCTURE.md) を参照。

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: index
topic: "DSA — Search"
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

## このフォルダについて

（1〜2 文で、このカテゴリに何が集約されているか）

## ノート一覧

| ノート | 概要 |
|--------|------|
| [[Lower Bound]] | 二分探索の lower bound 実装 |
| [[Search Insert Position]] | LeetCode 35 の解法 |

## 前提知識

- [[Binary Search Basics]]（他フォルダのノートがあればリンク）

## 関連フォルダ

- [[../_index|DSA]] — 上位カテゴリ
```

---

## blog-draft（技術ブログ用ネタ）

`Tech/Zenn/` 専用。ユーザーがブログ化を明示した場合のみ使用。

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: blog-draft
topic: ""
tags:
  - zenn-draft
domains: []
writing_status: draft       # draft | outline | writing | published
source: agent
agent: cursor
related:
  - "[[Agent側の学習ノート]]"
---

## 記事タイトル案

-

## 想定読者・前提

（誰に向けて、何を知っている前提で書くか）

## 記事構成（アウトライン）

1. 
2. 
3. 

## 核心メッセージ

（読者に伝えたい 1 つのこと）

## 素材・具体例

（コード、図、比較表 — 記事に使える素材）

## 差別化ポイント

（既存記事と何が違うか）

## 執筆メモ

-
```

---

## 追記セクション（既存ノート更新時）

既存ノートの末尾に追加:

```markdown
## YYYY-MM-DD 追記

（新しい学び・修正・復習メモ）

> 復習: mastery を `learning` → `familiar` に更新
```
