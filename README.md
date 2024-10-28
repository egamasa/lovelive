## 蓮ノ空ダッシュボード

![Screen Shot 2024-10-20 at 20 07 15-fullpage](https://github.com/user-attachments/assets/cbd93699-ae00-4c08-a5c8-c1d7fb1dfa78)

### batch

AWS Lambda

#### デプロイ

```
sam build
aws sso login
sam deploy --profile hoge  # IAMを作成可能な権限を持つプロファイルを指定
```

### frontend

Svelte + SvelteKit + Tailwind CSS

#### プレビュー

```
npm run dev
```

#### ビルド

```
npm run build
```
