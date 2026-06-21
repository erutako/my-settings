---
name: obsidian-agent-learning
description: >-
  AIエージェントとのやり取りから得た学び・知識・記録を Obsidian vault に構造化して保存する。
  ユーザーが「Obsidianに残して」「学びを記録」「ナレッジ化」等と言ったとき、または会話末尾で
  知識の定着を求められたときに使用する。
compatibility: Obsidian vault へのファイル書き込み権限が必要。ネットワーク不要。
metadata:
  version: "1.8"
---

# Obsidian Agent Learning Capture

AI エージェントとの対話から、**将来の自分が検索・復習・関連付けしやすい**ノートを Obsidian に残す。

**構造の目的**: 人間が「どこに何があるか」の知識マップを持てるよう、必要に応じてドキュメントを分割し、再帰的にディレクトリ階層を作る。詳細は [references/STRUCTURE.md](references/STRUCTURE.md) を参照。

## セットアップ（初回・パス解決）

**vault パス等の機密・環境依存情報は SKILL 本文に書かない。** `config.local.yaml`（gitignore）または環境変数で渡す。

1. `config.example.yaml` を `config.local.yaml` にコピーし `vault:` を設定
2. 各 vault 操作の**最初**にパスを解決（zsh / bash 共通）:

```bash
eval "$( "<skill-dir>/scripts/resolve-config.sh" )"
# → VAULT, SCRIPT, SKILL_DIR が export される
```

bash のみ `source "<skill-dir>/scripts/resolve-config.sh"` でも可。

| 変数 | 意味 |
|------|------|
| `VAULT` | Obsidian vault の絶対パス |
| `SCRIPT` | `scripts/vault-write.sh` の絶対パス |
| `SKILL_DIR` | 本スキルディレクトリ |

環境変数 `OBSIDIAN_VAULT` でも vault を上書きできる。`config.local.yaml` は **コミットしない**。

**配置の推奨**: 公開テンプレートは git リポジトリ、実運用は `~/.agents/skills/obsidian-agent-learning/` 等のローカルに `config.local.yaml` 付きで置く。

## 起動条件

次のいずれかで本スキルを適用する:

- ユーザーが明示的に Obsidian への保存を依頼した
- 会話で重要な学びが生まれ、ユーザーが記録を求めた
- ユーザーが「この会話を残して」「ナレッジベースに追加して」と指示した

保存前に、**新規作成か既存ノート更新か**を必ず確認する。曖昧ならユーザーに 1 問だけ確認する。

## Vault 基本情報

| 項目 | 値 |
|------|-----|
| Vault パス | **`$VAULT`**（[セットアップ](#セットアップ初回パス解決) で解決） |
| 学習ノート（**デフォルト**） | `Tech/{カテゴリ}/` — 内容に応じた分野フォルダ（下表） |
| LeetCode 関連 | `Tech/LeetCode/{番号}_{name}/` |
| デイリーノート | `Daily/YYYY-MM-DD.md`（**本スキルのデフォルト保存先ではない**） |
| 技術ブログ用ネタ | `Tech/Zenn/`（**本スキルのデフォルト保存先ではない**） |
| 深掘りクイズ形式 | `Tech/daily−quiz/`（触らない） |
| 手順・ワークフロー | `Memo/{tool-or-context}/` |
| セッション要約 | `Tech/Sessions/YYYY-MM/` |
| フォルダ地図（MOC） | 共通フォーマット集合の `_index.md`（**条件を満たす場合のみ**） |

### `Tech/` カテゴリ（L0）

**`Tech/Agent/` ディレクトリは作らない。** エージェント由来は frontmatter で区別する。

| カテゴリフォルダ | 内容 | `domains` 目安 |
|----------------|------|----------------|
| `Algorithm & Data Structure/` | アルゴリズム・データ構造 | `DSA:*` |
| `LeetCode/` | LeetCode 問題・解法 | LeetCode 専用 |
| `Systems/` | OS・メモリ・GC 等 | `SYS:*` |
| `Programming Languages/` | 言語仕様・ランタイム | `FPL:*` |
| `Networking/` | プロトコル・分散 | `NET:*` |
| `Software Architecture/` | 設計・アーキテクチャ | `ARCH:*` |
| `Performance/` | パフォーマンス・計測 | `PERF:*` |
| `Sessions/` | セッション要約 | — |
| `Tools/` | ツール・エージェント設定 | `TOOL:*` |

サブトピック（L1）: `domains` の `"DSA: Search"` → `Tech/Algorithm & Data Structure/Search/`（任意。既存がフラットならカテゴリ直下でも可）

詳細: [references/STRUCTURE.md](references/STRUCTURE.md)

### エージェント由来の識別（metadata）

保存先フォルダではなく **frontmatter** で区別する:

```yaml
source: agent          # 必須
agent: cursor          # 推奨
tags:
  - agent-learning     # 必須
```

手動作成ノートと混在しても、Dataview や検索で `source: agent` / `#agent-learning` によりフィルタできる。

### `Tech/Zenn/` について

`Tech/Zenn/` は**技術ブログ（Zenn 等）に書くためのネタ・下書き素材**を貯める場所。学習記録やエージェント対話のログ置き場ではない。

| 保存先 | 用途 |
|--------|------|
| `Tech/{カテゴリ}/` | 学習・定着・復習用（本スキルのデフォルト） |
| `Tech/Zenn/` | 公開記事に昇格させるネタ・構成・下書き |

- ユーザーが「ブログネタに」「Zenn に書く用に」等と**明示した場合のみ** `Tech/Zenn/` に保存する
- 通常の学習記録は `Tech/{カテゴリ}/` に保存し、ブログ化の可能性がある場合は `related` で `Tech/Zenn/` のネタノートへリンクする（逆方向も可）
- `Tech/Zenn/` への保存をユーザーが求めていない限り、ここへ書き込まない

### `Daily/` について

`Daily/` は**日次の個人メモ・振り返り**用。エージェント学習記録の保存先ではない。

| 保存先 | 用途 |
|--------|------|
| `Tech/{カテゴリ}/` | 学習・定着・復習用（本スキルのデフォルト） |
| `Daily/` | その日の雑記・振り返り・個人的な記録 |

- 学習ノートの内容を `Daily/` に**書き込まない**（デフォルト）
- ユーザーが「デイリーノートにもリンクして」「Daily に追記して」等と**明示した場合のみ**、既存の `Daily/YYYY-MM-DD.md` へ wikilink を 1 行追記してよい
- `Daily/` にファイルを新規作成しない（ユーザーが明示しない限り）
- 学習内容そのものは常に `Tech/{カテゴリ}/` の専用ノートに保存する

## ワークフロー

### Step 1: 保存対象の抽出

会話から以下を抽出する（全部入りにしない。1 ノート = 1 トピックを原則とする）:

1. **核心の学び** — 1〜3 文で言える洞察
2. **なぜ重要か** — 問題解決・面接・本番でどう効くか
3. **具体例** — コード、コマンド、図、比較表
4. **誤解していた点** — あれば Before/After
5. **未解決・次の調査** — あれば

### Step 1.5: 分割と階層の設計

[references/STRUCTURE.md](references/STRUCTURE.md) に従い、保存前に構造を設計する:

1. **分割判断** — 独立トピック 2 つ以上、150 行超、`type`/`domains` 混在、時系列 step なら分割
2. **パス決定** — 内容から `Tech/{カテゴリ}/` を選び、必要ならサブトピック階層を追加
3. **MOC 判定** — 共通フォーマットの集合か確認。条件を満たす場合のみ `_index.md` を計画（[STRUCTURE.md](references/STRUCTURE.md) 参照）
4. **ディレクトリ作成** — 存在しないパスは `mkdir -p` で再帰的に作成

```
Tech/LeetCode/35_searchInsertPosition/    ← step 系列（MOC あり）
├── _index.md
├── step1.md
└── step2.md

Tech/Algorithm & Data Structure/Search/   ← 独立ノート（MOC なし）
├── Lower Bound.md
└── Binary Search Loop Invariant.md
```

分割時は兄弟ノートを `related` でリンクする。MOC がある集合では `_index.md` から子ノートへリンクする。

### Step 2: 既存ノートの確認（書き込み前必須）

保存先の **絶対パス `TARGET`** を決めたら、**Write の前に必ず**存在確認する。詳細: [references/WRITE.md](references/WRITE.md)

```bash
eval "$( "$SKILL_DIR/scripts/resolve-config.sh" )"

TARGET="$VAULT/Tech/..."   # Step 3 で決定した vault 内絶対パス

# 1. 正規パスの NEW / UPDATE 判定（必須）
"$SCRIPT" --check "$TARGET"

# 2. 意味的な重複検索
rg -l "キーワード" "$VAULT/Tech/"
```

| `--check` 結果 | 動作 |
|----------------|------|
| `UPDATE` | **新規作成しない**。ロック取得後、既存ファイルを Read → マージ → 同一路径へ上書き |
| `NEW` | ロック取得後、新規作成 |

追加ルール:

- **`ファイル (N).md` へは書き込まない** — Obsidian + 外部 Write の競合退避コピー。正規パス（`(N)` なし）を `TARGET` にする
- **LeetCode** — `Tech/LeetCode/_index.md` と `{番号}_*` フォルダ／フラット `.md` を確認。既存がフラットならサブフォルダを新設しない
- **LeetCode frontmatter** — `Tech/LeetCode/_default-metadata.md` を **Read のみ**参照（コピー先にしない）
- **同名の別パスを作らない** — 検索で見つかった既存ノートのパスを `TARGET` に採用

### Step 3: ノート種別と配置の決定

| `type` | 配置 | 用途 |
|--------|------|------|
| `concept` | `Tech/{カテゴリ}/` | 概念・原理の理解 |
| `algorithm` | `Tech/LeetCode/{id}_{name}/` 等 | LeetCode 解法・パターン |
| `debugging` | `Tech/{カテゴリ}/` | 調査・バグ解決の記録 |
| `workflow` | `Memo/{tool}/` | 手順・ツール設定・運用 |
| `decision` | `Tech/{カテゴリ}/` | 設計判断とトレードオフ |
| `snippet` | `Tech/{カテゴリ}/` | 再利用可能なコード片 |
| `session-summary` | `Tech/Sessions/YYYY-MM/` | 1 セッション全体の要約 |
| `index` | 集合フォルダの `_index.md` | 共通フォーマット群の MOC（**条件を満たす場合のみ**） |
| `blog-draft` | `Tech/Zenn/` | 技術ブログ用ネタ（**ユーザー明示時のみ**） |

ファイル名: `{topic の短い英語または日本語}.md`（Obsidian wiki リンクしやすい具体名。`Untitled` 禁止）

配置の詳細・分割基準・命名規則: [references/STRUCTURE.md](references/STRUCTURE.md)

### Step 4: Frontmatter の付与

[references/FRONTMATTER.md](references/FRONTMATTER.md) のスキーマに従う。必須フィールド:

- `created`, `updated`, `type`, `topic`, `tags`, `mastery`, `source`

`source: agent` と `agent: cursor` はエージェント由来のノートで必ず付ける。

### Step 5: ディレクトリ作成と MOC 更新

1. 決定したパスに対して `mkdir -p` を実行
2. [STRUCTURE.md](references/STRUCTURE.md) の MOC 作成条件を満たす場合のみ `_index.md` を計画（本文は Step 5.5 でロック付き書き込み）
3. MOC がない場合 → 兄弟ノート間を `related` でリンク。上位階層に `_index.md` を連鎖作成しない

### Step 5.5: ロック付き書き込み（必須）

**Cursor の Write ツールを vault へ直接使わない。** 必ず `scripts/vault-write.sh` 経由。詳細: [references/WRITE.md](references/WRITE.md)

```bash
eval "$( "$SKILL_DIR/scripts/resolve-config.sh" )"
TARGET="$VAULT/..."   # Step 2 で --check 済みの絶対パス

# UPDATE: ロック内で Read 済みのマージ全文を渡す
# NEW:    新規全文を渡す
"$SCRIPT" "$TARGET" <<'NOTE_EOF'
（frontmatter + 本文の完成稿）
NOTE_EOF
# 出力例: UPDATE:$VAULT/.../foo.md  または  NEW:$VAULT/.../foo.md
```

手順:

1. Step 2 の `--check` が `UPDATE` なら、**書き込み直前**に `TARGET` を Read し `created` を保持してマージ
2. `vault-write.sh` が **mkdir ロック取得 → 原子 replace 書き込み → ロック解放** を行う
3. 葉ノート → 集合 `_index.md`（MOC あり）→ `Daily/` 1 行追記（明示時）の順で、**ファイルごとに 1 回ずつ**呼ぶ
4. 1 シェル invocation = 1 ファイル（ロックを跨ぐ Write ツール呼び出しを挟まない）

### Step 6: 本文の構成と `related` の選定

[references/TEMPLATES.md](references/TEMPLATES.md) から `type` に合ったテンプレートを選ぶ（MOC は `index` テンプレート）。

**`related` は最大 5 件。** 付与前に vault を検索し、関連度の高い既存ノートを選ぶ。詳細: [references/RELATED.md](references/RELATED.md)

1. `topic` / `tags` / `domains` / キーワードで vault を検索
2. 前提・同一パターン・対比・同一 domain の順で関連度を評価
3. 上位 5 件までを `related` に設定（満たさなくてよい）
4. 本文「関連」セクションに、各リンクへ 1 行の理由を添える

共通原則:

- 見出しは `##` から（`#` は Obsidian のファイル名表示と被るため避ける）
- コードブロックに言語タグを付ける
- 自分の言葉での要約を必ず 1 セクション入れる（定着のため）
- 漫然とリンクしない。記憶の定着に貢献する有機的な接続を優先する

### Step 7: デイリーノートへのリンク（ユーザー明示時のみ）

**デフォルトでは実行しない。**

ユーザーが Daily への追記を明示した場合のみ、既存の `Daily/YYYY-MM-DD.md` に wikilink を追記する:

```markdown
- [[ノート名]] — 1 行サマリ
```

- 学習内容の本体は `Tech/{カテゴリ}/` に保存済みであること
- ファイルが存在しない場合は**作成せず**、ユーザーに確認する
- デイリーノートへの追記をユーザーが求めていない限り、`Daily/` には一切書き込まない

### Step 8: 保存後の報告

ユーザーに以下を簡潔に報告する:

- 作成/更新したファイルパス（分割した場合は一覧 + ディレクトリツリー）
- `topic`, `tags`, `next_review`
- 作成/更新した `_index.md`（MOC）のパス（作成した場合のみ）
- 関連ノートへのリンク有無

## 品質チェックリスト

保存前に確認:

- [ ] 1 ノート 1 トピックになっている
- [ ] 150 行超・複数トピック混在なら分割済み
- [ ] ディレクトリ深さが 4 階層以内
- [ ] 不要な `_index.md` を作っていない
- [ ] 既存 `_index.md` の `children` が実ファイルと一致（MOC がある場合）
- [ ] frontmatter の必須フィールドが揃っている
- [ ] `category` が実パスと一致（設定している場合）
- [ ] `tags` に `agent-learning` が含まれている
- [ ] TL;DR または要点セクションがある
- [ ] コード・事実に hallucination がない（会話内容のみから記述）
- [ ] 既存 vault の命名・フォルダ規則に従っている
- [ ] `next_review` が設定されている（復習促進）
- [ ] `related` が最大 5 件で、vault 検索に基づく関連度の高いノートのみ
- [ ] `Tech/Agent/` に新規ファイルを作っていない
- [ ] `Daily/` と `Tech/Zenn/` へユーザー明示なく書き込んでいない
- [ ] 書き込み前に `vault-write.sh --check "$TARGET"` を実行した
- [ ] `UPDATE` 時は同一路径をロック付きで上書きし、別パスに同名ファイルを作っていない
- [ ] `ファイル (N).md` 形式の競合コピーへ書き込んでいない
- [ ] `config.local.yaml` または `OBSIDIAN_VAULT` で `$VAULT` を解決済み
- [ ] vault へ Write ツールを使わず `vault-write.sh` 経由のみ

## 追加リソース

- 書き込み・ロック: [references/WRITE.md](references/WRITE.md)
- 分割・階層化・MOC: [references/STRUCTURE.md](references/STRUCTURE.md)
- `related` 選定ルール: [references/RELATED.md](references/RELATED.md)
- Frontmatter 全フィールド定義: [references/FRONTMATTER.md](references/FRONTMATTER.md)
- ノート種別テンプレート: [references/TEMPLATES.md](references/TEMPLATES.md)
