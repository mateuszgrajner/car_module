abstract class ObdConnection {
  /// Rozpoczyna połączenie
  Future<void> connect();

  /// Rozłącza połączenie
  Future<void> disconnect();

  /// Wysyła komendę i zwraca odpowiedź
  Future<String> sendCommand(String command);
}
