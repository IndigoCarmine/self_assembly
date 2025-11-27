## 全体アーキテクチャ

* **World（Forge2D）**

  * 物理更新ループを主管する (Flame Forge2DGame を使用)。
  * PeriodicBoundarySystem を保持（空間トポロジ管理）。
  * 外部から ConnectionSystem / BreakSystem を注入する。
  * 吸引力・剥離判定などはすべて World 更新内で実行。

* **EntityManager**

  * Body（多角形の集合体）を管理。
  * PolygonPart を Body 単位で管理し、合体後は Fixture 統合もしくは Body 再生成を担当。

* **PolygonPart**

  * 1個の多角形パーツ。
  * 複数の Connector を持つ。
  * Body の Fixture として Forge2D 上に存在。

* **Connector**

  * 各 PolygonPart の接続端点。
  * 種類（必ず対になるペア型）と向きを持つ。
  * 特殊データ：座標、接続種別、向き、接続状態。

* **ConnectionSystem**

  * 全 Connector を走査し、近接判定を実施。
  * 条件成立時に吸引力を付与（吸引モデル：**B**）。
  * 一定距離・角度条件を満たした瞬間に接続確定し、Body を統合（位置合わせ：**A**）。

* **BreakSystem**

  * 接続済みペアに対して、時間ベース確率モデルによる剥離判定。
  * 剥離イベントを EntityManager 経由で通知（優先度：**A**）。

* **EventBus**

  * 結合イベント、剥離イベントを発行。
  * World / EntityManager / UI などが購読可能。

---

## 吸引力モデル（B）

* Connector 間距離 `d` に応じて吸引力 `F(d)` を与える。
* 短距離強集中、長距離減衰。
* ポリゴン Body に直接力を加える。

---

## 接続時の位置合わせ（A）

* 接続条件クリア時、以下を実施：

  * 2つの Connector を完全一致する位置まで Body を補正移動。
  * Connector の向きを一致させるための角度補正。
  * Body 再構成（複数 Fixture を統合する方式 B を採用）。

---

## 剥離イベント（優先度 A）

* 接続済み Connector ペアごとに剥離判定。
* 時間ベースの確率モデルを用いる。
* 剥離成立時：

  * Body を分解し、PolygonPart ごとに再 Body 化。
  * 分離イベントを EventBus に通知。

---

## 空間構造（周期境界）

* World に PeriodicBoundarySystem を追加。
* 位置更新時に座標をトーラス空間へ写像 (実装済み: 100x100 ユニット)。
* 近接判定では周期境界を考慮した最短距離を算出。
* 結合判定や吸引力付与も周期境界下の距離で行う。

---

## UI / UX

* **Camera Controls**
  * マウスホイール / ピンチ操作によるズーム機能 (実装済み)。
  * 世界サイズは固定で、表示倍率のみ変化する。