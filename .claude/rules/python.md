---
paths:
  - "**/*.py"
  - "**/*.ipynb"
---

# Pythonコーディング規約

## 基本方針

- シンプルさ優先: 読みやすいコード > 巧妙なコード
- 単一責任: 1関数=1つのこと、1クラス=1つの責任
- 早期リターン: ネスト深さ最大4レベル
- イミュータビリティ: 既存オブジェクトを変更せず新しいオブジェクトを作成
- 型ヒント必須: すべての関数に型アノテーションを付ける
- 命名規則: 変数/関数=snake_case、クラス=PascalCase、定数=UPPER_SNAKE_CASE

## シンプルさ優先

- 複雑なコードよりも読みやすいコードを選ぶ
- 過度な抽象化や関数化を避ける
- 「動く」よりも「理解しやすい」を優先する

## Docstring

型ヒントが充実している現代のPython（3.8以降）では、Google Python Style Guideに従い、型情報をdocstringで繰り返さないことを原則とする。
ただし、型ヒントだけでは伝わりにくい情報（例: 引数の意味や関数の挙動）については、適切なdocstringを記述することが推奨される。

### Docstringに含めるべき内容

1. **What**: 関数の目的（1行目）
2. **Why**: なぜこの関数を使うか（非自明な場合）
3. **How**: 重要なアルゴリズムや実装詳細
4. **Edge cases**: 特殊な動作（ただしコードで自明な場合は省略）
5. **Side effects**: 副作用や状態変更
6. **Performance**: パフォーマンス特性

### 良い例: 型ヒントと簡潔な説明

```python
def add(a: int, b: int) -> int:
    """2つの整数を加算して返す"""
    return a + b
```

### 良い例: 型ヒントだけでは不明確な情報がある場合

```python
def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """2地点間の距離を計算

    Haversine公式を使用して球面上の最短距離を算出。

    Args:
        lat1, lon1: 始点の緯度・経度（度数法）
        lat2, lon2: 終点の緯度・経度（度数法）

    Returns:
        距離（キロメートル）
    """
```

### 悪い例: 型ヒントと冗長な説明

```python
def add(a: int, b: int) -> int:
    """2つの整数 a と b を加算して整数を返す

    Args:
        a (int): 最初の整数
        b (int): 2番目の整数
    
    Returns:
        int: 2つの整数の和
    """
```
