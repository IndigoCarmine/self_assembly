import 'package:flutter/foundation.dart';

/// Game state tracking points, hexamers, and monomers
class GameState extends ChangeNotifier {
  int _points = 100; // Starting points
  int _hexamersFormed = 0;
  int _monomersSpawned = 0;
  double _remainingTime = 120.0; // 2 minutes in seconds
  bool _isGameActive = false;

  int get points => _points;
  int get hexamersFormed => _hexamersFormed;
  int get monomersSpawned => _monomersSpawned;
  double get remainingTime => _remainingTime;
  bool get isGameActive => _isGameActive;
  bool get isGameOver => _remainingTime <= 0;

  /// Calculate assembly ratio: (hexamers × 6) / monomers spawned
  double get assemblyRatio {
    if (_monomersSpawned == 0) return 0.0;
    return (_hexamersFormed * 6) / _monomersSpawned;
  }

  /// Format remaining time as MM:SS
  String get formattedTime {
    final minutes = (_remainingTime / 60).floor();
    final seconds = (_remainingTime % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Start the game
  void startGame() {
    _isGameActive = true;
    _remainingTime = 120.0;
    _points = 100;
    _hexamersFormed = 0;
    _monomersSpawned = 0;
    notifyListeners();
  }

  /// End the game
  void endGame() {
    _isGameActive = false;
    notifyListeners();
  }

  /// Update the timer
  void updateTimer(double dt) {
    if (_isGameActive && _remainingTime > 0) {
      _remainingTime -= dt;
      if (_remainingTime <= 0) {
        _remainingTime = 0;
        endGame();
      }
      notifyListeners();
    }
  }

  /// Add points (e.g., from forming hexamers)
  void addPoints(int amount) {
    _points += amount;
    notifyListeners();
  }

  /// Deduct points (e.g., from spawning monomers)
  /// Returns true if successful, false if insufficient points
  bool deductPoints(int amount) {
    if (_points >= amount) {
      _points -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Increment hexamer count and award points
  void registerHexamer() {
    _hexamersFormed++;
    addPoints(10);
  }

  /// Increment monomer spawned count
  void registerMonomerSpawned() {
    _monomersSpawned++;
    notifyListeners();
  }

  /// Reset the game state
  void reset() {
    _points = 100;
    _hexamersFormed = 0;
    _monomersSpawned = 0;
    _remainingTime = 120.0;
    _isGameActive = false;
    notifyListeners();
  }
}
