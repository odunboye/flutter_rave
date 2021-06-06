import 'dart:async';
import 'dart:io';

class RaveInAppLocalhostServer {
  HttpServer _server;
  int _port = 8184;
  Function(Map<String, dynamic>) _onResponse;

  RaveInAppLocalhostServer(
      {int port = 8184, Function(Map<String, dynamic>) onResponse}) {
    this._port = port;
    this._onResponse = onResponse;
  }

  Future<void> start() async {
    if (this._server != null) {
      throw Exception('Server already started on http://127.0.0.1:$_port');
    }
    var completer = new Completer();
    runZoned(() {
      HttpServer.bind('127.0.0.1', _port).then((server) {
        this._server = server;
        server.listen((HttpRequest request) async {
          var qParams = request.requestedUri.queryParameters;
          if (this._onResponse != null) {
            this._onResponse(qParams);
          }
          request.response.close();
        });

        completer.complete();
      });
    }, onError: (e, stackTrace) => print('Error: $e $stackTrace'));

    return completer.future;
  }

  ///Closes the server.
  Future<void> close() async {
    if (this._server != null) {
      await this._server.close(force: true);

      this._server = null;
    }
  }
}
