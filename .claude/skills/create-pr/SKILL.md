---
name: create-pr
description: 変更内容をレビューし、ブランチ作成からDraft PR作成まで一気通貫で行うスキル。「PRを作って」「プルリク作成して」「Draft PRを出して」「この変更をPRにして」「レビューしてPR作って」などのリクエスト時に使用する。変更がワーキングツリーにある状態で呼び出されることを想定している。
---

# Create PR

変更をレビューし、ブランチ作成・コミット・Draft PR作成まで一気通貫で行う。

## パラメータ

- BRANCH_DESCRIPTION: $1（任意。ブランチ名の説明部分。省略時は変更内容から自動生成）
- LINEAR_ISSUE: $2（任意。Linear の issue 識別子。例: `TEAM-123`。省略時は自分にアサインされた In Progress の issue を提示して選択してもらう）

## 前提条件

- ワーキングツリーに未コミットの変更がある状態で呼び出される
- main or developブランチにいる（または新しいブランチを切る元のブランチにいる）

## ワークフロー

### Step 1: 変更内容の把握

まず現在の状態を確認する。

```bash
git status
git diff
git diff --cached
```

変更がなければ「コミットする変更がありません」と報告して終了する。

### Step 2: Linear issue の特定

LINEAR_ISSUE が指定されている場合は `mcp__linear__get_issue` でその issue の詳細を取得する。
指定されていない場合は `mcp__linear__list_issues` で自分にアサインされた issue を取得し、候補を提示してユーザーに選択してもらう

```text
mcp__linear__list_issues(assignee: "me", state: "started")
```

取得した issue から以下の情報を控えておく:
- **issue 識別子**（例: `TEAM-123`）— ブランチ名・コミットメッセージ・PR に使用
- **issue タイトル** — PR タイトルの参考にする
- **issue ID** — PR 作成後のリンク紐付けに使用

ユーザーが「Linear issue なしで進めたい」と言った場合はスキップする。

### Step 3: ブランチ作成

まず既存のブランチ名を確認し、リポジトリの命名規則を把握する。

```bash
git branch -a --sort=-committerdate | head -30
```

既存ブランチの命名パターン（プレフィックス、区切り文字、ケースなど）を分析し、それに倣ったブランチ名を生成する。

- Linear issue がある場合はブランチ名に issue 識別子を含める（例: `yumizu/TEAM-123-add-user-filter`）
- 既存ブランチに明確なパターンがない場合のフォールバック: `yumizu/<short-description>` や `feature/<short-description>` など
- BRANCH_DESCRIPTION が指定されていればそれを使い、なければ変更内容から推測する

```bash
git checkout -b <命名規則に沿ったブランチ名>
```

### Step 4: code-review プラグインによるレビュー

`code-review` プラグイン（`/code-review:code-review`）を使って変更内容をレビューする。

このプラグインは以下の5つの専門エージェントを **並列** で実行する:
- CLAUDE.md コンプライアンスチェック
- バグ検出（変更部分のみ対象）
- Git履歴コンテキスト分析
- 過去のPRコメントレビュー
- コードコメント検証

各問題には信頼度スコア（0-100）が付与され、閾値80以上の問題のみ出力される。

```bash
/code-review:code-review
```

レビュー結果をユーザーに提示し、指摘事項があれば対応するかどうかユーザーに判断を委ねる。
ユーザーが修正を希望した場合は修正を行い、再度 Step 4 に戻る（ユーザーが「OK」と言うまで）。

### Step 5: ステージングとコミット

ユーザーがレビュー結果を確認し、進めてよいと判断したら：

- `git status` で変更ファイルを確認
- 必要なファイルだけを `git add` する（`.env` やクレデンシャルファイルは除外）
- シンプルなコミットメッセージでコミットする

コミットメッセージの形式:
例: `feat: ユーザーフィルター機能を追加`

### Step 6: Draft PR 作成

#### 6-1. リモートにプッシュ

```bash
git push -u origin HEAD
```

#### 6-2. Draft PR を作成

PR template（`.github/pull_request_template.md`）のフォーマットに沿って作成する。

PRタイトルの形式:
- Linear issue がある場合: `[TEAM-123] ユーザーフィルター機能を追加`
- Linear issue がない場合: `ユーザーフィルター機能を追加`

```bash
gh pr create --draft --title "[TEAM-123] PRタイトル" --body "$(cat <<'EOF'
## 概要
<変更内容の簡潔な説明（1-3行）>

Linear: TEAM-123

## リリース時の注意事項
なし
EOF
)"
```

- タイトルは70文字以内、先頭に issue 識別子を付ける
- Linear issue がある場合は body の概要セクションにも `Linear: <issue識別子>` を記載する
- bodyは「概要」と「リリース時の注意事項」のみ記載する（最低限に絞る）
- 「動作確認事項」「実装上の説明」は省略してよい（必要ならユーザーが後から追記）

#### 6-3. Linear issue に PR をリンク

```text
mcp__linear__save_issue(id: "<issue識別子>", links: [{url: "<PR URL>", title: "<PRタイトル>"}])
```

#### 6-4. 完了報告

作成したPRのURLをユーザーに報告する。
