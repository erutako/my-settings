---
name: leetcode-github-pr-discussion
description: >-
  LeetCodeの英語問題名を受け取り、GitHub検索（is:pr in:title）で該当PRを列挙し、
  ghでレビュー・会話コメントを取得して、BigTechのソフトウェアエンジニアリング観点の論点を
  多角的に整理する。問題名からGitHub上のPR議論を調べたい、面接・学習の文脈で
  「世の中のPRで何が議論されているか」を知りたいときに使用する。
---

# LeetCode 問題名に紐づく GitHub PR 議論の抽出（gh）

## 目的

ユーザーから **LeetCode の公式英語タイトル**（例: `Best Time to Buy and Sell Stock`）が渡されたとき、GitHub 上で **タイトルにその問題名を含む Pull Request** を探し、**議論が活発だった順に最大 20 件** を対象に、**レビューコメント・会話コメント** を読み、**BigTech の現場で効く論点** を優先して整理する。最終出力では **コメントごとに GitHub の URL** を示し、**前後の文脈・概念・ジュニアがどう活かせるか** を噛み砕いて書く。

## 前提

- **GitHub CLI (`gh`) がインストールされ、`gh auth status` で認証済み**であること。
- ネットワークが利用できること（Search / REST API を呼ぶ）。
- 問題名は **公式の英語タイトル**（ユーザーが別表記の場合は、LeetCode 公式ページのタイトルに揃える）。

## 重要な仕様（検索と「盛り上がり」の定義）

### 検索クエリ（Web の「タイトル検索」と揃える）

GitHub の Web 検索に相当するクエリは次の形とする（ユーザー指定の例と同じ構造）。

```text
is:pr in:title "<LeetCode の英語問題名>"
```

- `gh api` では `-f q='is:pr in:title "..."'` のように **`q` にそのまま渡す**（問題名に `"` が含まれる場合はエスケープや別の区切り方が必要なので、その場合はユーザーに公式タイトルの表記を確認する）。

### 「コメント数」の落とし穴（必ず読む）

GitHub の **Issue/PR 検索結果の `comments` フィールド**は、**会話タブの Issue コメント数**を指すことが多く、**行単位のレビューコメント（`review_comments`）を含まない**ことがある。

そのため **「議論が活発な上位 20 件」** は次の **合算スコア** で決める。

- `GET /repos/{owner}/{repo}/pulls/{pull_number}` のレスポンスにある  
  **`comments`（会話コメント数） + `review_comments`（レビューコメント数）**

手順は次のとおり。

1. **検索 API** で `is:pr in:title "<問題名>"` に一致する PR を **十分な件数** 集める（例: `per_page=100`、必要なら `page` を増やして最大 **1000 件** まで。GitHub Search の上限に注意）。
2. 各ヒットについて `repository_url` と `number` から `owner/repo` を特定する。
3. **`pulls` API** で上記スコアを取得し、**降順でソート**して **上位 20 件** を選ぶ。

`gh search prs` の `--sort comments` だけに頼らない（検索 API の `comments` とスコアの定義が一致しないため）。

### Web 検索 URL（参考・ユーザーへの提示用）

次の形式で **ブラウザ用の検索 URL** を組み立ててよい（`q` は URL エンコードする）。

```text
https://github.com/search?q=is%3Apr+in%3Atitle+%22<URLエンコードした問題名>%22&type=pullrequests&s=comments&o=desc
```

エージェント側の「正」は **`gh` 経由の API** とし、上記は人間が同じ条件を再確認するための補助。

---

## 実行手順（エージェントが実際に叩くコマンド）

### Phase 1 — PR 候補の取得（Search Issues）

`gh api` の **`--method GET`** と **`-f`** でクエリを渡す（`-f` だけだと POST 扱いになり 404 になることがあるので **GET を明示**する）。

```bash
PROBLEM_NAME='Best Time to Buy and Sell Stock'   # ユーザー入力に置き換え

gh api --method GET '/search/issues' \
  -f q="$(printf 'is:pr in:title "%s"' "$PROBLEM_NAME")" \
  -f per_page=100 \
  -f page=1 \
  --jq '.items[] | {number, title, html_url, repository_url, search_comments: .comments}'
```

- ヒットが多い場合は `page=2,3,...` を繰り返すか、`--paginate` が使える場合はドキュメントに従う（**Search API は 1000 件上限**）。
- `items` が空なら、**問題名の表記ゆれ**（`II` / `2`、大文字小文字、先頭の番号 `121.` など）を疑い、ユーザーに **公式タイトル** を確認する。

### Phase 2 — 「盛り上がり」スコアで上位 20 件に絞る

各 `item` について `repository_url`（例: `https://api.github.com/repos/owner/repo`）から `owner/repo` を取り出し、次を取得する。

```bash
gh api "repos/OWNER/REPO/pulls/NUMBER" \
  --jq '{html_url, title, comments, review_comments, total: (.comments + .review_comments)}'
```

- すべての候補に対して `total` を計算し、**`total` 降順**でソートして **先頭 20** を採用する（jq・小さなループ・一時 JSON ファイルでよい）。
- **同点**の場合は `updated_at` が新しい方、または `review_comments` が多い方を優先してよい（一貫していればよい）。

### Phase 3 — コメント本文の取得（議論の原材料）

採用した **20 件それぞれ**について、次の **2 系統**を取る（どちらも `html_url` で個別にリンク可能）。

1. **会話（Issue コメント）**  
   `GET /repos/{owner}/{repo}/issues/{number}/comments`  
   - `gh api --paginate "repos/OWNER/REPO/issues/NUMBER/comments"`

2. **レビュー（行コメント）**  
   `GET /repos/{owner}/{repo}/pulls/{number}/comments`  
   - `gh api --paginate "repos/OWNER/REPO/pulls/NUMBER/comments"`

必要に応じて **レビュー本文**（`GET /repos/{owner}/{repo}/pulls/{number}/reviews`）も足すと、「Approve / Request changes」の**意思決定の理由**が取れる。

### Phase 4 — レート制限と失敗時

- 認証付きでも **Search / REST のレート制限**がある。大量ループのあとは **指数バックオフ**で再試行する。
- **404 / プライベートリポジトリ**はスキップし、取得できた PR だけで続行する。

---

## 分析・出力の型（BigTech 優先・ジュニア向け）

### 論点の切り口（優先度の目安）

次のような **本番開発でも通じる論点** を、コメントの内容に応じて優先的に拾う（該当がなければ無理に盛らない）。

| 論点の例 | 現場での意味 |
|----------|----------------|
| 命名・ドメイン語彙 | 変数が状態と一致しているか、略語で読めなくなっていないか |
| 複雑度と読みやすさのトレードオフ | 一行圧縮 vs 意図が伝わる分解 |
| 不変条件・ループ不変式 | レビューで「ここが崩れるとバグ」と指摘される箇所 |
| 境界条件・入力契約 | 空、1 要素、負、オーバーフロー、想定外入力 |
| 計算量・メモリ | Big-O の妥当性、定数倍、実装が制約に合うか |
| 型・API 設計 | 戻り値の意味、例外 vs Result、公開関数の契約 |
| テスト・再現性 | 最小ケース、回帰、プロパティベースの示唆 |
| スタイルとチーム規約 | formatter / linter、コメントの付け方 |
| セキュリティ・信頼境界 | 一般には少ないが、入力検証や副作用に触れていれば拾う |

### 出力フォーマット（必須に近い構造）

1. **概要**（2〜4 文）  
   - どの問題名で検索し、**上位 20 PR** をどう選んだか（スコア定義を一文で）。

2. **選定 PR 一覧（20 件以内）**  
   - `タイトル` / `total = comments + review_comments` / `PR の URL`

3. **論点別セクション**（複数セクション可）  
   各論点ブロックに次を含める。
   - **論点名**（上表のようなラベル）
   - **代表的なコメント**  
     - **本文の要約**（長い場合は要約 + 原文の引用は短く）  
     - **permalink（`html_url`）** を必ず付与  
   - **前後の文脈**（そのコメントの直前・直後で何が議論されているか）  
   - **登場する概念**（例: 不変条件、ガード節、two pointers、DP の状態定義など）を **用語を噛み砕いて**  
   - **ジュニアがどう活かすか**（自分の PR・自分のコードレビュー・設計メモに落とす具体策）

4. **補足**  
   - サンプルバイアス（特定コミュニティの PR に偏る）があること、**公式解答の正しさの代替ではない**ことを短く書く。

### トーン

- 断定的すぎず、**コメント発言者の意図**を尊重する。
- 英語コメントは **必要なら日本語で要約**し、用語は初出で軽く定義する。

---

## エージェント向けチェックリスト

- [ ] 問題名は公式英語タイトルに揃えたか（必要ならユーザー確認）。
- [ ] 検索クエリは `is:pr in:title "<問題名>"` か。
- [ ] 上位 20 は **`comments + review_comments`** で並べ替えたか（検索の `comments` だけで決めていないか）。
- [ ] 会話コメントとレビューコメントの **両方**を取得したか。
- [ ] 紹介する各コメントに **GitHub の URL** があるか。
- [ ] 論点が **BigTech で通じる観点**に寄っているか、**ジュニア向けの「使い方」**まで書いたか。

---

## 参考リンク（エージェントが詰まったとき）

- GitHub 検索の構文: [Searching issues and pull requests](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/filtering-and-searching-issues-and-pull-requests)
- REST: [Search issues and pull requests](https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-issues-and-pull-requests)
- `gh api` で GET に `-f` を使うときは **`--method GET`** を付ける（本 SKILL の Phase 1）。
