class Logger {
  static void info(String message) {
    _printLog('🟢', 'INFO', message);
  }

  static void error(String message, {Object? error}) {
    _printLog('🔴', 'ERROR', message);
    if (error != null) {
      _printLog('🔴', 'ERROR', 'Error: $error');
    }
  }

  static void debug(String message) {
    _printLog('🔵', 'DEBUG', message);
  }

  static void api(String method, String endpoint) {
    _printLog('🌐', 'API', '$method $endpoint');
  }

  static void _printLog(String emoji, String level, String message) {
    final timestamp = DateTime.now().toString().split(' ')[1];
    print('$emoji $timestamp [$level] $message');
  }
}