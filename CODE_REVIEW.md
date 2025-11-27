# コードレビュー: SOLID原則に基づく分析

## 概要

このドキュメントでは、self_assembly プロジェクトのコードベースを SOLID 原則に照らし合わせてレビューし、改善点を提案します。

---

## 1. S - 単一責任の原則 (Single Responsibility Principle)

> クラスは一つの責任のみを持つべきである。

### ✅ 良い点

- **`PeriodicBoundarySystem`**: 周期境界条件の処理のみを担当しており、SRP に従っている。
- **`EntityManager`**: エンティティの追加・削除のみを管理している。
- **`Connector`**: コネクタのデータ構造のみを定義している。
- **`PolygonPart`**: ポリゴンパーツのデータ構造のみを定義している。

### ⚠️ 改善が必要な点

#### 1.1 `SelfAssemblyBody` (body_component.dart)

**問題**: このクラスは複数の責任を持っている。
- 物理ボディの作成 (`createBody()`)
- レンダリング (`render()`)

**推奨**: レンダリングロジックを別のクラスに分離する。

```dart
// 改善案: レンダリング専用クラス
class SelfAssemblyBodyRenderer {
  void render(Canvas canvas, SelfAssemblyBody body) {
    // レンダリングロジック
  }
}
```

#### 1.2 `ConnectionSystem` (connection_system.dart)

**問題**: このクラスは複数の責任を持っている。
- コネクタ間の距離計算
- 吸引力の適用
- 反発力の適用
- ボディの結合処理
- 角度の正規化
- 周期境界を考慮した距離計算

**推奨**: 以下のように分離する。

```dart
// 改善案
class ForceCalculator {
  Vector2 calculateAttractionForce(Connector a, Connector b, double distance);
  Vector2 calculateRepulsionForce(Connector a, Connector b, double distance);
}

class BodyMerger {
  SelfAssemblyBody merge(SelfAssemblyBody bodyA, SelfAssemblyBody bodyB);
}

class PeriodicDistanceCalculator {
  Vector2 getShortestVector(Vector2 from, Vector2 to, Vector2 worldSize);
}
```

#### 1.3 `SelfAssemblyGame` (self_assembly_game.dart)

**問題**: ゲーム初期化時にエンティティの生成ロジックが直接書かれている。

**推奨**: エンティティ生成ロジックを別のクラス（ファクトリやスポーナー）に分離する。

```dart
// 改善案
class EntitySpawner {
  List<SelfAssemblyBody> createInitialBodies(int count, Vector2 worldSize);
}
```

---

## 2. O - 開放/閉鎖の原則 (Open/Closed Principle)

> ソフトウェアエンティティは拡張に対して開いており、修正に対して閉じているべきである。

### ⚠️ 改善が必要な点

#### 2.1 `ConnectorType` の処理

**問題**: `ConnectionSystem` 内で `ConnectorType` の比較がハードコードされている。

```dart
// 現在の実装
final sameType = connA.type == connB.type;
```

**推奨**: コネクタの互換性ロジックをインターフェースまたは戦略パターンで抽象化する。

```dart
// 改善案
abstract class ConnectorCompatibility {
  bool isCompatible(ConnectorType a, ConnectorType b);
  bool shouldAttract(ConnectorType a, ConnectorType b);
  bool shouldRepel(ConnectorType a, ConnectorType b);
}

class PlusMinusCompatibility implements ConnectorCompatibility {
  @override
  bool isCompatible(ConnectorType a, ConnectorType b) => a != b;
  
  @override
  bool shouldAttract(ConnectorType a, ConnectorType b) => a != b;
  
  @override
  bool shouldRepel(ConnectorType a, ConnectorType b) => a == b;
}
```

#### 2.2 力の計算モデル

**問題**: 吸引力・反発力の計算式がハードコードされている。

**推奨**: 力の計算を戦略パターンで抽象化する。

```dart
// 改善案
abstract class ForceModel {
  double calculateForce(double distance, double maxRange);
}

class LinearForceModel implements ForceModel {
  @override
  double calculateForce(double distance, double maxRange) {
    return 1.0 - distance / maxRange;
  }
}

class InverseSquareForceModel implements ForceModel {
  @override
  double calculateForce(double distance, double maxRange) {
    return 1.0 / (distance * distance);
  }
}
```

---

## 3. L - リスコフの置換原則 (Liskov Substitution Principle)

> サブタイプは、その基本型と置換可能でなければならない。

### ✅ 良い点

- **`SelfAssemblyBody extends BodyComponent`**: 親クラスの契約を正しく実装している。
- **システムクラス**: すべて `Component` を正しく継承し、`update()` メソッドをオーバーライドしている。

### ⚠️ 軽微な問題

#### 3.1 `createBody()` の戻り値

`SelfAssemblyBody.createBody()` は常に `Body` を返すが、例外処理がない。`parts` が空の場合の動作が未定義。

```dart
// 改善案
@override
Body createBody() {
  if (parts.isEmpty) {
    throw StateError('SelfAssemblyBody must have at least one part');
  }
  // ...
}
```

---

## 4. I - インターフェース分離の原則 (Interface Segregation Principle)

> クライアントは、自分が使用しないメソッドに依存すべきではない。

### ⚠️ 改善が必要な点

#### 4.1 `HasGameReference<SelfAssemblyGame>` の過度な使用

**問題**: すべてのシステムが `SelfAssemblyGame` 全体への参照を持っている。

```dart
class PeriodicBoundarySystem extends Component with HasGameReference<SelfAssemblyGame>
class ConnectionSystem extends Component with HasGameReference<SelfAssemblyGame>
class BreakSystem extends Component with HasGameReference<SelfAssemblyGame>
```

**推奨**: 必要な依存関係のみを注入する。

```dart
// 改善案
class PeriodicBoundarySystem extends Component {
  final EntityManager entityManager;
  final Vector2 worldSize;
  
  PeriodicBoundarySystem({
    required this.entityManager,
    required this.worldSize,
  });
}
```

---

## 5. D - 依存性逆転の原則 (Dependency Inversion Principle)

> 高レベルモジュールは低レベルモジュールに依存すべきではない。両者は抽象に依存すべきである。

### ⚠️ 改善が必要な点

#### 5.1 具象クラスへの直接依存

**問題**: `ConnectionSystem` と `BreakSystem` が `SelfAssemblyBody` と `EntityManager` の具象実装に直接依存している。

**推奨**: インターフェース（抽象クラス）を導入する。

```dart
// 改善案
abstract class IEntityManager {
  List<SelfAssemblyBody> get bodies;
  void addBody(SelfAssemblyBody body);
  void removeBody(SelfAssemblyBody body);
}

class EntityManager extends Component implements IEntityManager {
  // ...
}
```

#### 5.2 ゲームクラスへの直接依存

**問題**: システムクラスが `SelfAssemblyGame` の具象実装に依存している。

```dart
// 現在の実装
final bodies = game.entityManager.bodies;
final worldSize = game.worldSize;
```

**推奨**: 必要なデータを抽象化して注入する。

---

## 追加の設計上の問題

### 6. マジックナンバーの使用

**問題**: 多くのハードコードされた値が存在する。

```dart
final double attractionRange = 5.0;
final double attractionForce = 10.0;
final double repulsionRange = 3.0;
final double repulsionForce = 15.0;
final double connectionThreshold = 0.5;
final double angleThreshold = 0.3;
final double breakProbabilityPerSecond = 0.1;
```

**推奨**: 設定クラスを作成する。

```dart
// 改善案
class ConnectionSystemConfig {
  final double attractionRange;
  final double attractionForce;
  final double repulsionRange;
  final double repulsionForce;
  final double connectionThreshold;
  final double angleThreshold;
  
  const ConnectionSystemConfig({
    this.attractionRange = 5.0,
    this.attractionForce = 10.0,
    this.repulsionRange = 3.0,
    this.repulsionForce = 15.0,
    this.connectionThreshold = 0.5,
    this.angleThreshold = 0.3,
  });
}
```

### 7. デバッグ用 print 文

**問題**: プロダクションコードに `print` 文が残っている。

```dart
print('Connecting! dist=$dist, angleDiff=$angleDiff');
```

**推奨**: ロギングフレームワークを使用するか、デバッグモードでのみ出力する。

```dart
// 改善案
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('Connecting! dist=$dist, angleDiff=$angleDiff');
}
```

---

## 優先度別改善リスト

### 高優先度

1. **SRP違反の修正**: `ConnectionSystem` の責任分離
2. **DIP違反の修正**: インターフェースの導入
3. **デバッグ print 文の削除**

### 中優先度

4. **設定のハードコード**: 設定クラスの導入
5. **ISP違反の修正**: 依存関係の最小化
6. **OCP違反の修正**: 戦略パターンの導入

### 低優先度

7. **レンダリングの分離**: `SelfAssemblyBody` からレンダリングロジックを分離
8. **エンティティ生成の分離**: ファクトリパターンの導入

---

## 結論

全体的に、このコードベースはゲーム開発の初期段階として妥当な設計ですが、SOLID原則に照らし合わせると、特に**単一責任の原則（SRP）**と**依存性逆転の原則（DIP）**において改善の余地があります。

プロジェクトが成長するにつれて、上記の改善を段階的に適用することで、保守性とテスト容易性が向上します。
