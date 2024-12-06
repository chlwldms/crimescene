import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class GameServerService extends ChangeNotifier {
  // Server Configuration
  static const String serverHost = "127.0.0.1"; // Replace with your server IP
  static const int serverPort = 35398;

  // Private fields
  Socket? _socket;
  String? _clientName;
  bool _isConnected = false;

  // Stream Controllers
  final StreamController<ResponseMessage> _responseController =
  StreamController<ResponseMessage>.broadcast();
  final StreamController<NotifyMessage> _notifyController =
  StreamController<NotifyMessage>.broadcast();

  // Getters
  bool get isConnected => _isConnected;
  Stream<ResponseMessage> get responseStream => _responseController.stream;
  Stream<NotifyMessage> get notifyStream => _notifyController.stream;

  // Connect to the server
  Future<void> connect() async {
    print('Attempting to connect to the server...');
    try {
      _socket = await Socket.connect(serverHost, serverPort);
      _isConnected = true;
      notifyListeners();
      print('Connected to the server.');

      _socket!.listen(
            (List<int> data) {
          _handleIncomingMessage(utf8.decode(data));
        },
        onError: (error) {
          print('Socket error: $error');
          _cleanup();
        },
        onDone: () {
          print('Server connection closed.');
          _cleanup();
        },
      );
    } catch (e) {
      print('Failed to connect to the server: $e');
      throw ServerException('Failed to connect to the server: $e');
    }
  }

  // Handle incoming messages
  void _handleIncomingMessage(String data) {
    try {
      for (String message in data.split('\n')) {
        if (message.trim().isEmpty) continue;

        Map<String, dynamic> json = jsonDecode(message);
        String msgType = json['msgType'];

        if (msgType == MessageType.response) {
          final response = ResponseMessage.fromJson(json);
          if (response.responseType == 'BADREQUEST') {
            _responseController.addError(ServerException(
                response.responseBody ?? 'Unknown server error'));
          } else {
            _responseController.add(response);
          }
        } else if (msgType == MessageType.notify) {
          _notifyController.add(NotifyMessage.fromJson(json));
        } else {
          print('Unknown message type: $msgType');
        }
      }
    } catch (e) {
      print('Error processing message: $e');
      _responseController.addError(ServerException('Message processing error: $e'));
    }
  }

  // Send a request to the server
  Future<void> sendRequest(RequestMessage request) async {
    if (_socket == null || !_isConnected) {
      throw ServerException('Not connected to the server');
    }

    try {
      final jsonString = jsonEncode(request.toJson());
      _socket!.write('$jsonString\n');
      await _socket!.flush();
      print('Request sent: $jsonString');
    } catch (e) {
      print('Error sending request: $e');
      throw ServerException('Failed to send request: $e');
    }
  }

  // Set client name
  Future<void> setName(String name) async {
    _clientName = name;
    await sendRequest(RequestMessage(
      requestType: 'SETNAME',
      sender: 'null',
      requestBody: name,
    ));
  }

  // Send a chat message
  Future<void> sendChat(String message) async {
    if (_clientName == null) {
      throw ServerException('Client name not set. Please set a name first.');
    }

    if (message.trim().isEmpty) {
      throw ServerException('Chat message cannot be empty.');
    }

    await sendRequest(RequestMessage(
      requestType: 'CHAT',
      sender: _clientName!,
      requestBody: message,
    ));
  }

  // Send a request to fetch evidence
  Future<void> fetchEvidence(String location, String object, int clueNumber) async {
    if (_clientName == null) {
      throw ServerException('Client name not set. Please set a name first.');
    }

    final String requestBody = "$location/$object/$clueNumber";
    final RequestMessage request = RequestMessage(
      requestType: 'GETEVIDENCE',
      sender: _clientName!,
      requestBody: requestBody,
    );

    await sendRequest(request);
  }


  // Cleanup resources
  void _cleanup() {
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  // Dispose the service
  @override
  void dispose() {
    _cleanup();
    _responseController.close();
    _notifyController.close();
    super.dispose();
  }
}

// Custom Exception for server errors
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

// Message types for server communication
class MessageType {
  static const String request = "REQUEST";
  static const String response = "RESPONSE";
  static const String notify = "NOTIFY";
}

// Base message class
class BaseMessage {
  final String msgType;
  final String sender;

  BaseMessage({required this.msgType, required this.sender});

  Map<String, dynamic> toJson() => {
    'msgType': msgType,
    'sender': sender,
  };
}

// Request message class
class RequestMessage extends BaseMessage {
  final String requestType;
  final String? requestBody;

  RequestMessage({
    required this.requestType,
    required String sender,
    this.requestBody,
  }) : super(msgType: MessageType.request, sender: sender);

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'requestType': requestType,
    'requestBody': requestBody,
  };
}

// Response message class
class ResponseMessage extends BaseMessage {
  final String responseType;
  final String? responseBody;

  ResponseMessage({
    required this.responseType,
    required this.responseBody,
    required String sender,
  }) : super(msgType: MessageType.response, sender: sender);

  factory ResponseMessage.fromJson(Map<String, dynamic> json) {
    return ResponseMessage(
      responseType: json['responseType'],
      responseBody: json['responseBody'],
      sender: json['sender'],
    );
  }
}

// Notify message class
class NotifyMessage extends BaseMessage {
  final String notifyType;
  final String? notifyBody;

  NotifyMessage({
    required this.notifyType,
    required this.notifyBody,
    required String sender,
  }) : super(msgType: MessageType.notify, sender: sender);

  factory NotifyMessage.fromJson(Map<String, dynamic> json) {
    return NotifyMessage(
      notifyType: json['notifyType'],
      notifyBody: json['notifyBody'],
      sender: json['sender'],
    );
  }
}
