# 推しパレ - エラー解決ログ

このファイルは推しパレアプリ開発中に発生したエラーとその解決方法を記録します。

## ログ形式

各エラーエントリは以下の形式で記録します：

```markdown
## [日付] エラータイトル

### エラー内容
- **エラーメッセージ**: 
- **スタックトレース**: 
- **発生状況**: 

### 根本原因
- 

### 解決手順
1. 
2. 
3. 

### 予防策
- 

### 関連ファイル
- 

---
```

## エラー履歴

### 2025-08-14 プロジェクト初期化

初期セットアップ完了。まだエラーは発生していません。

---

## [2025-08-14 16:30] Swift構文エラー修正

### エラー内容
- **エラーメッセージ1**: 
  ```
  /Users/sora1/CODE/palette/palette/Core/Models/ColorPalette.swift:275:34 
  Missing argument labels 'saturation:lightness:' in call
  ```
- **エラーメッセージ2**:
  ```
  /Users/sora1/CODE/palette/palette/Shared/Components/GradientBackground.swift:140:63 
  Ambiguous use of operator '/'
  ```
- **発生状況**: Xcodeでビルド実行時に発生

### 根本原因
1. **ColorPalette.swift**: HSLColorイニシャライザに必要な引数ラベル（saturation:, lightness:）が省略されていた
2. **GradientBackground.swift**: `.pi`の型推論が曖昧で、除算演算子の使用が不明確だった

### 解決手順
1. ColorPalette.swift 275行目のHSLColorイニシャライザに引数ラベルを追加:
   - 変更前: `HSLColor(hue: 210, 29, 29)`
   - 変更後: `HSLColor(hue: 210, saturation: 29, lightness: 29)`

2. GradientBackground.swift 140行目の演算子の型を明示化:
   - 変更前: `animationOffset * .pi / 180`
   - 変更後: `animationOffset * Double.pi / 180.0`

3. 類似エラーの確認（grepによる検索で他に該当箇所なし）

### 予防策
- 構造体イニシャライザを使用する際は、すべての引数ラベルを明示的に記載する
- 数値計算時は型を明示的に指定し、型推論に頼らない
- コード記述時にXcodeのエラーチェックを活用する

### 関連ファイル
- `/Users/sora1/CODE/palette/palette/Core/Models/ColorPalette.swift`
- `/Users/sora1/CODE/palette/palette/Shared/Components/GradientBackground.swift`

---

## [2025-08-22 06:40] ホーム画面からの画面遷移が動作しない問題

### エラー内容
- **エラーメッセージ**: なし（実行時の画面遷移が反応しない）
- **発生状況**: ホーム画面のメニューカード（手動ピッカー、自動抽出、手動作成）をタップしても画面遷移しない

### 根本原因
- ContentView.swiftで`NavigationRouter`を計算プロパティ経由で取得していたため、`@Published`プロパティの変更が正しく監視されていなかった
- NavigationRouterがObservableObjectとしてContentViewに正しくバインドされていなかった

### 解決手順
1. ContentView.swiftの11-12行目で`NavigationRouter`を`@StateObject`として直接保持するよう変更
   ```swift
   // 変更前
   private var router: any NavigationRouterProtocol {
       diContainer.navigationRouter
   }
   
   // 変更後
   @StateObject private var router = NavigationRouter.shared
   ```

2. NavigationStackのpath引数を直接`$router.homePath`などにバインディング
   ```swift
   // 変更前
   NavigationStack(path: Binding(
       get: { router.homePath },
       set: { router.homePath = $0 }
   )) {
   
   // 変更後
   NavigationStack(path: $router.homePath) {
   ```

3. sheet、fullScreenCover、alertのバインディングも同様に修正

### 予防策
- ObservableObjectを使用する際は、`@StateObject`または`@ObservedObject`で正しくラップする
- 計算プロパティ経由でObservableObjectにアクセスしない
- SwiftUIのデータバインディングは直接的な`$`プレフィックスを使用する

### 関連ファイル
- `/Users/sora1/CODE/palette/palette/ContentView.swift`
- `/Users/sora1/CODE/palette/palette/Core/Utilities/NavigationRouter.swift`

---

*Last Updated: 2025-08-22*