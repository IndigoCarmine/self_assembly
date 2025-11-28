// インターフェース定義ファイル
// 
// このファイルは、並行開発を可能にするための抽象インターフェースを定義します。
// 各インターフェースは具象クラスから分離されており、依存性逆転の原則（DIP）に従っています。
// 
// ## 使用方法
// 実装クラスは対応するインターフェースを実装（implements）してください。
// システムクラスは具象クラスではなく、これらのインターフェースに依存してください。

import 'dart:ui' show Canvas;
import 'package:flame/components.dart';
import '../components/connector.dart';
import '../components/polygon_part.dart';

// =============================================================================
// エンティティ管理インターフェース
// =============================================================================

/// エンティティ（ボディ）の管理を担当するインターフェース
/// 
/// 実装クラス: EntityManager
abstract class IEntityManager {
  /// 現在管理されているすべてのボディを取得
  List<IAssemblyBody> get bodies;
  
  /// 新しいボディを追加（次のフレームで反映）
  void addBody(IAssemblyBody body);
  
  /// ボディを削除（次のフレームで反映）
  /// ボディを削除（次のフレームで反映）
  void removeBody(IAssemblyBody body);
}

// =============================================================================
// ボディインターフェース
// =============================================================================

/// 物理ボディへのアクセスを提供するインターフェース
/// 
/// Forge2DのBodyをラップして抽象化
abstract class IPhysicsBody {
  /// 現在の位置
  Vector2 get position;
  
  /// 現在の角度（ラジアン）
  double get angle;
  
  /// 線形速度
  Vector2 get linearVelocity;
  
  /// 角速度
  double get angularVelocity;
  
  /// 質量
  double get mass;
  
  /// 力を適用
  void applyForce(Vector2 force, {Vector2? point});
  
  /// トランスフォームを設定
  void setTransform(Vector2 position, double angle);
}

/// 自己組織化ボディのインターフェース
/// 
/// 実装クラス: SelfAssemblyBody
abstract class IAssemblyBody {
  /// このボディを構成するパーツのリスト
  List<PolygonPart> get parts;
  
  /// ボディがマウント（アクティブ）されているか
  bool get isMounted;
  
  /// 物理ボディへのアクセス
  IPhysicsBody get physicsBody;
  Vector2 get linearVelocity;
  
  /// 角速度
  double get angularVelocity;
  
  /// 質量
  double get mass;
  
  /// 力を適用
  void applyForce(Vector2 force, {Vector2? point});
  
  /// トランスフォームを設定
  void setTransform(Vector2 position, double angle);
}

// =============================================================================
// システムインターフェース
// =============================================================================

/// 接続システムのインターフェース
/// 
/// 実装クラス: ConnectionSystem
abstract class IConnectionSystem {
  /// コネクタ間の吸引・反発・接続を処理
  void update(double dt);
}

/// 分離システムのインターフェース
/// 
/// 実装クラス: BreakSystem
abstract class IBreakSystem {
  /// ボディの分離処理
  void update(double dt);
}

/// 周期境界システムのインターフェース
/// 
/// 実装クラス: PeriodicBoundarySystem
abstract class IPeriodicBoundarySystem {
  /// ワールドサイズ
  Vector2 get worldSize;
  
  /// 周期境界条件を適用
  void update(double dt);
}

// =============================================================================
// 力計算インターフェース
// =============================================================================

/// 力の計算モデルを定義するインターフェース
/// 
/// 戦略パターンによる力計算の抽象化
abstract class IForceModel {
  /// 距離に基づいて力の大きさを計算
  /// 
  /// [distance] 2点間の距離
  /// [maxRange] 力が作用する最大範囲
  /// 
  /// 戻り値: 0.0〜1.0の範囲の力の係数
  double calculateForce(double distance, double maxRange);
}

/// 線形減衰力モデル
/// 
/// 距離が近いほど強い力、遠いほど弱い力を返す
class LinearForceModel implements IForceModel {
  @override
  double calculateForce(double distance, double maxRange) {
    if (distance >= maxRange) return 0.0;
    return 1.0 - distance / maxRange;
  }
}

/// 逆二乗力モデル
/// 
/// 重力や電磁気力のような逆二乗則に従う
/// 注意: 戻り値は0.0〜1.0に正規化される
class InverseSquareForceModel implements IForceModel {
  final double minDistance;
  
  InverseSquareForceModel({this.minDistance = 0.1});
  
  @override
  double calculateForce(double distance, double maxRange) {
    if (distance >= maxRange) return 0.0;
    final clampedDistance = distance < minDistance ? minDistance : distance;
    // 最大範囲での力を基準に正規化（minDistanceでの力が1.0になる）
    final maxForce = 1.0 / (minDistance * minDistance);
    final force = 1.0 / (clampedDistance * clampedDistance);
    return (force / maxForce).clamp(0.0, 1.0);
  }
}

// =============================================================================
// コネクタ互換性インターフェース
// =============================================================================

/// コネクタ間の互換性を判定するインターフェース
/// 
/// 異なる接続ルールを実装可能にする
abstract class IConnectorCompatibility {
  /// 2つのコネクタが接続可能か判定
  bool isCompatible(ConnectorType a, ConnectorType b);
  
  /// 2つのコネクタが吸引すべきか判定
  bool shouldAttract(ConnectorType a, ConnectorType b);
  
  /// 2つのコネクタが反発すべきか判定
  bool shouldRepel(ConnectorType a, ConnectorType b);
}

/// プラス・マイナス互換性モデル
/// 
/// 異なるタイプ同士が吸引し、同じタイプ同士が反発する
class PlusMinusCompatibility implements IConnectorCompatibility {
  @override
  bool isCompatible(ConnectorType a, ConnectorType b) => a != b;
  
  @override
  bool shouldAttract(ConnectorType a, ConnectorType b) => a != b;
  
  @override
  bool shouldRepel(ConnectorType a, ConnectorType b) => a == b;
}

// =============================================================================
// 距離計算インターフェース
// =============================================================================

/// 距離計算を抽象化するインターフェース
/// 
/// 周期境界条件を考慮した距離計算を可能にする
abstract class IDistanceCalculator {
  /// 2点間の最短ベクトルを計算
  /// 
  /// 周期境界条件下では、ラップアラウンドを考慮した最短経路を返す
  Vector2 getShortestVector(Vector2 from, Vector2 to);
  
  /// 2点間の最短距離を計算
  double getShortestDistance(Vector2 from, Vector2 to);
}

/// 周期境界を考慮した距離計算
class PeriodicDistanceCalculator implements IDistanceCalculator {
  final Vector2 worldSize;
  late final Vector2 _halfWorldSize;
  
  PeriodicDistanceCalculator({required this.worldSize}) {
    _halfWorldSize = worldSize / 2;
  }
  
  @override
  Vector2 getShortestVector(Vector2 from, Vector2 to) {
    var dx = to.x - from.x;
    var dy = to.y - from.y;

    if (dx > _halfWorldSize.x) {
      dx -= worldSize.x;
    } else if (dx < -_halfWorldSize.x) {
      dx += worldSize.x;
    }

    if (dy > _halfWorldSize.y) {
      dy -= worldSize.y;
    } else if (dy < -_halfWorldSize.y) {
      dy += worldSize.y;
    }

    return Vector2(dx, dy);
  }
  
  @override
  double getShortestDistance(Vector2 from, Vector2 to) {
    return getShortestVector(from, to).length;
  }
}

// =============================================================================
// ボディマージャーインターフェース
// =============================================================================

/// 2つのボディを結合するインターフェース
abstract class IBodyMerger {
  /// 2つのボディを結合して新しいボディを作成
  /// 
  /// [bodyA] 結合元ボディA
  /// [bodyB] 結合元ボディB
  /// [connA] ボディAの接続コネクタ
  /// [connB] ボディBの接続コネクタ
  IAssemblyBody merge(
    IAssemblyBody bodyA,
    IAssemblyBody bodyB,
    Connector connA,
    Connector connB,
  );
}

// =============================================================================
// イベントバスインターフェース
// =============================================================================

/// ゲームイベントの基底クラス
abstract class GameEvent {}

/// イベントバスのインターフェース
/// 
/// システム間の疎結合な通信を実現する
abstract class IEventBus {
  /// 特定のイベントタイプを購読
  Stream<T> on<T extends GameEvent>();
  
  /// イベントを発火
  void fire(GameEvent event);
}

// =============================================================================
// ボディスプリッターインターフェース
// =============================================================================

/// ボディを分割するインターフェース
abstract class IBodySplitter {
  /// ボディを個々のパーツに分割
  /// 
  /// [body] 分割対象のボディ
  /// 
  /// 戻り値: 分割後の新しいボディのリスト
  List<IAssemblyBody> split(IAssemblyBody body);
}

// =============================================================================
// 設定インターフェース
// =============================================================================

/// 接続システムの設定
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

/// 分離システムの設定
class BreakSystemConfig {
  final double breakProbabilityPerSecond;
  final double separationForceMagnitude;
  final double randomVelocityRange;
  
  const BreakSystemConfig({
    this.breakProbabilityPerSecond = 0.1,
    this.separationForceMagnitude = 3.0,
    this.randomVelocityRange = 1.0,
  });
}

// =============================================================================
// エンティティファクトリインターフェース
// =============================================================================

/// エンティティの生成を担当するインターフェース
abstract class IEntityFactory {
  /// 初期ボディを生成
  /// 
  /// [count] 生成するボディの数
  /// [worldSize] ワールドサイズ（配置範囲）
  List<IAssemblyBody> createInitialBodies(int count, Vector2 worldSize);
}

// =============================================================================
// レンダラーインターフェース
// =============================================================================

/// ボディのレンダリングを担当するインターフェース
/// 
/// SRPに従い、レンダリング責任を分離
abstract class IBodyRenderer {
  /// ボディをキャンバスに描画
  void render(Canvas canvas, IAssemblyBody body);
}
